%% Preparación de Datos
imds = imageDatastore('./cifar5','IncludeSubfolders',true,'LabelSource','foldernames'); 

uLabels = unique(imds.Labels);
nCls =numel(uLabels); 

Im = readall(imds); 

%% Red neuronal 
Dense_layers = [... 
        imageInputLayer([32,32,3]); 
        
        fullyConnectedLayer(1000); 
        reluLayer;
        dropoutLayer(0.2);
        
        fullyConnectedLayer(512);
        reluLayer;
        dropoutLayer(0.2);

        fullyConnectedLayer(256);
        reluLayer;
        
        fullyConnectedLayer(nCls);
        softmaxLayer; 
        classificationLayer]; 

%% Entrenamiento y test
nTrain = 3000; 
[trainData, testData] = imds.splitEachLabel(nTrain, 'randomized'); 
options = trainingOptions('sgdm', 'InitialLearnRate', 0.00002, 'MaxEpochs', 15); 
net = trainNetwork(trainData, Dense_layers, options); 
labelTest = classify(net, testData); 
Accuracy = mean(labelTest == testData.Labels); 
disp(['Clasification accuracy test = ' num2str(100*Accuracy,3) '%'])

%% Clasificación de Gatos 
imdsC = imageDatastore('./Cats'); 
archivos = imdsC.Files;         
numCats = numel(archivos);
numCols = 4; 
numRows = ceil(numCats / numCols); 

figure('Name', 'Clasificación de Gatos', 'Color', 'w');
for i = 1:numCats
    img = readimage(imdsC, i);
    imgResized = imresize(img, [32 32]);
    [label, ~] = classify(net, imgResized);
    
    subplot(numRows, numCols, i);
    imshow(img);
    title(['Pred: ' char(label)], 'FontSize', 10);
    axis off
end

