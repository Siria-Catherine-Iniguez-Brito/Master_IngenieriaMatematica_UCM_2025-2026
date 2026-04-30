% =========================================================================
% PRÁCTICA 1: EJERCICIO 1
% =========================================================================
clear all 
close all 

lpass = 4*300000; 

for ii = 1:lpass 
    pass(ii) = char(round(rand*1792)); 
end 

%% --- ESTRUCTURA SECUENCIAL ---
tic 
lcode = char(0:1792)'; 
asciic = 0:1792; 

for ii = 1:lpass 
    passc(ii) = asciic(pass(ii) == lcode); 
end 

tiemp(1) = toc; 
disp(['Tiempo Secuencial: ' num2str(tiemp(1)) ' (s)'])


%% --- ESTRUCTURA SPMD ---
pjob = gcp('nocreate'); 
if isempty(pjob)
    pjob = parpool(); 
end
npmax = pjob.NumWorkers; 


nn = round(lpass / npmax); 

tic 
spmd 
    % Cada Worker calcula su trozo usando labindex
    inicio = (labindex - 1) * nn + 1; 
    fin = labindex * nn; 
    
    mi_trozo = pass(inicio:fin); 
    mi_resultado = zeros(1, nn); 
    
    for ii = 1:nn 
        mi_resultado(ii) = asciic(mi_trozo(ii) == lcode); 
    end
end 

% Concatenamos todo en un único vector solución 
passc_spmd = [mi_resultado{1:npmax}]; 
tiemp(2) = toc; 

disp(['Tiempo SPMD:       ' num2str(tiemp(2)) ' (s)'])


%% --- APARTADO B: BUCLE PARFOR ---
pass_dividida = reshape(pass(1:npmax*nn), npmax, nn); 
passp = zeros(npmax, nn); 

tic
parfor ii = 1:npmax
    fila_actual = pass_dividida(ii, :);
    for jj = 1:nn
        passp(ii, jj) = asciic(fila_actual(jj) == lcode);
    end
end
% Al final concatenamos todo en un único vector solución 
passc_parfor = reshape(passp, 1, npmax*nn);
tiemp(3) = toc;
disp(['Tiempo PARFOR:     ' num2str(tiemp(3)) ' (s)'])


%% ---  COMPARAR PARFOR CON 2, 3, 4 y 6 WORKERS ---
nucleos = [2, 3, 4, 6];
tiempos_nucleos = [];

for indice = 1:length(nucleos)
    np = nucleos(indice); 
    
    % Ajustamos el tamaño divisible para el número de núcleos actual
    nn_local = round(lpass / np);
 
    pass_dividida_graf = reshape(pass, np, nn_local); 
    passp_graf = zeros(np, nn_local);
    
    tic 
    % Forzamos al parfor a usar exactamente 'np' workers
    parfor (ii = 1:np, np)
        fila_actual = pass_dividida_graf(ii, :);
        res_local = zeros(1, nn_local);
        for jj = 1:nn_local
            res_local(jj) = asciic(fila_actual(jj) == lcode);
        end
        passp_graf(ii, :) = res_local;
    end
    tiempos_nucleos(indice) = toc; 
end 

% Graficamos los resultados
figure(1)
clf 

speedup = tiemp(1) ./ tiempos_nucleos;

plot(nucleos, speedup, ':or', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r')
xlabel('Número de Workers')
ylabel('Ratio de Speedup')
title('Comparativa de Speedup (Secuencial vs PARFOR)')
grid on
box on