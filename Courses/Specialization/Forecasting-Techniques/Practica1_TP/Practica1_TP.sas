
/*Practica GARCH - Serie Eurostoxx50*/

libname TP "C:\MARTA\Mestrado\Asignaturas ahora\TP\Practica1\final";

data TP.eurostoxx50_DIARIA;
  %let _EFIERR_ = 0; 
  infile 'C:\MARTA\Mestrado\Asignaturas ahora\TP\Practica1\final\serie_eurostoxx50.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
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

/*****************************************/
/* La bolsa cierre los fines de semana   */
/* Por tanto, una posible estacionalidad */
/* sería de orden 5. Sin embargo, también*/
/* puede cerrar otros días festivos      */
/* que no estarán informados. Para evitar*/
/* que esto puede romper ese posible     */
/* (aunque raro) efecto estacional,      */
/* completamos el histórico con todos los*/
/* datos y quitamos los fines de semana  */
/*****************************************/


/* Ordenar por fecha*/
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


/* Guardamos la semana más reciente para test*/
data work.eurostoxx50_DIARIA;
  set work.eurostoxx50_DIARIA(drop= Close);
  recuerda_eurostoxx50=eurostoxx50;
  if fecha > '03dec2025'd then eurostoxx50=.;
run;


/* Graficamos la serie*/
goptions device=activex;
ods html style=sasweb;

  proc gplot data=work.eurostoxx50_DIARIA;
    plot eurostoxx50*fecha/href=('03jan2021'd) chref=red lhref=2;
    symbol i=join v=dot h=0.1 c=black;
  run;
  quit;

ods html close;




/*******************************************/
/* Aplicamos la metodología de Box-Jenkins */
/*******************************************/

/*********************************/
/* ¿ES ESTACIONARIA EN VARIANZA? */
/*********************************/

ods html;
%boxcoxar(work.eurostoxx50_DIARIA,eurostoxx50,nlambda=3,lambdalo=0,lambdahi=1);

/* No tendria que hacer nada*/ 

/*
LAMBDA   LOGLIK    RMSE        AIC       SBC 
1.0     -5402.47  2457.11   10816.95   10846.53 
0.5     -5415.13  2431.54   10842.26   10871.84 
0.0     -5439.07  2442.76   10890.15   10919.73 
*/

/*Por AIC, SBC no hace falta tomar logaritmo - los menores valores están en lambda = 1 y para el LOGLIK el mayor valor (el menos negativo)*/
/*Por RMSE ganaría lambda = 0.5 */



/* Tomamos la decisión haciendo un gráfico std-media*/
data work.eurostoxx50_DIARIA;
	set work.eurostoxx50_DIARIA;
	idSemana=week(fecha);
	anyo=year(fecha);
	mes=month(fecha);
run;

proc means data=work.eurostoxx50_DIARIA
	/* Estadísticos a calcular */
	std mean noprint;
	/* Variable a analizar */
	var eurostoxx50;
	/* Variable en función de la cual */
	/* quiero agrupar los cálculos */
	by anyo mes;
	/* Generación de una tabla de salida */
	output
	/* Nombre de la tabla de salida */
	out=work.salidaParaGraficoStdMedia
	/* Nombres de las variables */
	/* que contendrán los estadísticos */
	std=std_eurostoxx50
	mean=media_eurostoxx50;
run;
quit;

data work.salidaParaGraficoStdMedia;
	set work.salidaParaGraficoStdMedia;
	log_std_eurostoxx50 = log(std_eurostoxx50);
	log_media_eurostoxx50 = log(media_eurostoxx50);
run;

ods html;
proc gplot data=work.salidaParaGraficoStdMedia;
	plot
	log_std_eurostoxx50*log_media_eurostoxx50;
	symbol v=dot h=0.1 c=blue
	i=rline /* Ajusta una línea de regresión */
	;
run;
quit;

proc reg data=work.salidaParaGraficoStdMedia;
	model 
	log_std_eurostoxx50=
	log_media_eurostoxx50;
run;
quit;

/*Por semana
Estimaciones de parámetro 
Variable                DF   Estimación de parámetros   Error estándar     t valor   Pr > |t| 
Intercept               1    12.33559                   3.81156            3.24      0.0022 
log_media_eurostoxx50   1    -0.96213                   0.45271            -2.13     0.0390 
*/

