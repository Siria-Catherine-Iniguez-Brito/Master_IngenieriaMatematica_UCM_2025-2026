%% PROBLEMA 2: Clasificación de Dígitos Caseros
clear; clc; close all;

%% 1. Carga y Preprocesamiento de Datos 
[XTrain, YTrain] = digitTrain4DArrayData; 
[XTest, YTest] = digitTest4DArrayData;

% Normalizar valores de píxeles al rango [0, 1]
XTrain = im2double(XTrain);
XTest = im2double(XTest);

%% 2. Construcción de Redes Neuronales 
% a) Red Fully Connected Optimizada
layersDense = [
    imageInputLayer([28 28 1], 'Name', 'Input', 'Normalization', 'none')
    fullyConnectedLayer(1024, 'Name', 'FC1')
    batchNormalizationLayer('Name', 'BN1')
    reluLayer('Name', 'ReLU1')
    dropoutLayer(0.4, 'Name', 'Drop1')
    fullyConnectedLayer(512, 'Name', 'FC2')
    batchNormalizationLayer('Name', 'BN2')
    reluLayer('Name', 'ReLU2')
    dropoutLayer(0.4, 'Name', 'Drop2')
    fullyConnectedLayer(256, 'Name', 'FC3')
    reluLayer('Name', 'ReLU3')
    fullyConnectedLayer(10, 'Name', 'OutputFC')
    softmaxLayer('Name', 'Softmax')
    classificationLayer('Name', 'ClassOutput')];

% b) Red Convolucional (CNN) más profunda
layersCNN = [
    imageInputLayer([28 28 1], 'Name', 'Input', 'Normalization', 'none')

    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'Conv1')
    batchNormalizationLayer('Name', 'BN1')
    reluLayer('Name', 'ReLU1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'Pool1')

    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'Conv2')
    batchNormalizationLayer('Name', 'BN2')
    reluLayer('Name', 'ReLU2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'Pool2')

    convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'Conv3')
    batchNormalizationLayer('Name', 'BN3')
    reluLayer('Name', 'ReLU3')

    fullyConnectedLayer(256, 'Name', 'FC_Hidden')
    reluLayer('Name', 'ReLU_FC')
    dropoutLayer(0.3, 'Name', 'Drop') 

    fullyConnectedLayer(10, 'Name', 'Output')
    softmaxLayer('Name', 'Softmax')
    classificationLayer('Name', 'ClassOutput')];


%% 3. Configuración y Entrenamiento 
% --- Opciones para la Red Densa  ---
optionsDense = trainingOptions('adam', ... 
    'MaxEpochs', 30, ...
    'InitialLearnRate', 0.0005, ... 
    'L2Regularization', 0.001, ...   
    'ValidationData', {XTest, YTest}, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% --- Opciones para la Red CNN  ---
optionsCNN = trainingOptions('sgdm', ...
    'MaxEpochs', 20, ...             
    'InitialLearnRate', 0.01, ...    
    'Momentum', 0.9, ...             
    'ValidationData', {XTest, YTest}, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% Crear un aumentador de datos (rotaciones, traslaciones ...)
augmenter = imageDataAugmenter(...
    'RandRotation', [-15 15], ...   % Rota los números hasta 15 grados
    'RandXTranslation', [-3 3], ... % Los desplaza 
    'RandYTranslation', [-3 3], ...
    'RandScale', [0.9 1.1]);        % Cambia ligeramente el tamaño

augimds = augmentedImageDatastore([28 28], XTrain, YTrain, 'DataAugmentation', augmenter);


% --- Entrenamiento Red Densa ---
fprintf('Entrenando Red Densa...\n');
netDense = trainNetwork(augimds, layersDense, optionsDense);
% --- Entrenamiento Red CNN ---
fprintf('Entrenando Red Convolucional...\n');
netCNN = trainNetwork(augimds, layersCNN, optionsCNN);

%% 4. Evaluación de Rendimiento Final en Test
predTestDense = classify(netDense, XTest);
accuracyDense = mean(predTestDense == YTest);

predTestCNN = classify(netCNN, XTest);
accuracyCNN = mean(predTestCNN == YTest);

fprintf('\n--- RESULTADOS FINALES EN TEST (MNIST) ---\n');
fprintf('Precisión Red Densa: %.2f%%\n', accuracyDense*100);
fprintf('Precisión Red CNN: %.2f%%\n', accuracyCNN*100);


%% 5. Clasificación de Cifras "Caseras"
folderPath = 'MisDigitos'; 

if ~exist(folderPath, 'dir')
    error('No se encuentra la carpeta "MisDigitos" en el directorio actual.');
end

imageFiles = dir(fullfile(folderPath, '*.png')); 

if isempty(imageFiles)
    warning('La carpeta "MisDigitos" está vacía.');
    return;
end

figure('Color', 'w', 'Name', 'Resultados de Clasificación: CNN vs Densa');

for i = 1:length(imageFiles)
    % 1. Leer y convertir a escala de grises
    imgFull = imread(fullfile(folderPath, imageFiles(i).name));
    if size(imgFull, 3) == 3, imgGray = rgb2gray(imgFull); else, imgGray = imgFull; end

    % 2. Binarizar e invertir
    imgBW = imbinarize(imgGray, 'adaptive', 'ForegroundPolarity', 'dark');
    imgBW = imcomplement(imgBW);

    % 3. Centrado
    [fila, col] = find(imgBW);
    if ~isempty(fila)
        imgCrop = imgBW(min(fila):max(fila), min(col):max(col));
        imgFinal = padarray(imgCrop, [5 5], 0, 'both');
        imgFinal = imresize(imgFinal, [28 28]);
    else
        imgFinal = zeros(28, 28);
    end
    imgFinal = reshape(double(imgFinal), 28, 28, 1);

    % 4. Inferencia
    labelCNN = classify(netCNN, imgFinal);
    labelDense = classify(netDense, imgFinal);

    % 5. Visualización 
    subplot(ceil(length(imageFiles)/5), 5, i);
    imshow(imgFull);

    [~, fileNameOnly] = fileparts(imageFiles(i).name);
    numero = regexp(fileNameOnly, '\d+', 'match'); 
    if ~isempty(numero)
        titulo = ['P.' numero{1}];
    else
        titulo = fileNameOnly;
    end

    title(titulo, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel(sprintf('CNN: %s\nDensa: %s', char(labelCNN), char(labelDense)), ...
        'FontSize', 8, 'Interpreter', 'none');
end
