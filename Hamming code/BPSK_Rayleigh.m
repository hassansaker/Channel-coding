% Rayleigh Fading Channel Simulation with Hamming Coding and Interleaving
clear; clc;

% Simulation Parameters
SNR = 0:0.5:20; % Signal-to-noise ratio range (dB)
EbN0 = SNR + 10*log10(2); % Convert SNR to Eb/N0 for BPSK
L_SNR = length(SNR); % Number of SNR points
maxF = 1e3; % Maximum number of frames
m = 3; % Number of parity bits for Hamming code
k = (2^m) - m - 1; % Message length
n = (2^m) - 1; % Codeword length
Len = k * 1000; % Number of data bits per frame
ber1 = zeros(1, L_SNR); % BER for uncoded system
ber2 = zeros(1, L_SNR); % BER for coded system without interleaving
ber3 = zeros(1, L_SNR); % BER for coded system with interleaving

% Define Rayleigh Fading Channel
fs = 8 * Len; % Sampling rate (adjustable)
pathDelays = [0 200 800 1200 2300 3700] * 1e-9; % Path delays in seconds
avgPathGains = [0 -3 -4.9 -8 -7.8 -23.9]; % Average path gains in dB
fD = 50; % Maximum Doppler shift in Hz
rayleighChan = comm.RayleighChannel( ...
    'SampleRate', fs, ...
    'PathDelays', pathDelays, ...
    'AveragePathGains', avgPathGains, ...
    'MaximumDopplerShift', fD);

% Simulation Loop
for ii = 1:L_SNR
    num1 = 0; % Error counter for uncoded system
    num2 = 0; % Error counter for coded system without interleaving
    num3 = 0; % Error counter for coded system with interleaving
    jj = 1; % Frame counter for uncoded system
    pp = 1; % Frame counter for coded system without interleaving
    kk = 1; % Frame counter for coded system with interleaving

    % Uncoded Transmission
    while (jj < maxF && num1 < 1000)
        %-----------------Transmitter---------------------
        data = randi([0 1], Len, 1); % Generate random data bits
        t1 = 2 * data - 1; % BPSK modulation (0 -> -1, 1 -> +1)

        %----------------Channel--------------------------
        h_ray = rayleighChan(ones(length(t1), 1)); % Rayleigh fading coefficients
        hh = abs(h_ray); % Magnitude of fading coefficients
        fadedSignal = hh .* t1; % Apply fading
        fadedSignal = fadedSignal / sqrt(mean(abs(fadedSignal).^2)); % Normalize signal power
        r1 = awgn(fadedSignal, EbN0(ii)); % Add AWGN noise

        %-----------------Receiver------------------------
        bb1 = r1 > 0; % Demodulation (BPSK)
        num1 = num1 + biterr(bb1, data); % Count bit errors
        jj = jj + 1; % Increment frame counter
    end

    % Coded Transmission without Interleaving
    while (pp < maxF && num2 < 1000)
        %-----------------Transmitter---------------------
        data = randi([0 1], Len, 1); % Generate random data bits
        encData = encode(data, n, k, 'hamming/binary'); % Hamming encoding
        t2 = 2 * encData - 1; % BPSK modulation

        %----------------Channel--------------------------
        h_ray = rayleighChan(ones(length(t2), 1)); % Rayleigh fading coefficients
        hh = abs(h_ray); % Magnitude of fading coefficients
        fadedSignal = hh .* t2; % Apply fading
        fadedSignal = fadedSignal / sqrt(mean(abs(fadedSignal).^2)); % Normalize signal power
        r2 = awgn(fadedSignal, EbN0(ii) + 10*log10(k/n)); % Add AWGN noise

        %-----------------Receiver----------------------
        bb2 = double(r2 > 0); % Demodulation (BPSK)
        decData = decode(bb2, n, k, 'hamming/binary'); % Hamming decoding
        num2 = num2 + biterr(decData, data); % Count bit errors
        pp = pp + 1; % Increment frame counter
    end

    % Coded Transmission with Interleaving
    while (kk < maxF && num3 < 1000)
        %-----------------Transmitter---------------------
        data = randi([0 1], Len, 1); % Generate random data bits
        encData = encode(data, n, k, 'hamming/binary'); % Hamming encoding
        t3 = 2 * encData - 1; % BPSK modulation
        p = randperm(length(t3)); % Permutation vector for interleaving
        interleavedData = intrlv(t3, p); % Interleave encoded data

        %----------------Channel--------------------------
        h_ray = rayleighChan(ones(length(t3), 1)); % Rayleigh fading coefficients
        hh = abs(h_ray); % Magnitude of fading coefficients
        fadedSignal = hh .* interleavedData; % Apply fading
        fadedSignal = fadedSignal / sqrt(mean(abs(fadedSignal).^2)); % Normalize signal power
        r3 = awgn(fadedSignal, EbN0(ii) + 10*log10(k/n)); % Add AWGN noise

        %-----------------Receiver----------------------
        bb3 = double(r3 > 0); % Demodulation (BPSK)
        bb3 = deintrlv(bb3, p); % Deinterleave to restore original order
        decData = decode(bb3, n, k, 'hamming/binary'); % Hamming decoding
        num3 = num3 + biterr(decData, data); % Count bit errors
        kk = kk + 1; % Increment frame counter
    end

    % Calculate BER for each case
    ber1(ii) = num1 / (jj * Len); % Uncoded BER
    ber2(ii) = num2 / (pp * Len); % Coded BER without interleaving
    ber3(ii) = num3 / (kk * Len); % Coded BER with interleaving
end

% Plot Results
figure;
semilogy(SNR, ber1, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 8); % Uncoded
hold on;
semilogy(SNR, ber2, 'g-h', 'LineWidth', 1.5, 'MarkerSize', 8); % Coded without interleaving
hold on;
semilogy(SNR, ber3, 'c-s', 'LineWidth', 1.5, 'MarkerSize', 8); % Coded with interleaving
grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title('BER Performance: Coded vs Uncoded BPSK in Rayleigh Fading Channel');
legend('Uncoded', 'Coded without Interleaving', 'Coded with Interleaving');