/*Por mes
Estimaciones de parámetro 
Variable                DF   Estimación de parámetros   Error estándar     t valor   Pr > |t| 
Intercept               1    12.33559                   3.81156            3.24      0.0022 
log_media_eurostoxx50   1    -0.96213                   0.45271            -2.13     0.0390 
*/

/* salen iguales*/ 

/*Más cercanos a 0 -> Alpha=0 => lambda = 1*/
/*No tomamos transformación*/

/*Sale pendiente -0.96213
si hacemos 1 -( -0.96213) > 1 entonces no aplicaria nada*/



/******************************/
/* ¿ES ESTACIONARIA EN MEDIA? */
/******************************/

%dftest(work.eurostoxx50_DIARIA, eurostoxx50,dlag=1,ar=2,trend=0);
%put &dfpvalue;
/*0.8851922881 - la serie tiene tendencia, seria necesario diferenciar*/

ods html;
proc arima data=work.eurostoxx50_DIARIA;
	identify var= eurostoxx50 stationarity=(adf dlag=1);
run;
quit;

/*
Pruebas aumentadas de la raíz unidad de Dickey-Fuller 
Tipo          Retardos   Rho       Pr < Rho   Tau   Pr < Tau   F      Pr > F
Media cero    0          0.2689    0.7479     0.81  0.8874     
  			  1          0.2641    0.7467     0.82  0.8880     
  			  2          0.2590    0.7454     0.80  0.8852     
Media simple  0          -1.3211   0.8548    -0.55  0.8792    0.55    0.9369 
 			  1          -1.1763   0.8694    -0.50  0.8891    0.52    0.9460 
 			  2          -1.1663   0.8704    -0.49  0.8901    0.51    0.9510 
Tendencia 	  0 		 -27.4231  0.0141 	 -4.20  0.0046    9.39 	  0.0010 
  			  1          -27.6656  0.0133    -4.26  0.0037 	  9.73    0.0010 
  			  2          -28.7780  0.0104    -4.36  0.0026   10.19    0.0010 
*/



/* Podría ser necesario deferenciar - no estacionaria en media*/

/* Dada la baja potencia asociada al test de raíces unitarias,
no se tomará aún la decisión de diferenciar o no la serie.
Dicha decisión se tomará a la vista de las estimaciones que se vayan
obteniendo según va siendo ajustada la parte autorregresiva*/

/*Ajustamos un AR(1)*/
proc arima data=work.eurostoxx50_DIARIA;
	identify var=eurostoxx50;
  estimate plot p=(1);
run;
quit;
/*
Estimación por mínimos cuadrados condicional 
Parámetro    Estimación Error estándar   t valor    Aprox.Pr > |t|   Retardo 
MU 			 4332.6 	47.54446 		 91.13		 <.0001          0 
AR1,1		 0.99950	0.0022292		 448.36		 <.0001			 1 
*/ 


/*Como el intervalo (0.99950-2*0.0022292, 0.99950-2*0.0022292)= (0.9950416, 1.0039584) contiene el 1, vamos a diferenciar la serie */

/* Diferenciamos - ARIMA(0,1,0)*/
proc arima data=work.eurostoxx50_DIARIA;
	identify var=eurostoxx50(1);
  estimate plot;
  forecast out=work.salidaARIMA id=fecha;
run;
/* Mirando la tabla : Comprobación de autocorrelación de residuales ya tendriamos ruido blanco*/ 
/* Comprobación de autocorrelación de residuales
Para retardo  Chi-cuadrado     DF  Pr > ChiSq  		Autocorrelaciones 
6			  4.61 			   6   0.5953 		-0.023 0.000   -0.048   0.001    0.023   -0.033 
12 			  5.32			   12  0.9466 		0.004  0.015    0.016   0.013    0.003   -0.001 
18			  13.02			   18  0.7906 		-0.045 -0.009  -0.058   0.005   -0.038   -0.020 
24			  26.55			   24  0.3256 		0.077  -0.025   0.005   0.013   -0.006   -0.078 
30			  30.65			   30  0.4327 		0.003  0.021   -0.045   0.003    0.006    0.037 
36			  32.65            36  0.6286 		0.003  -0.018  -0.004  -0.031    0.017   -0.016 
42			  39.08            42  0.5998 		-0.049 -0.050   0.001   0.031   -0.016    0.002 
48			  42.68            48  0.6898 		-0.021 -0.007   0.001  -0.040    0.026    0.024 
*/


