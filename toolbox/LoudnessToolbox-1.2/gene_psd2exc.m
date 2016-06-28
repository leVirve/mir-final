function [Exc, L] = gene_psd2exc(dsp, f, fc, L)
%%%%%%%
% USE:
%   [Exc, L] = gene_psd2exc(dsp, f, fc, L)
%
% FUNCTION:
%   conversion from a power spectral density in Pa²/Hz into an excitation
%   pattern.
%
% INPUT:
%   dsp : PSD in Pa²/Hz
%   f   : frequency of the PSD in Hz (same length as dsp)
%   fc  : central frequencies of ERB bands
%   L   : levels (dB SPL), same size as fc (optional parameter)
%           - If L is specified, excitation computation is done using L.
%           - If not specified, computation of L is done from dsp
%   and then excitation computation is done.
%
% OUTPUT:
%   Exc : excitation pattern for frequencies fc
%   L   : level in dB SPL for fc
%
% REFERENCES:
%   Glasberg Moore "Derivation of auditory filter shapes from notched-nois
%   data", Hearing Research 47, 1990.
%
%   ANSI S3.4-2007 norm - section 3.5
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%

% frequency step
df = f(2) - f(1);

P0 = 2e-5;

%% mean SPL level from narrow band spectrum, after integration of ERB bands

if nargin < 4, % if L is not passed as input
    
    erb_narrow = gene_freq2erb(f);

    L = zeros( size(dsp) );

    for i = 1:length(dsp),
        
        % find frequencies index centered to erb_narrow and close to less
        % than half an ERB band
        id = find( (erb_narrow > erb_narrow(i)-0.5) .* (erb_narrow <= erb_narrow(i)+0.5) );
        
        % Integration over the band
        if (~isempty(id)),
            L(i) = sum( dsp(id) * df );
        end;
    end;
    
    % threshold
    id = L < 1e-10;
    L(id) = 1e-10;
    
    % conversion to dB SPL
    L = 10*log10(L/P0^2);
end


%% Excitation calculation
Exc = zeros(size(fc));

% values of p for level of 51dB for center frequencies of ERB filters, fc
p51 = 4*fc ./ gene_freq2erbWidth(fc);

% value for 1 kHz
p51_1k = 4*1000 / gene_freq2erbWidth(1000);

% loop over ERB filters
for i = 1:length(fc),
    
    % idc: find index of narrow band for current fc
    [unused, idc] = min(abs(fc(i)-f));
    
    % pu: value of p in the upper side of the band (f > fc) - independent of level
    pu = ones(size(f)) * p51(i);
    pu(1:idc-1) = 0; % for f<fc, pu is zero
    
    % g: normalized deviation from the center of the filter
    if fc(i) > 0,
        g = abs(fc(i)-f) / fc(i);
    else
        g = zeros(size(f));
    end;
    
    % pl: value of p in the lower side of the band (f <= fc) - depends of
    % level L
    pl = ones(size(f)) * p51(i) .* ( 1 - (0.35/p51_1k)*(L-51) );
    pl(idc+1:end) = 0;
    
    % W calculation
    C = (pl+pu) .* g;
    W = (1+C) .* exp(-C);
    
    if (fc(i) == 0),
        W = 0;
    end;

    % Excitation pattern calculation: integration of W*dsp vs frequency
    Exc(i) = sum( W.*dsp*df );
    
end;
