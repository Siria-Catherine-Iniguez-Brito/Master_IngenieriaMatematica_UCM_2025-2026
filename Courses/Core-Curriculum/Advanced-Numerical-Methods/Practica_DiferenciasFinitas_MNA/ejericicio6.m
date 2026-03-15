% ------------------------------------------------------------
% SCRIPT: ejercicio6_df.m
% ------------------------------------------------------------
% Resuelve numéricamente el problema de contorno mixto:
%
%        y'' - y' - 2y = -4x,   x ∈ (0,1)
% con condiciones de contorno:
%        y'(0) = 4,    y(1) = 1 + e^2
%
% mediante el método de diferencias finitas centradas,
% usando una aproximación de segundo orden para la condición
% de Neumann en x = 0 y de tipo Dirichlet en x = 1.

% Se comparan:
%   - Solución numérica vs. solución exacta
%   - Error absoluto en cada punto 
%   - Orden de convergencia estimado mediante regresión log-log
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N = 100;                        % Número de subintervalos (N+1 nodos)
h = 1 / N;                      % Paso de malla
x = linspace(0, 1, N+1)';       % Puntos del dominio
yN = 1 + exp(2);                % Condición Dirichlet en x = 1

%% 2. SOLUCIÓN APROXIMADA MEDIANTE DIFERENCIAS FINITAS
sol_a = ejercicio6_df1d(N,yN);     % Llamada a la función principal

%% 3. SOLUCIÓN EXACTA EN LOS MISMOS NODOS
sol_e = 2*x - 1 + exp(2*x);

%% 4. GRÁFICA: SOLUCIÓN EXACTA Y APROXIMADA
figure;
plot(x, sol_a, 'r-', 'LineWidth', 2);        
hold on;
plot(x, sol_e, 'b--', 'LineWidth', 2);      
hold off;
legend('Solución aproximada', 'Solución exacta', 'Location', 'Best');
xlabel('x'); ylabel('y(x)');
title('Ejercicio 6 df1d: Solución aproximada vs exacta');
grid on;

%% 5. GRÁFICA: ERROR ABSOLUTO
%error_abs = abs(sol_e - sol_a);

%figure;
%plot(x, error_abs, 'k-', 'LineWidth', 1.5);
%xlabel('x');
%ylabel('|Error|');
%title('Ejercicio 6 df1d: Error absoluto entre solución exacta y aproximada');
%grid on;

%% 6. ESTUDIO DEL ORDEN DE CONVERGENCIA
vector_N = [20, 40, 80, 160, 320];
vector_h = 1 ./ vector_N;
vector_e = zeros(size(vector_N));

for i = 1:length(vector_N)
    % Solución numérica
    y_aprox = ejercicio6_df1d(vector_N(i),yN);
    x_i = linspace(0, 1, vector_N(i) + 1)';
    % Solución exacta
    y_exacta = 2*x_i - 1 + exp(2*x_i);
    % Error máximo
    vector_e(i) = max(abs(y_exacta - y_aprox));
end

%% 7. CÁLCULO DEL ORDEN DE CONVERGENCIA
log_h = log(vector_h);
log_e = log(vector_e);

p = polyfit(log_h, log_e, 1);
orden_convergencia = p(1);
fprintf('Orden de convergencia estimado: %.4f\n', orden_convergencia);

%% 8. GRÁFICA: CONVERGENCIA LOG–LOG
figure;
loglog(vector_h, vector_e, '-*', 'LineWidth', 1.5, ...
       'MarkerSize', 8, 'MarkerFaceColor', 'b');
xlabel('Paso de malla h');
ylabel('Error máximo ||e||_\infty');
title(['Ejercicio 6: Convergencia log-log (p \approx ', ...
        num2str(orden_convergencia, '%.2f'), ')']);
grid on;
