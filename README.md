#Projeto de Análise e Transformação de Dados - Identificação de Dígitos por Áudio
##Descrição do Projeto
Este projeto visa identificar dígitos (0-9) em inglês através da análise de sinais de áudio, utilizando técnicas de processamento digital de sinal e aprendizado de máquina. O sistema extrai características nos domínios temporal, frequencial e tempo-frequência para classificar dígitos falados.

###Dataset
AudioMNIST: 60 participantes, 50 repetições por dígito (500 arquivos/participante)

##Formato: .wav mono, taxa de amostragem de 48 kHz

Origem: Kaggle Dataset

##Estrutura do Código
O projeto está organizado em 4 metas principais:

###Meta 1: Pré-processamento e Características Temporais
Arquivo: ATF2025.m

Importação e organização dos áudios em estrutura de dados

Pré-processamento:

Remoção de silêncio inicial

Normalização de amplitude

Uniformização da duração

Extração de características temporais:

Energia total

Amplitude máxima/média

Desvio padrão

Duração do sinal

Gráficos Gerados:

Sinais no Domínio do Tempo: Visualização dos sinais de áudio após pré-processamento

Boxplot de Energia Total: Distribuição da energia por dígito

Boxplot de Amplitude Máxima: Variação da amplitude máxima por dígito

Desvio Padrão: Variação entre dígitos

Duração do Sinal: Comparação da duração média por dígito

###Meta 2: Análise em Frequência
Arquivo: ATD2025_2.m

Cálculo da Transformada de Fourier

Espectros medianos e quartis (Q25/Q75)

Extração de características espectrais:

Amplitude e frequência do pico espectral

Centróide espectral

Spectral Edge Frequency (SEF75)

Assimetria espectral (Skewness)

Gráficos Gerados:

Espectros Medianos: Comparação entre dígitos com quartis

Boxplots Características Espectrais: Distribuição das 5 características por dígito

Scatter 3D: Dispersão entre centróide, SEF75 e skewness

###Meta 3: Classificação
Arquivo: ATD2025_3.m

Classificador "Minimum Distance" usando:

Características temporais (energia, amplitude média, desvio padrão)

Características espectrais (frequência do pico, centróide, SEF75)

Cálculo de acurácia

Saída:

Percentagem de acertos na classificação

###Meta 4: Análise Tempo-Frequência
Arquivo: ATD2025_4.m

STFT (Short-Time Fourier Transform):

Parametrização com diferentes janelas (Hamming 256/512/1024)

Visualização de espectrogramas

Extração de características tempo-frequência:

Frequência média

Frequência de máxima energia

Largura de banda

Fluxo espectral

Entropia de energia

DWT (Discrete Wavelet Transform):

Decomposição com wavelet 'db4' (4 níveis)

Energia nos coeficientes de detalhe/aproximação

Gráficos Gerados:

Espectrogramas: Para cada dígito (0-9)

Boxplots Características TF: Distribuição das 5 características

Scatter 3D: Melhores características para discriminação

Energia DWT: Distribuição energética por nível de decomposição

##Como Executar
Clone o repositório:

git clone https://github.com/seu-usuario/audio-digit-recognition.git

Baixe o dataset AudioMNIST

Extraia na pasta data/

Execute os scripts em ordem:

text
ATF2025.m    -> Meta 1
ATD2025_2.m  -> Meta 2
ATD2025_3.m  -> Meta 3
ATD2025_4.m  -> Meta 4

##Dependências
MATLAB (versão R2020a ou superior)

##Toolboxes:

Signal Processing Toolbox

Wavelet Toolbox

##Resultados Esperados
Pré-processamento de sinais de áudio

Visualizações de características temporais/espaciais

Classificação de dígitos com acurácia reportada

Análise comparativa STFT vs DWT
