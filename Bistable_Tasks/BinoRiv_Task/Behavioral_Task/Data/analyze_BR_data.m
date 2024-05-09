function dataAve = analyze_BR_data(options)
% usage: dataAve = analyze_BR_data(options)
%
% KWK - 20230206

%%
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'top_dir')
%     options.top_dir = '/labs/srslab/data_main/SYON.git/Bistable_Tasks/BinoRiv_Task/Behavioral_Task/Data/';
    options.top_dir = 'E:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';
%     options.top_dir = 'C:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';
end
% if ~isfield(options,'dateCutoff')
%     options.dateCutoff = 0;   % Only take participants after a given date
%     options.dateCutoffVal = 20210815;   % Don't take ppt after this date
%     options.dateCutoffValConverted = datenum(num2str(options.dateCutoffVal),'yyyymmdd');
% end
if ~isfield(options,'excludeRedcap')
    options.excludeRedcap = 1; % exclude subjects based on control task performance, 0 = no, 1 = yes
%     addpath(genpath('/home/shaw-raid1/matlab_tools/COP_analysis.git')) % Add path for redcap excludion function (in COP_analysis.git)
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 1; % 1 = on, 0 = off
end
if ~isfield(options,'displaySubjFigs')
    options.displaySubjFigs = 0;
end
if ~isfield(options,'subj_group_def')
    options.subj_group_def = 2;
end
if ~isfield(options,'normalize')
    options.normalize = 1;   % Normalize the data being analyzed (1=log; 0=non normalized)
end
if ~isfield(options,'normalize_plot')
    options.normalize_plot = 0;   % Normalize the data being plotted (1=log; 0=non normalized)
end
if ~isfield(options,'showStatsFig')
    options.showStatsFig = 'off';   % Plot stats figs
end
if ~isfield(options,'plot_stats')
    options.plot_stats = 1;   % Plot stats on figures
end
if ~isfield(options,'includeMixed')
    options.includeMixed = 0;   % Include mixed percepts (1) or not (0)
end
if ~isfield(options,'includeRelatives')
    options.includeRelatives = 0;   % Include relatives (1) or not (0)
end

% If we're not looking at all 3 groups, set includeRelatives to 1
if options.subj_group_def ~= 1
    options.includeRelatives = 1;
end

% addpath(genpath('/labs/srslab/data_main/SYON.git/Functions/'))
% options.curDur = '/labs/srslab/data_main/SYON.git/Bistable_Tasks/BinoRiv_Task/Behavioral_Task/Data/';

addpath(genpath('E:\GitRepos\SYON.git\Functions'))
options.curDur = 'E:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';

% addpath(genpath('C:\GitRepos\SYON.git\Functions'))
% options.curDur = 'C:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';

%% pull in data
dataAve.A.dataFileList = dir(fullfile(options.top_dir,'S*BinoRiv*.mat'));
dataAve.B.dataFileList = dir(fullfile(options.top_dir,'S*BinoRiv*.mat'));

% Ensure all the files are actually data files and not tests/pilots
holderName = {dataAve.A.dataFileList.name};
holderName = cellfun(@(x) x(1:8), holderName, 'UniformOutput', false);
holderNum = cellfun(@(x) x(2:8), holderName, 'UniformOutput', false);
% Returns a number for each subject that indexes where in the string
% (holderName{iI}) the patter shown in the second input begins. It checks
% each input in holderName for the patter (letter digit digit ...). Any
% value w/ a '0' or empty in the output means that file is not correct and
% should be tossed.
holderTaskData = regexp(holderName, '\w\d\d\d\d\d\d\d','once');
holderTaskDataIdx = cellfun('isempty',holderTaskData);
dataAve.A.dataFileList(holderTaskDataIdx) = [];
dataAve.B.dataFileList(holderTaskDataIdx) = [];
dataAve.A.subjID = holderName(~holderTaskDataIdx);
dataAve.B.subjID = holderName(~holderTaskDataIdx);
dataAve.A.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
dataAve.B.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
clear holderName holderTaskData holderTaskDataIdx

% If not including relatives
if options.includeRelatives == 0
    excludeListA = dataAve.A.subjNum>=2000000 & dataAve.A.subjNum<6000000;
    dataAve.A.dataFileList(excludeListA) = [];
    dataAve.A.subjID(excludeListA) = [];
    dataAve.A.subjNum(excludeListA) = [];

    excludeListB = dataAve.B.subjNum>=2000000 & dataAve.B.subjNum<6000000;
    dataAve.B.dataFileList(excludeListB) = [];
    dataAve.B.subjID(excludeListB) = [];
    dataAve.B.subjNum(excludeListB) = [];

    clear excludeListA excludeListB
end

