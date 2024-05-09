% Script to read in photodiode spike recordings, count spikes, and look for
% timing between spikes and events as well as between individual spikes, 
% for the  BR EEG task.
% 
% Run from the functions folder in the functions folder in SYON.git

clear all; close all;

%% Define input variables 

% 1 for plotting 
plotData = 1;
plotAveData = 1;

expName = 'SSVEP_BR';
% subjID = 'PhotodiodeTest_8hz';
% subjID = 'PhotodiodeTest_10hz';
% subjID = 'PhotodiodeTest_12hz';
subjID = {'PhotodiodeTest_8hz', 'PhotodiodeTest_10hz', 'PhotodiodeTest_12hz'};

% Define paths
% inputPath = '/labs/srslab/data_staging/SYON_EEG/PhotodiodeTest_September1/';
% outputPath = '/labs/srslab/data_main/SYON_EEG/PhotodiodeTest_September1/';
% ftPath = '/labs/srslab/data_main/SYON.git/fieldtrip-20200130/';

inputPath = 'Z:/srslab/data_staging/SYON_EEG/PhotodiodeTest_September1/';
outputPath = 'Z:/srslab/data_main/SYON_EEG/PhotodiodeTest_September1/';
ftPath = 'C:\Users\EEG Task Computer\Desktop\SYON.git\Functions\fieldtrip-20200130\';

addpath(ftPath)   % FieldTtip Dir - in SION.git folder
ft_defaults;

