function [vector_U, x_intervalos] = mi_centrado(v, t_final, intervalo, delta_T, delta_X, condicion_ini)
%
% ENTRADAS:
%   v          : Velocidad de transporte (constante).
%   t_final    : Tiempo final de la simulación.
%   intervalo  : Vector [x_min, x_max] del dominio espacial.
%   delta_T    : Tamaño del paso temporal (dt).
%   delta_X    : Tamaño del paso espacial (dx).
%   condicion_ini: Handle de la función de condición inicial (@condicion_inicial).
% SALIDAS:
%   vector_U   : Vector de solución en el tiempo final t_final.
%   x_intervalos: Vector de puntos espaciales.
%   t_intervalos: Vector de puntos temporales.
%

% Parámetros de Discretización y Mallado
nu = v * delta_T / delta_X; % Número de Courant

% Calcular N_x y N_t a partir de delta_X y delta_T
L = intervalo(2) - intervalo(1); % Longitud del dominio espacial
N_x = round(L / delta_X) + 1;
N_t = round(t_final / delta_T) + 1;

% Puntos de mallado
x_intervalos = linspace(intervalo(1), intervalo(2), N_x);

% Aplicar condición inicial e inicializar vector_U (U^n)
vector_U = condicion_ini(x_intervalos);

% Bucle de Tiempo (Esquema Centrado Vectorial)
for i = 1:N_t - 1
    
    % vector_U(1:N_x-2) son los U_{j-1}^n
    % vector_U(3:N_x) son los U_{j+1}^n
    vector_U(2:N_x-1) = vector_U(2:N_x-1) + (nu/2) * (vector_U(1:N_x-2) - vector_U(3:N_x));
    
    % Condición de contorno nula en las fronteras (para ambos v)
    vector_U(1) = 0;  % Frontera izquierda (j=1)
    vector_U(N_x) = 0; % Frontera derecha (j=N_x)
end 
end