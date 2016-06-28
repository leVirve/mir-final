function res = Loudness_TimeVaryingSound_Moore(signal, FS, type, show)

%%%%%%%%%%%%%
% FUNCTION:
%   Calculation of loudness for time-varying sounds, following the model of
%   Glasberg and Moore (2002). See reference for more details.
%
% USE:
%   res = Loudness_TimeVaryingSound_Moore(signal, FS, type, show)
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
%   res    : structure which contains the following fields:
%             - frequency : frequency vector of central frequencies of ERB bands (Hz)
%             - time : time vector in seconds
%             - InstantaneousLoudness: instantaneous loudness (sone) vs time
%             - STL: short-term loudness (sone) vs time
%             - LTL: long-term loudness (sone) vs time
%             - STLmax: max of STL value (sone)
%             - LTLmax: max of LTL value (sone)
%             - InstantaneousLoudnessLevel: instantaneous loudness level (phon) vs time
%             - STLlevel: short-term loudness level (phon) vs time
%             - LTLlevel: long-term loudness level (phon) vs time
%             - STLlevelmax: max of STL level value (phon)
%             - LTLlevelmax: max of LTL level value (phon)
%             - InstantaneousSpecificLoudness: specific loudness (sone/ERB) vs time and frequency
% 
% REFERENCE: 
% Glasberg B. R. et Moore B. C. J.,
% "A model of loudness applicable to time-varying sounds",
%  J. Audio Eng. Soc., 50, n° 5, 331-342, 2002
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Pre-processing
if nargin < 2,
    help Loudness_TimeVaryingSound_Moore;
    error('Not enough input parameters.');
end;

if nargin < 3,  % at least 3 parameters
    type = 'mic'; 
end;

if nargin < 4,  % display is disabled by default
    show = false; 
end;

sig = signal(:);

%% Some constants

% Time step for calculation of loudness (1 ms)
T = 0.001;

% Step for ERB bands numbers
erbStep = 0.25;

% Temporal integration constants (valid only if T = 0.001)
Ta  = -0.001 / ( log( 1 - 0.045));
Tr  = -0.001 / ( log( 1 - 0.02));
Tal = -0.001 / ( log( 1 - 0.01));
Trl = -0.001 / ( log( 1 - 0.0005));

KST_att = 1 - exp( -T / Ta);    % attack time for STL calculation
KST_dec = 1 - exp( -T / Tr);    % release time for STL calculation
KLT_att = 1 - exp( -T / Tal);   % attack time for LTL calculation
KLT_dec = 1 - exp( -T / Trl);   % release time for LTL calculation



%% Outer and Middle ear transfer (FIR filtering)

% Get transfer function
freq_earFRF = 0:FS/2; % (from 1 to FS/2 Hz by 1 Hz steps)

if strcmp(type, 'mic'), % omnidirectional microphone
    
    % Middle ear transfer function
    WdB = gene_Middle_Ear_Transfer_Function(freq_earFRF);
    
    % Outer ear transfer function
    WdBext = gene_Transfer_function_to_eardrum(freq_earFRF);
    
    % total TF
    WdB_cor = WdB + WdBext;
   
elseif strcmp(type, 'head'), % binaural (dummy head)
   
    % Middle ear transfer function
    WdB = gene_Transfer_function_to_eardrum(freq_earFRF);
    
    % total TF
    WdB_cor = WdB;
   
else
    error('"type" parameter value is not valid.');
    
end;

% Design and application of a FIR filter having a transfer function equal to WdB_cor

% filter order
ordreFIR = 4096;

% zero padding (useful when filtering the end of the signal)
sig((end + 1) : (end + ordreFIR)) = 0;

% FIR filter design
outMidFIR = fir2(ordreFIR, linspace(0, 1, FS/2+1), 10.^(WdB_cor./20));

% filtering process
sigFilt = filter(outMidFIR, 1, sig);

% zero padding
sigFilt((end + 1) : (end + 0.1 * FS)) = 0;

% filter delay compensation
sig = [zeros(ordreFIR/2-1,1); sig];


%% Time-frequency analysis of the signal
% with 6 different FFT sizes

[ SpecNiv, t, f] = gene_loop_specgram_6win(sigFilt, FS, T);

%% variables and parameteres settings

Nf = length(f);
Nt = length(t);

% 1st ERB band and frequency
fLo = 20;  erbLo = gene_freq2erb(fLo);

% last ERB band and frequencyf
fHi = 15000; erbHi = gene_freq2erb(fHi);

