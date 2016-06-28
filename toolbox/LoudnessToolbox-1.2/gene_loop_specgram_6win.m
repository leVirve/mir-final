function  [P, t, f] = gene_loop_specgram_6win(x, fs, step)

%%%%%%%%%%%%%
% FUNCTION:
%   Signal analysis in time and frequency using six different FFT sizes.
%   According to Moore et al. article (see Reference).
%   Levels are calculated every step seconds.
%
% USE:
%   [P, t, f] = gene_loop_specgram_6win(x, fs, step)
% 
% INPUT:
%   x    : input signal, one channel (Pa)
%   fs   : sampling frequency (Hz)
%   step : time step in second (T = 0.001s to match the reference article)
% 
% OUTPUT:
%   P = power matrix vs time and freq
%   t = time vector (s)
%   f = frequencies vector (Hz)
% 
% REFERENCE: 
% Glasberg B. R. et Moore B. C. J.,
% "A model of loudness applicable to time-varying sounds",
%  J. Audio Eng. Soc., 50, n° 5, 331-342, 2002
%
% NOTA BENE:
%   in order not to overload RAM capacity, signal is divided in blocks
%   during computation procedure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nhalfwin = fix( 0.032 * fs ); % halp number of FFT samples

%% case: signal length < 1 second
if length(x) < round(1 * fs), 
    
    y = zeros(length(x) + 2 * nhalfwin, 1);
    y(nhalfwin + 1 : length(x) + nhalfwin) = x;
    [Ptf, Pi_unused, t, f ] = specgram_6windows( y, fs, step);
%     Pinst = Pi;
    P = Ptf;

    
%% case: signal length > 1 second
else                          
    
    nwin = fix( 0.064 * fs ); % nb of FFT samples
    noverlap = round ( nwin - ( step * fs ) );
    block_size = nwin + (nwin - noverlap) * 800;
    
    % memory allocation
    
    y = zeros(1, block_size);       % memory allocation of (sub-)block of original signal
    
    
    %---------- first block
    index = block_size - nhalfwin;  % current index in the original signal
    
    y(nhalfwin + 1:end) = x(1:index);
    
    [ Ptf, Pi, time, freq ] = specgram_6windows( y, fs, step);

    % memory allocation for output P
    nb_freqs = length(freq);
    nb_times_per_block = length(time) - 1;
    nb_blocks = floor(length(x)/block_size) + 1;
    nb_times = (nb_blocks-1) * nb_times_per_block;
    
    % fill output t and f
    real_step = time(2) - time(1);    
    t = (0:nb_times-1)' * real_step;
    
    f = freq;
    
    % fill P for 1st block
    n_time = 1; % current column (of time)
    
    P(:, n_time:n_time+nb_times_per_block-1) = Ptf(:, 1:end-1);
    
    n_time = n_time + nb_times_per_block - 1;
    
    %---------- middle blocks
    deb = index - nwin + 1;
    stop = deb + block_size;
    
    i = 1;
    
    while( stop < length(x)),
        
        [ Ptf, Pi ] = specgram_6windows( x(deb : stop), fs, step);

        % store P
        P(:, n_time:n_time+nb_times_per_block-1) = Ptf(:, 1:end-1);

        % increment variables
        n_time = n_time + nb_times_per_block;
        index = index + block_size - nwin;
        deb = index - nwin + 1;
        stop = deb + block_size;
        i = i+1;       

    end;
   
    %---------- last block
    y = zeros(length(x(deb:end)) + nhalfwin, 1);
    y(1:length(x(deb:end))) = x(deb:end);
    [ Ptf, Pi ] = specgram_6windows( y, fs, step);
    
    P(:, n_time:n_time+size(Ptf,2)-1-1) = Ptf(:, 1:end-1);
        
end;


%% SUBFUNCTION

function [ P, Pinst, t, f ] = specgram_6windows( x, fs, step, progress, show)

%%%%%%%%%%%%%
% Spectrogram calculation using six different FFT size.
% Window sizes used are: 64, 32, 16, 8, 4, 2 ms
%
% 64 ms window is used for frequency band 0 - 80 Hz
% 32 ms window is used for frequency band 80 - 500 Hz
% 16 ms window is used for frequency band 500 - 1250 Hz
%  8 ms window is used for frequency band 1250 - 2540Hz
%  4 ms window is used for frequency band 2540 - 4050 Hz
%  2 ms window is used for frequency band 4050 - (fs/2) Hz
%
%  
% INPUT
%   x = signal in Pascal (dB SPL)
%   fs = sampling frequency (Hz)
%   step = temporal step (s)
%   progress = 'progress' to display progress of computation
%   show = 'show' to display some figure
%
% OUTPUT
%   P = power matrix vs time and freq
%   Pinst = instantaneous power vs time
%   t = time vector (s)
%   f = frequencies vector (Hz)
%
% REFERENCE
%   "A model of loudness applicable time-varying sounds"
%   Glasberg B.R., Moore J., J. Audio Eng. Soc., Vol.50, N°5, 2002
%
% GENESIS S.A. - 2009 - www.genesis.fr
%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5,
    show = ' ';
