
/* Práctica 2 - TP*/
/* Práctica modelos VARMA y Cointegración*/
/* Análisis de EuroStoxx 50 y DAX 40**/
/* Ana Marta Oliveira y Siria Catherine Iniguez*/



/*----------------------------------------------------------------------------*/
/* 1. CONFIGURACIÓN, CARGA Y LIMPIEZA DE DATOS                                */
/*----------------------------------------------------------------------------*/


/* Definición de la librería y carga de datos*/
libname TP "C:\MARTA\Mestrado\Asignaturas ahora\TP\Practica2";


/* Importamos la serie eurostoxx50 */
data TP.eurostoxx50_DIARIA;
  %let _EFIERR_ = 0; 
  infile 'C:\MARTA\Mestrado\Asignaturas ahora\TP\Practica2\serie_eurostoxx50.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
     informat Date mmddyy10. ;
     informat Open best32. ;
     informat High best32. ;
     informat Low best32. ;
     informat Close best32. ;

     format Date mmddyy10. ;
     format Open best12. ;
     format High best12. ;
     format Low best12. ;
     format Close best12. ;
  input
              Date
              Open
              High
              Low
              Close
  ;
  if _ERROR_ then call symputx('_EFIERR_',1); 
run;
data TP.eurostoxx50_DIARIA;
  set TP.eurostoxx50_DIARIA;
  rename date=fecha;
run;

/* Importamos la serie dax40 */
data TP.serie_dax40_DIARIA;
  %let _EFIERR_ = 0; 
  infile 'C:\MARTA\Mestrado\Asignaturas ahora\TP\Practica2\serie_dax40.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
     informat Date mmddyy10. ;
     informat Open best32. ;
     informat High best32. ;
     informat Low best32. ;
     informat Close best32. ;

     format Date mmddyy10. ;
     format Open best12. ;
     format High best12. ;
     format Low best12. ;
     format Close best12. ;
  input
              Date
              Open
              High
              Low
              Close
  ;
  if _ERROR_ then call symputx('_EFIERR_',1); 
run;
data TP.serie_dax40_DIARIA;
  set TP.serie_dax40_DIARIA;
  rename date=fecha;
run;

/* LIMPIEZA Y ALINEACIÓN DE FECHAS Y TRATAMIENTO DE FESTIVOS: En finanzas, 
los fines de semana no existen. Creamos un calendario de lunes a viernes y
rellenamos los festivos con el último dato conocido*/


/* Eurostoxx */
proc sort data=TP.eurostoxx50_DIARIA;
  by fecha;
run;
quit;

/* Encontrar primera fecha*/
proc sql;
  select min(fecha) into:primera_fecha
  from TP.eurostoxx50_DIARIA;
run;

/* Encontrar última fecha*/
proc sql;
  select max(fecha) into:ultima_fecha
  from TP.eurostoxx50_DIARIA;
run;

/* Crear tabla con todas las fechas a utilizar menos los fines de semana*/
data work.todas_las_fechas;
  do fecha=&primera_fecha to &ultima_fecha;
    if weekday(fecha) not in (1,7) then output;
  end;
  format fecha ddmmyy10.;
run;

/* Añadir festivos con el cierre del día anterior*/
data work.eurostoxx50_DIARIA(keep=fecha 
  Close cierraBolsa eurostoxx50 maximo_eurostoxx50 minimo_eurostoxx50);
  merge work.todas_las_fechas(in=a) TP.eurostoxx50_DIARIA;
  by fecha;
  if a;
  cierraBolsa=0;
  if Close ne . then do;
    eurostoxx50 = Close;
    maximo_eurostoxx50 = High;
    minimo_eurostoxx50 = Low;
  end;
  else cierraBolsa=1;
  retain eurostoxx50 maximo_eurostoxx50 minimo_eurostoxx50;
run;

/* Guardamos el ultimo mes para test*/
/* Reservamos del 13 de noviembre hasta el 12 de diciembre de 2025*/
data work.eurostoxx50_DIARIA;
  set work.eurostoxx50_DIARIA(drop= Close);
  recuerda_eurostoxx50=eurostoxx50;
  if fecha > '12nov2025'd then eurostoxx50=.;
run;


/* Dax */
proc sort data=TP.serie_dax40_DIARIA;
  by fecha;
run;
quit;

/* Encontrar primera fecha*/
proc sql;
  select min(fecha) into:primera_fecha
  from TP.serie_dax40_DIARIA;
run;

/* Encontrar última fecha*/
proc sql;
  select max(fecha) into:ultima_fecha
  from TP.serie_dax40_DIARIA;
run;

