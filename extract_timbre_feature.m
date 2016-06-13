function [feature, raw] = extract_timbre_feature(audio, fs, w, h, mode)
    % file: file name
    % w: window size (in samples)
    % h: hop size (in samples)

    % normalize with respect to RMS energy

    a = miraudio(audio, fs, 'Normal');
    % window length 1024 samples, hop size 512 samples
    % w = 1024;
    % h = 512;
    f = mirframe(a, 'Length', w, 'sp', 'Hop', h, 'sp');
    % compute the spectrogram

    % while S is an object, x is the values inside
    % x = mirgetdata(S); % size: 513 x number of frames
    if strcmp(mode, 'mfcc') == 1
        S = mirspectrum(f);
        result = mirmfcc(S, 'Rank', 1:20);
    end
    if strcmp(mode, 'brightness') == 1
        S = mirspectrum(f);
        result = mirbrightness(S);
    end
    if strcmp(mode, 'zerocorss') == 1
        result = mirzerocross(f);  
    end
    if strcmp(mode, 'rolloff') == 1
        S = mirspectrum(f);
        result = mirrolloff(S);
    end
    if strcmp(mode, 'centroid') == 1
        S = mirspectrum(f);
        result = mircentroid(S);
    end
    if strcmp(mode, 'spread') == 1
        S = mirspectrum(f);
        result = mirspread(S);
    end
    if strcmp(mode, 'skewness') == 1
        S = mirspectrum(f);
        result = mirskewness(S);
    end
    if strcmp(mode, 'kurtosis') == 1
        S = mirspectrum(f);
        result = mirkurtosis(S);
    end
    if strcmp(mode, 'flatness') == 1
        S = mirspectrum(f);
        result = mirflatness(S);
    end
    if strcmp(mode, 'entropy') == 1
        S = mirspectrum(f);
        result = mirentropy(S);
    end
    if strcmp(mode, 'attackslope') == 1
        o = mironsets(a, 'Attacks');
        result = mirattackslope(o);
    end
    if strcmp(mode, 'attacktime') == 1
        o = mironsets(a, 'Attacks');
        result = mirattacktime(o);
    end
    if strcmp(mode, 'attackleap') == 1
        o = mironsets(a,'Attacks');
        result = mirattackleap(o);
    end

    raw = mirgetdata(result);
    feature = [mean(raw, 2); std(raw, 0, 2)]; % e.g. feature(21) = std(raw(1, :))
end
