function [vector_U, x_intervalos] = mi_laxWendroff_3(v, t_final, intervalo, delta_T, delta_X, condicion_ini)
%
% ENTRADAS:
%   v          : Velocidad de transporte (constante).
%   t_final    : Tiempo final de la simulación.
%   intervalo  : Vector [x_min, x_max] del dominio espacial.
%   delta_T    : Tamaño del paso temporal (dt).
%   delta_X    : Tamaño del paso espacial (dx).
%   condicion_ini: Condicion inical
% SALIDAS:
%   vector_U   : Vector de solución en el tiempo final t_final.
%   x_intervalos: Vector de puntos espaciales.
%   t_intervalos: Vector de puntos temporales.

nu = v * delta_T / delta_X; 
    
L = intervalo(2) - intervalo(1); 
N_x = round(L / delta_X) + 1;
N_t = round(t_final / delta_T) + 1;
    
x_intervalos = linspace(intervalo(1), intervalo(2), N_x);

    
% Inicialización: vector_U es el vector de solución actual (U^n)
vector_U = condicion_ini(x_intervalos);
    
nu_half = nu / 2;
nu_cuadrado_half = (nu^2) / 2;

for i = 1:N_t - 1
        
% U_siguiente contendrá la solución en el paso de tiempo i+1 (U^{n+1})
    U_siguiente = vector_U; 
        
    % 1. CÁLCULO DE PUNTOS INTERIORES 
        
    % Indices para U_{j-1} (izquierdo)
    idx_izq = 1 : N_x-2;
    % Indices para U_{j} (central)
    idx_cen = 2 : N_x-1;
    % Indices para U_{j+1} (derecho)
    idx_der = 3 : N_x;

    % ESQUEMA LAX-WENDROFF VECTORIZADO:
        
    % 1. Término de diferencia centrada (difusión numérica de primer orden)
    diferencia_centrada = nu_half * (vector_U(idx_der) - vector_U(idx_izq));
        
    % 2. Término de Lax-Wendroff (difusión numérica de segundo orden)
    diferencia_segundo_orden = nu_cuadrado_half * (vector_U(idx_der) - 2*vector_U(idx_cen) + vector_U(idx_izq));

    % Actualización de los puntos interiores
    U_siguiente(idx_cen) = vector_U(idx_cen) - diferencia_centrada + diferencia_segundo_orden;

    % 2. APLICACIÓN DE CONDICIONES DE CONTORNO
    % C.C. Nulas en ambos extremos
    U_siguiente(1) = 0;   % Punto j=1 (x_min)
    U_siguiente(N_x) = 0; % Punto j=N_x (x_max)
        
    % Actualizar el vector de solución principal
    vector_U = U_siguiente;
end 
end