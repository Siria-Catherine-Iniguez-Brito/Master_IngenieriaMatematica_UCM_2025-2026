% ------------------------------------------------------------
% SCRIPT: ejercicio2_df1d
% ------------------------------------------------------------
% Resuelve numéricamente el problema:
%        y'' - y' - 2y = -4x,   x ∈ (0,2)
% con condiciones de contorno:
%        y(0) = 0,   y(2) = 3 + exp(4)
%
% utilizando el método de diferencias finitas centradas
% con N puntos interiores y discretización uniforme.
%
% Se comparan:
%   - Solución numérica vs. solución exacta
%   - Error absoluto en cada punto 
%   - Orden de convergencia estimado mediante regresión log-log
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N  = 100;                % Número de puntos interiores
y_0 = 0;                  % Condición de contorno en x = 0
y_2 = 3 + exp(4);         % Condición de contorno en x = 2

%% 2. SOLUCIÓN APROXIMADA MEDIANTE DIFERENCIAS FINITAS
sol_a = ejercicio2_df1d(N, y_0, y_2);

%% 3. SOLUCIÓN EXACTA EN LOS MISMOS NODOS
x = linspace(0, 2, N + 2)';   % Vector de nodos (0, h, ..., 2)
sol_e = 2*x - 1 + exp(2*x);   % Solución analítica exacta


%% 4. GRÁFICA: SOLUCIÓN EXACTA Y APROXIMADA
figure;
plot(x, sol_e, 'r-', 'LineWidth', 2);   % Exacta en rojo
hold on;
plot(x, sol_a, 'g--', 'LineWidth', 2);   % Aproximada en verde
hold off;
legend('Solución exacta', 'Solución aproximada', 'Location', 'Best');
xlabel('x');
ylabel('y(x)');
title('Ejercicio 2 df1d: Solución aproximada vs exacta');
grid on;

%% 5. GRÁFICA: ERROR ABSOLUTO
error_abs = abs(sol_e - sol_a);
figure;
plot(x, error_abs, 'k-', 'LineWidth', 1.5); % línea negra
xlabel('x');
ylabel('Error absoluto');
title('Error absoluto entre solución exacta y aproximada');
grid on;

%% 6. ESTUDIO DEL ORDEN DE CONVERGENCIA
vector_N = [10, 20, 40, 80, 160, 320]; 
vector_h = 2 ./ (vector_N + 1);
vector_e = zeros(size(vector_N));
for i = 1:length(vector_N)
    sol_a = ejercicio2_df1d(vector_N(i), y_0, y_2);
    x = linspace(0, 2, vector_N(i) + 2)'; 
    % Solución exacta
    sol_e = 2*x - 1 + exp(2*x);
    vector_e(i) = max(abs(sol_a - sol_e)); 
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



%orden_local = zeros(1, length(vector_e)-1);
%for i = 1:length(orden_local)
%    orden_local(i) = log(vector_e(i) / vector_e(i+1)) / log(vector_h(i) / vector_h(i+1));
%end

% Mostrar resultados
%fprintf('\nOrden de convergencia local entre pares de puntos:\n');
%disp(orden_local);
