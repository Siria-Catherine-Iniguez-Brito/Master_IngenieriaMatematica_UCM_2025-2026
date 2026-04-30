%% PRACTICA 1 RRNN

% Carga de datos
data = load('PesoAltura.mat'); 
x = data.Altura; 
y = data.Peso; 
N = length(x);

% Configuración 
alpha = [2e-5; 0.01]; 
K_max = 10^4; 
p = randn(2, 1); 

for k = 1:K_max
    neurona = p(1) * x + p(2);
    
    g_w = (2/N) * sum((neurona - y) .* x);
    g_theta = (2/N) * sum(neurona - y);   
    grad = [g_w; g_theta];
 
    p = p - alpha .* grad;
end

% Resultados 
w_final = p(1);
theta_final = p(2);

fprintf('Valores finales: w = %.4f, theta = %.4f\n', w_final, theta_final);

% Predicción para 170 cm
peso_170 = w_final * 170 + theta_final;
fprintf('Peso estimado para 170cm: %.2f kg\n', peso_170);
