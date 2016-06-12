%% clean
clc; clear all; close all;

%% set path
PATH_AUDITORY_TOOLBOX = get_env_variables();

%% initial
% -- RWC - GT and SONGS --

path_audio_rwc  = '.\rwc48mp3';
path_audio_ours = '.\ours';
path_annotation = '.\annotations'

listOfAnnotations = [
    listfile(fullfile(path_annotation, 'AIST.RWC-MDB-P-2001.CHORUS'), '\RM-*.CHORUS.txt', 1:48)';
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

clear path_audio_rwc path_audio_ours;
%% Segmentatoin Algo

% SM
% ...
%% segmentatoin by groundtruth
songs_seg = get_gt_sgmts(listOfAnnotations);

%% Extract Features

    % -- Select training and testing set randomly.

pool_num = 85;
train_num = 51;
test_num = 34;
rp = randperm(pool_num);
song_pool_index =  rp(1 : pool_num);
for i = 1 : pool_num
    listOfSong_pool{i} = listOfSongs{song_pool_index(i)};
end

%%
w = 1024;
h = 512;

Xtrain = [];
Ytrain = [];
for i=1:train_num
    sgmts = audio_sgmt(listOfSong_pool{i}, songs_seg{i});
    Xtemp = [];
    nXtemp = length(sgmts);
    for j = 1 : length(sgmts)
        clc;
        fprintf('%d %d %s\n', i, j, listOfSong_pool{i});

        x = extract_timbre_feature(sgmts{j}.audio', sgmts{j}.fs, w, h, 'mfcc');
        Xtemp = [Xtemp; x'];

        if (strcmp(songs_seg{i}{j}.label, 'chorus'))
            Ytrain = [Ytrain; 1];
        else
            Ytrain = [Ytrain; 0];
        end
    end
    featMean = mean(Xtemp);
    featSTD = std(Xtemp);
    Xtemp = (Xtemp - repmat(featMean, nXtemp, 1)) ./ (repmat(featSTD, nXtemp, 1) + eps);
    Xtrain = [Xtrain; Xtemp];
end

%%
Xvalidation = [];
Yvalidation = [];
for i = train_num + 1 : train_num + test_num
    sgmts = audio_sgmt(listOfSong_pool{i}, songs_seg{i});
    Xtemp = [];
    nXtemp = length(sgmts);
    for j = 1:length(sgmts)
        clc;
        fprintf('%d %d %s\n', i, j, listOfSong_pool{i});
        x = extract_timbre_feature(sgmts{j}.audio', sgmts{j}.fs, w, h, 'mfcc');
        Xtemp = [Xtemp; x'];

        if (strcmp(songs_seg{i}{j}.label, 'chorus'))
            Yvalidation = [Yvalidation; 1];
        else
            Yvalidation = [Yvalidation; 0];
        end
    end
    featMean = mean(Xtemp);
    featSTD = std(Xtemp);
    Xtemp = (Xtemp - repmat(featMean, nXtemp, 1)) ./ (repmat(featSTD, nXtemp, 1) + eps);
    Xvalidation = [Xvalidation; Xtemp];
end
%% train classifier

g0 = 1/size(Xtrain, 2);
Cs = [1 10 100 1000]; % possible range of the parameter C
Gs = [g0 g0/10 g0/100]; % possible range of the parameter gamma

% default
bestAccuraccy = 0.25;
bestModel = {};
bestC = nan;
bestG = nan;

for c=1:length(Cs)
    for g=1:length(Gs)

        model = svmtrain(Ytrain,Xtrain,sprintf('-t 2 -c %f -g %f -q', Cs(c), Gs(g))); % quiet mode

        [Ypred, accuracy, ~] = svmpredict(Yvalidation, Xvalidation, model, '-q');
        accuracy = accuracy(1);

        disp(sprintf('c=%f g=%f accuracy=%f', Cs(c), Gs(g), accuracy))

        if accuracy > bestAccuraccy
            bestAccuraccy = accuracy;
            bestModel = model;
            bestC = Cs(c);
            bestG = Gs(g);
        end
    end
end

% from Ypred and Yvalidation you can create the confusion tlabe
[Ypred, accuracy, ~] = svmpredict(Yvalidation, Xvalidation, bestModel);

 ConfusionTable = zeros(4, 4);

for i = 1 : size(Ypred, 1)
    ConfusionTable(Yvalidation(i), Ypred(i)) = ConfusionTable(Yvalidation(i), Ypred(i)) + 1;
end

