clear; close all;
M = 4;                   % Modulation order
bps = log2(M);           % Bits per symbol for modulation
N = 7;                   % RS codeword length
K = 5;                   % RS message length
m=log2(N+1);             % bits per symbol in reed-solomon
gp = rsgenpoly(N,K,[],0);% Generator polynomial
numBits=bps*K*m*100;     % Number of input bits
rate=K/N;                % Code rate
maxF=1e3;                % Maximum number of frames
pskModulator = comm.PSKModulator(M,'BitInput',true,'SymbolMapping','Gray','PhaseOffset',0);
pskDemodulator = comm.PSKDemodulator(M,'BitOutput',true,'SymbolMapping','Gray','PhaseOffset',0);
awgnChannel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)');
errorRate = comm.ErrorRate;
rsEncoder = comm.RSEncoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
rsDecoder = comm.RSDecoder('BitInput',true,'CodewordLength',N,'MessageLength',K);

EbNo =0:0.5:8;
SNR = EbNo + 10*log10(bps); % Account for RS coding gain
ber1 = zeros(size(SNR)); % BER for uncoded system
ber2 =zeros(size(SNR)); % BER for coded system 

for i=1:length(SNR)
jj=1;
pp=1;
numErrors_coded=0;
numErrors_uncoded=0;
awgnChannel.SNR = SNR(i);
    while (pp < maxF && numErrors_uncoded <1000)

    %-----------------Transmitter---------------------
    inputBits = randi([0 1], numBits, 1); % Generate random binary data
    % 4PSK Modulation 
    txSig_uncoded = pskModulator(inputBits);
    
    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig_uncoded = awgnChannel(txSig_uncoded);              
    
    %-----------------Receiver------------------------
    % 4PSK Demodulation 
    rxData = pskDemodulator(rxSig_uncoded);            
    % Calculate Bit Errors 
    err_num = errorRate(inputBits, rxData);
    numErrors_uncoded =numErrors_uncoded+err_num(2);
    pp=pp+1;  
    reset(errorRate);
    end
awgnChannel.SNR = SNR(i)+10*log10(rate);    
    while (jj < maxF && numErrors_coded < 1000) 

    %-----------------Transmitter---------------------
    inputBits = randi([0 1], numBits, 1); % Generate random binary data 
    % RS encode
    encData = rsEncoder(inputBits);                 
    % 4PSK Modulation 
    txSig_coded = pskModulator(encData);

    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig = awgnChannel(txSig_coded); 
    
    %-----------------Receiver------------------------
    % Demodulate
    rxData = pskDemodulator(rxSig);            
    % RS decode
    decData = rsDecoder(rxData);            
    err_num = errorRate(inputBits, decData);
    numErrors_coded =numErrors_coded+err_num(2);
    jj=jj+1;
    reset(errorRate);
    end
    ber1(i) = numErrors_uncoded / pp /numBits;
    ber2(i) = numErrors_coded / jj /numBits;

end

figure;
semilogy(EbNo, ber1, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 8); % Uncoded
hold on;
semilogy(EbNo, ber2, 'g-h', 'LineWidth', 1.5, 'MarkerSize', 8); % Coded 
grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title('BER Performance: Coded vs Uncoded 4PSK in AWGN Channel');
legend('Uncoded', 'Coded');