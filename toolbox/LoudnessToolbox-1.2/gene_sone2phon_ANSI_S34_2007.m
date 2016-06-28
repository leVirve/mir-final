function phon = gene_sone2phon_ANSI_S34_2007(sone)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% phon = gene_sone2phon_ANSI_S34_2007(sone)
%
% Converts a sone value to a phon value
% according to the norm ANSI S3.4 - 2007
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phon_ref = [0 0 1 2 3 4 5 7.5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120];

sone_ref =  [0 0.0011 0.0018 0.0028 0.0044 0.0065 0.0088 0.017 0.029 0.07 0.142 0.255 0.422 0.662 0.997 1.461 ...
             2.098 2.970 4.166 5.813 8.102 11.326 15.98 22.929 33.216 48.242 70.362 103.274 152.776 227.855 341.982];
         
phon = interp1(sone_ref, phon_ref, sone, 'linear');