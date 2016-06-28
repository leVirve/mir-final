function erbWidth = gene_freq2erbWidth(f)

%%%%%
% USE:
%   erbWidth = gene_freq2erbWidth(f)
%
% FUNCTION:
%   transformation from center frequency of the ERB band, in Hz
%   to the bandwidth (ERB) in Hz
%   according to ANSI S3.4-2007 - section 3.5
%
% INPUT:
%   freq: center frequency of the band, in Hz
%
% OUTPUT:
%   erbWidth: ERB in Hz
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%


erbWidth = 24.673 * (1 + 0.004368*f);
