function Np = gene_exc2specificloudness(Exc, Ethrq, C, A, alpha, G)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USE:
%   Np = gene_exc2specificloudness(Exc, Ethrq, C, A, alpha, G)
%
% FUNCTION:
%   Calculation of specific loudness from excitation pattern
%   according to norm ANSI S3.4-2007, section 3.6.*
%
% INPUT:
%   Exc   : excitation pattern
%   Ethrq : peak excitation at absolute threshold produced by a sinusoidal signal
%   C     : constant C
%   A     : A parameter
%   alpha : alpha parameter
%   G     : G parameter
%
% OUTPUT:
%   Np    : specific loudness
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% index of the areas of levels
id_mid = find((Exc >= Ethrq) .* (Exc <= 10^10));
id_inf = find(Exc <= Ethrq);
id_sup = find(Exc > 10^10);

Np = zeros(size(Exc));

% low levels
Np(id_inf) = C * (2 * Exc(id_inf) ./ (Exc(id_inf)+Ethrq(id_inf)) ).^1.5 ...
            .* ( (G(id_inf).*Exc(id_inf)+A(id_inf)).^alpha(id_inf) - A(id_inf).^alpha(id_inf) );

% intermediate levels
Np(id_mid) = C * ( ( G(id_mid).*Exc(id_mid)+A(id_mid) ) .^ alpha(id_mid) ...
                    - A(id_mid).^alpha(id_mid) );

% high levels
Np(id_sup) = C * ( Exc(id_sup) / 1.0707 ) .^ 0.2;
% Np(id_sup) = C * ( Exc(id_sup) / 1.04e6 ) .^ 0.5; % former formula for
% article "A model for the prediction of thresholds, loudness, and partial loudness",
% B.C.J. Moore, B.R. Glasberg, T. Baer JAES 45(4), 1997
