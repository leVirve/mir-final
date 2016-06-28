function [sgmts] = audio_sgmt(audio_path, sgmts_info)
    [audio, fs] = audioread(audio_path);
    sgmts = cell(size(sgmts_info));
    for i = 1 : length(sgmts_info)
        interval = floor(sgmts_info{i}.range * fs);
        if(interval(1) == 0), interval(1) = 1; end
        sgmts{i}.audio = audio(interval(1) : interval(2));
        sgmts{i}.fs = fs;
    end
end
