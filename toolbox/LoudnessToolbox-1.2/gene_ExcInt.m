function ExcIntdB = gene_ExcInt(FreqVector)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USE:
%   ExcIntdB = gene_ExcInt(FreqVector)
%
% FUNCTION:
%   Returns (at given input frequencies) the internal excitation level at
%   threshold for monaural listening (in dB).
%   According to norm ANSI S3.4-2007, table 4.
%
% INPUT:
%   FreqVector: vector of frequencies in Hz
%
% OUTPUT:
%   ExcIntdB: internal excitation level at trhreshold for FreqVector
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Freq_ref = [50 63 80 100 125 160 200 250 315 400 500 630 750 800 1000];

ExcIntdB_ref = [28.18 23.9 19.2 15.68 12.67 10.09 8.08 6.3 5.3 4.5 3.73 3.73 3.73 3.73 3.73];

if max(FreqVector) > max(Freq_ref),
    Freq_ref(end) = max(FreqVector);
end;

ExcIntdB = interp1(Freq_ref, ExcIntdB_ref, FreqVector, 'cubic');