/* 
Estimación por mínimos cuadrados condicional 
Parámetro   Estimación   Error estándar   t valor   Aprox.Pr > |t|  Retardo 
MU          1.33341      1.48686          0.90      0.3700          0 
*/

/*Quitamos la constante que no es significativa*/

proc arima data=work.eurostoxx50_DIARIA;
	identify var=eurostoxx50(1);
  estimate plot noint;
  forecast out=work.salidaARIMA id=fecha;
run;
quit;
/*ARIMA(0,1,0) sin constante.
Al no presentar componentes de media movil o autorregresiva significativa, la
predicción para cualquier horizonte temporal es el último valor observado. 
El aumento progresivo de los intervalos de confianza refleja la acumulación de incertidumbre*/



/************************************************************/
/* Macro para realizar el test de normalidad de Jarque-Bera */
/************************************************************/

%macro jbtest(data = , var = );

   ods listing close;
   proc univariate data = &data ;
       var &var;
      ods output moments = _1;
   run;
  
   data _2;
      set _1;
	  if label1 = "Asimetría" then label1 = "Asimetria";
      label = label1; value = nValue1; output;
      label = label2; value = nValue2; output;
      drop cvalue: label1 label2 nvalue:;
   run;

   proc transpose data = _2 out = _3;
      by varname notsorted;
      id label;
      var value;
   run;

   data _4;
      set _3;
      jb = (Asimetria**2 * N)/6 + ((Curtosis)**2 *N)/24;
      p = 1 - probchi(jb, 2);
      label jb = 'JB Statistic' p = 'P-value'
         Curtosis = 'Excess Kurtosis'
		 Asimetria = 'Asimetría';
   run;
   ods listing;
   proc print data = _4 label;
      var varname N Asimetria Curtosis jb p;
   run;

%mend jbtest;

/* Lanzamos el test sobre los residuos del eurostoxx 50 */
%jbtest(data = WORK.salidaARIMA, var = residual);

/*Obs  VarName    N      Asimetría   Excess Kurtosis   JB Statistic   P-value 
  1    RESIDUAL   1022   -0.36129    3.33488           495.822        0      */

/* Los residuos no son normales y por tanto no son independientes pudiendo haber estructura ARCH*/ 


proc univariate data=WORK.salidaARIMA;
  var residual;
  histogram;
run;
quit;

/* Asimetría a la izquierda (-0.3612873) y curtosis (3.33488314) */
/*
Curtosis, 3.33:  "colas pesadas". En el Eurostoxx 50, los eventos extremos, como por ejemplo, subidas bruscas, 
                 ocurren con más frecuencia de lo que predeciría una distribución normal.

Asimetría negativa, -0.36: Indica que la cola de la izquierda es más larga. El mercado tiende a caer con más violencia de la que sube.*/


ods html close;
ods html;
proc autoreg data=work.salidaARIMA;
  model residual=/archtest noint;
run;
quit;
/* Existe estructura ARCH de orden alto */
/*Test para alteraciones ARCH basadas en residuales OLS 
Orden  Q          Pr > Q   LM         Pr > LM 
1	   78.2645	  <.0001   76.2939    <.0001 
2	   111.0131	  <.0001   87.8200    <.0001 
3	   191.9677	  <.0001   134.5375	  <.0001 
4	   222.5120   <.0001   136.3215   <.0001 
5	   243.7385   <.0001   138.3538   <.0001 
6	   255.0905   <.0001   138.4978   <.0001 
7	   256.1692   <.0001   141.1802   <.0001 
8	   260.6555   <.0001   141.4748   <.0001 
9      270.2254   <.0001   144.3283   <.0001 
10     270.5594   <.0001   144.8074   <.0001 
11     270.5650   <.0001   145.6053   <.0001 
12     271.4556   <.0001   145.6280   <.0001 
*/


/* Concretemos el orden del ARCH */
data work.salidaARIMA;
  set work.salidaARIMA;
  residualCuadrado=residual**2;
run;

goptions device=activex;
ods html style=sasweb;

  proc gplot data=salidaARIMA;
    plot residualCuadrado*fecha;
    symbol i=join v=dot h=0.1 c=blue;
  run;
  quit;

ods html close;

ods html;

proc arima data=work.salidaARIMA;
  identify var=residualCuadrado;
run;
quit;

/*Observando las fas y fap, se propone un ARCH(4)  - AR(4)*/
proc arima data=work.salidaARIMA;
  identify var=residualCuadrado;
  estimate plot p=4;
