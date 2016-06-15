%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialization
% 2. Feature Extraction  
% 3. Generate SVM Model
% 4. two segmentation algo
% 5. GMM (and K-means)
% 6. apply SVM Models
% 7. f-measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear all; close all;
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialization                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load all files
[PATH_AUDITORY_TOOLBOX] = get_env_variables();

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

% Determine songs for SVM or RAW audio 
num_songs_all = length(listOfSongs);
num_songs_svm = 60;
num_songs_raw = 45;

rp = randperm(num_songs_all);
index_songs_svm = rp(1:num_songs_svm);
index_songs_raw = rp(num_songs_svm + 1:num_songs_svm +num_songs_raw);

clear path_audio_rwc path_audio_ours  PATH_AUDITORY_TOOLBOX path_annotation rp;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Feature Extraction                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% segmentatoin by groundtruth
songs_seg = get_gt_sgmts(listOfAnnotations);

% -- Select training and testing set randomly.
Timbre = {'mfcc', 'brightness', 'zerocorss', 'rolloff', 'centroid', 'spread', 'skewness',...
            'kurtosis', 'flatness', 'entropy', 'attackslope', 'attacktime', 'attackleap'};

for i = 1 : 2 : 3
   filename = sprintf('songs_seg_%s.mat', Timbre{i});
   songs_seg = merge_struct_field(songs_seg, load(filename));
end

pool_num = num_songs_svm;
train_num = round(num_songs_svm * 0.8);
test_num = num_songs_svm - train_num;

rp = randperm(pool_num);
%%
w = 1024;
h = 512;

Xtrain = [];
Ytrain = [];
for i = 1 : train_num
    ri = rp(i);
    Xtemp = [];
    nXtemp = numel(songs_seg{ri});
    for j = 1 : numel(songs_seg{ri})
        Xtemp = [Xtemp; songs_seg{ri}{j}.(Timbre{1})' songs_seg{ri}{j}.(Timbre{3})'];
        if (strcmp(songs_seg{ri}{j}.label, 'chorus'))
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
    ri = rp(i);
    Xtemp = [];
    nXtemp = numel(songs_seg{ri});
    for j = 1 : numel(songs_seg{ri})
        Xtemp = [Xtemp; songs_seg{ri}{j}.(Timbre{1})' songs_seg{ri}{j}.(Timbre{3})'];
        if (strcmp(songs_seg{ri}{j}.label, 'chorus'))
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
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Generate SVM model                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
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

        model = svmtrain(Ytrain, Xtrain, sprintf('-t 2 -c %f -g %f -q', Cs(c), Gs(g))); % quiet mode

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
[~, accuracy, ~] = svmpredict(Yvalidation, Xvalidation, bestModel);

clearvars -except index_songs_raw listOfAnnotations listOfSongs num_songs_all num_songs_raw num_songs_svm ...
         songs_seg bestAccuraccy bestModel bestC bestG;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. two segmentation algo                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
path_json = './msaf_annotations';
seg_algo = 'cnmf'; % scluster or cnmf
listOfJsons = [
    listfile(fullfile(path_json, ['Disc1/', seg_algo]))';
    listfile(fullfile(path_json, ['Disc2/', seg_algo]))';
    listfile(fullfile(path_json, ['Disc3/', seg_algo]))';
    listfile(fullfile(path_json, ['Sa/', seg_algo]))';
    listfile(fullfile(path_json, ['Yi/', seg_algo]))';
    listfile(fullfile(path_json, ['Wu/', seg_algo]))';
];

for i = 1:length(listOfJsons)
    
    disp(['get Segmentation:', num2str(i)]);
    
    fname = listOfJsons{i};
    fid = fopen(fname);
    data = JSON.parse(char(fread(fid,inf)'));
    fclose(fid);
    
    sgmt_amount = length(data.annotations{1,1}.data);
    songs_seg_raw{i}.filename = listOfSongs{i};
    songs_seg_raw{i}.sgmt_amount = sgmt_amount;
    for j = 1:sgmt_amount
        songs_seg_raw{i}.sgmt{j}.index = j;
        songs_seg_raw{i}.sgmt{j}.start = data.annotations{1,1}.data{1,j}.time;
        songs_seg_raw{i}.sgmt{j}.label = data.annotations{1,1}.data{1,j}.value;
        songs_seg_raw{i}.sgmt{j}.duration = data.annotations{1,1}.data{1,j}.duration;
        % fprintf('%s %d %f %f',listOfSongs{i}, j ,data.annotations{1,1}.data{1,j}.time, data.annotations{1,1}.data{1,j}.duration);
    end  
end

clear i j fid seg_algo sgmt_amount path_json fname data 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. GMM (and K-means)                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. apply SVM Models                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = 1024;
h = 512;

Xtrain = [];
Ytrain = [];
for i = 1 : num_songs_raw
    ri = index_songs_raw(i);
    Xtemp = [];
    nXtemp = numel(songs_seg{ri});
    for j = 1 : numel(songs_seg{ri})
        extract_timbre_feature
        Xtemp = [Xtemp; songs_seg{ri}{j}.(Timbre{1})' songs_seg{ri}{j}.(Timbre{3})'];
        if (strcmp(songs_seg{ri}{j}.label, 'chorus'))
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


