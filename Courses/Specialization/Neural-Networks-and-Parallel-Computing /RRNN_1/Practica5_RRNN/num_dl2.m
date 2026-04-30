% Cargar los datos de entrenamiento
[XTrain, YTrain] = digitTrain4DArrayData; % Im´agenes 28x28x1xN y etiquetas
% Definir la arquitectura de la red
layers = [
imageInputLayer([28 28 1]) % Capa de entrada para im´agenes en gris
fullyConnectedLayer(100) % Capa densa con 100 neuronas
reluLayer % Activacion ReLU
fullyConnectedLayer(10) % 10 neuronas (una por d´ıgito)
softmaxLayer % Convertir a probabilidades
classificationLayer % Capa de salida para clasificaci´on
];
% Opciones de entrenamiento
options = trainingOptions('sgdm','MaxEpochs',20, 'Verbose',false, 'Plots','training-progress', 'ExecutionEnvironment', 'gpu');
% Entrenar la red
net = trainNetwork(XTrain, YTrain, layers, options);


%Comprobar la red con una imagen
% Cargar datos de prueba
[XTest, YTest] = digitTest4DArrayData;
% Probar con una imagen concreta (por ejemplo, la n´umero 42)
img = XTest(:, :, :, 8);
trueLabel = YTest(42);
% Clasificar la imagen con la red entrenada
predictedLabel = classify(net, img);
% Mostrar la imagen y resultado
imshow(img);
title(['Etiqueta real: ', char(trueLabel), '/ Predición: ', char(predictedLabel)]);