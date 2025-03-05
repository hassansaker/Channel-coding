clear ; clc;
SNR = 0:0.5:16; % Signal-to-noise ratio (dB)
L_SNR=length(SNR);
maxF = 1e5; 
m = 3;
k = (2^m)-m-1;  % Message length
n = (2^m)-1;    % Codeword length
Len = k * 1000; % Number of data bits per frame
ber1 = zeros(1, L_SNR); 
ber2 = zeros(1, L_SNR); 

for ii = 1:L_SNR
    num1 = 0; % Number of errors (coded)
    num2 = 0; % Number of errors (uncoded)
    
    jj = 1;
    pp = 1;
    
    % Uncoded Transmission
    while (jj < maxF && num1 < 1000)
        
        %-----------------Transmitter---------------------
        data = randi([0 1], 1, Len);
        t1 = 2 * data - 1; % BPSK modulation
        
        %----------------Channel---------------------
        r1 = awgn(t1, SNR(ii)+10*log10(2)); % Adding noise
        
        %-----------------Receiver----------------------
        bb1 = r1 > 0; % Demodulation
        num1 = num1 + biterr(bb1, data);
        jj = jj + 1;
    end
    
    % Coded Transmission
    while (pp < maxF && num2 < 1000)
        
        %-----------------Transmitter---------------------
        data = randi([0 1], 1, Len);
        encData = encode(data', n, k, 'hamming/binary')';
        t2 = 2 * encData - 1; % BPSK modulation
        
        %----------------Channel---------------------
        r2 = awgn(t2, SNR(ii) +10*log10(2)+ 10*log10(k/n)); % Adding noise
        
        %-----------------Receiver----------------------
        bb2 = r2 > 0; % Demodulation
        decData = decode(bb2, n, k, 'hamming/binary')';
        num2 = num2 + biterr(decData', data);
        pp = pp + 1;
        
    end
    
    ber1(ii) = num1 / pp / Len;
    ber2(ii) = num2 / jj / Len;
end

figure; 
semilogy(SNR, ber1, 'r-s', 'LineWidth', 2);
hold on;
semilogy(SNR, ber2, 'g-s', 'LineWidth', 2);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('BER Performance: Coded vs Uncoded BPSK');
legend('Uncoded','Coded');

