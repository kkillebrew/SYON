% Script to read in photodiode spike recordings, count spikes, and look for
% timing between spikes and events as well as between individual spikes. 
% 
% Run from the functions folder in the functions folder in SYON.git

clear all; close all;

% Define input variables 

% 1 for plotting 
plotData = 0;
plotAveData = 1;
whichDataset = 1;   % 1=IllCont; 2=SSVEP; 3=GamOsc
whichSubj = 2;

if whichDataset == 1
    expName = 'IllCont';
elseif whichDataset == 2
    expName = 'SSVEP';
elseif whichDataset == 3
    expName = 'GamOsc';
end

if whichSubj == 1
    subjID = 'photodiode_test';
elseif whichSubj == 2
    subjID = 'photodiode_test2';
elseif whichSubj == 3
    subjID = 'photodiode_test3';
end

% Define paths
inputPath = '/labs/srslab/data_staging/SYON_testing/';
outputPath = ['/labs/srslab/data_main/SYON_testing/' expName '/data.mat/'];
ftPath = '../fieldtrip-20200130/';
addpath(ftPath)   % FieldTtip Dir - in SION.git folder
ft_defaults;

% File name
fileName = [inputPath subjID '/' subjID '_' expName '.bdf'];

% Load and format
event = ft_read_event(fileName);

cfg = [];
cfg.dataset = fileName;
cfg.trialdef.eventtype  = 'STATUS';

if whichDataset == 1
    cfg.trialdef.eventvalue = [2 3 4 5 6 7 8 9 10 11];
%     cfg.trialdef.eventvalue = 14;
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 0.6;
elseif whichDataset == 2
    cfg.trialdef.eventvalue = [10:14 16:31 111:114 116:119 121:124 126:131];
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 2.5;
elseif whichDataset == 3
    cfg.trialdef.eventvalue = [21 22 23 24];
    cfg.trialdef.prestim    = 0.2;
    cfg.trialdef.poststim   = 1;
end

cfg = ft_definetrial(cfg);

cfg.reref = 'no';
cfg.refchannel = 'A1';
cfg.demean = 'no';
cfg.baselinewindow = [-0.2 0];
data = ft_preprocessing(cfg);

if whichDataset == 1
    data.eventLabels = {'Fat','Thin','ULFat','URFat','LLFat','LRFat','ULThin','URThin','LLThin','LRThin'}';
elseif whichDataset == 2
    data.eventLabels = {'NoFlankVCenterUpper0'
        'NoFlankVCenterUpper10'
        'NoFlankVCenterUpper20'
        'NoFlankVCenterUpper40'
        'NoFlankVCenterUpper80'
        'NoFlankHCenterUpper10'
        'NoFlankHCenterUpper20'
        'NoFlankHCenterUpper40'
        'NoFlankHCenterUpper80'
        'FlankVCenterUpper0'
        'FlankVCenterUpper10'
        'FlankVCenterUpper20'
        'FlankVCenterUpper40'
        'FlankVCenterUpper80'
        'FlankHCenterUpper0'
        'FlankHCenterUpper10'
        'FlankHCenterUpper20'
        'FlankHCenterUpper40'
        'FlankHCenterUpper80'
        'FlankTaskUpper'
        'NoFlankTaskUpper'
        'NoFlankVCenterLower10'
        'NoFlankVCenterLower20'
        'NoFlankVCenterLower40'
        'NoFlankVCenterLower80'
        'NoFlankHCenterLower10'
        'NoFlankHCenterLower20'
        'NoFlankHCenterLower40'
        'NoFlankHCenterLower80'
        'FlankVCenterLower10'
        'FlankVCenterLower20'
        'FlankVCenterLower40'
        'FlankVCenterLower80'
        'FlankHCenterLower10'
        'FlankHCenterLower20'
        'FlankHCenterLower40'
        'FlankHCenterLower80'
        'FlankTaskLower'
        'NoFlankTaskLower'};
elseif whichDataset == 3
    data.eventLabels = {'1000s','1500s','2000s','2500s'}';
end

data.eventsOrig = [cfg.event.value];
data.events = data.eventsOrig(ismember(data.eventsOrig,cfg.trialdef.eventvalue));
data.eventTPs = [cfg.event.sample];
data.eventTPs([1]) = [];   % Get ride of the first value (which is only 1 for whatever reason) - it doesn't correspond to an event
data.eventTPs = data.eventTPs(ismember(data.eventsOrig,cfg.trialdef.eventvalue));

for i=1:length(data.events)
    data.dataRange{i} = data.sampleinfo(i,1):data.sampleinfo(i,2);
end

