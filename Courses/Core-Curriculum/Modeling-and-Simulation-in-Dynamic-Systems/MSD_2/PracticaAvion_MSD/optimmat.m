clear; clc; close all;
rng(1);

%-----------------------------
% Parámetros del GA
%-----------------------------
Npop = 80;     % tamaño de la población
Ngen = 100;    % número máximo de generaciones

Niter = 50;   % número máximo de iteraciones del método local fminunc 


nvars = 2;     % dos variables

lb = [-6, -6];
ub = [ 6,  6];

%-----------------------------
% Función objetivo
%-----------------------------
fun = @(v) v(1)^2 + v(2)^2 + 10*sin(v(1))*sin(v(2));

% Gradiente de la función
gradfun = @(v) [2*v(1) + 10*cos(v(1))*sin(v(2));
                2*v(2) + 10*sin(v(1))*cos(v(2))];

% Función para fminunc con valor y gradiente
fun_grad = @(v) deal(fun(v), gradfun(v));

%-----------------------------
% Algoritmo genético
%-----------------------------
options_ga = optimoptions('ga', ...
    'PopulationSize', Npop, ...
    'MaxGenerations', Ngen, ...
    'Display', 'iter', ...
    'PlotFcn', {@gaplotbestf, @gaplotscores, @gaplotstopping});

[xopt_ga, fopt_ga, exitflag_ga, output_ga, population, scores] = ...
    ga(fun, nvars, [], [], [], [], lb, ub, [], options_ga);

%-----------------------------
% Método local de gradiente
%-----------------------------
options_fminunc = optimoptions('fminunc', ...
    'Algorithm', 'quasi-newton', ...
    'SpecifyObjectiveGradient', true, ...
    'MaxIterations', Niter, ...
    'Display', 'iter');

% Dos puntos iniciales distintos
x0_1 = [ -2,  4];
x0_2 = [ 4, 2];

% Resolución desde el primer punto inicial
[xopt_loc1, fopt_loc1, exitflag_loc1, output_loc1] = ...
    fminunc(fun_grad, x0_1, options_fminunc);

% Resolución desde el segundo punto inicial
[xopt_loc2, fopt_loc2, exitflag_loc2, output_loc2] = ...
    fminunc(fun_grad, x0_2, options_fminunc);

%-----------------------------
% Mostrar resultados
%-----------------------------
fprintf('\n==============================\n');
fprintf('RESULTADOS DEL ALGORITMO GENÉTICO\n');
fprintf('==============================\n');
fprintf('x = %.6f\n', xopt_ga(1));
fprintf('y = %.6f\n', xopt_ga(2));
fprintf('f(x,y) = %.6f\n', fopt_ga);
fprintf('Generaciones realizadas: %d\n', output_ga.generations);
fprintf('Tamaño de población: %d\n', options_ga.PopulationSize);

fprintf('\n==============================\n');
fprintf('RESULTADOS DEL MÉTODO LOCAL DESDE x0_1\n');
fprintf('==============================\n');
fprintf('Punto inicial = (%.6f, %.6f)\n', x0_1(1), x0_1(2));
fprintf('x = %.6f\n', xopt_loc1(1));
fprintf('y = %.6f\n', xopt_loc1(2));
fprintf('f(x,y) = %.6f\n', fopt_loc1);
fprintf('Iteraciones: %d\n', output_loc1.iterations);

fprintf('\n==============================\n');
fprintf('RESULTADOS DEL MÉTODO LOCAL DESDE x0_2\n');
fprintf('==============================\n');
fprintf('Punto inicial = (%.6f, %.6f)\n', x0_2(1), x0_2(2));
fprintf('x = %.6f\n', xopt_loc2(1));
fprintf('y = %.6f\n', xopt_loc2(2));
fprintf('f(x,y) = %.6f\n', fopt_loc2);
fprintf('Iteraciones: %d\n', output_loc2.iterations);

%-----------------------------
% Mallado para visualización
%-----------------------------
[xg, yg] = meshgrid(linspace(lb(1), ub(1), 200), linspace(lb(2), ub(2), 200));
zg = xg.^2 + yg.^2 + 10*sin(xg).*sin(yg);

%-----------------------------
% Figura 1: superficie
%-----------------------------
figure;
surf(xg, yg, zg, 'EdgeColor', 'none');
hold on;

h_ga   = plot3(xopt_ga(1),   xopt_ga(2),   fopt_ga,   'ro', 'MarkerSize', 10, 'LineWidth', 2);
h_loc1 = plot3(xopt_loc1(1), xopt_loc1(2), fopt_loc1, 'ms', 'MarkerSize', 10, 'LineWidth', 2);
h_loc2 = plot3(xopt_loc2(1), xopt_loc2(2), fopt_loc2, 'ks', 'MarkerSize', 10, 'LineWidth', 2);

xlabel('x');
ylabel('y');
zlabel('f(x,y)');
title('Función objetivo y soluciones encontradas');
colorbar;
view(45, 35);

legend([h_ga, h_loc1, h_loc2], ...
       {'GA', 'Local desde x0\_1', 'Local desde x0\_2'}, ...
       'Location', 'best');

%-----------------------------
% Figura 2: curvas de nivel
%-----------------------------
figure;
contourf(xg, yg, zg, 40, 'LineColor', [0.3 0.3 0.3]);
hold on;

h_ga   = plot(xopt_ga(1),   xopt_ga(2),   'ro', 'MarkerSize', 10, 'LineWidth', 2);
h_loc1 = plot(xopt_loc1(1), xopt_loc1(2), 'ms', 'MarkerSize', 10, 'LineWidth', 2);
h_loc2 = plot(xopt_loc2(1), xopt_loc2(2), 'ks', 'MarkerSize', 10, 'LineWidth', 2);

h_x01  = plot(x0_1(1), x0_1(2), 'm+', 'MarkerSize', 12, 'LineWidth', 2);
h_x02  = plot(x0_2(1), x0_2(2), 'k+', 'MarkerSize', 12, 'LineWidth', 2);

xlabel('x');
ylabel('y');
title('Curvas de nivel y mínimos encontrados');
colorbar;
axis equal;

legend([h_ga, h_loc1, h_loc2, h_x01, h_x02], ...
       {'GA', 'Local desde x0_1', 'Local desde x0_2', ...
        'Punto inicial x0_1', 'Punto inicial x0_2'}, ...
       'Location', 'best');