function WextdB = gene_Transfer_function_to_eardrum(FreqVector, field_type)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Free field to eardrum transfert function (frontal incidence).
% Source: ANSI S3.4-2007 Table 1
% Values at intermediate frequencies are interpolated
%
% USE:
%   WextdB = gene_Transfer_function_to_eardrum(FreqVector, field_type)
%
% INPUT:
%   FreqVector: Signal frequency vector 
%   field_type: Type of listenig (0: free field (default) or 1: diffuse field)
%
% OUTPUT:
%   WextdB: Level at eardrum minus free-field or difuse-field level, dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2,
    field_type = 0;
end;

if field_type ~= 1 && field_type ~= 0
        error('Field type (0=free,1=diffuse)');
end

Freq = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 750 800 1000 1250 1500 ...
        1600 2000 2500 3000 3150 4000 5000 6000 6300 8000 9000 10000 11200 12500 14000 15000 16000 20000];

if FreqVector(end) > Freq(end),
    Freq(end) = FreqVector(end);
end;
    
if field_type == 0, % free field
    WextdB_values = [0 0 0 0 0 0 0 0 0.1 0.3 0.5 0.9 1.4 1.6 1.7 2.5 2.7 2.6 2.6 3.2 5.2 ...
        6.6 12 16.8 15.3 15.2 14.2 10.7 7.1 6.4 1.8 -0.9 -1.6 1.9 4.9 2 -2 2.5 2.5];
        
elseif field_type == 1, % diffuse field
    WextdB_values = [0 0 0 0 0 0 0 0 0.1 0.3 0.4 0.5 1 1.6 1.7 2.2 2.7 2.9 3.8 5.3 6.8 7.2 ...
        10.2 14.9 14.5 14.4 12.7 10.8 8.9 8.7 8.5 6.2 5 4.5 4 3.3 2.6 2 2];
end
        
WextdB = interp1(Freq, WextdB_values, FreqVector, 'cubic');

Index20000 = find(FreqVector >= 20000);

if ~isempty(Index20000),
    WextdB(Index20000) = WextdB_values(end);
end;