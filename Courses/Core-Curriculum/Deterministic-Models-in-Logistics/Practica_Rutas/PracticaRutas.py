# -*- coding: utf-8 -*-
"""
Created on Tue Nov 25 17:24:03 2025

@author: usu319
"""

# MODELO DE RUTAS DE VEHÍCULOS CON CAPACIDAD Y TIEMPOS DE DISPONIBILIDAD 
#
# Problema: Planificar las rutas para 3 vehículos (K) para atender a 5 clientes (Nodos 1 a 5)
#           desde un depósito (D_ini/D_fin), con el objetivo de MINIMIZAR Z, tiempo total
#           de finalización de la última ruta).

# Características de la Instancia:
#  Flota: 3 vehículos con distintas capacidades y diferentes tiempos de inicio de
#  operación.
#  Demandas: Mixtas (Entrega y Recogida).
#   - Np (/Recogida, p > 0): Clientes {1, 4}.
#   - Nd (Entrega, p < 0): Clientes {2, 3, 5}.
#
# Variables Clave:
#   - X[i,j,k]: 1 si el vehículo k viaja del nodo i al j.
#   - T[i,k]: Tiempo de llegada del vehículo k al nodo i.
#   - C[i,k]: Carga del vehículo k al salir del nodo i.
#   - Z: Tiempo objetivo a minimizar.

import pyomo.environ as pyo
from pyomo.opt import SolverFactory


# ---------------------------
# 1. DATOS
# ---------------------------

K = ['V1','V2','V3']
Np = [1,4]
Nd = [2,3,5]
N = sorted(set(Np) | set(Nd))
Nmas = N + ['D_ini','D_fin']

q = {'V1':6, 'V2':5, 'V3':4}
a = {'V1':60, 'V2':30, 'V3':0}
dem = {1:4, 2:3, 3:4, 4:2, 5:2}
p = {i: (dem[i] if i in Np else -dem[i]) for i in N} # p_i con signo 

t = {
    (1,1):0, (1,2):30, (1,3):60, (1,4):150, (1,5):120,
    (2,1):30, (2,2):0, (2,3):30, (2,4):150, (2,5):150,
    (3,1):60, (3,2):30, (3,3):0, (3,4):90, (3,5):120,
    (4,1):150, (4,2):150, (4,3):90, (4,4):0, (4,5):60,
    (5,1):120, (5,2):150, (5,3):120, (5,4):60, (5,5):0,
    ('D_ini',1):90, ('D_ini',2):120, ('D_ini',3):120, ('D_ini',4):180, ('D_ini',5):180,
    (1,'D_fin'):90, (2,'D_fin'):120, (3,'D_fin'):120, (4,'D_fin'):180, (5,'D_fin'):180,
    ('D_ini','D_fin'):0, ('D_fin','D_ini'):0, ('D_ini','D_ini'):0, ('D_fin','D_fin'):0,
}

for i in N:
    t[(i,'D_ini')] = t[('D_ini',i)]
    t[('D_fin',i)] = t[(i,'D_fin')]


# ---------------------------
# 2. Big-M AJUSTADAS
# ---------------------------

max_t = max(t.values())
num_clients = len(N)

#Big M para el tiempo
M_time = {k: a[k] + (num_clients + 1) * max_t for k in K}

#Big M para la capacidad
M_cap = {k: q[k] + max(dem.values()) for k in K}


# ---------------------------
# 3. MODELO
# ---------------------------

model = pyo.ConcreteModel()

model.K = pyo.Set(initialize=K)
model.N = pyo.Set(initialize=N)
model.Nmas = pyo.Set(initialize=Nmas)
model.Np = pyo.Set(initialize=Np)
model.Nd = pyo.Set(initialize=Nd)

model.q = pyo.Param(model.K, initialize=q)
model.a = pyo.Param(model.K, initialize=a)
model.dem = pyo.Param(model.N, initialize=dem)

