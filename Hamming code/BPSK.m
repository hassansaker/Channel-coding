clear ; clc;
SNR = 0:0.5:12; % Signal-to-noise ratio (dB)
maxF = 1e4; 
m = 3;
k = (2^m)-m-1;  % Message length
n = (2^m)-1;    % Codeword length
[h, g] = hammgen(m); 
M = length(SNR);
Len = k * 1000; % Number of data bits per frame
ber1 = zeros(1, M); 
ber2 = zeros(1, M); 

for ii = 1:M
    num1 = 0; % Number of errors (coded)
    num2 = 0; % Number of errors (uncoded)
    
    jj = 1;
    pp = 1;
    
    % Uncoded Transmission
    while (jj < maxF && num2 < 1000)
        
        %-----------------Transmitter---------------------
        data = randi([0 1], 1, Len);
        t2 = 2 * data - 1; % BPSK modulation
        
        %----------------Channel---------------------
        r2 = awgn(t2, SNR(ii)+10*log10(2)); % Adding noise
        
        %-----------------Receiver----------------------
        bb2 = r2 > 0; % Demodulation
        num2 = num2 + biterr(bb2, data);
        jj = jj + 1;
    end
    
    % Coded Transmission
    while (pp < maxF && num1 < 1000)
        
        %-----------------Transmitter---------------------
        data = randi([0 1], 1, Len);
        encData = encode(data', n, k, 'hamming/binary')';
        t1 = 2 * encData - 1; % BPSK modulation
        
        %----------------Channel---------------------
        r1 = awgn(t1, SNR(ii) +10*log10(2)+ 10*log10(k/n)); % Adding noise
        
        %-----------------Receiver----------------------
        bb1 = r1 > 0; % Demodulation
        decData = decode(bb1, n, k, 'hamming/binary')';
        num1 = num1 + biterr(decData', data);
        pp = pp + 1;
        
    end
    
    ber1(ii) = num1 / pp / Len;
    ber2(ii) = num2 / jj / Len;
end

figure(1); 
semilogy(SNR, ber1, 'r', 'LineWidth', 2);
hold on;
semilogy(SNR, ber2, 'g', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('BER Performance: Coded vs Uncoded BPSK');
legend('Coded', 'Uncoded');
