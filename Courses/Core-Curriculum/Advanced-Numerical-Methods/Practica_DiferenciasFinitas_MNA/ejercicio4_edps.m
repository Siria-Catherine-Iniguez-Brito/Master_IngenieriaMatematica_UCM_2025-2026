% ------------------------------------------------------------
% SCRIPT: ejercicio4_edps.m
% ------------------------------------------------------------
% Resuelve numéricamente la ecuación del calor:
%
%        u_t = u_xx,       (x,t) ∈ (0,1) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,   u(1,t) = 0,
%
% y condición inicial:
%        u(x,0) = f(x).
%
% mediante el método de lineas.
%
% Este script:
%   - Define los parámetros del problema y la condición inicial.
%   - Llama a la función ejercicio1_edp para obtener la solución numérica.
%   - Representa la evolución temporal de la temperatura u(x,t)
%     en una superficie 3D.
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
f = @(x) 7 .* sin(pi * x);   % condición inicial del ejercicio 4
N = 10;
T = 1;

%% 2. SOLUCIÓN APROXIMADA
[t_sol, U_sol] = ejercicio4_edp(N, T, f);

%% 3. PARÁMETROS DE LA MALLA
h = 1 / (N + 1);
vector_X = 0:h:1;                  % nodos espaciales (incluyendo bordes)


%% 4. CONSTRUCCIÓN DE LA MALLA
[X, Tm] = meshgrid(vector_X, t_sol);

%% 5. GRÁFICA
figure;
surf(X, Tm, U_sol, 'EdgeColor', 'none');
colormap jet;
colorbar;
xlabel('x');
ylabel('t');
zlabel('u(x,t)');
title('Solución numérica por el Método de Líneas (ode23s)');
view(45, 30);

%% 6.Solución aproximada en t = 1
% Buscar el índice del tiempo más cercano a t = 1
[~, idx] = min(abs(t_sol - 1));
u_T1 = U_sol(idx, :);

% --- Gráfica ---
figure;
plot(vector_X, u_T1, 'b', 'LineWidth', 2, 'MarkerSize', 14);
xlabel('x'); ylabel('u(x,1)');
title('Solución numérica aproximada en t = 1 (método de líneas)');
grid on;