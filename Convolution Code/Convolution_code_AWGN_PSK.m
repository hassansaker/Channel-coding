clear; clc;

% Simulation Parameters
constraintLength = 3;                  % Constraint length
codeGenerator = [7 5];                 % Octal generator polynomials 
tracebackDepth = 16;                   % Viterbi traceback depth 
M = 4;                                 % BPSK modulation
numBits =1000*M;                       % Number of input bits
EbN0 = 0:0.5:10;                       % Signal-to-noise ratio range (dB)
SNR= EbN0 + 10*log10(log2(M));         % Convert SNR to Eb/N0 for BPSK
L_SNR = length(SNR);                   % Number of SNR points
maxF =1e4;                             % Maximum number of frames
pskModulator = comm.PSKModulator(M,'BitInput',true,'SymbolMapping','Gray','PhaseOffset',0);
pskDemodulator = comm.PSKDemodulator(M,'BitOutput',true,'SymbolMapping','Gray','PhaseOffset',0);
ber1 = zeros(1, L_SNR); % BER for uncoded system
ber2 =zeros(1, L_SNR); % BER for coded system 

for i=1:L_SNR
jj=1;
pp=1;
numErrors_coded=0;
numErrors_uncoded=0;

    while (pp < maxF && numErrors_uncoded < 1000)

    %-----------------Transmitter---------------------
    inputBits = randi([0 1], numBits, 1); % Generate random binary data
    % M-PSK Modulation (with bit input & unit average power)
    txSig_uncoded =pskModulator(inputBits);
    % constellation(pskModulator); % see the constellation
    
    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig_uncoded = awgn(txSig_uncoded,SNR(i),'measured');
    
    %-----------------Receiver------------------------
    % M-PSK Demodulation (output as bits)
    rxDataHard_uncoded = pskDemodulator(rxSig_uncoded);
    % Calculate Bit Errors 
    numErrors_uncoded =numErrors_uncoded+ biterr(inputBits,rxDataHard_uncoded );
    pp=pp+1;  
    
    end
    
    while (jj < maxF && numErrors_coded < 1000) 

    %-----------------Transmitter---------------------
    inputBits = randi([0 1], numBits, 1); % Generate random binary data 

    % Convolutional Encoding 
    trellis = poly2trellis(constraintLength, codeGenerator);
    encodedBits = convenc(inputBits, trellis);
    
    % M-PSK Modulation (with bit input & unit average power)
    txSig_coded =pskModulator(encodedBits);

    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig_coded = awgn(txSig_coded,SNR(i)+10*log10(0.5),'measured');
    
    %-----------------Receiver------------------------
    % Hard-Decision M-PSK Demodulation (output as bits)
    rxDataHard_coded = pskDemodulator(rxSig_coded);
    % Viterbi Decoding (continuous mode, hard-decision)
    decodedBits = vitdec(rxDataHard_coded, trellis, tracebackDepth, 'cont', 'hard');
    % Calculate Bit Errors (skip last 'tbl' bits due to decoding delay)
    numErrors_coded =numErrors_coded+ biterr(inputBits(1:end-tracebackDepth), decodedBits(tracebackDepth+1:end));
    jj=jj+1;
    
    end
    ber1(i) = numErrors_uncoded / pp / numBits;
    ber2(i) = numErrors_coded / jj / numBits;

end
% Plot Results
figure;
semilogy(EbN0, ber1, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 8); % Uncoded
hold on;
semilogy(EbN0, ber2, 'g-h', 'LineWidth', 1.5, 'MarkerSize', 8); % Coded 
grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER Performance: Coded vs Uncoded ',num2str(M),'-PSK in AWGN Channel']);
legend('Uncoded', 'Coded');