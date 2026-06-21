%% PROBLEMA 3: Clasificación de Reseñas de Películas
clear all; clc; close all;

%% 1. CARGA DE LA BASE DE DATOS
fprintf('--- 1. CARGANDO RECURSOS ---\n');
load('BBDD_resenas.mat'); 
fprintf('Base de datos cargada: %d reseñas\n', numel(bd))

% Extraer textos, etiquetas y puntuaciones originales
TextStrings = {bd(:).text};
scores_raw = [bd(:).score]; 
labels = categorical(1 + [bd(:).label]); % 1=Negativa (0 en bd), 2=Positiva (1 en bd)

fprintf('Total reseñas: %d | Positivas: %d | Negativas: %d\n', ...
    numel(labels), sum(labels == '2'), sum(labels == '1'))

%% 2. PREPROCESAMIENTO DE TEXTOS

fprintf('\n--- 2. PREPROCESAMIENTO ---\n');

% Recortar reseñas largas (>500 caracteres) para agilizar
maxLength = 500;
for k = 1:numel(TextStrings)
    dum = TextStrings{k};
    TextStrings{k} = dum(1:min(maxLength, numel(dum)));
end

% Tokenizar
tok_org = tokenizedDocument(TextStrings');

% Limpieza
cleanToks = lower(tok_org);
commonWords = ["br", "><", "movie", "film"]; 
cleanToks = removeWords(cleanToks, commonWords);
cleanToks = removeStopWords(cleanToks); 
cleanToks = erasePunctuation(cleanToks);
cleanToks = removeShortWords(cleanToks, 2); 
cleanToks = normalizeWords(cleanToks, 'Style', 'lemma'); 

% Nubes de palabras
figure('color', 'w', 'Name', 'Nube: Antes vs Después')
subplot(1,2,1); wordcloud(tok_org); title('Original');
subplot(1,2,2); wordcloud(cleanToks); title('Limpio (Lematizado)');

%% 3. VECTORIZACIÓN: WORD EMBEDDING 
% Cargar el modelo preentrenado
fprintf('\nCargando modelo externo .vec (puede tardar varios minutos)...\n')
emb = readWordEmbedding('wiki-news-300d-1M.vec.zip'); 
fprintf('Modelo cargado. Dimensión del embedding: %d\n', emb.Dimension)

% Convertir reseñas a secuencias de vectores
maxTokens = 100;
fprintf('Vectorizando reseñas (maxTokens = %d)...\n', maxTokens)
sequences = doc2sequence(emb, cleanToks, 'Length', maxTokens);

%% 4. CONJUNTOS DE APRENDIZAJE Y TEST
fprintf('\n--- 3. PARTICIÓN DE DATOS ---\n');
rng(2026); % Semilla para reproducibilidad
M = numel(sequences);
r = randperm(M);

% Mezclamos todo simultáneamente (X, Etiquetas y Scores para análisis)
X_shuffled = sequences(r);
L_shuffled = labels(r);
S_shuffled = scores_raw(r); 

p = 0.8; 
nmax = round(p * M);


% Partición principal
Xtrain_full = X_shuffled(1:nmax); 
Ltrain_full = L_shuffled(1:nmax);
Xtest = X_shuffled(nmax+1:end);   
Ltest = L_shuffled(nmax+1:end);
scores_test = S_shuffled(nmax+1:end); % Solo para el análisis de errores

% Separar validación del conjunto de entrenamiento (10%)
nval = round(0.1 * numel(Xtrain_full));
Xval = Xtrain_full(1:nval);     Lval = Ltrain_full(1:nval);
Xtr  = Xtrain_full(nval+1:end); Ltr  = Ltrain_full(nval+1:end);

fprintf('Conjunto Train: %d | Validación: %d | Test: %d\n', numel(Xtr), numel(Xval), numel(Xtest))

%% 5. ENTRENAMIENTO DE LA RED 
fprintf('\n--- 4. ENTRENAMIENTO (RED PROFUNDA) ---\n');

layers = [ ...
    sequenceInputLayer(emb.Dimension)
    convolution1dLayer(5, 128, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    convolution1dLayer(3, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    globalMaxPooling1dLayer
    dropoutLayer(0.4)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.0005, ...
    'ValidationData', {Xval, Lval}, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

net = trainNetwork(Xtr, Ltr, layers, options);

%% 6. ANÁLISIS DE RESULTADOS Y ERRORES

fprintf('\n--- 5. GENERANDO ANÁLISIS GRÁFICO ---\n');

Lnet_test = classify(net, Xtest);
Lnet_test = Lnet_test(:); Ltest = Ltest(:); scores_test = scores_test(:);

idx_wrong = (Lnet_test ~= Ltest);
idx_correct = (Lnet_test == Ltest);

% --- Histogramas ---
edges = 0.5:1:10.5;
figure('color', 'w', 'Name', 'Análisis de Errores');
sgtitle('Distribución de Errores según Puntuación Real');
subplot(1,3,1); histogram(scores_test, edges, 'Normalization', 'probability'); title('Todas (Test)'); grid on;
subplot(1,3,2); if any(idx_wrong); histogram(scores_test(idx_wrong), edges, 'Normalization', 'probability', 'FaceColor', [0.9 0.3 0.3]); end; title('Mal clasificadas'); grid on;
subplot(1,3,3); if any(idx_correct); histogram(scores_test(idx_correct), edges, 'Normalization', 'probability', 'FaceColor', [0.3 0.8 0.4]); end; title('Bien clasificadas'); grid on;

% --- Ejemplos ---
num_idx_wrong = find(idx_wrong);
num_idx_correct = find(idx_correct);

fprintf('\n--- Ejemplo mal clasificado ---\n')
if ~isempty(num_idx_wrong)
    k = num_idx_wrong(1);
    orig_idx = r(nmax + k); 
    fprintf('Score real: %d | Pred: %s\n', scores_test(k), char(Lnet_test(k)))
    fprintf('Texto:\n%s\n', TextStrings{orig_idx}(1:min(350,end)))
end

fprintf('\n--- Ejemplo bien clasificado ---\n')
if ~isempty(num_idx_correct)
    k = num_idx_correct(1); % Tomamos el primer acierto encontrado
    
    orig_idx = r(nmax + k);
    
    fprintf('Puntuación real del usuario: %d\n', scores_test(k))
    fprintf('Clase real:     %s\n', char(Ltest(k)))
    fprintf('Predicción red: %s\n', char(Lnet_test(k)))
    fprintf('Texto (primeros 300 chars):\n%s\n', TextStrings{orig_idx}(1:min(300,end)))
end



%% 7. RESUMEN FINAL
Lnet_train = classify(net, Xtr);
acc_train = mean(Lnet_train(:) == Ltr(:));
acc_test  = mean(Lnet_test(:) == Ltest(:));

fprintf('\n========================================\n')
fprintf('    RESUMEN FINAL - PROBLEMA 3 (NLP)\n')
fprintf('========================================\n')
fprintf('  Precisión Train:    %.2f%%\n', 100 * acc_train)
fprintf('  Precisión Test:     %.2f%%\n', 100 * acc_test)
fprintf('========================================\n')