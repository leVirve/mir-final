function [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B_from_sound(Sig, FS, FieldType)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% USE: 
%   [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B_from_sound(Sig, FS, FieldType)
% 
% FUNCTION:
%   Computation of loudness (Zwicker model) according to ISO 532B / DIN 45631 norms. 
%   This model is valid for steady sounds.
%   Code based on BASIC program published in the following article:
%   "Program for calculating loudness according to DIN 45 631 (ISO 532B)",
%   E.Zwicker and H.Fastl, J.A.S.J (E) 12, 1 (1991).
% 
% INPUT:
%       Sig       : signal in Pascal
%       FS        : sampling frequency in Hz
%       FieldType : sound field type (0: free field (default value), 1: diffuse field)
% 
% OUTPUT:
%       N_tot    : total loudness, in sone
%       N_specif : specific loudness, in sone/bark
%       BarkAxis : vector of Bark band numbers used for N_specif computation
%       LN       : loudness level, in phon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - www.genesis.fr - July 2009    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% parameters checking
if nargin < 3,
    FieldType = 0; % free field by default
    
elseif nargin == 3,
    if FieldType ~= 1 && FieldType ~= 0,
        error('FieldType value must be 0 or 1. (0=free field, 1=diffuse field)');
    end;    
end;

%% Signal checking

if min(size(Sig)) > 1,
     error('Signal must be monophonic (one channel)');
end;

Sig = Sig(:);

%% Third octave analysis of signal

P0 = 2e-5; % sound pressure level reference in Pa
deltaT = fix(length(Sig)/FS);    % length of the signal in seconds

VectNiv3Oct = gene_ThirdOctave_levels(Sig, FS, deltaT, P0); % third octave levels computation
VectNiv3Oct = VectNiv3Oct(1:28,:); % the 28 third octave bands of interest are keeped

VectNiv3Oct = VectNiv3Oct(:);
VectNiv3Oct( VectNiv3Oct < -60 ) = -60;

%% Loudness computation

[N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B(VectNiv3Oct, FieldType);