function [vector_U, x_intervalos] = mi_upwind(v, t_final, intervalo, delta_T, delta_X, condicion_ini)
%
% ENTRADAS:
%   v          : Velocidad de transporte (constante).
%   t_final    : Tiempo final de la simulación.
%   intervalo  : Vector [x_min, x_max] del dominio espacial.
%   delta_T    : Tamaño del paso temporal (dt).
%   delta_X    : Tamaño del paso espacial (dx).
%   condicion_ini: La función de condición inicial.
% SALIDAS:
%   vector_U   : Vector de solución en el tiempo final t_final.
%   x_intervalos: Vector de puntos espaciales.
%

nu = v * delta_T / delta_X; % Número de Courant
    
% Parámetros de Discretización y Mallado
L = intervalo(2) - intervalo(1); 
N_x = round(L / delta_X) + 1;
N_t = round(t_final / delta_T) + 1;
    
% Puntos de mallado
x_intervalos = linspace(intervalo(1), intervalo(2), N_x);
    
% Inicialización: vector_U es ahora el vector de solución actual
vector_U = condicion_ini(x_intervalos);
    
% Bucle de Tiempo
for i = 1:N_t - 1
    % U_siguiente contendrá la solución en el paso de tiempo i+1
    U_siguiente = vector_U; 
        
    if v > 0 % Flujo hacia la derecha (Upwind usa el punto j-1)
        U_siguiente(2:N_x) = vector_U(2:N_x) - nu * (vector_U(2:N_x) - vector_U(1:N_x-1));
        % Condición de Contorno Nula en la entrada (izquierda, j=1)
        U_siguiente(1) = 0; 
            
    else % Flujo hacia la izquierda (Upwind usa el punto j+1)
         U_siguiente(1:N_x-1) = vector_U(1:N_x-1) - nu * (vector_U(2:N_x) - vector_U(1:N_x-1));         
          % Condición de Contorno Nula en la entrada (derecha, j=N_x)
         U_siguiente(N_x) = 0; 
    end 
        % Actualizar el vector de solución (vector_U se convierte en U^{n+1})
        vector_U = U_siguiente;
end 
end