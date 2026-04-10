import pandas as pd
import pyomo.environ as pyo
from pyomo.opt import SolverFactory

def leer_datos(nombre_archivo, version):
    # Cargar el archivo
    xl = pd.ExcelFile(nombre_archivo)

    # Hoja DEMANDA
    df_dem = xl.parse('DEMANDA', header=0)

    df_dem_long = df_dem.melt(id_vars=[df_dem.columns[0]], var_name='mes', value_name='cantidad')
    df_dem_long.columns = ['id', 'mes', 'cantidad']

    # Limpiar
    df_dem_long['mes'] = df_dem_long['mes'].str.strip()
    df_dem_long['cantidad'] = pd.to_numeric(df_dem_long['cantidad'])

    # Separar comunidad y tipo de arroz
    patron = r'^(?P<comunidad>.*?)\s+(?P<producto>A\d+)$'
    df_dem_long[['comunidad', 'producto']] = df_dem_long['id'].str.strip().str.extract(patron)

    # crear diccionarios
    demanda_dict = df_dem_long.set_index(['comunidad', 'producto', 'mes'])['cantidad'].to_dict()

    # Hoja PRODUCCION
    df_costes = xl.parse('PRODUCCION', header=0)

    # Limpieza
    col_tipo = df_costes.columns[0]
    col_mes = df_costes.columns[1]
    df_costes[col_tipo] = df_costes[col_tipo].astype(str).str.strip()
    df_costes[col_mes] = df_costes[col_mes].astype(str).str.strip()

    df_costes_indexed = df_costes.set_index([col_tipo, col_mes])

    # Crear los diccionarios
    coste_est_dict = df_costes_indexed[df_costes.columns[3]].to_dict()
    coste_ext_dict = df_costes_indexed[df_costes.columns[4]].to_dict()

    # Hoja ALMACENAMIENTO
    df_alm = xl.parse('ALMACENAMIENTO', header=0, nrows=2)
    df_alm_indexed = df_alm.set_index(df_alm.columns[0])

    # Crear todos los diccionarios
    cap_alm_dict = df_alm_indexed[df_alm.columns[4]].to_dict()
    cap_mensual_planta = df_alm_indexed[df_alm.columns[2]].to_dict()
    cap_mensual_planta_extra = df_alm_indexed[df_alm.columns[3]].to_dict()
    coste_ton_mes = df_alm_indexed[df_alm.columns[5]].to_dict()

    # Hoja TRANSPORTE
    df_tra = xl.parse('TRANSPORTE', skiprows=13, nrows=2, usecols="A:F", header=None)
    df_tra.columns = ['planta', 'Andalucía', 'Aragón', 'Cataluña', 'Comunidad Valenciana', 'Madrid']
    coste_alquiler_dict = df_tra.set_index('planta').stack().to_dict()
    
    if version ==2: 
         #Hoja  FLOTA 
         df_flota = xl.parse('FLOTA', header=0, nrows=2)
         df_cupos = df_flota.iloc[:, 0:6].set_index(df_flota.columns[0])
         cupo_base_dict = df_cupos.stack().to_dict()
         
         # Leer el recargo de la celda A6 
         df_recargo = xl.parse('FLOTA', header=None, skiprows=5, nrows=1, usecols="A")
         recargo_val = float(df_recargo.iloc[0,0])
         return (demanda_dict,coste_est_dict,coste_ext_dict, cap_alm_dict, cap_mensual_planta, cap_mensual_planta_extra, coste_ton_mes, coste_alquiler_dict, cupo_base_dict, recargo_val )
    
    return (demanda_dict,coste_est_dict,coste_ext_dict, cap_alm_dict, cap_mensual_planta, cap_mensual_planta_extra, coste_ton_mes, coste_alquiler_dict)  



