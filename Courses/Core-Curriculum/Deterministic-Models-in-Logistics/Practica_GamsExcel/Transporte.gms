* ================================
*   PROBLEMA TRANSPORTE
* ================================

* ---------- Conjuntos ----------
SETS
    i "Almacenes" /A1, A2, A3/
    j "Clientes"  /C1, C2/;

* ---------- Parámetros ----------
PARAMETERS
    ci(i)     "Capacidad del almacén i"
    dj(j)     "Demanda del cliente j"
    bij(i,j)  "Coste de transporte de una unidad desde i a j";

* ---------- Tabla de costos de transporte ----------
TABLE bij(i,j) "Coste de transporte de una unidad desde i a j"
         C1    C2
    A1   1.5   2
    A2   2     1.5
    A3   2.5   2.25;

* ---------- Tablas de datos automáticas ----------
TABLE data(i,*) "Capacidades de almacenes"
         valor
    A1    4000
    A2    5000
    A3    6000;

TABLE demand(j,*) "Demandas de los clientes"
         valor
    C1    3000
    C2    5000;

* ---------- Asignación automática ----------
ci(i) = data(i,"valor");
dj(j) = demand(j,"valor");

* ---------- Variables ----------
VARIABLES
    Yij(i,j) "Cantidad enviada desde el almacén i al cliente j"
    z        "Costo total de transporte";

POSITIVE VARIABLES Yij;

* ---------- Ecuaciones ----------
EQUATIONS
    funObj       "Función objetivo: minimizar costo total"
    capConstr(i) "Restricción de capacidad de cada almacén"
    demConstr(j) "Restricción de satisfacción de demanda de cada cliente";

* ---------- Función objetivo ----------
funObj..
    z =E= SUM((i,j), bij(i,j) * Yij(i,j));

* ---------- Restricciones ----------
capConstr(i)..
    SUM(j, Yij(i,j)) =L= ci(i);

demConstr(j)..
    SUM(i, Yij(i,j)) =G= dj(j);

* ---------- Modelo ----------
MODEL Transporte /all/;

* ---------- Resolver ----------
SOLVE Transporte USING LP MINIMIZING z;

* ---------- Mostrar resultados ----------
DISPLAY Yij.l, z.l, capConstr.m, demConstr.m;