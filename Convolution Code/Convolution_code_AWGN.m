clear; clc;

% Simulation Parameters
constraintLength = 7;            % Constraint length
codeGenerator = [133 171];       % Octal generator polynomials 
tracebackDepth = 32;             % Viterbi traceback depth 
modOrder = 64;                   % 64-QAM modulation
numBits = 1000*log2(modOrder);   % Number of input bits
SNR = 0:0.5:20;                  % Signal-to-noise ratio range (dB)
EbN0 = SNR + 10*log10(modOrder); % Convert SNR to Eb/N0 for BPSK
L_SNR = length(SNR);             % Number of SNR points
maxF = 1e3;                      % Maximum number of frames

ber1 = zeros(1, L_SNR); % BER for uncoded system
ber2 = zeros(1, L_SNR); % BER for coded system 

while (jj < maxF && num1 < 1000) 

inputBits = randi([0 1], numBits, 1); % Generate random binary data 

% Convolutional Encoding 
trellis = poly2trellis(constraintLength, codeGenerator);
encodedBits = convenc(inputBits, trellis);

% 64-QAM Modulation (with bit input & unit average power)
txSig = qammod(encodedBits, modOrder, 'InputType', 'bit', 'UnitAveragePower', true);

% Add AWGN noise
rxSig = awgn(txSig, EbN0+10*log10(1/2), 'measured');

% Hard-Decision QAM Demodulation (output as bits)
rxDataHard = qamdemod(rxSig, modOrder, 'OutputType', 'bit', 'UnitAveragePower', true);

% Viterbi Decoding (continuous mode, hard-decision)
decodedBits = vitdec(rxDataHard, trellis, tracebackDepth, 'cont', 'hard');

% Calculate Bit Errors (skip last 'tbl' bits due to decoding delay)
numErrors = biterr(inputBits(1:end-tracebackDepth), decodedBits(tracebackDepth+1:end));
ber = numErrors / jj;
end

% Display Results
fprintf('Bit Error Rate (BER): %.4f\n', ber);
fprintf('Number of Errors: %d\n', numErrors);