def resolver_modelo1(nombre_archivo, nombresalida):
    # Obtener los parámetros
    (demanda_dict, coste_est_dict, coste_ext_dict, cap_alm_dict, cap_mensual_planta, cap_mensual_planta_extra,
     coste_ton_mes, coste_alquiler_dict) = leer_datos(nombre_archivo, 1)

    # Modelo
    ccaa = ['Andalucía', 'Aragón', 'Cataluña', 'Comunidad Valenciana', 'Madrid']
    tipo_arroz = ['A1', 'A2', 'A3', 'A4']
    plantas = ['Planta Sevilla', 'Planta Valencia']
    meses = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
             'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']

    model = pyo.ConcreteModel()
    model.name = 'Distribucion de arroz'

    # ==============================================================
    # Conjuntos de indices
    model.iCCAA = pyo.Set(initialize=ccaa, doc='Comunidades Autonomas')
    model.iPlanta = pyo.Set(initialize=plantas, doc='Plantas produccion')
    model.iArroz = pyo.Set(initialize=tipo_arroz, doc='Tipos de arroz')
    model.iMes = pyo.Set(initialize=meses, doc='Meses')

    # ==============================================================
    # Parametros

    # Demanda y produccion
    doc = 'Demanda de arroz tipo k en comunidad j en mes t'
    model.d = pyo.Param(model.iCCAA, model.iArroz, model.iMes, doc=doc, initialize=demanda_dict)

    doc = 'Capacidad de produccion en planta i en mes t'  # O independiente de t
    model.prod = pyo.Param(model.iPlanta, doc=doc, initialize=cap_mensual_planta)

    doc = 'Capacidad de produccion extra en planta i en mes t'
    model.prodExtra = pyo.Param(model.iPlanta, doc=doc, initialize=cap_mensual_planta_extra)

    doc = 'Coste de produccion por tonelada de arroz k en mes t'
    model.costProd = pyo.Param(model.iArroz, model.iMes, doc=doc, initialize=coste_est_dict)

    doc = 'Coste extra de produccion'
    model.costProdExtra = pyo.Param(model.iArroz, model.iMes, doc=doc, initialize=coste_ext_dict)

    # Inventario
    doc = 'Capacidad de almacenamiento en planta i'
    model.store = pyo.Param(model.iPlanta, doc=doc, initialize=cap_alm_dict)
    

    doc = 'Coste almacenamiento (por tn) de arroz tipo k en planta i en mes t'  # !
    model.storeC = pyo.Param(model.iPlanta, doc=doc, initialize=coste_ton_mes)

    # Transporte
    doc = 'Capacidad de carga de un camion'
    model.capCam = pyo.Param(initialize=25, doc=doc)

    doc = 'Coste transporte de planta i a comunidad j (por camion)'
    model.cTrans = pyo.Param(model.iPlanta, model.iCCAA, doc=doc, initialize=coste_alquiler_dict)

    # ==============================================================
    # Variables

    doc = 'Produccion de arroz tipo k en planta i en mes t'
    model.P = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals, doc=doc)

    doc = 'Produccion extra de arroz tipo k en planta i en mes t'
    model.PExtra = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals, doc=doc)

    doc = 'Inventario de arroz tipo k en planta i al final del mes t'
    model.I = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals, doc=doc)

    doc = 'Envio (en tn) de arroz tipo k de planta i a destino j en mes t'
    model.Q = pyo.Var(model.iPlanta, model.iCCAA, model.iArroz, model.iMes, within=pyo.NonNegativeReals, doc=doc)

    doc = 'Numero de camiones alquilados para transportar de i a j en mes t'
    model.nCam = pyo.Var(model.iPlanta, model.iCCAA, model.iMes, within=pyo.NonNegativeIntegers, doc=doc)

    # ==============================================================
    # Restricciones

    def res_demanda(model, j, k, t):
        expr = pyo.quicksum([model.Q[i, j, k, t] for i in model.iPlanta])
        return expr >= model.d[j, k, t]
    model.resCap = pyo.Constraint(model.iCCAA, model.iArroz, model.iMes, rule=res_demanda, doc='La demanda debe ser satisfecha')

    def res_balance(model, i, k, t):
        v = model.P[i, k, t] + model.PExtra[i, k, t]
        v -= pyo.quicksum([model.Q[i, j, k, t] for j in model.iCCAA])
        if t != 'ENERO':  # I_{ik0} = 0
            index_mes = list(model.iMes).index(t)
            v += model.I[i, k, list(model.iMes)[index_mes - 1]]  # Mes anterior
        return model.I[i, k, t] == v
    model.resInv = pyo.Constraint(model.iPlanta, model.iArroz, model.iMes, rule=res_balance, doc='Conservacion del nivel de inventario por tipo de arroz')

    def res_pro_normal(model, i, t):
        expr = pyo.quicksum([model.P[i, k, t] for k in model.iArroz])
        return expr <= model.prod[i]
    model.resProd = pyo.Constraint(model.iPlanta, model.iMes, rule=res_pro_normal, doc='Restriccion de capacidad de produccion normal')

    def res_pro_extra(model, i, t):
        expr = pyo.quicksum([model.PExtra[i, k, t] for k in model.iArroz])
        return expr <= model.prodExtra[i]
    model.resProdEx = pyo.Constraint(model.iPlanta, model.iMes, rule=res_pro_extra, doc='Restriccion de capacidad de produccion extra')

    def res_almacenamiento(model, i, t):
        expr = pyo.quicksum([model.I[i, k, t] for k in model.iArroz])
        return expr <= model.store[i]
    model.resStore = pyo.Constraint(model.iPlanta, model.iMes, rule=res_almacenamiento, doc='Capacidad de almacenamiento')

    def res_camiones(model, i, j, t):
        expr = pyo.quicksum([model.Q[i, j, k, t] for k in model.iArroz])
        return expr <= model.nCam[i, j, t] * model.capCam
    model.resCam = pyo.Constraint(model.iPlanta, model.iCCAA, model.iMes, rule=res_camiones, doc='Numero de camiones')
    

    # ==============================================================
    # Funcion objetivo

    def objetivo(model):
        # Produccion
        indices = [(i, k, t) for i in model.iPlanta for k in model.iArroz for t in model.iMes]

        expr = pyo.quicksum([model.P[a] * model.costProd[a[1:]] for a in indices])
        expr += pyo.quicksum([model.PExtra[a] * model.costProdExtra[a[1:]] for a in indices])

        # Inventario
        expr += pyo.quicksum([model.I[a] * model.storeC[a[0]] for a in indices])

        # Transporte
        indices = [(i, j, t) for i in model.iPlanta for j in model.iCCAA for t in model.iMes]

        expr += pyo.quicksum([model.nCam[a] * model.cTrans[a[:-1]] for a in indices])

        return expr

    # ==============================================================
    # Resolucion

    model.obj = pyo.Objective(rule=objetivo, sense=pyo.minimize)
    optimizer = SolverFactory('gurobi')
    optimizer.solve(model, tee=1)

    escribir(model, 1, nombresalida)
    
       

