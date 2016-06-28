function [E, Niv, Nivpond] = gene_energyLevelBC(sig, fs, show)

%%%%
% FUNCTION:
% Calculation of energy and level into the 24 critical bands from a signal
%
% USE:
%   [E, Niv, Nivpond] = gene_energyLevelBC(sig, fs, show)
%
%
% INPUT:
%   sig  : acoustic signal, monophonic (Pa)
%   fs   : sampling frequency (Hz)
%   show : 'on' to display some figures, 'off' if not (default)
%
% OUTPUT:
%   E       : energy in each critical band (J)
%   Niv     : level in each critical band (dB SPL)
%   Nivpond : level in each critical band with a0 (cf. Zwicker model) correction (dB SPL)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% pre-processing
if (nargin < 3) || strcmp(show, 'off'),
    show = 'off';
else
    show = 'on';
end;


%% Parameters

% Bark critical bands bounds
fc = [22 100 200 300 400 510 630 770 920 1080 ...
      1270 1480 1720 2000 2320 2700 3150 3700 4400 5300 ...
      6400 7700 9500 12000 15500];

% a0 attenuation for critical band
% (Correction of levels according to the transmission characteristics of
% the ear)
ao = [0 0 0 0 0 0 0 0 0 0 -0.2 -0.5 -1.2 -2.1 -3.2 -4.6 -5.5 -5.6 -4.3...
      -2.5 -0.1 2.8 6.4 20];
  
% reference
I0 = 10^-12;

% air impedance
pc = 415;


%% Fourier domain computation
%--------------------------------------------------------------------------

N = length(sig);

if rem(N, 2),
    nfft = N + 1;
else 
    nfft = N;
end

% samples corresponding to Bark band limits
kc = round(nfft ./ fs .* fc + 1);

% FFT
S = fft(sig,nfft);
S = S(1:nfft/2+1);

E = zeros(1, 24);
Niv = zeros(1, 24);
Nivpond = zeros(1, 24);

% Sum across bands
for i = 1:24,
    s = sum(abs(S(kc(i):kc(i+1)-1)).^2);
    E(i) = 2./(nfft*fs*pc) * s;
    Niv(i) = 10 * log10((fs/N)*E(i) / I0 + eps);
    Nivpond(i) = Niv(i) - ao(i);
end


%% Optional display

if strcmp(show, 'on'),
    figure;    
    stairs(0.5:1:24.5, [E E(end)]);
    title('Energy per critical band');
    xlabel('Critical band number');
    ylabel('Energy (J/Bark)');
    legend('Energy');
end;