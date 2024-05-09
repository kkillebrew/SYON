function dataAve = analyze_SFM_data(options)
% usage: dataAve = analyze_SFM_data(options)
%
% KWK - 20230206

%%
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'top_dir')
    %     options.top_dir = '/home/shaw-raid1/data/psychophysics/SYON.git/Bistable_Tasks/SFM_Task/subjectResponseFiles/';
        options.top_dir = 'E:\GitRepos\SYON.git\Bistable_Tasks\SFM_Task\subjectResponseFiles\';
%     options.top_dir = 'C:\GitRepos\SYON.git\Bistable_Tasks\SFM_Task\subjectResponseFiles\';
end
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
if ~isfield(options,'includeRelatives')
    options.includeRelatives = 0;   % Include relatives (1) or not (0)
end

% If we're not looking at all 3 groups, set includeRelatives to 1
if options.subj_group_def ~= 1
    options.includeRelatives = 1;
end

% 
% addpath(genpath('/labs/srslab/data_main/SYON.git/Functions/'))
% options.curDur = '/labs/srslab/data_main/SYON.git/Bistable_Tasks/SFM_Task/';
% 
% addpath(genpath('/home/shaw-raid1/data/psychophysics/SYON.git/Functions/'))
% options.curDur = '/home/shaw-raid1/data/psychophysics/SYON.git/Bistable_Tasks/SFM_Task/';

addpath(genpath('E:\GitRepos\SYON.git\Functions'))
options.curDur = 'E:\GitRepos\SYON.git\Bistable_Tasks\SFM_Task\';

% addpath(genpath('C:\GitRepos\SYON.git\Functions'))
% options.curDur = 'C:\GitRepos\SYON.git\Bistable_Tasks\SFM_Task\';

options.runLength = 120+1;   % One subj has resp at 120.037, so extend this out by a second
options.hz = 60;

%% pull in data
part_exclude_list = {'S1010098' 'S3501101'};   % No responses in this persons file for some reason. - KWK 20230207
all_pickles{1} = dir(fullfile(options.top_dir,'S*SFM*typeA*.pickle'));
all_txt{1} = dir(fullfile(options.top_dir,'S*SFM*typeA*.txt'));
all_pickles{2} = dir(fullfile(options.top_dir,'S*SFM*typeB*.pickle'));
all_txt{2} = dir(fullfile(options.top_dir,'S*SFM*typeB*.txt'));
missing_txt = [];

taskNames = {'A', 'B'};
for iT=1:2   % For real switch and bi-stable tasks
    if numel(all_pickles{iT}) ~= numel(all_txt{iT})
        for iP = 1:numel(all_pickles{iT})
            find_me = 0;
            for iM = 1:numel(all_txt{iT})
                if strcmp(all_pickles{iT}(iP).name(1:end-7),all_txt{iT}(iM).name(1:end-4)) || ...
                        sum(strcmp(all_pickles{iT}(iP).name(1:end-7),excluded_data))
                    find_me = 1;
                    break
                end
            end
            if ~find_me
                missing_txt = str2mat(missing_txt, all_pickles{iT}(iP).name(1:end-7));
            end
        end
    end
    dataAve.(taskNames{iT}).missing_txt = missing_txt;
    if ~isempty(missing_txt)
        warning('Quitting, because I found .pickle files that weren''t converted to .txt');
        return
    else dataAve.(taskNames{iT}) = rmfield(dataAve.(taskNames{iT}),'missing_txt');
    end
end

