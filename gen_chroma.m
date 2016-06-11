function [chroma] = gen_chroma(f_audio, params)

    [~, ~, PATH_AUDITORY_TOOLBOX] = get_env_variables();
    rmpath(PATH_AUDITORY_TOOLBOX);

    shiftFB = estimateTuning(f_audio);

    paramPitch.winLenSTMSP = params.w;
    paramPitch.shiftFB = shiftFB;
    [f_pitch, sideinfo] = audio_to_pitch_via_FB(f_audio, paramPitch, struct());

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = params.gamma;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    paramCLP.visualize = params.visualize;
    [chroma, ~] = pitch_to_chroma(f_pitch, paramCLP, sideinfo);

    addpath(PATH_AUDITORY_TOOLBOX);