% Plot events overlaid on data
if plotData == 1
%         for i=1:length(data.events)
    for i=randperm(length(data.events),10)
        figure()
        plot((data.dataRange{i}==data.eventTPs(i))*5000)
        hold on
        plot(data.trial{i}(265,:))
        xticks(linspace(0,length(data.time{1}),5))
        xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
    end
end


% Find the spikes
% Find the peaks
for i=1:length(data.events)
    [data.spikes{i}.peaks, data.spikes{i}.locs] = findpeaks(data.trial{i}(265,:));
end

% Plot the peaks
if plotData == 1
%         for i=1:length(data.events)
%         for i=find(data.events~=9)   % JUST USE FOR NOW B/C EVENT 9 PHOTOTDIODE WAS OFFSET OF THE WHITE STIM
%         for i=1:length(data.events)
    for i=randperm(length(data.events),10)
        figure()
        plot(data.trial{i}(265,:))
        hold on
        plot(data.spikes{i}.locs,data.spikes{i}.peaks,'or')
        plot((data.dataRange{i}==data.eventTPs(i))*5000)
        xticks(linspace(0,length(data.time{1}),5))
        xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
    end
end

% Find the cutoff between white and gray, look for differences of >400
% plot(data.spikes{1}.peaks)
for j=1:length(data.spikes)
    for i=2:length(data.spikes{j}.peaks)
        data.spikes{j}.diffArray(i) = abs(data.spikes{j}.peaks(i)-data.spikes{j}.peaks(i-1));
    end
end
% plot(data.spikes.diffArray)

if whichDataset == 1
    for i=1:length(data.spikes)
        % Get rid of peaks that are part of a larger peak
        % Find the four max peaks, corr w/ the on/offset
        spikeDiffMaxHolder = findpeaks(data.spikes{i}.diffArray,'MinPeakDistance',20);
        spikeDiffMaxHolder = maxk(spikeDiffMaxHolder,4);
        
        data.spikeDiffMaxIdxHolder(i,:) = find(ismember(data.spikes{i}.diffArray,spikeDiffMaxHolder));
    
        % Average the values within the ranges of the max peak diffs
        data.aveWhitePeak(i) = nanmean([data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,1):data.spikeDiffMaxIdxHolder(i,2)) ...
            data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,3):data.spikeDiffMaxIdxHolder(i,4))]);
        data.aveGrayPeak(i) = nanmean([data.spikes{i}.peaks(1:data.spikeDiffMaxIdxHolder(i,1)-1) ...
            data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,2)+1:data.spikeDiffMaxIdxHolder(i,3)-1) ...
            data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,4)+1:length(data.spikes{i}.peaks))]);
        
        % Take the differencebetween the average gray and average white
        data.grayWhitePeakDiff(i) = (data.aveWhitePeak(i) + data.aveGrayPeak(i))/2;
        
    end
elseif whichDataset == 2
    for i=1:length(data.spikes)
        % Get rid of peaks that are part of a larger peak
        % Find the four max peaks, corr w/ the on/offset
        spikeDiffMaxHolder = findpeaks(data.spikes{i}.diffArray,'MinPeakDistance',20);
        spikeDiffMaxHolder = maxk(spikeDiffMaxHolder,2);
        
        spikeDiffMaxIdxHolder = find(ismember(data.spikes{i}.diffArray,spikeDiffMaxHolder));
    
        % Average the values within the ranges of the max peak diffs
        data.aveWhitePeak(i) = nanmean([data.spikes{i}.peaks(spikeDiffMaxIdxHolder(1):spikeDiffMaxIdxHolder(2))]);
        data.aveGrayPeak(i) = nanmean([data.spikes{i}.peaks(1:spikeDiffMaxIdxHolder(1)-1) ...
            data.spikes{i}.peaks(spikeDiffMaxIdxHolder(2)+1:length(data.spikes{i}.peaks))]);
        
        % Take the differencebetween the average gray and average white
        data.grayWhitePeakDiff(i) = (data.aveWhitePeak(i) + data.aveGrayPeak(i))/2;
        
    end
