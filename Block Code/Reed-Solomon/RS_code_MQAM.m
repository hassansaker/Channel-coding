clear; close all;
M = 16;                  % Modulation order
bps = log2(M);           % Bits per symbol for modulation
N = 127;                 % RS codeword length
K = 111;                 % RS message length
m=log2(N+1);             % bits per symbol in reed-solomon
gp = rsgenpoly(N,K,[],0);% Generator polynomial
numBits=bps*K*m*5;       % Number of input bits
rate=K/N;                % Code rate
maxF=1e4;                % Maximum number of frames

awgnChannel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)');
errorRate = comm.ErrorRate;
rsEncoder = comm.RSEncoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
rsDecoder = comm.RSDecoder('BitInput',true,'CodewordLength',N,'MessageLength',K);

EbNo =0:0.5:10;
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
    % M-QAM Modulation 
    txSig_uncoded = qammod(inputBits, M, 'InputType', 'bit', 'UnitAveragePower', true);
    
    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig_uncoded = awgnChannel(txSig_uncoded);              
    
    %-----------------Receiver------------------------
    % M-QAM Demodulation 
    rxData = qamdemod(rxSig_uncoded, M, 'OutputType', 'bit', 'UnitAveragePower', true);
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
    % M-QAM Modulation 
    txSig_coded = qammod(encData, M, 'InputType', 'bit', 'UnitAveragePower', true);

    %----------------Channel--------------------------
    % Add AWGN noise
    rxSig_coded = awgnChannel(txSig_coded); 
    
    %-----------------Receiver------------------------
    % M-QAM Demodulation
    rxData = qamdemod(rxSig_coded, M, 'OutputType', 'bit', 'UnitAveragePower', true);
    % RS decode
    decData = rsDecoder(rxData);
    % Calculate Bit Errors 
    err_num = errorRate(inputBits, decData);
    numErrors_coded =numErrors_coded+err_num(2);
    jj=jj+1;
    reset(errorRate);
    end
    ber1(i) = numErrors_uncoded / pp /numBits;
    ber2(i) = numErrors_coded / jj /numBits;

end

ber1=berfit(EbNo,ber1);
ber2=berfit(EbNo,ber2);
figure;
semilogy(EbNo, ber1, 'r-*', 'LineWidth', 1.5, 'MarkerSize', 8); % Uncoded
hold on;
semilogy(EbNo, ber2, 'g-h', 'LineWidth', 1.5, 'MarkerSize', 8); % Coded 
grid on;
xlabel('Eb/N0 (dB)');
ylabel('BER');
title(['BER Performance: Coded vs Uncoded ',num2str(M),'-QAM in AWGN Channel']);
legend('Uncoded', 'Coded');