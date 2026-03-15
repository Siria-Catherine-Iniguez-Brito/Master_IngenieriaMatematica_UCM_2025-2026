%% CALL AMERICANA 
clear all; clc;

%% --- Parámetros del Modelo Constante ---
K = 10;                      % Precio de ejercicio (Strike)       
r = @(t) 0.05 +0*t;          % Tasa de interés libre de riesgo      
sigma = @(t) 0.2 + 0*t;
q = @(t) 0.035 + 0*t;

S_max = 3*K; 
T = 1;  
w = 1.2; 
tol = 1e-6;

%% --- Malla ---
M = 1000; 
N = 500;


%% ========================================================================
%% COMPARACION CON LA SOLUCIÓN DE MATLAB 
%% ========================================================================
h = S_max / M; 
S_vec = (0:h:S_max)'; 
V_bin_hoy = zeros(length(S_vec), 1);

for i = 1:length(S_vec)
    S_val = S_vec(i);
    if S_val == 0
        V_bin_hoy(i) = 0;
    else
        [~, oPrice] = binprice(S_val, K, r(0), T, T/N, sigma(0), 1, q(0));
        V_bin_hoy(i) = oPrice(1); 
    end
end

V_americano_hoy = call_americana(K, S_max, T, r, sigma, q, M, N, tol, w);
V_americano_hoy = V_americano_hoy(:,1);
error_inf = max(abs(V_americano_hoy - V_bin_hoy));

fprintf('\n============================================================\n');
fprintf('   VALIDACIÓN AMERICANA: PSOR vs MATLAB\n');
fprintf('============================================================\n');
fprintf(' Error en Norma Infinito:  %.4e\n', error_inf);
fprintf(' Parámetro w (relajación): %.2f\n', w);
fprintf(' Tolerancia PSOR:          %.1e\n', tol);
fprintf('============================================================\n');


vector_g = max((0:M)*h-K,0)';

figure('Name', 'Valoracion Americana', 'NumberTitle', 'off'); clf;
plot(S_vec, vector_g, 'k', 'LineWidth', 1, 'DisplayName', 'Payoff (t=T)'); hold on;
plot(S_vec, V_bin_hoy, 'b-', 'LineWidth', 1.2, 'DisplayName', 'Referencia');
plot(S_vec, V_americano_hoy, 'r--', 'LineWidth', 1.2, 'DisplayName', 'CN-PSOR');
grid on; xlim([-1, 3*K+1]); ylim([-1, 21]);  
title('Valoración Americana');
xlabel('Precio del Activo (S)'); ylabel('Valor (V)');
legend('Location', 'northwest');



%% ========================================================================
%% FRONTERA DE EJERICIO ÓPTIMO
%% ========================================================================

S_optimo = zeros(1, N);
matriz = call_americana(K, S_max, T, r, sigma, q, M, N, tol, w); 
for j = 1:N
    idx = find(matriz(:,j) > vector_g, 1, "last"); 
    S_optimo(j) = S_vec(idx);
end

tau = T/N;
tiempo = 0:tau:T;
figure('Name','Ejericio Óptimo','NumberTitle', 'off'); clf;
plot(tiempo(1:end-1), S_optimo, 'b', 'LineWidth', 2);
grid on; title('Frontera de Ejercicio Óptimo S^*(t)');
xlabel('Tiempo (t)'); ylabel('Precio Crítico S^*(t)');


%% ========================================================================
%% PROBAMOS LA FUNCION CON PARAMETROS NO CONSTANTES 
%% ========================================================================

r_var = @(t) 0.05 + 0.02 * sin(2*pi*t);     
sigma_var = @(t) 0.2 + 0.1 * cos(2*pi*t);   
q_var = @(t) 0.03 + 0.01 * t;               

matriz_var = call_americana(K, S_max, T, r_var, sigma_var, q_var, M, N, tol, w);
V_var_hoy = matriz_var(:, 1);

function matriz = call_americana(K, S_max, T, r, sigma, q, M, N, tol, w)
    h = S_max / M; 
    tau = T / N;
    
    n_filas = M + 1;    
    n_columnas = N + 1; 
    
    matriz = zeros(n_filas, n_columnas);
    
    
    %% --- Condiciones de Contorno ---
     
    matriz(:, end) = max((0:M)*h' -K, 0);
    
    tiempo = 0:tau:T ; 
    vec_r = r(tiempo);
    vec_q = q(tiempo);
    matriz(end, :) = max(S_max*exp(-trapz(tiempo, vec_q) + cumtrapz(tiempo, vec_q)) - K*exp(-trapz(tiempo, vec_r) + cumtrapz(tiempo, vec_r)), S_max - K);
    
    matriz(1, :) = 0;
    
    
    %% --- Metodo CN + PSRO ---
    
    vector_g = max((0:M)*h-K,0)'; 
    
    i_vec = (1:M-1)'; 
    
    ai = (tau / 4) * ((r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec - sigma(tiempo(N + 1))^2 * (i_vec.^2));
    bi = (tau / 2) * (sigma(tiempo(N + 1))^2 * i_vec.^2 + r(tiempo(N + 1)));
    ci = (-tau / 4) * ((r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec + sigma(tiempo(N + 1))^2 * (i_vec.^2));
    
    for j = n_columnas:-1:2
       
        vector_d = -ci(end)*matriz(M+1,j) ; 
        
        vector_v = (1 - bi).*matriz(2:end-1, j) - [ci(1: end-1).*matriz(3:end-1, j); 0] - [0; ai(2:end).*matriz(2:end-2, j)];
    
        
        ai = (tau / 4) * ((r(tiempo(j - 1)) - q(tiempo(j - 1)))* i_vec - sigma(tiempo(j - 1))^2 * (i_vec.^2));
        bi = (tau / 2) * (sigma(tiempo(j - 1))^2 * i_vec.^2 + r(tiempo(j - 1)));
        ci = (-tau/4) * ((r(tiempo(j - 1)) - q(tiempo(j - 1))) *i_vec + sigma(tiempo(j - 1))^2 * i_vec.^2);
      
        vector_v(end) = vector_v(end) + vector_d  - ci(end)*matriz(M+1,j-1);
    
        fold = matriz(2 : M, j); 
        fnew = fold;
        error = 1; 
    
        while (error > tol)
            fnew(1) = max(vector_g(2), (1 - w) * fold(1) + w / (1 + bi(1)) * (vector_v(1) - ci(1) * fold(2))); 
            
            for i = 2 : M - 2
                fnew(i) = max(vector_g(i+1), (1 - w) * fold(i) + w / (1 + bi(i)) * (vector_v(i) - ai(i) * fnew(i - 1) - ci(i) * fold(i + 1)));
                
            end 
            fnew(M - 1) = max(vector_g(M), (1 - w) * fold(M - 1) + w/(1 + bi(M - 1)) * (vector_v(M - 1) - ai(M - 1) * fnew(M - 2)));
    
            error = norm(fold - fnew, inf);
            fold = fnew; 
        end 
        matriz(2 : M, j - 1) = fnew; 
    
    end
end 







