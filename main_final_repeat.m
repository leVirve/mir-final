%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialization
% 2. Feature Extraction  
% 3. Generate SVM Model
% 4. two segmentation algo
% 5. GMM (and K-means)
% 6. apply SVM Models
% 7. f-measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all;
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

% rp = randperm(num_songs_all);
rp = randperm(60);
id_songs_svm = rp(1 : num_songs_svm);
rp = randperm(45) + 60;
id_songs_raw = rp(1 : num_songs_raw);
% id_songs_raw = rp(num_songs_svm + 1 : num_songs_svm +num_songs_raw);

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

train_num = round(num_songs_svm * 0.8);
test_num = num_songs_svm - train_num;

%% Partition for Training and Validation
w = 1024;
h = 512;

Xtrain = [];
Ytrain = [];
for i = 1 : train_num
    ri = id_songs_svm(i);

    
    Xtemp = [];
    nXtemp = numel(songs_seg{ri});
    for j = 1 : numel(songs_seg{ri})

        xr = feature_repeated_sgmt(songs_seg{ri}, j,{'chorus', 'verse', 'intro', 'ending', 'bridge', 'inter', 'pre-chorus', 'post-chorus'});
        Xtemp = [Xtemp; songs_seg{ri}{j}.(Timbre{1})' songs_seg{ri}{j}.(Timbre{3})' xr];
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

Xvalidation = [];
Yvalidation = [];
for i = train_num + 1 : train_num + test_num
    ri = id_songs_svm(i);
    Xtemp = [];
    nXtemp = numel(songs_seg{ri});
    for j = 1 : numel(songs_seg{ri})
        xr = feature_repeated_sgmt(songs_seg{ri}, j,{'chorus', 'verse', 'intro', 'ending', 'bridge', 'inter', 'pre-chorus', 'post-chorus'});
        Xtemp = [Xtemp; songs_seg{ri}{j}.(Timbre{1})' songs_seg{ri}{j}.(Timbre{3})' xr];
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

for c = 1 : length(Cs)
    for g = 1 : length(Gs)

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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. two segmentation algo                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
path_json = './msaf_annotations';
seg_algo = 'scluster'; % scluster or cnmf
listOfJsons = [
    listfile(fullfile(path_json, ['Disc1/', seg_algo]))';
    listfile(fullfile(path_json, ['Disc2/', seg_algo]))';
    listfile(fullfile(path_json, ['Disc3/', seg_algo]))';
    listfile(fullfile(path_json, ['Sa/', seg_algo]))';
    listfile(fullfile(path_json, ['Yi/', seg_algo]))';
    listfile(fullfile(path_json, ['Wu/', seg_algo]))';
];

