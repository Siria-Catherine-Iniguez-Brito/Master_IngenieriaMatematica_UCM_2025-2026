#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 29 00:11:29 2025

@author: cati
"""
import pyomo.environ as pyo 
from pyomo.opt import SolverFactory 


model = pyo.ConcreteModel()


model.I = pyo.Set(initialize=['D1', 'D2', 'D3'])
model.J = pyo.Set(initialize=['E1', 'E2', 'E3', 'E4'])

# 1. Definir el conjunto de arcos activos (A) basados en las tablas del problema
model.A = pyo.Set(initialize=[
    ('D1', 'E1'), ('D1', 'E3'), 
    ('D2', 'E2'), ('D2', 'E3'), ('D2', 'E4'),
    ('D3', 'E1'), ('D3', 'E2'), ('D3', 'E4')
])

# 2. Reestructurar parámetros y variables sobre el conjunto A

# Costo de camión por ruta (solo arcos activos)
c_dict = {
    ('D1', 'E1'): 100, ('D1', 'E3'): 125,
    ('D2', 'E2'): 100, ('D2', 'E3'): 125, ('D2', 'E4'): 100,
    ('D3', 'E1'): 75, ('D3', 'E2'): 100, ('D3', 'E4'): 125
}
model.c = pyo.Param(model.A, initialize=c_dict)

# Capacidad máxima de la ruta (solo arcos activos)
capac_dict = {
    ('D1', 'E1'): 80, ('D1', 'E3'): 70,
    ('D2', 'E2'): 60, ('D2', 'E3'): 90, ('D2', 'E4'): 85,
    ('D3', 'E1'): 40, ('D3', 'E2'): 60, ('D3', 'E4'): 50
}
model.capac = pyo.Param(model.A, initialize=capac_dict)

# Parámetros de Capacidad de Depósito y Demanda Cliente (sin cambios)
model.cap = pyo.Param(model.I, initialize = dict(zip(model.I,[150, 300, 250])))
model.dem = pyo.Param(model.J, initialize = dict(zip(model.J,[130, 200, 150, 250])))

# Variables definidas solo sobre el conjunto de arcos activos (A)
model.Y = pyo.Var(model.A, domain = pyo.NonNegativeReals)
model.X = pyo.Var(model.A, domain = pyo.NonNegativeIntegers)


# 3. Modificar la Función Objetivo y Restricciones para iterar sobre A

def ObjRule(model):
    # Iterar solo sobre los arcos activos A
    return sum(7*model.Y[i,j] - model.c[i,j]*model.X[i, j] for (i, j) in model.A)

model.obj = pyo.Objective(rule=ObjRule, sense=pyo.maximize)


def CapacidadDeposito(model, i):
    # Suma solo sobre las rutas activas que salen de i
    return sum(model.Y[i, j] for j in model.J if (i, j) in model.A) <= model.cap[i]

model.capacidad = pyo.Constraint(model.I, rule=CapacidadDeposito)


def DemandaCliente(model, j):
    # Suma solo sobre las rutas activas que llegan a j
    return sum(model.Y[i, j] for i in model.I if (i, j) in model.A) <= model.dem[j]

model.demanda = pyo.Constraint(model.J, rule=DemandaCliente)


def CapacidadRuta(model, i, j):
    # Restricción aplicada solo a los arcos activos A
    return model.Y[i,j] <= model.capac[i,j]

# La restricción se define solo para el conjunto A
model.ruta = pyo.Constraint(model.A, rule=CapacidadRuta)


def Camiones(model, i, j):
    # Restricción aplicada solo a los arcos activos A
    return model.Y[i,j] <= 20*model.X[i,j]

# La restricción se define solo para el conjunto A
model.camiones = pyo.Constraint(model.A, rule=Camiones)


# Opciones de Solver
opt = SolverFactory('glpk')
results = opt.solve(model, tee=False)




print("") 

print("")
print("FUNCION OBJETIVO")
print("")
model.obj.pprint()

print("")
model.obj.display()



print("")
print("MODELO")
model.display()


print("")
print("VARIABLE X")
print("")
model.X.display()

print("")
print("VARIABLE Y")
print("")
model.Y.display()