/* Añadir festivos con el cierre del día anterior*/
data work.serie_dax40_DIARIA(keep=fecha 
  Close cierraBolsa dax40 maximo_dax40 minimo_dax40);
  merge work.todas_las_fechas(in=a) TP.serie_dax40_DIARIA;
  by fecha;
  if a;
  cierraBolsa=0;
  if Close ne . then do;
    dax40 = Close;
    maximo_dax40 = High;
    minimo_dax40 = Low;
  end;
  else cierraBolsa=1;
  retain dax40 maximo_dax40 minimo_dax40;
run;

/* Guardamos el ultimo mes para test*/
/* Reservamos del 13 de noviembre hasta el 12 de diciembre de 2025*/
data work.serie_dax40_DIARIA;
  set work.serie_dax40_DIARIA(drop= Close);
  recuerda_dax40=dax40;
  if fecha > '12nov2025'd then dax40=.;
run;


/* Unimos ambas series en una sola tabla */
data TP.bolsa_para_modelar;
  merge work.eurostoxx50_DIARIA work.serie_dax40_DIARIA;
  by fecha;
run;

/* Graficamos ambas series */
goptions device=activex;
ods html style=sasweb;

legend1 label=none 
        value=('EuroStoxx 50' 'DAX 40') 
        position=(bottom center) 
        mode=protect;

proc gplot data=TP.bolsa_para_modelar;
   plot eurostoxx50*fecha=1 dax40*fecha=2 / overlay legend=legend1;
   
   label eurostoxx50="Puntos de Cotización"
         fecha="Fecha";
         
   symbol1 i=join v=none c=blue l=1;
   symbol2 i=join v=none c=green l=1;
run;
quit;



/*----------------------------------------------------------------------------*/
/* 2. ANÁLISIS DE ESTACIONARIEDAD Y TRANSFORMACIONES                          */
/*----------------------------------------------------------------------------*/


/* ¿ES ESTACIONARIA EN VARIANZA? */

ods html;
%boxcoxar(work.eurostoxx50_DIARIA,eurostoxx50,nlambda=3,lambdalo=0,lambdahi=1);
/* No tendria que hacer nada*/ 

/*
LAMBDA   LOGLIK    RMSE        AIC       SBC 
1.0     -5323.77  2492.57   10659.53   10689.03 
0.5     -5336.09  2474.59   10684.17   10713.67 
0.0     -5359.30  2451.48   10730.60   10760.10 

*/

/*Por AIC, SBC no hace falta tomar logaritmo - los menores valores están en lambda = 1 y para el LOGLIK el mayor valor (el menos negativo)*/
/*Por RMSE ganaría lambda = 0.0 */


ods html;
%boxcoxar(work.serie_dax40_DIARIA,dax40,nlambda=3,lambdalo=0,lambdahi=1);
/* No tendria que hacer nada*/ 
/*
LAMBDA   LOGLIK    RMSE        AIC       SBC 
1.0     -5420.98  3168.71   10853.97   10883.46 
0.5     -5429.21  3392.34   10870.43   10899.92 
0.0     -5451.74  3132.98   10915.48   10944.98 

*/

/*Por AIC, SBC no hace falta tomar logaritmo - los menores valores están en lambda = 1 y para el LOGLIK el mayor valor (el menos negativo)*/
/*Por RMSE ganaría lambda = 0.0 */


/*Conclusión: no es necesario realizar ninguna transformación*/


/* ¿ES ESTACIONARIA EN MEDIA? */

/* ANALISIS DE ESTACIONARIEDAD: Comprobar raíces unitarias para decidir diferenciación. 
Se analiza la necesidad de diferenciar */

proc varmax data=TP.bolsa_para_modelar;
   model eurostoxx50 dax40 / p=1 print=(roots);
run;
quit;

/*Raíces del polinomio de característica AR 
Índice	 Real		 Imaginario		 Módulo		 Radián 	Grado 
1		 1.00071 	 0.00000		 1.0007		 0.0000 	0.0000 
2 		 0.98025	 0.00000		 0.9802 	 0.0000		0.0000 

Al analizar las raíces del sistema conjunto, observamos que la raíz número 1 
presenta un módulo de 1.0007. Al ser igual o superior a la unidad (raíz unitaria), 
queda demostrado que el sistema en niveles no es estacionario.*/



/*----------------------------------------------------------------------------*/
/* 3. IDENTIFICACIÓN Y ESTIMACIÓN DEL MODELO VAR                              */
/*----------------------------------------------------------------------------*/


/*Vamos a aplicar una diferencia regular a ambas series y utilizar el comando MINIC
para identificar el mejor orden 'p' y 'q' para nuestro modelo VARMA/VECM 
Se recurre al cálculo de una métrica que penalice la presencia de parámetros*/


