function [chroma] = gen_chroma(f_audio, params)
    % since chromagram needs another version of specific function in the
    % Auditory Toolbox, we need to remove the old one first
    rmpath('./toolbox/AuditoryToolbox');

    shiftFB = estimateTuning(f_audio);

    paramPitch.winLenSTMSP = params.w;
    paramPitch.shiftFB = shiftFB;
    [f_pitch, sideinfo] = audio_to_pitch_via_FB(f_audio, paramPitch, struct());

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = params.gamma;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    paramCLP.visualize = params.visualize;
    [chroma, ~] = pitch_to_chroma(f_pitch, paramCLP, sideinfo);

    % after calculating the chromagram, we now add the Auditory Toolbox back
    addpath('./toolbox/AuditoryToolbox');
end
