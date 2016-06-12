function [PATH_AUDITORY_TOOLBOX] = get_env_variables()

    PATH_AUDITORY_TOOLBOX = '.\toolbox\AuditoryToolbox';

    addpath('.\toolbox\ChromaToolbox');
    addpath('.\toolbox\MIRToolbox');

    % Must add AuditoryToolbox through VARIABLE, due to some hacky solution
    % for solving the overwriting buit-in function `spectrogram` by AuditoryToolbox
    addpath(PATH_AUDITORY_TOOLBOX);
end
