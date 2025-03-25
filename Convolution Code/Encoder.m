clear; clc;

% Simulation Parameters
constraintLength = 7;          % Constraint length (K=7)
codeGenerator = [133 171];     % Octal generator polynomials (G1=133, G2=171)
tracebackDepth = 7;            % Viterbi traceback depth (5*(K-1) is typical)
snrdB = 15;                    % SNR in dB (adjust for testing)
modOrder = 64;                 % 64-QAM modulation
numBits = 1000*log2(modOrder); % Number of input bits
SNR = 0:0.5:20;                % Signal-to-noise ratio range (dB)
EbN0 = SNR + 10*log10(2);      % Convert SNR to Eb/N0 for BPSK
L_SNR = length(SNR);           % Number of SNR points
maxF = 1e3;                    % Maximum number of frames

Len = k * 1000; % Number of data bits per frame
ber1 = zeros(1, L_SNR); % BER for uncoded system
ber2 = zeros(1, L_SNR); % BER for coded system without interleaving


% Generate random binary data (column vector)
inputBits = randi([0 1], numBits, 1);

% Convolutional Encoding (adds termination tail automatically)
trellis = poly2trellis(constraintLength, codeGenerator);
encodedBits = convenc(inputBits, trellis);

% 64-QAM Modulation (with bit input & unit average power)
txSig = qammod(encodedBits, modOrder, 'InputType', 'bit', 'UnitAveragePower', true);

% Add AWGN noise
rxSig = awgn(txSig, snrdB, 'measured');

% Hard-Decision QAM Demodulation (output as bits)
rxDataHard = qamdemod(rxSig, modOrder, 'OutputType', 'bit', 'UnitAveragePower', true);

% Viterbi Decoding (continuous mode, hard-decision)
decodedBits = vitdec(rxDataHard, trellis, tracebackDepth, 'cont', 'hard');

% Calculate Bit Errors (skip last 'tbl' bits due to decoding delay)
numErrors = biterr(inputBits(1:end-tracebackDepth), decodedBits(tracebackDepth+1:end));
ber = numErrors / (numBits - tracebackDepth);

% Display Results
fprintf('Bit Error Rate (BER): %.4f\n', ber);
fprintf('Number of Errors: %d\n', numErrors);