%% sort out subjects
for iT=1:2   % For real switch and bi-stable tasks
    for iSubj = 1:numel(all_txt{iT})
        dataAve.(taskNames{iT}).dataFileList{iSubj} = fullfile(options.top_dir,all_txt{iT}(iSubj).name);
        string_idx = regexp(dataAve.(taskNames{iT}).dataFileList{iSubj},'S\d\d\d\d\d\d\d');
        dataAve.(taskNames{iT}).subjID{iSubj} = dataAve.(taskNames{iT}).dataFileList{iSubj}(string_idx:string_idx+7);

        dataAve.(taskNames{iT}).subjNum(iSubj) = str2num(dataAve.(taskNames{iT}).dataFileList{iSubj}(string_idx+1:string_idx+7));

        datetime_idx = regexp(dataAve.(taskNames{iT}).dataFileList{iSubj},'\d\d\d\d\d\d\d\d');
        dataAve.(taskNames{iT}).dateNum(iSubj) = datenum(dataAve.(taskNames{iT}).dataFileList{iSubj}(datetime_idx:datetime_idx+7),'yyyymmdd');
    end

    % Exclude predefined subjects
    exclude_array = zeros([numel(dataAve.(taskNames{iT}).subjID) 1]);
    for iI = 1:numel(part_exclude_list)
        exclude_array(strcmp(part_exclude_list{iI},dataAve.(taskNames{iT}).subjID)) = 1;
    end
    dataAve.(taskNames{iT}).dataFileList(boolean(exclude_array)) = [];
    dataAve.(taskNames{iT}).subjID(boolean(exclude_array)) = [];
    dataAve.(taskNames{iT}).subjNum(boolean(exclude_array)) = [];
    dataAve.(taskNames{iT}).dateNum(boolean(exclude_array)) = [];
end

% If not including relatives
if options.includeRelatives == 0
    excludeListA = dataAve.A.subjNum>=2000000 & dataAve.A.subjNum<6000000;
    dataAve.A.dataFileList(excludeListA) = [];
    dataAve.A.subjID(excludeListA) = [];
    dataAve.A.subjNum(excludeListA) = [];
    dataAve.A.dateNum(excludeListA) = [];

    excludeListB = dataAve.B.subjNum>=2000000 & dataAve.B.subjNum<6000000;
    dataAve.B.dataFileList(excludeListB) = [];
    dataAve.B.subjID(excludeListB) = [];
    dataAve.B.subjNum(excludeListB) = [];
    dataAve.B.dateNum(excludeListB) = [];

    clear excludeListA excludeListB
end

%% Only include subjects that have both real and switch task data
% Find any subjects that don't have both
excludeIncompletSubjs = setdiff(dataAve.A.subjNum,dataAve.B.subjNum);
excludeA = zeros([size(dataAve.A.subjNum) 1]);
excludeB = zeros([size(dataAve.B.subjNum) 1]);
for iExclude = 1:length(excludeIncompletSubjs)
    excludeA(dataAve.A.subjNum == excludeIncompletSubjs(iExclude)) = 1;
    excludeB(dataAve.B.subjNum == excludeIncompletSubjs(iExclude)) = 1;
end

dataAve.A.dataFileList(boolean(excludeA)) = [];
dataAve.A.dateNum(boolean(excludeA)) = [];
dataAve.A.subjID(boolean(excludeA)) = [];
dataAve.A.subjNum(boolean(excludeA)) = [];

dataAve.B.dataFileList(boolean(excludeB)) = [];
dataAve.B.dateNum(boolean(excludeB)) = [];
dataAve.B.subjID(boolean(excludeB)) = [];
dataAve.B.subjNum(boolean(excludeB)) = [];


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
options.responseNumCutoff = 7;   % Response # cutoff
options.responseTimeCutoff = 7;   % Reaction time cutoff (s)
[options,dataAve] = analyze_SFM_control_data(options,dataAve);

% Create array to exclude poor performing subjects
dataAve.A.excludedPorPerfIdx = dataAve.A.numCorrectResp<options.responseNumCutoff;

