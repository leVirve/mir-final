%% set path and load files

clc; clear all; close all;
cd 'D:\mir final';
PATH_ANNOTATION = 'D:\mir final\AIST.RWC-MDB-P-2001.CHORUS\AIST.RWC-MDB-P-2001.CHORUS';
annotation_folder = 'D:\mir final\AIST.RWC-MDB-P-2001.CHORUS\AIST.RWC-MDB-P-2001.CHORUS';
annotation_files = dir([annotation_folder, '\RM-*.CHORUS.txt']);
listOfAnnotations = fullfile(annotation_folder, {annotation_files.name})';

PATH_AUDIO = 'D:\mir final\rwc48mp3';
listOfSongsDisc1 = listfile(fullfile(PATH_AUDIO,'Disc1'))';
listOfSongsDisc2 = listfile(fullfile(PATH_AUDIO,'Disc2'))';
listOfSongsDisc3 = listfile(fullfile(PATH_AUDIO,'Disc3'))';
listOfSongs = [listOfSongsDisc1; listOfSongsDisc2; listOfSongsDisc3];

clear listOfSongsDisc1 listOfSongsDisc2 listOfSongsDisc3 annotation_files annotation_folder;
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



