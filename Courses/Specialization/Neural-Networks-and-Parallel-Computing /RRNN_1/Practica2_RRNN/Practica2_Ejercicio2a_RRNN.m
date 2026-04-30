% =========================================================================
% PRÁCTICA 2: EJERCICIO 2.a
% =========================================================================
clear all
close all 
clc 

x = rand(36,1); 
y = zeros(length(x),1); 

tic 
for i = 1: length(x)
    y(i)=func1(x(i));
end 

timec(1) = toc; 
disp(['Tiempo con bucle for en secuencial: ' num2str(toc)])


tic  
y2 = arrayfun(@(x) func1(x), x);
timec(2) = toc; 
disp(['Tiempo con array en secuencial: ' num2str(toc)])


% Version paralela 
gcp; 
pjob = gcp; 
npmax = pjob.NumWorkers; 
nn = ceil(length(x)/npmax); 
yp = zeros(npmax, nn); 
tic 
parfor i = 1:npmax
    for j = 1:nn 
        yp(i,j) = func1(x(j+(i-1)*nn)); 
    end 
end 
ypf = [yp(1,:), yp(2,:), yp(3,:), yp(4,:), yp(5,:), yp(6,:)]; 
timec(4) = toc; 

disp(['Tiempo con bucle for en paralelo: ' num2str(toc) ' con ' num2str(npmax) ' workers'])



%% --- EJERCICIO 2 a): ---
gcp;
pjob = gcp;
npmax = pjob.NumWorkers; 
nn = length(x) / npmax; 


yp2_matriz = zeros(npmax, nn); 

tic
parfor i = 1:npmax
    idx_inicio = 1 + (i-1)*nn;
    idx_fin = i*nn; 
    
    mi_trozo = x(idx_inicio:idx_fin);
    
    res_local = arrayfun(@(val) func1(val), mi_trozo);
    
    yp2_matriz(i, :) = res_local;
end

ypf2 = yp2_matriz'; 
ypf2 = ypf2(:)'; 

timec(6) = toc;
disp(['Tiempo con arrayfun en paralelo usando ', num2str(npmax), ' workers: ', num2str(timec(6)), ' (s)'])