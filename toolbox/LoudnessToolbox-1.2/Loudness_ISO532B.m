function [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B(VectNiv3Oct, FieldType)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% USE: 
%   [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B(VectNiv3Oct, FieldType)
% 
% FUNCTION:
%   Computation of loudness (Zwicker model) according to ISO 532B / DIN 45631 norms. 
%   This model is valid for steady sounds.
%   Code based on BASIC program published in the following article:
%   "Program for calculating loudness according to DIN 45 631 (ISO 532B)",
%   E.Zwicker and H.Fastl, J.A.S.J (E) 12, 1 (1991).
% 
% 
% INPUT:
%       VectNiv3oct: vector of 1/3 octave levels into the 28 normalized bands (dBSPL)
%                   (see band frequency values below)
%       FieldType  : sound field type (0: free field (default value), 1: diffuse field)
% 
% OUTPUT:
%       N_tot   : total loudness, in sone
%       N_specif: specific loudness, in sone/bark
%       BarkAxis: vector of Bark band numbers used for N_specif computation
%       LN      : loudness level, in phon
%
%
% NOTA:
%  third octave bands center frequencies required:
%  [25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500
%   3150 4000 5000 6300 8000 10000 12500]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - www.genesis.fr - July 2009    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Pre-processing

if nargin < 2,
    FieldType = 0; % free field by default
    
elseif nargin == 2,
    if FieldType ~= 1 && FieldType ~= 0,
        error('FieldType value must be 0 or 1. (0=free field, 1=diffuse field)');
    end;    
end;

Nbands3Oct = 28;
VectNiv3Oct = VectNiv3Oct(:);

if size(VectNiv3Oct,1) ~= Nbands3Oct,
    error(['Input vector must have ' num2str(Nbands3Oct) ' third octave bands values']);
end

if (max(VectNiv3Oct)) > 120 || min(VectNiv3Oct) < -60,
    error('Third octave levels must be within interval [-60, 120] dBSPL (for model validity)');
end
    
%% Variables definition

% For information - Third octave bands center frequencies
% FR = [25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 ...
%     6300 8000 10000 12500];

% Ranges of 1/3 octave band levels for correction at low frequencies
% according to equal loudness contours
RAP = [45 55 65 71 80 90 100 120];

% Reduction of 1/3 octave band levels at low frequencies according to 
% equal loudness contours within the eight ranges defined by RAP
DLL = [-32 -24 -16 -10 -5 0 -7 -3 0 -2 0;
    -29 -22 -15 -10 -4 0 -7 -2 0 -2 0;
    -27 -19 -14 -9 -4 0 -6 -2 0 -2 0;
    -25 -17 -12 -9 -3 0 -5 -2 0 -2 0;
    -23 -16 -11 -7 -3 0 -4 -1 0 -1 0;
    -20 -14 -10 -6 -3 0 -4 -1 0 -1 0;
    -18 -12 -9 -6 -2 0 -3 -1 0 -1 0;
    -15 -10 -8 -4 -2 0 -3 -1 0 -1 0];

% Critical band rate level at absolute threshold without taking into
% account the transmission characteristics of the ear
LTQ = [30 18 12 8 7 6 5 4 3 3 3 3 3 3 3 3 3 3 3 3];

% Correction of levels according to the transmission characteristics of the ear
A0  = [0 0 0 0 0 0 0 0 0 0 -0.5 -1.6 -3.2 -5.4 -5.6 -4 -1.5 2 5 12];

% Level differences between free and diffuse sound fields
DDF = [0 0 0.5 0.9 1.2 1.6 2.3 2.8 3 2 0 -1.4 -2 -1.9 -1 0.5 3 4 4.3 4];

% Adaptation of 1/3 octave band levels to the corresponding critical band levels
DCB = [-0.25 -0.6 -0.8 -0.8 -0.5 0 0.5 1.1 1.5 1.7 1.8 1.8 1.7 1.6 1.4 1.2 0.8 0.5 0 -0.5];

% Upper limits of approximated critical bands in terms of critical band rate
ZUP  = [0.9 1.8 2.8 3.5 4.4 5.4 6.6 7.9 9.2 10.6 12.3 13.8 15.2 16.7 18.1 19.3 20.6 21.8 22.7 23.6 24];

% Range of specific loudness for the determination of the steepness of the
% upper slopes in the specific loudness - critical band rate pattern
RNS = [21.5 18 15.1 11.5 9 6.1 4.4 3.1 2.13 1.36 0.82 0.42 0.30 0.22 0.15 0.10 0.035 0];

% Steepness of the upper slopes in the specific loudness - critical band
% rate pattern for the ranges RNS as a function of the number of the
% critical band
USL = [13 8.2 6.3 5.5 5.5 5.5 5.5 5.5;
    9 7.5 6 5.1 4.5 4.5 4.5 4.5;
    7.8 6.7 5.6 4.9 4.4 3.9 3.9 3.9;
    6.2 5.4 4.6 4.0 3.5 3.2 3.2 3.2;
    4.5 3.8 3.6 3.2 2.9 2.7 2.7 2.7;
    3.7 3.0 2.8 2.35 2.2 2.2 2.2 2.2;
    2.9 2.3 2.1 1.9 1.8 1.7 1.7 1.7;
    2.4 1.7 1.5 1.35 1.3 1.3 1.3 1.3;
    1.95 1.45 1.3 1.15 1.1 1.1 1.1 1.1;
    1.5 1.2 0.94 0.86 0.82 0.82 0.82 0.82;
    0.72 0.67 0.64 0.63 0.62 0.62 0.62 0.62;
    0.59 0.53 0.51 0.50 0.42 0.42 0.42 0.42;
    0.40 0.33 0.26 0.24 0.24 0.22 0.22 0.22;
    0.27 0.21 0.20 0.18 0.17 0.17 0.17 0.17;
    0.16 0.15 0.14 0.12 0.11 0.11 0.11 0.11;
    0.12 0.11 0.10 0.08 0.08 0.08 0.08 0.08;
    0.09 0.08 0.07 0.06 0.06 0.06 0.06 0.05;
    0.06 0.05 0.03 0.02 0.02 0.02 0.02 0.02];

%% Correction of 1/3 octave band levels according to equal loudness
% contours (XP) and calculation of the intensities for 1/3 octave bands up
% to 315Hz

TI = zeros(1, size(DLL,2));
for i = 1:size(DLL,2),
    
    j = 1;
    while ( (VectNiv3Oct(i) > (RAP(j) - DLL(j,i))) && j < 8 ),
        j = j+1;
    end;
    
    XP = VectNiv3Oct(i) + DLL(j,i);
    TI(i) = 10^(XP/10);
    
end;

%% Determination of levels (LCB) within the first three critical bands

GI(1) = sum(TI(1:6));   % sum of 6 third octave bands from 25 Hz to 80 Hz
GI(2) = sum(TI(7:9));   % sum of 3 third octave bands from 100 Hz to 160 Hz
GI(3) = sum(TI(10:11)); % sum of 2 third octave bands from 200 Hz to 250 Hz

FNGI = 10*log10(GI);
LCB = zeros(length(GI),1);

for i = 1:length(GI)
    if GI(i) > 0
        LCB(i) = FNGI(i);
    end
end

%% Calculation of main loudness

Ncriticalbands = 20;
S = 0.25;
Ntotalbarkbands = 24;
BarkStep = 0.1;
LE = zeros(1, Ncriticalbands+1);
NM = zeros(1, Ncriticalbands+1);

for i = 1:Ncriticalbands,
    LE(i) = VectNiv3Oct(i+8);

    if i <= 3,
        LE(i) = LCB(i);
    end;

     LE(i) = LE(i) - A0(i);
     NM(i) = 0;
 
     if FieldType == 1,
         LE(i) = LE(i) + DDF(i);
     end;
 
     if LE(i) > LTQ(i),
          LE(i) = LE(i) - DCB(i);
          MP1 = 0.0635 * 10^(0.025*LTQ(i));
          MP2 = (1 - S + S*10^((LE(i)-LTQ(i))/10))^0.25 - 1;
          NM(i) = MP1 * MP2;
 
          if NM(i) <= 0
              NM(i) = 0;
         end;
 
     end;
end;

NM(Ncriticalbands + 1) = 0;

% correction of specific loudness within the first critical band taking
% into account the dependence of absolute threshold within the band
KORRY = 0.4 + 0.32*NM(1)^0.2;

if KORRY > 1;
    KORRY = 1;
end;

NM(1) = NM(1)*KORRY;

% Initial values settings
N = 0;
Z1 = 0;
N1 = 0;
IZ = 1;
Z = 0.1;
NS = zeros(1, round(Ntotalbarkbands/BarkStep));

% loop over critical bands
for i = 1:Ncriticalbands+1,
    
    ZUP(i) = ZUP(i) + 0.0001;
    IG = i - 1;

    if IG > 8  % steepness of upper slope (USL) for bands above 8th one are identical
        IG = 8;
    end;

    while Z1 < ZUP(i),
    
        if N1 <= NM(i),
               % contribution of unmasked main loudness to total loudness
               % and calculation of values 
             if N1 < NM(i),
                j=1;
                
                while (RNS(j) > NM(i)) && (j < 18),% determination of the number j corresponding
                    j = j+1;                       % to the range of specific loudness
                end;
                
            end;

            Z2 = ZUP(i);
            N2 = NM(i);
            N = N + N2*(Z2-Z1);
            k = Z;                     % initialisation of k
            
            while (k <= Z2),
                NS(IZ) = N2;
                IZ = IZ + 1;                           
                k = k+BarkStep;
            end;
            
            Z = k; 
            
        else %if N1 > NM(i)
             % decision wether the critical band in question is completely
             % or partly masked by accessory loudness

            N2 = RNS(j);

            if N2 < NM(i),
                N2 = NM(i);
            end;
            
            DZ = (N1-N2) / USL(j,IG);
            Z2 = Z1 + DZ;                                        

            if Z2 > ZUP(i),
                Z2 = ZUP(i);
                DZ = Z2 - Z1;
                N2 = N1 - DZ*USL(j,IG);
            end;
            
            N = N + DZ*(N1+N2)/2;
            k = Z;                     % initialisation of k
            
            while (k <= Z2)
                NS(IZ) = N1 - (k-Z1)*USL(j,IG);
                IZ = IZ + 1;
                k = k+BarkStep;
            end;
            
            Z = k; 

        end;

        while (N2 <= RNS(j)) && (j < 18),
            j = j+1;
        end;
        
        if (N2 <= RNS(j)) && (j >= 18),
            j = 18;
        end;

        Z1 = Z2;     % N1 and Z1 for next loop
        N1 = N2;

    end;

end; % end of loop over critica bands


% post-processing
if N < 0,
    N = 0;
end;

if N <= 16,
    N = floor(N*1000+0.5)/1000;   % total loudness is rounded to 3 decimals
else
    N = floor(N*100+0.5)/100;     % total loudness is rounded to 2 decimals
end;

%% output data

N_specif = NS;
N_tot = N;
BarkAxis = 0.1:BarkStep:Ntotalbarkbands;

% Loudness level calculation

LN = gene_sone2phon_ISO532B( N_tot );
