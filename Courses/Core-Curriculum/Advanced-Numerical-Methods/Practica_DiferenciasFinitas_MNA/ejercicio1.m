% ------------------------------------------------------------
% SCRIPT: ejercicio1_df1d
% ------------------------------------------------------------
% Resuelve numéricamente el problema:
%        y'' - y = 0,  x ∈ (0,1)
% con condiciones de frontera:
%        y(0) = 1,  y(1) = e
%
% usando diferencias finitas con N nodos interiores.
%
% Se comparan:
%   - Solución numérica vs. solución exacta (e^x)
%   - Error absoluto en cada punto
%   - Orden de convergencia estimado mediante regresión log-log
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N = 100;  % Número de puntos interiores

% Condiciones de frontera
y_0 = 1;         % Condición de contorno en x=0
y_1 = exp(1);    % Condición de contorno en x=1

%% 2. SOLUCIÓN APROXIMADA MEDIANTE DIFERENCIAS FINITAS

sol_a = ejercicio1_df1d(N, y_0, y_1);


%% 3. SOLUCIÓN EXACTA EN LOS MISMOS NODOS
x = linspace(0, 1, N + 2)';
sol_e = exp(x);

%% 4. GRÁFICA: SOLUCIÓN EXACTA Y APROXIMADA
plot(x, sol_a, 'g-', 'LineWidth', 2);  % Solución aproximada en verde
hold on;
plot(x, sol_e, 'r--', 'LineWidth', 2); % Solución exacta en rojo (línea discontinua)
hold off;
legend('Aproximada', 'Exacta');
xlabel('x'); 
ylabel('y(x)');
title('Ejercicio1 df1d: Solución aproximada vs exacta');
grid on;



%% 5. GRÁFICA: ERROR ABSOLUTO
figure;
error_abs = abs(sol_e - sol_a);
plot(x, error_abs, 'k-', 'LineWidth', 1); % línea negra continua sin marcadores
xlabel('x');
ylabel('Error absoluto');
title('Error absoluto entre solución exacta y aproximada');
grid on;


%% 6. ESTUDIO DEL ORDEN DE CONVERGENCIA
vector_N = [50, 100, 150, 200, 250, 300]; 
vector_h = 1 ./ (vector_N + 1);
vector_e = zeros(size(vector_N));
for i = 1:length(vector_N)
    sol_a = ejercicio1_df1d(vector_N(i), y_0, y_1);
    x = linspace(0, 1, vector_N(i) + 2)';
    % Solución exacta
    sol_e = exp(x);
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
loglog(vector_h, vector_e, '-*b', 'LineWidth', 1.5, ...
       'MarkerSize', 8, 'MarkerFaceColor', 'b');
xlabel('Paso de malla h');
ylabel('Error máximo ||e||_\infty');
title(['Convergencia log-log, orden ≈ ', ... 
    num2str(orden_convergencia, '%.2f')]);
grid on;

