% PRACTICA 1 RRNN
clear all 
close all 

%% Ejemplo 1 
comp = 2*1e6; 
MAT = rand(comp,10); 
u = rand(10,1); 

% Metodo directo 
tic 
b = MAT*u; 
td = toc; 
disp(['Tiempo directo: ' num2str(td) '(s)'])

% Método iterativo secuencial 
tic 
b = []; 
for ii = 1: comp 
    b(ii) = MAT(ii,:)*u; 
end 
tf = toc; 
disp(['Tiempo for: ' num2str(tf) '(s)'])


% Método iterativo paralelo

%Cambiar esto : 
% parfor ii = 1: nmax
% añadir un for 
%     b(ii) = MAT(ii,:)*u;
%end 
tic 
b = []; 
parfor ii = 1: comp
     b(ii) = MAT(ii,:)*u;
end 
tp = toc; 
disp(['Tiempo parfor: ' num2str(tp) '(s)'])

disp(['Speedup vs directo: ' num2str(td/tp)])
disp(['Speedup vs it. sec.: ' num2str(tf/tp)])