%% Look at spikes from each Hz condition (8, 10, 12)f
for iS = 1:length(subjID)
    %% Load and format
    % File name
    fileName = [inputPath subjID{iS} '.bdf'];
    event = ft_read_event(fileName);

    clear cfg

    cfg = [];
    cfg.dataset = fileName;
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
    data{iS} = ft_preprocessing(cfg);

    data{iS}.eventLabels = {'BlockStart'}';

    data{iS}.eventsOrig = [cfg.event.value];
    data{iS}.events = data{iS}.eventsOrig(ismember(data{iS}.eventsOrig,cfg.trialdef.eventvalue));
    data{iS}.eventTPs = [cfg.event.sample];
    data{iS}.eventTPs([1]) = [];   % Get ride of the first value (which is only 1 for whatever reason) - it doesn't correspond to an event
    data{iS}.eventTPs = data{iS}.eventTPs(ismember(data{iS}.eventsOrig,cfg.trialdef.eventvalue));

    for i=1:length(data{iS}.events)
        data{iS}.dataRange{i} = data{iS}.sampleinfo(i,1):data{iS}.sampleinfo(i,2);
    end

    photodiode_number = 171;

    %% Find all spikes
    % sampling rate of photodiode = .00048s
    % Find the peaks
    for i=1:length(data{iS}.events)
        [data{iS}.spikes{i}.peaks, data{iS}.spikes{i}.locs] = findpeaks(data{iS}.trial{i}(photodiode_number,:));
    end

    % % Plot the peaks
    % if plotData == 1
    %     for i=1:length(data{iS}.events)
    %         figure()
    %         plot(data{iS}.trial{i}(photodiode_number,:))
    %         hold on
    %         plot(data{iS}.spikes{i}.locs,data{iS}.spikes{i}.peaks,'or')
    %         plot((data{iS}.dataRange{i}==data{iS}.eventTPs(i))*5000)
    %         xticks(linspace(0,length(data{iS}.time{1}),5))
    %         xticklabels(linspace(data{iS}.time{i}(1),data{iS}.time{i}(end),5))
    %     end
    % end

    %% Find the screen flips (true peaks)
    % Seems like there are too many samples and each 'peak' is accompanied by
    % other smaller peaks. Find each major peak, or the point at which the
    % peaks reverse direction.
    for iI = 1:length(data{iS}.spikes)
        peakCounter = 1;
        % Find the initial direction of the peaks (pos or neg)
        if data{iS}.spikes{iI}.peaks(1) > data{iS}.spikes{iI}.peaks(2)
            peakDiffDir = 1;
        else
            peakDiffDir = 2;
        end
        for iJ = 2:length(data{iS}.spikes{iI}.peaks)-1
            % Compare to previous peak and find direction (pos or neg)
            if data{iS}.spikes{iI}.peaks(iJ) > data{iS}.spikes{iI}.peaks(iJ+1)
                peakDiffDirHolder = 1;
            else
                peakDiffDirHolder = 2;
            end

            if peakDiffDirHolder == peakDiffDir % If they're the same (both pos or both neg) we haven't reached the peak
            elseif peakDiffDirHolder == 2 & peakDiffDir == 1   % If previous was a pos reversal its a trough, ignore
                peakDiffDir = 3-peakDiffDir;
            elseif peakDiffDirHolder == 1 & peakDiffDir == 2   % If previous was a pos reversal its a true peak, record
                data{iS}.spikes{iI}.truePeak(peakCounter) = data{iS}.spikes{iI}.peaks(iJ);
                data{iS}.spikes{iI}.truePeakLocs(peakCounter) = data{iS}.spikes{iI}.locs(iJ);
                peakDiffDir = 3-peakDiffDir;
                peakCounter = peakCounter+1;
            end
        end
    end

    % % Plot the true peaks only
    % if plotData == 1
    %     for i=1:length(data{iS}.events)
    %         figure()
    %         plot(data{iS}.trial{i}(photodiode_number,:))
    %         hold on
    %         plot(data{iS}.spikes{i}.truePeakLocs,data{iS}.spikes{i}.truePeak,'or')
    %         plot((data{iS}.dataRange{i}==data{iS}.eventTPs(i))*5000)
    %         xticks(linspace(0,length(data{iS}.time{1}),5))
    %         xticklabels(linspace(data{iS}.time{i}(1),data{iS}.time{i}(end),5))
    %     end
    % end


    %% Find the cycles (SSVEP changes in contrast)
    % Want to do the same thing as above, this time finding the reversals in
    % the true peaks, which indicate a minimum/maximum in the cycle.
    for iI = 1:length(data{iS}.spikes)
        peakCounter = 1;
        % Find the initial direction of the peaks (pos or neg)
        if data{iS}.spikes{iI}.truePeak(1) > data{iS}.spikes{iI}.truePeak(2)
            peakDiffDir = 1;
        else
            peakDiffDir = 2;
        end
        for iJ = 2:length(data{iS}.spikes{iI}.truePeak)-1
            % Compare to previous peak and find direction (pos or neg)
            if data{iS}.spikes{iI}.truePeak(iJ) > data{iS}.spikes{iI}.truePeak(iJ+1)
                peakDiffDirHolder = 1;
            else
                peakDiffDirHolder = 2;
            end

            if peakDiffDirHolder == peakDiffDir % If they're the same (both pos or both neg) we haven't reached the peak
            elseif peakDiffDirHolder == 2 & peakDiffDir == 1   % If previous was a pos reversal its a trough, ignore
                peakDiffDir = 3-peakDiffDir;
            elseif peakDiffDirHolder == 1 & peakDiffDir == 2   % If previous was a pos reversal its a true peak, record
                % As there is some variablilty in the raw values of the true
                % peaks, we only want to look at the peaks > 1400.
                peakDiffDir = 3-peakDiffDir;
                if data{iS}.spikes{iI}.truePeak(iJ) > 14000
                    data{iS}.spikes{iI}.cyclePeak(peakCounter) = data{iS}.spikes{iI}.truePeak(iJ);
                    data{iS}.spikes{iI}.cyclePeakLocs(peakCounter) = data{iS}.spikes{iI}.truePeakLocs(iJ);
                    peakCounter = peakCounter+1;
                end
            end
        end
    end

    
    %% Run a fourier transform on the raw photodiode data
    for iI=1:length(data{iS}.spikes)
        % Downsample the photodiode data
