% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 4 Ejercicio 2
% -------------------------------------------------------------------------
%
% Ecuación:      u_t + v * u_x = 0        en (x_min, x_max) x (0, t_f]
% Condiciones:   u(x_entrada, t) = 0 (Condición de contorno nula)
%                u(x,0) = U_0(x) (Condición Inicial)
%
% Se evalúan: Upwind de 3 puntos y Lax-Wendroff.
% -------------------------------------------------------------------------

clear; close all; clc;

% =========================================================================
%% 1. DEFINICIÓN DE DATOS Y PARÁMETROS DE LA SIMULACIÓN
% =========================================================================
v = 1; 
t_final = 0.5;
intervalo = [-2, 2];
%delta_X = 0.00025;  % Paso espacial
delta_X = 0.001;
condicion_inicial_fn = @condicion_inicial_2; % La función u_0(x)


% =========================================================================
%% 2. CASO: NÚMERO DE COURANT nu = 0.2 (CÁLCULO DE SOLUCIONES Y ERRORES)
% =========================================================================

delta_T_nu02 = 0.2 * delta_X / v; % delta_T para nu = 0.2
nu_02 = v * delta_T_nu02 / delta_X; 

% --- Upwind (nu = 0.2) ---

[vector_U_Upwind_nu02, x_intervalos] = mi_upwind_3(v, t_final, intervalo, delta_T_nu02, delta_X, condicion_inicial_fn); 

u_exacta_nu02 = condicion_inicial_fn(x_intervalos - v * t_final);

error_Linf_Upwind_nu02 = max(abs(vector_U_Upwind_nu02(end, :) - u_exacta_nu02));
fprintf('Error L_inf (Upwind, nu=0.2):     %.4e\n', error_Linf_Upwind_nu02);


% --- Lax-Wendroff (nu = 0.2) ---

[vector_U_LW_nu02, ~] = mi_laxWendroff_3(v, t_final, intervalo, delta_T_nu02, delta_X, condicion_inicial_fn); 

error_Linf_LW_nu02 = max(abs(vector_U_LW_nu02(end, :) - u_exacta_nu02));
fprintf('Error L_inf (Lax-Wendroff, nu=0.2): %.4e\n', error_Linf_LW_nu02);


% --------------------- GRÁFICA Upwind (nu = 0.2) -------------------------

figure;
plot(x_intervalos, u_exacta_nu02, 'r-', 'LineWidth', 2, 'DisplayName', 'Solución Exacta'); hold on;
plot(x_intervalos, vector_U_Upwind_nu02(end, :), 'b-', 'LineWidth', 2, 'DisplayName', ['Upwind ($\nu=' num2str(nu_02) '$, $L_{\infty}=' num2str(error_Linf_Upwind_nu02, '%.2e') '$)']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Upwind con $\nu=' num2str(nu_02) '$ en $t=' num2str(t_final) '$'], 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);
ylim([-0.05, 1.05]);


% ----------------- GRÁFICA Lax-Wendroff (nu = 0.2) -----------------------

figure;
plot(x_intervalos, u_exacta_nu02, 'r-', 'LineWidth', 2, 'DisplayName', 'Solución Exacta'); hold on;
plot(x_intervalos, vector_U_LW_nu02(end, :), 'b-', 'LineWidth', 1.5, 'DisplayName', ['Lax-Wendroff ($\nu=' num2str(nu_02) '$, $L_{\infty}=' num2str(error_Linf_LW_nu02, '%.2e') '$)']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title(['Esquema Lax-Wendroff con $\nu=' num2str(nu_02) '$ en $t=' num2str(t_final) '$'], 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);
ylim([-0.05, 1.05]);


% =========================================================================
%% 3. CASO: NÚMERO DE COURANT nu = 1.0 
% =========================================================================

delta_T_nu10 = 1.0 * delta_X / v; % delta_T para nu = 1.0
nu_10 = v * delta_T_nu10 / delta_X; % Confirmación: nu = 1.0

% --- Upwind (nu = 1.0) ---

[vector_U_Upwind_nu10, x_intervalos] = mi_upwind_3(v, t_final, intervalo, delta_T_nu10, delta_X, condicion_inicial_fn); 

u_exacta_nu10 = condicion_inicial_fn(x_intervalos - v * t_final);

error_Linf_Upwind_nu10 = max(abs(vector_U_Upwind_nu10(end, :) - u_exacta_nu10));
fprintf('Error L_inf (Upwind, nu=1.0):     %.4e\n', error_Linf_Upwind_nu10);


% --- Lax-Wendroff (nu = 1.0) ---

[vector_U_LW_nu10, ~] = mi_laxWendroff_3(v, t_final, intervalo, delta_T_nu10, delta_X, condicion_inicial_fn); 

error_Linf_LW_nu10 = max(abs(vector_U_LW_nu10(end, :) - u_exacta_nu10));
fprintf('Error L_inf (Lax-Wendroff, nu=1.0): %.4e\n', error_Linf_LW_nu10);


% ----------------- GRÁFICA: COMPARATIVA (nu = 1.0) ---------------------
figure;
plot(x_intervalos, u_exacta_nu10, 'k-', 'LineWidth', 3, 'DisplayName', 'Solución Exacta'); hold on;
plot(x_intervalos, vector_U_Upwind_nu10(end, :), 'b--', 'LineWidth', 2, 'DisplayName', ['Upwind ($\nu=1.0$, $L_{\infty}=' num2str(error_Linf_Upwind_nu10, '%.2e') '$)']); 
plot(x_intervalos, vector_U_LW_nu10(end, :), 'r-', 'LineWidth', 1.5, 'DisplayName', ['Lax-Wendroff ($\nu=1.0$, $L_{\infty}=' num2str(error_Linf_LW_nu10, '%.2e') '$)']); 
hold off;
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$u$', 'Interpreter', 'latex');
title([' Comparacion upwind vs laxwendroff con $\nu=' num2str(nu_10) '$ en $t=' num2str(t_final) '$'], 'Interpreter', 'latex');
legend('show', 'Interpreter', 'latex', 'Location', 'northeast');
grid on;
xlim(intervalo);
ylim([-0.05, 1.05]);


% =========================================================================
%% 4. FUNCION CONDICION INICIAL 
% =========================================================================

function y = condicion_inicial_2(x)
% 1. Inicializa el vector de salida 'y' con ceros 
y = zeros(size(x)); 
    
% 2. Usa indexación lógica para encontrar dónde la condición es verdadera (|x| <= 1)
idx = abs(x) <= 1;
    
% 3. Asigna el valor 1 solo a esos índices
y(idx) = 1; 
end
