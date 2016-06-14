clc; close all; clear all;

addpath('../toolbox');

path_audio_rwc  = '../rwc48mp3';
path_audio_ours = '../Label Dataset(song)';
path_json = '../annotations';

listOfSongs = [
    listfile(fullfile(path_audio_rwc, 'Disc1'))';
    listfile(fullfile(path_audio_rwc, 'Disc2'))';
    listfile(fullfile(path_audio_rwc, 'Disc3'))';
    listfile(fullfile(path_audio_ours, 'Sa'))';
    listfile(fullfile(path_audio_ours, 'Yi'))';
    listfile(fullfile(path_audio_ours, 'Wu'))';
];
clear path_audio_rwc path_audio_ours path_json;
%%

filename = listOfSongs{1};
[f_audio, fs] = audioread(listOfSongs{1});
sideinfo.wav.fs = fs;

%%
paramPitch.winLenSTMSP = 4410;
[f_pitch] = audio_to_pitch_via_FB(f_audio,paramPitch);
paramCENS.winLenSmooth = 11;
paramCENS.downsampSmooth = 5;
[f_CENS] = pitch_to_CENS(f_pitch,paramCENS);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   3. Computes and visualizes an enhanced and thresholded similarity 
%      matrix. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

paramSM.smoothLenSM = 20;
paramSM.tempoRelMin = 0.5;
paramSM.tempoRelMax = 2;
paramSM.tempoNum = 7;
paramSM.forwardBackward = 1;
paramSM.circShift = [0:11];
[S,I] = features_to_SM(f_CENS,f_CENS,paramSM);

paramVis.colormapPreset = 2;
visualizeSM(S,paramVis);
title('S');

visualizeTransIndex(I,paramVis);
title('Transposition index');


paramThres.threshTechnique = 2;
paramThres.threshValue = 0.15;
paramThres.applyBinarize = 0;
paramThres.applyScale = 1;
paramThres.penalty = -2;
[S_final] = threshSM(S,paramThres);  

paramVis.imagerange = [-2,1];
paramVis.colormapPreset = 3;
handleFigure = visualizeSM(S_final,paramVis);
title('Final S with thresholding for computing the scapeplot matrix');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   4. Computes and saves a fitness scape plot.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute fitness scape plot and save
parameter.dirFitness = 'data_fitness/';
parameter.saveFitness = 1;
parameter.title = filename(1:end-4);

%-----------!!IMPORTANT!!--------------------------------------------------%
% For fast computing of fitness scape plot, please enable parallel computing.
% To enable that, use command 'matlabpool open'.
% To disable that, use command 'matlabpool close'
%--------------------------------------------------------------------------%
[fitness_info,parameter] = SSM_to_scapePlotFitness(S_final, parameter);
fitness_matrix = fitness_info.fitness;

% % instead of computing fitness, you can load a previously computed scape plot:
% fitnessSaveFileName = ['data_fitness/',filename(1:end-4),'_fit','.mat'];
% fitnessFile = load(fitnessSaveFileName);
% fitness_matrix = fitnessFile.fitness_info.fitness;

paramVisScp = [];
% paramVisScp.timeLineUnit = 'sample';
% paramVisScp.timeLineUnit = 'second'; paramVisScp.featureRate = ... 
[h_fig_scapeplot,x_axis,y_axis] = visualizeScapePlot(fitness_matrix,paramVisScp);
title('Fitness scape plot','Interpreter','none');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  5. Computes the thumbnail 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute thumbnail with length constraint
parameter.len_min_seg_frame= 20;
[thumb_frame] = scapePlotFitness_to_thumbnail(fitness_matrix,parameter);

% show corresponding thumbnail point in fitness scape plot
center_thumb_frame = floor((thumb_frame(1) + thumb_frame(2))/2);
length_thumb_frame = thumb_frame(2) - thumb_frame(1) + 1;

point_x_pos = x_axis(center_thumb_frame);
point_y_pos = y_axis(length_thumb_frame);

hold on;
plot(point_x_pos,point_y_pos,'o','LineWidth',2,'color',[1, 0.5, 0]);
hold off;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   6. Computes optimal path family and induced segment family
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% find repetitions of thumbnail
[induced_frame,pathFamily] = thumbnailSSM_to_pathFamily(thumb_frame,S_final,parameter);

paramVisPathSSM = [];
paramVisPathSSM.visualizeInducedSegments = 1;
paramVisPathSSM.visualizeWarpingpath = 1;
visualizePathFamilySSM(S_final,pathFamily,paramVisPathSSM);
title('S, path family, and induced segment family');


% convert from frames to seconds
parameter.featureRate = 10/paramCENS.downsampSmooth;
parameter.duration = size(S_final,1)/parameter.featureRate;
induced_second = convertSegment_frames_to_seconds(induced_frame,parameter.featureRate);
thumb_second = convertSegment_frames_to_seconds(thumb_frame,parameter.featureRate);



% attach audio file to SSMPathFamily
if isfield(parameter,'timeLineUnit') && (strcmp(parameter.timeLineUnit,'second'))
    parameterMPP.featureTimeResType = 'seconds';
else
    parameterMPP.featureTimeResType = 'features';
end
parameterMPP.featureRate = parameter.featureRate;
parameterMPP.fs = sideinfo.wav.fs;
h_fig = gcf;
makePlotPlayable(f_audio, h_fig, parameterMPP);



% assign label to each repetition and wrap up in segment struct
computedSegments = wrapUpSegmentInStruct(induced_second,thumb_second);
paramVisSegFam = [];
paramVisSegFam.duration = parameter.duration;

paramVisSegFam.showLabelText = 1;
paramVisSegFam.segType = 'computed';
visualizeSegFamily(computedSegments,paramVisSegFam);
title('Computed segmentation');


% attach audio file to segment family visualization
parameterMPP.featureRate = parameter.featureRate;
parameterMPP.fs = sideinfo.wav.fs;
parameterMPP.featureTimeResType = 'seconds';
h_fig = gcf;
makePlotPlayable(f_audio, h_fig, parameterMPP);
% by left clicking on the x-axis of the figure, the playback will
% jump to the clicked position.
% by right clicking on the x-axis of the figure, the player will stop.



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   7. Loads ground truth segmentation and compares with computed 
%      segmentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% reading ground truth from txt file:
dirAnnotation = 'data_annotation/';
groundTruth_struct = parseAnnotationFile([dirAnnotation parameter.title '.txt']);

paramVisSegFam.segType = 'groundtruth';
visualizeSegFamily(groundTruth_struct,paramVisSegFam);
title('Ground truth segmentation');
h_fig = gcf;
makePlotPlayable(f_audio, h_fig, parameterMPP);

% show ground truth and computed result together
figure;
h_fig = subplot(2,1,1);
paramVisSegFam.segType = 'groundtruth';
visualizeSegFamily(groundTruth_struct,paramVisSegFam,h_fig);
title('Ground truth segmentation');
h_fig = subplot(2,1,2);
paramVisSegFam.segType = 'computed';
visualizeSegFamily(computedSegments,paramVisSegFam,h_fig);
title('Computed segmentation');
makePlotPlayable(f_audio, h_fig, parameterMPP);
