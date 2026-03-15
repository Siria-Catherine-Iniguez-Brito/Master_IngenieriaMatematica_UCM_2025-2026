% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 4 Ejercicio 1
% -------------------------------------------------------------------------
% ECUACIÓN DE ADVECCIÓN 1D - Esquemas de 3 puntos (Primer Orden)
%
% Ecuación:      u_t + v * u_x = 0        en (x_min, x_max) x (0, t_f]
% Condiciones:   u(x_entrada, t) = 0 (Condición de contorno nula)
%                u(x,0) = U_0(x) (Condición Inicial)
%
% Se evalúan: mi_upwind, mi_downwind y mi_centrado.
% -------------------------------------------------------------------------

clear; close all; clc;

% =========================================================================
%% 1. DEFINICIÓN DE DATOS Y PARÁMETROS DE LA SIMULACIÓN
% =========================================================================
v = 1; 
v_neg = -1; 
t_final = 0.5; 
intervalo = [-2,2];
delta_X = 0.001; 
delta_T = 0.001; 
nu = v * delta_T / delta_X; % Número de Courant (nu = 1.0)
nu_neg =  v_neg * delta_T / delta_X;


% =========================================================================
%% 2. ESQUEMA UPWIND (Primer Orden, Estabilidad si |nu| <= 1)
% =========================================================================

% Con v = 1

[vector_U1, x_intervalos1] = mi_upwind(v, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos1);  

u_exacta = condicion_inicial_1(x_intervalos1 - v * t_final); 

figure;
plot(x_intervalos1, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos1, vector_U1(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Upwind $\nu=' num2str(nu) '$']); 
plot(x_intervalos1, u_exacta, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Solución Exacta'); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Upwind (1er Orden) con $\nu=' num2str(nu) '$ en $t=' num2str(t_final) '$'], 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'northwest');
grid on;
xlim(intervalo);
ylim([-0.05, 1.05]); 

% Con v_neg = -1 

[vector_U11, x_intervalos11] = mi_upwind(v_neg, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos11);  

u_exacta = condicion_inicial_1(x_intervalos11 - v_neg * t_final); 

figure;
plot(x_intervalos11, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos11, vector_U11(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Upwind $\nu=' num2str(nu_neg) '$']); 
plot(x_intervalos11, u_exacta, 'k:', 'LineWidth', 1.5, 'DisplayName', 'Solución Exacta'); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Upwind (1er Orden) con $\nu=' num2str(nu_neg) '$ en $t=' num2str(t_final) '$'], 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'northwest');
grid on;
xlim(intervalo);
ylim([-0.05, 1.05]); 


% =========================================================================
%% 3. ESQUEMA DOWNWIND 
% =========================================================================

% Con v = 1

[vector_U2, x_intervalos2] = mi_downwind(v, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos2); 

figure;
plot(x_intervalos2, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos2, vector_U2(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Downwind $v=' num2str(v) '$']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Downwind con $\nu=' num2str(nu) '$ en $t=' num2str(t_final) '$ (Inestable)'], 'Interpreter', 'latex')
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);

% Con v_neg = -1 

[vector_U22, x_intervalos22] = mi_downwind(v_neg, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos22); 

figure;
plot(x_intervalos22, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos22, vector_U22(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Downwind $v=' num2str(v_neg) '$']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Downwind con $\nu=' num2str(nu_neg) '$ en $t=' num2str(t_final) '$ (Inestable)'], 'Interpreter', 'latex')
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);


% =========================================================================
%% 4. ESQUEMA CENTRADO 
% =========================================================================

% Con v = 1

[vector_U3, x_intervalos3] = mi_centrado(v, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos3);  

figure;
plot(x_intervalos3, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos3, vector_U3(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Centrado $v=' num2str(v) '$']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Centrado con $\nu=' num2str(nu) '$ en $t=' num2str(t_final) '$ (Inestable)'], 'Interpreter', 'latex')
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);

% Con v_neg = -1 

[vector_U33, x_intervalos33] = mi_centrado(v_neg, t_final, intervalo, delta_T, delta_X, @condicion_inicial_1); 

u_0 = condicion_inicial_1(x_intervalos33);  

figure;
plot(x_intervalos33, u_0, 'b-', 'LineWidth', 2, 'DisplayName', '$u_0$ (Inicial)'); hold on;
plot(x_intervalos33, vector_U33(end, :), 'r-', 'LineWidth', 2, 'DisplayName', ['Centrado $v=' num2str(v_neg) '$']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Centrado con $\nu=' num2str(nu_neg) '$ en $t=' num2str(t_final) '$ (Inestable)'], 'Interpreter', 'latex')
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);


% =========================================================================
%% 5. FUNCION CONDICION INICIAL 
% =========================================================================

function y = condicion_inicial_1(x)

% CONDICION_INICIAL_1 Implementa la función de condición inicial para el Ejercicio 1.
%   u0(x) = ((1 - x^2)_+)^2, 
%
% ENTRADAS:
%   x : Vector de puntos espaciales.
%
% SALIDAS:
%   y : Vector con los valores de la condición inicial en cada punto x.

y = zeros(size(x));

for i = 1 : length(x)
    % La función es no nula solo si |x| <= 1, es decir, (1 - x^2) >= 0.
    if abs(x(i)) <= 1
        % u0(x) = (1 - x^2)^2
        y(i) = (1 - x(i)^2)^2; 
    else 
        % u0(x) = 0
        y(i) = 0; 
    end
end 

end
