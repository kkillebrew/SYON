% Script to read in photodiode spike recordings, count spikes, and look for
% timing between spikes and events as well as between individual spikes,
% for the  BR EEG task.
%
% Run from the functions folder in the functions folder in SYON.git

function [options,data] = BREntrain_FFT_analysis(options,data)

clear all; close all;
%%
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'top_dir')
    options.top_dir = 'Z:\data_main\SYON.git\Bistable_Tasks\BinoRiv_Task\EEG_Task\Data\';
%     options.top_dir = '/labs/srslab/data_main/SYON.git/Bistable_Tasks/BinoRiv_Task/EEG_Task/Data/';
    % options.top_dir = 'E:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\EEG_Task\Data\';
%     options.top_dir = 'C:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';
end

%% Define input variables

% 1 for plotting
plotData = 1;
plotAveData = 1;

subjID = {'PhotodiodeTest_8hz'};
% subjID = 'PhotodiodeTest_10hz';
% subjID = 'PhotodiodeTest_12hz';
% subjID = {'PhotodiodeTest_8hz', 'PhotodiodeTest_10hz', 'PhotodiodeTest_12hz'};
% subjID = {'PhotodiodeTest8hz', 'PhotodiodeTest10hz', 'PhotodiodeTest12hz'};
% expID = 'BRSSVEP';

