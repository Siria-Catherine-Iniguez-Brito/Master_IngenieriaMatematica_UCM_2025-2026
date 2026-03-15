% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL TRABAJO FINAL: EJERCICIO 2 
% -------------------------------------------------------------------------
% Este script resuelve la Ecuación de Burgers 
% (du/dt + u*du/dx = 0) usando tres esquemas de Volúmenes Finitos (Upwind, 
% Centrado, Lax-Wendroff) y calcula la solución exacta mediante el Método
% de Puntos Fijos.
% 
% Compara el error en norma infinito de los esquemas numéricos con la 
% solución exacta en el tiempo final T_final.
% -------------------------------------------------------------------------

clear; close all; clc;


% =========================================================================
%% 1. PARÁMETROS GLOBALES
% =========================================================================

% --- 1. PARÁMETROS DEL PROBLEMA ---
L_min = -2;         % Límite izquierdo del dominio
L_max = 2;          % Límite derecho del dominio
Delta_x = 0.01;     % Paso de espacio (Delta x)
Delta_t = 0.01;     % Paso de tiempo (Delta t) 
T_final = 0.5;      % Tiempo final de simulación


% =========================================================================
%% 2. PREPARACIÓN Y EJECUCIÓN 
% =========================================================================

% La condición inicial U0 : u(x,0)=max(0, 1 - x^2)^2
U_inicial = inicializar_condicion_inicial(L_min, L_max, Delta_x);

% 2.1. SIMULACIÓN UPWIND NO LINEAL
U_upwind = simular_burgers('paso_upwind', U_inicial, Delta_t, Delta_x, T_final);

% 2.2. SIMULACIÓN CENTRADO NO LINEAL
U_centrado = simular_burgers('paso_centrado', U_inicial, Delta_t, Delta_x, T_final);

% 2.3. SIMULACIÓN LAX-WENDROFF NO LINEAL
U_LW = simular_burgers('paso_lax_wendroff', U_inicial, Delta_t, Delta_x, T_final);

% 2.4. CÁLCULO DE LA SOLUCIÓN EXACTA 
U_exacta = calcular_solucion_exacta_puntfijo(L_min, L_max, Delta_x, T_final);

% Vector de posiciones x para graficar
x = (L_min + Delta_x/2) : Delta_x : (L_max - Delta_x/2);


% =========================================================================
%% 3. RESULTADOS FINALES
% =========================================================================

figure;
plot(x, U_upwind, 'b-', 'LineWidth', 2); hold on;
plot(x, U_centrado, 'r--', 'LineWidth', 2);
plot(x, U_LW, 'g:', 'LineWidth', 2);
plot(x, U_exacta, 'k', 'LineWidth', 1); 
title(sprintf('Comparación de Esquemas No Lineales en t = %.2f', T_final));
xlabel('Posición x');
ylabel('u(x,t)');
legend('Upwind', 'Centrado', 'Lax-Wendroff', 'Exacta', 'Location', 'NorthEast');
grid on;
axis([L_min L_max -0.1 1.1]);
hold off;

% CÁLCULO DEL ERROR EN NORMA INFINITO 
Error_Upwind = max(abs(U_upwind - U_exacta));
Error_Centrado = max(abs(U_centrado - U_exacta));
Error_LW = max(abs(U_LW - U_exacta));

fprintf('\nErrores en norma infinito (||u_num - u_exac||_inf):\n');
fprintf('Upwind:    %e\n', Error_Upwind);
fprintf('Centrado:  %e\n', Error_Centrado);
fprintf('Lax-W:     %e\n', Error_LW);


% =========================================================================
%% 4. FUNCIONES LOCALES 
% =========================================================================

% 1. FUNCIÓN DE INICIALIZACIÓN DE LA CONDICIÓN INICIAL 
function U0 = inicializar_condicion_inicial(L_min, L_max, Delta_x)
    x = (L_min + Delta_x/2) : Delta_x : (L_max - Delta_x/2);
    U0 = max(0, 1 - x.^2).^2; 
end


% 2. FUNCIÓN DE SIMULACIÓN GENÉRICA
function U_final = simular_burgers(nombre_funcion_paso, U_inicial, Delta_t, Delta_x, T_final)
    Nt = round(T_final / Delta_t);
    U_actual = U_inicial;
   
    funcion_paso = str2func(nombre_funcion_paso); 
    for n = 1:Nt
        U_actual = funcion_paso(U_actual, Delta_t, Delta_x);
    end
    U_final = U_actual; 
end


% 3. ESQUEMA UPWIND NO LINEAL 
function U_nuevo = paso_upwind(U_viejo, Delta_t, Delta_x)
    Nx = length(U_viejo);
    lambda = Delta_t / Delta_x;
    U_nuevo = zeros(1, Nx);
    for i = 1:Nx
        U_i = U_viejo(i);
        if i == 1
            U_i_menos_1 = 0; % Condición de contorno (CC) nula en borde izquierdo 
        else
            U_i_menos_1 = U_viejo(i-1);
        end
        % Flujo para Burgers: g(u) = u^2 / 2
        g_U_i = 0.5 * U_i^2;
        g_U_i_menos_1 = 0.5 * U_i_menos_1^2;
        
        % Diferencia de Flujos
        Diferencia_Flujo = g_U_i - g_U_i_menos_1;
        
        % U^{n+1}_i = U^n_i - lambda * [Diferencia_Flujo]
        U_nuevo(i) = U_i - lambda * Diferencia_Flujo;
    end
