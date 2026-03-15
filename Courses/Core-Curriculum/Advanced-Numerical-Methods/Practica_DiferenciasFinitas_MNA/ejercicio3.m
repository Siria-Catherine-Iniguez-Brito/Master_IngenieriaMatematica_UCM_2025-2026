% ------------------------------------------------------------
% SCRIPT: ejercicio3_df1d.m
% ------------------------------------------------------------
% Resuelve numéricamente el problema:
%
%        y'' - x y' - 2x^2 y = 2 e^{x^2},    x ∈ (0,1)
% con condiciones de contorno:
%        y(0) = 1,    y(1) = e
%
% mediante el método de diferencias finitas centradas.
%
% Se comparan:
%   - Solución numérica vs. solución exacta
%   - Error absoluto en cada punto 
%   - Orden de convergencia estimado mediante regresión log-log
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N = 100;        % Número de puntos interiores
y_0 = 1;         % Condición en x = 0
y_1 = exp(1);    % Condición en x = 1

%% 2. SOLUCIÓN APROXIMADA MEDIANTE DIFERENCIAS FINITAS
sol_a = ejercicio3_df1d(N, y_0, y_1);

%% 3. SOLUCIÓN EXACTA EN LOS MISMOS NODOS
x = linspace(0, 1, N + 2)';
sol_e = exp(x.^2);

%% 4. GRÁFICA: SOLUCIÓN EXACTA Y APROXIMADA
figure;
plot(x, sol_e, 'r-', 'LineWidth', 2);   
hold on;
plot(x, sol_a, 'g--', 'LineWidth', 2);   
hold off;
legend('Solución exacta', 'Solución aproximada', 'Location', 'Best');
xlabel('x'); ylabel('y(x)');
title('Ejercicio 3 df1d: Solución aproximada vs exacta');
grid on;

%% 5. GRÁFICA: ERROR ABSOLUTO
figure;
error_abs = abs(sol_e - sol_a);
plot(x, error_abs, 'k-', 'LineWidth', 1.5);
xlabel('x');
ylabel('Error absoluto');
title('Error absoluto entre solución exacta y aproximada');
grid on;


%% 6. ESTUDIO DEL ORDEN DE CONVERGENCIA
vector_N = [50, 100, 150, 200, 250, 300]; 
vector_h = 1 ./ (vector_N + 1);
vector_e = zeros(size(vector_N));
for i = 1:length(vector_N)
    sol_a = ejercicio3_df1d(vector_N(i), y_0, y_1);
    x = linspace(0, 1, vector_N(i) + 2)';
    % Solución exacta
    sol_e = exp(x.^2);
    vector_e(i) = max(abs(sol_e - sol_a)); 
end   


%% 7. CÁLCULO DEL ORDEN DE CONVERGENCIA
log_h = log(vector_h);
log_e = log(vector_e);

p = polyfit(log_h, log_e, 1);
orden_convergencia = p(1);
fprintf('El orden de convergencia estimado es: %.4f\n', orden_convergencia);

%% 8. GRÁFICA: CONVERGENCIA LOG–LOG
figure;
loglog(vector_h, vector_e, '-*', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'b')
xlabel('Paso de malla h');
ylabel('Error máximo ||e||_\infty');
title(['Convergencia log-log, orden ≈ ', ... 
    num2str(orden_convergencia, '%.2f')]);

