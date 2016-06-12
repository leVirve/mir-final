%% clean
clc; clear all; close all;

%% set path
[PATH_ANNOTATIONS, PATH_AUDITORY_TOOLBOX] = get_env_variables();

%% initial
% -- RWC - GT and SONGS --

path_audio_rwc  = '.\rwc48mp3';
path_audio_ours = '.\ours';
path_ground_rwc = '.\annotations\AIST.RWC-MDB-P-2001.CHORUS';

annotation_files = dir([path_ground_rwc, '\RM-*.CHORUS.txt']);

listOfAnnotations_RWC = fullfile(path_ground_rwc, {annotation_files.name})';
listOfAnnotations = [listOfAnnotations_RWC(1:48);...
                     listfile(fullfile(PATH_ANNOTATIONS, 'Sa'))';...
                     listfile(fullfile(PATH_ANNOTATIONS, 'Yi'))';...
                     listfile(fullfile(PATH_ANNOTATIONS, 'Wu'))'];
listOfSongs = [listfile(fullfile(path_audio_rwc, 'Disc1'))';...
               listfile(fullfile(path_audio_rwc, 'Disc2'))';...
               listfile(fullfile(path_audio_rwc, 'Disc3'))';...
               listfile(fullfile(path_audio_ours, 'Sa'))';...
               listfile(fullfile(path_audio_ours, 'Yi'))';...
               listfile(fullfile(path_audio_ours, 'Wu'))'];

clear annotation_files listOfAnnotations_rwc path_gt_rwc path_au_rwc path_au_ours;
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

for i = 1 : 1   %length(listOfSongs)
    sgmts = audio_sgmt(listOfSongs{i}, songs_seg{i});
    for j = 1 : length(sgmts)
        songs_seg{i}{j}.chroma = gen_chroma(sgmts{j}.audio', chroma_params);
        songs_seg{i}{j}.mfcc = extract_timbre_feature(sgmts{j}.audio', sgmts{j}.fs, w, h, 'mfcc');
    end
end

%% Extract Features

%   - thumbnailing
%   - MFCC, Timbre, Brightness, ...etc

%% SVM



%% Validation