/* Identificación de órdenes p y q*/
proc varmax data = TP.bolsa_para_modelar;
  model eurostoxx50 dax40  /dify(1) minic=(p=(0:13) q=(0:13));
run;
quit;

/* Criterio de información mínimo basado en AICC 
Retardo 	MA 0			 MA 1			 MA 2			 MA 3			 MA 4			 MA 5			 MA 6 			MA 7 			MA 8			 MA 9		 	MA 10 			MA 11			MA 12		   MA 13 
AR 0	 15.453198		 15.295795		 15.294322		 15.290106		 15.289707		 15.290633		 15.296278		 15.301928		 15.305634		 15.305415		 15.302148		 15.301812		 15.305725		 15.310071 
AR 1	 15.295083		 15.268404		 15.270263		 15.272387		 15.270322		 15.272336		 15.275549		 15.282524		 15.287313		 15.289173		 15.289978		 15.292935		 15.298216		 15.303215 
AR 2	 15.297002		 15.271614		 15.276131		 15.278584		 15.276863		 15.27919		 15.282496		 15.288516		 15.293504		 15.295271		 15.295463		 15.29766		 15.302664		 15.307695 
AR 3	 15.297681		 15.27197		 15.278701		 15.283738		 15.28415		 15.286295		 15.289746		 15.295817		 15.300697		 15.302422		 15.302569		 15.304786		 15.309857		 15.31539 
AR 4	 15.306373		 15.271915		 15.279043		 15.285626		 15.287565		 15.286464		 15.291712		 15.29712		 15.303033		 15.303645		 15.304303		 15.306883		 15.311797		 15.318976 
AR 5	 15.312323		 15.276674		 15.28417		 15.290468		 15.289735		 15.289804		 15.295393		 15.300139		 15.304993		 15.30684		 15.308814		 15.310948		 15.314354		 15.321622 
AR 6	 15.316823		 15.277953		 15.285589		 15.292613		 15.291304		 15.293231		 15.292489		 15.290486		 15.294701		 15.295397		 15.298586		 15.297859		 15.302229		 15.307933 
AR 7	 15.326588		 15.285543		 15.293111		 15.30024		 15.298439		 15.30065		 15.296721		 15.296819		 15.29133		 15.292856		 15.295005		 15.295221		 15.299777		 15.30435 
AR 8	 15.329248		 15.288511		 15.295969		 15.30348		 15.3028		 15.304885		 15.300813		 15.295114		 15.297392		 15.297533		 15.300232		 15.296775		 15.301572		 15.304707 
AR 9	 15.336755		 15.291793		 15.299167		 15.306004		 15.303923		 15.305583		 15.301123		 15.294335		 15.299183		 15.303158		 15.307606		 15.303473		 15.308213		 15.312136 
AR 10	 15.341585		 15.292347		 15.29889		 15.30632		 15.305582		 15.309033		 15.304958		 15.299007		 15.303499		 15.307781		 15.308543		 15.308011		 15.312914		 15.316998 
AR 11	 15.345853		 15.293322		 15.2994		 15.305893		 15.305765		 15.307729		 15.302123		 15.293855		 15.29791		 15.301413		 15.305201		 15.310446		 15.31376		 15.318016 
AR 12	 15.352583		 15.298521		 15.304519		 15.311026		 15.311382		 15.312348		 15.307012		 15.297901		 15.302049		 15.306306		 15.310407		 15.314141		 15.320895		 15.326347 
AR 13	 15.355119		 15.303385		 15.309838		 15.315883		 15.317147		 15.318463		 15.313239		 15.302545		 15.306675		 15.311116		 15.314346		 15.318599		 15.326445		 15.327422 
*/ 


/* Criterio de información mínimo basado en AICC
El valor más bajo de la nueva tabla es 15.268404, que se encuentra 
en la fila AR 1 y columna MA 1.

De acuerdo con el criterio AICC, el mejor orden para el par de series 
diferenciadas es p=1 y q=1, lo que sugiere un modelo VARMA(1,1).

El segundo valor más bajo es 15.270263 que se encuentra en la fila AR 1
y columna MA 2, lo que también podría suponer un modleo VARMA(1,1)

De este modo, se analizará entre ellos, cuál supera mejor el
test de RB de Portmanteau
*/

/* 3.1 Ajustamos el VARMA(1,1) sugerido por el criterio AICC */
proc varmax data=TP.bolsa_para_modelar print=diagnose;
   model eurostoxx50 dax40 / p=1 q=1 dify(1);
run;
quit;

