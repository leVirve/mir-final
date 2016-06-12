function [result] = listfile(path, rule, range)

    % if no specified rule, default: list all files under `path`
    if nargin == 1
        rule = '\*';
    end
    
    files = dir([path rule]);
    files(1:2) = [];
    result = fullfile(path, {files.name});

    % if specify sub-list range
    if nargin == 3
        result = result(range);
    end
