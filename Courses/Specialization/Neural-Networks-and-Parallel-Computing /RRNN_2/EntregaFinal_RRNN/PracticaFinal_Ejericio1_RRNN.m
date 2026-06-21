%% PROBLEMA I: Perceptón
clear; clc; close all;

%% 1. Carga y Preparación de Datos 
[XTrainRaw, YTrainRaw] = digitTrain4DArrayData; 
[XTestRaw, YTestRaw] = digitTest4DArrayData;

% --- CONFIGURACIÓN DEL EXPERIMENTO ---
cifraA = '0'; 
cifraB = '4';
alpha = 0.25;
beta  = 0.85;
MaxEpochs = 500;
nRepeticiones = 1; % Cambio a 10 para hacer las pruebas
% -------------------------------------

% Filtrado y Normalización
idxTr = (YTrainRaw == cifraA | YTrainRaw == cifraB);
idxTe = (YTestRaw == cifraA | YTestRaw == cifraB);
X_train_all = reshape(double(XTrainRaw(:,:,:,idxTr)), 784, []) / 255; 
X_test  = reshape(double(XTestRaw(:,:,:,idxTe)), 784, []) / 255;
C_train_all = double(YTrainRaw(idxTr) == cifraB)'; 
C_test  = double(YTestRaw(idxTe) == cifraB)';

%% 2. Ejecución de las Pruebas
precisiones = zeros(nRepeticiones, 1);
fprintf('Iniciando experimento: %s vs %s\n', cifraA, cifraB);

for r = 1:nRepeticiones
    [train_err, test_err, acc] = entrenarPerceptron(X_train_all, C_train_all, X_test, C_test, alpha, beta, MaxEpochs);

    precisiones(r) = acc;
    fprintf('  Repetición %d: Precisión = %.2f%%\n', r, acc);
end

%% 3. Resultados y Visualización
media_acc = mean(precisiones);
desv_std  = std(precisiones);

fprintf('\n--- RESULTADOS PARA LA TABLA LATEX ---\n');
fprintf('VALOR: %.2f%% \\pm %.2f%%\n', media_acc, desv_std);

% Graficamos el resultado de la última repetición
figure('Color', 'w');
plot(1:MaxEpochs, train_err, 'b-', 'LineWidth', 1.5); hold on;
plot(1:MaxEpochs, test_err, 'r-', 'LineWidth', 1.5);
grid on; xlabel('Época'); ylabel('Error E');
title(sprintf('Dígitos %s vs %s (\\alpha=%.2f, \\beta=%.2f)', cifraA, cifraB, alpha, beta));
legend('Entrenamiento', 'Test');

function [train_error, test_error, final_acc] = entrenarPerceptron(X_tr_all, C_tr_all, X_te, C_te, alpha, beta, MaxEpochs)
% 1. Randomización interna
nMuestras = size(X_tr_all, 2);
idx = randperm(nMuestras);
X_train = X_tr_all(:, idx);
C_train = C_tr_all(idx);

% 2. Inicialización
[nFeatures, N] = size(X_train);
w = randn(1, nFeatures) * 0.01;
theta = 0;
sk_w = zeros(size(w));
sk_theta = 0;

train_error = zeros(MaxEpochs, 1);
test_error = zeros(MaxEpochs, 1);

% 3. Bucle de entrenamiento
for k = 1:MaxEpochs
    u = w * X_train + theta;
    y = 1 ./ (1 + exp(-u));

    % Gradiente
    dy = y - C_train;
    grad_u = (2/N) * dy .* (y .* (1 - y));
    grad_w = grad_u * X_train';
    grad_theta = sum(grad_u);

    % Momentos
    sk_w = beta * sk_w + (1 - beta) * grad_w;
    sk_theta = beta * sk_theta + (1 - beta) * grad_theta;

    % Actualización
    w = w - alpha * sk_w;
    theta = theta - alpha * sk_theta;

    % Cálculo de errores 
    train_error(k) = mean(abs(C_train - (y > 0.5)));

    u_test = w * X_te + theta;
    y_test = 1 ./ (1 + exp(-u_test));
    test_error(k) = mean(abs(C_te - (y_test > 0.5)));
end

final_acc = 100 * (1 - test_error(end));
end