/* 3.2 Ajustamos el VARMA(1,2) sugerido por el criterio AICC */
proc varmax data=TP.bolsa_para_modelar print=diagnose;
   model eurostoxx50 dax40 / p=1 q=2 dify(1);
run;
quit;

/* 
VARMA(1,1)
Test de Portmanteau para correlaciones cruzadas de residuales
Hasta retardo   DF   Chi-cuadrado   Pr > ChiSq
      3          4       8.20         0.0845
      4          8      10.36         0.2404
      5         12      13.09         0.3623
      6         16      15.99         0.4534
      7         20      16.63         0.6770
      8         24      19.48         0.7259
      9         28      24.00         0.6816
     10         32      29.53         0.5920
     11         36      32.30         0.6454
     12         40      33.12         0.7713

VARMA(1,2)
Test de Portmanteau para correlaciones cruzadas de residuales
Hasta retardo   DF   Chi-cuadrado   Pr > ChiSq
      4          4       3.62         0.4596
      5          8       6.10         0.6359
      6         12       8.58         0.7382
      7         16       9.52         0.8905
      8         20      11.96         0.9175
      9         24      16.99         0.8489
     10         28      22.46         0.7594
     11         32      25.17         0.7992
     12         36      25.90         0.8931
*/


/* 3.3. Para comprobar, se prueba también el VAR(1) clásico (p=1, q=0), 
A veces los modelos con parte de Medias Móviles (MA) dan problemas 
de convergencia o no mejoran los residuos reales. */

proc varmax data=TP.bolsa_para_modelar print=diagnose;
   model eurostoxx50 dax40 / p=1 dify(1);
run;
quit;

/* VAR(1)
Test de Portmanteau para correlaciones cruzadas de residuales
Hasta retardo   DF   Chi-cuadrado   Pr > ChiSq
      2          4       2.55         0.6354
      3          8       9.93         0.2699
      4         12      12.00         0.4459
      5         16      14.43         0.5669
      6         20      17.51         0.6198
      7         24      18.20         0.7930
      8         28      21.14         0.8196
      9         32      25.94         0.7661
     10         36      31.74         0.6714
     11         40      34.42         0.7192
     12         44      35.52         0.8151
*/

/* Teniendo en cuenta el Test de Portmanteau , y la simplicidad del modelo 
VAR(1) en relación a número de parámetros del modleo, este parece ser el modleo 
más adecuado. En consecuencia será este para el que se mustre la estimación 
de los parámetros y se realicen las predicciones*/

/* Estimación de los parámetros del modelo VAR(1)*/
/*Estimaciones del parámetro del modelo

Ecuación      Parámetro  Estimación  Err. Estándar  t valor  Pr > |t|  Variable
eurostoxx50   CONST1       1.00562      1.42407       0.71    0.48031  1
              AR1_1_1     -0.17309      0.03295      -5.25    0.0001   eurostoxx50(t-1)
              AR1_1_2      0.31672      0.02987      10.60    0.0001   dax40(t-1)

dax40         CONST2       2.02305      1.64882       1.23    0.22011  1
              AR1_2_1      0.11167      0.03814       2.93    0.0035   eurostoxx50(t-1)
              AR1_2_2     -0.06510      0.03458      -1.88    0.0600   dax40(t-1)
*/


/* Los términos constantes pueden ser eliminados*/
/* El resto de los parámetros los dejamos por ser significativos
Nota: AR(1,2,2) - 0.0600*/

proc varmax data=TP.bolsa_para_modelar print=diagnose;
   model eurostoxx50 dax40 / p=1 dify(1) noint;
run;
quit;

/*Estimaciones del parámetro del modelo

Ecuación      Parámetro  Estimación  Err. Estándar  t valor  Pr > |t|  Variable
eurostoxx50   AR1_1_1     -0.17276      0.03293      -5.25    0.0001   eurostoxx50(t-1)
              AR1_1_2      0.31734      0.02985      10.63    0.0001   dax40(t-1)

dax40         AR1_2_1      0.11233      0.03815       2.94    0.0033   eurostoxx50(t-1)
              AR1_2_2     -0.06386      0.03457      -1.85    0.0651   dax40(t-1)
*/

/*Trás retirar los términos constantes, la significatividad
de los parámetros se mantiene*/



/*PREDICCIONES: antes del análisis de cointegración,
se realizan predicciones con el modleo elegido*/

