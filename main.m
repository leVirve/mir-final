%% clean
clc; clear all; close all;
mirwaitbar(0);

%% set path
[PATH_AUDITORY_TOOLBOX] = get_env_variables();

%% initial
% -- RWC - GT and SONGS --

path_audio_rwc  = './rwc48mp3';
path_audio_ours = './Label Dataset(song)';
path_annotation = './annotations';

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
%           1           2            3           4          5           6
Timbre = {'mfcc', 'brightness', 'zerocorss', 'rolloff', 'centroid', 'spread',...
          'skewness', 'kurtosis', 'flatness', 'entropy', 'attackslope',...
          'attacktime', 'attackleap'};
%              12            13

clear path_audio_rwc path_audio_ours;
%% Segmentatoin Algo

% SM
% ...
%% segmentatoin by groundtruth
songs_seg = get_gt_sgmts(listOfAnnotations);


%%
w = 1024;
h = 512;

chroma_params.w = w;
chroma_params.gamma = 10;
chroma_params.visualize = 0;

for k = 14 : 14 %length(Timbre)
    for i = 1 : length(listOfSongs)
        disp(i);
        sgmts = audio_sgmt(listOfSongs{i}, songs_seg{i});
        for j = 1 : length(sgmts)
%             songs_seg{i}{j}.chroma = gen_chroma(sgmts{j}.audio', chroma_params);
            songs_seg{i}{j}.(Timbre{k}) = extract_features(sgmts{j}.audio', sgmts{j}.fs, w, h, Timbre{k});
        end
    end
    filename = sprintf('songs_seg_%s.mat', Timbre{k});
    save(filename, 'songs_seg');
    clear songs_seg;
    songs_seg = get_gt_sgmts(listOfAnnotations);
end


%% Extract Features

%   - thumbnailing
%   - MFCC, Timbre, Brightness, ...etc

%% SVM



%% Validation



