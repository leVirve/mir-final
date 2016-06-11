function [files,files_short] = listfile(path)

names = dir(path);
files = {}; % complete file path
files_short = {}; % only the file name 

for n=1:length(names)
    
    if strcmp(names(n).name,'.'), continue; end
    if strcmp(names(n).name,'..'), continue; end
        
    files{end+1} = fullfile(path,names(n).name);
    files_short{end+1} = names(n).name;
    
end