def resolver_modelo2(nombre_archivo, nombresalida):
    # 1. Obtener los parámetros 
    (demanda_dict, coste_est_dict, coste_ext_dict, cap_alm_dict, 
     cap_mensual_planta, cap_mensual_planta_extra, coste_ton_mes, 
     coste_alquiler_dict, cupo_base_dict, recargo_val) = leer_datos(nombre_archivo, 2)

    # 2. Configuración de conjuntos
    ccaa = ['Andalucía', 'Aragón', 'Cataluña', 'Comunidad Valenciana', 'Madrid']
    tipo_arroz = ['A1', 'A2', 'A3', 'A4']
    plantas = ['Planta Sevilla', 'Planta Valencia']
    meses = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
             'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']

    model = pyo.ConcreteModel()
    model.name = 'Distribucion de arroz - Flota Mixta'

    # Conjuntos de indices
    model.iCCAA = pyo.Set(initialize=ccaa)
    model.iPlanta = pyo.Set(initialize=plantas)
    model.iArroz = pyo.Set(initialize=tipo_arroz)
    model.iMes = pyo.Set(initialize=meses)

    # 3. Parámetros
    model.d = pyo.Param(model.iCCAA, model.iArroz, model.iMes, initialize=demanda_dict)
    model.prod = pyo.Param(model.iPlanta, initialize=cap_mensual_planta)
    model.prodExtra = pyo.Param(model.iPlanta, initialize=cap_mensual_planta_extra)
    model.costProd = pyo.Param(model.iArroz, model.iMes, initialize=coste_est_dict)
    model.costProdExtra = pyo.Param(model.iArroz, model.iMes, initialize=coste_ext_dict)
    model.store = pyo.Param(model.iPlanta, initialize=cap_alm_dict)
    model.storeC = pyo.Param(model.iPlanta, initialize=coste_ton_mes)
    model.capCam = pyo.Param(initialize=25)
    model.cTrans = pyo.Param(model.iPlanta, model.iCCAA, initialize=coste_alquiler_dict)
    
    # Parámetros específicos de la versión 2
    model.cupoBase = pyo.Param(model.iPlanta, model.iCCAA, initialize=cupo_base_dict)
    model.recargoExtra = pyo.Param(initialize=recargo_val)
    model.pSeguridad = pyo.Param(initialize=0.10) # 10% de seguridad

    # 4. Variables
    model.P = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals)
    model.PExtra = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals)
    model.I = pyo.Var(model.iPlanta, model.iArroz, model.iMes, within=pyo.NonNegativeReals)
    model.Q = pyo.Var(model.iPlanta, model.iCCAA, model.iArroz, model.iMes, within=pyo.NonNegativeReals)
    
    # Variables de camiones desglosadas
    model.nBase = pyo.Var(model.iPlanta, model.iCCAA, model.iMes, within=pyo.NonNegativeIntegers)
    model.nExtra = pyo.Var(model.iPlanta, model.iCCAA, model.iMes, within=pyo.NonNegativeIntegers)

    # 5. Restricciones 
    def res_demanda(model, j, k, t):
        return pyo.quicksum(model.Q[i, j, k, t] for i in model.iPlanta) >= model.d[j, k, t]
    model.resCap = pyo.Constraint(model.iCCAA, model.iArroz, model.iMes, rule=res_demanda)

    def res_balance(model, i, k, t):
        v = model.P[i, k, t] + model.PExtra[i, k, t]
        v -= pyo.quicksum(model.Q[i, j, k, t] for j in model.iCCAA)
        if t != 'ENERO':
            idx = list(model.iMes).index(t)
            v += model.I[i, k, list(model.iMes)[idx - 1]]
        return model.I[i, k, t] == v
    model.resInv = pyo.Constraint(model.iPlanta, model.iArroz, model.iMes, rule=res_balance)
    
    def res_pro_normal(m, i, t):
        total_producido = sum(m.P[i, k, t] for k in m.iArroz)
        return total_producido <= m.prod[i]
    model.resProd = pyo.Constraint(model.iPlanta, model.iMes, rule=res_pro_normal)
    
    
    def res_pro_extra(m, i, t):
        total_extra = sum(m.PExtra[i, k, t] for k in m.iArroz)
        return total_extra <= m.prodExtra[i]
    model.resProdEx = pyo.Constraint(model.iPlanta, model.iMes, rule=res_pro_extra)
    
    def res_almacenamiento(m, i, t):
            total_almacenado = sum(m.I[i, k, t] for k in m.iArroz)
            return total_almacenado <= m.store[i]
    model.resStore = pyo.Constraint(model.iPlanta, model.iMes, rule=res_almacenamiento)

    # Límite de camiones de contrato (Cupo)
    def res_cupo_base(m, i, j, t):
        return m.nBase[i, j, t] <= m.cupoBase[i, j]
    model.resCupoBase = pyo.Constraint(model.iPlanta, model.iCCAA, model.iMes, rule=res_cupo_base)

    # Capacidad de transporte (Base + Extra)
    def res_cam_mixto(m, i, j, t):
        return pyo.quicksum(m.Q[i, j, k, t] for k in m.iArroz) <= (m.nBase[i, j, t] + m.nExtra[i, j, t]) * m.capCam
    model.resCam = pyo.Constraint(model.iPlanta, model.iCCAA, model.iMes, rule=res_cam_mixto)

    # Stock de seguridad
    def res_stock_seguridad(m, i, k, t):
        # Si es ENERO, no aplicamos la restricción (comenzamos vacíos)
        if t == 'ENERO':
            return pyo.Constraint.Skip
        
        lista_meses = list(m.iMes)
        idx_actual = lista_meses.index(t)
        
        # Lógica para el mes siguiente
        if t != 'DICIEMBRE':
            mes_siguiente = lista_meses[idx_actual + 1]
        else:
            # Para Diciembre, tomamos la demanda de ENERO (suponiendo ciclo anual)
            mes_siguiente = 'ENERO' 
            
        # Suma de demanda de todas las comunidades para el arroz k en el mes t+1
        demanda_proxima = sum(m.d[j, k, mes_siguiente] for j in m.iCCAA)
            
        # El inventario al final del mes t debe cubrir el 10% de la demanda del mes siguiente
        return m.I[i, k, t] >= m.pSeguridad * demanda_proxima
    
    model.resSeguridad = pyo.Constraint(model.iPlanta, model.iArroz, model.iMes, rule=res_stock_seguridad)
    
    # 6. Función Objetivo
    def objetivo_v2(model):
        # Costes de Producción e Inventario
        indices = [(i, k, t) for i in model.iPlanta for k in model.iArroz for t in model.iMes]
        costo_prod = pyo.quicksum(model.P[a] * model.costProd[a[1:]] + model.PExtra[a] * model.costProdExtra[a[1:]] for a in indices)
        costo_inv = pyo.quicksum(model.I[a] * model.storeC[a[0]] for a in indices)

        # Costes de Transporte (Base y Extra con recargo)
        indices_trans = [(i, j, t) for i in model.iPlanta for j in model.iCCAA for t in model.iMes]
        costo_trans = pyo.quicksum(model.nBase[a] * model.cTrans[a[:-1]] + 
                                   model.nExtra[a] * (model.cTrans[a[:-1]] + model.recargoExtra) 
                                   for a in indices_trans)

        return costo_prod + costo_inv + costo_trans

    model.obj = pyo.Objective(rule=objetivo_v2, sense=pyo.minimize)

    # 7. Resolución
    optimizer = SolverFactory('gurobi')
    
    optimizer.solve(model, tee=True)

    # 8. Guardar resultados (enviando version=2)
    escribir(model, 2, nombresalida)    
    
    

