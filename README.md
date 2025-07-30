# Audio Digit Recognition Project
## Project Description
This project aims to identify English digits (0-9) through audio signal analysis using digital signal processing and machine learning techniques. The system extracts temporal, frequency, and time-frequency features to classify spoken digits.

### Dataset
AudioMNIST: 60 participants, 50 repetitions per digit (500 files/participant)

Format: .wav mono, 48 kHz sampling rate

Source: Kaggle Dataset

## Code Structure
The project is organized into 4 main milestones:


### Milestone 1: Preprocessing and Temporal Features
File: ATF2025.m

- Audio import and data organization

- Preprocessing:

  - Initial silence removal

  - Amplitude normalization

  - Duration standardization

  - Temporal feature extraction:

  - Total energy

  - Max/mean amplitude

  - Standard deviation

  - Signal duration

#### Generated Plots:

- Time Domain Signals: Visualization of preprocessed audio signals

- Total Energy Boxplot: Energy distribution per digit

- Max Amplitude Boxplot: Amplitude variation per digit

- Standard Deviation Bar Chart: Dispersion comparison across digits

- Signal Duration Boxplot: Duration distribution per digit


### Milestone 2: Frequency Domain Analysis
File: ATD2025_2.m

- Fourier Transform calculation

- Median spectra with quartiles (Q25/Q75)

- Spectral feature extraction:

- Spectral peak amplitude/frequency

- Spectral centroid

- Spectral Edge Frequency (SEF75)

- Spectral skewness

#### Generated Plots:

- Median Spectra: Digit comparison with quartiles

- Spectral Feature Boxplots: Distribution of 5 spectral features

- 3D Scatter Plot: Spectral centroid vs SEF75 vs skewness


### Milestone 3: Classification
File: ATD2025_3.m

Minimum Distance classifier using:

- Temporal features (energy, mean amplitude, std deviation)

- Spectral features (peak frequency, centroid, SEF75)

- Accuracy calculation

#### Output:

- Classification accuracy percentage


### Milestone 4: Time-Frequency Analysis
File: ATD2025_4.m

- STFT (Short-Time Fourier Transform):

  - Parameterization with Hamming windows (256/512/1024 samples)

  - Spectrogram visualization

  - Time-frequency feature extraction:

  - Mean frequency

  - Max energy frequency

  - Bandwidth

  - Spectral flux

  - Energy entropy

- DWT (Discrete Wavelet Transform):

  - 'db4' wavelet decomposition (4 levels)

  - Energy distribution in detail/approximation coefficients

#### Generated Plots:

- Spectrograms: Time-frequency representations for each digit

- Time-Frequency Feature Boxplots: Distribution of 5 features

- 3D Feature Scatter: Optimal features for digit discrimination

- DWT Energy Distribution: Energy by decomposition level

### Execution Instructions
1. Clone repository:

git clone https://github.com/seu-usuario/audio-digit-recognition.git

2. Download AudioMNIST dataset

3. Extract into data/ directory

4. Run scripts sequentially:

  -ATF2025.m    → Milestone 1
  -ATD2025_2.m  → Milestone 2
  -ATD2025_3.m  → Milestone 3
  -ATD2025_4.m  → Milestone 4

### Dependencies
MATLAB (R2020a or newer)

Required Toolboxes:

  - Signal Processing Toolbox

  - Wavelet Toolbox

### Expected Results
- Preprocessed audio signals

- Feature visualizations (temporal/spectral/time-frequency)

- Digit classification accuracy report

- Comparative analysis of STFT vs DWT

## Contribution Guidelines
Contributions are welcome! Please open issues for suggestions or submit pull requests for improvements.
