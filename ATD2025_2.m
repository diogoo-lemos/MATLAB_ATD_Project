%% Carregar a estrutura de dados da meta 1
audioInfo = load("audioInfo.mat").audioInfo;

%% Calculo dos coeficientes da série complexa de Fourier
for i = 1:height(audioInfo)
    % Carregar o arquivo .wav
    filePath = fullfile(audioInfo.Directory{i}, audioInfo.FileName{i});
    [sinal, fs] = audioread(filePath); % Carrega o sinal e a taxa de amostragem
    
    % Calcular a FFT e normalizar
    N = length(sinal);
    coef = fft(sinal)/N; % Coeficientes normalizados
    
    % Armazenar na estrutura
    audioInfo.CoeficientesFourier{i} = coef;
end

% Inicializar
digitList = unique(str2double(audioInfo.Participant));
maxLength = 0;

% Determinar comprimento máximo do espectro positivo
for i = 1:height(audioInfo)
    N = length(audioInfo.CoeficientesFourier{i});
    posFreqLength = floor(N/2) + 1;
    if posFreqLength > maxLength
        maxLength = posFreqLength;
    end
end

% Mapear espectros por dígito
espectrosPorDigito = containers.Map('KeyType','double','ValueType','any');
for d = digitList'
    espectrosPorDigito(d) = [];
end

% Preencher os espectros
for i = 1:height(audioInfo)
    coef = audioInfo.CoeficientesFourier{i};
    N = length(coef);
    mag = abs(coef(1:floor(N/2)+1)); % frequências positivas
    mag = mag(:)'; % linha
    mag(end+1:maxLength) = 0; % zero-padding
    d = str2double(audioInfo.Participant(i));
    espectrosPorDigito(d) = [espectrosPorDigito(d); mag];
end

%% Cálculo do espectro mediano e quantis
espectrosMedianos = containers.Map('KeyType','double','ValueType','any');
espectrosQ1 = containers.Map('KeyType','double','ValueType','any');
espectrosQ3 = containers.Map('KeyType','double','ValueType','any');

for d = digitList'
    allSpecs = espectrosPorDigito(d);
    espectrosMedianos(d) = median(allSpecs, 1);
    quantis = quantile(allSpecs, [0.25, 0.75], 1);
    espectrosQ1(d) = quantis(1, :);
    espectrosQ3(d) = quantis(2, :);
end

fs = 48000; % taxa de amostragem (se todos os sinais forem iguais)

N = (maxLength - 1) * 2; % Reverter floor(N/2)+1 => N
f = linspace(0, fs/2, maxLength); % eixo de frequência real em Hz

figure;
tiledlayout(5,2);
for idx = 1:length(digitList)
    d = digitList(idx);
    nexttile;

    % Plot com eixo X em Hz
    plot(f, espectrosMedianos(d), 'Color', [0.4 0.6 0.8], 'LineWidth', 1.5); hold on;
    plot(f, espectrosQ1(d), '--', 'Color', [0.85 0.7 0.9]);
    plot(f, espectrosQ3(d), '--', 'Color', [0.9 0.7 0.5]);

    title(sprintf('Dígito %d', d));
    xlabel('Frequência (Hz)');
    ylabel('Amplitude');
    xlim([0 8000]);
    
    legend({'Median', 'Q25', 'Q75'}, 'Location', 'northeast');
end
sgtitle('Espectros de Amplitude Medianos por Dígito');
set(gcf, 'Color', 'w');

%% Extração de características
% Alocação para os máximos espectrais
audioInfo.MaxSpectralAmplitude = zeros(height(audioInfo),1);
audioInfo.MaxSpectralFreq      = zeros(height(audioInfo),1);
% Alocação para média espectral
audioInfo.SpectralCentroid = zeros(height(audioInfo), 1);
% Alocação para spectral edge frequency (75%)
audioInfo.SEF75 = zeros(height(audioInfo), 1);
% Alocação para spectral skewness
audioInfo.SpectralSkewness = zeros(height(audioInfo), 1);