% Grab datenums
taskNames = {'A','B'};
for iTask = 1:length(taskNames)
    for iSubj = 1:length(dataAve.(taskNames{iTask}).subjNum)
        tempOptions = load([dataAve.(taskNames{iTask}).dataFileList(iSubj).folder '/' dataAve.(taskNames{iTask}).dataFileList(iSubj).name],'options');

        dataAve.(taskNames{iTask}).dateNum(iSubj) = datenum(tempOptions.options.datecode,'mmddyy');
    
        clear tempOptions
    end
end

%% Calculate control data switch times
% Load in the control switch values and times
options.responseNumCutoff = 20;   % Response # cutoff (out of 31; 64% of trials)
options.responseTimeCutoff = 2.5;   % Reaction time cutoff (s)
% Switch times:
%     [0,2.95,8.2,12.25,15.6,19.55,21.7,26.95,30.5,34.25,36.8,40.65,44.1,...
%     48.05,53.5,57.15,59.2,64.35,66.5,71.85,76,78.15,83.2,85.75,90.8,...
%     94.35,98,102.15,105.7,109.55,111.8,115.45]
for iSubj = 1:numel(dataAve.A.subjNum)
    tempOptions = load([dataAve.A.dataFileList(iSubj).folder '/' dataAve.A.dataFileList(iSubj).name],'options');
    % Create time bins that we can use to search for correct responses
    % in within the given RT cutoff range.
    if isfield(tempOptions.options.control,'switchTimesArray')
        dataAve.A.controlSwitchTime{iSubj} = tempOptions.options.control.time.flipTimes(tempOptions.options.control.switchTimesArray(1:end-1)+1);
        dataAve.A.controlSwitchType{iSubj} = tempOptions.options.control.gratValue(tempOptions.options.control.switchTimesArray(1:end-1)+1);
        dataAve.A.controlSwitchTimeBins{iSubj} = [dataAve.A.controlSwitchTime{iSubj}(:) dataAve.A.controlSwitchTime{iSubj}(:)+options.responseTimeCutoff];
        holderCounter(iSubj) = 1;
        holderCounter2(iSubj) = size(tempOptions.options.control.switchTimesArray,2);
    elseif isfield(tempOptions.options.control,'switchTimeArray')
        dataAve.A.controlSwitchTime{iSubj} = tempOptions.options.control.time.flipTimes(tempOptions.options.control.switchTimeArray(1:end-1)+1);
        dataAve.A.controlSwitchType{iSubj} = tempOptions.options.control.gratValue(tempOptions.options.control.switchTimeArray(1:end-1)+1);
        dataAve.A.controlSwitchTimeBins{iSubj} = [dataAve.A.controlSwitchTime{iSubj}(:) dataAve.A.controlSwitchTime{iSubj}(:)+options.responseTimeCutoff];
        holderCounter(iSubj) = 0;
        holderCounter2(iSubj) = size(tempOptions.options.control.switchTimeArray,2);
    end
    clear tempOptions
end

% Some subjects did not have 33 switches, exclude these subjects
dataAve.A.dataFileList(holderCounter==0) = [];
dataAve.A.subjID(holderCounter==0) = [];
dataAve.A.subjNum(holderCounter==0) = [];
dataAve.A.dateNum(holderCounter==0) = [];
dataAve.A.controlSwitchTime(holderCounter==0) = []; 
dataAve.A.controlSwitchTimeBins(holderCounter==0) = [];
dataAve.A.controlSwitchType(holderCounter==0) = [];

dataAve.B.dataFileList(holderCounter==0) = [];
dataAve.B.subjID(holderCounter==0) = [];
dataAve.B.subjNum(holderCounter==0) = [];
dataAve.B.dateNum(holderCounter==0) = [];
clear holderCounter holderCounter2

taskNames = {'A', 'B'};
%% Define groups
for iT=1   % For real switch task
    %% Define groups
    % 1 = controls, relatives, probands; 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 4 = healthy (con+rel),
    % SZ+SCA, bipolar,
    group_def_opt = [];
    group_def_opt.subj_group_def = options.subj_group_def;
    group_def_opt.subj_number = dataAve.(taskNames{iT}).subjNum;

    group_def_out = run_subj_group_def_SYON( group_def_opt ); % mps 20220127 changing how we use subj group def

    % Set group colors/idxing from group_def_out to remain consistent w/ other
    % analysis code group defs.
    options.col_list{1} = group_def_out.use_colors_RGB{1};
    options.col_list{2} = group_def_out.use_colors_RGB{2};
    options.col_list{3} = group_def_out.use_colors_RGB{3};
    options.(taskNames{iT}).grpIdx{1} = group_def_out.g1_idx;
    options.(taskNames{iT}).grpIdx{2} = group_def_out.g2_idx;
    options.(taskNames{iT}).grpIdx{3} = group_def_out.g3_idx;
    options.(taskNames{iT}).grpLabel{1} = group_def_out.g1_label;
    options.(taskNames{iT}).grpLabelShort{1} = group_def_out.g1_short;
    options.(taskNames{iT}).grpLabel{2} = group_def_out.g2_label;
    options.(taskNames{iT}).grpLabelShort{2} = group_def_out.g2_short;
    options.(taskNames{iT}).grpLabel{3} = group_def_out.g3_label;
    options.(taskNames{iT}).grpLabelShort{3} = group_def_out.g3_short;

    dataAve.(taskNames{iT}).group_def = group_def_out;
    clear group_def_out

    dataAve.(taskNames{iT}).grouping = zeros([1 numel(dataAve.(taskNames{iT}).subjNum)]);
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{1}) = 1;
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{2}) = 2;
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{3}) = 3;

    options.(taskNames{iT}).x_labels = {[options.(taskNames{iT}).grpLabelShort{1} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{1}))],...
        [options.(taskNames{iT}).grpLabelShort{2} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{2}))],...
        [options.(taskNames{iT}).grpLabelShort{3} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{3}))]};
