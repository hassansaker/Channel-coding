# Convolutional Coding Simulation in AWGN Channel

This MATLAB project simulates the performance of convolutionally encoded and uncoded communication systems in an Additive White Gaussian Noise (AWGN) channel. The simulations compare Bit Error Rate (BER) performance for:

- **M-PSK Modulation**
- **M-QAM Modulation**

## 📜 Overview

The project consists of two MATLAB scripts:

1. **Convolution_code_AWGN_PSK.m**: Simulates convolutionally coded and uncoded M-PSK transmission over an AWGN channel.
2. **Convolution_code_AWGN_QAM.m**: Simulates convolutionally coded and uncoded M-QAM transmission over an AWGN channel.

Both scripts use **Viterbi decoding** for error correction.

## 📌 Features

- Convolutional encoding with different constraint lengths and generator polynomials.
- Viterbi decoding with traceback depth.
- Modulation using PSK and QAM schemes.
- AWGN noise addition.
- BER calculation and performance comparison between coded and uncoded transmission.

## 🛠 Installation & Usage

1. Clone this repository or download the files.
2. Open MATLAB and navigate to the directory containing the scripts.
3. Run either script:

   ```matlab
   run('Convolution_code_AWGN_PSK.m')
