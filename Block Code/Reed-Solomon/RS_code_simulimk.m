RS_TsUncoded = 1; % Sample time (s)
RS_n = 63; % Codeword length
RS_k = 53; % Message length
RS_MQAM = 64; % QAM order
RS_numBitsPerSymbol = log2(RS_MQAM); % 6 bits per symbol
RS_sigPower = 42; % Assume points at +/-1, +/-3, +/-5, +/-7
RS_EbNoUncoded = 13;
ber=yout{1}.Values.Data;
fprintf("The BER for 64 QAM is: %f \n",ber(end,1));