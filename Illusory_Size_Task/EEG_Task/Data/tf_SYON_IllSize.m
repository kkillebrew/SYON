% ERP code for use on pipeline preprocessed data. Run from scripts folder.
% 20191010
% subjID is either a string or cell array w/ a list of participants.

function [dataFIC, cfg, options] = tf_SYON_IllSize(options)

%% Initialize

addpath(genpath('/labs/srslab/data_main/SYON_testing/Functions/'));
ftPath = dir('/labs/srslab/data_main/SYON.git/fieldtrip-*');
addpath(sprintf('%s%s%s','/labs/srslab/data_main/SYON.git/',ftPath.name,'/'));
ft_defaults();

% Check for subjId list
if ~isfield(options,'subjID')
    options.subjID = {'Kyle_Test7'};
    % options.subjID = {'Kyle_Test7','Collin_Test2','MT_Pilot','Sam_Pilot'};   % Reversal subjects (long time bins)
    % options.subjID = {'Sam_Pilot'};   % Reversal subjects (long time bins)
end
options.nSubjIDArray = length(options.subjID);

% Display figures
options.displaySubjFigures = 1;
options.displayAveFigures = 1;

% Total time in ms
options.timeDuration = 3000;   %  Using a slightly smaller num so we get 7.2 Hz
options.timeIdx = ceil((options.timeDuration*256)/1000);

% Number of baseline TPs
options.baselineDuration = 1500;
options.baselineIdx = ceil((options.baselineDuration*256)/1000);

% Number of stim TPs
options.stimDuration = 1500;
options.stimIdx = ceil((options.stimDuration*256)/1000);

% Sample rate
options.samplingRate = 256 / 1000;

%% Start analysis
for n=1:options.nSubjIDArray
    
    % Clear previous participants data
    clear data ecnt_af
    options.nTimePoints = [];
    options.eventList = [];
    options.firstLastTimePoint = [];
    
    %% Load in data from pipeline output
    options.subjID = options.subjID{n};
    cd(sprintf('%s%s','../data.mat/0.1Hz_Highpass/',options.subjID))
    load(sprintf('%s%s',options.subjID,'_IllSize_ecnt_af.mat'))
    cd(sprintf('%s','../../../scripts/'))
    
    % Number of trials
    options.nTrials = size(ecnt_af.ntbins,1);
    
    % Number of time points per trial
    options.nTimePoints = size(ecnt_af.data,2)/options.nTrials;
    
    % Find the unique data.event values
    % Exclude trials with 0 contrast targ and task trials
    options.eventList = unique(ecnt_af.event);
    options.eventList(options.eventList == -1 | options.eventList == 15 | options.eventList == 16 | options.eventList == 17 |...
        options.eventList == 131 | options.eventList == 132 | options.eventList == 133 | options.eventList == 134 |...
        options.eventList == 141 | options.eventList == 142 | options.eventList == 143 | options.eventList == 144) = [];
    
    % First/last timepoint of each trial (corresponding to the data.event list)
%     options.firstLastTimePoint = 1:options.nTimePoints:size(ecnt_af.data,2);
    
    %% Preprocessing
    % Segment into trial types
    for i=1:length(options.eventList)   % Trial types
        data.event{i} = find(ecnt_af.event==options.eventList(i));
        for j=1:size(ecnt_af.data,1)   % Elec
            for k=1:length(data.event{i})
                data.dataStim{i}(k,j,:) = ecnt_af.data(j,data.event{i}(k):data.event{i}(k)+options.stimIdx-1);
                data.dataBase{i}(k,j,:) = ecnt_af.data(j,data.event{i}(k)-(options.baselineIdx-1):data.event{i}(k));
            end
        end
    end
    
