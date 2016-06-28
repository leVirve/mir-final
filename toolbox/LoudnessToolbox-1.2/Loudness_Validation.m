function Loudness_Validation()

% Function used to validate the loudness models included into the Loudnes Toolbox
% regarding to data from the literature.
% This function run every function of loudness calculation from the
% Loudness Toolbox with input sound coming from the WAV directory.
%
% USE:
%   acts as a script, no imput, no output variables
%   figures are produced and saved into files (into ResultPathName)
%   a log file is also produced that contaisn the values of loudness
%   (Results.txt)
%
% NOTA BENE
%   this function must be run from the root directory of the toolbox in
%   order to find the WAV folder that contains all the required sound files
%
%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%


%% pre-processing and settings

WavPathName = 'WAV';
ResultPathName = 'RESULTS';

NoiseFileNamesPN = {'PinkNoise_0dBpHz@1000Hz.wav', 'PinkNoise_20dBpHz@1000Hz.wav', 'PinkNoise_40dBpHz@1000Hz.wav'};

NoiseFileNamesPT = {'sinus_1000Hz_10dBSPL.wav', 'sinus_1000Hz_40dBSPL.wav', 'sinus_1000Hz_50dBSPL.wav', ...
    'sinus_1000Hz_60dBSPL.wav', 'sinus_1000Hz_80dBSPL.wav', 'sinus_100Hz_10dBSPL.wav', ...
    'sinus_100Hz_40dBSPL.wav', 'sinus_100Hz_50dBSPL.wav', 'sinus_100Hz_60dBSPL.wav', ...
    'sinus_100Hz_80dBSPL.wav', 'sinus_3000Hz_10dBSPL.wav', 'sinus_3000Hz_40dBSPL.wav', ...
    'sinus_3000Hz_50dBSPL.wav', 'sinus_3000Hz_60dBSPL.wav', 'sinus_3000Hz_80dBSPL.wav'};

NoiseFileNamesTB = {'ToneBurst_1000Hz_60dBSPL_16ms.wav', 'ToneBurst_1000Hz_60dBSPL_32ms.wav', 'ToneBurst_1000Hz_60dBSPL_64ms.wav',...
    'ToneBurst_1000Hz_60dBSPL_128ms.wav', 'ToneBurst_1000Hz_60dBSPL_200ms.wav', 'ToneBurst_4000Hz_60dBSPL_16ms.wav', ...
    'ToneBurst_4000Hz_60dBSPL_32ms.wav', 'ToneBurst_4000Hz_60dBSPL_64ms.wav', 'ToneBurst_4000Hz_60dBSPL_128ms.wav', ...
    'ToneBurst_4000Hz_60dBSPL_200ms.wav', 'ToneBurst_5000Hz_86.5dBSPL_10ms.wav', 'ToneBurst_5000Hz_86.5dBSPL_100ms.wav'};

NoiseFileNamesTVS = {'bus.wav', 'cyclo.wav', 'trafic.wav'};

NoiseFileNamesIS = {'son02.wav', 'son10.wav', 'son22.wav'};

ResultsFileName = 'Results.txt';

ResultsFileName = fullfile(ResultPathName, ResultsFileName);

if exist('res','var'),
    clear res;
end;

if ~exist(ResultPathName, 'dir'),
    mkdir( ResultPathName );
end;

%% open file for output

ResultFile = fopen(ResultsFileName, 'w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MODELS FOR STATIONARY SOUNDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ISO 532B - Zwicker (1991) - stationary sounds

disp('Loudness calculation for pink noises (ISO 532B)...');

fprintf(ResultFile, '\n----------\nStationary (ISO 532B)\n----------\n\n');

% Pink Noise (PN) %%%%
for i = 1 : length(NoiseFileNamesPN),
    
    % read file
    name = NoiseFileNamesPN{i};
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B_from_sound(sig, fs, 0);
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness: %.2f sones\nLoudness level: %.2f phones\n', N_tot, LN);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

% Pure tones (PT) %%%%
disp('Loudness calculation for pure tones (ISO 532B)...');
for i = 1 : length(NoiseFileNamesPT),
    
    % read file
    name = NoiseFileNamesPT{i}; 
    name = fullfile(WavPathName, name);
    
    % computation
    [sig, fs] = wavread(name);
    [N_tot, N_specif, BarkAxis, LN] = Loudness_ISO532B_from_sound(sig, fs, 0);
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness: %.2f sones\nLoudness level: %.2f phones\n', N_tot, LN);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

%% ANSI S3.4 2007 - Moore (1997) - stationary sounds

fprintf(ResultFile, '\n----------\nStationary (ANSI S3.4 2007)\n----------\n');


% Pink Noise (PN) %%%%
disp('Loudness calculation for pink noises (ANSI S3.4 2007)...');
for i = 1 : length(NoiseFileNamesPN),
    
    % read file
    name = NoiseFileNamesPN{i};
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    [Loudness, Specific_loudness, fc, LoudnessLevel] = Loudness_ANSI_S34_2007(sig,fs,0,'mic');
      
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness: %.2f sones\nLoudness level: %.2f phones\n', Loudness, LoudnessLevel);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');
    