run;
quit;

/*Ya tendria ruido blanco ARCH(4)*/ 
/* Mirando la tabla : Comprobación de autocorrelación de residuales ya tendriamos ruido blanco*/

/* Comprobación de autocorrelación de residuales
Para retardo  Chi-cuadrado     DF  Pr > ChiSq  		Autocorrelaciones
6	 		  2.24	  			2  0.3262 		-0.002  -0.010   0.000   0.001   0.045  -0.004 
12	 		  12.29 	  		8  0.1387 		-0.055   0.012   0.062  -0.023  -0.047   0.002 
18	 		  19.26    		   14  0.1554 		 0.013   0.074  -0.032  -0.003  -0.004  -0.005 
24	 		  31.28    		   20  0.0516 		-0.008   0.028  -0.029   0.032   0.076   0.054 
30	 		  35.39    		   26  0.1035 		 0.010  -0.001   0.027  -0.046   0.004  -0.031 
36	 		  40.21    		   32  0.1511 		-0.022   0.052   0.013  -0.018   0.028   0.013 
42	          43.75    		   38  0.2404 		 0.040  -0.010  -0.001  -0.035  -0.002   0.019 
48	          46.51    		   44  0.3695 		 0.016  -0.029  -0.002  -0.019   0.031  -0.011 
*/



/* Sin embargo, proponemos tambien un ARMA(1,1) - Garch(1,1) por ser un modelo habitual */
proc arima data=work.salidaARIMA;
  identify var=residualCuadrado;
  estimate plot p=(1) q=(1);
run;
quit;

/* Aún siendo un modelo habitual, el
GARCH(1,1) no genera RB, por lo
que iremos con el ARCH(4).*/


/* Decidimos seguir con el ARCH(4)*/
/* Utilizamos autoreg*/
proc autoreg data=work.salidaARIMA;
  model residual=/garch=(q=(1 2 3 4)) noint;
run;
quit;

/* Estimaciones de parámetro 
Variable  DF  Estimación  Error estándar   t valor   Aprox.Pr > |t| 
ARCH0	  1   1332        85.7852          15.53     <.0001 
ARCH1 	  1   0.1172      0.0295           3.97      <.0001 
ARCH2     1   0.0197      0.0275           0.72      0.4741 
ARCH3     1   0.1347      0.0283           4.76      <.0001 
ARCH4     1   0.1146      0.0349           3.29      0.0010 
*/

/*El parámetro ARCH2 no sale significativo
Sin embargo, no tiene sentido generar una descontinuidad, 
nos fijaríamos en los residuales cuadráticos de hace 1,3 y 4 días,
pero no de hace 2.*/

/*Ya obtenemos ruído blanco*/



/*************************************/
/* Análisis de efecto apalancamiento */
/*************************************/

data work.salidaARIMA;
  set work.salidaARIMA;
  residual1=lag(residual);
  residual2=lag2(residual);
  residual3=lag3(residual);
  residual4=lag4(residual);
run;

proc reg data=work.salidaARIMA;
  model residualCuadrado=residual1 
                         residual2 
                         residual3 
                         residual4;
run;
quit;

/* Existe efecto apalancamiento */
/*Estimaciones de parámetro 
Variable    DF   EstimaciónParámetros   ErrorEstándar  t valor   Pr > |t| 
Intercept   1    2345.76330				155.08225      15.13     <.0001 
residual1   1    -20.93846              3.26198 	   -6.42     <.0001 
residual2   1    -4.68099 		        3.25595        -1.44     0.1508 
residual3   1    -21.85135 		        3.25559        -6.71     <.0001 
residual4   1    -17.58024              3.25779        -5.40     <.0001 
*/ 

/* Se confirma la presencia de efecto de apalancamiento en la serie del Eurostoxx 50
El retardo 2 no significativo es consistente con la estructura detectada previamente 
en la fase de identificación del modelo ARCH*/

/* Se pueden ajustar los 3 tipos de modelos no lineales vistos*/

/*EGARCH(4)*/
proc autoreg data=work.salidaARIMA;
  model residual=/
  garch=(q=(1 2 3 4),type=egarch) noint;
