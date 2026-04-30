%% PRACTICA 5: RRNN 

baseFolder = 'colores';
classNames = {'rojo','verde','azul','amarillo','negro','blanco'};

if ~exist(baseFolder, 'dir')
    mkdir(baseFolder);
end

for k = 1:length(classNames)
    % Usamos fullfile para compatibilidad de rutas
    if ~exist(fullfile(baseFolder, classNames{k}), 'dir')
        mkdir(fullfile(baseFolder, classNames{k}));
    end
end

imgSize = [32 32 3];
numImages = 100; 
colors = { 
    'rojo', [255 0 0]; 
    'verde', [0 255 0]; 
    'azul', [0 0 255]; 
    'amarillo', [255 255 0];
    'negro', [0 0 0]; 
    'blanco', [255 255 255]
};

% --- Generación de imágenes con perturbaciones ---
for c = 1:size(colors,1)
    folderName = fullfile(baseFolder, colors{c,1});
    colorBase = colors{c,2};
    
    for i = 1:numImages
        tonoGeneral = randi([-30, 30], 1, 3);
        img = ones(imgSize, 'uint8');
        r = max(0, min(255, colorBase(1) + tonoGeneral(1)));
        g = max(0, min(255, colorBase(2) + tonoGeneral(2)));
        b = max(0, min(255, colorBase(3) + tonoGeneral(3)));
        
        img(:,:,1) = r; img(:,:,2) = g; img(:,:,3) = b;
        

        ruidoPixel = randi([-80, 80], imgSize); 
        img = uint8(double(img) + ruidoPixel); 
        
        filename = fullfile(folderName, sprintf('%s_%03d.png', colors{c,1}, i));
        imwrite(img, filename);
    end
end

% --- Carga y preparación de datos ---
imds = imageDatastore(baseFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames'); 
[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8, 'randomized');

inputSize = [32 32 3]; 
augTrain = augmentedImageDatastore(inputSize, imdsTrain); 
augTest = augmentedImageDatastore(inputSize, imdsTest);


numClasses = numel(categories(imds.Labels));
layers = [
    imageInputLayer(inputSize, 'Normalization','rescale-zero-one')

    convolution2dLayer(3, 8, 'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride',2)

    convolution2dLayer(3, 16, 'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride',2)

    fullyConnectedLayer(32)
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
];

% --- Entrenamiento con medición de tiempo ---
options = trainingOptions('sgdm', 'MaxEpochs', 5, 'MiniBatchSize', 16, ...
                          'ExecutionEnvironment', 'cpu', ...
                          'Verbose', false, 'Plots', 'training-progress'); 

fprintf('Iniciando entrenamiento...\n');
tic; 
net = trainNetwork(augTrain, layers, options); 
tiempoEntrenamiento = toc;  

% --- Evaluación ---
YPred = classify(net, augTest); 
accuracy = mean(YPred == imdsTest.Labels);

fprintf('\n--- RESULTADOS FINALIZADOS ---\n');
fprintf('Precisión (Accuracy): %.2f%%\n', accuracy * 100); 
fprintf('Tiempo de entrenamiento: %.2f segundos\n', tiempoEntrenamiento); 