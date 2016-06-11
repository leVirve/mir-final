%% set path and load files

clc; clear all; close all;
cd 'D:\mir final';
PATH_ANNOTATIONS = 'D:\mir final\annotations';
PATH_AUDIOS = 'D:\mir final\audios';

% -- RWC - GT and SONGS --
path_gt_rwc = [PATH_ANNOTATIONS, '\AIST.RWC-MDB-P-2001.CHORUS'];
path_au_rwc = [PATH_AUDIOS, '\rwc48mp3'];

annotation_files = dir([path_gt_rwc, '\RM-*.CHORUS.txt']);
listOfAnnotations = fullfile(path_gt_rwc, {annotation_files.name})';
listOfAnnotations = listOfAnnotations(1:48);

listOfSongsDisc1 = listfile(fullfile(path_au_rwc,'Disc1'))';
listOfSongsDisc2 = listfile(fullfile(path_au_rwc,'Disc2'))';
listOfSongsDisc3 = listfile(fullfile(path_au_rwc,'Disc3'))';
listOfSongs = [listOfSongsDisc1; listOfSongsDisc2; listOfSongsDisc3];

% -- Our dataset --
listOfAnnotations_Sa = listfile(fullfile(PATH_ANNOTATIONS,'sa'))';
listOfAnnotations_Yi = listfile(fullfile(PATH_ANNOTATIONS,'yi'))';
% listOfAnnotations_Wu = listfile(fullfile(PATH_ANNOTATIONS,'wu'))';

path_au_ours = [PATH_AUDIOS, '\ours'];
listOfSongsSa = listfile(fullfile(path_au_ours,'sa'))';
listOfSongsYi = listfile(fullfile(path_au_ours,'yi'))';
% listOfSongsWu = listfile(fullfile(path_au_ours,'wu'))';

listOfAnnotations = [listOfAnnotations_Yi];
listOfSongs = [listOfSongsYi];

clear listOfSongsDisc1 listOfSongsDisc2 listOfSongsDisc3 annotation_files path_gt_rwc path_au_rwc;
clear listOfAnnotations_Sa listOfAnnotations_Yi listOfAnnotations_Wu path_au_ours
clear listOfSongsSa listOfSongsYi listOfSongsWu
%% Segmentatoin Algo

% SM
% ... 
%% segmentatoin by groundtruth
songs_seg = segmentation_by_gt(listOfAnnotations, listOfSongs);

%% Extract Features

%   - thumbnailing
%   - MFCC, Timbre, Brightness, ...etc

%% SVM

%% Validation