addpath(genpath('Z:\data_main\SYON.git\Functions\'))
options.curDur = 'Z:\data_main\SYON.git\Bistable_Tasks\BinoRiv_Task\EEG_Task\Data\';

% addpath(genpath('E:\GitRepos\SYON.git\Functions'))
% options.curDur = 'E:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\EEG_Task\Data\';

% addpath(genpath('C:\GitRepos\SYON.git\Functions'))
% options.curDur = 'C:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';

% Define EEG paths
options.EEGinputPath = 'Z:/data_staging/SYON_EEG/PhotodiodeTest_September1/';
options.EEGoutputPath = 'Z:/data_main/SYON_EEG/PhotodiodeTest_September1/';
options.ftPath = 'C:\Users\EEG Task Computer\Desktop\SYON.git/fieldtrip-20200130/';

% options.EEGinputPath = '/labs/srslab/data_staging/SYON_EEG/PhotodiodeTest_September1/';
% options.EEGoutputPath = '/labs/srslab/data_main/SYON_EEG/PhotodiodeTest_September1/';
% options.ftPath = '/labs/srslab/data_main/SYON.git/fieldtrip-20200130/';
addpath(options.ftPath)   % FieldTtip Dir - in SYON.git folder
ft_defaults;

% Define subj list for behav
for iS = 1:length(subjID)
    data{iS}.behav.dataFileList = [options.top_dir subjID{iS} '_BinoRiv_Task_001.mat'];
    data{iS}.behav.subjID = subjID{iS};
    % data{iS}.behav.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
end

% % Ensure all the files are actually data files and not tests/pilots
% dataAve.A.dataFileList = dir(fullfile(options.top_dir,'S*BinoRiv*.mat'));
% data{iS}.behav.subjID = holderName(~holderTaskDataIdx);
% data{iS}.behav.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
% holderName = {dataAve.A.dataFileList.name};
% holderName = cellfun(@(x) x(1:8), holderName, 'UniformOutput', false);
% holderNum = cellfun(@(x) x(2:8), holderName, 'UniformOutput', false);
% % Returns a number for each subject that indexes where in the string
% % (holderName{iI}) the patter shown in the second input begins. It checks
% % each input in holderName for the patter (letter digit digit ...). Any
% % value w/ a '0' or empty in the output means that file is not correct and
% % should be tossed.
% holderTaskData = regexp(holderName, '\w\d\d\d\d\d\d\d','once');
% holderTaskDataIdx = cellfun('isempty',holderTaskData);
% data{iS}.behav.eeg.dataFileList(holderTaskDataIdx) = [];
% data{iS}.behav.subjID = holderName(~holderTaskDataIdx);
% data{iS}.behav.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
% clear holderName holderTaskData holderTaskDataIdx

% Define subj list for EEG
% File name
for iS = 1:length(subjID)
    % options.EEGfileName = [options.EEGinputPath subjID{iS} '/' subjID{iS} '_' expID '.bdf'];
    options.EEGfileName = [options.EEGinputPath subjID{iS} '.bdf'];
end

%% Look EEG and behav data for each subject
for iS = 1:length(subjID)
    %% Load in the behavioral data
    % Load in data files for each participant
    % behavData = load([data{iS}.behav.dataFileList.folder '/' data{iS}.behav.dataFileList.name],'data');
    behavData = load(data{iS}.behav.dataFileList, 'data');
    data{iS}.behav.rawdata = behavData.data.rawdata;
    data{iS}.behav.rawdataPractice = behavData.data.practice;

    % Load in a couple fields from the options file
    % behavOptions = load([dataAve.B.dataFileList(iS).folder '/' dataAve.B.dataFileList(iS).name],'options');
    behavOptions = load(data{iS}.behav.dataFileList,'options');
    options.runLength = behavOptions.options.runLength;
    options.hz = behavOptions.options.wInfoNew.hz;
    options.cyclePeak = behavOptions.options.flicker.flickerHz;
    clear behavOptions behavData

    %% Calculate switch rate values
    for iJ=1:size(data{iS}.behav.rawdata,1)
        percHolder = 0;
        counter = 0;
        for iI=1:size(data{iS}.behav.rawdata,2)

            % Look for a change in response
            if data{iS}.behav.rawdata(iJ,iI,2) ~= 0 && data{iS}.behav.rawdata(iJ,iI,2) ~= percHolder
                percHolder = data{iS}.behav.rawdata(iJ,iI,2);

                % Record the time and type
                counter = counter+1;
                data{iS}.behav.percSwitch{iS}{iJ}(counter) = data{iS}.behav.rawdata(iJ,iI,2);
                data{iS}.behav.percSwitchTime{iS}{iJ}(counter) = data{iS}.behav.rawdata(iJ,iI,1);

            end
        end

        % If no switches create an empty array for this participant for
        % this block
        if counter == 0 || counter == 1
            data{iS}.behav.percSwitch{iS}{iJ} = [];
            data{iS}.behav.percSwitchTime{iS}{iJ} = [];
        end
        clear percHolder

        % Added in order to not include first percept. - KWK 20231109
        data{iS}.behav.percSwitch{iS}{iJ} = data{iS}.behav.percSwitch{iS}{iJ}(2:end);
        data{iS}.behav.percSwitchTime{iS}{iJ} = data{iS}.behav.percSwitchTime{iS}{iJ}(2:end);

        % Number of flips total in this block
        data{iS}.behav.nFlips(iS,iJ) = numel(data{iS}.behav.percSwitch{iS}{iJ});

        % Duration of each dominant percept
        % This grabs the times or reported switches and subtracts each of
        % them from the prior switch time (first switch gets sub'd from 0)
        data{iS}.behav.perceptDur{iS}{iJ} = [data{iS}.behav.percSwitchTime{iS}{iJ}' - ...
            [0 ; data{iS}.behav.percSwitchTime{iS}{iJ}(1:end-1)']];

        % Swtich rate
        data{iS}.behav.switchRate(iS,iJ) = length(data{iS}.behav.percSwitch{iS}{iJ})/options.runLength;

        % Average perc dur
        data{iS}.behav.perDurAve(iS,iJ) = nanmean(data{iS}.behav.perceptDur{iS}{iJ});

        % CV
        data{iS}.behav.CV(iS,iJ) = ...
            std(data{iS}.behav.perceptDur{iS}{iJ}) / ...
            data{iS}.behav.perDurAve(iS,iJ); % mps 20200519 - kwk adapted for Br 20230206

    end

    %% Load and format EEG data
    % event = ft_read_event(options.EEGfileName);
    
    clear cfg

    cfg = [];
    cfg.dataset = options.EEGfileName;
    cfg.trialdef.eventtype  = 'STATUS';

    cfg.trialdef.eventvalue = [4];   % Event value for start of 2 min block
    %     cfg.trialdef.eventvalue = 14;
    cfg.trialdef.prestim    = 0;
    cfg.trialdef.poststim   = 120;   % Grab 10s after block start

    cfg = ft_definetrial(cfg);

    cfg.reref = 'no';
    cfg.refchannel = 'A1';
    cfg.demean = 'no';
    cfg.baselinewindow = [-0.2 0];
    data{iS}.eeg = ft_preprocessing(cfg);

    data{iS}.eeg.eventLabels = {'BlockStart'}';

    data{iS}.eeg.eventsOrig = [cfg.event.value];
    data{iS}.eeg.events = data{iS}.eeg.eventsOrig(ismember(data{iS}.eeg.eventsOrig,cfg.trialdef.eventvalue));
    data{iS}.eeg.eventTPs = [cfg.event.sample];
    data{iS}.eeg.eventTPs([1]) = [];   % Get ride of the first value (which is only 1 for whatever reason) - it doesn't correspond to an event
    data{iS}.eeg.eventTPs = data{iS}.eeg.eventTPs(ismember(data{iS}.eeg.eventsOrig,cfg.trialdef.eventvalue));

    for iI=1:length(data{iS}.eeg.events)
        data{iS}.eeg.dataRange{iI} = data{iS}.eeg.sampleinfo(iI,1):data{iS}.eeg.sampleinfo(iI,2);
    end

    photodiode_number = 171;
    cyclePeak = options.cyclePeak;   % SSVEP rates of interest
    truePeak = options.hz;   % Refresh rate

    %% Load in resting data
    

    %% Run FFT on 1s chunks of the raw EEG data
    % Occ electrode list
    options.elecList = [14 15 16 22 23 24 27 28 29];

    % Define the 1s chunk start:end timepoints
    timeSegsFFT(1,:) = 0:1:cfg.trialdef.poststim-8;
    timeSegsFFT(2,:) = 8:1:cfg.trialdef.poststim;
    
    for iI = 1:length(data{iS}.eeg.trial)   % For each block
        for iE = 1:length(options.elecList)   % For all occ electrodes
            for iK = 1:length(timeSegsFFT)
                % Grab the relevant data
                dataIndex = data{iS}.eeg.trial{iI}(options.elecList(iE),...
                    find(data{iS}.eeg.time{iI}==timeSegsFFT(1,iI)):find(data{iS}.eeg.time{iI}==timeSegsFFT(2,iI)));

                % Take the fft
                data{iS}.eeg.eegFFT{iI}.rawFFT(iE,iK,:) = abs(fft(dataIndex));

                % Grab the amplitudes and frequencies and convert to hz
                data{iS}.eeg.eegFFT{iI}.amp(iE,iK,:) = data{iS}.eeg.eegFFT{iI}.rawFFT(iE,iK,:);
                data{iS}.eeg.eegFFT{iI}.freq(iE,iK,:) = ([1:length(dataIndex)] * data{iS}.eeg.fsample) / length(dataIndex);

                clear datIndex
            end
        end
        % Average the fft across time segments and electrodes
        data{iS}.eeg.eegFFT{iI}.aveAmp_elec = squeeze(mean(data{iS}.eeg.eegFFT{iI}.amp,1));
        data{iS}.eeg.eegFFT{iI}.aveAmp = squeeze(mean(data{iS}.eeg.eegFFT{iI}.aveAmp_elec,1));
    end

    % Take the average across the 3 blocks
    data{iS}.eeg.eegFFTAve.amp = mean([data{iS}.eeg.eegFFT{1}.aveAmp; data{iS}.eeg.eegFFT{2}.aveAmp; data{iS}.eeg.eegFFT{3}.aveAmp ]);
    data{iS}.eeg.eegFFTAve.freq = round(squeeze(data{iS}.eeg.eegFFT{iI}.freq(1,1,:)),2);

    %% Identify peak alpha frequency
    % Find the range of values we care about
    xRange = [1 49; 2 50];   % Index of amplitudes and frequencies (offset by 1 as the 1st frequency is 0)
    ampIndex = data{iS}.eeg.eegFFTAve.freq > xRange(2,1) & data{iS}.eeg.eegFFTAve.freq < xRange(2,2);  % Find the frequencies you want to plot
    ampHolder = data{iS}.eeg.eegFFTAve.amp(ampIndex);
    freqIndex = data{iS}.eeg.eegFFTAve.freq > xRange(1,1) & data{iS}.eeg.eegFFTAve.freq < xRange(1,2);
    freqHolder = data{iS}.eeg.eegFFTAve.freq(ampIndex);

    % Find the index of the alpha values
    alphaRange = [8 12];
    alphaIndex = freqHolder > alphaRange(1) & ...
        freqHolder < alphaRange(2);
    alphaPeak = max(ampHolder(alphaIndex));
    alphaPeakIndex =  ampHolder == alphaPeak;  % Find the frequency which the alpha peak is at

    %% Plot the EEG FFT data
    if plotData == 1
        figure()
        stem(freqHolder,...
            ampHolder,'Color','k')
        hold on
        cycleIndex = data{iS}.eeg.eegFFTAve.freq == cyclePeak-1;
        % stem([freqHolder(alphaIndex(1)), freqHolder(alphaIndex(end))],...
        %     [ampHolder(alphaIndex(1)), ampHolder(alphaIndex(end))],'Color','y')   % Plot alpha range
        stem(freqHolder(cycleIndex), ampHolder(cycleIndex),'Color','g')   % Plot the cycle peak value
        stem(freqHolder(alphaPeakIndex), ampHolder(alphaPeakIndex),'Color','r')

        clear ampHolder freqHolder
    end

    %% Correlate resting EEG alpha peak with switch rate value


end



end