%     % Average and subtract out the baseline ()
%     for i=1:length(data.dataStim)
%         % Average the baseline for this trial
%         aveBaselineHolder = nanmean(data.dataBase{i},3);
%         
%         for j=1:size(aveBaselineHolder,2)
%             for k=1:size(aveBaselineHolder,1)
%                 % Substract out the average baseline
%                 data.dataStimBLC{i}(k,j,:) = data.dataStim{i}(k,j,:) - aveBaselineHolder(k,j);
%                 data.dataBaseBLC{i}(k,j,:) = data.dataBase{i}(k,j,:) - aveBaselineHolder(k,j);
%             end
%         end
%     end
    
    % Combine the baseline and stim 
    for i=1:length(data.dataStim)
        for j=1:size(data.dataStim{i},1)
            for k=1:size(data.dataStim{i},2)
                data.dataCombined{i}{j}(k,:) = [squeeze(data.dataBase{i}(j,k,:))',...
                    squeeze(data.dataStim{i}(j,k,:))'];
            end
            data.dataCombinedTime{i}{j}(:) =...
                linspace(-options.baselineDuration,options.stimDuration,size(data.dataCombined{i}{j},2))/1000;
        end
    end
    
    
    %% Reformat and do TFA
    for i=1:length(data.dataCombined)
        % For creating new FT structs w/out loading/preprocessing:
        % https://www.fieldtriptoolbox.org/faq/how_can_i_import_my_own_dataformat/
        % Format the data structure
        for m=1:length(ecnt_af.elecnames(1:128,:))
            dataFIC{n,i}.label{m} = ecnt_af.elecnames(m,:);   % Cell array containing strings, nchan x 1
        end
        dataFIC{n,i}.fsample = ecnt_af.samplerate;   % Sampling frequency in Hz
        dataFIC{n,i}.trial = data.dataCombined{i};   % Cell array w/ data matric for each trial (1 x ntrials) containing nchan x nsamples
        dataFIC{n,i}.time = data.dataCombinedTime{i};   % Cell array w/ time axxis for each trial (1 x ntrial)
        %     dataFIC.trialinfo
        %     dataFIC.sampleinfo
        dataFIC{n,i} = ft_datatype_raw(dataFIC{n,i});
        
        % Format the config structure
        % https://www.fieldtriptoolbox.org/tutorial/timefrequencyanalysis/
        cfg{n,i}.baseline = [-1.5 0];
        cfg{n,i}.baselinetype = 'absolute';
        cfg{n,i}.output = 'pow';
        cfg{n,i}.channel = dataFIC{n,i}.label;
        cfg{n,i}.method = 'mtmconvol';
        cfg{n,i}.taper = 'hanning';
        cfg{n,i}.foi = 2:2:128;   % analysis 2 to 100 Hz in steps of 2 Hz
        cfg{n,i}.t_ftimwin = ones(length(cfg{n,i}.foi),1)*0.5;   % length of time window = 0.5 sec
        cfg{n,i}.toi = -1.5:0.05:1.5;  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
        cfg{n,i}.pad = 'nextpow2';
        dataFIC{n,i}.freq = ft_freqanalysis(cfg{n,i}, dataFIC{n,i});
        
        % Remove the nans that are in the last/first 5 rows for some
        % reason...
%         dataFIC{n,i}.freq.powspctrm(:,:,1:5) = [];
%         dataFIC{n,i}.freq.powspctrm(:,:,end-4:end) = [];
        
    end
    
    % Average together data for different ball locations (compare hallway vs no hallway)
        options.figIdx(1,:) = [1 2 5 6];   % Index locations of the different ball locations
        options.figIdx(2,:) = [3 4 7 8];
        for i = 1:size(options.figIdx,2)
            holder1(i,:,:,:) = dataFIC{n,options.figIdx(1,i)}.freq.powspctrm;
            holder2(i,:,:,:) = dataFIC{n,options.figIdx(2,i)}.freq.powspctrm;
        end
        dataFICAve{n}.avePow_hall{1} = squeeze(nanmean(holder1,1));
        dataFICAve{n}.avePow_hall{2} = squeeze(nanmean(holder2,1));

    %% Save subjects data
    
    %% Plot individual subject data
    options.figLabels{1} = {'hallNoChangeUR'
        'hallNoChangeUL'
        'noHallNoChangeUR'
        'noHallNoChangeUL'
        'hallNoChangeLL'
        'hallNoChangeLR'
        'noHallNoChangeLL'
        'noHallNoChangeLR'};
    
    options.figLabels{2} = {'HallwayPresent','HallwayAbsent'};
    
    % Occ electrode list
    options.elecOz = 23;
    options.elecList = [14 15 16 22 23 24 27 28 29];
    options.elecListLeft = [9 10 11 16 15 14 22 23 24];
    options.elecListRight = [29 28 27 38 39 40 22 23 24];
    options.elecListOcc = unique([options.elecList options.elecListLeft options.elecListRight]);
    
    % Plot occipital electrode averages for each condition
    figure()
    suptitle(sprintf('%s\n\n','TFA For All Ball Locations, Hallway Present and Absent'));
    for i=1:size(dataFIC,2)   % Condition
        subplot(2,4,i)
        dataHolder = flip(squeeze(nanmean(dataFIC{n,i}.freq.powspctrm(options.elecOz,:,:),1)));
        imagesc(dataHolder);
        set(gca,'ylim',[length(dataFIC{n,i}.freq.freq)/2 length(dataFIC{n,i}.freq.freq)],...
            'ytick',length(dataFIC{n,i}.freq.freq)/2:4:length(dataFIC{n,i}.freq.freq),...
            'yticklabels',flip(dataFIC{n,i}.freq.freq(1:4:length(dataFIC{n,i}.freq.freq)/2+1)),...
            'xlim',[1 length(dataFIC{n,i}.freq.time)],...
            'xtick',1:10:length(dataFIC{n,i}.freq.time),...
            'xticklabels',round(dataFIC{n,i}.freq.time(1:10:end),2),...
            'YScale','log');
        title(options.figLabels{1}{i});
        colorbar;
        clear dataHolder
    end
    
    % Plot averages for hallway vs no hallway
    figure()
    suptitle(sprintf('%s\n\n','TFA For Hallway Present vs. Absent'));
    for i=1:size(dataFICAve{n}.avePow_hall,2)   % Condition
        subplot(1,2,i)
        dataHolder = flip(squeeze(nanmean(dataFICAve{n}.avePow_hall{i}(options.elecOz,:,:,:),1)));
        imagesc(dataHolder);
        set(gca,'ylim',[length(dataFIC{n,i}.freq.freq)/2 length(dataFIC{n,i}.freq.freq)],...
            'ytick',length(dataFIC{n,i}.freq.freq)/2:4:length(dataFIC{n,i}.freq.freq),...
            'yticklabels',flip(dataFIC{n,i}.freq.freq(1:4:length(dataFIC{n,i}.freq.freq)/2+1)),...
            'xlim',[1 length(dataFIC{n,i}.freq.time)],...
            'xtick',1:10:length(dataFIC{n,i}.freq.time),...
            'xticklabels',round(dataFIC{n,i}.freq.time(1:10:end),2),...
            'YScale','log');
        title(options.figLabels{2}{i});
        colorbar;
        clear dataHolder
    end
    
    % Plot figures for all electrodes for each condition
    cfg = [];
    cfg.baseline     = [-1.5 0];
    cfg.baselinetype = 'absolute';
    cfg{n,i}.layout = 'biosemi128.lay';
    cfg{n,i}.showlabels   = 'yes';
    figure()
    ft_multiplotTFR(cfg{n,i},dataFIC{n,i}.freq)
    set(gca,'ZScale','log');
    
end
end





