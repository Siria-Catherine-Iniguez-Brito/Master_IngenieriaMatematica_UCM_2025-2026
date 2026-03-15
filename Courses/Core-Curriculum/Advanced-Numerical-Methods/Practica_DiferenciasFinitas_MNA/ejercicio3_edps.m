% ------------------------------------------------------------
% SCRIPT: ejercicio3_edps
% ------------------------------------------------------------
% Resuelve numéricamente el problema: ecuación del calor
% (MÉTODO IMPLÍCITO CRANK–NICHOLSON)
%
% Problema:
%   u_t = u_xx ,    x ∈ (0,1),  t ∈ (0,T)
%   u(0,t) = 0 ,    u(1,t) = 0
%   u(x,0) = 4x - 4x^2
%
% Este script:
%   - Define los parámetros del problema y la condición inicial.
%   - Llama a la función ejercicio3_edp para obtener la solución numérica.
%   - Representa la evolución temporal de la temperatura u(x,t)
%     en una superficie 3D.
%-------------------------------------------------------------

clear; clc; close all;

%% 1. PARÁMETROS DEL PROBLEMA
f = @(x) 4.*x - 4.*x.^2;   % Condición inicial u(x,0)

N = 10;    % Número de nodos interiores en el espacio
M = 200;   % Número de pasos de tiempo
T = 1;     % Tiempo final

%% 2. SOLUCIÓN APROXIMADA
% Llamamos a la función que implementa el método de Crank–Nicolson
matriz_U = ejercicio3_edp(N, M, T, f);

%% 3. PARÁMETROS DE LA MALLA-
h  = 1 / (N + 1);      % Paso espacial
dt = T / (M + 1);      % Paso temporal

% Vector con los nodos espaciales (incluyendo los extremos)
vector_X = 0:h:1;

% Vector con los tiempos (desde 0 hasta T)
t = linspace(0, T, M + 2);

%% 4. CONSTRUCCIÓN DE LA MALLA
% Generamos las matrices X y Tm necesarias para la función surf()
% X contiene las posiciones espaciales y Tm los instantes de tiempo
[X, Tm] = meshgrid(vector_X, t);

%% 5. GRÁFICA
figure;
surf(X, Tm, matriz_U, 'EdgeColor', 'none');  % Superficie suave
colormap jet;                                
xlabel('x');                                 % Eje espacial
ylabel('t');                                 % Eje temporal
zlabel('U(x,t)');                            % Eje de la solución
title('Solución Numérica u(x,t)');           % Título de la gráfica

%% 6. GRAFICAR u(x,1)

% La solución en t=1 está en la fila M+1
u_final = matriz_U(M+1, :);

figure;
plot(vector_X, u_final, 'b', 'LineWidth', 1.8, 'MarkerSize', 18);
xlabel('x'); ylabel('u(x,1)');
title('Solución numérica aproximada en t = 1');
grid on;
