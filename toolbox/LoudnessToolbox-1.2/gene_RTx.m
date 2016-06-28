function [RTx, sig2noise, C, Lmax, Lnoise] = gene_RTx(ri, fs, x, T, show)

%%%%%
%
% FUNCTION:
%   Reverberation time RTx estimation accoriding to norm NF EN ISO 3382 (2000)
%
% USE:
%   [RTx, sig2noise, C, Lmax, Lnoise] = gene_RTx(ri, fs, x, T, show)
%
%INPUT:
%   ri   : impulse response
%   fs   : sampling frequency (Hz)
%   x    : value (dB) for estimation of decay from first x dB (x=20 or 30
%          to follow the norm)
%   T    : approximate duration (second) of background noise at the end of the signal
%   show : 'on' for display, 'off' to disable display (default)
%
%
%OUTPUT:
%   RTx       : RTx value (seconds)
%   sig2noise : if different of zero, SNR is not sufficient
%   C         : correlation coefficient between retrograd integration curve
%               and line estimating RTx in ms
%   Lmax      : maximum level (dB) of retrograd integration curve
%   Lnoise    : noise level (dB) estimated from the T last seconds of the signal
%
% REFERENCE:
%   NF EN ISO 3382 (2000) french norm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sig2noise = 0;

if nargin < 5,
    show = 'no';
end;

% Energy
ri2 = ri.^2;
t = (0 : length(ri)-1) / fs;


if strcmp(show, 'on'), % Echogram display
    figure;
    plot(t, 10*log10(ri2 + eps), 'b');
    grid on; hold on;
end

% Background noise
ibruit = round(T * fs);
Nbruit = mean (ri2(end - ibruit : end));

% Background nosie cancelling
ri2 = ri2 - Nbruit;

% Retrograd integration (IR)
IR = sum(ri2) - cumsum(ri2);
IR = IR(1 : end-1);
t = t(1:end-1);
IRdB = 10*log10(abs(IR) + eps);

% Display IR
if strcmp(show,'on'),
	plot(t, IRdB, 'r');
	grid on
	hold on
end

% Noise threshold for IR
Lnoise = 10*log10(mean(abs(IR(end - ibruit : end))) + eps);

% RTx: Points selection between max-5 dB and max-(x+5) dB
Lmax = IRdB(1);

bool  = 1;
start = 0;
stop  = 0;

for i = 1:length(IRdB),
    
    if (IRdB(i) < Lmax-5) && bool,
        start = i;
        bool = 0;
    end;
    
    if IRdB(i) < Lmax-(x+5),
        stop = i;
        break;
    end;
    
end;

if (start == 0) || (stop == 0) || (Lmax - (x + 5) < Lnoise + 5),
    sig2noise = 1; % background noise level is not sufficient
else
    IRdB_extract = IRdB(start:stop);
    t_extract = t(start:stop);

    if strcmp(show,'on'), % display of IR part corresponding to linear interpolation
     plot(t_extract, IRdB_extract,'b');
    end;

    % Linear interpolation
    Ordre = 1;
    p = polyfit(t_extract, IRdB_extract', Ordre);
    IRinterp = polyval(p, t_extract);

    if strcmp(show,'on'), % Display interpolation line
        plot(t_extract, IRinterp, 'k');
    end


% RTx computation
C = VectorCorr_subf(IRinterp, IRdB_extract);
if C < 0.96 || sig2noise,
    RTx = 0;    
else
    RTx = - 60 / p(1);
end;
end;
if sig2noise,
    RTx = 0;    
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUB-function
%%%%
function c = VectorCorr_subf(x, y)

%%%%
% calculation of correlation coefficient for signals x and y
%%%%

x = x(:);
y = y(:);

Sxx = sum((x-mean(x)).^2);
Syy = sum((y-mean(y)).^2);
Sxy = sum((x-mean(x)).*(y-mean(y)));

c = Sxy.^2 ./ (Sxx.*Syy);