%macro simula_predicciones_varma_bolsa(
  tabla_entrada=,
  idFecha=,
  fecha_inicial=,
  fecha_final=,
  modelo_varma=,
  horizonte=,
  tabla_salida=);

  /* 1. Limpiamos el acumulador de errores */
  data WORK.TODOS_LOS_ERRORES;
    HORIZONTE = .;
    error_eurostoxx50 = .;
    error_dax40 = .;
    stop;
  run;

  /* 2. Extraemos todos los días del rango de test */
  data WORK.DIAS_A_ITERAR;
    set &tabla_entrada(keep=&idFecha);
    where &idFecha >= &fecha_inicial and &idFecha <= &fecha_final;
  run;

  data _null_;
    set WORK.DIAS_A_ITERAR nobs=total;
    call symput('numDias', compress(put(total, 8.)));
  run;

  /* 3. Bucle de simulacion */
  %do i=1 %to &numDias;

    data _null_;
      set WORK.DIAS_A_ITERAR;
      if _n_=&i then call symput('contador_fecha', compress(put(&idFecha, 8.)));
    run;

    data WORK.HISTORICO;
      set &tabla_entrada;
      eurostoxx50 = recuerda_eurostoxx50;
      dax40 = recuerda_dax40;
      
      if &idFecha >= &contador_fecha then do;
        eurostoxx50 = .;
        dax40 = .;
      end;
      where &idFecha <= &contador_fecha + &horizonte; 
    run;

    proc varmax data=WORK.HISTORICO;
      id &idFecha interval=weekday; 
      model eurostoxx50 dax40 = / &modelo_varma;
      output out=WORK.SALIDA lead=&horizonte noprint;
    run;
    quit;

    /* 4. Extraccion y calculo de errores */

    data WORK.PRED_LIMPIAS;
      set WORK.SALIDA;
      if eurostoxx50 = . and for1 ne .;
      HORIZONTE + 1;
      keep HORIZONTE for1 for2 &idFecha; 
    run;

    data WORK.CALCULO_ERRORES;
      merge WORK.PRED_LIMPIAS(in=a)
            &tabla_entrada(keep=&idFecha recuerda_eurostoxx50 recuerda_dax40);
      by &idFecha;
      if a;

      /* CORRECCIÓN DE BOLSA: El precio predicho es directamente la columna FOR */
      pred_euro_acum = for1;
      pred_dax_acum  = for2;

      /* Errores porcentuales normales de mercado */
      if recuerda_eurostoxx50 ne . then 
         error_eurostoxx50 = abs((recuerda_eurostoxx50 - pred_euro_acum) * 100 / recuerda_eurostoxx50);
         
      if recuerda_dax40 ne . then 
         error_dax40 = abs((recuerda_dax40 - pred_dax_acum) * 100 / recuerda_dax40);
         
      if HORIZONTE <= &horizonte;
      keep HORIZONTE error_eurostoxx50 error_dax40;
    run;

    data WORK.TODOS_LOS_ERRORES;
      set WORK.TODOS_LOS_ERRORES WORK.CALCULO_ERRORES;
    run;

  %end;

  /* 5. Resultado final */
  proc sort data=WORK.TODOS_LOS_ERRORES;
    by HORIZONTE;
  run;

  proc means data=WORK.TODOS_LOS_ERRORES mean median;
    title "RESULTADOS FINALES: HORIZONTES 1 A 22";
    var error_eurostoxx50 error_dax40;
    by HORIZONTE;
    output out=&tabla_salida(drop=_TYPE_ _FREQ_) 
           mean=ERROR_MEDIO_EURO ERROR_MEDIO_DAX 
           median=ERROR_MEDIANO_EURO ERROR_MEDIANO_DAX;
  run;
  title;

%mend simula_predicciones_varma_bolsa;

/* EJECUCIÓN */
%simula_predicciones_varma_bolsa(
  tabla_entrada=TP.bolsa_para_modelar,
  idFecha=fecha,
  fecha_inicial='13nov2025'd,
  fecha_final='12dec2025'd,
  modelo_varma=dify(1) p=1 noint,
  horizonte=22,
  tabla_salida=work.resultado_final_var
);



/*----------------------------------------------------------------------------*/
/* 4. ANÁLISIS DE COINTEGRACIÓN                                               */
/*----------------------------------------------------------------------------*/

/* Buscamos si existe una relación de equilibrio a largo plazo*/
/* La identificación de estas posibles relaciones permitirá el
empleo de técnicas de predicción multivariante que mejorasen
los resultados proporcionados por el modelo VAR*/

/*----------------------------------------------------------------*/
/* PASO 1: Comprobar orden de integración I(1) de las variables   */
/* Se usa el test de Dickey-Fuller Aumentado (ADF).               */
/*----------------------------------------------------------------*/

/* Analizamos el Eurostoxx50 para ver si es no estacionario */

/* Test en niveles, se busca no rechazar H0*/
proc arima data=TP.bolsa_para_modelar;
  identify var=recuerda_eurostoxx50 stationarity=(adf=(1));