% Pure tones (PT) %%%%
disp('Loudness calculation for pure tones (ANSI S3.4 2007)...');
for i = 1 : length(NoiseFileNamesPT),
    
    % read file
    name = NoiseFileNamesPT{i}; 
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    [Loudness, Specific_loudness, fc, LoudnessLevel] = Loudness_ANSI_S34_2007(sig,fs,0,'mic');
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness: %.2f sones\nLoudness level: %.2f phones\n', Loudness, LoudnessLevel);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NON stationary MODELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Zwicker and Fastl (1999) - non stationary sounds

fprintf(ResultFile, '\n----------\nNON stationary (Zwicker and Fastl)\n----------\n');

% Tone bursts(TB) %%%%
disp('Loudness calculation for tone burst (Zwicker and Fastl)...');
res = cell(1, length(NoiseFileNamesTB));
SigCell = cell(1, length(NoiseFileNamesTB));
for i = 1:length(NoiseFileNamesTB),
    
    % read file
    name = NoiseFileNamesTB{i}; 
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    res{i} = Loudness_TimeVaryingSound_Zwicker(sig, fs);
    SigCell{i} = sig;
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness N5: %.2f sones\nLoudness level N5: %.2f phones\n', res{i}.Nx, res{i}.Lx);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

% Plot specific loudness
        
    Time_Z10ms = res{11}.time;
    Loudness_Z10ms = res{11}.InstantaneousLoudness;    
    Time_Z100ms = res{12}.time;
    Loudness_Z100ms = res{12}.InstantaneousLoudness;
      
    LoudnessI = figure;
    subplot(2,1,1)
    plot(Time_Z10ms, Loudness_Z10ms, Time_Z100ms, Loudness_Z100ms, 'r');
    axis([0 0.5 0 32]); legend('10 ms','100 ms');
    title('Loudness of Tone burst (5 kHz, 10 and 100 ms, 86.5 dBSPL) from Zwicker and Fastl (1999)');
    xlabel('time, s');
    ylabel('Loudness, sones');
    
    subplot(2,1,2)
    plot(0:1/fs:(length(SigCell{11})-1)/fs,SigCell{11},0:1/fs:(length(SigCell{12})-1)/fs,SigCell{12},'r');
    axis([0 0.5 -0.3 0.3]);
    title('Signal');
    xlabel('time, s');
    ylabel('Pressure, Pa');
    print(LoudnessI, '-djpeg', [ResultPathName '\Zwicker_toneburst.jpeg']);
    

%% Zwicker and Fastl (1999) - non stationary sounds

% Real-world Time-varying sounds (TVS)

disp('Loudness calculation for time-varying sounds (Zwicker and Fastl)...');
res = cell(1, length(NoiseFileNamesTVS));
SigCell = cell(1, length(NoiseFileNamesTVS));

for i = 1:length(NoiseFileNamesTVS),
    
    %read file
    name = NoiseFileNamesTVS{i}; 
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    res{i} = Loudness_TimeVaryingSound_Zwicker(sig, fs);
    SigCell{i} = sig;
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness N5: %.2f sones\nLoudness level N5: %.2f phones\n', res{i}.Nx, res{i}.Lx);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

