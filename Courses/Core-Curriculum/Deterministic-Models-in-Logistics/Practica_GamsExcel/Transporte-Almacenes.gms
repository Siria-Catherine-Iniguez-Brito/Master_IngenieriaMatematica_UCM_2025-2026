* ==============================================================
*  PROBLEMA TRANSPORTE–ALMACENES
*  (Modelo de localización con costes fijos y transporte)
* ==============================================================

* ---------- Conjuntos ----------
SETS
    i "Almacenes potenciales" /A1, A2, A3/
    j "Clientes"              /C1, C2/;

* ---------- Parámetros ----------
PARAMETERS
    ci(i)    "Capacidad del almacén i"
    dj(j)    "Demanda del cliente j"
    fi(i)   "Coste fijo de apertura del almacén i"
    bij(i,j) "Coste unitario de transporte desde i a j";

* ---------- Tabla de costes de transporte ----------
TABLE bij(i,j) "Coste unitario de transporte desde i a j"
         C1     C2
   A1    1.5    2
   A2    2      1.5
   A3    2.5    2.25;

* ---------- Tablas de datos ----------
TABLE capData(i,*) "Capacidades de los almacenes"
         valor
    A1    4000
    A2    5000
    A3    6000;

TABLE demandData(j,*) "Demandas de los clientes"
         valor
    C1    3000
    C2    5000;

TABLE costData(i,*) "Costes fijos de apertura de almacenes"
         valor
    A1    8000
    A2    12000
    A3    7000;

* ---------- Asignación automática ----------
ci(i)  = capData(i,"valor");
dj(j)  = demandData(j,"valor");
fi(i) = costData(i,"valor");

* ---------- Variables ----------
VARIABLES
    Yij(i,j) "Cantidad enviada desde el almacén i al cliente j"
    Xi(i)    "Variable binaria: 1 si el almacén i se abre, 0 si no"
    z        "Costo total (transporte + costes fijos)";

POSITIVE VARIABLES Yij;
BINARY VARIABLES Xi;

* ---------- Ecuaciones ----------
EQUATIONS
    funObj       "Función objetivo: minimizar costes totales"
    capConstr(i) "Restricción de capacidad y apertura"
    demConstr(j) "Restricción de satisfacción de demanda";

* ---------- Función objetivo ----------
funObj..
    z =E= SUM((i,j), bij(i,j) * Yij(i,j)) + SUM(i, fi(i) * Xi(i));

* ---------- Restricciones ----------

* Un almacén solo puede enviar si está abierto y no puede superar su capacidad
capConstr(i)..
    SUM(j, Yij(i,j)) =L= ci(i) * Xi(i);

* Cada cliente debe recibir exactamente su demanda
demConstr(j)..
    SUM(i, Yij(i,j)) =E= dj(j);

* ---------- Modelo ----------
MODEL Transporte_Almacenes /all/;

* ---------- Resolver ----------
SOLVE Transporte_Almacenes USING MIP MINIMIZING z;

* ---------- Mostrar resultados ----------
DISPLAY Xi.l, Yij.l, z.l Yij.lo, Yij.up