elseif whichDataset == 3
    for i=1:length(data.spikes)
        % Get rid of peaks that are part of a larger peak
        % Find the four max peaks, corr w/ the on/offset
        spikeDiffMaxHolder = findpeaks(data.spikes{i}.diffArray,'MinPeakDistance',20);
        spikeDiffMaxHolder = maxk(spikeDiffMaxHolder,2);
        
        spikeDiffMaxIdxHolder = find(ismember(data.spikes{i}.diffArray,spikeDiffMaxHolder));
        
        % Average the values within the ranges of the max peak diffs
        data.aveWhitePeak(i) = nanmean([data.spikes{i}.peaks(spikeDiffMaxIdxHolder(1):spikeDiffMaxIdxHolder(2))]);
        data.aveGrayPeak(i) = nanmean([data.spikes{i}.peaks(1:spikeDiffMaxIdxHolder(1)-1) ...
            data.spikes{i}.peaks(spikeDiffMaxIdxHolder(2)+1:length(data.spikes{i}.peaks))]);
        
        % Take the differencebetween the average gray and average white
        data.grayWhitePeakDiff(i) = (data.aveWhitePeak(i) + data.aveGrayPeak(i))/2;
    end
end


% Find the time difference between the event and the stim onset
for i=1:length(data.events)
    
    % The time points at which the event occured are in data.eventTPs
    
    % Find the time point where the first peak occurs.
    % Find the amps of each peak
    data.spikes{i}.whitePeaks = data.spikes{i}.peaks((data.spikes{i}.peaks>=data.grayWhitePeakDiff(i)));
    data.spikes{i}.grayPeaks = data.spikes{i}.peaks(data.spikes{i}.peaks<data.grayWhitePeakDiff(i));
    
    % Find the locs of each peak
    data.spikes{i}.whiteLocs = data.spikes{i}.locs((data.spikes{i}.peaks>=data.grayWhitePeakDiff(i)));
    data.spikes{i}.grayLocs = data.spikes{i}.locs(data.spikes{i}.peaks<data.grayWhitePeakDiff(i));
    
    % If there are less tha 10 peaks for either gray or white, or the diff 
    % between gray/white ave peak is a small num (or neg), it is an
    % invalid trial. (Most likely something weird happened during data
    % collection). So don't calculate for that event.
    if (length(data.spikes{i}.whitePeaks) < 10 || length(data.spikes{i}.grayPeaks) < 10) ||...
            data.grayWhitePeakDiff(i) < 10000
        data.spikes{i}.stimOnset = NaN;
        data.eventOffset(i) = NaN;
        % Find the mask onset for ill cont data
        if whichDataset == 1
            data.maskOffset(i) = NaN;
        end
    else
        % Find the first white peak
        data.spikes{i}.stimOnset = data.time{i}(data.spikes{i}.whiteLocs(1));
        
        % Find the mask onset for ill cont data
        if whichDataset == 1
            % Find the firs white peak of the mask onset
            % Look for the loc of the long break between end of stim onset and start
            % of mask onset.
            for j=2:length( data.spikes{i}.whiteLocs)
                holder(j) = data.spikes{i}.whiteLocs(j)-data.spikes{i}.whiteLocs(j-1);
                if holder(j)>20
                   data.spikes{i}.maskOnsetLoc = data.spikes{i}.whiteLocs(j); 
                   data.spikes{i}.maskOnsetPeak = data.spikes{i}.whitePeaks(j);
                end
            end
            clear holder
            
            
            data.spikes{i}.maskOnset = data.time{i}(data.spikes{i}.maskOnsetLoc);
        end
        
        if data.spikes{i}.stimOnset < 0
            data.spikes{i}.stimOnset = NaN;
            data.eventOffset(i) = NaN;
            % Find the mask onset for ill cont data
            if whichDataset == 1
                data.spikes{i}.maskOnset = NaN;
            end
        else
            % Take the difference between event and stim onsets
            %         data.eventOffset(peakCounter) = data.spikes{i}.stimOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
            data.eventOffset(i) = data.spikes{i}.stimOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
            % Find the mask onset for ill cont data
            if whichDataset == 1
                data.maskOffset(i) = data.spikes{i}.maskOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
            end
        end
    end
end

% Grab the 'weird' trials (if any) from photodiode problems
data.weirdTrials = find(isnan(data.eventOffset)==1);

for i=data.weirdTrials
    figure()
    plot(data.trial{i}(265,:))
    hold on
    plot(data.spikes{i}.locs,data.spikes{i}.peaks,'or')
    plot((data.dataRange{i}==data.eventTPs(i))*5000)
    xticks(linspace(0,length(data.time{1}),5))
    xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
end

% Plot the peaks
% if plotData == 1
%             for i=1:length(data.events)
%         for i=find(data.events~=9)   % JUST USE FOR NOW B/C EVENT 9 PHOTOTDIODE WAS OFFSET OF THE WHITE STIM
for i=randperm(length(data.events),10)
    figure()
    plot(data.trial{i}(265,:))
    hold on
    plot(data.spikes{i}.grayLocs,data.spikes{i}.grayPeaks,'or')
    plot(data.spikes{i}.whiteLocs,data.spikes{i}.whitePeaks,'ob')
    plot(data.spikes{i}.whiteLocs(1),data.spikes{i}.whitePeaks(1),'og')
    plot(data.spikes{i}.maskOnsetLoc,data.spikes{i}.maskOnsetPeak,'oy')
    plot((data.dataRange{i}==data.eventTPs(i))*5000)
    xticks(linspace(0,length(data.time{1}),5))
    xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