end

%% Calculate control data for further exclusions in bi-stable task analysis
[options,dataAve] = analyze_BR_control_data(options,dataAve);

% Create array to exclude poor performing subjects
dataAve.A.excludedPorPerfIdx = dataAve.A.numCorrectResp<options.responseNumCutoff;

% Exclude poor performers
dataAve.B.dataFileList(boolean(dataAve.A.excludedPorPerfIdx)) = [];
dataAve.B.subjID(boolean(dataAve.A.excludedPorPerfIdx)) = [];
dataAve.B.subjNum(boolean(dataAve.A.excludedPorPerfIdx)) = [];

% Now make grouping variable for bi-stable task
for iT=2   % For real switch task
    %% Define groups
    % 1 = controls, relatives, probands; 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 4 = healthy (con+rel),
    % SZ+SCA, bipolar,
    group_def_opt = [];
    group_def_opt.subj_group_def = options.subj_group_def;
    group_def_opt.subj_number = dataAve.(taskNames{iT}).subjNum;

    group_def_out = run_subj_group_def_SYON( group_def_opt ); % mps 20220127 changing how we use subj group def

    % Set group colors/idxing from group_def_out to remain consistent w/ other
    % analysis code group defs.
    options.col_list{1} = group_def_out.use_colors_RGB{1};
    options.col_list{2} = group_def_out.use_colors_RGB{2};
    options.col_list{3} = group_def_out.use_colors_RGB{3};
    options.(taskNames{iT}).grpIdx{1} = group_def_out.g1_idx;
    options.(taskNames{iT}).grpIdx{2} = group_def_out.g2_idx;
    options.(taskNames{iT}).grpIdx{3} = group_def_out.g3_idx;
    options.(taskNames{iT}).grpLabel{1} = group_def_out.g1_label;
    options.(taskNames{iT}).grpLabelShort{1} = group_def_out.g1_short;
    options.(taskNames{iT}).grpLabel{2} = group_def_out.g2_label;
    options.(taskNames{iT}).grpLabelShort{2} = group_def_out.g2_short;
    options.(taskNames{iT}).grpLabel{3} = group_def_out.g3_label;
    options.(taskNames{iT}).grpLabelShort{3} = group_def_out.g3_short;

    dataAve.(taskNames{iT}).group_def = group_def_out;
    clear group_def_out

    dataAve.(taskNames{iT}).grouping = zeros([1 numel(dataAve.(taskNames{iT}).subjNum)]);
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{1}) = 1;
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{2}) = 2;
    dataAve.(taskNames{iT}).grouping(options.(taskNames{iT}).grpIdx{3}) = 3;

    options.(taskNames{iT}).x_labels = {[options.(taskNames{iT}).grpLabelShort{1} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{1}))],...
        [options.(taskNames{iT}).grpLabelShort{2} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{2}))],...
        [options.(taskNames{iT}).grpLabelShort{3} ', n=' num2str(sum(options.(taskNames{iT}).grpIdx{3}))]};
end