def escribir(model_resuelto, version, nombresalida):
    meses_ordenados = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 
                       'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']

    # --- Variables comunes a ambas versiones ---
    resultados_envios = [{'Planta': i, 'Comunidad': j, 'Tipo': k, 'Mes': t, 'Cantidad': model_resuelto.Q[i, j, k, t].value}
                          for i in model_resuelto.iPlanta for j in model_resuelto.iCCAA for k in model_resuelto.iArroz for t in model_resuelto.iMes]
    df_Q = pd.DataFrame(resultados_envios).pivot(index=['Planta', 'Comunidad', 'Tipo'], columns='Mes', values='Cantidad')[meses_ordenados]

    result_Xest = [{'Planta': i, 'Tipo': k, 'Mes': t, 'Cantidad': model_resuelto.P[i, k, t].value} 
                   for i in model_resuelto.iPlanta for k in model_resuelto.iArroz for t in model_resuelto.iMes]
    df_Xest = pd.DataFrame(result_Xest).pivot(index=['Planta', 'Tipo'], columns='Mes', values='Cantidad')[meses_ordenados]

    result_Xext = [{'Planta': i, 'Tipo': k, 'Mes': t, 'Cantidad': model_resuelto.PExtra[i, k, t].value} 
                   for i in model_resuelto.iPlanta for k in model_resuelto.iArroz for t in model_resuelto.iMes]
    df_Xext = pd.DataFrame(result_Xext).pivot(index=['Planta', 'Tipo'], columns='Mes', values='Cantidad')[meses_ordenados]

    result_Iinv = [{'Planta': i, 'Tipo': k, 'Mes': t, 'Cantidad': model_resuelto.I[i, k, t].value} 
                   for i in model_resuelto.iPlanta for k in model_resuelto.iArroz for t in model_resuelto.iMes]
    df_Iinv = pd.DataFrame(result_Iinv).pivot(index=['Planta', 'Tipo'], columns='Mes', values='Cantidad')[meses_ordenados]

    # --- Escritura en Excel ---
    with pd.ExcelWriter(nombresalida + '.xlsx') as writer:
        start_row = 0
        
        # 1. Envíos
        pd.DataFrame(['Variables Q: ENVÍOS']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
        df_Q.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)
        start_row += len(df_Q) + 4

        # 2. Producción Estándar
        pd.DataFrame(['Variables Xest: PRODUCCIÓN ESTÁNDAR']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
        df_Xest.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)
        start_row += len(df_Xest) + 4

        # 3. Producción Extra
        pd.DataFrame(['Variables Xext: PRODUCCIÓN EXTRA']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
        df_Xext.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)
        start_row += len(df_Xext) + 4

        # 4. Inventarios
        pd.DataFrame(['Variables Inv: INVENTARIOS']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
        df_Iinv.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)
        start_row += len(df_Iinv) + 4
        
        #  5. Camiones ---
        if version == 1:
            result_N = [{'Planta': i, 'Comunidad': j, 'Mes': t, 'Cantidad': model_resuelto.nCam[i, j, t].value} 
                        for i in model_resuelto.iPlanta for j in model_resuelto.iCCAA for t in model_resuelto.iMes]
            df_N = pd.DataFrame(result_N).pivot(index=['Planta', 'Comunidad'], columns='Mes', values='Cantidad')[meses_ordenados]
            
            pd.DataFrame(['Variables N: CAMIONES']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
            df_N.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)

        else: # Versión 2: Camiones Base y Extra
            # Extraer camiones Base
            result_nBase = [{'Planta': i, 'Comunidad': j, 'Mes': t, 'Cantidad': model_resuelto.nBase[i, j, t].value} 
                            for i in model_resuelto.iPlanta for j in model_resuelto.iCCAA for t in model_resuelto.iMes]
            df_nBase = pd.DataFrame(result_nBase).pivot(index=['Planta', 'Comunidad'], columns='Mes', values='Cantidad')[meses_ordenados]
            
            # Extraer camiones Extra
            result_nExtra = [{'Planta': i, 'Comunidad': j, 'Mes': t, 'Cantidad': model_resuelto.nExtra[i, j, t].value} 
                             for i in model_resuelto.iPlanta for j in model_resuelto.iCCAA for t in model_resuelto.iMes]
            df_nExtra = pd.DataFrame(result_nExtra).pivot(index=['Planta', 'Comunidad'], columns='Mes', values='Cantidad')[meses_ordenados]

            # Escribir Base
            pd.DataFrame(['Variables nBase: CAMIONES CONTRATO (CUPO)']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
            df_nBase.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)
            start_row += len(df_nBase) + 4
            
            # Escribir Extra
            pd.DataFrame(['Variables nExtra: CAMIONES EXTRA (CON RECARGO)']).to_excel(writer, sheet_name='Resultados', startrow=start_row, index=False, header=False)
            df_nExtra.to_excel(writer, sheet_name='Resultados', startrow=start_row + 1)        


# Ejecución:
resolver_modelo1('Datos.xlsx', 'Resultados_V1')

resolver_modelo2('Datos.xlsx', 'Resultados_V2')