# Param p  en Nmas
p_ext = {i: (dem[i] if i in Np else -dem[i]) for i in N}
p_ext['D_ini'] = 0
p_ext['D_fin'] = 0
model.p = pyo.Param(model.Nmas, initialize=p_ext)

# Param t en Nmas x Nmas
model.t = pyo.Param(model.Nmas, model.Nmas, initialize=t)

# Ms como Params
model.M_time = pyo.Param(model.K, initialize=M_time)
model.M_cap = pyo.Param(model.K, initialize=M_cap)

# Variables
model.X = pyo.Var(model.Nmas, model.Nmas, model.K, domain=pyo.Binary)
model.T = pyo.Var(model.Nmas, model.K, domain=pyo.NonNegativeReals)
model.C = pyo.Var(model.Nmas, model.K, domain=pyo.NonNegativeReals)
model.Z = pyo.Var(domain=pyo.NonNegativeReals)

# Objetivo
model.obj = pyo.Objective(expr=model.Z, sense=pyo.minimize)


# ---------------------------
# 4. RESTRICCIONES
# ---------------------------

# ---- (0) ACOPLAMIENTO Z >= T_Dfin
def Res0(model,k):
    return model.Z >= model.T['D_fin',k]
model.Res0 = pyo.Constraint(model.K, rule=Res0)


# ---- (1) VISITA ÚNICA
def Res11(model,i):
    return sum(model.X[i,j,k] for j in model.Nmas if j!=i for k in model.K) == 1
model.Res11 = pyo.Constraint(model.N, rule=Res11)

def Res12(model,j):
    return sum(model.X[i,j,k] for i in model.Nmas if i!=j for k in model.K) == 1
model.Res12 = pyo.Constraint(model.N, rule=Res12)


# ---- (2) DEPÓSITOS
def Res21(model,k):
    return sum(model.X['D_ini',j,k] for j in model.N) <= 1
model.Res21 = pyo.Constraint(model.K, rule=Res21)

def Res22(model,k):
    return sum(model.X[i,'D_fin',k] for i in model.N) <= 1
model.Res22 = pyo.Constraint(model.K, rule=Res22)

def Res23(model,i,k):
    # prohibir entrar al depósito inicial 
    if i != 'D_ini':
        return model.X[i,'D_ini',k] == 0
    return pyo.Constraint.Skip
model.Res23 = pyo.Constraint(model.Nmas, model.K, rule=Res23)

def Res24(model,k):
    return model.X['D_ini','D_fin',k] == 0
model.Res24 = pyo.Constraint(model.K, rule=Res24)


# ---- (3) FLUJO CONTINUO
def Res3(model,i,k):
    return sum(model.X[i,j,k] for j in model.Nmas if j!=i) == sum(model.X[j,i,k] for j in model.Nmas if j!=i)
model.Res3 = pyo.Constraint(model.N, model.K, rule=Res3)


# ---- (4) TIEMPOS
def Res41(model,k):
    return model.T['D_ini',k] >= model.a[k] * sum(model.X['D_ini',j,k] for j in model.N)
model.Res41 = pyo.Constraint(model.K, rule=Res41)

def Res42(model,k):
    return model.T['D_ini',k] <= model.M_time[k] * sum(model.X['D_ini',j,k] for j in model.N)
model.Res42 = pyo.Constraint(model.K, rule=Res42)

def Res_seq1(model,i,j,k):
    if i != j:
        return model.T[i,k] + model.t[i,j] - model.T[j,k] <= (1-model.X[i,j,k]) * model.M_time[k]
    return pyo.Constraint.Skip
model.Res_seq1 = pyo.Constraint(model.Nmas, model.Nmas, model.K, rule=Res_seq1)

def Res_seq2(model,i,j,k):
    if i != j:
        return model.T[i,k] + model.t[i,j] - model.T[j,k] >= -(1-model.X[i,j,k]) * model.M_time[k]
    return pyo.Constraint.Skip
model.Res_seq2 = pyo.Constraint(model.Nmas, model.Nmas, model.K, rule=Res_seq2)

