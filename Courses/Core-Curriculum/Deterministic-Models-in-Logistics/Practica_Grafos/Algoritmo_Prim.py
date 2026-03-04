#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  9 14:05:44 2025

@author: cati
"""

INF = float('inf') # Define el valor para representar una distancia o peso infinito (ausencia de conexión)



# ---------------------------------------------------------------------
# BLOQUE 1: REPRESENTACION DEL GRAFO POR MATRIZ DE ADYACENCIA
# ---------------------------------------------------------------------

def aristas_a_matriz(aristas: dict, nodos: list):
    
    """
    Convierte la representación del grafo de aristas (diccionario) a una
    matriz de adyacencia. ASUME UN GRAFO NO DIRIGIDO (simetría).
    """
    
    num_nodos = len(nodos)
    
    # 1. Inicializar la matriz con 0 en la diagonal e INF en el resto
    matriz_adyacencia = []
    for i in range (0,num_nodos): 
        fila = []
        for j in range (0,num_nodos): 
            if (i==j): 
                fila.append(0.0) # Distancia de un nodo a sí mismo es cero
            else:
                fila.append(INF) # Distancia inicial a otros nodos (no conectados)
        matriz_adyacencia.append(fila)
        
    # 2. Mapear nombres de nodos a índices (0, 1, 2, ...)    
    mapeo_nodos = {nodo: i for i, nodo in enumerate(nodos)}
    
    # 3. Rellenar la matriz con los pesos de las aristas
    for arista, peso in aristas.items(): 
        # Las aristas se esperan en formato 'Origen-Destino'
        salida, llegada = arista.split('-')
        
        # Obtener los índices de la matriz
        i = mapeo_nodos[salida]
        j = mapeo_nodos[llegada] 
        peso_float = float(peso)
        
        # Asignación directa (Salida -> Llegada)
        matriz_adyacencia[i][j] = peso_float
        
        # Asignación inversa (Llegada -> Salida) para simetría (grafo no dirigido)
        matriz_adyacencia[j][i] = peso_float 
        
    return matriz_adyacencia



# ---------------------------------------------------------------------
# BLOQUE 2: ALGORITMO PRINCIPAL DE PRIM
# ---------------------------------------------------------------------

def Algoritmo_Prim(aristas: dict, nodos: list, nodo_raiz): 
    
    """
    Implementación del Algoritmo de Prim para encontrar el Árbol de Expansión Mínima (AEM).
    Prim crece el AEM seleccionando la arista más barata que conecta un nodo en el
    árbol actual (conjunto C) con un nodo fuera de él.
    """
    num_nodos = len(nodos)
    mapeo_nodos = {nodo: i for i, nodo in enumerate(nodos)}
    
    
    # 1. Validación de la raíz
    if nodo_raiz not in mapeo_nodos:
        return "ERROR: Nodo raíz no encontrado.", None, None
    
    # Convertir la lista de aristas a la matriz de adyacencia
    matriz_adyacencia = aristas_a_matriz(aristas, nodos)
    
    C = {nodo_raiz}      # Conjunto de nodos ya incluidos en el AEM
    grafo = {}           # Diccionario para almacenar las aristas del AEM (el resultado)
    m = 1                # Contador de nodos en el conjunto C
    peso = 0             # Peso total del AEM
    
    # El bucle principal se ejecuta hasta que todos los nodos (num_nodos) estén en C
    while m < num_nodos  : 
        nuevo_nodo = ''
        minimo = INF 
        arista = ''      # Inicialización de variables para la arista óptima de la iteración
        origen = ''      # Nodo en C que conecta con el nuevo nodo
        
        # 1. Buscar la arista de menor peso que conecta un nodo en C con uno fuera de C
        for i in C :              # Iterar sobre los nodos ya conectados (en C)
            for j in nodos :      # Iterar sobre todos los nodos posibles
                if j not in C :   # Solo buscar aristas hacia nodos NO conectados
                    
                    # Obtener el peso de la arista candidata (i -> j) usando los mapeos
                    arista_candidata = matriz_adyacencia[mapeo_nodos[i]][mapeo_nodos[j]]
                    
                    # Criterio de Prim: actualizar el mínimo si encontramos una arista más barata
                    if (arista_candidata < minimo and arista_candidata != INF ): 
                        minimo = arista_candidata # Guardar el nuevo peso mínimo
                        nuevo_nodo = j   # Nodo que se unirá a C
                        origen = i       # Nodo que lo conecta desde C
                        
        # 2. Manejo de desconexión
        if nuevo_nodo == '' : 
            # Si no se encontró un nuevo nodo accesible, el grafo está desconectado. 
            return 'INFACTIBLE', None, None 
        
        # 3. Incluir el nuevo nodo y la arista al arbol
        C.add(nuevo_nodo) # Añadir el nodo al conjunto de nodos conectados
        arista = origen + '-' + nuevo_nodo
        grafo[arista] = minimo # Guardar la arista elegida y su peso
        m = m + 1 # Aumentar el contador de nodos en C
        peso += minimo  # Sumar el peso de la arista al peso total del AEM

    return 'EXITO', grafo, peso 



# ---------------------------------------------------------------------
# BLOQUE 3: DATOS DE ENTRADA Y EJECUCIÓN DEL CASO DE ESTUDIO
# ---------------------------------------------------------------------

# Conjunto de datos para el Problema 4.b
nodos_fuenfria = ['O', 'A', 'B', 'C', 'D', 'E']

# Los datos de entrada del ejercicio
aristas_fuenfria = {
    'O-A': 2, 'O-B': 5, 'O-C': 4, 
    'C-B': 1, 'A-B': 2, 'A-D': 8, 
    'B-D': 4, 'C-D': 3, 'E-D': 1, 
    'C-E': 4
}

print("")
print("PROBLEMA 4.b: ")
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

print("SOLUCIÓN CON PRIM: ")
# Ejecución del Algoritmo de Prim
solucion_prim = Algoritmo_Prim(aristas_fuenfria, nodos_fuenfria, 'O')
print(solucion_prim)