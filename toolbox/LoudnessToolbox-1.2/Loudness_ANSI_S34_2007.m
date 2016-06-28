function [Loudness, Specific_loudness, fc, LoudnessLevel] = Loudness_ANSI_S34_2007(Sig, fe, field_type, rec_type, show)

%%%%%%%%%%%%%%%%%%%%
% FUNCTION:
%   loudness computation according to Moore and Glasberg model,
%   according to ANSI S3.4-2007 norm.
%   This model is valid for steady sounds.
%
% USE:
%   [Loudness, Specific_loudness, fc, LoudnessLevel] =
%               Loudness_ANSI_S34_2007(Sig, fe, field_type, rec_type, show)
%
% INPUT:
%   Sig       : signal (Pascal)
%   fe        : sampling freq of the signal (Hz)
%   field_type: field type (0: free field, 1: diffuse field)
%   rec_type  : 'mic' or 'head', depending on the measure (microphone or dummy head)
%   show      : 'on' or 'off' to enable or disable some figures display
%
% OUTPUT:
%   Loudness          : total loudness of the signal (sone)
%   Specific_loudness : specific loudness of the signal (sone/ERB)
%   fc                : central frequencies of the Equivalent Rectangular Bandwith 
%                       bands (ERB bands)
%   LoudnessLevel     : total loudness level (phon)
%
%
% REFERENCES:
% "A model for the prediction of thresholds, loudness, and partial loudness",
% par B.C.J. Moore, B.R. Glasberg, T. Baer JAES 45(4), 1997
%
% "Derivation of auditory filters shapes from notched-noise data",
% par B.C.J. Moore, B.R. Glasberg, Hearing Research 47 (1990) 103-138
%
% ANSI S3.4-2007 : "Procedure for the Computation of Loudness of Steady Sounds"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Pre-processing
if size(Sig,2) > 2,
    Sig = Sig';
end;

%% Variables settings

% FFT length
Nfft = round(2*2048*fe/48000);

% ERB step resolution
res = 0.1;

% Highest ERB band to take into account 
ERB_max = 38; % corresponds to freq = 15 kHz

% ERb bands numbers
erb_c = 1.5 : res : ERB_max+0.5;

% ERB to Hertz conversion
fc = gene_erb2freq(erb_c);

% Frequencies axis
f = (0:Nfft/2)*fe / Nfft;

% C constant
C = 0.046871; % ANSI S3.4-2007 section 3.6.4

% reference pressure
P0 = 2e-5;


%% Calculation of the normalisation constant for PSD

% Sinusoid with RMS value equal to 1
sig_test = sqrt(2)*sin(2*pi*(0:(Nfft-1)*20)*1000/fe);

% PSD of the test sinusoid
PSD_sin = pwelch(sig_test,blackmanharris(Nfft),Nfft/2,Nfft,fe);;

% Normalisation factor in order to have PSD values in Pa^2/Hz
dfreq = fe / Nfft;
fac = 1 / ( sum(PSD_sin) * dfreq );


%% Transfer functions of middle ear and outer to eardrum

WdB = gene_Middle_Ear_Transfer_Function(f); % middle ear transfer function

WdBext = gene_Transfer_function_to_eardrum(f, field_type); % field to eardrum transfer function (outer ear)


%% Ethrq, internal excitation level at threshold

Ethrq_dB = gene_ExcInt(fc);
Ethrq = 10.^(Ethrq_dB/10); % Ethrq is already normalized w.r.t. E0


%% G term value

% G represents the low-level gain of the cochlear amplifier at a specific
% frequency, relative to the gain at 500Hz and above (which is assumed to
% be constant). We have the relationship: G * Ethrq = constant

Ethrq_dB_500 = gene_ExcInt(500); % internal excitation level at threshold for freq. 500Hz and above
G = 10.^( (Ethrq_dB_500-Ethrq_dB) / 10 );


%% Parameters loading: A et Alpha

A = gene_A_Parameter_ANSI_S34_2007( 10 * log10(G) );
alpha = gene_AlphaParameter_ANSI_S34_2007( 10 * log10(G) );


%% Correction factor calculation (depending on the value of rec_type)

if strcmp(rec_type, 'mic'), % outer + middle ear TF
   WdB_cor = WdB + 10*log10(fac) + WdBext;
   