run;
quit;
/*                                    Estimaciones de parámetro

                                                       Error                 Aprox.
               Variable        DF    Estimación     estándar    t valor    Pr > |t|

               EARCH0           1        7.6285       0.0412     185.20      <.0001
               EARCH1           1        0.2030       0.0465       4.37      <.0001
               EARCH2           1        0.0423       0.0259       1.63      0.1026
               EARCH3           1        0.1678       0.0373       4.50      <.0001
               EARCH4           1        0.1655       0.0419       3.95      <.0001
               THETA            1       -1.1952       0.2624      -4.56      <.0001
*/

/*GJR-ARCH(4)*/
proc autoreg data=work.salidaARIMA;
  model residual=/
  garch=(q=(1 2 3 4),type=gjr) noint;
run;
quit;
/*                                    Estimaciones de parámetro

                                                       Error                 Aprox.
               Variable        DF    Estimación     estándar    t valor    Pr > |t|

               TARCHA0          1          1444      87.0136      16.60      <.0001
               TARCHA1          1       -0.0591     0.008657      -6.82      <.0001
               TARCHA2          1       -0.0304       0.0223      -1.36      0.1725
               TARCHA3          1       -0.0125       0.0229      -0.55      0.5856
               TARCHA4          1       -0.0186       0.0131      -1.42      0.1549
               TARCHB1          1        0.3010       0.0657       4.58      <.0001
               TARCHB2          1        0.0843       0.0439       1.92      0.0547
               TARCHB3          1        0.3181       0.0607       5.24      <.0001
               TARCHB4          1        0.2371       0.0516       4.60      <.0001

*/

/*QARCH(4)*/
proc autoreg data=work.salidaARIMA;
  model residual=/
  garch=(q=(1 2 3 4),type=qgarch) noint;
run;
quit;
/*                                    Estimaciones de parámetro

                                                       Error                 Aprox.
               Variable        DF    Estimación     estándar    t valor    Pr > |t|

               QARCHA0          1          1606     162.3617       9.89      <.0001
               QARCHA1          1        0.0797       0.0283       2.82      0.0048
               QARCHA2          1             0            0        .         .
               QARCHA3          1        0.1004       0.0349       2.87      0.0040
               QARCHA4          1        0.0612       0.0328       1.86      0.0622
               QARCHB1          1       39.1664      22.7030       1.73      0.0845
               QARCHB2          1     0.0000419            0      Infty      <.0001
               QARCHB3          1       25.8148      20.0026       1.29      0.1969
               QARCHB4          1        4.5835      16.7624       0.27      0.7845
*/


/* A la vista de la significatividad de los parámetros, parece que lo más adecuado sería
ajustar un ARCH exponencial EARCH(4)*/



/********************/
/* ¿Existe GARCH-M? */
/********************/

/*ARCH(4)-M*/
proc autoreg data=work.salidaARIMA;
  model residual=/
  garch=(q=(1 2 3 4),mean=linear) noint;
run;
quit;
/* Significativo - DELTA 1  0.001841  0.000624  2.95  0.0032   */


/*EARCH(4)-M*/
proc autoreg data=work.salidaARIMA;
  model residual=/
  garch=(q=(1 2 3 4),type=egarch,mean=linear) noint;
run;
quit;

/*DELTA 1  0.000853  0.000670  1.27  0.2032  
Aquí el efecto GARCH-M no es significativo*/


/*Par el ARCH(4)-M*/
/*Como en el ARCH(4) el efecto es significativo (p-valor<0.05):
Significa que cuando la volatilidad (ht) aumenta, el retorno esperado de la serie
también aumenta*/

/*Ecuación de la media:
Retornot = 0.001841*ht + epsilon_t*/

/*Ecuación de la varianza- ARCH(4)
ht = 1292 + 0.1224 *epsilon_{t-1}^2 + 0.0107*epsilon_{t-2}^2 + 0.0.1417*epsilon_{t-3}^2 + 0.1313*epsilon_{t-4}^2*/



/****************/
/* Predicciones */
/****************/

/*Primero se realizan varias pruebas para los modelos propuestos*/

/***************************************************/
/* Se representan las predicciones de la           */
/* volatilidad y se comparan con los "datos        */
/* reales" (aproximados por residuales al cuadrado)*/
/***************************************************/

/* EARCH(4) sin GARCH-M */

proc autoreg data=work.salidaARIMA;
  model residual=/garch=(q=(1 2 3 4),type=egarch) noint;
  output out=work.salidaAUTOREG1
  p=prediccionIncrementoEUROSTOXX50
  /*************************************************/
  /* Si no existen variables independientes en el  */
  /* modelo que predice la media (como es el       */
  /* caso, donde ya se juega con el residuo del    */
  /* ARIMA, se puede utilizar ht (volatilidad)     */
  /* o cev (=conditional error variance), es igual */
  /* Si existieran variables independientes        */
  /* debería utilizarse cpev (=c prediction ev     */
  /*************************************************/
  ht=predVolatilidad;