run;
quit;
/*Pruebas aumentadas de la raíz unidad de Dickey-Fuller

Tipo          Retardos     Rho     Pr < Rho    Tau     Pr < Tau    F      Pr > F
Media cero       1        0.2704    0.7483     0.84     0.8916     -        -
Media simple     1       -1.1073    0.8761    -0.47     0.8939    0.53    0.9447
Tendencia        1      -27.7957    0.0129    -4.28     0.0036    9.79    0.0010
*/

/* Al no rechazar la hipótesis nula en niveles, concluimos que es I(1) */

/* Para comprobar el resultado anterior*/
/* Test en primera diferencia, se busca rechazar H0*/
proc arima data=TP.bolsa_para_modelar;
   identify var=recuerda_eurostoxx50(1) stationarity=(adf=(1));
run; quit;

/*Pruebas aumentadas de la raíz unidad de Dickey-Fuller

Tipo          Retardos      Rho      Pr < Rho     Tau      Pr < Tau      F      Pr > F
Media cero       1      -1049.25      0.0001    -22.89     < .0001      -        -
Media simple     1      -1051.76      0.0001    -22.91     < .0001    262.32   0.0010
Tendencia        1      -1055.66      0.0001    -22.94     < .0001    263.08   0.0010
*/



/* Analizamos el Dax40 para ver si es no estacionario */
proc arima data=TP.bolsa_para_modelar;
  identify var=recuerda_dax40 stationarity=(adf=(1));
run;
quit;

/* Pruebas aumentadas de la raíz unidad de Dickey-Fuller

Tipo          Retardos     Rho     Pr < Rho    Tau     Pr < Tau    F      Pr > F
Media cero       1        0.4080    0.7836     1.25     0.9470     -        -
Media simple     1        0.3948    0.9739     0.22     0.9737    0.78    0.8709
Tendencia        1      -15.5376    0.1662    -3.46     0.0450    7.51    0.0175
*/


/* Nota: Al igual que el Eurostoxx50, los p-valores indican que es una variable I(1) */


/*----------------------------------------------------------------*/
/* Paso 2: Método de Engle-Granger (Doble paso)                   */
/* 1. Generar regresión para extraer los residuos.                */
/* 2. Comprobar si los residuos son estacionarios I(0).           */
/*----------------------------------------------------------------*/

/* 1. Hacemos la regresión lineal para obtener la relación a largo plazo */
proc reg data=TP.bolsa_para_modelar;
  model recuerda_eurostoxx50 = recuerda_dax40;
  output out=WORK.salidaReg r=residual_bolsa;
run;
quit;

/* 2. Aplicamos ADF al residuo. Si es menor a 0.05, confirma cointegración */
proc arima data=WORK.salidaReg;
  identify var=residual_bolsa stationarity=(adf=(1));
run;
quit;

/*Pruebas aumentadas de la raíz unidad de Dickey-Fuller

Tipo          Retardos      Rho      Pr < Rho     Tau      Pr < Tau      F      Pr > F
Media cero       1       -10.7848     0.0224     -2.32      0.0196      -        - 
*/

/* p-valor = 0.0196 < 0.05 => rechazamos la hipótesis nula de raíz unitaria
/* Conclusión Engle-Granger: El residuo dio significativo (estacionario)
Las series están cointegradas*/


/*-----------------------------------------------------*/
/* Paso 3: Test de Cointegración de Johansen           */
/* Se utiliza para determinar el número de vectores de */
/* cointegración (rango) en un sistema multivariante.  */
/*-----------------------------------------------------*/

proc varmax data=TP.bolsa_para_modelar;
  id fecha interval=weekday;
  model recuerda_eurostoxx50 recuerda_dax40 = / 
        p=2 cointtest=(johansen=(type=trace));
run;
quit;

/*Test de ranking de cointegración utilizando traza

H0: Rank=r   H1: Rank>r   Autovalor    Traza    Pr > Traza   Deriva en ECM   Deriva en proceso
    0            0         0.0058      5.9401     0.7026       Constant          Linear
    1            1         0.0000      0.0037     0.9517          -                -
*/ 

/*Dado que el p-valor para r = 0 es 0.7026 > 0.05, no se puede rechazar la hipótesis 
nula de que el rango es 0. Esto indica que, según la prueba de la traza, no existe 
una relación de cointegración a largo plazo entre las variables del modelo con este 
nivel de confianza.*/

/* Sin embargo, dado que el test de Engle-Granger resultó significativo (0.0196), existe
evidencia de una relación de equilibrio. Siguiendo un enfoque práctico de predicción, se 
opta por ajustar el VECM para comparar su desempeño real frente al modelo VAR.*/

