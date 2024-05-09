% Used to quickly analyze resting data for IPAF extraction and use in the
% BR entrainment SYON EEG task.
% KWK - 20240327


function [data] = restingFFTAnalysis(options)

%% Define input variables
if ~isfield(options,'displayFigs')
    % 1 for plotting
    options.displayFigs = 1;
end

subjID = options.subjid;
expID = options.expName;

% Define paths
inputPath = options.restEEGPath;
ftPath = 'C:\Users\EEG Task Computer\Desktop\SYON.git\fieldtrip-20200130';
addpath(ftPath)   % FieldTtip Dir - in SYON.git folder
% addpath(genpath('C:/data_main/SYON_EEG/Functions/'))
ft_defaults;

%% Load and format
% File name
% fileName = [inputPath subjID '/' subjID '_' expID '.bdf'];
fileName = [inputPath subjID '_' expID '.bdf'];

clear cfg

cfg = [];
cfg.dataset = fileName;
cfg.trialdef.eventtype  = 'STATUS';

cfg.trialdef.eventvalue = [11 21 12 22 13 23];   % Event value for start of 2 min block
%     cfg.trialdef.eventvalue = 14;
cfg.trialdef.prestim    = 0;
cfg.trialdef.poststim   = 45;   % Grab 10s after block start

cfg = ft_definetrial(cfg);

cfg.reref = 'no';
cfg.refchannel = 'A1';
cfg.demean = 'no';
cfg.baselinewindow = [-0.2 0];
data = ft_preprocessing(cfg);

data.eventLabels = {'BlockStart'}';

data.eventsOrig = [cfg.event.value];
data.events = data.eventsOrig(ismember(data.eventsOrig,cfg.trialdef.eventvalue));
data.eventTPs = [cfg.event.sample];
data.eventTPs([1]) = [];   % Get ride of the first value (which is only 1 for whatever reason) - it doesn't correspond to an event
data.eventTPs = data.eventTPs(ismember(data.eventsOrig,cfg.trialdef.eventvalue));

for iI=1:length(data.events)
    data.dataRange{iI} = data.sampleinfo(iI,1):data.sampleinfo(iI,2);
end

%% Run FFT on 8s chunks of the raw EEG data
% Define the 1s chunk start:end timepoints
timeSegsFFT(1,:) = 0:1:cfg.trialdef.poststim-8;
timeSegsFFT(2,:) = 8:1:cfg.trialdef.poststim;
% Occ electrode list
options.elecList = [14 15 16 22 23 24 27 28 29];
for iI = 1:length(data.trial)   % For each block
    for iE = 1:length(options.elecList)   % For all occ electrodes
        for iK = 1:length(timeSegsFFT)
            dataIndex = data.trial{iI}(options.elecList(iE),...
                find(data.time{iI}==timeSegsFFT(1,iI)):find(data.time{iI}==timeSegsFFT(2,iI)));

            data.eegFFT{iI}.rawFFT(iE,iK,:) = abs(fft(dataIndex));

            % Grab the amplitudes and frequencies and convert to hz
            data.eegFFT{iI}.amp(iE,iK,:) = data.eegFFT{iI}.rawFFT(iE,iK,:);
            data.eegFFT{iI}.freq(iE,iK,:) = ([1:length(dataIndex)] * data.fsample) / length(dataIndex);

            clear datIndex
        end
    end
    % Average the fft across time segments and electrodes
    data.eegFFT{iI}.aveAmp_elec = squeeze(mean(data.eegFFT{iI}.amp,1));
    data.eegFFT{iI}.aveAmp = squeeze(mean(data.eegFFT{iI}.aveAmp_elec,1));
end

% First take the average across the eyes open/closed blocks
data.eegFFTAve.amp_open = mean([data.eegFFT{1}.aveAmp; data.eegFFT{3}.aveAmp; data.eegFFT{5}.aveAmp]);
data.eegFFTAve.amp_closed = mean([data.eegFFT{2}.aveAmp; data.eegFFT{4}.aveAmp; data.eegFFT{6}.aveAmp]);
data.eegFFTAve.freq = round(squeeze(data.eegFFT{iI}.freq(1,1,:)),2);