%         photodiodeDataDownSample = ;

        data{iS}.spikes{iI}.rawFFT = abs(fft(data{iS}.trial{i}(photodiode_number,:)));
    end
    

    
    %% Look at average number of spikes in 2 second windows
    % Grab the time points at the locations of the spikes we care about
    % Make list of time points to segment spikes into 2 second chunks
    for iI=1:size(data{iS}.spikes,2)
        data{iS}.spikes{iI}.cyclePeakTimes = data{iS}.time{iI}(data{iS}.spikes{iI}.cyclePeakLocs);
        data{iS}.spikes{iI}.truePeakTimes = data{iS}.time{iI}(data{iS}.spikes{iI}.truePeakLocs);
    end

    % List of time segment windows
    timeSegs(1,:) = 0:2:cfg.trialdef.poststim-2;
    timeSegs(2,:) = 2:2:cfg.trialdef.poststim;

    % Walk through each time segment and grab all peaks within the window
    for iI=1:size(data{iS}.spikes,2)
        for iJ = 1:length(timeSegs)
            truePeakIndex = find(data{iS}.spikes{iI}.truePeakTimes>timeSegs(1,iJ) &...
                data{iS}.spikes{iI}.truePeakTimes<timeSegs(2,iJ));

            data{iS}.spikes{iI}.numTruePeaks(iJ) = numel(data{iS}.spikes{iI}.truePeak(truePeakIndex));

            cyclePeakIndex = find(data{iS}.spikes{iI}.cyclePeakTimes>timeSegs(1,iJ) &...
                data{iS}.spikes{iI}.cyclePeakTimes<timeSegs(2,iJ));

            data{iS}.spikes{iI}.numCyclePeaks(iJ) = numel(data{iS}.spikes{iI}.cyclePeak(cyclePeakIndex));

            clear truePeakIndex
        end
    end

    %% Plot
    % Plot the true peaks including cycle peaks in different color
    if plotData == 1
        for i=1:length(data{iS}.events)
            figure()
            subplot(2,2,1:2)
            plot(data{iS}.trial{i}(photodiode_number,:))
            hold on
            plot(data{iS}.spikes{i}.truePeakLocs,data{iS}.spikes{i}.truePeak,'or')
            plot(data{iS}.spikes{i}.cyclePeakLocs,data{iS}.spikes{i}.cyclePeak,'og')
            plot((data{iS}.dataRange{i}==data{iS}.eventTPs(i))*5000)
            xticks(linspace(0,length(data{iS}.time{1}),5))
            xticklabels(linspace(data{iS}.time{i}(1),data{iS}.time{i}(end),5))

            % Plot histrogram of peaks
            % Plot true peaks
            subplot(2,2,3)
            hist(data{iS}.spikes{iI}.numTruePeaks)

            % Plot cycle peaks
            subplot(2,2,4)
            hist(data{iS}.spikes{iI}.numCyclePeaks)
        end
    end

end