run;
quit;
/*                                 Estimaciones GARCH exponenciales

                SSE                  2308642.29    Observaciones               1022
                MSE                        2259    Var Uncond                     .
                Verosimilitud log    -5323.9675    R-cuadrado total          0.0000
                SBC                  10689.5121    AIC                    10659.935
                MAE                  34.3471235    AICC                  10660.0178
                MAPE                        100    HQC                   10671.1645
                                                   Test de normalidad      110.2656
                                                   Pr > ChiSq                <.0001

*/

/***************************************************/
/* Para calcular la volatilidad diaria, deberíamos */
/* disponer de varios datos intradiarios y hallar  */
/* la varianza. En ausencia de ellos, tomaremos el */
/* máximo y el mínimo diario y calcularemos una    */
/* medida de dispersión alternativa (el rango),    */
/* que debe estar elevada al cuadrado porque la    */
/* volatilidad es h(t)=sigma(t)**2                 */
/***************************************************/

data work.salidaAUTOREG1;
  merge work.salidaAUTOREG1(in=a) 
  work.Eurostoxx50_DIARIA(keep=fecha recuerda_Eurostoxx50 maximo_Eurostoxx50 minimo_Eurostoxx50);
  by fecha;
  if a;
  /* Máximo incremento real del día */
  maximoIncrementoEurostoxx50=maximo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  /* Mínimo incremento real del día */
  minimoIncrementoEurostoxx50=minimo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  rangoIncrementoAlCuadrado=(maximoIncrementoEurostoxx50-minimoIncrementoEurostoxx50)**2;
run;

ods html style=sasweb;
goptions device=activex;

  proc gplot data=work.salidaAUTOREG1(rename=(residual=incrementoEurostoxx50));
    plot incrementoEurostoxx50*fecha=1
    prediccionIncrementoEurostoxx50*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

  proc gplot data=work.salidaAUTOREG1;
    plot rangoIncrementoAlCuadrado*fecha=1
    predVolatilidad*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

ods html close;

/********************************************************/
/* Como efecto del ARCH(4), las 4 primeras predicciones */
/* experimentan variaciones y luego se queda constante  */
/********************************************************/


/* EARCH(4) con GARCH-M */
ods html;
proc autoreg data=work.salidaARIMA;
  model residual=/garch=(q=(1 2 3 4),type=egarch,mean=linear) noint;
  output out=work.salidaAUTOREG2
  p=prediccionIncrementoEurostoxx50
  ht=predVolatilidad;
run;
quit;
/*                                 Estimaciones GARCH exponenciales

                SSE                   2304905.2    Observaciones               1022
                MSE                        2255    Var Uncond                     .
                Verosimilitud log    -5323.6023    R-cuadrado total          0.0016
                SBC                  10695.7112    AIC                   10661.2045
                MAE                  34.3028747    AICC                   10661.315
                MAPE                 128.872311    HQC                   10674.3056
                                                   Test de normalidad      119.1227
                                                   Pr > ChiSq                <.0001

*/


data work.salidaAUTOREG2;
  merge work.salidaAUTOREG2(in=a) 
  work.Eurostoxx50_DIARIA(keep=fecha recuerda_Eurostoxx50 maximo_Eurostoxx50 minimo_Eurostoxx50);
  by fecha;
  if a;
  /* Máximo incremento real del día */
  maximoIncrementoEurostoxx50=maximo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  /* Mínimo incremento real del día */
  minimoIncrementoEurostoxx50=minimo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  rangoIncrementoAlCuadrado=(maximoIncrementoEurostoxx50-minimoIncrementoEurostoxx50)**2;
run;

ods html style=sasweb;
goptions device=activex;

  proc gplot data=work.salidaAUTOREG2(rename=(residual=incrementoEurostoxx50));
    plot incrementoEurostoxx50*fecha=1
    prediccionIncrementoEurostoxx50*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

  proc gplot data=work.salidaAUTOREG2;
    plot rangoIncrementoAlCuadrado*fecha=1
    predVolatilidad*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

ods html close;

