# BPSK Modulation with Hamming Code
This repository contains a MATLAB script that compares the performance of BPSK modulation with and without Hamming coding in terms of Bit Error Rate (BER) over a range of Signal-to-Noise Ratios (SNR).

## Overview
The script simulates both coded and uncoded BPSK transmission over an AWGN channel. It uses Hamming codes for error correction in the coded scenario. The BER performance is plotted against SNR for both cases.

## Key Features
- **BPSK Modulation**: Both coded and uncoded BPSK modulation schemes are implemented.
- **Hamming Coding**: Hamming codes are used for error correction in the coded scenario.
- **AWGN Channel**: Simulates transmission over an Additive White Gaussian Noise (AWGN) channel.
- **BER Performance**: Plots BER against SNR for both coded and uncoded scenarios.

## Requirements
- MATLAB with Communications Toolbox (for `awgn`, `encode`, and `decode` functions).

## Usage
1. Clone the repository.
2. Open MATLAB and navigate to the cloned repository.
3. Run the provided MATLAB script.
4. The script will generate a plot comparing the BER performance of coded and uncoded BPSK over a range of SNR values.

## Parameters
- **SNR Range**: 0 dB to 12 dB with a step of 0.5 dB.
- **Message Length (k)**: Calculated based on the Hamming code parameters.
- **Codeword Length (n)**: Calculated based on the Hamming code parameters.
- **Number of Data Bits per Frame**: 1000 times the message length.
- **Maximum Frames**: 100,000.

## Plot Description
The plot displays the BER performance of both coded and uncoded BPSK modulation schemes. The x-axis represents the SNR in dB, and the y-axis represents the BER. The red line corresponds to the coded scenario, and the green line corresponds to the uncoded scenario.

## Contributing
Contributions are welcome! Feel free to modify or extend the script to explore different scenarios or parameters.

