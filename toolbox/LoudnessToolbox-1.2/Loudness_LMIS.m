function [Loudness LoudnessLevel] = Loudness_LMIS(signal, FS, type, show)

%%%%%%%%%%%%%
% FUNCTION:
%   Calculation of loudness of impulsive sounds acording to Boullet's model
%   LMIS: Loudness Model for Impulsive Sounds
%
% USE:
%   [Loudness LoudnessLevel] = Loudness_LMIS(signal, FS, type, show)
% 
% INPUT:
%   signal : acoustic signal, monophonic (Pa)
%   FS     : sampling frequency (Hz)
%   type   : (optional parameter) 'mic' (default value) for omnidirectional sound
%            recording, 'head' for dummy head measurement
%   show   : optional parameter for some figures display.
%            May be false (disable, default value) or true (enable).
% 
% OUTPUT:
%   Loudness      : overall loudness (sone)
%   LoudnessLevel : overall loudness level (phon)
% 
% REFERENCES: 
% Boullet - "La sonie des sons impulsionnels: perception, mesures et modèles"
% Ph.D thesis - LMA-CNRS, Marseille - 2005
%
% Boullet et al - "Un estimateur de sonie d'impulsion: élaboration et
% validation" - Proc. Acoustics French Congress CFA'06 - Tours - 2006
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Pre-processing

if nargin < 2,
    help LMIS;
    error('Not enough arguments');
end;

if nargin < 3,  % default type is microphone
    type = 'mic';
end;

if nargin < 4,  % default display is disabled
    show = false;
end;



%% recording type processing

switch type,
    case 'mic',  % MICROPHONE: nothing to do, standard case for LMIS algorithm
        sig = signal(:);
        
    case 'head', % Dummy head: outer ear effect must be corrected
       
        sig = signal(:);

        % Frequency vector for filter
        freq_earFRF = 0:FS/2; % (1 to FS Hz by 1 Hz steps)
        normalized_freq = linspace(0, 1, FS/2+1);

        % Outer ear effect is inverted
        WdB_cor = -Transfer_function_to_eardrum(freq_earFRF);

        % FIR filter design

        % Filter order
        FIRorder = 4096;

        % Zero padding
        sig((end + 1) : (end + FIRorder)) = 0;

        % Filter design
        outEarFIR = fir2(FIRorder, normalized_freq, 10.^(WdB_cor./20));

        % Filtering step
        sigFilt = filter(outEarFIR, 1, sig);

        % Zero padding 
        sigFilt((end + 1) : (end + 0.1 * FS)) = 0;
        
        % sig will be used in what follows
        sig = sigFilt;
        
    otherwise,
        error('Wrong parameter type : ''mic'' or ''head''')
        
end;




if show == true,
    disp('---------------------------------------------------------------')
    disp('Calculation of critical bands energy...')
end


%% Decay time (-60 dB) within each critical band

% dyn: dyn parameter for RT60 calculation (20 or 30 dB)
dyn = 20; % dB

sigFilt = gene_filtersBC(sig, FS);


 I0 = 1e-12;
 pc = 415;

%% Energy level into the 24 critical bands
 Eband = (mean(sigFilt.^2)./pc)* length(sig)/FS;

 
 Nband = 10*log10( Eband / I0 );

Tnoise = 0.05;
Td = zeros(1,24);

for i = 1:24,

    [Td(i), sig2noise] = gene_RTx(sigFilt(:,i), FS, dyn, Tnoise, 'off');
    
    if (sig2noise) && (show == true),
       disp(['SNR in band n. ' int2str(i)]);
       disp('----------------------------------');
    end;
    
end;


%% Optional display

if (show == true),
    figure;
    subplot(211);
    bar(1000 * Td);
    ax = axis; ax(3) = 0; ax(4) = 300; axis(ax);
    title(['Temps de descente dans chaque bande critique: RT' num2str(dyn)]);
    ylabel('Temps en millisecondes');
    grid on;
    subplot(212);
    stairs(0.5:1:24.5, [E E(end)]);
    grid on;
    legend('Energie');
    title('Energie et énergie pondérée ao dans chaque bande critique');
    ylabel('Energie en Joules / Bark');
    xlabel('Bandes critiques');
    grid on;

end


%% Main loudness

% Steepness of loudness functions
alpha = [0.42 0.42 0.42 0.4225 0.425 0.3825 0.34 0.365 0.39 0.40...
         0.41 0.395 0.38 0.405 0.43 0.425 0.42 0.415 0.41 0.415...
         0.42 0.405 0.39 0.39];

% Constants for critical bands corrections
K = [15.254 15.254 15.254 16.36 17.604 14.63 12.155 12.24 12.845 13.831...
     15.081 14.989 14.94 17.153 19.005 20.16 21.335 18.104 15.094 14.024...
     13.044 9.4124 6.1607 6.1607];

beta = 0.1;

krn = zeros(1,24);
for i = 1:24,
   if Td(i) ~= 0,
       krn(i) = K(i) * Eband(i).^(alpha(i)/2) .* (1000.*Td(i)).^beta;
   else
       krn(i) = K(i) * Eband(i).^(alpha(i)/2);
   end;
end;


%% Specific loudness

if show == true,
    disp('---------------------------------------------------------------')
    disp('Calculation of specific loudness...')
end;

% Number of calculation steps per critical band
Nbc = 20;
if (show == true),
    l_show = 'on';
else
    l_show = 'off';
    
end;

% Specific loudness calculation
SpecificLoudness = gene_mainLoudness2density(krn, Nbc, l_show);

% Integration
Loudness = sum(SpecificLoudness) / Nbc;

% Conversion
LoudnessLevel = gene_sone2phon_ISO532B(Loudness);