% Plot specific loudness
    
    Time_bus = res{1}.time;
    Loudness_bus = res{1}.InstantaneousLoudness;
    N5_bus = res{1}.Lx;        
    Time_cyclo = res{2}.time;
    Loudness_cyclo = res{2}.InstantaneousLoudness;
    N5_cyclo = res{2}.Lx;     
    Time_trafic = res{3}.time;
    Loudness_trafic = res{3}.InstantaneousLoudness;
    N5_trafic = res{3}.Lx;
    
    bus_legend = ['N5 bus: ' num2str(round(10*N5_bus)/10) ' phons'];
    cyclo_legend = ['N5 cyclo: ' num2str(round(10*N5_cyclo)/10) ' phons'];
    trafic_legend = ['N5 trafic: ' num2str(round(10*N5_trafic)/10) ' phons'];
    
    Loudness = figure;
    subplot(4,1,1);
    plot(Time_bus, Loudness_bus,Time_cyclo, Loudness_cyclo, 'r', Time_trafic,Loudness_trafic,'g');
    axis([0 10 0 30]); legend(bus_legend, cyclo_legend, trafic_legend);
    title('Loudness vs time from Zwicker and Fastl (1999)');
    ylabel('Loudness, sones');
    subplot(4,1,2);
    plot(0:1/fs:(length(SigCell{1})-1)/fs,SigCell{1});
    axis([0 10 -0.5 0.5]);
    ylabel('Pressure, Pa');    
    subplot(4,1,3);
    plot(0:1/fs:(length(SigCell{2})-1)/fs,SigCell{2}, 'r');
    axis([0 10 -0.5 0.5]);
    ylabel('Pressure, Pa');    
    subplot(4,1,4)
    plot(0:1/fs:(length(SigCell{3})-1)/fs,SigCell{3},'g');
    axis([0 10 -0.5 0.5]);
    title('Signal');
    xlabel('time, s');
    ylabel('Pressure, Pa');
    
    print(Loudness, '-djpeg', [ResultPathName '\Zwicker_realsounds.jpeg']);

     
%% Glasberg and Moore (2002) - non stationary sounds
fprintf(ResultFile, '\n----------\nNON stationary (Glasberg and Moore)\n----------\n');

% Tone bursts(PT)

disp('Loudness calculation for tone burst (Glasberg and Moore)...');
res = cell(1, length(NoiseFileNamesTB));
SigCell = cell(1, length(NoiseFileNamesTB));

for i = 1:length(NoiseFileNamesTB),
    
    % read file
    name = NoiseFileNamesTB{i};
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    res{i} = Loudness_TimeVaryingSound_Moore(sig, fs);
    SigCell{i} = sig;

    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness STLmax: %.2f sones\nLoudness level STLmax: %.2f phones\n', res{i}.STLmax, res{i}.STLlevelmax);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

% Plot specific loudness
        
    Time_200ms = res{10}.time;
    IL_200ms = res{10}.InstantaneousLoudnessLevel;
    STL200ms = res{10}.STLlevel;
    LTL200ms = res{10}.LTLlevel;
    
    LoudnessG1 = figure;
    subplot(2,1,1)
    plot(Time_200ms,IL_200ms,Time_200ms,STL200ms,'r',Time_200ms,LTL200ms,'g');
    axis([0 0.5 0 80]); legend('IL','STL', 'LTL');
    title( 'Loudness of Tone burst (4 kHz, 200 ms, 60 dBSPL) from Glasberg and Moore (2002)');
    xlabel('time, s');
    ylabel('Loudness level, phons');
    subplot(2,1,2)
    plot(0:1/fs:(length(SigCell{10})-1)/fs,SigCell{10});
    axis([0 0.5 -0.2 0.2]);
    title('Signal');
    xlabel('time, s');
    ylabel('Pressure, Pa');
    
    print(LoudnessG1, '-djpeg',[ResultPathName '\Moore_toneburst200ms.jpeg']);
    
    LoudnessG2 = figure;
    Time_TB = [0.016 0.032 0.064 0.128 0.2];
    MaxPhonieST_1kHz = [res{1}.STLlevelmax res{2}.STLlevelmax res{3}.STLlevelmax res{4}.STLlevelmax res{5}.STLlevelmax];
    MaxPhonieST_4kHz = [res{6}.STLlevelmax res{7}.STLlevelmax res{8}.STLlevelmax res{9}.STLlevelmax res{10}.STLlevelmax];
    plot(Time_TB, MaxPhonieST_1kHz,'-rs', Time_TB, MaxPhonieST_4kHz,'-bx');
    axis([0 0.3 50 70]);
    title('Loudness of Tone burst (16, 32, 64, 128 and 200 ms; 60 dBSPL) from Glasberg and Moore (2002)');
    xlabel('Duration, s'); legend('1kHz','4kHz');
    ylabel('Short-Term Loudness, phons');
    
    print(LoudnessG2, '-djpeg',[ResultPathName '\Moore_toneburst.jpeg']);
    

