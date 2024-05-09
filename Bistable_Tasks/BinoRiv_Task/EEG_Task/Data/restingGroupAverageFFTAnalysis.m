function [options,data] = restingGroupAverageFFTAnalysis(options,data)

clear all; close all;

%% Define input variables
% 1 for plotting
plotData = 1;
plotAveData = 1;

% subjID = 'PhotodiodeTest_RestingEEG';
% expID = 'BRSSVEP';

% Define paths
inputPath = 'Z:/data_staging/SYON_EEG/PhotodiodeTest_September1/';
outputPath = 'Z:/data_main/SYON_EEG/PhotodiodeTest_September1/';
ftPath = 'C:\Users\EEG Task Computer\Desktop\SYON.git\fieldtrip-20200130';
addpath(ftPath)   % FieldTtip Dir - in SION.git folder
addpath(genpath('Z:/data_main/SYON_EEG/Functions/'))

% inputPath = '/labs/srslab/data_staging/SYON_EEG/PhotodiodeTest_September1/';
% outputPath = '/labs/srslab/data_main/SYON_EEG/PhotodiodeTest_September1/';
% ftPath = '/labs/srslab/data_main/SYON.git/fieldtrip-20200130/';
% addpath(ftPath)   % FieldTtip Dir - in SION.git folder
% addpath(genpath('/labs/srslab/data_main/SYON_EEG/Functions/'))
ft_defaults;

%% Load and format
% File name
% fileName = [inputPath subjID '/' subjID '_' expID '.bdf'];
fileName = [inputPath subjID '.bdf'];
event = ft_read_event(fileName);

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

%% Run FFT on 1s chunks of the raw EEG data
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
            data.eegFFT{iI}.freq(iE,iK,:) = ([1:length(dataIndex)] * length(dataIndex)) / data.fsample;

            clear datIndex
        end
    end
    % Average the fft across time segments and electrodes
    data.eegFFT{iI}.aveAmp_elec = squeeze(mean(data.eegFFT{iI}.amp,1));
    data.eegFFT{iI}.aveAmp = squeeze(mean(data.eegFFT{iI}.aveAmp_elec,1));
end

%% Plot the EEG FFT data
% First take the average across the eyes open/closed blocks
data.eegFFTAve.amp_open = mean([data.eegFFT{1}.aveAmp; data.eegFFT{2}.aveAmp]);
data.eegFFTAve.amp_closed = mean([data.eegFFT{3}.aveAmp; data.eegFFT{4}.aveAmp]);
data.eegFFTAve.freq = squeeze(data.eegFFT{iI}.freq(1,1,:));

if plotData == 1
    figure()
    subplot(1,2,1)
    ampHolder = data.eegFFTAve.amp_open(2:50);
    freqHolder = data.eegFFTAve.freq(1:49);
    stem(freqHolder,...
        ampHolder,'Color','k')

    clear ampHolder freqHolder

    subplot(1,2,2)
    ampHolder = data.eegFFTAve.amp_closed(2:50);
    freqHolder = data.eegFFTAve.freq(1:49);
    stem(freqHolder,...
        ampHolder,'Color','k')

    clear ampHolder freqHolder
end

end