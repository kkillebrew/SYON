function [options,dataAve] = analyze_SFM_control_data(options,dataAve)
% usage: dataAve = analyze_SFM_control_data(options)
% Load in and analyze real switch task data for SFM SYON task. 
% Output array that will be used to exclude poor performers from bi-stable
% task.
% KWK - 20231017
%

%% Load in the control switch values and times
dataAve.A.controlSwitch = readtable(fullfile(options.curDur,'SFMControlSwitches.xlsx'));
dataAve.A.controlSwitch = table2cell(dataAve.A.controlSwitch);
% Create time bins that we can use to search for correct responses
% in within the given RT cutoff range.
dataAve.A.controlSwitchTime = [dataAve.A.controlSwitch{4:end,2}];
dataAve.A.controlSwitchType = {dataAve.A.controlSwitch{4:end,1}};
dataAve.A.controlSwitchTimeBins = [dataAve.A.controlSwitchTime(:) dataAve.A.controlSwitchTime(:)+options.responseTimeCutoff];

%% Load in subj data / calculate switch rate
dataAve.A.nBlocks = 1;
for iSubj = 1:numel(dataAve.A.subjNum)

    % Load in data files for each participant
    % Contains, block, key, and time
    % Block = -1,0,1,2... defining which block responses are made (-1 is
    % practice block during control task)
    % Key are the responses (left or right)
    % Time is the time relative to block start responses are made
    data = tdfread(dataAve.A.dataFileList{iSubj},'tab');

    for iB = 1:dataAve.A.nBlocks
        resp_idx = find(data.block == iB-1);   % Only one block definded by 0
        all_resp = data.key(resp_idx);
        flip_resp_idx = resp_idx( find(all_resp(2:end) ~= all_resp(1:end-1)) + 1 );
        % add 1 because we want the 2nd of the pair, which differs from the 1st...
        % also need to index into resp_idx, so we're looking at the
        % corect block...

        % Grab the switch times and types for this block
        dataAve.A.percSwitch{iSubj}{iB} = ...
            data.key(flip_resp_idx);
        dataAve.A.percSwitchTime{iSubj}{iB} = ...
            data.time(flip_resp_idx);

        % Make an array w/ values to plot to visualize the switches in each
        % block.
        dataPlot(iB,:) = zeros([1 options.runLength*1000]);   
        for iI = 1:length(dataAve.A.percSwitchTime{iSubj}{iB})
            if strcmp(dataAve.A.percSwitch{iSubj}{iB}(iI),'l')
                dataPlot(round(dataAve.A.percSwitchTime{iSubj}{iB}(iI)*1000)) = 1;
            elseif strcmp(dataAve.A.percSwitch{iSubj}{iB}(iI),'r')
                dataPlot(iB,round(dataAve.A.percSwitchTime{iSubj}{iB}(iI)*1000)) = 2;
            end
        end

        %% Look at reaction times
        % Grab responses made within each time window
        respTimeHolder = cell([1,size(dataAve.A.controlSwitchTime,2)]);
        respTypeHolder = cell([1,size(dataAve.A.controlSwitchTime,2)]);
        for iContResp = 1:size(dataAve.A.controlSwitchTimeBins,1)
            counter = 0;
            for iResp = 1:numel(dataAve.A.percSwitchTime{iSubj}{iB})
                if dataAve.A.percSwitchTime{iSubj}{iB}(iResp) > dataAve.A.controlSwitchTimeBins(iContResp,1) & ...
                        dataAve.A.percSwitchTime{iSubj}{iB}(iResp) < dataAve.A.controlSwitchTimeBins(iContResp,2)
                    counter = counter + 1;
                    respTimeHolder{iContResp}(counter) = dataAve.A.percSwitchTime{iSubj}{iB}(iResp);
                    respTypeHolder{iContResp}{counter} = dataAve.A.percSwitch{iSubj}{iB}(iResp);
                end
            end
        end
        
        % Now look for correct responses
        for iResp = 1:size(respTypeHolder,2)
            if isempty(respTypeHolder{iResp})   % If no response within window mark as incorrect
                respTypeAcc(iResp) = 0;
                respTimeAcc(iResp) = NaN;
            elseif size(respTypeHolder{iResp},2) == 1   % If only one response check accuracy
                respTypeAcc(iResp) = strcmp(respTypeHolder{iResp}, dataAve.A.controlSwitchType{iResp}(1));
                respTimeAcc(iResp) = respTimeHolder{iResp};
            else   % If there are more than one responses w/in the time window check until there is a correct resp
                for iNumResp = 1:size(respTypeHolder{iResp},2)
                    respTypeAccHolder = strcmp(respTypeHolder{iResp}{iNumResp}, dataAve.A.controlSwitchType{iResp}(1));
                    if respTypeAccHolder == 1
                        respTypeAcc(iResp) = 1;
                        respTimeAcc(iResp) = respTimeHolder{iResp}(iNumResp);
                        break
                    else
                        respTypeAcc(iResp) = 0;
                        respTimeAcc(iResp) = NaN;
                    end
                end
            end
        end

        % Time after actual switch response was made
        dataAve.A.reactionTime(iSubj,iB,:) = respTimeAcc - dataAve.A.controlSwitchTime;
        dataAve.A.reactionTimeAve(iSubj,iB) = nanmean(dataAve.A.reactionTime(iSubj,iB,:));
        dataAve.A.numCorrectResp(iSubj,iB) = sum(respTypeAcc);

        clear respTimeAcc respTypeAcc respTypeHolder respTimeHolder

        %% Find all initial correct responses made after a switch (up until
        % the next switch occurs) to make histogram of total responses made
        % by response time figure. 
        % Make response bins that go from initial switch to time of next
        % switch
        for iI = 1:length(dataAve.A.controlSwitchTime)-1
            controlSwitchTimeBinsFull(iI,:) = [dataAve.A.controlSwitchTime(iI) dataAve.A.controlSwitchTime(iI+1)];
        end
        % Add one extra time bin for the last time window up to the end of the experiment
        controlSwitchTimeBinsFull(length(dataAve.A.controlSwitchTime),:) = [dataAve.A.controlSwitchTime(end) 120];

        % Grab responses made within each time window
        respTimeHolder = cell([1,size(dataAve.A.controlSwitchTime,2)]);
        respTypeHolder = cell([1,size(dataAve.A.controlSwitchTime,2)]);
        for iContResp = 1:size(controlSwitchTimeBinsFull,1)
            counter = 0;
            for iResp = 1:numel(dataAve.A.percSwitchTime{iSubj}{iB})
                if dataAve.A.percSwitchTime{iSubj}{iB}(iResp) > controlSwitchTimeBinsFull(iContResp,1) & ...
                        dataAve.A.percSwitchTime{iSubj}{iB}(iResp) < controlSwitchTimeBinsFull(iContResp,2)
                    counter = counter + 1;
                    respTimeHolder{iContResp}(counter) = dataAve.A.percSwitchTime{iSubj}{iB}(iResp);
                    respTypeHolder{iContResp}{counter} = dataAve.A.percSwitch{iSubj}{iB}(iResp);
                end
            end
        end

        % Now look for correct responses
        for iResp = 1:size(respTypeHolder,2)
            if isempty(respTypeHolder{iResp})   % If no response within window mark as incorrect
                respTypeAcc(iResp) = 0;
                respTimeAcc(iResp) = NaN;
            elseif size(respTypeHolder{iResp},2) == 1   % If only one response check accuracy
                respTypeAcc(iResp) = strcmp(respTypeHolder{iResp}, dataAve.A.controlSwitchType{iResp}(1));
                respTimeAcc(iResp) = respTimeHolder{iResp};
            else   % If there are more than one responses w/in the time window check until there is a correct resp
                for iNumResp = 1:size(respTypeHolder{iResp},2)
                    respTypeAccHolder = strcmp(respTypeHolder{iResp}{iNumResp}, dataAve.A.controlSwitchType{iResp}(1));
                    if respTypeAccHolder == 1
                        respTypeAcc(iResp) = 1;
                        respTimeAcc(iResp) = respTimeHolder{iResp}(iNumResp);
                        break
                    else
                        respTypeAcc(iResp) = 0;
                        respTimeAcc(iResp) = NaN;
                    end
                end
            end
        end

        % Time after actual switch response was made
        dataAve.A.reactionTime_NoTimeWindow(iSubj,iB,:) = respTimeAcc - dataAve.A.controlSwitchTime;
        dataAve.A.reactionTimeAve_NoTimeWindow(iSubj,iB) = nanmean(dataAve.A.reactionTime_NoTimeWindow(iSubj,iB,:));
        dataAve.A.numCorrectResp_NoTimeWindow(iSubj,iB) = sum(respTypeAcc);

        clear respTimeAcc respTypeAcc respTypeHolder respTimeHolder


        %% Calculate switch values
        % Total number of switches
        dataAve.A.nFlips(iSubj,iB) = ...
            numel(dataAve.A.percSwitchTime{iSubj}{iB});
        
        % Calculate percept durations for each dom percept
        dataAve.A.perceptDur{iSubj}{iB} = ...
            [dataAve.A.percSwitchTime{iSubj}{iB} - ...
            [0 ; dataAve.A.percSwitchTime{iSubj}{iB}(1:end-1)]];

        % Calculate Hz
        dataAve.A.switchRate(iSubj,iB) = ...
            dataAve.A.nFlips(iSubj,iB)/options.runLength;

        % Calculate average percept duration
        dataAve.A.perDurAve(iSubj,iB) = ...
            mean(dataAve.A.perceptDur{iSubj}{iB});

        % Coeff of variance
        dataAve.A.CV(iSubj,iB) = ...
            std(dataAve.A.perceptDur{iSubj}{iB}) / ...
            dataAve.A.perDurAve(iSubj,iB); % mps 20200519- kwk adapted for SYON 20230206
    end

    if options.displaySubjFigs == 1
        
        figure()

        % Display time series (change in percept over time)
        subplot(1,4,1:3)
        plot(dataPlot(1,:));
        title('Switches Over Time');
        xlabel('Time (s)');
        ylabel('Percept (1=Left,2=Right)');
        set(gca,'XTick',[0:20000:size(dataPlot,2)],...
            'XTickLabels',[0:20:options.runLength]);
        %         subplot(3,4,5:7)
        %         plot(dataPlot(2,:));
        %         title('Switches Over Time');
        %         xlabel('Time (s)');
        %         ylabel('Percept (1=Left,2=Right)');
        %         set(gca,'XTick',[0:20000:size(dataPlot,2)],...
        %             'XTickLabels',[0:20:options.runLength]);
        %         subplot(3,4,9:11)
        %         plot(dataPlot(3,:));
        %         title('Switches Over Time');
        %         xlabel('Time (s)');
        %         ylabel('Percept (1=Left,2=Right)');
        %         set(gca,'XTick',[0:20000:size(dataPlot,2)],...
        %             'XTickLabels',[0:20:options.runLength]);

        % Display switch rate (Hz)
        subplot(1,4,[4]);
        bar([dataAve.A.switchRate(iSubj,:) nanmean(dataAve.A.switchRate(iSubj,:))]);
        hold on
        errorbar(length([dataAve.A.switchRate(iSubj,:) nanmean(dataAve.A.switchRate(iSubj,:))]),...
            nanmean(dataAve.A.switchRate(iSubj,:)),nanstd(dataAve.A.switchRate(iSubj,:)),'.k')
        title('Switche Rate');
        ylabel('Switch Rate (Hz)');
        % Make xtick labels
        for iI=1:size(dataAve.A.switchRate,2)
            xLab{iI} = num2str(iI);
        end
        set(gca,'XTickLabels',{xLab{:},'Average'});
        set(gca,'YLim',[0 1.5],'YTick',[0:.2:1.5]) 
    end

    clear data dataPlot