% Exclude poor performers
dataAve.B.dataFileList(boolean(dataAve.A.excludedPorPerfIdx)) = [];
dataAve.B.dateNum(boolean(dataAve.A.excludedPorPerfIdx)) = [];
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
dataAve.B.nBlocks = 3;
for iSubj = 1:numel(dataAve.B.subjNum)

    % Load in data files for each participant
    % Contains, block, key, and time
    % Block = -1,0,1,2... defining which block responses are made (-1 is
    % practice block during control task)
    % Key are the responses (left or right)
    % Time is the time relative to block start responses are made
    data = tdfread(dataAve.B.dataFileList{iSubj},'tab');

    for iB = 1:dataAve.B.nBlocks
        resp_idx = find(data.block == iB-1);
        all_resp = data.key(resp_idx);
        flip_resp_idx = resp_idx( find(all_resp(2:end) ~= all_resp(1:end-1)) + 1 );
        % add 1 because we want the 2nd of the pair, which differs from the 1st...
        % also need to index into resp_idx, so we're looking at the
        % corect block...

        % Grab the switch times and types for this block
        dataAve.B.percSwitch{iSubj}{iB} = ...
            data.key(flip_resp_idx);
        dataAve.B.percSwitchTime{iSubj}{iB} = ...
            data.time(flip_resp_idx);

        % Make an array w/ values to plot to visualize the switches in each
        % block.
        dataPlot(iB,:) = zeros([1 options.runLength*1000]);   
        for iI = 1:length(dataAve.B.percSwitchTime{iSubj}{iB})
            if strcmp(dataAve.B.percSwitch{iSubj}{iB}(iI),'l')
                dataPlot(round(dataAve.B.percSwitchTime{iSubj}{iB}(iI)*1000)) = 1;
            elseif strcmp(dataAve.B.percSwitch{iSubj}{iB}(iI),'r')
                dataPlot(iB,round(dataAve.B.percSwitchTime{iSubj}{iB}(iI)*1000)) = 2;
            end
        end

        % Total number of switches
        dataAve.B.nFlips(iSubj,iB) = ...
            numel(dataAve.B.percSwitchTime{iSubj}{iB});
        
        % Calculate percept durations for each dom percept
        dataAve.B.perceptDur{iSubj}{iB} = ...
            [dataAve.B.percSwitchTime{iSubj}{iB} - ...
            [0 ; dataAve.B.percSwitchTime{iSubj}{iB}(1:end-1)]];

        % Calculate Hz
        dataAve.B.switchRate(iSubj,iB) = ...
            dataAve.B.nFlips(iSubj,iB)/options.runLength;

        % Calculate average percept duration
        dataAve.B.perDurAve(iSubj,iB) = ...
            mean(dataAve.B.perceptDur{iSubj}{iB});

        % Coeff of variance
        dataAve.B.CV(iSubj,iB) = ...
            std(dataAve.B.perceptDur{iSubj}{iB}) / ...
            dataAve.B.perDurAve(iSubj,iB); % mps 20200519- kwk adapted for SYON 20230206
    end

    if options.displaySubjFigs == 1
        
        figure()

        % Display time series (change in percept over time)
        subplot(3,4,1:3)
        plot(dataPlot(1,:));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Left,2=Right)');
        set(gca,'XTick',[0:20000:size(dataPlot,2)],...
            'XTickLabels',[0:20:options.runLength]);
        subplot(3,4,5:7)
        plot(dataPlot(2,:));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Left,2=Right)');
        set(gca,'XTick',[0:20000:size(dataPlot,2)],...
            'XTickLabels',[0:20:options.runLength]);
        subplot(3,4,9:11)
        plot(dataPlot(3,:));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Left,2=Right)');
        set(gca,'XTick',[0:20000:size(dataPlot,2)],...
            'XTickLabels',[0:20:options.runLength]);

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

    clear data dataPlot

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
    max_Hz = .4;
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

    title('Bi-stable Task (SFM)','fontsize',titleFontSize)
    box off
    ylabel('Switch Rate (Hz)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[0 .5])
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

% Since there are some subjects w/ no switches in a particular direction,
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
        hb = boxplot(mean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',{sprintf('%s%d',options.B.x_labels{1}(1:find(options.B.x_labels{1}=='=')),...
            sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:))==1)),...
            sprintf('%s%d',options.B.x_labels{2}(1:find(options.B.x_labels{2}=='=')),...
            sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:))==2)),...
            sprintf('%s%d',options.B.x_labels{3}(1:find(options.B.x_labels{3}=='=')),...
            sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:))==3))},'fontsize',axisLabelFontSize)
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
        hb = boxplot(mean(allDataPlot(dataAve.B.grouping~=0,:),2),dataAve.B.grouping(dataAve.B.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',{sprintf('%s%d',options.B.x_labels{1}(1:find(options.B.x_labels{1}=='=')),...
            sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:))==1)),...
            sprintf('%s%d',options.B.x_labels{3}(1:find(options.B.x_labels{3}=='=')),...
            sum(dataAve.B.grouping(dataAve.B.grouping'~=0 & durData_partIdx(:))==3))},'fontsize',axisLabelFontSize)
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
    max_Hz = 70;
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
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{2},': X2(' sprintf('%d',dataAve.B.stats.purDur.KW2{1}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{1}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{1}.table{2,6})],...
                'fontsize',statsFontSize);
            % Plot Cont vs Bp
            text(statsXVal,max_Hz-5,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.purDur.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 1
            % Plot Cont vs PwPP
            text(statsXVal,max_Hz,...
                [options.B.grpLabel{1},' vs ',options.B.grpLabel{3},': X2(' sprintf('%d',dataAve.B.stats.purDur.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.B.stats.purDur.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        end
    end

    title('Bi-stable Task (SFM)','fontsize',titleFontSize)
    box off
    ylabel('Percept Duration (sec)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[0 75])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRate.figSize,'color','w')
end


%% Split duration by the two reported directions
% Seperate out the percept durations based on walking direction
for iSubj = 1:length(dataAve.B.subjNum)
    for iBlock = 1:length(dataAve.B.perceptDur{iSubj})
        % Grab the percept durations for away / towards
        dataAve.B.percSwitch_Dir{iSubj,iBlock,1}(:) = dataAve.B.perceptDur{iSubj}{iBlock}(dataAve.B.percSwitch{iSubj}{iBlock}'=='l');
        dataAve.B.percSwitch_Dir{iSubj,iBlock,2}(:) = dataAve.B.perceptDur{iSubj}{iBlock}(dataAve.B.percSwitch{iSubj}{iBlock}'=='r');
    
        % Now average percept durations for those directions across each
        % block for each subj
        dataAve.B.percSwitch_DirAve(iSubj,iBlock,1) = nanmean(dataAve.B.percSwitch_Dir{iSubj,iBlock,1});
        dataAve.B.percSwitch_DirAve(iSubj,iBlock,2) = nanmean(dataAve.B.percSwitch_Dir{iSubj,iBlock,2});
    end
end

% Assign all data
clear allData allDataPlot
allData = dataAve.B.percSwitch_DirAve;
allDataPlot = dataAve.B.percSwitch_DirAve;

% Average across blocks for each direction
clear durData
durData = squeeze(nanmean(allData,2));

% Since there are some subjects w/ no switches in a particular direction,
% make index to exclude sucbjects and make final participant counts. 
durData_partIdx = ~isnan(durData);

% Plot seperated duration for away / towards
if options.displayFigs
    directionTitle = {'Left','Right'};
    for iDir = 1:2   % Plot for both directions
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
            beePlot = plotSpread({nanmean(allDataPlot((dataAve.B.grouping==1)'~=0 & durData_partIdx(:,iDir),:,iDir),2),
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

        title(sprintf('%s%s%s','Bi-stable Task (SFM - ',directionTitle{iDir},')'),'fontsize',titleFontSize)
        box off
        ylabel('Percept Duration (sec)','fontsize',axisTitleFontSize)
        set(gca,'ylim',[0 90])
        set(gca,'XColor','k','YColor','k')

        set(gcf,'Units','inches')
        set(gcf,'Position',figSize.switchRate.figSize,'color','w')
    end
end


end