def Res45(model,k):
    return model.T['D_fin',k] <= model.M_time[k] * sum(model.X[i,'D_fin',k] for i in model.N)
model.Res45 = pyo.Constraint(model.K, rule=Res45)


# ---- (5) CAPACIDAD
def Res51(model,k):
    return model.C['D_ini',k] == sum(model.dem[i] * sum(model.X[i,j,k] for j in model.Nmas if j!=i) for i in model.Nd)
model.Res51 = pyo.Constraint(model.K, rule=Res51)

def Res52(model,i,j,k):
    if i != j:
        return model.C[i,k] + model.p[j] - model.C[j,k] <= (1-model.X[i,j,k]) * model.M_cap[k]
    return pyo.Constraint.Skip
model.Res52 = pyo.Constraint(model.Nmas, model.Nmas, model.K, rule=Res52)

def Res53(model,i,j,k):
    if i != j:
        return model.C[i,k] + model.p[j] - model.C[j,k] >= -(1-model.X[i,j,k]) * model.M_cap[k]
    return pyo.Constraint.Skip
model.Res53 = pyo.Constraint(model.Nmas, model.Nmas, model.K, rule=Res53)

def Res54(model,i,k):
    return model.C[i,k] <= model.q[k] * sum(model.X[i,j,k] for j in model.Nmas if j !='D_ini')
model.Res54 = pyo.Constraint(model.Nmas, model.K, rule=Res54)


# ==========================================================
# 6. SOLVER
# ==========================================================

solver = SolverFactory('glpk')

res = solver.solve(model, tee=True)

print("\n================= DETALLE DE VARIABLES =================")
model.display()


# ==========================================================
# 7. IMPRESIÓN DE LAS RUTAS 
# ==========================================================

def Ruta (model, k):
    
    """Reconstruye la ruta secuencialmente a partir de X."""
    
    start = None
    for j in model.N:
        if model.X['D_ini',j,k].value == 1:
            start = j
            break
    if start is None:
        return ["Vehículo no usado"]

    ruta = ['D_ini', start]
    actual = start

    while actual != 'D_fin':
        next_node = None
        for j in model.Nmas:
            if j != actual and model.X[actual,j,k].value == 1:
                next_node = j
                ruta.append(j)
                actual = j
                break
        if next_node is None:
            break

    return ruta


print("\n================= RUTAS OBTENIDAS =================")
for k in K:
    ruta = Ruta(model, k)
    if ruta == ["Vehículo no usado"]:
        print(f"\nVehículo {k}: NO USADO")
    else:
        pretty = " → ".join(str(x) for x in ruta)
        print(f"\nVehículo {k}: {pretty}")

print("\nValor óptimo Z:", model.Z.value)



# ==========================================================
# 8. DETALLE DE TIEMPOS Y CARGAS
# ==========================================================

print("\n================= TIEMPOS Y CARGAS CLAVE =================")
for k in K:
    # Comprobar si el vehículo fue utilizado
    ruta = Ruta(model, k)
    if ruta != ["Vehículo no usado"]:
        # T_ini,k : Tiempo de salida del depósito inicial (D_ini)
        t_ini_k = model.T['D_ini', k].value
        
        # T_fin,k : Tiempo de llegada al depósito final (D_fin)
        t_fin_k = model.T['D_fin', k].value
        
        # C_ini,k : Carga al salir del depósito inicial (D_ini)
        c_ini_k = model.C['D_ini', k].value
        
        print(f"\n--- Vehículo {k} (Capacidad: {model.q[k]}, Disponibilidad: {model.a[k]}) ---") 
        print(f"Ruta: {' → '.join(str(x) for x in ruta)}")
        print(f"Carga Inicial (C_ini): {c_ini_k}")
        print(f"Tiempo de Inicio (T_ini): {t_ini_k}")
        print(f"Tiempo de Finalización (T_fin): {t_fin_k}")
    else:
        print(f"\n--- Vehículo {k}: NO USADO ---")

print("\nValor óptimo Z (Max de T_fin):", model.Z.value)
