%% 21. Carregar estrutura de dados anterior
audioInfo = load("audioInfo.mat").audioInfo;

%% 22. Calcular a STFT para cada dígito com diferentes parametrizações
janelaOpts = {hamming(256), hamming(512), hamming(1024)};
sobreposicaoOpts = [0.25, 0.5, 0.75];
nfftOpts = [512, 1024, 2048];

% Armazenar espectrogramas por dígito
audioInfo.Spectrograms = cell(height(audioInfo), 1);

for i = 1:height(audioInfo)
    filePath = fullfile(audioInfo.Directory{i}, audioInfo.FileName{i});
    [sinal, fs] = audioread(filePath);
    
    janela = hamming(512);
    sobreposicao = round(0.5 * length(janela));
    nfft = 1024;
    
    [S, F, T, P] = spectrogram(sinal, janela, sobreposicao, nfft, fs, 'yaxis');
    
    audioInfo.Spectrograms{i} = struct( ...
        'S', S, ...
        'F', F, ...
        'T', T, ...
        'P', P ...
    );
end

% Exemplo gráfico de STFT para os dígitos 0 a 9
digitos = unique(str2double(audioInfo.Participant));
figure;
tiledlayout(5,2);
for d = 0:9
    idx = find(str2double(audioInfo.Participant) == d, 1);
    if ~isempty(idx)
        spec = audioInfo.Spectrograms{idx};
        nexttile;
        imagesc(spec.T, spec.F, 10*log10(spec.P));
        axis xy;
        title(sprintf('Dígito %d', d));
        xlabel('Tempo (s)');
        ylabel('Frequência (Hz)');
        colormap jet;
    end
end
sgtitle('STFT para dígitos 0–9 (exemplos)');

%% 23. Extração de 5 características de tempo-frequência
audioInfo.MeanFreq       = zeros(height(audioInfo), 1);
audioInfo.MaxFreq        = zeros(height(audioInfo), 1);
audioInfo.Bandwidth      = zeros(height(audioInfo), 1);
audioInfo.SpectralFlux   = zeros(height(audioInfo), 1);
audioInfo.EnergyEntropy  = zeros(height(audioInfo), 1);

for i = 1:height(audioInfo)
    P = audioInfo.Spectrograms{i}.P;
    F = audioInfo.Spectrograms{i}.F;
    
    % Normalizar
    Pnorm = P ./ max(P(:));
    
    % 1. Frequência Média ao longo do tempo
    meanFreq = mean(sum(F .* Pnorm ./ sum(Pnorm), 1));
    
    % 2. Frequência com máxima energia média
    [~, maxIdx] = max(mean(Pnorm, 2));
    maxFreq = F(maxIdx);
    
    % 3. Largura de banda média
    bandWidth = mean(std(Pnorm, 0, 1));
    
    % 4. Spectral Flux (diferença entre frames)
    flux = mean(sum((diff(Pnorm,1,2)).^2,1));
    
    % 5. Entropia da energia
    normP = P ./ sum(P);
    entropy = -sum(normP .* log(normP + eps), 'all') / numel(P);
    
    audioInfo.MeanFreq(i) = meanFreq;
    audioInfo.MaxFreq(i) = maxFreq;
    audioInfo.Bandwidth(i) = bandWidth;
    audioInfo.SpectralFlux(i) = flux;
    audioInfo.EnergyEntropy(i) = entropy;
end

%% 24. Análise gráfica das características
% Extrair apenas as colunas de interesse como uma nova tabela
featuresTable = table( ...
    audioInfo.MeanFreq, ...
    audioInfo.MaxFreq, ...
    audioInfo.Bandwidth, ...
    audioInfo.SpectralFlux, ...
    audioInfo.EnergyEntropy, ...
    'VariableNames', {'MeanFreq', 'MaxFreq', 'Bandwidth', 'SpectralFlux', 'EnergyEntropy'} ...
);
digitos = str2double(audioInfo.Participant);

% Converter para arrays
vars = featuresTable.Properties.VariableNames;
for v = 1:numel(vars)
    figure;
    boxplot(featuresTable.(vars{v}), digitos, 'Labels', string(0:9));
    title(sprintf('Boxplot de %s por Dígito', vars{v}));
    xlabel('Dígito');
    ylabel(vars{v});
    set(gcf, 'Color', 'w');
end

% Escolha visual de 3 melhores (exemplo)
selectedFeatures = {'MeanFreq', 'MaxFreq', 'EnergyEntropy'};
X = featuresTable.(selectedFeatures{1});
Y = featuresTable.(selectedFeatures{2});
Z = featuresTable.(selectedFeatures{3});

figure;
scatter3(X, Y, Z, 36, digitos, 'filled');
xlabel(selectedFeatures{1});
ylabel(selectedFeatures{2});
zlabel(selectedFeatures{3});
title('Scatter 3D das 3 Melhores Características');
grid on;
set(gcf, 'Color', 'w');

%% 25. Aplicar DWT para cada sinal
waveletType = 'db4';
nivel = 4;

audioInfo.DWT_Energy = zeros(height(audioInfo), nivel+1); % A + D1..D4

for i = 1:height(audioInfo)
    filePath = fullfile(audioInfo.Directory{i}, audioInfo.FileName{i});
    [sinal, ~] = audioread(filePath);
    
    [C, L] = wavedec(sinal, nivel, waveletType);
    
    % Extrair coeficientes de aproximação e detalhe
    energiaTotal = 0;
    for n = 1:nivel
        D = detcoef(C, L, n);
        audioInfo.DWT_Energy(i,n) = sum(D.^2);
        energiaTotal = energiaTotal + sum(D.^2);
    end
    A = appcoef(C, L, waveletType, nivel);
    audioInfo.DWT_Energy(i,nivel+1) = sum(A.^2);
    energiaTotal = energiaTotal + sum(A.^2);
    
    % Normalizar energia
    audioInfo.DWT_Energy(i,:) = audioInfo.DWT_Energy(i,:) / energiaTotal;
end

% Gráfico de barras de energia média por dígito
figure;
meanEnergy = zeros(10, nivel+1);
for d = 0:9
    idx = str2double(audioInfo.Participant) == d;
    meanEnergy(d+1, :) = mean(audioInfo.DWT_Energy(idx, :), 1);
end

bar(meanEnergy, 'stacked');
legend(["D1","D2","D3","D4","A4"]);
xlabel('Dígito');
ylabel('Energia Normalizada');
title('Distribuição da Energia por DWT para Cada Dígito');
xticklabels(string(0:9));
set(gcf, 'Color', 'w');

%% 26. Guardar a estrutura atualizada
save("audioInfo.mat", "audioInfo");
