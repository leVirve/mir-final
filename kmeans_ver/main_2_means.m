%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Segmentaion
% 2. Extract Features
% 3. 2-means
% 4. Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear all;

cd 'D:\mir_final_V2';
path_audio_rwc  = './rwc48mp3';
path_audio_ours = './Label Dataset(song)';
path_annotation = './annotations';
path_json = './msaf-tag';

listOfAnnotations = [
    listfile(fullfile(path_annotation, 'AIST.RWC-MDB-P-2001.CHORUS'), '/RM-*.CHORUS.txt', 1:48)';
    listfile(fullfile(path_annotation, 'Sa'))';
    listfile(fullfile(path_annotation, 'Yi'))';
    listfile(fullfile(path_annotation, 'Wu'))';
];
listOfSongs = [
    listfile(fullfile(path_audio_rwc, 'Disc1'))';
    listfile(fullfile(path_audio_rwc, 'Disc2'))';
    listfile(fullfile(path_audio_rwc, 'Disc3'))';
    listfile(fullfile(path_audio_ours, 'Sa'))';
    listfile(fullfile(path_audio_ours, 'Yi'))';
    listfile(fullfile(path_audio_ours, 'Wu'))';
];
listOfJsons = [
    listfile(fullfile(path_json, 'Disc1'))';
    listfile(fullfile(path_json, 'Disc2'))';
    listfile(fullfile(path_json, 'Disc3'))';
    listfile(fullfile(path_json, 'Sa'))';
    listfile(fullfile(path_json, 'Yi'))';
    listfile(fullfile(path_json, 'Wu'))';
];
clear path_audio_rwc path_audio_ours path_json;
%% Segmentatoin

for i = 1:length(listOfJsons)
    
    disp(['get Segmentation:', num2str(i)]);
    
    fname = listOfJsons{i};
    fid = fopen(fname);
    data = JSON.parse(char(fread(fid,inf)'));
    fclose(fid);
    
    sgmt_amount = length(data.annotations{1,1}.data);
    song_seg{i}.filename = listOfSongs{i};
    song_seg{i}.sgmt_amount = sgmt_amount;
    for j = 1:sgmt_amount
        song_seg{i}.sgmt{j}.index = j;
        song_seg{i}.sgmt{j}.start = data.annotations{1,1}.data{1,j}.time;
        song_seg{i}.sgmt{j}.label = data.annotations{1,1}.data{1,j}.value;
        song_seg{i}.sgmt{j}.duration = data.annotations{1,1}.data{1,j}.duration;
        % fprintf('%s %d %f %f',listOfSongs{i}, j ,data.annotations{1,1}.data{1,j}.time, data.annotations{1,1}.data{1,j}.duration);
    end  
end
%% Extract Features


for i = 1:1%length(listOfJsons)
    total_sgmts = 1;
    for j = 1:song_seg{i}.sgmt_amount
        
        % Feature - Count Repeated Sgmt
        
         score(total_sgmts) = feature_repeated_sgmt(song_seg{i}.sgmt, j);
         total_sgmts = total_sgmts+1;
        % fprintf('%c %f\n', song_seg{i}.sgmt{j}.label, score);
        
            
        
    end
end
%%

arr = [];
for i =1:length(song_seg{1}.sgmt)
    arr = [arr,song_seg{1}.sgmt{i}.start];
end

%%
blocks = [];
for i =1:length(song_seg{1}.sgmt)
    blocks = [blocks repmat(song_seg{1}.sgmt{i}.label-'A', 1, floor(song_seg{1}.sgmt{i}.duration))];
end

imagesc(1:360,1:11,blocks)
set(gca,'XTick',0:10:360)
%set(gca,'XTickLabelMode', 'manual', 'XTickLabel', arr)
%% 2-means

idx = kmeans(score',2);

% plot(X(:,1),X(:,2),'k*','MarkerSize',5);
%% Evaluation