for i = 1:height(audioInfo)
    coef = audioInfo.CoeficientesFourier{i};
    N = length(coef);
    mag = abs(coef(1:floor(N/2)+1));
    f = (0:floor(N/2)) * (fs / N);

    % Máximos espectrais (posição e amplitude)
    [ampMax, idxMax] = max(mag);
    freqMax = f(idxMax);

    audioInfo.MaxSpectralAmplitude(i) = ampMax;
    audioInfo.MaxSpectralFreq(i) = freqMax;
    
    % Média espectral
    if sum(mag) == 0
        centroid = 0;
    else
        centroid = sum(f .* mag') / sum(mag);
    end

    audioInfo.SpectralCentroid(i) = centroid;
    
    % SEF
    % Energia acumulada normalizada
    energiaTotal = sum(mag);
    energiaAcumulada = cumsum(mag) / energiaTotal;

    % Encontrar índice onde a energia acumulada atinge 75%
    idxSEF = find(energiaAcumulada >= 0.75, 1);
    sefFreq = f(idxSEF);

    audioInfo.SEF75(i) = sefFreq;
    
    % Spectral Skewness
    % Centroide e média ponderada
    if sum(mag) == 0
        skewness_val = 0;
    else
        centroid = sum(f .* mag') / sum(mag);
        spread = sqrt(sum(((f - centroid).^2) .* mag') / sum(mag));  % desvio padrão espectral

        if spread == 0
            skewness_val = 0;
        else
            skewness_val = sum(((f - centroid).^3) .* mag') / (sum(mag) * (spread^3));
        end
    end

    audioInfo.SpectralSkewness(i) = skewness_val;
end

% Lista de dígitos
digitos = str2double(audioInfo.Participant);

%% 1. Boxplot da Amplitude Máxima Espectral
figure;
boxplot(audioInfo.MaxSpectralAmplitude, digitos, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Amplitude Máxima Espectral');
xlabel('Dígitos');
title('Boxplot da Amplitude Máxima Espectral por Dígito');
set(gcf, 'Color', 'w');

%% 2. Boxplot da Frequência do Pico Espectral
figure;
boxplot(audioInfo.MaxSpectralFreq, digitos, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Frequência do Pico (Hz)');
xlabel('Dígitos');
title('Boxplot da Frequência do Pico Espectral por Dígito');
set(gcf, 'Color', 'w');

%% 3. Boxplot do Centroide Espectral
figure;
boxplot(audioInfo.SpectralCentroid, digitos, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Centroide Espectral (Hz)');
xlabel('Dígitos');
title('Boxplot do Centroide Espectral por Dígito');
set(gcf, 'Color', 'w');

%% 4. Boxplot do SEF75
figure;
boxplot(audioInfo.SEF75, digitos, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('SEF75 (Hz)');
xlabel('Dígitos');
title('Boxplot da Spectral Edge Frequency 75% por Dígito');
set(gcf, 'Color', 'w');

%% 5. Boxplot da Assimetria Espectral (Skewness)
figure;
boxplot(audioInfo.SpectralSkewness, digitos, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Skewness Espectral');
xlabel('Dígitos');
title('Boxplot da Assimetria Espectral por Dígito');
set(gcf, 'Color', 'w');

%% Scatter
X = audioInfo.SpectralCentroid;
Y = audioInfo.SEF75;
Z = audioInfo.SpectralSkewness;

digits = str2double(audioInfo.Participant);
digits = digits(:);

coresScatter = [
    0.1, 0.1, 0.8;   % azul escuro
    0.2, 0.6, 1.0;   % azul claro
    0.0, 0.7, 0.2;   % verde
    0.9, 0.6, 0.0;   % laranja
    1.0, 0.0, 0.0;   % vermelho
    0.8, 0.0, 0.6;   % magenta
    0.6, 0.4, 0.8;   % roxo claro
    0.4, 0.4, 0.4;   % dcinzento
    0.0, 0.8, 0.8;   % turquesa
    0.8, 0.8, 0.0    % amarelo
];

figure;
hold on;
for d = 0:9
    idx = digits == d;

    scatter3(X(idx), Y(idx), Z(idx), 36, ...
        'o', ...
        'MarkerEdgeColor', coresScatter(d+1, :), ...
        'MarkerFaceColor', 'none', ...
        'DisplayName', sprintf('Dígito %d', d));
end
hold off;

xlabel('Centroide Espectral (Hz)');
ylabel('SEF75 (Hz)');
zlabel('Skewness Espectral');
title('Scatter 3D com Cores Manuais por Dígito');
legend('Location', 'bestoutside');
grid on;
set(gcf, 'Color', 'w');
view(-30, 20);

% Salvar a estrutura de dados em um arquivo .mat
save('audioInfo.mat', 'audioInfo');