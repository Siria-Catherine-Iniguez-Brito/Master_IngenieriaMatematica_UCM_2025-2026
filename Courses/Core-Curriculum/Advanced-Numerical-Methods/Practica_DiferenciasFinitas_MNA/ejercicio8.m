% ------------------------------------------------------------
% SCRIPT: ejercicio8_df.m
% ------------------------------------------------------------
% Resuelve numéricamente el problema de contorno mixto:
%
%        y'' - x y' - 2x^2 y = 2 e^{x^2},    x ∈ (0,1)
% con condiciones:
%        y(0) = 1,     (Dirichlet)
%        y'(1) = 2e,   (Neumann)
%
% mediante el método de diferencias finitas centradas
% de segundo orden (O(h^2)), implementado en la función
% ejercicio8_df1d.m.
%
% Se comparan:
%   - Solución numérica vs. solución exacta
%   - Error absoluto en cada punto
%   - Orden de convergencia estimado mediante regresión log-log
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N = 100;                       % Número de subintervalos
h = 1 / N;                     % Paso de malla
x = linspace(0, 1, N+1)';      % Nodos del dominio

y0 = 1;                        % Condición Dirichlet
yprima = 2 * exp(1);           % Condición Neumann (y'(1)=2e)

%% 2. SOLUCIÓN NUMÉRICA MEDIANTE DIFERENCIAS FINITAS
sol_a = ejercicio8_df1d(N, y0, yprima);

%% 3. SOLUCIÓN EXACTA
sol_e = exp(x.^2);

%% 4. GRÁFICA: SOLUCIÓN EXACTA Y APROXIMADA
figure;
plot(x, sol_a, 'r-', 'LineWidth', 2);        
hold on;
plot(x, sol_e, 'b--', 'LineWidth', 2);      
hold off;
legend('Solución aproximada', 'Solución exacta', 'Location', 'Best');
xlabel('x'); ylabel('y(x)');
title('Ejercicio 8 df1d: Solución exacta vs aproximada');
grid on;

%% 5. GRÁFICA: ERROR ABSOLUTO
error_abs = abs(sol_e - sol_a);
figure;
plot(x, error_abs, 'k-', 'LineWidth', 1.5);
xlabel('x'); ylabel('|Error|');
title('Ejercicio 8: Error absoluto entre solución exacta y aproximada');
grid on;

%% 6. CÁLCULO DEL ERROR MÁXIMO
error_max = max(error_abs);
fprintf('Error máximo con N=%d: %.3e\n', N, error_max);

%% 7. ESTUDIO DEL ORDEN DE CONVERGENCIA
vector_N = [20, 40, 80, 160, 320];
vector_h = 1 ./ vector_N;
vector_e = zeros(size(vector_N));

for i = 1:length(vector_N)
    N_i = vector_N(i);
    x_i = linspace(0, 1, N_i + 1)';
    
    y_aprox = ejercicio8_df1d(N_i, y0, yprima);
    y_exacta = exp(x_i.^2);
    
    vector_e(i) = max(abs(y_exacta - y_aprox));
end

%% 8. CÁLCULO DEL ORDEN DE CONVERGENCIA
log_h = log(vector_h);
log_e = log(vector_e);

p = polyfit(log_h, log_e, 1);
orden_convergencia = p(1);

fprintf('Orden de convergencia estimado: %.4f\n', orden_convergencia);

%% 9. GRÁFICA: CONVERGENCIA LOG–LOG
figure;
loglog(vector_h, vector_e, '-*', 'LineWidth', 1.5, ...
       'MarkerSize', 8, 'MarkerFaceColor', 'b');
xlabel('Paso de malla h');
ylabel('Error máximo ||e||_\infty');
title(['Ejercicio 8: Convergencia log-log (p \approx ', ...
        num2str(orden_convergencia, '%.2f'), ')']);
grid on;
grid on;
