% ------------------------------------------------------------
% SCRIPT: ejercicio5_edps.m
% ------------------------------------------------------------
% Resuelve numéricamente la ECUACIÓN DE ONDAS en una dimensión:
%
%        u_tt = u_xx,       (x,t) ∈ (0,2) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,   u(2,t) = 0,
%
% y condiciones iniciales:
%        u(x,0)  = sin(pi·x)
%        u_t(x,0) = pi·sin(pi·x)
%
% mediante el MÉTODO DE DIFERENCIAS FINITAS EXPLÍCITO.
%
% Este script:
%   - Define los parámetros del problema y la condición inicial.
%   - Llama a la función ejercicio5_edp para obtener la solución numérica.
%   - Representa la evolución temporal de la onda u(x,t)
%     en una superficie 3D.
%   - Calcula la solución exacta u(x,t) = [cos(pi·t) + sin(pi·t)]·sin(pi·x)
%     y estima el error máximo absoluto al tiempo final.
%
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
N = 100;        % número de nodos interiores
M = 400;        % número de pasos temporales
T = 2;          % tiempo final de simulación

% Condición inicial
f = @(x) sin(pi*x);   % u(x,0) = sin(pi x)

%% 2. SOLUCIÓN APROXIMADA MEDIANTE DIFERENCIAS FINITAS
matriz_U = ejercicio5_edp(N, M, T, f);

%% 3. PARÁMETROS DE LA MALLA
h  = 2 / (N + 1);          % paso espacial
dt = T / (M + 1);          % paso temporal
x  = 0:h:2;                % nodos espaciales incluyendo fronteras
t  = linspace(0, T, M+1);  % instantes de tiempo (coincide con filas de matriz_U)

%% 4. SOLUCIÓN EXACTA
% Expresión analítica: u(x,t) = [cos(pi t) + sin(pi t)] * sin(pi x)
[X, Tm] = meshgrid(x, t);
U_exact = (cos(pi * Tm) + sin(pi * Tm)) .* sin(pi * X);

%% 5. GRÁFICA SUPERFICIAL (u(x,t))
figure;
surf(x, t, matriz_U, 'EdgeColor', 'none');
colormap turbo; shading interp;
xlabel('x'); ylabel('t'); zlabel('u(x,t)');
title('Solución Numérica de la Ecuación de Ondas (Método Explícito)');
colorbar;
view(45, 40);

%% 6. COMPARACIÓN CON LA SOLUCIÓN EXACTA EN t = T
U_num_T = matriz_U(end, :);    % última fila (t = T)
U_ex_T  = U_exact(end, :);     % exacta en t = T

figure;
plot(x, U_ex_T, 'r-', 'LineWidth', 1.8); hold on;
plot(x, U_num_T, 'bo-', 'MarkerFaceColor', 'b', 'MarkerSize', 4);
legend('Solución exacta','Solución numérica','Location','best');
xlabel('x'); ylabel('u(x,T)');
title(sprintf('Comparación en t = %.2f', T));
grid on;

%% 7. CÁLCULO DEL ERROR MÁXIMO ABSOLUTO
error_max = max(max(abs(matriz_U - U_exact)));
fprintf('Error máximo absoluto = %.3e\n', error_max);