end

%% Group analysis 
% Average switch rate
dataAve.A.switchRateGrpAve(1) = mean(mean(dataAve.A.switchRate(dataAve.A.grouping==1),2));
dataAve.A.switchRateGrpAve(2) = mean(mean(dataAve.A.switchRate(dataAve.A.grouping==2),2));
dataAve.A.switchRateGrpAve(3) = mean(mean(dataAve.A.switchRate(dataAve.A.grouping==3),2));

%% Do stats for Hz
% Normalize data for analysis needed 
if options.normalize == 0
    allData = dataAve.A.switchRate;
elseif options.normalize == 1
    allData = log10(dataAve.A.switchRate);
    allData(allData == Inf | allData == -Inf) = NaN;
end

% Normalize data for plotting needed 
if options.normalize_plot == 0
    allDataPlot = dataAve.A.switchRate;
elseif options.normalize_plot == 1
    allDataPlot = log10(dataAve.A.switchRate);
    allDataPlot(allDataPlot == Inf | allDataPlot == -Inf) = NaN;
end

% Average allData
hzData = nanmean(allData,2);

% Create grouping variables for stats
allBlock = [ones([size(allData,1) 1]) ones([size(allData,1) 1])+1 ones([size(allData,1) 1])+2];
allGroup = [dataAve.A.grouping' dataAve.A.grouping' dataAve.A.grouping'];
allSubj = repmat([1:size(allData,1)]',[1 size(allData,2)]);

% Do ANOVA
nest = zeros(3,3);
nest(1,2) = 1;

% [dataAve.A.stats.Hz.ANOVA.p, dataAve.A.stats.Hz.ANOVA.anovaTable] = ...
%     anovan(allData(:), {allSubj(:), allGroup(:), allBlock(:)}, 'random', 1, 'continuous', [3],...
%     'nested', nest, 'model', 'full', 'varnames', {'subj', 'group', 'block'}, 'display', options.showStatsFig);

% Run 2KW between controls and PwPP
% Run 2KW between 3 groups
statsRunIdx = [1 2; 1 3; 2 3];
for iI=1:3
    % Run 2KW between the three groups
    [dataAve.A.stats.Hz.KW2{iI}.p, dataAve.A.stats.Hz.KW2{iI}.table, dataAve.A.stats.Hz.KW2{iI}.stats] = ...
        kruskalwallis([hzData(dataAve.A.grouping == statsRunIdx(iI,1),:)', hzData(dataAve.A.grouping == statsRunIdx(iI,2),:)'],...
        [dataAve.A.grouping(dataAve.A.grouping == statsRunIdx(iI,1)) dataAve.A.grouping(dataAve.A.grouping == statsRunIdx(iI,2))], options.showStatsFig);
end


%% Distribution of total responses made by response time
if options.displayFigs
    titleFontSize = 12;
    axisLabelFontSize = 10;
    axisTitleFontSize = 12;
    statsFontSize = 10;
    legendTitleHolder = {sprintf('%s%s%d%s',options.A.grpLabel{1},'(n=',sum(options.A.grpIdx{1}),')'),...
        sprintf('%s%s%d%s',options.A.grpLabel{2},'(n=',sum(options.A.grpIdx{2}),')'),...
        sprintf('%s%s%d%s',options.A.grpLabel{3},'(n=',sum(options.A.grpIdx{3}),')')};
    figure()
    % Set figure size
    figSize.distOfTotalResp.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.distOfTotalResp.aspectRatio = [6.5 6];
    figSize.distOfTotalResp.figSize = [0 0 ...
        figSize.distOfTotalResp.aspectRatio];

    if options.includeRelatives == 1
        subplot(3,1,1)
        holderPlot = squeeze(dataAve.A.reactionTime_NoTimeWindow(options.A.grpIdx{1},1,:));
        hist(holderPlot, [1:12])
        xlim([0 13])
        title(legendTitleHolder{1},'color',options.col_list{1},'fontsize',titleFontSize)
        set(gca,'XColor','k','YColor','k','fontsize',axisLabelFontSize)
        set(gca,'XTickLabel',[0:11],'XTick',[1:12])
        clear holderPlot

        subplot(3,1,2)
        holderPlot = squeeze(dataAve.A.reactionTime_NoTimeWindow(options.A.grpIdx{2},1,:));
        hist(holderPlot, [1:12])
        ylabel('Number of Time Bins','fontsize',axisTitleFontSize)
        xlim([0 13])
        title(legendTitleHolder{2},'color',options.col_list{2},'fontsize',titleFontSize)
        set(gca,'XColor','k','YColor','k','fontsize',axisLabelFontSize)
        set(gca,'XTickLabel',[0:11],'XTick',[1:12])
        clear holderPlot

        subplot(3,1,3)
        holderPlot = squeeze(dataAve.A.reactionTime_NoTimeWindow(options.A.grpIdx{3},1,:));
        hist(holderPlot, [1:12])
        xlim([0 13])
        title(legendTitleHolder{3},'color',options.col_list{3},'fontsize',titleFontSize)
        set(gca,'XColor','k','YColor','k','fontsize',axisLabelFontSize)
        set(gca,'XTickLabel',[0:11],'XTick',[1:12])
        clear holderPlot
    elseif options.includeRelatives == 0
        subplot(2,1,1)
        holderPlot = squeeze(dataAve.A.reactionTime_NoTimeWindow(options.A.grpIdx{1},1,:));
        hist(holderPlot, [1:12])
        ylabel('Number of Time Bins','fontsize',axisTitleFontSize)
        xlim([0 13])
        title(legendTitleHolder{1},'color',options.col_list{1},'fontsize',titleFontSize)
        set(gca,'XColor','k','YColor','k','fontsize',axisLabelFontSize)
        set(gca,'XTickLabel',[0:11],'XTick',[1:12])
        clear holderPlot

        subplot(2,1,2)
        holderPlot = squeeze(dataAve.A.reactionTime_NoTimeWindow(options.A.grpIdx{3},1,:));
        hist(holderPlot, [1:12])
        xlim([0 13])
        title(legendTitleHolder{3},'color',options.col_list{3},'fontsize',titleFontSize)
        set(gca,'XColor','k','YColor','k','fontsize',axisLabelFontSize)
        set(gca,'XTickLabel',[0:11],'XTick',[1:12])
        clear holderPlot
    end
end

%% Distribution of the number of responses made
if options.displayFigs
    % Create arrays of # of participants in each bin to plot
    if options.includeRelatives == 1
        grpIdxHolder = 1:3;
    elseif options.includeRelatives == 0
        grpIdxHolder = [1 3];
    end
    for iG = 1:length(grpIdxHolder)   % For each group
        for iB = 1:length(dataAve.A.controlSwitchTime)+1   % For total number of real switches
            dataHolder(iG,iB) = sum(dataAve.A.numCorrectResp(options.A.grpIdx{grpIdxHolder(iG)}) == iB-1);
        end
    end

    figure()
    % Set figure size
    figSize.distOfResp.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.distOfResp.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.distOfResp.figSize = [0 0 ...
        figSize.distOfResp.aspectRatio];   % Size/postion of fig
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;

    hBar = bar(1:length(dataAve.A.controlSwitchTime)+1,dataHolder);
    hold on
    plot([options.responseNumCutoff options.responseNumCutoff],[0 100],'--k');
    if options.includeRelatives == 1
        hBar(1).FaceColor = options.col_list{1};
        hBar(2).FaceColor = options.col_list{2};
        hBar(3).FaceColor = options.col_list{3};
        hBar(1).EdgeColor = [0 0 0];
        hBar(2).EdgeColor = [0 0 0];
        hBar(3).EdgeColor = [0 0 0];

        legend({legendTitleHolder{:}},'FontName','Arial','FontSize',axisLabelFontSize,'LineWidth',[1],'EdgeColor',[0 0 0],'Location','northwest')
    elseif options.includeRelatives == 0
        hBar(1).FaceColor = options.col_list{1};
        hBar(2).FaceColor = options.col_list{3};
        hBar(1).EdgeColor = [0 0 0];
        hBar(2).EdgeColor = [0 0 0];
        
        legend({legendTitleHolder{[1 3]}},'FontName','Arial','FontSize',axisLabelFontSize,'LineWidth',[1],'EdgeColor',[0 0 0],'Location','northwest')
    end
    title(sprintf('%s%.1f%s','Histogram of Participant Responses Made Before ',options.responseTimeCutoff,'s'))
    ylabel('Number of Participants','FontSize',axisTitleFontSize)
    xlabel('Number of Responses Made','FontSize',axisTitleFontSize)
    ylim([0 20])
    set(gca,'xticklabels',[0:length(dataHolder)-1],'xtick',[1:length(dataHolder)])
    box off
end

%% Plot switch rate
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
        beePlot = plotSpread({mean(allDataPlot(options.A.grpIdx{1},:),2),...
            mean(allDataPlot(options.A.grpIdx{2},:),2),mean(allDataPlot(options.A.grpIdx{3},:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(mean(allDataPlot(dataAve.A.grouping~=0),2),dataAve.A.grouping(dataAve.A.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',options.A.x_labels,'fontsize',axisLabelFontSize)
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

        % Plot line at physical switch
        plot([0 4],[0.09 0.09],'--k');
    elseif options.includeRelatives == 0
        % Beeswarm
        x_val = [1 2];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        options.beePointSize = 16;
        beePlot = plotSpread({mean(allDataPlot(options.A.grpIdx{1},:),2),mean(allDataPlot(options.A.grpIdx{3},:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(mean(allDataPlot(dataAve.A.grouping~=0),2),dataAve.A.grouping(dataAve.A.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',options.A.x_labels([1 3]),'fontsize',axisLabelFontSize)
        set(hb,'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        useColList = {options.col_list{3} options.col_list{1}};
        for iHB = 1:size(hb,2)
            set(hb2((iHB)+2:2:end),'color',useColList{iHB})
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

        % Plot line at physical switch
        plot([0 4],[0.09 0.09],'--k');
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
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{2},': X2(' sprintf('%d',dataAve.A.stats.Hz.KW2{1}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{1}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{1}.table{2,6})],...
                'fontsize',statsFontSize);
            % Plot Cont vs Bp
            text(statsXVal,max_Hz-.05,...
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{3},': X2(' sprintf('%d',dataAve.A.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 1
            % Plot Cont vs PwPP
            text(statsXVal,max_Hz,...
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{3},': X2(' sprintf('%d',dataAve.A.stats.Hz.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.Hz.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        end
        
    end

    title('Real Switch Task (SFM)','fontsize',titleFontSize)
    box off
    ylabel('Switch Rate (Hz)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[0 .5])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRate.figSize,'color','w')
end

%% Do stats for duration
clear allBlock allGroup allSubj allData allDataPlot
allData = dataAve.A.perDurAve;
allDataPlot = dataAve.A.perDurAve;

% Average allData
durData = nanmean(allData,2);

% Create grouping variables for stats
allBlock = [ones([size(allData,1) 1]) ones([size(allData,1) 1])+1 ones([size(allData,1) 1])+2];
allGroup = [dataAve.A.grouping' dataAve.A.grouping' dataAve.A.grouping'];
allSubj = repmat([1:size(allData,1)]',[1 size(allData,2)]);

% Do ANOVA
nest = zeros(3,3);
nest(1,2) = 1;

% [dataAve.A.stats.purDur.ANOVA.p, dataAve.A.stats.purDur.ANOVA.anovaTable] = ...
%     anovan(allData(:), {allSubj(:), allGroup(:), allBlock(:)}, 'random', 1, 'continuous', [3],...
%     'nested', nest, 'model', 'full', 'varnames', {'subj', 'group', 'block'}, 'display', options.showStatsFig);

statsRunIdx = [1 2; 1 3; 2 3];
for iI=1:3
    % Run 2KW between the three groups
    [dataAve.A.stats.purDur.KW2{iI}.p, dataAve.A.stats.purDur.KW2{iI}.table, dataAve.A.stats.purDur.KW2{iI}.stats] = ...
        kruskalwallis([durData(dataAve.A.grouping == statsRunIdx(iI,1),:)', durData(dataAve.A.grouping == statsRunIdx(iI,2),:)'],...
        [dataAve.A.grouping(dataAve.A.grouping == statsRunIdx(iI,1)) dataAve.A.grouping(dataAve.A.grouping == statsRunIdx(iI,2))], options.showStatsFig);
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
        beePlot = plotSpread({mean(allDataPlot(options.A.grpIdx{1},:),2),...
            mean(allDataPlot(options.A.grpIdx{2},:),2),mean(allDataPlot(options.A.grpIdx{3},:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(mean(allDataPlot(dataAve.A.grouping~=0,:),2),dataAve.A.grouping(dataAve.A.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',options.A.x_labels,'fontsize',axisLabelFontSize)
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
        beePlot = plotSpread({mean(allDataPlot(options.A.grpIdx{1},:),2),mean(allDataPlot(options.A.grpIdx{3},:),2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb = boxplot(mean(allDataPlot(dataAve.A.grouping~=0,:),2),dataAve.A.grouping(dataAve.A.grouping~=0)');
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',options.A.x_labels([1 3]),'fontsize',axisLabelFontSize)
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
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{2},': X2(' sprintf('%d',dataAve.A.stats.purDur.KW2{1}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{1}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{1}.table{2,6})],...
                'fontsize',statsFontSize);
            % Plot Cont vs Bp
            text(statsXVal,max_Hz-5,...
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{3},': X2(' sprintf('%d',dataAve.A.stats.purDur.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 1
            % Plot Cont vs PwPP
            text(statsXVal,max_Hz,...
                [options.A.grpLabel{1},' vs ',options.A.grpLabel{3},': X2(' sprintf('%d',dataAve.A.stats.purDur.KW2{2}.table{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{2}.table{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.A.stats.purDur.KW2{2}.table{2,6})],...
                'fontsize',statsFontSize);
        end
    end

    title('Real Switch Task (SFM)','fontsize',titleFontSize)
    box off
    ylabel('Percept Duration (sec)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[0 75])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRate.figSize,'color','w')
end


end