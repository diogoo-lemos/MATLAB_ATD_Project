%% Carregar a estrutura de dados da meta 1
audioInfo = load("audioInfo.mat").audioInfo;

%% EXERCÍCIO 17 - Classificação dos dígitos com Minimum Distance

% Features selecionadas (ajusta se usarem outras)
X = [audioInfo.TotalEnergy, ...
     audioInfo.MeanAmplitude, ...
     audioInfo.StdDeviation, ...
     audioInfo.MaxSpectralFreq, ...
     audioInfo.SpectralCentroid, ...
     audioInfo.SEF75];

% Rótulos verdadeiros
y_true = str2double(audioInfo.Participant);

% Dígitos únicos (0 a 9)
unique_digits = unique(y_true);

% Calcular centróides (média das features por dígito)
centroids = zeros(length(unique_digits), size(X,2));
for i = 1:length(unique_digits)
    idx = y_true == unique_digits(i);
    centroids(i,:) = mean(X(idx,:), 1);
end

% Classificação: distância euclidiana a cada centróide
y_pred = zeros(size(y_true));
for i = 1:size(X,1)
    dists = vecnorm(centroids - X(i,:), 2, 2); % distâncias
    [~, minIdx] = min(dists); % índice do centróide mais próximo
    y_pred(i) = unique_digits(minIdx);
end

% Guardar classificação na estrutura
audioInfo.PredictedDigit = y_pred;

% (Exercício 18) Percentagem de acertos
accuracy = sum(y_pred == y_true) / length(y_true) * 100;
fprintf('Percentagem de acertos: %.2f%%\n', accuracy);