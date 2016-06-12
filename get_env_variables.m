function [PATH_ANNOTATIONS, PATH_AUDITORY_TOOLBOX] = get_env_variables()

    % PATH_AUDITORY_TOOLBOX = 'D:\VirtualMachines\MIRtoolbox1.6.1\AuditoryToolbox';
    PATH_AUDITORY_TOOLBOX = 'C:\Program Files\MATLAB\R2014a\toolbox\auditorytoolbox';
    PATH_ANNOTATIONS = '.\annotations';

    addpath('.\toolbox\MATLAB-ChromaToolbox2.0');
    % addpath('D:\VirtualMachines\MIRtoolbox1.6.1\MIRToolbox');
    addpath('C:\Program Files\MATLAB\R2014a\toolbox\mirtoolbox');
    
    % Must add AuditoryToolbox through VARIABLE, due to some hacky solution
    % for solving the overwriting buit-in function `spectrogram` by AuditoryToolbox
    addpath(PATH_AUDITORY_TOOLBOX);
end
