function [songs] = segmentation_by_gt(listOfAnnotaions)

    songs = cell(size(listOfAnnotaions));
    for i = 1:length(listOfAnnotaions)
        fh = fopen(listOfAnnotaions{i});
        C = textscan(fh, '%f %f %[^\r\n]');
        fclose(fh);

        ss = cell(size(C{1}));
        for sgmt = 1:length(C{1})
            [tag, other] = parse_annotation_tag(C{3}{sgmt});
            s = struct(...
                'label', tag, ...
                'range', [C{1}(sgmt) / 100, C{2}(sgmt) / 100], ...
                'other', other);
            ss{sgmt} = s;
        end
        songs{i} = ss;
    end

end