end


% 4. ESQUEMA CENTRADO NO LINEAL 
function U_nuevo = paso_centrado(U_viejo, Delta_t, Delta_x)
    Nx = length(U_viejo);
    lambda = Delta_t / Delta_x;
    U_nuevo = zeros(1, Nx);
    % CC: U_0=0 (inflow), U_{N+1}=U_N 
    U_fantasma = [0, U_viejo, U_viejo(end)]; 
    
    for i = 1:Nx
        U_i_menos_1 = U_fantasma(i);     
        U_i_mas_1 = U_fantasma(i+2);    
        
        % Flujo derecho:
        U_promedio_D = 0.5 * (U_viejo(i) + U_i_mas_1); 
        Q_D = 0.5 * U_promedio_D^2; 
        
        % Flujo izquierdo: 
        U_promedio_I = 0.5 * (U_i_menos_1 + U_viejo(i)); 
        Q_I = 0.5 * U_promedio_I^2; 
        
        % Diferencia de flujos: Q_D - Q_I
        Diferencia_Flujo = Q_D - Q_I;
        
        % U^{n+1}_i = U^n_i - lambda * [Diferencia_Flujo]
        U_nuevo(i) = U_viejo(i) - lambda * Diferencia_Flujo;
    end
end


% 5. ESQUEMA LAX-WENDROFF NO LINEAL 
function U_nuevo = paso_lax_wendroff(U_viejo, Delta_t, Delta_x)
    Nx = length(U_viejo);
    lambda = Delta_t / Delta_x;
    U_nuevo = zeros(1, Nx);
    
    % Condiciones de contorno: Dirichlet homogéneo (u=0 en bordes)
    U_ext = [0, U_viejo, 0];
    
    for i = 1:Nx
        U_i = U_ext(i+1);
        U_ip1 = U_ext(i+2);
        U_im1 = U_ext(i);
        
        % Flujos
        F_i = 0.5 * U_i^2;
        F_ip1 = 0.5 * U_ip1^2;
        F_im1 = 0.5 * U_im1^2;
        
        % Término de primer orden (centrado)
        term1 = -0.5 * lambda * (F_ip1 - F_im1);
        
        % Término de segundo orden (Lax-Wendroff)
        % Velocidad local en i+1/2
        a_ip12 = 0.5 * (U_i + U_ip1);
        % Velocidad local en i-1/2
        a_im12 = 0.5 * (U_im1 + U_i);
        
        term2 = 0.5 * lambda^2 * (a_ip12 * (F_ip1 - F_i) - a_im12 * (F_i - F_im1));
        
        U_nuevo(i) = U_i + term1 + term2;
    end
end


% 6. FUNCIÓN PARA EL CÁLCULO DE LA SOLUCIÓN EXACTA 
function U_exacta = calcular_solucion_exacta_puntfijo(L_min, L_max, Delta_x, T_final)
    
    coordenadas_x = (L_min + Delta_x/2) : Delta_x : (L_max - Delta_x/2);
    Nx = length(coordenadas_x);
    U_exacta = zeros(1, Nx); % Inicializar todo a cero
    
    TOL = 1.0e-8; 
    MAX_ITER = 100; 

    % Restricción de dominio: SOLO iterar para x en [-1, 1]
    i_inicio = find(coordenadas_x >= -1, 1, 'first');
    i_fin = find(coordenadas_x <= 1, 1, 'last');

    for i = i_inicio : i_fin
        xi = coordenadas_x(i);
        t = T_final;

        x_hat_viejo = xi; % Inicialización 
        
        for k = 1:MAX_ITER
            
            % DENOMINADOR: 1 + t*x_hat*(x_hat^2 - 2)
            denominador = 1 + t * x_hat_viejo * (x_hat_viejo^2 - 2);
            
            % Iteración de Punto Fijo: F(x_hat) = (x - t) / den
            if abs(denominador) < eps
                x_hat_nuevo = x_hat_viejo; 
            else
                x_hat_nuevo = (xi - t) / denominador; 
            end
            
            % Criterio de parada
            if abs(x_hat_nuevo - x_hat_viejo) < TOL
                break; 
            end
            
            x_hat_viejo = x_hat_nuevo; 
        end
        
        % La solución es u(x,t) = u0(x_hat).
        U_exacta(i) = u0_exacta(x_hat_viejo);
    end
    
end


% 7. FUNCIÓN PARA LA CONDICIÓN INICIAL EXACTA u0(x)
function u0 = u0_exacta(x_hat)
% Calcula la condición inicial: u(x,0) = max(0, 1 - x^2)^2
    termino = 1 - x_hat^2;
    if termino > 0
        u0 = termino^2;
    else
        u0 = 0; 
    end
end