% ERB numbers
erbc = erbLo : erbStep : erbHi;

% ERB center frequencies
fc = gene_erb2freq(erbc);

% sample numbers associated to frequencies fc
kc = round(2 * (Nf - 1) / FS * fc + 1);

% number of ERB bands
Nerb = length(erbc);

% lower band limits of ERB bands
fcLo = gene_erb2freq(erbc - 0.5);

% upper band limits of ERB bands
fcHi = gene_erb2freq(erbc + 0.5);

% sample number corresponding to freq. fcLo
kcLo = round(2 * (Nf - 1) / FS * fcLo + 1);

% sample number corresponding to freq. fcHi
kcHi = round(2 * (Nf - 1) / FS * fcHi + 1);

% useful variables used to calculate excitation pattern from PSD
g = zeros(Nerb, Nf);
for ierb = 1 : Nerb,
    g(ierb, :) = abs(f.' - fc(ierb)) / fc(ierb);
end;

EthNiv = gene_ExcInt(fc)';                  % internal excitation level at threshold
EthInt = 10.^( EthNiv / 10);                % internal excitation at threshold
p51 = 4 * fc ./ gene_freq2erbWidth(fc) ;    % values of p for level of 51dB for center frequencies of ERB filters, fc
p51_1k = 4*1000 / gene_freq2erbWidth(1000); % value for 1 kHz

% constants for the calculation of Specific Loudness from excitation pattern
Ethrq_dB_500 = gene_ExcInt(500); % internal excitation level at threshold for freq. 500Hz and above
G = 10.^( (Ethrq_dB_500-EthNiv) / 10 );

% A = zeros(Nerb, 1);
% alpha = zeros(Nerb, 1);
A = gene_A_Parameter_ANSI_S34_2007( 10 * log10(G) );
alpha = gene_AlphaParameter_ANSI_S34_2007( 10 * log10(G) );

C = 0.046871; % ANSI S3.4-2007 section 3.6.4

%% Instantaneous loudness calculation

% Initialisation
XNivc = zeros(1, Nerb);
% roex = zeros(Nf, 1);
ExcitInt = zeros(Nerb, 1);
InstantaneousLoudness = zeros(1, Nt);
InstantaneousSpecificLoudness = zeros(Nt, Nerb);

h = waitbar(0,'Please wait...');

% loop along time steps (every T second)
for i = 1 : Nt,
    
    if rem(i, 100) == 0,
        waitbar( i / Nt, h);
    end;
    
    % spectrum (intensity) for current time window
    SpecInt = 10.^( SpecNiv( :, i) ./ 10);
    isup = [];
    
    for ierb = 1 : Nerb,
        % ERB limit bins
        index = kcLo(ierb) : kcHi(ierb);
        
        if isempty( index),
            % if no sample within the ERB band, default value if -100dB
            XInt = 1e-10;
        else
            % sum within the ERB band
            XInt = sum( SpecInt( index)); 
        end;

        % level in dB/ERB
        XNivc(ierb) = 10*log10( XInt + eps);

    end;
    
    % Interpolation to a ERB spaced frequency vector
    XNiv = interp1([0 fc FS/2], [ -20 XNivc -20], f.').';

    % excitation pattern calculation (ExcitInt)
    for ierb = 1 : Nerb,
        
        % pu: upper side of band centered in fc
        pu = ones(Nf, 1) * p51(ierb);
        pu(1:kc(ierb)-1) = 0;
        
        % pl: lower side of band centered in fc
        pl = ones(Nf, 1) * p51(ierb) .* ( 1 - (0.35/p51_1k)*(XNiv-51) );
        pl(kc(ierb) : Nf) = 0;
        
        pg = (pl+pu) .* g(ierb, :)';
        
        roex = (1+pg) .* exp(-pg);
        
        if fc(ierb) == 0,
            roex = 0;
        end;
        
        ExcitInt(ierb) =  sum(roex .* SpecInt);
        
        if ExcitInt(ierb) > EthInt(ierb), 
            isup = [isup; ierb]; 
        end;
    end;

    % Specific loudness calculation 
    SpecLoud = gene_exc2specificloudness(ExcitInt, EthInt, C, A, alpha, G);
        
    % NOTE: SpecLoud is multiplied by two to take into account the
    % contribution of two ears
    InstantaneousSpecificLoudness(i, 1:Nerb) = 2 * SpecLoud;

    % Intagration to reach instantaneous loudness
    InstantaneousLoudness(i) = sum(InstantaneousSpecificLoudness(i, 1:Nerb)) * erbStep;
end;

close(h);


%% STL calculation

STL = zeros(size(InstantaneousLoudness)); 
for i = 2 : length(STL),
    if InstantaneousLoudness(i) > STL(i - 1),
        STL(i) = KST_att * InstantaneousLoudness(i)...
                     + (1 - KST_att) * STL(i - 1);
    else
        STL(i) = KST_dec * InstantaneousLoudness(i)... 
                     + (1 - KST_dec) * STL(i - 1);
    end;
end;

% keep calculating STL until a threshold
while STL(end) > max(STL / 2),
    InstantaneousLoudness(end + 1) = 0;
    STL(end + 1)  = (1 - KST_dec) * STL(end);
    t(end + 1)    = t(end) + T;
end;

%% LTL calculation

LTL = zeros(size(InstantaneousLoudness));
for i = 2 : length(LTL),
    if STL(i) > LTL(i - 1),
        LTL(i) = KLT_att * STL(i)... 
                    + (1 - KLT_att) * LTL(i - 1);
    else
        LTL(i) = KLT_dec * STL(i)...
                    + (1 - KLT_dec) * LTL(i - 1);
    end;
end;


%% OUTPUT - fill res structure

res.frequency = fc;
res.time = t;
res.InstantaneousSpecificLoudness = InstantaneousSpecificLoudness;
res.InstantaneousLoudness = InstantaneousLoudness;
res.InstantaneousLoudnessLevel = gene_sone2phon_ANSI_S34_2007(InstantaneousLoudness);

res.STLlevel = gene_sone2phon_ANSI_S34_2007( STL );
res.LTLlevel  = gene_sone2phon_ANSI_S34_2007( LTL ); 
res.STL = STL;
res.LTL = LTL; 

res.STLlevelmax = gene_sone2phon_ANSI_S34_2007( max(STL) );
res.LTLlevelmax = gene_sone2phon_ANSI_S34_2007( max(LTL) );
res.STLmax = max(STL);
res.LTLmax = max(LTL);

%--------------------------------------------------------------------------
% AFFICHAGES
%--------------------------------------------------------------------------

if show == true,
    
    figure(1);
    t = (0 : length(sig)-1) ./ FS;
    xmax = t(end);
    subplot(411), plot( t, sig); 
        ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Signal: ');
        ylabel('Amplitude (Pa)');
    subplot(412), plot( res.time, res.InstantaneousLoudnessLevel);
        ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Instantaneous loudness level');
        ylabel('Loudness level (phon)');
        grid on;
    subplot(413), plot( res.time, res.STLlevel);
        ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('STL level');
        ylabel('Loudness level (phon)');
        grid on;
        text(t(end) * 0.7, res.STLlevelmax - 10,...
            ['STL level max = ' num2str(res.STLlevelmax, 4)]);
    subplot(414), plot( res.time, res.LTLlevel);
        ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('LTL level');
        xlabel('Time (s)');
        ylabel('Loudness level (phon)');
        grid on;
        text(t(end) * 0.7, res.LTLlevelmax - 10,...
            ['LTL level max = ' num2str(res.LTLlevelmax, 4)]);
    
    figure(2);
    subplot(411), plot( t, sig);
        ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Signal: ');
        ylabel('Amplitude (Pa)');
    subplot(412), plot( res.time, res.InstantaneousLoudness);
        ax = axis; axis([0 xmax ax(3) ax(4)]); 
        title('Instantaneous loudness');
        ylabel('Loudness (sone)');
        grid on;
    subplot(413), plot( res.time, res.STL);
        ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('STL');
        ylabel('Loudness (sone)');
        grid on;
        text(t(end) * 0.7, res.STLmax / 2,... 
            ['STLmax = ' num2str(res.STLmax, 3)]);
    subplot(414), plot( res.time, res.LTL);
        ax = axis; axis([0 xmax ax(3) ax(4)]);
        title('LTL');
        xlabel('Time (s)');
        ylabel('Loudness (sone)');
        grid on;
        text(t(end) * 0.7, res.LTLmax / 2,...
            ['LTLmax = ' num2str(res.LTLmax, 3)]);
    
    figure(3);
    mesh(res.time(1 : size(res.InstantaneousSpecificLoudness, 1)), res.frequency, res.InstantaneousSpecificLoudness');
    view( 60, 60);
    title('Sensory time-frequency representation: ');
    xlabel('Time (s)');
    ylabel('ERB central frequency (Hz)');
    zlabel('Specific loudness (sone/ERB)');
    
end;
