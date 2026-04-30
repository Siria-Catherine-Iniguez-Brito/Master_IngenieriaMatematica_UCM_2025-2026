clear all 
close all 
clc 
warning off 
startTime = tic; 
for i =1:10
    fun2(rand(1,4)); 
end 
stopTime = toc(startTime) ;
averageTimef = stopTime/10; 

startTime = tic; 
for i =1:10
    cons2(rand(1,4)); 
end 
stopTime = toc(startTime) ;
averageTimer = stopTime/10; 

%% FUNCION SECUENCIAL 
startPoint = [1 -2 0 5]; 
options = optimset('Display', 'iter', 'Algorithm', 'active-set'); 
startTime = tic; 
fmincon(@fun2, startPoint, [],[],[], [], [],[], @cons2, options); 
time_fmincon_sequential = toc(startTime); 

%% FUNCION PARALELO
try 
    gcp  
end 

pjob = gcp; 
npmax = pjob.NumWorkers; 

options =  optimset(options, 'UseParallel', 'always'); 

startTime = tic; 
fmincon(@fun2, startPoint, [],[],[], [], [],[], @cons2, options); 
time_fmincon_parallel = toc(startTime); 

disp(' ')
disp('Resumen de los resultados')
disp(' ')
disp(' ')
disp(['La funcion objetivo tarda en promedio ' num2str(averageTimef) '(s) en 10 evaluaciones'])
disp(' ')
disp(['La funcion restriccion tarda en promedio ' num2str(averageTimer) '(s) en 10 evaluaciones'])

disp(['Fmincon en secuencial tarda ' num2str(time_fmincon_sequential) ' (s)' ])
disp(['Fmincon en paralelo tarda ' num2str(time_fmincon_parallel) ' (s)' ])
disp(['El speedup es de  ' num2str(time_fmincon_sequential / time_fmincon_parallel) ])




