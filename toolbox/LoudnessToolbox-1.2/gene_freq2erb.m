function erb = gene_freq2erb(f)

%%%%%
% USE:
%   erb = gene_freq2erb(f)
%
% FUNCTION:
%   transformation from center frequency to ERB number
%   according to ANSI S3.4-2007
%
% INPUT:
%   freq: center frequency of the corresponding ERB band, in Hz
%
% OUTPUT:
%   erb: Equivalent Rectangular Bandwith band number
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%

erb = 21.366 * log10(0.004368*f + 1);