songs_seg_raw = cell(size(listOfJsons, 1), 1);
for i = 1 : length(listOfJsons)

    disp(['get Segmentation:', num2str(i)]);
    fname = listOfJsons{i};
    fid = fopen(fname);
    data = JSON.parse(char(fread(fid, inf)'));
    fclose(fid);
    
    sgmt_amount = length(data.annotations{1, 1}.data);
    for j = 1 : sgmt_amount
        songs_seg_raw{i}{j, 1}.name = fname;
        songs_seg_raw{i}{j, 1}.index = j;
        songs_seg_raw{i}{j, 1}.start = data.annotations{1, 1}.data{1, j}.time;
        songs_seg_raw{i}{j, 1}.label = data.annotations{1, 1}.data{1, j}.value;
        songs_seg_raw{i}{j, 1}.duration = data.annotations{1, 1}.data{1, j}.duration;
        songs_seg_raw{i}{j, 1}.end = songs_seg_raw{i}{j, 1}.start + songs_seg_raw{i}{j, 1}.duration;
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

% extract feature
w = 1024;
h = 512;

% for i = 1 : num_songs_raw
for i = 1 : 1
    disp(i);
    Xtest = [];
    Ytest = [];
%     ri = id_songs_raw(i);
    ri = 86;
    [audio, fs] = audioread(listOfSongs{ri});
    nXtest = numel(songs_seg_raw{ri});
    
    for j = 1:numel(songs_seg_raw{ri})
        
        s = ceil(songs_seg_raw{ri}{j}.start * fs);
        if(s == 0)
            s = 1;
        end
        e = floor((songs_seg_raw{ri}{j}.start + songs_seg_raw{ri}{j}.duration) * fs);
        audio_temp = audio(s:e);
        x1 = extract_features(audio_temp', fs, w, h, 'mfcc');
        x2 = extract_features(audio_temp', fs, w, h, 'zerocorss');
        xr = feature_repeated_sgmt(songs_seg_raw{ri}, j,{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'});
        Xtest = [Xtest; x1' x2' xr];
        Ytest = [Ytest; 1];
    end
    featMean = mean(Xtest);
    featSTD = std(Xtest);
    Xtest = (Xtest - repmat(featMean, nXtest, 1)) ./ (repmat(featSTD, nXtest, 1) + eps);
    [Ypred, accuracy, ~] = svmpredict(Ytest, Xtest, bestModel);
    
    for j = 1:numel(songs_seg_raw{ri})
        songs_seg_raw{ri}{j}.pred = Ypred(j);
    end
end

%% Demo generating block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual control above code to generate demo clips
%
%  1. choose `algorithm` for sgmts: cnmf, scluster
%  2. set `ri` for `Ypred` result
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ri = 86;
song = songs_seg_raw{ri};
clips = cell(size(song));
for i = 1:length(Ypred)
    if Ypred(i)
        s = ceil(song{i}.start * fs);
        if(s == 0)
            s = 1;
        end
        e = floor((song{i}.start + song{i}.duration) * fs);
        clips{i} = audio(s:e);
        audiowrite(sprintf('song_%d_clip_%d.wav', ri, i), clips{i}, fs);
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7. Evaluating of Precision, Recall, F-Measure                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Na = 2;
Ne = 2;
fs = 44100;
window = 1024;

score_song = cell(size(listOfJsons, 1)+1, 1);
score_song{106}.filename = 'Total';
for i = 1 : num_songs_raw
	ri = id_songs_raw(i);
    song_time = songs_seg{ri}{numel(songs_seg{ri})}.range(2) - songs_seg{ri}{1}.range(1);
    N = (44100 / 1024) * fs;
    num_seg_gt = numel(songs_seg{ri});
    num_seg_js = numel(songs_seg_raw{ri});
    
	% Our Score Calculation
    score_EP_sec = 0;
    score_AP_sec = 0;
    score_sum = 0;
    score_TP_sec = 0;
    
    for j = 1 : num_seg_gt
        if strcmp(songs_seg{ri}{j}.label, 'chorus') == 1
            score_AP_sec = score_AP_sec + (songs_seg{ri}{j}.range(2) - songs_seg{ri}{j}.range(1));
        end
    end
    for j = 1 : num_seg_js
        raw_pred = songs_seg_raw{ri}{j}.pred;
        score_EP_sec = score_EP_sec + (1 && raw_pred) * songs_seg_raw{ri}{j}.duration;
        LB = songs_seg_raw{ri}{j}.start;
        RB = songs_seg_raw{ri}{j}.end;
        for k = 1 : num_seg_gt
            if strcmp(songs_seg{ri}{k}.label, 'chorus') ~= 1 % gt not chorus
                continue;
            else
                if songs_seg{ri}{k}.range(1) >= RB % GT out of bound (right)
                    continue;
                elseif songs_seg{ri}{k}.range(2) <= LB % GT out of bound (left)
                    continue;
                else % GT intersects with Pred
                    gt_duration = songs_seg{ri}{k}.range(2) - songs_seg{ri}{k}.range(1);
                    if songs_seg{ri}{k}.range(1) >= LB % GT_LB >= LB
                        if songs_seg{ri}{k}.range(2) <= RB % GT_RB <= RB
                            score_sum = score_sum + (1 && raw_pred);
                            score_TP_sec = score_TP_sec + (1 && raw_pred) * (gt_duration);
                        else % GT_LB >= LB && GT_RB > RB
                            ratio = (RB - songs_seg{ri}{k}.range(1)) / gt_duration;
                            score_sum = score_sum + ((1 && raw_pred) * ratio);
                            score_TP_sec = score_TP_sec + (1 && raw_pred) * (RB - songs_seg{ri}{k}.range(1));
                        end
                    else % GT_LB < LB
                        if RB <= songs_seg{ri}{k}.range(2)
                            ratio = (RB - LB) / gt_duration;
                            score_TP_sec = score_TP_sec + (1 && raw_pred) * (RB - LB);
                        else
                            ratio = (songs_seg{ri}{k}.range(2) - LB) / gt_duration;
                            score_TP_sec = score_TP_sec + (1 && raw_pred) * (songs_seg{ri}{k}.range(2) - LB);
                        end
                        score_sum = score_sum + ((1 && raw_pred) * ratio);
                    end
                end
            end
        end
    end
    
    gt_num_chorous = 0;
    for j = 1 : numel(songs_seg{ri})
       if strcmp(songs_seg{ri}{j}.label, 'chorus') == 1
           gt_num_chorous = gt_num_chorous + 1;
       end
    end
    score_song{ri}.Atime = song_time;
    score_song{ri}.Etime = songs_seg_raw{ri}{numel(songs_seg_raw{ri})}.end - songs_seg_raw{ri}{1}.start;
    score_song{ri}.num_chorus = gt_num_chorous;
    score_song{ri}.EPsec = score_EP_sec;
    score_song{ri}.APsec = score_AP_sec;
    score_song{ri}.TPsec = score_TP_sec;
    score_song{ri}.FPsec = score_EP_sec - score_TP_sec;
    score_song{ri}.FNsec = score_AP_sec - score_TP_sec;
    score_song{ri}.TNsec = (song_time - score_AP_sec) - score_song{ri}.FNsec;
    score_song{ri}.Ensec = score_song{ri}.Etime - score_EP_sec;
    score_song{ri}.Ansec = score_song{ri}.Atime - score_AP_sec;
    score_song{ri}.P = score_TP_sec / (score_TP_sec + score_song{ri}.FPsec);
    score_song{ri}.R = score_TP_sec / (score_TP_sec + score_song{ri}.FNsec);
    score_song{ri}.F = (2 * score_song{ri}.P * score_song{ri}.R) / (score_song{ri}.P + score_song{ri}.R);
    score_song{ri}.score = score_sum;
    score_song{ri}.score_normal = score_sum / gt_num_chorous;
end

avg = 0;
for i = 1 : num_songs_raw
    ri = id_songs_raw(i);
    if isnan(score_song{ri}.F)
        avg = avg + 0;
        fprintf('Song %3d: %f\n', ri, 0);
    else
        avg = avg + score_song{ri}.F;
        fprintf('Song %3d: %f\n', ri, score_song{ri}.F);
    end
end
avg = avg / num_songs_raw;
fprintf('Average: %f\n', avg);

%%


