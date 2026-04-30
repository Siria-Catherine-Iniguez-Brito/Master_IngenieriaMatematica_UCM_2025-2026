ub = [10,  90]; 
lb =[1, -90];
Npop = 4;     % tamaño de la población
Ngen = 3;    % número máximo de generaciones
Niter = 50;   % número máximo de iteraciones del método local fminunc 
nvars = length(ub);     % dos variables

%-----------------------------
% Algoritmo genético
%-----------------------------
options_ga = optimoptions('ga', ...
    'PopulationSize', Npop, ...
    'MaxGenerations', Ngen, ...
    'Display', 'iter', ...
    'PlotFcn', {@gaplotbestf, @gaplotscores, @gaplotstopping});

[xopt_ga, fopt_ga, exitflag_ga, output_ga, population, scores] = ...
    ga(@(x) wing(x,0), nvars, [], [], [], [], lb, ub, [], options_ga);
disp(['El diseño optimo es: ' num2str(xopt_ga)])
disp(['La portanza es: ' num2str(fopt_ga)])
wing(xopt_ga,1)
saveas(gcf,'Disenooptim-GA','jpg')