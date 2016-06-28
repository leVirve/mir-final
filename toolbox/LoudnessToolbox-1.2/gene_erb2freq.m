function freq = gene_erb2freq(erb)

%%%%%
% USE:
%   freq = gene_erb2freq(erb)
%
% FUNCTION:
%   transformation from ERB number to center frequency of the band, in Hz
%   according to ANSI S3.4-2007
%
% INPUT:
%   erb: Equivalent Rectangular Bandwith band number
%
% OUTPUT:
%   freq: center frequency of the corresponding ERB band, in Hz
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%

freq = ( 10.^( erb/21.366) - 1 ) / 0.004368;


