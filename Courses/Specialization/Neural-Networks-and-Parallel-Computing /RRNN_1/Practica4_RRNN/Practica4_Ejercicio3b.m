% =========================================================================
% PRÁCTICA 4: EJERCICIO 3.a
% =========================================================================

rng(12345);
options = optimset('Display', 'iter');
startTime = tic;
ga(@fun2, 4, [], [], [], [], [], [], @cons2, [], options);
time_ga_sequential = toc(startTime);

% GA Paralelo
try
    pjob = gcp;
catch
    pjob = parpool; 
end

npmax = pjob.NumWorkers;
rng(12345);
options = optimset( options, 'UseParallel', 'always');
startTime = tic;
ga(@fun2, 4, [], [], [], [], [], [], @cons2, [], options);
time_ga_parallel = toc(startTime);

speedup = time_ga_sequential / time_ga_parallel;

fprintf('Resultados Ejercicio 3.b:\n');
fprintf('Tiempo Secuencial: %.4f s\n', time_ga_sequential);
fprintf('Tiempo Paralelo:   %.4f s\n', time_ga_parallel);
fprintf('Speedup obtenido:  %.4f\n', speedup);