end;

if nargin < 4,
    progress = ' ';
end;

%% parameters:
Pref = 2e-5;                                                  % reference sound pressure
x_norm = x(:) / Pref;                                         % signal normalization

nwind = fix ( [0.002 0.004 0.008 0.016 0.032 0.064] .* fs);   % FFT sizes in samples 
noverlap = round ( nwind - ( step * fs ) );                   % overlap
nfft = 2^nextpow2(max(nwind));                                % FFT sizes for blocks

if noverlap(1) <= 0,
    error('calculation step  shall be reduced because overlap value is not sufficient');
end;

% short term FFT for 6 different window sizes

% frequency bands index for each window size
k0    = 1;                                  
k80   = fix (       80 .* nfft ./ fs);           % 64ms window
k500  = fix (      500 .* nfft ./ fs);           % 32ms window
k1250 = fix (     1250 .* nfft ./ fs);           % 16ms window
k2540 = fix (     2540 .* nfft ./ fs);           %  8ms window
k4050 = fix (     4050 .* nfft ./ fs);           %  4ms window
kmax  = fix ((fs ./ 2) .* nfft ./ fs) + 1;       %  2ms window


%% 64ms

x64 = x_norm; clear x_norm;

% hanning window normalized in a way to keep signal energy
han = hanning( nwind(6) );
han_norm = han * sqrt(length(han) ./ sum(han.^2));

% spectrogram computation
[y64 f64 t64] = specgram( x64, nfft, fs, han_norm, noverlap(6) );
clear han han_norm;

% PSD
y64 = abs(y64( k0 : k80 , :)).^2 ./ (nwind(6) * nfft);

% message
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 64 ms (1/6): OK');
end;

%% 32 ms
x32 = tronque(x64, nwind(5)); clear x64;
han = hanning( nwind(5) ); han_norm = han * sqrt(length(han) ./ sum(han.^2));
y32 = specgram( x32, nfft, fs, han_norm, noverlap(5) );
clear han han_norm;
y32 = abs(y32( (k80+1) : k500 , 1:length(t64))).^2 ./ (nwind(5) * nfft); 
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 32 ms (2/6): OK');
end;

%% 16 ms
x16 = tronque(x32, nwind(4)); clear x32;
han = hanning( nwind(4) ); han_norm = han * sqrt(length(han) ./ sum(han.^2));
[y16] = specgram( x16, nfft, fs, han_norm, noverlap(4) );
clear han han_norm;
y16 = abs(y16( (k500+1) : k1250 , 1:length(t64))).^2 ./ (nwind(4) * nfft);
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 16 ms (3/6): OK');
end;

%% 8ms
x08 = tronque(x16, nwind(3)); clear x16;
han = hanning( nwind(3) ); han_norm = han * sqrt(length(han) ./ sum(han.^2));
[y08] = specgram( x08, nfft, fs, han_norm, noverlap(3) );
clear han han_norm;
y08 = abs(y08( (k1250+1) : k2540 , 1:length(t64))).^2 ./ (nwind(3) * nfft);
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 8 ms (4/6): OK');
end;

%% 4ms
x04 = tronque(x08, nwind(2)); clear x08;
han = hanning( nwind(2) ); han_norm = han * sqrt(length(han) ./ sum(han.^2));
[y04] = specgram( x04, nfft, fs, han_norm, noverlap(2) );
clear han han_norm;
y04 = abs(y04( (k2540+1) : k4050 , 1:length(t64))).^2 ./ (nwind(2) * nfft);
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 4 ms (5/6): OK');
end;

%% 2ms
x02 = tronque(x04, nwind(1)); clear x04;
han = hanning( nwind(1) ); han_norm = han * sqrt(length(han) ./ sum(han.^2));
[y02] = specgram( x02, nfft, fs, han_norm, noverlap(1) );
clear han han_norm;
y02 = abs(y02( (k4050+1) : kmax , 1:length(t64))).^2 ./ (nwind(1) * nfft);
if strcmp(progress, 'progress'),
    disp('Calculation with a window size of 2 ms (6/6): OK');
end;

%% post-processing
f = f64;                          % frequency axis
t = t64;                          % time axis: center times of the analysis window

% put PSD all in one
dp = [y64 ; y32; y16; y08; y04; y02];

% power in dB
P = 10 * log10( 2*dp + eps);

% instantaneous power vs time
Pinst = 10 * log10( 2 * sum(dp(:,:)) + eps);

% optional display
if strcmp(show, 'show'),
    m = min( min(P) );
    M = max( max(P) );
    figure;
    imagesc(t, f, P, [m M]); axis xy; colormap(jet);
    xlabel('Time (s)'); ylabel('Frequency (Hz)');

    figure;
    plot(t, Pinst, '+'),title('Instantaneous power of the signal');

end;


%% truncation routine
function out = tronque(in, ntronque)

out = in( ceil(ntronque/2) : length(in) - fix(ntronque/2) - 1 );