/********************************************************/
/* Como efecto del ARCH(4), las 4 primeras predicciones */
/* experimentan variaciones y luego se queda constante  */
/* Además, en este caso, la predicción de la media != 0 */
/********************************************************/


/* ARCH(4) con GARCH-M */
ods html;
proc autoreg data=work.salidaARIMA;
  model residual=/garch=(q=(1 2 3 4),mean=linear) noint;
  output out=work.salidaAUTOREG3
  p=prediccionIncrementoEurostoxx50
  ht=predVolatilidad;
run;
quit;
/*                                        Estimaciones GARCH

                SSE                  2323397.02    Observaciones               1022
                MSE                        2273    Var Uncond                     .
                Verosimilitud log    -5335.4471    R-cuadrado total               .
                SBC                  10712.4713    AIC                   10682.8942
                MAE                  34.4004143    AICC                  10682.9769
                MAPE                 176.040013    HQC                   10694.1236
                                                   Test de normalidad      180.8872
                                                   Pr > ChiSq                <.0001
*/


data work.salidaAUTOREG3;
  merge work.salidaAUTOREG3(in=a) 
  work.Eurostoxx50_DIARIA(keep=fecha recuerda_Eurostoxx50 maximo_Eurostoxx50 minimo_Eurostoxx50);
  by fecha;
  if a;
  /* Máximo incremento real del día */
  maximoIncrementoEurostoxx50=maximo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  /* Mínimo incremento real del día */
  minimoIncrementoEurostoxx50=minimo_Eurostoxx50-lag(recuerda_Eurostoxx50);
  rangoIncrementoAlCuadrado=(maximoIncrementoEurostoxx50-minimoIncrementoEurostoxx50)**2;
run;

ods html style=sasweb;
goptions device=activex;

  proc gplot data=work.salidaAUTOREG3(rename=(residual=incrementoEurostoxx50));
    plot incrementoEurostoxx50*fecha=1
    prediccionIncrementoEurostoxx50*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

  proc gplot data=work.salidaAUTOREG3;
    plot rangoIncrementoAlCuadrado*fecha=1
    predVolatilidad*fecha=2/overlay legend=legend1;
    symbol1 i=join v=dot h=0.5 c=blue;
    symbol2 i=join v=dot h=0.5 c=red;
    legend1;
  run;
  quit;

ods html close;


/*Se selecciona como modelo definitivo el EGARCH(4) sin efecto GARCH-M, ya que
presenta los criterios de información más bajos de toda la comparativa, con un AIC de
10659.935 y un SBC de 10689.5121. Además, el modelo captura el efecto de apalancamiento
mediante un parámetro theta significativo, mientras que se descarla la variante GARCH-M
por la falta de significatividad estadística.*/


/**********************/
/*PREDICCIONES FINALES*/
/**********************/

/* Predicciones solo de la ventana de test*/
/* MODELO ELEGIDO: EGARCH(4) SIN GARCH-M */
/* Estimación conjunta ARIMA(0,1,0)+EGARCH(4)*/
/* Comparación en ventana de test (fechas > 19dec2025) */

/* Calcular retornos a partir de eurostoxx50  */
data work.retornos;
    set work.eurostoxx50_DIARIA;
    by fecha;
    retorno = dif(eurostoxx50);   /* retorno = precio_t - precio_{t-1} */
    if _n_ = 1 then retorno = .;  /* El primer registro no tiene retorno */
run;


/* Estimar modelo EGARCH(4) y obtener pronósticos*/
proc autoreg data=work.retornos;
    model retorno = / noint garch=(q=(1 2 3 4), type=egarch);
    output out=work.pronosticos_egarch
		   lcl=lcl_y
		   ucl=ucl_y
           p=predRetorno          
           ht=predVolatilidad;    /* varianza condicional pronosticada */
run;
quit;

/* Calcular los retornos REALES de la semana de test */
data work.reales_test;
    set work.eurostoxx50_DIARIA;
    by fecha;
    retain precio_anterior;
    if _n_ = 1 then precio_anterior = .;
    else retorno_real = recuerda_eurostoxx50 - precio_anterior;
    precio_anterior = recuerda_eurostoxx50;
    keep fecha retorno_real;
run;


/* Fusionar pronósticos con reales y filtrar semana de test */
data work.comparacion_test;
    merge work.pronosticos_egarch(keep=fecha predRetorno predVolatilidad lcl_y ucl_y recuerda_eurostoxx50)
          work.reales_test;
    by fecha;
    where fecha > '03dec2025'd;   /* Solo nos interesa la semana de test */
    retornoCuadrado = retorno_real**2;   /* Volatilidad realizada aproximada */