%% Load in subject data / calculate switch rate
for iSubj = 1:numel(dataAve.B.subjNum)

    % Load in data files for each participant
    load([dataAve.B.dataFileList(iSubj).folder '/' dataAve.B.dataFileList(iSubj).name],'data');

    % Load in a couple fields from the options file
    tempOptions = load([dataAve.B.dataFileList(iSubj).folder '/' dataAve.B.dataFileList(iSubj).name],'options');
    options.runLength = tempOptions.options.runLength;
    options.hz = tempOptions.options.wInfoNew.hz; 
    clear tempOptions

    % Find the time for each change in percept for each block
    for iJ=1:size(data.rawdata,1)
        percHolder = 0;
        counter = 0;
        for iI=1:size(data.rawdata,2)

            % Look for a change in response
            if data.rawdata(iJ,iI,2) ~= 0 && data.rawdata(iJ,iI,2) ~= percHolder
                percHolder = data.rawdata(iJ,iI,2);

                % Record the time and type
                counter = counter+1;
                dataAve.B.percSwitch{iSubj}{iJ}(counter) = data.rawdata(iJ,iI,2);
                dataAve.B.percSwitchTime{iSubj}{iJ}(counter) = data.rawdata(iJ,iI,1);

            end
        end

        % If no switches create an empty array for this participant for
        % this block
        if counter == 0 || counter == 1
            dataAve.B.percSwitch{iSubj}{iJ} = [];
            dataAve.B.percSwitchTime{iSubj}{iJ} = [];
        end
        clear percHolder

        % Added in order to not include first percept. - KWK 20231109
        dataAve.B.percSwitch{iSubj}{iJ} = dataAve.B.percSwitch{iSubj}{iJ}(2:end);
        dataAve.B.percSwitchTime{iSubj}{iJ} = dataAve.B.percSwitchTime{iSubj}{iJ}(2:end);

        % If only looking at red / blue changes remove mixed
        if options.includeMixed == 1
            percSwitchHolder = dataAve.B.percSwitch{iSubj}{iJ};
            dataAve.B.percSwitch{iSubj}{iJ}(percSwitchHolder==3) = [];
            dataAve.B.percSwitchTime{iSubj}{iJ}(percSwitchHolder==3) = [];
            clear percSwitchHolder
        end
        
        % Number of flips total in this block
        dataAve.B.nFlips(iSubj,iJ) = numel(dataAve.B.percSwitch{iSubj}{iJ});

        % Duration of each dominant percept
        % This grabs the times or reported switches and subtracts each of
        % them from the prior switch time (first switch gets sub'd from 0)
        dataAve.B.perceptDur{iSubj}{iJ} = [dataAve.B.percSwitchTime{iSubj}{iJ}' - ...
            [0 ; dataAve.B.percSwitchTime{iSubj}{iJ}(1:end-1)']];

        % Swtich rate
        dataAve.B.switchRate(iSubj,iJ) = length(dataAve.B.percSwitch{iSubj}{iJ})/options.runLength;

        % Average perc dur
        dataAve.B.perDurAve(iSubj,iJ) = nanmean(dataAve.B.perceptDur{iSubj}{iJ});

        % CV
        dataAve.B.CV(iSubj,iJ) = ...
                std(dataAve.B.perceptDur{iSubj}{iJ}) / ...
                dataAve.B.perDurAve(iSubj,iJ); % mps 20200519 - kwk adapted for Br 20230206

    end

    if options.displaySubjFigs == 1
        figure()

        % Display time series (change in percept over time)
        subplot(3,4,1:3)
        plot(data.rawdata(1,:,2));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Blue, 2=Red, 3=Mix)');
        set(gca,'XTick',[0:20*options.hz:options.hz*options.runLength],...
            'XTickLabels',[0:20*options.hz:options.hz*options.runLength]./options.hz);
        subplot(3,4,5:7)
        plot(data.rawdata(2,:,2));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Blue, 2=Red, 3=Mix)');
        set(gca,'XTick',[0:20*options.hz:options.hz*options.runLength],...
            'XTickLabels',[0:20*options.hz:options.hz*options.runLength]./options.hz);
        subplot(3,4,9:11)
        plot(data.rawdata(3,:,2));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Blue, 2=Red, 3=Mix)');
        set(gca,'XTick',[0:20*options.hz:options.hz*options.runLength],...
            'XTickLabels',[0:20*options.hz:options.hz*options.runLength]./options.hz);

        % Display switch rate (Hz)
        subplot(3,4,[4 8 12]);
        bar([dataAve.B.switchRate(iSubj,:) nanmean(dataAve.B.switchRate(iSubj,:))]);
        hold on
        errorbar(length([dataAve.B.switchRate(iSubj,:) nanmean(dataAve.B.switchRate(iSubj,:))]),...
            nanmean(dataAve.B.switchRate(iSubj,:)),nanstd(dataAve.B.switchRate(iSubj,:)),'.k')
        title('Switche Rate');
        ylabel('Switch Rate (Hz)');
        % Make xtick labels
        for iI=1:size(dataAve.B.switchRate,2)
            xLab{iI} = num2str(iI);
        end
        set(gca,'XTickLabels',{xLab{:},'Average'});
        set(gca,'YLim',[0 1.5],'YTick',[0:.2:1.5])
    end

    clear data

end

%% Group analysis 
% Average switch rate
dataAve.B.switchRateGrpAve(1) = mean(mean(dataAve.B.switchRate(dataAve.B.grouping==1),2));
dataAve.B.switchRateGrpAve(2) = mean(mean(dataAve.B.switchRate(dataAve.B.grouping==2),2));
dataAve.B.switchRateGrpAve(3) = mean(mean(dataAve.B.switchRate(dataAve.B.grouping==3),2));

%% Do stats for Hz
% Normalize data for analysis needed 
if options.normalize == 0
    allData = dataAve.B.switchRate;
elseif options.normalize == 1
    allData = log10(dataAve.B.switchRate);
    allData(allData == Inf | allData == -Inf) = NaN;
