#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  9 10:51:25 2025

@author: cati
"""

INF = float('inf')

# ---------------------------------------------------------------------
# BLOQUE 1: REPRESENTACION DEL GRAFO POR MATRIZ DE ADYACENCIA
# ---------------------------------------------------------------------


def aristas_a_matriz(aristas: dict, nodos: list):
    
    """
    Convierte la representación del grafo de aristas (diccionario) a una
    matriz de adyacencia.
    """
    
    num_nodos = len(nodos)
    
    # 1. Inicializar la matriz con 0 en la diagonal e INF en el resto
    matriz_adyacencia = []
    for i in range (0,num_nodos): 
        fila = []
        for j in range (0,num_nodos): 
            if (i==j): 
                fila.append(0.0)
            else:
                fila.append(INF)
        matriz_adyacencia.append(fila)
        
    # 2. Mapear nombres de nodos a índices (0, 1, 2, ...)    
    mapeo_nodos = {nodo: i for i, nodo in enumerate(nodos)}
    
    # 3. Rellenar la matriz con los pesos de las aristas
    for arista, peso in aristas.items(): 
        # Las aristas se esperan en formato 'Origen-Destino'
        salida, llegada = arista.split('-')
        i = mapeo_nodos[salida]
        j = mapeo_nodos[llegada] 
        matriz_adyacencia[i][j] = float(peso)
    
    return matriz_adyacencia


# -----------------------------------------------------------------------------
# BLOQUE 2: FUNCIONES AUXILIARES 
# -----------------------------------------------------------------------------

def Buscar_minimo (vector_u, lista_estados): 
    
    """
    Busca el nodo con la menor distancia (mínimo) entre aquellos que
    aún están en estado Temporal ('T').
    """

    minimo = INF 
    minimo_posicion = -1
    
    # Recorrer todas las distancias
    for i in range (0,len(vector_u)): 
        if lista_estados[i] == 'T':
            # Solo considerar nodos temporales
            candidato = vector_u[i] 
    
            # Comprobar si el candidato es menor que el mínimo actual y es accesible (no INF)
            if  candidato < minimo and candidato != INF: 
                minimo = candidato
                minimo_posicion = i # Guardar el índice (posición) del nodo mínimo
    
    # Determinar si se encontró un nodo factible           
    encontrado = (minimo_posicion != -1)
    
    return encontrado, minimo_posicion 


def Actualizar_vectores(vector_u, lista_estados, lista_predecesor, matriz, minimo_posicion): 
    
    """
    Realiza la operación de relajación: actualiza las distancias de los
    nodos vecinos si se encuentra un camino más corto a través del
    nodo recién etiquetado como permanente (minimo_posicion).
    """
    
    for j in range (0, len(vector_u)): 
       
        if (lista_estados[j] == 'T'): 
        
            if vector_u[minimo_posicion]+ matriz[minimo_posicion][j] < vector_u[j]: 
            
                vector_u[j] = vector_u[minimo_posicion]+ matriz[minimo_posicion][j]
                lista_predecesor[j] = minimo_posicion
    
    return vector_u, lista_estados, lista_predecesor



# ---------------------------------------------------------------------
# BLOQUE 3: ALGORITMO PRINCIPAL Y FUNCIONES DE EJECUCION
# ---------------------------------------------------------------------

def Algoritmo_Dijkstra(aristas: dict, nodos: list, nodo_raiz): 
    
    """
    Implementación principal del Algoritmo de Dijkstra basado en matriz.
    """
    
    num_nodos = len(nodos)
    mapeo_nodos = {nodo: i for i, nodo in enumerate(nodos)}
    
    
    # 1. Validación de la raíz
    if nodo_raiz not in mapeo_nodos:
        return "ERROR: Nodo raíz no encontrado.", None, None
    
    # 2. Conversión a matriz y obtención de distancias iniciales
    matriz_adyacencia = aristas_a_matriz(aristas, nodos)
    
    # El vector u (distancias) se inicializa con la fila de la matriz de la raíz
    vector_u = matriz_adyacencia[mapeo_nodos[nodo_raiz]].copy()
    
    # 3. Inicialización de estados y predecesores
    lista_estados = ['T']* num_nodos
    lista_estados[mapeo_nodos[nodo_raiz]] = 'P'
    # Inicialmente, todos los nodos tienen la raíz como su predecesor (si es accesible)
    lista_predecesor = [mapeo_nodos[nodo_raiz]]* num_nodos
    
    m = 1 # Contador de nodos etiquetados permanentemente
    
    # 4. Bucle principal de Dijkstra 
    while m < num_nodos : 
        # a. Buscar el nodo temporal más cercano
        encontrado, minimo_posicion = Buscar_minimo(vector_u, lista_estados)  
        
        # b. Si no se encuentra un nodo temporal accesible (distancia != INF), el grafo está desconectado
        if not encontrado and m < num_nodos:
            break
        
        # c. Etiquetar el nodo encontrado como Permanente ('P')
        lista_estados[minimo_posicion] = 'P'
        
        m += 1
        
        # d. Relajar aristas salientes del nodo permanente
        Actualizar_vectores(vector_u, lista_estados, lista_predecesor, matriz_adyacencia, minimo_posicion)
        
    # 5. Devolver resultados
    if m < num_nodos:
        
        # Si el bucle terminó antes de tiempo, es infactible (desconectado)
        return "INFACTIBLE: El grafo está desconectado.", None, None
    return  "ÉXITO", vector_u, lista_predecesor


# -----------------------------------------------------------------------------
# FUNCIONES DE POST-PROCESAMIENTO
# -----------------------------------------------------------------------------
     
def Reconstruir_Grafo_Orientado(nodos: list, lista_predecesor: list, vector_u: list):

    """
    Reconstruye el conjunto de aristas que forman el Árbol de Caminos Más Cortos
    a partir del vector de predecesores.
    """
    
    aristas_grafo = []
    mapeo_inverso = {i: nodo for i, nodo in enumerate(nodos)}
    
    for i, predecesor_index in enumerate(lista_predecesor):
        
        # No se procesa el nodo raíz (distancia 0.0) ni nodos inaccesibles (INF)
        if vector_u[i] == INF or vector_u[i] == 0.0:
            continue
        
        destino = mapeo_inverso[i]
        origen = mapeo_inverso[predecesor_index]
        
        arista_grafo = f"{origen}-{destino}"
        aristas_grafo.append(arista_grafo)
    
    # Devolver una lista única de las aristas del árbol
    return list(set(aristas_grafo))


def Algoritmo_Dijkstra_final(aristas: dict, nodos: list, nodo_raiz):

    """
    Función de interfaz: ejecuta Dijkstra, maneja errores y formatea la salida.
    """
    
    # 1. Ejecutar Dijkstra
    estado, vector_u, lista_predecesor = Algoritmo_Dijkstra(aristas, nodos, nodo_raiz)
    
    # 2. Manejar Errores
    if estado.startswith("ERROR"):
        return {"Estado": estado, "Grafo_Orientado": None, "Distancias": None}
    
    # 3. Reconstruir el Grafo
    grafo_orientado_final = Reconstruir_Grafo_Orientado(nodos, lista_predecesor, vector_u)
    
    # 4. Formatear la salida de distancias
    distancias_finales = {nodos[i]: round(d, 2) for i, d in enumerate(vector_u)}
    
    # 5. Devolver el resultado
    return {
        "Estado": "Éxito Total" if estado == "ÉXITO" else "Éxito Parcial/Infactible",
        "Grafo_Orientado": grafo_orientado_final,
        "Distancias": distancias_finales,
        "Detalle": "El grafo final contiene solo las aristas que forman los caminos más cortos desde la raíz."
    }    



# ---------------------------------------------------------------------
# BLOQUE 4: DATOS DE ENTRADA Y EJECUCIÓN DEL CASO DE ESTUDIO
# ---------------------------------------------------------------------

# Conjunto de datos para el Problema 4.a
nodos_fuenfria = ['O', 'A', 'B', 'C', 'D', 'E']

# Los datos de entrada del ejercicio
aristas_fuenfria = {
    'O-A': 2, 'O-B': 5, 'O-C': 4, 
    'C-B': 1, 'A-B': 2, 'A-D': 8, 
    'B-D': 4, 'C-D': 3, 'E-D': 1, 
    'C-E': 4
}

print("")
print("PROBLEMA 4.a: ")
print("")

print("ARISTAS: ")
print(aristas_fuenfria)
print("")

print("NODOS: ")
print(nodos_fuenfria)
print("")

print("NODO RAÍZ: ")
nodo_raiz = 'O'
print(nodo_raiz)
print("")

print("SOLUCIÓN CON DIJKSTRA: ")
print (Algoritmo_Dijkstra_final(aristas_fuenfria , nodos_fuenfria, nodo_raiz))

        