run;

/* Graficar retorno real vs predicho (solo test) */
ods html style=sasweb;
goptions device=activex;

proc gplot data=work.comparacion_test;
	
    plot retorno_real * fecha = 1
         predRetorno  * fecha = 2
		 ucl_y * fecha = 3
		 lcl_y * fecha = 4
         / overlay legend = legend1;
    symbol1 i = join v = dot h = 0.4 c = black;
    symbol2 i = join v = dot h = 0.4 c = red;
	symbol3 i = join v = none l = 3 c = gray;
	symbol4 i = join v = none l = 3 c = gray;
    legend1 label = ("Retorno real vs predicho (test)");

run;
quit;


/* Graficar volatilidad realizada vs predicha (solo test) */
proc gplot data=work.comparacion_test;
    plot retornoCuadrado * fecha = 1
         predVolatilidad  * fecha = 2
         / overlay legend = legend1;
    symbol1 i = join v = dot h = 0.4 c = blue;
    symbol2 i = join v = dot h = 0.4 c = red;
    legend1 label = ("Volatilidad realizada vs predicha (test)");
run;
quit;

ods html close;


/* Calcular precios*/
/* Guardar el último precio antes de test*/
proc sql noprint;
   select recuerda_eurostoxx50 into :ultimo_precio
   from work.eurostoxx50_DIARIA
   where fecha = '03dec2025'd;
quit;

data work.comparacion_PRECIO;
   set work.comparacion_test;
   retain precio_pred var_acumulada;
   
   if _n_ = 1 then do;
      /* Primer día del test: partimos del último precio real */
      precio_pred = &ultimo_precio + predRetorno; 
      var_acumulada = predVolatilidad; 
   end;
   else do;
      /* Días siguientes: vamos acumulando */
      precio_pred = precio_pred + predRetorno; 
      var_acumulada = var_acumulada + predVolatilidad;
   end;
   
   /* El error típico del precio es la raíz de la varianza acumulada */
   std_error_precio = sqrt(var_acumulada);
   
   /* Calculamos los nuevos límites para el precio */
   ucl_precio = precio_pred + 1.96 * std_error_precio;
   lcl_precio = precio_pred - 1.96 * std_error_precio;
   
   precio_real = recuerda_eurostoxx50;
run;

/*NOTA: Para el cálculo de los intervalos de confianza al 95%, se utiliza el valor
crítico de 1.96 correspondiente a la distribución normal estándar. Aunque los test
indican que los residuos presnetan colas pesadas y no siguen una distribución normal,
se adopta este valor como una aproximación asintótica estándar para la construcción 
de las bandas de predicción en el horizonte de test.*/ 



ods html style=sasweb;
goptions device=activex;

proc gplot data=work.comparacion_PRECIO;
   plot precio_real * fecha = 1
        precio_pred * fecha = 2
        ucl_precio  * fecha = 3
        lcl_precio  * fecha = 4 / overlay legend=legend1;

		symbol1 i=none v=dot h=0.5 c=black;   
		symbol2 i=join v=none l=1 l=2 c=red;     
		symbol3 i=join v=none l=3 c=blue;   
		symbol4 i=join v=none l=3 c=blue;   

   legend1 label=("Prediccion de Niveles (Eurostoxx 50)")
           value=("Real" "Predicho" "Limite Sup" "Limite Inf");
   title "Prediccion de Precios con EGARCH(4)";
run;
quit;

/* Contrastar bondad de la predicción en la semana de test*/
data work.metricas_error;
   set work.comparacion_PRECIO;
   error = precio_real - precio_pred;
   error_abs = abs(error);
   error_cuadrado = error**2;
run;

proc means data=work.metricas_error mean;
   var error_abs error_cuadrado;
   output out=work.temp_rmse mean(error_cuadrado)=mse;
   title "Métricas de Error en la Semana de Test (Bondad de Predicción)";
run;

data work.rmse;
   set work.temp_rmse;
   rmse = sqrt(mse); /* Calculamos el RMSE */
   label rmse = "Raíz del Error Cuadrático Medio (RMSE)";
run;

proc print data=work.rmse noobs label;
   var rmse;
   title "Resultado Final: Bondad de Ajuste";
run;
/*RMSE - 32.3800*/