%% Identify and plot peak alphha
% Identify peak alpha frequency eyes open
% Find the range of values we care about
data.xRange = [1 49; 2 50];   % Index of amplitudes and frequencies (offset by 1 as the 1st frequency is 0)
data.ampIndex = data.eegFFTAve.freq > data.xRange(2,1) & data.eegFFTAve.freq < data.xRange(2,2);  % Find the frequencies you want to plot
data.ampArray_eyesOpen = data.eegFFTAve.amp_open(data.ampIndex);
data.freqIndex = data.eegFFTAve.freq > data.xRange(1,1) & data.eegFFTAve.freq < data.xRange(1,2);
data.freqArray = data.eegFFTAve.freq(data.ampIndex);

% Find the index of the alpha values
data.alphaRange = [7 13];
data.alphaIndex = data.freqArray > data.alphaRange(1) & ...
    data.freqArray < data.alphaRange(2);
data.alphaPeakFreq_eyesOpen = max(data.ampArray_eyesOpen(data.alphaIndex));
data.alphaPeakIndex_eyesOpen =  data.ampArray_eyesOpen == data.alphaPeakFreq_eyesOpen;  % Find the frequency which the alpha peak is at
data.alphaPeakAmp_eyesOpen = data.freqArray(data.alphaPeakIndex_eyesOpen);

% Plot the EEG FFT data
if options.displayFigs == 1
    % Grab the freq / amp values for 7-13Hz
    ampHolder = data.ampArray_eyesOpen(data.alphaIndex);
    freqHolder = data.freqArray(data.alphaIndex);
    figure()
    subplot(1,2,1)
    stem(freqHolder,...
        ampHolder,'Color','k')
    hold on
    % stem([freqHolder(data.alphaIndex(1)), freqHolder(data.alphaIndex(end))],...
    %     [ampHolder(data.alphaIndex(1)), ampHolder(data.alphaIndex(end))],'Color','y')   % Plot alpha range
    stem(data.freqArray(data.alphaPeakIndex_eyesOpen), data.ampArray_eyesOpen(data.alphaPeakIndex_eyesOpen),'Color','g')
    title('Eyes Open');
    
    clear ampHolder freqHolder
end

% Identify peak alpha frequency eyes closed
% Find the range of values we care about
data.ampArray_eyesClosed = data.eegFFTAve.amp_closed(data.ampIndex);

% Find the index of the alpha values
data.alphaPeakFreq_eyesClosed = max(data.ampArray_eyesClosed(data.alphaIndex));
data.alphaPeakIndex_eyesClosed =  data.ampArray_eyesClosed == data.alphaPeakFreq_eyesClosed;  % Find the frequency which the alpha peak is at
data.alphaPeakAmp_eyesClosed = data.freqArray(data.alphaPeakIndex_eyesClosed);

% Plot the EEG FFT data
if options.displayFigs == 1
    % Grab the freq / amp values for 7-13Hz
    ampHolder = data.ampArray_eyesClosed(data.alphaIndex);
    freqHolder = data.freqArray(data.alphaIndex);
    subplot(1,2,2)
    stem(freqHolder,...
        ampHolder,'Color','k')
    hold on
    % stem([freqHolder(data.alphaIndex(1)), freqHolder(data.alphaIndex(end))],...
    %     [ampHolder(data.alphaIndex(1)), ampHolder(data.alphaIndex(end))],'Color','y')   % Plot alpha range
    stem(data.freqArray(data.alphaPeakIndex_eyesClosed), data.ampArray_eyesClosed(data.alphaPeakIndex_eyesClosed),'Color','g')
    title('Eyes Closed');
    
    clear ampHolder freqHolder
end

end