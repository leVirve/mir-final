function [ tag, other ] = parse_annotation_tag( annotation )

    C = strsplit(annotation(2:end-1));
    tag = C{1};

    if length(C) == 2
        other = C{2};
    else
        other = '';
    end
end