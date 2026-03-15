%% COMPARATIVA DE ESQUEMAS: CALL EUROPEA 
clear all; clc;

%% --- Parámetros ---
K = 10;    
S_max = 3*K;        
T = 1;              
r = @(t) 0.05 + 0*t;       
sigma = @(t) 0.2 + 0*t;
q = @(t) 0.035 + 0*t;

%% --- Configuración de la Malla ---
M = 100; 
N = 1000;
S_vec = linspace(0, S_max, M+1)';

[V_BS_vec, ~] = blsprice(S_vec, K, r(0), T, sigma(0), q(0));

S_plot = S_vec;

V_payoff = max(S_plot - K, 0);

V_CN = call_europea_CN(K, S_max, T, r, sigma, q, M, N);
V_I  = call_europea_I(K, S_max, T, r, sigma, q, M, N);
V_E  = call_europea_E(K, S_max, T, r, sigma, q, M, N);



%% ========================================================================
%% 1. COMPRACION CON BLSPRICE
%% ========================================================================

% Crank-Nicolson
figure('Name', 'Método Crank-Nicolson', 'NumberTitle', 'off');
plot(S_plot, V_payoff, 'k', 'LineWidth', 1.5, 'DisplayName', 'Payoff (t=T)'); hold on;
plot(S_plot, V_BS_vec, 'b-', 'LineWidth', 1.5, 'DisplayName', 'BS Referencia');
plot(S_plot, V_CN, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Crank-Nicolson');
xlabel('Precio del Activo (S)');
ylabel('Valor de la Opción (V)');
title('Valoración de una Opción Call - Crack-Nicolson'); grid on; xlim([-1, 3*K+1]); ylim([-1, 21]); legend('Location', 'northwest');

% Implícito
figure('Name', 'Método Implícito', 'NumberTitle', 'off');
plot(S_plot, V_payoff, 'k', 'LineWidth', 1.5, 'DisplayName', 'Payoff (t=T)'); hold on;
plot(S_plot, V_BS_vec, 'b-', 'LineWidth', 1.5, 'DisplayName', 'BS Referencia');
plot(S_plot, V_I, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Implícito');
xlabel('Precio del Activo (S)');
ylabel('Valor de la Opción (V)');
title('Valoración de una Opción Call - Método Implícito'); grid on; xlim([-1, 3*K+1]); ylim([-1, 21]);legend('Location', 'northwest');

% Explícito
figure('Name', 'Método Explícito', 'NumberTitle', 'off');
plot(S_plot, V_payoff, 'k', 'LineWidth', 1.5, 'DisplayName', 'Payoff (t=T)'); hold on;
plot(S_plot, V_BS_vec, 'b-', 'LineWidth', 1.5, 'DisplayName', 'BS Referencia');
plot(S_plot, V_E, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Explícito');
xlabel('Precio del Activo (S)');
ylabel('Valor de la Opción (V)');
title('Valoración de una Opción Call - Método Explícito'); grid on; xlim([-1, 3*K+1]); ylim([-1, 21]); legend('Location', 'northwest');


%% ========================================================================
%% 2. DISTRIBUCIÓN DEL ERROR 
%% ========================================================================

figure('Name', 'Error Absoluto', 'NumberTitle', 'off');
plot(S_vec, abs(V_CN - V_BS_vec), 'r', 'LineWidth', 1.5); hold on;
plot(S_vec, abs(V_I - V_BS_vec), 'b', 'LineWidth', 1.5);
plot(S_vec, abs(V_E - V_BS_vec), 'g', 'LineWidth', 1.5);
xlim([0, 3*K]); grid on;
xlabel('Precio del Activo (S)');
ylabel('Error Absoluto');
title('Distribución del Error Absoluto');
legend('Crank-Nicolson', 'Implícito', 'Explícito');

norm_inf_CN = max(abs(V_CN - V_BS_vec));
norm_inf_I  = max(abs(V_I - V_BS_vec));
norm_inf_E  = max(abs(V_E - V_BS_vec));

fprintf('\n============================================================\n');
fprintf('   CÁLCULO ERRORES\n');
fprintf('============================================================\n');
fprintf('Norma Infinito Crank-Nicolson: %.2e\n', norm_inf_CN);
fprintf('Norma Infinito Implícito:      %.2e\n', norm_inf_I);
fprintf('Norma Infinito Explícito:      %.2e\n', norm_inf_E);



%% ========================================================================
%% 3. COMPARACIÓN METODOS 
%% ========================================================================
fprintf('\n============================================================\n');
fprintf('   COMPARACIÓN MÉTODOS\n');
fprintf('============================================================\n'); 

M_comp = [10, 20, 40, 80]; 
N_comp = [100, 400, 1600, 6400];

%% --- Comparativa: Explícito vs Implícito vs CN ---
err_E = zeros(size(M_comp));
err_I = zeros(size(M_comp));
err_CN = zeros(size(M_comp));

fprintf('\n%-5s %-7s | %-12s %-12s %-12s\n', 'M', 'N', 'Err Expl', 'Err Impl', 'Err CN');
fprintf('------------------------------------------------------------\n');

for i = 1:length(M_comp)
    m = M_comp(i);
    n = N_comp(i);
    
    S_tmp = linspace(0, S_max, m+1)';
    V_BS = blsprice(S_tmp, K, r(0), T, sigma(0), q(0));
    
 
    V_E  = call_europea_E(K, S_max, T, r, sigma, q, m, n);
    V_I  = call_europea_I(K, S_max, T, r, sigma, q, m, n);
    V_CN = call_europea_CN(K, S_max, T, r, sigma, q, m, n);
    

    err_E(i) = max(abs(V_E - V_BS));
    err_I(i) = max(abs(V_I - V_BS));
    err_CN(i) = max(abs(V_CN - V_BS));
    
    fprintf('%-5d %-7d | %-12.2e %-12.2e %-12.2e\n', m, n, err_E(i), err_I(i), err_CN(i));
end



M_pre = [40, 80, 160, 320];
N_exp  = [64, 256, 1024, 4096]; 
N_cn_eff = [40, 80, 160, 320];  

fprintf('\n============================================================================\n');
fprintf('      COMPARATIVA DE PRECISIÓN Y ESFUERZO \n');
fprintf('============================================================================\n');
fprintf('%-6s | %-25s | %-25s\n', 'M', 'Error Explícito (N_exp)', 'Error Crank-Nicolson (N_cn)');
fprintf('----------------------------------------------------------------------------\n');

for i = 1:length(M_pre)
    m = M_pre(i);
    n_e = N_exp(i);
    n_c = N_cn_eff(i);
    
    S_tmp = linspace(0, S_max, m+1)';
    V_BS = blsprice(S_tmp, K, r(0), T, sigma(0), q(0));
    
    V_E = call_europea_E(K, S_max, T, r, sigma, q, m, n_e);
    err_E = max(abs(V_E - V_BS));
    
    V_CN = call_europea_CN(K, S_max, T, r, sigma, q, m, n_c);
    err_CN = max(abs(V_CN - V_BS));
    
    str_E  = sprintf('%.3e (N=%d)', err_E, n_e);
    str_CN = sprintf('%.3e (N=%d)', err_CN, n_c);
    
    fprintf('%-6d | %-25s | %-25s\n', m, str_E, str_CN);
end
fprintf('----------------------------------------------------------------------------\n');


%% ========================================================================
%% 6. ESCENARIO DINÁMICO 
%% ========================================================================

% Parámetros variables 
r_var     = @(t) 0.05 + 0.01 * sin(pi * t); 
sigma_var = @(t) 0.20 + 0.05 * sin(pi * t); 
q_var     = @(t) 0.035 + 0.01 * sin(pi * t); 

M_var = 150; 
N_var = 2500; 


V_CN_var = call_europea_CN(K, S_max, T, r_var, sigma_var, q_var, M_var, N_var);
V_I_var  = call_europea_I(K, S_max, T, r_var, sigma_var, q_var, M_var, N_var);
V_E_var  = call_europea_E(K, S_max, T, r_var, sigma_var, q_var, M_var, N_var);

diff_CN_I = max(abs(V_CN_var - V_I_var));
diff_CN_E = max(abs(V_CN_var - V_E_var));
diff_I_E = max(abs(V_I_var - V_E_var));

fprintf('\n============================================================\n');
fprintf('   RESULTADOS DEPENDIENTE DEL TIEMPO\n');
fprintf('============================================================\n');
fprintf('Diferencia Máxima (CN vs Implícito): %.2e\n', diff_CN_I);
fprintf('Diferencia Máxima (CN vs Explícito): %.2e\n', diff_CN_E);
fprintf('Diferencia Máxima (Implícito vs Explícito): %.2e\n', diff_I_E);


figure('Name', 'Valoración en Escenario Dinámico', 'NumberTitle', 'off');

S_plot_var = linspace(0, S_max, M_var+1)';
V_payoff_var = max(S_plot_var - K, 0);

plot(S_plot_var, V_payoff_var, 'k-', 'LineWidth', 1.2, 'DisplayName', 'Payoff (t=T)'); hold on;
plot(S_plot_var, V_CN_var, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Crank-Nicolson');
plot(S_plot_var, V_I_var, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Implícito ');
plot(S_plot_var, V_E_var, 'g:', 'LineWidth', 1.5, 'DisplayName', 'Explícito');

grid on;
xlim([-1, 3*K+1]); 
ylim([-1, 21]);
title('Comparativa de Métodos: Escenario Dinámico');
xlabel('Precio del Activo Subyacente (S)');
ylabel('Valor de la Opción (V)');
legend('Location', 'northwest', 'FontSize', 10);

text(K*0.1, K*0.8, {['r(t) = 0.05 + 0.01·sin(\pi t)'], ...
                   ['\sigma(t) = 0.2 + 0.05·sin(\pi t)'], ...
                   ['q(t) = 0.035 + 0.01·sin(\pi t)']}, ...
     'BackgroundColor', [1 1 0.9], 'EdgeColor', 'k');



%% ========================================================================
%% 5. ESQUEMAS
%% ========================================================================

function valor_hoy = call_europea_CN(K, S_max, T, r, sigma, q, M, N)
    h = S_max / M; 
    tau = T / N;
    
    n_filas = M + 1;    
    n_columnas = N + 1; 
    
    matriz = zeros(n_filas, n_columnas);
    
    
    %% --- Condiciones de Contorno ---
    matriz(:, end) = max((0:M)*h' - K, 0);
    
    tiempo = 0 : tau : T ; 
    vec_r = r(tiempo);
    vec_q = q(tiempo);
    
    int_r = cumtrapz(tiempo, vec_r);
    int_q = cumtrapz(tiempo, vec_q);
    
    matriz(end,:) = S_max * exp(-(int_q(end) - int_q))  - K * exp(-(int_r(end) - int_r));
    
    
    i_vec = (1:M-1)'; 
    
    ai = (tau / 4) * ((r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec - sigma(tiempo(N + 1))^2 * (i_vec.^2));
    bi = tau / 2 * (sigma(tiempo(N + 1))^2 * i_vec.^2 + r(tiempo(N + 1)));
    ci = - tau / 4 * ((r(tiempo(N + 1)) -q(tiempo(N+1))) * i_vec + sigma(tiempo(N + 1))^2 * i_vec.^2);
    for j = n_columnas:-1:2
        
        
        vector_d = zeros(M - 1, 1);
        vector_d(end) = -ci(end)*matriz(M + 1,j); 
     
        izq = (1 - bi) .* matriz(2 : end - 1, j) - [ci(1: end-1) .* matriz(3 : end - 1, j); 0] - [0; ai(2 : end) .* matriz(2 : end - 2, j)];
        
        ai = (tau / 4) * ((r(tiempo(j - 1)) - q(tiempo(j - 1))) * i_vec - sigma(tiempo(j - 1))^2 * (i_vec.^2));
        bi = tau / 2 * (sigma(tiempo(j - 1))^2 * i_vec.^2 + r(tiempo(j - 1)));
        ci = -tau / 4 * ((r(tiempo(j - 1)) - q(tiempo(j - 1))) * i_vec + sigma(tiempo(j - 1))^2 * i_vec.^2);
        
        vector_d(end) = vector_d(end) - ci(end) * matriz(M + 1, j - 1);
        
        matriz(2:M, j-1) = tridiag(ai(2 : end), 1 + bi, ci(1 : end - 1), izq + vector_d);  
    end 
    valor_hoy = matriz(:, 1); 
end 


function valor_hoy = call_europea_E(K, S_max, T, r, sigma, q, M, N)
    h = S_max / M; 
    tau = T / N;
    
    n_filas = M + 1;    
    n_columnas = N + 1; 
    
    matriz = zeros(n_filas, n_columnas);
    
    
    %% --- Condiciones de Contorno ---
    matriz(:, end) = max((0:M)*h' - K, 0);
    
    tiempo = 0:tau:T ; 
    vec_r = r(tiempo);
    vec_q = q(tiempo);
    
    int_r = cumtrapz(tiempo, vec_r);
    int_q = cumtrapz(tiempo, vec_q);
    
    matriz(end,:) = S_max * exp(-(int_q(end) - int_q))  - K * exp(-(int_r(end) - int_r));
    
    
    i_vec = (1:M-1)'; 
    
    ai = (tau / 2) * (-(r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec + sigma(tiempo(N + 1))^2 * (i_vec.^2));
    bi = 1 - tau * (sigma(tiempo(N + 1))^2 * i_vec.^2 + r(tiempo(N + 1)));
    ci = (tau / 2) * ((r(tiempo(N + 1)) - q(tiempo(N+1))) * i_vec + sigma(tiempo(N + 1))^2 * i_vec.^2);
    for j = n_columnas : -1 : 2

        for i = 2 : M
            matriz(i, j - 1) = ai(i-1) * matriz(i - 1, j) + bi(i-1) * matriz(i, j) + ci(i-1) * matriz(i + 1, j); 
        end 
        
        ai = (tau / 2) * (-(r(tiempo(j - 1)) - q(tiempo(j - 1))) * i_vec + sigma(tiempo(j - 1))^2 * (i_vec.^2));
        bi = 1 - tau * (sigma(tiempo(j - 1))^2 * i_vec.^2 + r(tiempo(j-1)));
        ci = (tau / 2) * ((r(tiempo(j - 1)) - q(tiempo(j - 1))) * i_vec + sigma(tiempo(j - 1))^2 * i_vec.^2);
    end 
    valor_hoy = matriz(:,1); 
end 


function valor_hoy = call_europea_I(K, S_max, T, r, sigma, q, M, N)
    h = S_max / M; 
    tau = T / N;
    
    n_filas = M + 1;    
    n_columnas = N + 1; 
    
    matriz = zeros(n_filas, n_columnas);
    
    
    %% --- Condiciones de Contorno ---
    matriz(:, end) = max((0:M)*h' - K, 0);
    
    tiempo = 0:tau:T ; 
    vec_r = r(tiempo);
    vec_q = q(tiempo);
    
    int_r = cumtrapz(tiempo, vec_r);
    int_q = cumtrapz(tiempo, vec_q);
    
    matriz(end,:) = S_max * exp(-(int_q(end) - int_q))  - K * exp(-(int_r(end) - int_r));
    
    for j = N:-1:1

        i_vec = (1:M-1)'; 
        ai = (tau / 2) * ((r(tiempo(j)) - q(tiempo(j))) * i_vec - sigma(tiempo(j))^2 * i_vec.^2 );
        bi = 1 + tau * (sigma(tiempo(j))^2 * i_vec.^2 + r(tiempo(j)));
        ci = -(tau / 2) * (sigma(tiempo(j))^2 * i_vec.^2 + (r(tiempo(j)) - q(tiempo(j))) * i_vec);
        
        vector_d = matriz(2 : M, j + 1);
        vector_d(end) = vector_d(end) - ci(end) * matriz(end, j);
        
        matriz(2:M, j) = tridiag(ai(2:end), bi, ci(1:end-1), vector_d);
    end
    valor_hoy = matriz(:, 1); 
end 

