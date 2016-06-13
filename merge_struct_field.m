function [merged_song_seg] = merge_struct_field(old_song_seg, new_song_seg)
    % old_song_seg = source songs_seg
    % new_song_seg = what load('songs_seg_<feature>.mat'); return

    % malloc cell space for song level
    merged_song_seg = cell(numel(old_song_seg), 1);
    for i = 1 : numel(old_song_seg) % song level
        
        % malloc cell space for segment level
        merged_song_seg{i, 1} = cell(numel(old_song_seg{i, 1}), 1);
        
        for j = 1 : numel(old_song_seg{i, 1}) % segment level
        
            % Remove overlapping fields from first struct
            merged_song_seg{i, 1}{j, 1} = rmfield(old_song_seg{i, 1}{j, 1}, intersect(fieldnames(old_song_seg{i, 1}{j, 1}), fieldnames(new_song_seg.songs_seg{i, 1}{j, 1})));

            % Obtain all unique names of remaining fields
            names = [fieldnames(merged_song_seg{i, 1}{j, 1}); fieldnames(new_song_seg.songs_seg{i, 1}{j, 1})];

            % Merge both structs
            merged_song_seg{i, 1}{j, 1} = cell2struct([struct2cell(merged_song_seg{i, 1}{j, 1}); struct2cell(new_song_seg.songs_seg{i, 1}{j, 1})], names, 1);
        end
    end
end