end

% Normalize data for plotting needed 
if options.normalize_plot == 0
    allDataPlot = dataAve.B.switchRate;
elseif options.normalize_plot == 1
    allDataPlot = log10(dataAve.B.switchRate);
    allDataPlot(allDataPlot == Inf | allDataPlot == -Inf) = NaN;
end

% Average allData
hzData = nanmean(allData,2);

% Create grouping variables for stats
allBlock = [ones([size(allData,1) 1]) ones([size(allData,1) 1])+1 ones([size(allData,1) 1])+2];
allGroup = [dataAve.B.grouping' dataAve.B.grouping' dataAve.B.grouping'];
allSubj = repmat([1:size(allData,1)]',[1 size(allData,2)]);

% Do ANOVA
nest = zeros(3,3);
nest(1,2) = 1;

% [dataAve.B.stats.Hz.ANOVA.p, dataAve.B.stats.Hz.ANOVA.anovaTable] = ...
%     anovan(allData(:), {allSubj(:), allGroup(:), allBlock(:)}, 'random', 1, 'continuous', [3],...
%     'nested', nest, 'model', 'full', 'varnames', {'subj', 'group', 'block'}, 'display', options.showStatsFig);

% Run 2KW between 3 groups
statsRunIdx = [1 2; 1 3; 2 3];
for iI=1:3
    % Run 2KW between the three groups
    [dataAve.B.stats.Hz.KW2{iI}.p, dataAve.B.stats.Hz.KW2{iI}.table, dataAve.B.stats.Hz.KW2{iI}.stats] = ...
        kruskalwallis([hzData(dataAve.B.grouping == statsRunIdx(iI,1),:)', hzData(dataAve.B.grouping == statsRunIdx(iI,2),:)'],...
        [dataAve.B.grouping(dataAve.B.grouping == statsRunIdx(iI,1)) dataAve.B.grouping(dataAve.B.grouping == statsRunIdx(iI,2))], options.showStatsFig);
end


%% Plot
if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRate.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRate.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRate.figSize = [0 0 ...
        figSize.switchRate.aspectRatio];   % Size/postion of fig
%     addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread')) alredy in SYON.git functions
     
    hold on

    if options.includeRelatives == 1
        % Beeswarm
        x_val = [1 2 3];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        options.beePointSize = 16;
        beePlot = plotSpread({nanmean(allDataPlot(dataAve.B.grouping==1,:),2),...
            nanmean(allDataPlot(dataAve.B.grouping==2,:),2),nanmean(allDataPlot(dataAve.B.grouping==3,:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(nanmean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',options.B.x_labels,'fontsize',axisLabelFontSize)
        set(hb,'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        for iHB = 1:size(hb,2)
            set(hb2((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'Color',options.col_list{4-iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb,2)
            set(hbCurr((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hbCurr((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
        end
    elseif options.includeRelatives == 0
        % Beeswarm
        x_val = [1 2];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        options.beePointSize = 16;
        beePlot = plotSpread({nanmean(allDataPlot(dataAve.B.grouping==1,:),2),nanmean(allDataPlot(dataAve.B.grouping==3,:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(nanmean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',options.B.x_labels([1 3]),'fontsize',axisLabelFontSize)
        set(hb,'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        useColList = {options.col_list{3} options.col_list{1}};
        for iHB = 1:size(hb,2)
            set(hb2((iHB)+2:2:end),'color',options.col_list{4-iHB})
            set(hb2((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
            set(hb2((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
            set(hb3((iHB)+3:2:end),'MarkerEdgeColor',useColList{iHB})
            set(hb3((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
            set(hb3((iHB)+2:2:end),'Color',useColList{iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb,2)
            set(hbCurr((iHB)+2:2:end),'color',useColList{iHB})
            set(hbCurr((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
        end
    end

    % Plot significance
    %         max_Hz = max([Hz_data_plot(grouping==1); Hz_data_plot(grouping==2); Hz_data_plot(grouping==3)]);
    max_Hz = .55;
    if options.plot_stats == 1
        %             % Plot 3-K-W
        %             text(1,max_Hz*.75,...
        %                 ['X2(' sprintf('%d',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,3})  ') = ' ...
        %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,5}) ', p = ' ...
        %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,6})],...
        %                 'fontsize',statsFontSize);

        if options.includeRelatives == 1
            statsXVal = 2.25;
        elseif options.includeRelatives == 0
            statsXVal = 1.25;
        end

        % Plot post hoc 2-K-W for controls vs patients
        if options.subj_group_def == 2
            % Plot Cont vs Sz
            text(statsXVal,max_Hz,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{2},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{1}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{1}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{1}.table{2,6})],...
                'fontsize',statsFontSize);
            % Plot Cont vs Bp
            text(statsXVal,max_Hz-.05,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 1
            % Plot Cont vs PwPP
            text(statsXVal,max_Hz,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        end
    end

    title('Bi-stable Task (BR)','fontsize',titleFontSize)
    box off
    ylabel('Switch Rate (Hz)','fontsize',axisTitleFontSize)
%     set(gca,'ylim',[50 150])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRate.figSize,'color','w')
end

clear allBlock allGroup allSubj allData allDataPlot durData durData_partIdx

%% Do stats for duration
allData = dataAve.B.perDurAve;
allDataPlot = dataAve.B.perDurAve;

% Average allData
durData = nanmean(allData,2);

% Since there are some subjects w/ no switches for a particular direction,
% make index to exclude sucbjects and make final participant counts. 
durData_partIdx = ~isnan(durData);

% Create grouping variables for stats
allBlock = [ones([size(allData,1) 1]) ones([size(allData,1) 1])+1 ones([size(allData,1) 1])+2];
allGroup = [dataAve.B.grouping' dataAve.B.grouping' dataAve.B.grouping'];
allSubj = repmat([1:size(allData,1)]',[1 size(allData,2)]);

% Do ANOVA
nest = zeros(3,3);
nest(1,2) = 1;

% [dataAve.B.stats.purDur.ANOVA.p, dataAve.B.stats.purDur.ANOVA.anovaTable] = ...
%     anovan(allData(:), {allSubj(:), allGroup(:), allBlock(:)}, 'random', 1, 'continuous', [3],...
%     'nested', nest, 'model', 'full', 'varnames', {'subj', 'group', 'block'}, 'display', options.showStatsFig);

statsRunIdx = [1 2; 1 3; 2 3];
for iI=1:3
    % Run 2KW between the three groups
    [dataAve.B.stats.purDur.KW2{iI}.p, dataAve.B.stats.purDur.KW2{iI}.table, dataAve.B.stats.purDur.KW2{iI}.stats] = ...
        kruskalwallis([durData(dataAve.B.grouping == statsRunIdx(iI,1),:)', durData(dataAve.B.grouping == statsRunIdx(iI,2),:)'],...
        [dataAve.B.grouping(dataAve.B.grouping == statsRunIdx(iI,1)) dataAve.B.grouping(dataAve.B.grouping == statsRunIdx(iI,2))], options.showStatsFig);
end

%% Plot duration
if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRate.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRate.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRate.figSize = [0 0 ...
        figSize.switchRate.aspectRatio];   % Size/postion of fig
%     addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread')) alredy in SYON.git functions
     
    hold on

    if options.includeRelatives == 1
        % Beeswarm
        x_val = [1 2 3];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        options.beePointSize = 16;
        beePlot = plotSpread({nanmean(allDataPlot(dataAve.B.grouping==1,:),2),...
            nanmean(allDataPlot(dataAve.B.grouping==2,:),2),nanmean(allDataPlot(dataAve.B.grouping==3,:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(nanmean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',options.B.x_labels,'fontsize',axisLabelFontSize)
        set(hb,'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        for iHB = 1:size(hb,2)
            set(hb2((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'Color',options.col_list{4-iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb,2)
            set(hbCurr((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hbCurr((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
        end
    elseif options.includeRelatives == 0
        % Beeswarm
        x_val = [1 2];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        options.beePointSize = 16;
        beePlot = plotSpread({nanmean(allDataPlot(dataAve.B.grouping==1,:),2),nanmean(allDataPlot(dataAve.B.grouping==3,:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(nanmean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',options.B.x_labels([1 3]),'fontsize',axisLabelFontSize)
        set(hb,'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        useColList = {options.col_list{3} options.col_list{1}};
        for iHB = 1:size(hb,2)
            set(hb2((iHB)+2:2:end),'color',useColList{iHB})
            set(hb2((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
            set(hb2((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
            set(hb3((iHB)+3:2:end),'MarkerEdgeColor',useColList{iHB})
            set(hb3((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
            set(hb3((iHB)+2:2:end),'Color',useColList{iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb,2)
            set(hbCurr((iHB)+2:2:end),'color',useColList{iHB})
            set(hbCurr((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
        end
    end

    % Plot significance
    %         max_Hz = max([Hz_data_plot(grouping==1); Hz_data_plot(grouping==2); Hz_data_plot(grouping==3)]);
    max_Hz = 18;
    if options.plot_stats == 1
        %             % Plot 3-K-W
        %             text(1,max_Hz*.75,...
        %                 ['X2(' sprintf('%d',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,3})  ') = ' ...
        %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,5}) ', p = ' ...
        %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,6})],...
        %                 'fontsize',statsFontSize);

        if options.includeRelatives == 1
            statsXVal = 2.25;
        elseif options.includeRelatives == 0
            statsXVal = 1.25;
        end

        % Plot post hoc 2-K-W for controls vs patients
        if options.subj_group_def == 2
            % Plot Cont vs Sz
            text(statsXVal,max_Hz,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{2},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{1}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{1}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{1}.table{2,6})],...
                'fontsize',statsFontSize);
            % Plot Cont vs Bp
            text(statsXVal,max_Hz-.05,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 1
            % Plot Cont vs PwPP
            text(statsXVal,max_Hz,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        end
    end

    title('Bi-stable Task (BR)','fontsize',titleFontSize)
    box off
    ylabel('Percept Duration (sec)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[0 22])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRate.figSize,'color','w')
end

clear allBlock allGroup allSubj allData allDataPlot durData durData_partIdx


%% Split duration by the two reported directions
% Seperate out the percept durations based on percieved grating
for iSubj = 1:length(dataAve.B.subjNum)
    for iBlock = 1:length(dataAve.B.perceptDur{iSubj})
        % Grab the percept durations for red / blue / mixed
        dataAve.B.percSwitch_Dir{iSubj,iBlock,1}(:) = dataAve.B.perceptDur{iSubj}{iBlock}(dataAve.B.percSwitch{iSubj}{iBlock}'==1);
        dataAve.B.percSwitch_Dir{iSubj,iBlock,2}(:) = dataAve.B.perceptDur{iSubj}{iBlock}(dataAve.B.percSwitch{iSubj}{iBlock}'==2);
        dataAve.B.percSwitch_Dir{iSubj,iBlock,3}(:) = dataAve.B.perceptDur{iSubj}{iBlock}(dataAve.B.percSwitch{iSubj}{iBlock}'==3);
    
        % Now average percept durations for those directions across each
        % block for each subj
        dataAve.B.percSwitch_DirAve(iSubj,iBlock,1) = nanmean(dataAve.B.percSwitch_Dir{iSubj,iBlock,1});
        dataAve.B.percSwitch_DirAve(iSubj,iBlock,2) = nanmean(dataAve.B.percSwitch_Dir{iSubj,iBlock,2});
        dataAve.B.percSwitch_DirAve(iSubj,iBlock,3) = nanmean(dataAve.B.percSwitch_Dir{iSubj,iBlock,3});
    end
end

% Assign all data
clear allData allDataPlot
allData = dataAve.B.percSwitch_DirAve;
allDataPlot = dataAve.B.percSwitch_DirAve;

% Average across blocks for each grating
clear durData durData_partIdx
durData = squeeze(nanmean(allData,2));

% Since there are some subjects w/ no switches for a particular direction,
% make index to exclude sucbjects and make final participant counts. 
durData_partIdx = ~isnan(durData);

% Plot seperated duration for away / towards
if options.displayFigs
    if options.includeMixed == 1
        plotArray = [1:2];
        directionTitle = {'Red','Blue'};
    elseif options.includeMixed == 0
        plotArray = [1:3];
        directionTitle = {'Red','Blue','Mixed'};
    end
    for iDir = plotArray   % Plot for red / blue / mixed
        figure(); hold on
        % Set font sizes
        titleFontSize = 12;
        axisTitleFontSize = 12;
        axisLabelFontSize = 10;
        statsFontSize = 10;
        % Set figure size
        figSize.switchRate.baseSize = get(0,'Screensize');   % Base size in pixels
        figSize.switchRate.aspectRatio = [6.5 5];   % Aspect ratio
        figSize.switchRate.figSize = [0 0 ...
            figSize.switchRate.aspectRatio];   % Size/postion of fig
        %     addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread')) alredy in SYON.git functions

        hold on

        if options.includeRelatives == 1
            % Beeswarm
            x_val = [1 2 3];
            set(gca,'XColor','k','YColor','k')
            bee_bin_width = .1;
            bee_spread_width = .5;
            options.beePointSize = 16;
            beePlot = plotSpread({nanmean(allDataPlot((dataAve.B.grouping==1)'~=0 & durData_partIdx(:,iDir),:,iDir),2),...
                nanmean(allDataPlot((dataAve.B.grouping==2)'~=0 & durData_partIdx(:,iDir),:,iDir),2),...
                nanmean(allDataPlot((dataAve.B.grouping==3)'~=0 & durData_partIdx(:,iDir),:,iDir),2)},...
                'binWidth', bee_bin_width,...
                'distributionColors', {[.8 .8 .8]},...
                'xValues', x_val,...
                'spreadWidth', bee_spread_width);
            set(beePlot{1},'MarkerSize',options.beePointSize)
            hold on

            % Boxplots
            hb = boxplot(mean(allDataPlot(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir),:,iDir),2),...
                dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir)));
            pause(0.5)
            set(gca,'XTick',1:3,'XTickLabel',{sprintf('%s%d',options.B.x_labels{1}(1:find(options.B.x_labels{1}=='=')),...
                sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir))==1)),...
                sprintf('%s%d',options.B.x_labels{2}(1:find(options.B.x_labels{2}=='=')),...
                sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir))==2)),...
                sprintf('%s%d',options.B.x_labels{3}(1:find(options.B.x_labels{3}=='=')),...
                sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir))==3))},'fontsize',axisLabelFontSize)
            set(hb,'linewidth',2)
            hb2 = findobj(gca,'type','line');
            hb3 = findobj(gca,'type','Outliers');
            for iHB = 1:size(hb,2)
                set(hb2((iHB)+3:3:end),'color',options.col_list{4-iHB})
                set(hb2((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
                set(hb2((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
                set(hb3((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
                set(hb3((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
                set(hb3((iHB)+3:3:end),'Color',options.col_list{4-iHB})
            end
            hbCurr = findobj(gca,'type','line');
            for iHB = 1:size(hb,2)
                set(hbCurr((iHB)+3:3:end),'color',options.col_list{4-iHB})
                set(hbCurr((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            end
        elseif options.includeRelatives == 0
            % Beeswarm
            x_val = [1 2];
            set(gca,'XColor','k','YColor','k')
            bee_bin_width = .1;
            bee_spread_width = .5;
            options.beePointSize = 16;
            beePlot = plotSpread({nanmean(allDataPlot((dataAve.B.grouping==1)'~=0 & durData_partIdx(:,iDir),:,iDir),2),...
                nanmean(allDataPlot((dataAve.B.grouping==3)'~=0 & durData_partIdx(:,iDir),:,iDir),2)},...
                'binWidth', bee_bin_width,...
                'distributionColors', {[.8 .8 .8]},...
                'xValues', x_val,...
                'spreadWidth', bee_spread_width);
            set(beePlot{1},'MarkerSize',options.beePointSize)
            hold on

            % Boxplots
            hb = boxplot(mean(allDataPlot(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir),:,iDir),2),...
                dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir)));
            pause(0.5)
            set(gca,'XTick',1:2,'XTickLabel',{sprintf('%s%d',options.B.x_labels{1}(1:find(options.B.x_labels{1}=='=')),...
                sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir))==1)),...
                sprintf('%s%d',options.B.x_labels{3}(1:find(options.B.x_labels{3}=='=')),...
                sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:,iDir))==3))},'fontsize',axisLabelFontSize)
            set(hb,'linewidth',2)
            hb2 = findobj(gca,'type','line');
            hb3 = findobj(gca,'type','Outliers');
            useColList = {options.col_list{3} options.col_list{1}};
            for iHB = 1:size(hb,2)
                set(hb2((iHB)+2:2:end),'color',options.col_list{4-iHB})
                set(hb2((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
                set(hb2((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
                set(hb3((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
                set(hb3((iHB)+2:2:end),'MarkerFaceColor',useColList{iHB})
                set(hb3((iHB)+2:2:end),'Color',useColList{iHB})
            end
            hbCurr = findobj(gca,'type','line');
            for iHB = 1:size(hb,2)
                set(hbCurr((iHB)+2:2:end),'color',useColList{iHB})
                set(hbCurr((iHB)+2:2:end),'MarkerEdgeColor',useColList{iHB})
            end
        end

        %     % Plot significance
        %     %         max_Hz = max([Hz_data_plot(grouping==1); Hz_data_plot(grouping==2); Hz_data_plot(grouping==3)]);
        %     max_Hz = 45;
        %     if options.plot_stats == 1
        %         %             % Plot 3-K-W
        %         %             text(1,max_Hz*.75,...
        %         %                 ['X2(' sprintf('%d',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,3})  ') = ' ...
        %         %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,5}) ', p = ' ...
        %         %                 sprintf('%1.3f',output.(task_names{iTask}).Hz.kruskall_wallis_3_groups.table{2,6})],...
        %         %                 'fontsize',statsFontSize);
        %
        %         % Plot post hoc 2-K-W for controls vs patients
        %         if options.subj_group_def == 2
        %             whichGroupPlot = 1;   % Plot Cont vs Sz
        %         elseif options.subj_group_def == 1
        %             whichGroupPlot = 2;   % Plot Cont vs PwPP
        %         end
        %         text(2.5,max_Hz,...
        %             ['X2(' sprintf('%d',dataAve.B.stats.purDur.KW2{1}.table{2,3})  ') = ' ...
        %             sprintf('%1.3f',dataAve.B.stats.purDur.KW2{whichGroupPlot}.table{2,5}) ', p = ' ...
        %             sprintf('%1.3f',dataAve.B.stats.purDur.KW2{whichGroupPlot}.table{2,6})],...
        %             'fontsize',statsFontSize);
        %     end

        title(sprintf('%s%s%s','Bi-stable Task (BR - ',directionTitle{iDir},')'),'fontsize',titleFontSize)
        box off
        ylabel('Percept Duration (sec)','fontsize',axisTitleFontSize)
        set(gca,'ylim',[0 15])
        set(gca,'XColor','k','YColor','k')

        set(gcf,'Units','inches')
        set(gcf,'Position',figSize.switchRate.figSize,'color','w')
    end
end



end