/* Nota: Aunque el test de traza no es concluyente, procedemos con rango=1 
   basándonos en el resultado positivo de Engle-Granger y en la guía del profesor */


/*----------------------------------------------------------------*/
/* PASO 4: Macro de Simulación Predictiva con VECM                */
/* Adaptada para corregir el cálculo acumulado e incorporar el    */
/* modelo de Corrección de Error (VECM).                          */
/*----------------------------------------------------------------*/
%macro simula_predicciones_vecm_bolsa(
  tabla_entrada=,
  idFecha=,
  fecha_inicial=,
  fecha_final=,
  rango_ecm=,
  horizonte=,
  tabla_salida=);

  /* 1. Limpiamos el acumulador de errores */
  data WORK.TODOS_LOS_ERRORES;
    HORIZONTE = .;
    error_eurostoxx50 = .;
    error_dax40 = .;
    stop;
  run;

  /* 2. Extraemos todos los días del rango de test */
  data WORK.DIAS_A_ITERAR;
    set &tabla_entrada(keep=&idFecha);
    where &idFecha >= &fecha_inicial and &idFecha <= &fecha_final;
  run;

  data _null_;
    set WORK.DIAS_A_ITERAR nobs=total;
    call symput('numDias', compress(put(total, 8.)));
  run;

  /* 3. Bucle de simulacion */
  %do i=1 %to &numDias;

    data _null_;
      set WORK.DIAS_A_ITERAR;
      if _n_=&i then call symput('contador_fecha', compress(put(&idFecha, 8.)));
    run;

    data WORK.HISTORICO;
      set &tabla_entrada;
      eurostoxx50 = recuerda_eurostoxx50;
      dax40 = recuerda_dax40;
      
      if &idFecha >= &contador_fecha then do;
        eurostoxx50 = .;
        dax40 = .;
      end;
      where &idFecha <= &contador_fecha + &horizonte; 
    run;

    /* Ejecutamos VARMAX con el modelo ECM del profesor */
    proc varmax data=WORK.HISTORICO;
      id &idFecha interval=weekday; 
      model eurostoxx50 dax40 = / p=2 ecm=(rank=&rango_ecm);
      output out=WORK.SALIDA lead=&horizonte noprint;
    run;
    quit;

    /* 4. Extraccion y calculo de errores */
    data WORK.PRED_LIMPIAS;
      set WORK.SALIDA;
      if eurostoxx50 = . and for1 ne .;
      HORIZONTE + 1;
      keep HORIZONTE for1 for2 &idFecha; 
    run;

    data WORK.CALCULO_ERRORES;
      merge WORK.PRED_LIMPIAS(in=a)
            &tabla_entrada(keep=&idFecha recuerda_eurostoxx50 recuerda_dax40);
      by &idFecha;
      if a;

      pred_euro_acum = for1;
      pred_dax_acum  = for2;

      /* Errores porcentuales */
      if recuerda_eurostoxx50 ne . then 
         error_eurostoxx50 = abs((recuerda_eurostoxx50 - pred_euro_acum) * 100 / recuerda_eurostoxx50);
         
      if recuerda_dax40 ne . then 
         error_dax40 = abs((recuerda_dax40 - pred_dax_acum) * 100 / recuerda_dax40);
         
      if HORIZONTE <= &horizonte;
      keep HORIZONTE error_eurostoxx50 error_dax40;
    run;

    data WORK.TODOS_LOS_ERRORES;
      set WORK.TODOS_LOS_ERRORES WORK.CALCULO_ERRORES;
    run;

  %end;

  /* 5. Resultado final */
  proc sort data=WORK.TODOS_LOS_ERRORES;
    by HORIZONTE;
  run;

  proc means data=WORK.TODOS_LOS_ERRORES mean median;
    title "RESULTADOS FINALES VECM (Rank=&rango_ecm): HORIZONTES 1 A 22";
    var error_eurostoxx50 error_dax40;
    by HORIZONTE;
    output out=&tabla_salida(drop=_TYPE_ _FREQ_) 
           mean=ERROR_MEDIO_EURO ERROR_MEDIO_DAX 
           median=ERROR_MEDIANO_EURO ERROR_MEDIANO_DAX;
  run;
  title;

%mend simula_predicciones_vecm_bolsa;


/* EJECUCIÓN DE LA SIMULACIÓN: Se fuerza Rank=1 en la restricción ECM para aplicar
el vector de cointegración hallado.*/
%simula_predicciones_vecm_bolsa(
  tabla_entrada=TP.bolsa_para_modelar,
  idFecha=fecha,
  fecha_inicial='13nov2025'd,
  fecha_final='12dec2025'd,
  rango_ecm=1,
  horizonte=22,
  tabla_salida=work.resultado_vecm_rank1
);

