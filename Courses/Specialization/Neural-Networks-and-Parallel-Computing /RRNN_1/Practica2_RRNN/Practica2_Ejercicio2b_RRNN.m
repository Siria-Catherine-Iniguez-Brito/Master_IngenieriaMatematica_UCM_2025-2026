% =========================================================================
% PRÁCTICA 2: EJERCICIO 2.b
% =========================================================================
clear all
close all 
clc 

NS = 1000; 

tic 
for ii = 1: NS
    betai = unifrnd(0.05, 0.5); 
    gamma = 1/ unifrnd(10,20); 
    mu = 1/ unifrnd(30,90); 
    cm = 1/ unifrnd(20000,30000); 
    N = 100 ; 
    x0 = [N-1; 1; 0]; 
    tf = 365*300; 
    beta = @(t) (2 + sin(2 * pi * t / 365)) * betai * exp( -cm * t); 
    model = @(t,x) [-beta(t) * x(1) * x(2) / N + mu * x(3);...
                    beta(t) * x(1) * x(2) / N - gamma * x(2); ...
                    + gamma * x(2) - mu * x(3)]; 
    sol = ode23(model, [0 tf], x0); 
    tfinal(ii)= max(sol.x(sol.y(2, :) > 1));
end 
tiempo_secuencial = toc;
disp(['Tiempo Secuencial: ' num2str(tiempo_secuencial) ' (s)'])

figure(1)
clf 
hold on 
plot(sol.x, sol.y(1,:))
plot(sol.x, sol.y(2,:))
plot(sol.x, sol.y(3,:))
legend('S', 'I', 'R')
axis tight 
grid on 
box on 


% =========================================================================
% EJERCICIO 2.b): MODELO EPIDEMIOLÓGICO EN PARALELO Y SPEEDUP
% =========================================================================

% Version paralela
pjob = gcp('nocreate'); 
if isempty(pjob)
    pjob = parpool(); 
end
npmax = pjob.NumWorkers;


disp(' ');
disp(['2. Ejecutando versión paralela al máximo con ', num2str(npmax), ' núcleos...']);
tfinal_par_max = zeros(1, NS);

tic
parfor ii = 1:NS
    betai_p = unifrnd(0.05, 0.5); 
    gamma_p = 1 / unifrnd(10, 20); 
    mu_p = 1 / unifrnd(30, 90); 
    cm_p = 1 / unifrnd(20000, 30000); 
    
    N_p = 100; 
    x0_p = [N_p-1; 1; 0]; 
    tf_p = 365 * 300; 
    
    beta_p = @(t) (2 + sin(2 * pi * t / 365)) * betai_p * exp(-cm_p * t); 
    
    model_p = @(t,x) [-beta_p(t) * x(1) * x(2) / N_p + mu_p * x(3);...
                      beta_p(t) * x(1) * x(2) / N_p - gamma_p * x(2); ...
                      gamma_p * x(2) - mu_p * x(3)]; 
                
    sol_par = ode23(model_p, [0 tf_p], x0_p); 
    
    tfinal_par_max(ii) = max(sol_par.x(sol_par.y(2, :) > 1));
end 

tiempo_paralelo_max = toc;
disp(['-> Tiempo Paralelo al máximo: ', num2str(tiempo_paralelo_max), ' (s)'])


disp(' ');
disp('3. Calculando tiempos para la gráfica de Speedup...');


nucleos_evaluar = 1:npmax;
tiempos_par = zeros(1, length(nucleos_evaluar));

for idx = 1:length(nucleos_evaluar)
    num_nuc = nucleos_evaluar(idx);
    
    tic
    tfinal_par = zeros(1, NS);
    
    % Forzamos al parfor a usar el número de núcleos específico
    parfor (ii = 1:NS, num_nuc)
        betai_p = unifrnd(0.05, 0.5); 
        gamma_p = 1 / unifrnd(10, 20); 
        mu_p = 1 / unifrnd(30, 90); 
        cm_p = 1 / unifrnd(20000, 30000); 
        
        N_p = 100; 
        x0_p = [N_p-1; 1; 0]; 
        tf_p = 365 * 300; 
        
        beta_p = @(t) (2 + sin(2 * pi * t / 365)) * betai_p * exp(-cm_p * t); 
        
        model_p = @(t,x) [-beta_p(t) * x(1) * x(2) / N_p + mu_p * x(3);...
                          beta_p(t) * x(1) * x(2) / N_p - gamma_p * x(2); ...
                          gamma_p * x(2) - mu_p * x(3)]; 
                    
        sol_p = ode23(model_p, [0 tf_p], x0_p); 
        
        tfinal_par(ii) = max(sol_p.x(sol_p.y(2, :) > 1));
    end 
    tiempos_par(idx) = toc;
    disp(['Completado con ', num2str(num_nuc), ' núcleo(s) en ', num2str(tiempos_par(idx)), ' (s)']);
end


% Figura 2: Gráfica de Speedup
figure(2)
clf
speedup = tiempo_secuencial ./ tiempos_par;

plot(nucleos_evaluar, speedup, ':ob', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b')
hold on
plot(nucleos_evaluar, nucleos_evaluar, '--k', 'LineWidth', 1)

xlabel('Número de Workers (Núcleos)')
ylabel('Ratio de Speedup')
title('Gráfica de Speedup para el Modelo Epidemiológico')
legend('Speedup obtenido', 'Speedup ideal (teórico)', 'Location', 'NorthWest')
grid on
box on
