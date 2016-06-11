function [f_CLP] = gen_chroma(filename, gamma)

    [f_audio, sideinfo] = chroma_audio(filename);
    shiftFB = estimateTuning(f_audio);

    paramPitch.winLenSTMSP = 4410;
    paramPitch.shiftFB = shiftFB;
    [f_pitch, sideinfo] = audio_to_pitch_via_FB(f_audio, paramPitch, sideinfo);

    paramCLP.applyLogCompr = 1;
    paramCLP.factorLogCompr = gamma;
    paramCLP.inputFeatureRate = sideinfo.pitch.featureRate;
    paramCLP.visualize = 1;
    [f_CLP, ~] = pitch_to_chroma(f_pitch, paramCLP, sideinfo);