%% Glasberg and Moore (2002) - non stationary sounds

% Real-world Time-varying sounds (TVS)

disp('Loudness calculation for time-varying sounds (Glasberg and Moore)...');
res = cell(1, length(NoiseFileNamesTB));
SigCell = cell(1, length(NoiseFileNamesTB));

for i = 1:length(NoiseFileNamesTVS),
    
    % read file
    name = NoiseFileNamesTVS{i}; 
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    res{i}= Loudness_TimeVaryingSound_Moore(sig, fs);    
    SigCell{i} = sig;
    
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness STLmax: %.2f sones\nLoudness level STLmax: %.2f phones\n', res{i}.STLmax, res{i}.STLlevelmax);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');

% Plot specific loudness

    Time_bus = res{1}.time;
    Loudness_bus = res{1}.STL;
    STL_bus = res{1}.STLlevelmax;    
    Time_cyclo = res{2}.time;
    Loudness_cyclo = res{2}.STL;
    STL_cyclo = res{2}.STLlevelmax;
    Time_trafic = res{3}.time;
    Loudness_trafic = res{3}.STL;
    STL_trafic = res{3}.STLlevelmax;
    
    bus_legend = ['STLmax bus: ' num2str(round(10*STL_bus)/10) ' phons'];
    cyclo_legend = ['STLmax cyclo: ' num2str(round(10*STL_cyclo)/10) ' phons'];
    trafic_legend = ['STLmax trafic: ' num2str(round(10*STL_trafic)/10) ' phons'];
    
    LoudnessG3 = figure;
    subplot(4,1,1)
    plot(Time_bus,Loudness_bus,Time_cyclo,Loudness_cyclo,'r', Time_trafic,Loudness_trafic,'g');
    axis([0 10 0 30]); legend(bus_legend,cyclo_legend,trafic_legend);
    title('Loudness vs time from Glasberg and Moore (2006)');
    ylabel('Loudness, sones');    
    subplot(4,1,2)
    plot(0:1/fs:(length(SigCell{1})-1)/fs,SigCell{1});
    axis([0 10 -0.5 0.5]);
    title('Signal');
    ylabel('Pressure, Pa');    
    subplot(4,1,3)
    plot(0:1/fs:(length(SigCell{2})-1)/fs,SigCell{2}, 'r');
    axis([0 10 -0.5 0.5]);
    ylabel('Pressure, Pa');    
    subplot(4,1,4)
    plot(0:1/fs:(length(SigCell{3})-1)/fs,SigCell{3},'g');
    axis([0 10 -0.5 0.5]);
    xlabel('time, s');
    ylabel('Pressure, Pa');
    print(LoudnessG3, '-djpeg',[ResultPathName '\Moore_realsounds.jpeg']);

    
%%%%%%%%%%%%%%%%%%
% IMPULSIVE SOUNDS
%%%%%%%%%%%%%%%%%%
fprintf(ResultFile, '\n----------\nIMPULSIVE SOUNDS (LMIS)\n----------\n');


%% LMIS - Boullet (2006)

disp('Loudness calculation for impulsive sounds (Boullet LMIS)...');

for i = 1:length(NoiseFileNamesIS),
    
    %read file
    name = NoiseFileNamesIS{i}; 
    name = fullfile(WavPathName, name);
    [sig, fs] = wavread(name);
    
    % computation
    [loudness loudness_level] = Loudness_LMIS(sig, fs);
     
    % Print in results file
    fprintf(ResultFile, 'File: %s\n', name);
    fprintf(ResultFile, 'Loudness : %.2f sones\nLoudness level : %.2f phones\n', loudness, loudness_level);
    fprintf(ResultFile, '---------\n');

end;
disp('done!');



%% Before to leave

fclose(ResultFile);
disp('Validation finished.');