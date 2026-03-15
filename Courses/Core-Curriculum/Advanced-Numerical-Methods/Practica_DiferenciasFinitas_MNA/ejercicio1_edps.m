% ------------------------------------------------------------
% SCRIPT: ejercicio1_edps.m
% ------------------------------------------------------------
% Resuelve numéricamente la ecuación del calor 1D:
%
%        u_t = u_xx,       (x,t) ∈ (0,1) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,    u(1,t) = 0,
%
% y condición inicial:
%        u(x,0) = f(x) = 4x - 4x^2.
%
% mediante el método de diferencias finitas explícito
% (esquema de Euler hacia adelante en el tiempo y
% diferencias centradas en el espacio).
%
% Este script:
%   - Define los parámetros del problema y la condición inicial.
%   - Llama a la función ejercicio1_edp para obtener la solución numérica.
%   - Representa la evolución temporal de la temperatura u(x,t)
%     en una superficie 3D.
% ------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
f = @(x) 4.*x - 4.*x.^2;  % u(x,0) = 4x - 4x^2
N = 10;                            % Número de nodos interiores (en x)
M = ceil(2*(N+1)^2 - 1);           % Número de pasos temporales (condición de estabilidad CFL)
T = 1;                             % Tiempo final de simulación

%% 2. SOLUCIÓN APROXIMADA
matriz_U = ejercicio1_edp(N, M, T, f);  % Llamada a la función principal

%% 3. PARÁMETROS DE LA MALLA
h  = 1 / (N + 1);                  % Paso espacial
dt = T / (M + 1);                  % Paso temporal
vector_X = 0:h:1;                  % Nodos espaciales
t = linspace(0, T, M + 2);         % Tiempos de simulación

%% 4. CONSTRUCCIÓN DE LA MALLA
[X, Tm] = meshgrid(vector_X, t);   % Mallas espaciales y temporales

%% 5. GRÁFICA
figure;
surf(X, Tm, matriz_U, 'EdgeColor', 'none');  % Superficie suave
colormap jet;                                % Escala de color tipo "jet"
xlabel('x'); ylabel('t'); zlabel('u(x,t)');
title('Ecuación del calor 1D: Solución numérica u(x,t)');
grid on;
view(45,30); 

%% 6. GRAFICAR u(x,1)

% La solución en t=1 está en la fila M+1
u_final = matriz_U(M+1, :);

figure;
plot(vector_X, u_final, 'b', 'LineWidth', 1.8, 'MarkerSize', 18);
xlabel('x'); ylabel('u(x,1)');
title('Solución numérica aproximada en t = 1');
grid on;