/* Visualización de errores por horizonte */
proc print data=work.resultado_final_var; title "MAPE por Horizonte - Modelo VAR"; run;
proc print data=work.resultado_vecm_rank1; title "MAPE por Horizonte - Modelo VECM"; run;



/*----------------------------------------------------------------------------*/
/* 5. DIAGNOSIS FINAL Y COMPARATIVA DE RESULTADOS                             */
/*----------------------------------------------------------------------------*/

/* Cálculo del MAPE in-sample para el VAR(1)*/
proc varmax data=TP.bolsa_para_modelar noprint;
   model eurostoxx50 dax40 / p=1 dify(1) noint;
   output out=work.insample_var;
run;

data work.mape_insample;
   set work.insample_var;
   if res1 ne . then mape_euro = abs(res1/eurostoxx50)*100;
   if res2 ne . then mape_dax = abs(res2/dax40)*100;
run;

proc means data=work.mape_insample mean;
   title "MAPE In-Sample - Modelo VAR";
   var mape_euro mape_dax;
run;

/*  Variable    Media 
	mape_euro   0.7475561
	mape_dax    0.7776097  
*/


/* Cálculo del MAPE in-sample para el VECM(2) Rank=1 */
proc varmax data=TP.bolsa_para_modelar noprint;
   /* p=2 porque es el equivalente en niveles al VAR(1) en diferencias */
   model eurostoxx50 dax40 / p=2 ecm=(rank=1); 
   output out=work.insample_vecm;
run;

data work.mape_insample_vecm;
   set work.insample_vecm;
   if res1 ne . then mape_euro = abs(res1/eurostoxx50)*100;
   if res2 ne . then mape_dax = abs(res2/dax40)*100;
run;

proc means data=work.mape_insample_vecm mean;
   title "MAPE In-Sample - Modelo VECM";
   var mape_euro mape_dax;
run;

/* Variable    Media 
   mape_euro   0.7468320
   mape_dax    0.7765848 
*/


/* Comparativa final de MAPES out-of-sample */
data work.comparativa_final;
	merge work.resultado_final_var(rename=(ERROR_MEDIO_EURO=MAPE_VAR_EURO ERROR_MEDIO_DAX=MAPE_VAR_DAX))
	      work.resultado_vecm_rank1(rename=(ERROR_MEDIO_EURO=MAPE_VECM_EURO ERROR_MEDIO_DAX=MAPE_VECM_DAX));
	by HORIZONTE;
run;

proc print data=work.comparativa_final;
   title "Comparativa de Precisión: VAR vs VECM por Horizonte";
run;


/*Gráfico de comparación*/
legend1 label=none 
        value=('VAR' 'VECM') 
        position=(bottom center) 
        mode=protect;

proc gplot data=work.comparativa_final;
   plot MAPE_VAR_EURO*HORIZONTE=1 MAPE_VECM_EURO*HORIZONTE=2 / overlay legend=legend1;
   symbol1 i=join v=dot c=blue; /* VAR */
   symbol2 i=join v=dot c=red;  /* VECM */
   label HORIZONTE="Días de predicción (Horizonte)"
         MAPE_VAR_EURO="Error Porcentual (MAPE %)";
   title "Evolución del Error (MAPE) por Horizonte: VAR vs VECM (Eurostoxx)";
run;
quit;

ods html close;

/*----------------------------------------------------------------------------*/
/* 6. CONCLUSIONES FINALES                                                    */
/*----------------------------------------------------------------------------*/

/* 1. Estacionariedad: ambas series son I(1), presentando una raíz 
      unitaria que obliga a diferenciar.
  
   2. VAR: el criterio AICC sugirió un VARMA(1,1), pero el test de 
      Portmanteau confirmó que un VAR(1) es suficiente para obtener 
      ruido blanco.
   
   3. Cointegración: aunque el test de Johansen no fue conlcuyente,
      el test de Engle-Granger confirmó cointegración (p = 0.0196).
   
   4. Comparativa: El modleo VECM(2) ofrece un aligera mejora en el 
      MAPE in-sample respecto al VAR(1). En la predicción out-of-sample,
      se observa que el VECM aprovecha la relación de equilibrio a largo
      plazo para estabilizar las predicciones en horizontes lejanos.
  
   5. Intervenciones: No se han incluido variables de intervención,
      dado que el proceso residual del modelo VAR(1) ya cumplía con 
      la condición de ruido blanco sin necesidad de parámetros adicionales.
*/