end
% end

% Take the average offset
data.eventOffsetAve = nanmean(data.eventOffset);
data.eventOffsetSTE = ste(data.eventOffset);
data.eventOffsetSTD = nanstd(data.eventOffset);

% Take the average offset as a function of event type
data.uniqueEvents = unique(data.events);
for i=1:length(data.uniqueEvents)
    
    data.uniqueEventOffsetAve(i) = nanmean(data.eventOffset(data.events==data.uniqueEvents(i)));
    data.uniqueEventOffsetSTE(i) = ste(data.eventOffset(data.events==data.uniqueEvents(i)));
    data.uniqueEventOffsetSTD(i) = nanstd(data.eventOffset(data.events==data.uniqueEvents(i)));
    
end

% Look at average mask onset
if whichDataset==1
    data.maskOffsetAve = nanmean(data.maskOffset);
    data.maskOffsetSTE = ste(data.maskOffset);
    data.maskOffsetSTD = nanstd(data.maskOffset);
    
    for i=1:length(data.uniqueEvents)
        data.uniqueMaskOffsetAve(i) = nanmean(data.maskOffset(data.events==data.uniqueEvents(i)));
        data.uniqueMaskOffsetSTE(i) = ste(data.maskOffset(data.events==data.uniqueEvents(i)));
        data.uniqueMaskOffsetSTD(i) = nanstd(data.maskOffset(data.events==data.uniqueEvents(i)));
    end
end

% Plot the offsets
if plotAveData == 1
    figure()
    bar(data.uniqueEventOffsetAve)
    hold on
    bar(length(data.uniqueEventOffsetAve)+1,data.eventOffsetAve)
    errorbar(data.uniqueEventOffsetAve,data.uniqueEventOffsetSTD,'.k')
    errorbar(length(data.uniqueEventOffsetAve)+1,data.eventOffsetAve,data.eventOffsetSTD,'.k')
    xticks(1:length(data.uniqueEvents)+1)
    eventLabels = [data.eventLabels' 'Average'];
%     eventLabels = [num2cell(data.uniqueEvents) 'Average'];
    nEventsTotal = 0;
    for j=1:length(eventLabels)
        if j<length(eventLabels)
            nEvents = sum(~isnan(data.eventOffset(data.events==data.uniqueEvents(j))));
            nEventsTotal = nEvents+nEventsTotal;
            eventLabels{j} = sprintf('%s%s%d',eventLabels{j},', n=',nEvents);
        end
    end
    eventLabels{length(eventLabels)} = sprintf('%s%s%d',eventLabels{length(eventLabels)},', n=',nEventsTotal);
    ylim([-.01 .1])
    xticklabels(eventLabels)
    xtickangle(315)
    xlabel('Event Code')
    ylabel('Event Offset (s)')
    title('Stim Offset By Event Code')
end

% Plot the mask offset if ill cont
if whichDataset==1
    figure()
    bar(data.uniqueMaskOffsetAve)
    hold on
    bar(length(data.uniqueMaskOffsetAve)+1,data.maskOffsetAve)
    errorbar(data.uniqueMaskOffsetAve,data.uniqueMaskOffsetSTD,'.k')
    errorbar(length(data.uniqueMaskOffsetAve)+1,data.maskOffsetAve,data.maskOffsetSTD,'.k')
    xticks(1:length(data.uniqueEvents)+1)
    eventLabels = [data.eventLabels' 'Average'];
%     eventLabels = [num2cell(data.uniqueEvents) 'Average'];
    nEventsTotal = 0;
    for j=1:length(eventLabels)
        if j<length(eventLabels)
            nEvents = sum(~isnan(data.maskOffset(data.events==data.uniqueEvents(j))));
            nEventsTotal = nEvents+nEventsTotal;
            eventLabels{j} = sprintf('%s%s%d',eventLabels{j},', n=',nEvents);
        end
    end
    eventLabels{length(eventLabels)} = sprintf('%s%s%d',eventLabels{length(eventLabels)},', n=',nEventsTotal);
    ylim([-.01 .75])
    xticklabels(eventLabels)
    xtickangle(315)
    xlabel('Event Code')
    ylabel('Mask Offset (s)')
    title('Mask Offset By Event Code')
end