elseif strcmp(rec_type,'head'), % only middle ear TF
   WdB_cor = WdB + 10*log10(fac);
   
else
    error('rec_type value is not valid (must be ''mic'' or ''head'').');    
end
    

%% PSD calculation + ear transfer function correction + excitation calculation
%%%%%%%%

%% MONAURAL case
if size(Sig, 2) == 1,

        % PSD of signal
        psdTot = pwelch(Sig,blackmanharris(Nfft),Nfft/2,Nfft,fe);
        psdTot = psdTot(:)';

        % ear influence + factor correction
        psdTot = psdTot .* 10.^(WdB_cor/10);

        % Calculation of excitation from psd
        Etot = gene_psd2exc(psdTot, f, fc);

        % P0² normalisation
        Etot = Etot / P0^2;

        % optional plot
        if exist('show','var') && ~strcmp(show, 'off'),
            figure;
            semilogx(fc, 10*log10(Etot),'k');
            grid on;
            legend('Excitation pattern');
            xlabel('freq (Hz)');
            ylabel('dB SPL');
            axis([20 20000 0 120]);
        end;

        % Specific loudness calculation 
        NprimTot = gene_exc2specificloudness(Etot, Ethrq, C, A, alpha, G);

        Specific_loudness = NprimTot;
        
        % optional plot
        if exist('show','var') && ~strcmp(show,'off'),
            figure;
            semilogx(fc,NprimTot);
            title('Specific loudness');
            ylabel('Specific loudness (Sone / Hz)');
            xlim([20 20000])
            xlabel('freq (Hz)');
        end;
            
        % total loudness: integration of specific loudness
        if strcmp(rec_type, 'mic'),
            Loudness = 2 * sum(NprimTot) * res;
            % total loudness = twice loudness of "one ear" (thus, factor 2)

        elseif strcmp(rec_type, 'head'),
            Loudness = sum(NprimTot) * res;
            % no factor 2: we suppose we are interested in only one ear
        end;

        
%% BINAURAL case
elseif size(Sig, 2) == 2,

        % PSD of signal for both channels
        psdTot_L = psd(Sig(:,1), Nfft, fe);
        psdTot_L = psdTot_L(:)';
        
        psdTot_R = psd(Sig(:,2), Nfft, fe);
        psdTot_R = psdTot_R(:)';
        
        % ear influence + factor correction
        psdTot_L = psdTot_L.*10.^(WdB_cor/10);
        psdTot_R = psdTot_R.*10.^(WdB_cor/10);

        % Calculation of excitations from psd for both ear
        Etot_L = gene_psd2exc(psdTot_L, f, fc);
        Etot_R = gene_psd2exc(psdTot_R, f, fc);

        % P0² normalisation
        Etot_L = Etot_L / P0^2;
        Etot_R = Etot_R / P0^2;
        
        % optional plot
        if exist('show','var') && ~strcmp(show,'off'),
            figure;
            semilogx(fc, 10*log10(Etot_L+Etot_R),'k');
            grid on;
            legend('Excitation pattern (L+R)');
            xlabel('freq (Hz)');
            ylabel('dB SPL');
            axis([20 20000 0 120]);
        end;

        % Specific loudness calculation from parameters of the two ears
        NprimTot_L = gene_exc2specificloudness(Etot_L, Ethrq, C, A, alpha, G);
        NprimTot_R = gene_exc2specificloudness(Etot_R, Ethrq, C, A, alpha, G);
        
        Specific_loudness = NprimTot_L + NprimTot_R;
        
        % optional plots
        if exist('show','var') && ~strcmp(show,'off'),
            figure;
            semilogx(fc, Specific_loudness);
            grid on;
            legend('specific loudness');
            xlim([20 20000])
            xlabel('freq (Hz)');
            ylabel('Specific loudness (Sone par Hertz)')
        end;

        % total loudness: integration of specific loudness     
        Loudness_L = sum(NprimTot_L) * res; % left ear
        Loudness_R = sum(NprimTot_R) * res; % right ear
        Loudness = Loudness_L + Loudness_R; % total
        
else
    error('Input signal not valid. Must have 1 channel (monaural) or 2 channels (binaural).');
        
end;

% Loudness level computation
LoudnessLevel = gene_sone2phon_ANSI_S34_2007( Loudness );