function Alpha = gene_AlphaParameter_ANSI_S34_2007( G )

%%%%
% This function gives the value of Alpha from G.
% Loudness model of Moore et al.
% Reference: Table 5 of norm ANSI S3.4-2007.
%
% USE
%   Alpha = gene_AlphaParameter_ANSI_S34_2007( G )
%
% INPUT
%   G: low level gain of the cochlear amplifier (in dB, using G = 10*log10(G_linear))
%      may be a scalar or a vector
%
% OUTPUT
%   Alpha: exponent used for the computation of specific loudness
%
%%%%


G_ref = [-25 -20 -15 -10 -5 -0];
Alpha_ref = [26692 25016 23679 22228 21055 20000]*1e-5;

Alpha = interp1(G_ref, Alpha_ref, G, 'cubic');

