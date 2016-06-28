function A = gene_A_Parameter_ANSI_S34_2007( G )

%%%%
% This function gives the value of A from G.
% Loudness model of Moore et al.
% Reference: Table 6 of norm ANSI S3.4-2007.
%
% USE
%   A = gene_A_Parameter_ANSI_S34_2007( G )
%
% INPUT
%   G: low level gain of the cochlear amplifier (in dB, using G = 10*log10(G_linear))
%      may be a scalar or a vector
%
% OUTPUT
%   A: constant used for the computation of specific loudness
%
%%%%


G_ref = [2454531 2378397 2278169 1978305 1621055 1123866 945902 738338 589392 497718 362882 250042 177405 ...
         157745 124006 94596 75663 52501 35451 18750 7845 2470 0] * -1e-5;
A_ref = [885200 863150 835840 765258 699954 610719 582490 555322 536425 525064 510314 498203 490515 ...
         488449 484918 481854 479890 477494 475736 474019 472899 472349 472096] * 1e-5;

A = interp1(G_ref, A_ref, G, 'cubic');

