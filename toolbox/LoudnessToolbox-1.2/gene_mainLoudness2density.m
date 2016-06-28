function [SpecLoudness, Cbn] = gene_mainLoudness2density(krn, Nbc, show)

%%%%%%%%%%%%%
% FUNCTION:
%   Calculation of loudness of impulsive sounds acording to Boullet's model
%   LMIS: Loudness Model for Impulsive Sounds
%
% USE:
%   [SpecLoudness, Cbn] = mainLoudness2density(krn, Nbc, show)
% 
% INPUT:
%   krn  : vector of 24 main loudness values
%   Nbc  : number of samples per critical band (sub-sampling)
%   show : optional parameter for some figures display.
%            May be false (disable, default value) or true (enable).
% 
% OUTPUT:
%   SpecLoudness : specific loudness
%   Cbn          : critical bands numbers vector
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if length(krn) ~= 24,
    error('krn has an invalid length'),
end

if nargin < 3 || strcmp(show, 'off'),
    show = 'off';
else
    show = 'on';
end

%% Parameters

fls = [ 13.0 8.20 5.70 5.00 5.00 5.00 5.00 5.00 .* ones(1,17);
        9.00 7.50 6.00 5.10 4.50 4.50 4.50 4.50 .* ones(1,17);
        7.80 6.70 5.60 4.90 4.40 3.90 3.90 3.90 .* ones(1,17);
        6.40 5.50 4.70 4.10 3.60 3.20 3.20 3.20 .* ones(1,17);
	    5.60 5.00 4.50 4.30 3.50 2.90 2.90 2.90 .* ones(1,17);
        4.20 3.90 3.70 3.30 2.90 2.42 2.42 2.42 .* ones(1,17);
        3.20 2.80 2.50 2.30 2.20 2.20 2.20 2.02 .* ones(1,17);
        2.80 2.10 1.90 1.80 1.70 1.60 1.60 1.41 .* ones(1,17);
        1.60 1.50 1.40 1.30 1.20 1.10 1.10 1.02 .* ones(1,17);
        1.50 1.20 0.94 0.77 0.77 0.77 0.77 0.77 .* ones(1,17);
        0.72 0.66 0.61 0.54 0.54 0.54 0.54 0.54 .* ones(1,17);
        0.44 0.41 0.40 0.39 0.39 0.39 0.39 0.39 .* ones(1,17);
        0.29 0.25 0.22 0.22 0.22 0.22 0.22 0.22 .* ones(1,17);
        0.15 0.13 0.13 0.13 0.13 0.13 0.13 0.13 .* ones(1,17);
        0.06 0.05 0.05 0.05 0.05 0.05 0.05 0.05 .* ones(1,17);
        0.04 0.04 0.04 0.04 0.04 0.04 0.04 0.04 .* ones(1,17)];

lim = [ 23.5 19 15.1 11.9 9 6.6 4.6 3.2 2.13 ...
        1.36 0.82 0.43 0.21 0.08 0.03 0];

    
%% Specific loudness

sonieFlanc = zeros(24, 24 * Nbc);
z = zeros(1,20);
sbc = zeros(1,20);

for ibc = 1 : 24, % loop over critical bands  
     if krn(ibc) ~= 0,
        
        z(1:2) = [ibc ibc+1-1/Nbc];
        sbc(1:2) = krn(ibc) .* ones(1, 2);
        index = 3;
        
        for ilv = 1 : 16, % level index
            if lim(ilv) <= krn(ibc),
                dz = (sbc(index-1) - lim(ilv)) / fls(ilv, ibc);
                z(index) = z(index-1) + dz;
                sbc(index) = lim(ilv);
                index = index + 1;
            end;
        end;
        
        z(index) = 26;
        sbc(index) = lim(ilv);
        sonieFlanc(ibc, ((ibc-1) * Nbc) + 1 : end) =...
            interp1(z(1:index), sbc(1:index),...
                    linspace(ibc, 24+1-1/Nbc, (24-(ibc-1)).*Nbc));
     end;
end;


%% Output data

SpecLoudness = max(sonieFlanc);
Cbn = linspace(1, 24+1-1/Nbc, 24.*Nbc);


%% Optional display

if strcmp(show, 'on'),
    figure
    subplot(211), plot(linspace(0.5, 24+0.5-1/Nbc, 24.*Nbc), sonieFlanc');
    title('Main and specific loudness vs critical bands');
    xlabel('Bark band number');
    ylabel('Sone/Bark');
    
    subplot(212), plot(linspace(0.5, 24+0.5-1/Nbc, 24.*Nbc), SpecLoudness, 'r');
    hold on;
    bar(krn, 'b');
    title('Sonie de coeur et densité de sonie');
    xlabel('Bark band number');
    ylabel('Sone/Bark');
    legend('Specific loudness', 'Main loudness');
    
    hold on;
end

