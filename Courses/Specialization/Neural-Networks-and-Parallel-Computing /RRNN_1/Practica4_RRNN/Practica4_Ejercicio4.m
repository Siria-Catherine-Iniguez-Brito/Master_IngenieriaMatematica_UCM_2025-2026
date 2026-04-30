% =========================================================================
% PRÁCTICA 4: EJERCICIO 4
% =========================================================================

%xinit=rand(1,4)*2000;
%[sol,f,times,neval,sc,it,rhog,fevo]=gradpar(@func3,xinit,1000,1e-2,1e-3,1,100);

%xinit=rand(1)*2000;
%[sol,f,times,neval,sc,it,rhog,fevo]=gradseq(@func3,xinit,1000,1e-2,1e-3,1,100);

clear all
close all
clc


pjob = gcp('nocreate');
if isempty(pjob)
    parpool();
end


complist = [100000, 500000, 1000000, 1500000, 2000000, 2500000, 3000000];
dim = 4; 

% Inicializamos vectores para guardar tiempos
tiempos_seq = zeros(1, length(complist));
tiempos_par = zeros(1, length(complist));

disp('Iniciando la comparativa de tiempos...');

for k = 1:length(complist)
    compl = complist(k);
    disp(['-> Evaluando complejidad: ', num2str(compl)]);
    
    xinit = rand(1, dim) * 2000;
    
    [~, ~, t_seq, ~, ~, ~, ~, ~] = gradseq(@func3, xinit, 1000, 1e-2, 1e-3, 0, compl);
    tiempos_seq(k) = t_seq;
    
    [~, ~, t_par, ~, ~, ~, ~, ~] = gradpar(@func3, xinit, 1000, 1e-2, 1e-3, 0, compl);
    tiempos_par(k) = t_par;
end

% Cálculo de Speedup
speedup = tiempos_seq ./ tiempos_par

% Gráfica 
figure(1)
clf
plot(complist, speedup, ':ob', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b')
xlabel('Complejidad de la función coste')
ylabel('Speedup')
title('Speedup vs Complejidad de la Función Coste')
grid on
box on