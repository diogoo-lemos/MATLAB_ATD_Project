% -------------------------------------------------------
% #1 Importação dos sinais de áudio
% -------------------------------------------------------

% Definição do path e lista de ficheiros wav
folder_path = 'C:\Users\35191\Desktop\data\01\';
files = dir(fullfile(folder_path, '*.wav'));

% Inicialização de uma cell para guardar importar os ficheiros
num_files = length(files);
allAudio = cell(1, num_files);

% Inicialização da tabela para armazenar informações
audioInfo = table('Size', [num_files, 13], ...
    'VariableTypes', {'string', 'string', 'string', 'string', 'double', 'double', 'cell', 'cell', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Directory', 'FileName', 'Participant', 'Digit', 'Repetition', 'SampleRate', 'OriginalSignal', 'ProcessedSignal', 'MaxAmplitude', 'TotalEnergy', 'StdDeviation', 'Duration', 'MeanAmplitude'});

% Loop para importação dos ficheiros wav
for i = 1:num_files
    file_path = fullfile(folder_path, files(i).name);
    [data, fs] = audioread(file_path);
    allAudio{i} = data;
    
    % Extrair informações do nome do arquivo
    fileInfo = split(files(i).name, '_');
    participant = fileInfo{1};
    digit = fileInfo{2};
    repetition = str2double(regexp(fileInfo{3}, '\d+', 'match'));
    
    % Pré-processamento do sinal
    processedData = normalizeAmplitude(data);
    processedData = removeSilence(processedData);
    processedData = adjustDuration(processedData, fs, 0.4);
    
    % Cálculo das métricas
    maxAmp = max(abs(data)); % Amplitude máxima
    totalEner = sum(processedData.^2); % Energia total
    stdDev = std(processedData); % Desvio padrão
    duration = length(data) / fs; % Duração do sinal
    meanAmp = mean(abs(processedData)); % Amplitude média
    
    % Armazenar informações na tabela
    audioInfo.Directory(i) = folder_path;
    audioInfo.FileName(i) = files(i).name;
    audioInfo.Participant(i) = participant;
    audioInfo.Digit(i) = digit;
    audioInfo.Repetition(i) = repetition;
    audioInfo.SampleRate(i) = fs;
    audioInfo.OriginalSignal{i} = data; % Sinal original
    audioInfo.ProcessedSignal{i} = processedData; % Sinal processado
    audioInfo.MaxAmplitude(i) = maxAmp; % Amplitude máxima
    audioInfo.TotalEnergy(i) = totalEner; % Energia total
    audioInfo.StdDeviation(i) = stdDev; % Desvio padrão
    audioInfo.Duration(i) = duration; % Duração do sinal
    audioInfo.MeanAmplitude(i) = meanAmp; % Amplitude média
end

% -------------------------------------------------------
% #2 Exemplos de gráficos para os sinais importados
% -------------------------------------------------------

% Indices para os sinais a serem representados
fileIndices = [2, 50, 100, 150, 200, 250, 300, 350, 400, 450];

figure;

% Loop que percorre os sinais e representa-os gráficamente
for i = 1:10
    currentData = audioInfo.ProcessedSignal{fileIndices(i)};
    subplot(5, 2, i);
    plot(currentData);
    title(num2str(i-1));
    xlabel('Time[s]');
end

% -------------------------------------------------------
% #3 Características temporais dos sinais
% -------------------------------------------------------

% Energia Total
totalEnergy = zeros(50, 10);

for i = 1:10
    for j = 1:50    
        totalEnergy(j, i) = sum(allAudio{(i * j)}.^2);
    end
end

% Amplitude máxima e desvio padrão
maxAmplitude = zeros(50, 10);
stdDeviation = zeros(1, 10);

for i = 1:10
    for j = 1:50
        audioData = allAudio{i * j};
        maxAmplitude(j, i) = max(abs(audioData));
    end
    stdDeviation(i) = std(maxAmplitude(:, i));
end

% Duração do sinal
signalDuration = zeros(50, 10); % Inicialização da matriz para armazenar a duração dos sinais
for i = 1:10
    for j = 1:50
        signalDuration(j, i) = audioInfo.Duration((i - 1) * 50 + j); % Extrai a duração do sinal
    end
end

% Amplitude média
meanAmplitude = zeros(50, 10); % Inicialização da matriz para armazenar a amplitude média
for i = 1:10
    for j = 1:50
        meanAmplitude(j, i) = audioInfo.MeanAmplitude((i - 1) * 50 + j); % Extrai a amplitude média
    end
end

% -------------------------------------------------------
% #4 Representação gráfica das características
% -------------------------------------------------------

% Energia Total
figure;
boxplot(totalEnergy, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Energia Total');
xlabel('Digitos');
title('Boxplot da Energia Total por Dígito');

% Amplitude máxima
figure;
boxplot(maxAmplitude, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Amplitude Máxima');
xlabel('Dígitos');
title('Boxplot da Amplitude Máxima por Dígito');

% Desvio padrão
figure;
bar(0:9, stdDeviation);
xlabel('Dígitos');
ylabel('Desvio Padrão da Amplitude Máxima');
title('Desvio Padrão da Amplitude Máxima por Dígito');

% Duração do sinal
figure;
boxplot(signalDuration, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Duração do Sinal (s)');
xlabel('Dígitos');
title('Boxplot da Duração do Sinal por Dígito');

% Amplitude média
figure;
boxplot(meanAmplitude, 'Labels', {'0','1','2','3','4','5','6','7','8','9'});
ylabel('Amplitude Média');
xlabel('Dígitos');
title('Boxplot da Amplitude Média por Dígito');

% -------------------------------------------------------
% #5 Remover sinais de áudio e salvar estrutura de dados
% -------------------------------------------------------

% Criar uma nova tabela sem as colunas de sinais de áudio
audioInfoWithoutSignals = removevars(audioInfo, {'OriginalSignal', 'ProcessedSignal'});

% Salvar a estrutura de dados em um arquivo .mat
save('audioInfo.mat', 'audioInfoWithoutSignals');

% -------------------------------------------------------
% #6 Funções auxiliares
% -------------------------------------------------------
% Função para remover silêncio inicial
function data = removeSilence(data)
    energy = data.^2;
    threshold = 0.01 * max(energy); % Ajuste o threshold conforme necessário
    startIdx = find(energy > threshold, 1);
    if isempty(startIdx)
        startIdx = 1;
    end
    data = data(startIdx:end);
end

% Função para normalizar a amplitude
function data = normalizeAmplitude(data)
    data = data / max(abs(data));
end

% Função para ajustar a duração do sinal
function data = adjustDuration(data, fs, targetDuration)
    currentDuration = length(data) / fs;
    if currentDuration < targetDuration
        % Adicionar silêncio no final
        silenceDuration = targetDuration - currentDuration;
        silenceSamples = round(silenceDuration * fs);
        data = [data; zeros(silenceSamples, 1)];
    elseif currentDuration > targetDuration
        % Cortar o sinal
        targetSamples = round(targetDuration * fs);
        data = data(1:targetSamples);
    end
end