function WdB = gene_Middle_Ear_Transfer_Function(FreqVector)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Transfert function of midle ear. 
% According to ANSI S3.4-2007, Table 3.
% Values at intermediate frequencies are interpolated.
%
% USE:
%   WdB = gene_Middle_Ear_Transfer_Function(FreqVector)
%
% INPUT:
%   FreqVector: Signal frequency vector
%
% OUTPUT:
%   WedB: Middle ear effective attenuation, dB
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Freq_ref = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 ...
            4000 5000 6000 6300 8000 9000 10000 11200 12500 14000 15000 16000 18000 20000];

W_ref = -[39.6 32 25.85 21.4 18.5 15.9 14.1 12.4 11 9.6 8.3 7.4 6.2 4.8 3.8 3.3 2.9 2.6 2.6 4.5 5.4 6.1 8.5 10.4 7.3 7 ...
            6.6 7 9.2 10.2 12.2 10.8 10.1 12.7 15 18.2 23.8 32.3 45.5 50];

if FreqVector(end) > Freq_ref(end),
    Freq_ref(end) = FreqVector(end);
end;

WdB = interp1(Freq_ref, W_ref, FreqVector, 'cubic');

Index20000 = find(FreqVector >= 20000);

if ~isempty(Index20000),
    WdB(Index20000) = W_ref(end);
end;
