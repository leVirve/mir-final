function [songs] = segmentation_by_gt( listOfAnnotaions , listOfSongs)

songs = cell(size(listOfAnnotaions));
for i = 1:length(listOfAnnotaions)
    fh = fopen(listOfAnnotaions{i});
    C = textscan(fh, '%f %f %[^\r\n]');
    fclose(fh);

    ss = cell(size(C{1}));
    for sgmt = 1:length(C{1})
        [tag, other] = parse_annotation_tag(C{3}{sgmt});
        s = struct(...
            'audio', 0, ...
            'fs',0,...
            'label', tag, ...
            'start', C{1}(sgmt) / 100, ...
            'end', C{2}(sgmt) / 100, ...
            'other', other);
        ss{sgmt} = s;
    end
    songs{i} = ss;

end

for i = 1:length(listOfSongs)
    [audio,fs] = audioread(listOfSongs{i});
    info = songs{i};
   
    for sgmt = 1:length(info)
        st = floor(info{sgmt}.start * fs);
        ed = floor(info{sgmt}.end * fs);
        if(st == 0) st = 1; end
        info{sgmt}.audio = audio(st:ed);
        info{sgmt}.fs = fs;
    end
    songs{i} = info;

end
