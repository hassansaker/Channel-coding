%% 
% Rayleigh Fading channel
clear; clc;
SNR = 0:0.5:16; % Signal-to-noise ratio (dB)
L_SNR = length(SNR);
maxF = 1e5; 
m = 3;
k = (2^m) - m - 1;  % Message length
n = (2^m) - 1;      % Codeword length
Len = k * 1000;     % Number of data bits per frame
ber1 = zeros(1, L_SNR); 
ber2 = zeros(1, L_SNR); 

% Define Rayleigh Channel
fs = 8*Len; % Sampling rate (adjustable)
pathDelays = [0 200 800 1200 2300 3700] * 1e-9; % sec
avgPathGains = [0 -3 -4.9 -8 -7.8 -23.9]; % dB
fD = 50; % Doppler shift in Hz
rayleighChan = comm.RayleighChannel( ...
    'SampleRate', fs, ...
    'PathDelays', pathDelays, ...
    'AveragePathGains', avgPathGains, ...
    'MaximumDopplerShift', fD);

for ii = 1:length(SNR)
    num1 = 0; % Number of errors (coded)
    num2 = 0; % Number of errors (uncoded)
    
    jj = 1;
    pp = 1;
    
    % Uncoded Transmission
    while (jj < maxF && num1 < 1000)
        data = randi([0 1], Len, 1);
        t1 = 2 * data - 1; % BPSK modulation
        
        % Pass through Rayleigh Channel
        h_ray = rayleighChan(ones(length(t1), 1));
        hh=abs(h_ray);
        fadedSignal = hh .* t1;
        
        % Add AWGN
        r1 = awgn(fadedSignal, SNR(ii)+3);
        
        % Demodulation
        bb1 = r1 > 0;
        num1 = num1 + biterr(bb1, data);
        jj = jj + 1;
    end
    
    % Coded Transmission
    while (pp < maxF && num2 < 1000)
        data = randi([0 1], Len, 1);
        encData = encode(data, n, k, 'hamming/binary'); % Encoding
        
        t2 = 2 * encData - 1; % BPSK modulation
        
        % Pass through Rayleigh Channel
        h_ray = rayleighChan(ones(length(t2), 1)); 
        hh=abs(h_ray);
        fadedSignal = hh .* t2;
        
        % Add AWGN
        r2 = awgn(fadedSignal, SNR(ii) + 10*log10(k/n)+3);
        
        % Demodulation
        bb2 = r2 > 0;
        decData = decode(bb2, n, k, 'hamming/binary'); % Decoding
        
        num2 = num2 + biterr(decData, data);
        pp = pp + 1;
    end
    
    ber1(ii) = num1 / jj / Len; % Coded BER
    ber2(ii) = num2 / pp / Len; % Uncoded BER
end

% Plot Results
figure; 
semilogy(SNR, ber1, 'r-*', 'LineWidth', 1.5,'MarkerSize',8);
hold on;
semilogy(SNR, ber2, 'g-h', 'LineWidth', 1.5,'MarkerSize',8);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('BER Performance: Coded vs Uncoded BPSK in Rayleigh Channel');
legend('Uncoded','Coded');
