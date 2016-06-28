function [] = set_toolbox()
    % Must add AuditoryToolbox through VARIABLE, due to some hacky solution
    % for solving the overwriting buit-in function 'spectrogram' by AuditoryToolbox
    addpath('./toolbox/AuditoryToolbox');
    addpath('./toolbox/ChromaToolbox');
    addpath('./toolbox/MIRToolbox');
    addpath('./toolbox/libsvm-3.21/matlab');
    addpath('./kmeans_ver');
end
