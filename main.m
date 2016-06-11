%% set path
clc; clear all; close all;

PATH_ANNOTATIONS = 'annotations';
PATH_AUDIOS = 'C:\Users\salas\Downloads';

%% initial
% -- RWC - GT and SONGS --

path_gt_rwc = [PATH_ANNOTATIONS, '\AIST.RWC-MDB-P-2001.CHORUS'];
path_au_rwc = [PATH_AUDIOS, '\rwc48mp3'];
path_au_ours = [PATH_AUDIOS, '\ours'];

annotation_files = dir([path_gt_rwc, '\RM-*.CHORUS.txt']);
listOfAnnotations_rwc = fullfile(path_gt_rwc, {annotation_files.name})';

listOfAnnotations = [...
    listOfAnnotations_rwc(1:48);...
    listfile(fullfile(PATH_ANNOTATIONS,'sa'))';...
    listfile(fullfile(PATH_ANNOTATIONS,'yi'))';...
    % listfile(fullfile(PATH_ANNOTATIONS,'wu'))';...
    ];
listOfSongs = [...
    listfile(fullfile(path_au_rwc,'Disc1'))';...
    listfile(fullfile(path_au_rwc,'Disc2'))';...
    listfile(fullfile(path_au_rwc,'Disc3'))';...
    listfile(fullfile(path_au_ours,'sa'))';...
    listfile(fullfile(path_au_ours,'yi'))';...
    % listfile(fullfile(path_au_ours,'wu'))';...
    ];

clear annotation_files listOfAnnotations_rwc path_gt_rwc path_au_rwc path_au_ours;
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



