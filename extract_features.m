function [feature, raw] = extract_features(audio, fs, w, h, mode)
    % audio: file name
    % fs: sample frequency
    % w: window size
    % h: hop size
    % mode: feature name
    
    % normalize with respect to RMS energy
    a = miraudio(audio, fs, 'Normal');
    f = mirframe(a, 'Length', w, 'sp', 'Hop', h, 'sp');

    if strcmp(mode, 'mfcc') == 1
        S = mirspectrum(f);
        result = mirmfcc(S, 'Rank', 1:20);
    elseif strcmp(mode, 'brightness') == 1
        S = mirspectrum(f);
        result = mirbrightness(S);
    elseif strcmp(mode, 'zerocorss') == 1
        result = mirzerocross(f);  
    elseif strcmp(mode, 'rolloff') == 1
        S = mirspectrum(f);
        result = mirrolloff(S);
    elseif strcmp(mode, 'centroid') == 1
        S = mirspectrum(f);
        result = mircentroid(S);
    elseif strcmp(mode, 'spread') == 1
        S = mirspectrum(f);
        result = mirspread(S);
    elseif strcmp(mode, 'skewness') == 1
        S = mirspectrum(f);
        result = mirskewness(S);
    elseif strcmp(mode, 'kurtosis') == 1
        S = mirspectrum(f);
        result = mirkurtosis(S);
    elseif strcmp(mode, 'flatness') == 1
        S = mirspectrum(f);
        result = mirflatness(S);
    elseif strcmp(mode, 'entropy') == 1
        S = mirspectrum(f);
        result = mirentropy(S);
    elseif strcmp(mode, 'attackslope') == 1
        o = mironsets(a, 'Attacks');
        result = mirattackslope(o);
    end
    raw = mirgetdata(result);
    feature = [mean(raw, 2); std(raw, 0, 2)]; % e.g. feature(2, 1) = std(raw(1, :))
end