% % Find the cutoff between white and gray, look for differences of >400
% % plot(data.spikes{1}.peaks)
% for j=1:length(data.spikes)
%     for i=2:length(data.spikes{j}.peaks)
%         data.spikes{j}.diffArray(i) = abs(data.spikes{j}.peaks(i)-data.spikes{j}.peaks(i-1));
%     end
% end
% % plot(data.spikes.diffArray)
% 
% for i=1:length(data.spikes)
%     % Get rid of peaks that are part of a larger peak
%     % Find the four max peaks, corr w/ the on/offset
%     spikeDiffMaxHolder = findpeaks(data.spikes{i}.diffArray,'MinPeakDistance',20);
%     spikeDiffMaxHolder = maxk(spikeDiffMaxHolder,4);
% 
%     data.spikeDiffMaxIdxHolder(i,:) = find(ismember(data.spikes{i}.diffArray,spikeDiffMaxHolder));
% 
%     % Average the values within the ranges of the max peak diffs
%     data.aveWhitePeak(i) = nanmean([data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,1):data.spikeDiffMaxIdxHolder(i,2)) ...
%         data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,3):data.spikeDiffMaxIdxHolder(i,4))]);
%     data.aveGrayPeak(i) = nanmean([data.spikes{i}.peaks(1:data.spikeDiffMaxIdxHolder(i,1)-1) ...
%         data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,2)+1:data.spikeDiffMaxIdxHolder(i,3)-1) ...
%         data.spikes{i}.peaks(data.spikeDiffMaxIdxHolder(i,4)+1:length(data.spikes{i}.peaks))]);
% 
%     % Take the differencebetween the average gray and average white
%     data.grayWhitePeakDiff(i) = (data.aveWhitePeak(i) + data.aveGrayPeak(i))/2;
% 
% end
% 
% 
% % Find the time difference between the event and the stim onset
% for i=1:length(data.events)
% 
%     % The time points at which the event occured are in data.eventTPs
% 
%     % Find the time point where the first peak occurs.
%     % Find the amps of each peak
%     data.spikes{i}.whitePeaks = data.spikes{i}.peaks((data.spikes{i}.peaks>=data.grayWhitePeakDiff(i)));
%     data.spikes{i}.grayPeaks = data.spikes{i}.peaks(data.spikes{i}.peaks<data.grayWhitePeakDiff(i));
% 
%     % Find the locs of each peak
%     data.spikes{i}.whiteLocs = data.spikes{i}.locs((data.spikes{i}.peaks>=data.grayWhitePeakDiff(i)));
%     data.spikes{i}.grayLocs = data.spikes{i}.locs(data.spikes{i}.peaks<data.grayWhitePeakDiff(i));
% 
%     % If there are less tha 10 peaks for either gray or white, or the diff 
%     % between gray/white ave peak is a small num (or neg), it is an
%     % invalid trial. (Most likely something weird happened during data
%     % collection). So don't calculate for that event.
%     if (length(data.spikes{i}.whitePeaks) < 10 || length(data.spikes{i}.grayPeaks) < 10) ||...
%             data.grayWhitePeakDiff(i) < 10000
%         data.spikes{i}.stimOnset = NaN;
%         data.eventOffset(i) = NaN;
%         % Find the mask onset for ill cont data
%         if whichDataset == 1
%             data.maskOffset(i) = NaN;
%         end
%     else
%         % Find the first white peak
%         data.spikes{i}.stimOnset = data.time{i}(data.spikes{i}.whiteLocs(1));
% 
%         % Find the mask onset for ill cont data
%         if whichDataset == 1
%             % Find the firs white peak of the mask onset
%             % Look for the loc of the long break between end of stim onset and start
%             % of mask onset.
%             for j=2:length( data.spikes{i}.whiteLocs)
%                 holder(j) = data.spikes{i}.whiteLocs(j)-data.spikes{i}.whiteLocs(j-1);
%                 if holder(j)>20
%                    data.spikes{i}.maskOnsetLoc = data.spikes{i}.whiteLocs(j); 
%                    data.spikes{i}.maskOnsetPeak = data.spikes{i}.whitePeaks(j);
%                 end
%             end
%             clear holder
% 
% 
%             data.spikes{i}.maskOnset = data.time{i}(data.spikes{i}.maskOnsetLoc);
%         end
% 
%         if data.spikes{i}.stimOnset < 0
%             data.spikes{i}.stimOnset = NaN;
%             data.eventOffset(i) = NaN;
%             % Find the mask onset for ill cont data
%             if whichDataset == 1
%                 data.spikes{i}.maskOnset = NaN;
%             end
%         else
%             % Take the difference between event and stim onsets
%             %         data.eventOffset(peakCounter) = data.spikes{i}.stimOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
%             data.eventOffset(i) = data.spikes{i}.stimOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
%             % Find the mask onset for ill cont data
%             if whichDataset == 1
%                 data.maskOffset(i) = data.spikes{i}.maskOnset - data.time{i}(data.dataRange{i}==data.eventTPs(i));
%             end
%         end
%     end
% end
% 
% % Grab the 'weird' trials (if any) from photodiode problems
% data.weirdTrials = find(isnan(data.eventOffset)==1);
% 
% for i=data.weirdTrials
%     figure()
%     plot(data.trial{i}(265,:))
%     hold on
%     plot(data.spikes{i}.locs,data.spikes{i}.peaks,'or')
%     plot((data.dataRange{i}==data.eventTPs(i))*5000)
%     xticks(linspace(0,length(data.time{1}),5))
%     xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
% end
% 
% % Plot the peaks
% % if plotData == 1
% %             for i=1:length(data.events)
% %         for i=find(data.events~=9)   % JUST USE FOR NOW B/C EVENT 9 PHOTOTDIODE WAS OFFSET OF THE WHITE STIM
% for i=randperm(length(data.events),10)
%     figure()
%     plot(data.trial{i}(265,:))
%     hold on
%     plot(data.spikes{i}.grayLocs,data.spikes{i}.grayPeaks,'or')
%     plot(data.spikes{i}.whiteLocs,data.spikes{i}.whitePeaks,'ob')
%     plot(data.spikes{i}.whiteLocs(1),data.spikes{i}.whitePeaks(1),'og')
%     plot(data.spikes{i}.maskOnsetLoc,data.spikes{i}.maskOnsetPeak,'oy')
%     plot((data.dataRange{i}==data.eventTPs(i))*5000)
%     xticks(linspace(0,length(data.time{1}),5))
%     xticklabels(linspace(data.time{i}(1),data.time{i}(end),5))
% end
% % end
% 
% % Take the average offset
% data.eventOffsetAve = nanmean(data.eventOffset);
% data.eventOffsetSTE = ste(data.eventOffset);
% data.eventOffsetSTD = nanstd(data.eventOffset);
% 
% % Take the average offset as a function of event type
% data.uniqueEvents = unique(data.events);
% for i=1:length(data.uniqueEvents)
% 
%     data.uniqueEventOffsetAve(i) = nanmean(data.eventOffset(data.events==data.uniqueEvents(i)));
%     data.uniqueEventOffsetSTE(i) = ste(data.eventOffset(data.events==data.uniqueEvents(i)));
%     data.uniqueEventOffsetSTD(i) = nanstd(data.eventOffset(data.events==data.uniqueEvents(i)));
% 
% end
% 
% % Look at average mask onset
% if whichDataset==1
%     data.maskOffsetAve = nanmean(data.maskOffset);
%     data.maskOffsetSTE = ste(data.maskOffset);
%     data.maskOffsetSTD = nanstd(data.maskOffset);
% 
%     for i=1:length(data.uniqueEvents)
%         data.uniqueMaskOffsetAve(i) = nanmean(data.maskOffset(data.events==data.uniqueEvents(i)));
%         data.uniqueMaskOffsetSTE(i) = ste(data.maskOffset(data.events==data.uniqueEvents(i)));
%         data.uniqueMaskOffsetSTD(i) = nanstd(data.maskOffset(data.events==data.uniqueEvents(i)));
%     end
% end
% 
% % Plot the offsets
% if plotAveData == 1
%     figure()
%     bar(data.uniqueEventOffsetAve)
%     hold on
%     bar(length(data.uniqueEventOffsetAve)+1,data.eventOffsetAve)
%     errorbar(data.uniqueEventOffsetAve,data.uniqueEventOffsetSTD,'.k')
%     errorbar(length(data.uniqueEventOffsetAve)+1,data.eventOffsetAve,data.eventOffsetSTD,'.k')
%     xticks(1:length(data.uniqueEvents)+1)
%     eventLabels = [data.eventLabels' 'Average'];
% %     eventLabels = [num2cell(data.uniqueEvents) 'Average'];
%     nEventsTotal = 0;
%     for j=1:length(eventLabels)
%         if j<length(eventLabels)
%             nEvents = sum(~isnan(data.eventOffset(data.events==data.uniqueEvents(j))));
%             nEventsTotal = nEvents+nEventsTotal;
%             eventLabels{j} = sprintf('%s%s%d',eventLabels{j},', n=',nEvents);
%         end
%     end
%     eventLabels{length(eventLabels)} = sprintf('%s%s%d',eventLabels{length(eventLabels)},', n=',nEventsTotal);
%     ylim([-.01 .1])
%     xticklabels(eventLabels)
%     xtickangle(315)
%     xlabel('Event Code')
%     ylabel('Event Offset (s)')
%     title('Stim Offset By Event Code')
% end
% 
% % Plot the mask offset if ill cont
% if whichDataset==1
%     figure()
%     bar(data.uniqueMaskOffsetAve)
%     hold on
%     bar(length(data.uniqueMaskOffsetAve)+1,data.maskOffsetAve)
%     errorbar(data.uniqueMaskOffsetAve,data.uniqueMaskOffsetSTD,'.k')
%     errorbar(length(data.uniqueMaskOffsetAve)+1,data.maskOffsetAve,data.maskOffsetSTD,'.k')
%     xticks(1:length(data.uniqueEvents)+1)
%     eventLabels = [data.eventLabels' 'Average'];
% %     eventLabels = [num2cell(data.uniqueEvents) 'Average'];
%     nEventsTotal = 0;
%     for j=1:length(eventLabels)
%         if j<length(eventLabels)
%             nEvents = sum(~isnan(data.maskOffset(data.events==data.uniqueEvents(j))));
%             nEventsTotal = nEvents+nEventsTotal;
%             eventLabels{j} = sprintf('%s%s%d',eventLabels{j},', n=',nEvents);
%         end
%     end
%     eventLabels{length(eventLabels)} = sprintf('%s%s%d',eventLabels{length(eventLabels)},', n=',nEventsTotal);
%     ylim([-.01 .75])
%     xticklabels(eventLabels)
%     xtickangle(315)
%     xlabel('Event Code')
%     ylabel('Mask Offset (s)')
%     title('Mask Offset By Event Code')
% end




