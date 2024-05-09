function [dataAve] = illSizeBehavAnalysis_Batch(options)

%% Initialize variables
if ~exist('options','var') % parameters
    options = [];
end
if ~isfield(options,'subj_group_def')
    options.subj_group_def = 1; % 1 = controls, relatives, probands; 2 = controls, SZ, BP
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 1;   % Show figures
end
if ~isfield(options,'showStatsFig')
    options.showStatsFig = 'off';   % Display auto gen'd figures output from the stats test
end
if ~isfield(options,'plot_stats')
    options.plot_stats = 1;   % Plot stats on figures
end
if ~isfield(options,'norm_stats_data')
    options.norm_stats_data = 1;   % 0=no norm; 1=log10 norm
end
if ~isfield(options,'accCutoff')
    options.accCutoff = 85;   % Set cutoff for tossing based on catch trial accuracy 
end

if ~isfield (options,'symptom_measure')
    options.symptom_measure = [];
    % Enter as string (from get_syon_symptoms): 
    % BPRS (Tota/Positive/Negative/Disorganization/Depression/Mania), 
    % SAPS (Total/Reality Distortion/Thought Disorder/Bizarre Behavior),
    % SANS (Total/Negative Symptoms/Blunted Affect/Attention),
    % SPQ, SGI
end

if ~isfield (options, 'symp_date_limit')
    options.symp_date_limit = 30;
    % Choose limit appropriate to symptom measure (e.g. 30 days for BPRS)
end

% Use on MRI data server
addpath(genpath('/home/jaco-raid8/sponheim-data/SYON/SYON.git/Functions/'))
addpath(genpath('/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics/'))
options.curDur = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Illusory_Size_Task/Behavioral_Task/';

% Use on EEG server
% addpath(genpath('/labs/srslab/data_main/SYON.git/Functions/'))
% options.curDur = '/labs/srslab/data_main/SYON.git/Illusory_Size_Task/Behavioral_Task/';


%% Load in subject data
dataAve.dataFileList = dir([options.curDur 'Data/S*_1000ms_Flicker_FixLine_BothPersp_Illusory_Size_Task_MR_Prac_*.mat']);
% Ensure all the files are actually data files and not tests/pilots
holderName = {dataAve.dataFileList.name};
holderName = cellfun(@(x) x(1:8), holderName, 'UniformOutput', false);
holderNum = cellfun(@(x) x(2:8), holderName, 'UniformOutput', false);
% Returns a number for each subject that indexes where in the string
% (holderName{iI}) the patter shown in the second input begins. It checks
% each input in holderName for the patter (letter digit digit ...). Any
% value w/ a '0' or empty in the output means that file is not correct and
% should be tossed.
holderTaskData = regexp(holderName, '\w\d\d\d\d\d\d\d','once');
holderTaskDataIdx = cellfun('isempty',holderTaskData);
dataAve.dataFileList(holderTaskDataIdx) = [];
dataAve.subjID = holderName(~holderTaskDataIdx);
dataAve.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx)); 
clear holderName holderTaskData holderTaskDataIdx

% Choose example participant to show PSE plots for:
dataAve.examplePSE.subjName = 'S1012451';
dataAve.examplePSE.subjNum = 1012451;


for iJ=1:length(dataAve.dataFileList)
    
    %% Load in data files for each participant
    load([options.curDur 'Data/' dataAve.dataFileList(iJ).name],'data');
    tempOptions = load([options.curDur 'Data/' dataAve.dataFileList(iJ).name],'options');
    blockOrder = tempOptions.options.blockOrder;
    datecode{iJ} = tempOptions.options.datecode;
    if dataAve.subjNum(iJ) == dataAve.examplePSE.subjNum
        dataAve.examplePSE.blockOrder = tempOptions.options.blockOrder;   % Order of blocks presented
        dataAve.examplePSE.blockNum = tempOptions.options.blockNum;   % Number of blocks
    end 
    clear tempOptions
    if blockOrder == 1
        threshIdx = [1 3; 2 4];
    elseif blockOrder == 2
        threshIdx = [2 4; 1 3];
    end

    data.thresh.thresh_refit_mean(1) = nanmean([data.thresh.ave(threshIdx(1,:)).thresh_refit]);
    data.thresh.thresh_refit_mean(2) = nanmean([data.thresh.ave(threshIdx(2,:)).thresh_refit]);
    data.thresh.thresh_refit_ste(1) = nanstd([data.thresh.ave(threshIdx(1,:)).thresh_refit]) / sqrt(numel([data.thresh.ave(threshIdx(1,:)).thresh_refit]));
    data.thresh.thresh_refit_ste(2) = nanstd([data.thresh.ave(threshIdx(2,:)).thresh_refit]) / sqrt(numel([data.thresh.ave(threshIdx(2,:)).thresh_refit]));

    %% Calculate catch trial accuracy
    data.largerCatchBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10))/...
        length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10)))*100;   % Larger catch hallway
    data.largerCatchNoBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10))/...
        length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10)))*100;   % Larger catch no hallway
    data.smallerCatchBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10))/...
        length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10)))*100;   % Smaller catch hallway
    data.smallerCatchNoBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10))/...
        length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10)))*100;   % Smaller catch no hallway

    data.catchAve = nanmean([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);
    data.catchSTD = std([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);

    dataAve.PSE(iJ,:) = data.thresh.thresh_refit_mean .* 100;   % Average PSE per participant
    dataAve.PSE_norm(iJ,:) = log10(data.thresh.thresh_refit_mean .* 100);
    dataAve.diffPSE(iJ) = dataAve.PSE(iJ,1) - dataAve.PSE(iJ,2);
    dataAve.diffPSE_norm(iJ) = dataAve.PSE_norm(iJ,1) - dataAve.PSE_norm(iJ,2);
    dataAve.catch(iJ,:)  = [data.largerCatchBack data.largerCatchNoBack...
        data.smallerCatchBack data.smallerCatchNoBack data.catchAve];
    dataAve.catchAveBlock(iJ) = nanmean(dataAve.catch(iJ,:),2);
    dataAve.catchSTDBlock = nanstd(dataAve.catch(iJ,:));

    %% Grab an example PSE and plot the fitted functions for each condition
    if dataAve.subjNum(iJ) == dataAve.examplePSE.subjNum
        dataAve.examplePSE.thresh = data.thresh;
        dataAve.examplePSE.stair = data.stair;

        % Plot comparison graph
        if options.displayFigs == 1; figure;
            plot_symbols = {'o','s','^'};
            plot_lines = {'-','--','-.'};

            % Plot the four psychometric fits on the same plot
            subplot(1,4,1); hold on;
            x_val = .5:.025:1.5;
            plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
            if dataAve.examplePSE.blockOrder == 1
                lineCol = {'r' 'b' 'r' 'b'};
                lineTypeTitle = {'Hall:1','NoHall:1','Hall:2','NoHall:2'};
                faceColor = [1 0 0; 0 0 1; 0.5 0 0; 0 0 0.5];
                barOrder = [1 3 2 4];
            elseif dataAve.examplePSE.blockOrder == 2
                lineCol = {'b' 'r' 'b' 'r'};
                lineTypeTitle = {'NoHall:1','Hall:1','NoHall:2','Hall:2'};
                faceColor = [0 0 1; 1 0 0; 0 0 0.5; 0.5 0 0];
                barOrder = [2 4 1 3];
            end

            for iK=1:dataAve.examplePSE.blockNum
                % Plot rawdata acc
                for j=1:numel(data.thresh.ave(iK).stimLevels)
                    plot(data.thresh.ave(iK).stimLevels(j),data.thresh.ave(iK).numPos(j)/data.thresh.ave(iK).outOfNum(j),...
                        [plot_symbols{1}],'Color',faceColor(iK,:),'MarkerSize',data.thresh.ave(iK).outOfNum(j)+2,'linewidth',2)
                end

                blockPlot(iK) = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(iK).paramsFit(:)),x_val),[plot_lines{1}],...
                    'Color',faceColor(iK,:),'linewidth',2);
                plot([data.thresh.ave(iK).thresh_refit data.thresh.ave(iK).thresh_refit],[0 1],...
                    [plot_lines{2}],'Color',faceColor(iK,:),'linewidth',2);
            end
            axis([.5 1.5 -0.05 1.05])
            box off
            title('Hall-No Hall');
            set(gca,'fontsize',12)
            legend(blockPlot(:),lineTypeTitle,'location','northwest');
            
            % Plot the combined thresh in bargraph for shape/noshape
            subplot(1,4,2); hold on;
            for iK=1:dataAve.examplePSE.blockNum
                combinedBar(iK) = bar(iK,[data.thresh.ave(barOrder(iK)).thresh_refit]);
                combinedBar(iK).FaceColor = faceColor(barOrder(iK),:);
                hold on
            end
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2 3 4]);
            set(gca,'XTickLabel',lineTypeTitle(barOrder))
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Combined Hall-No Hall PSE')
            
            % Plot the mean/std across the 4 staircases
            data.thresh.thresh_refit_mean(barOrder(1:2)) = nanmean(data.thresh.thresh_refit(barOrder(1:2),:));
            data.thresh.thresh_refit_mean(barOrder(3:4)) = nanmean(data.thresh.thresh_refit(barOrder(3:4),:));
            data.thresh.thresh_refit_ste(barOrder(1:2)) = ste(data.thresh.thresh_refit(barOrder(1:2),:));
            data.thresh.thresh_refit_ste(barOrder(3:4)) = ste(data.thresh.thresh_refit(barOrder(3:4),:));
            
            subplot(1,4,3); hold on;
            for iK=1:dataAve.examplePSE.blockNum
                meanBar(iK) = bar(iK,[data.thresh.thresh_refit_mean(barOrder(iK))]);
                meanBar(iK).FaceColor = faceColor(barOrder(iK),:);
                meanErrorbar(iK) = errorbar(iK,data.thresh.thresh_refit_mean(barOrder(iK)),...
                    data.thresh.thresh_refit_ste(barOrder(iK)),'.k');
            end
            hold on
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2 3 4]);
            set(gca,'XTickLabel',lineTypeTitle(barOrder))
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Mean Hall-No Hall PSE')
            
            % Calculate and plot catch trial accuracy
            data.largerCatchBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10))/...
                length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10)))*100;   % Larger catch hallway
            data.largerCatchNoBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10))/...
                length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10)))*100;   % Larger catch no hallway
            data.smallerCatchBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10))/...
                length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10)))*100;   % Smaller catch hallway
            data.smallerCatchNoBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10))/...
                length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10)))*100;   % Smaller catch no hallway
            
            data.catchAve = nanmean([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);
            data.catchSTD = std([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);
            
            subplot(1,4,4); hold on;
            bar([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack data.catchAve]);
            hold on
            errorbar(5,data.catchAve,data.catchSTD,'.k');
            ylim([0 110])
            set(gca,'YTick',[0:10:110]);
            set(gca,'XTick',[1:5]);
            set(gca,'XTickLabel',{'Larger: Hall','Larger: No Hall','Smaller: Hall','Smaller: No Hall','Average'})
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Average Catch Trial Accuracy')
        end
    end

    clear data blockOrder
end
%% Create exclusion based on catch trial performance

dataAve.excludeIndex = dataAve.catchAveBlock <= options.accCutoff;

%% Take grand averages
% Take the average PSE across participants
dataAve.avePSE = nanmean(dataAve.PSE(~dataAve.excludeIndex,:),1);
dataAve.stdPSE = nanstd(dataAve.PSE(~dataAve.excludeIndex,:));

% Take the average difference between the two PSE values
dataAve.aveDiffPSE = nanmean(dataAve.diffPSE(~dataAve.excludeIndex),1);
dataAve.stdDiffPSE = nanstd(dataAve.diffPSE(~dataAve.excludeIndex),1);

% Take the average catch accuracy
dataAve.aveCatch = nanmean(dataAve.catchAveBlock);
dataAve.stdCatch = nanstd(dataAve.catchAveBlock);

%% Define the groups
% 1 = controls, relatives, probands; 2 = controls, SZ, BP

group_def_opt = [];
group_def_opt.subj_group_def = options.subj_group_def;
group_def_opt.subj_number = dataAve.subjNum;

group_def_out = run_subj_group_def_SYON( group_def_opt ); % mps 20220127 changing how we use subj group def

% Set group colors/idxing from group_def_out to remain consistent w/ other
% analysis code group defs. 
options.col_list{1} = group_def_out.use_colors_RGB{1};
options.col_list{2} = group_def_out.use_colors_RGB{2};
options.col_list{3} = group_def_out.use_colors_RGB{3};
grpIdx{1} = group_def_out.g1_idx;
grpIdx{2} = group_def_out.g2_idx;
grpIdx{3} = group_def_out.g3_idx;
grpLabel{1} = group_def_out.g1_label;
grpLabelShort{1} = group_def_out.g1_short;
grpLabel{2} = group_def_out.g2_label;
grpLabelShort{2} = group_def_out.g2_short;
grpLabel{3} = group_def_out.g3_label;
grpLabelShort{3} = group_def_out.g3_short;

% options.group_def = group_def_out;

options.grouping = zeros([1 numel(dataAve.subjNum)]);
options.grouping(grpIdx{1}) = 1;
options.grouping(grpIdx{2}) = 2;
options.grouping(grpIdx{3}) = 3;

x_labels = {[grpLabelShort{1} ', n=' num2str(sum(grpIdx{1}))],...
        [grpLabelShort{2} ', n=' num2str(sum(grpIdx{2}))],...
        [grpLabelShort{3} ', n=' num2str(sum(grpIdx{3}))]};

x_labels_exclude = {[grpLabelShort{1} ', n=' num2str(sum(grpIdx{1} & ~dataAve.excludeIndex))],...
        [grpLabelShort{2} ', n=' num2str(sum(grpIdx{2} & ~dataAve.excludeIndex))],...
        [grpLabelShort{3} ', n=' num2str(sum(grpIdx{3} & ~dataAve.excludeIndex))]};

%% Average across each group
% Ave / ste PSE
dataAve.groupAvePSE(1,:) = nanmean(dataAve.PSE(grpIdx{1} & ~dataAve.excludeIndex,:),1);
dataAve.groupAvePSE(2,:) = nanmean(dataAve.PSE(grpIdx{2} & ~dataAve.excludeIndex,:),1);
dataAve.groupAvePSE(3,:) = nanmean(dataAve.PSE(grpIdx{3} & ~dataAve.excludeIndex,:),1);
dataAve.groupStePSE(1,:) = nanstd(dataAve.PSE(grpIdx{1} & ~dataAve.excludeIndex,:),1) ./ sqrt(sum(grpIdx{1} & ~dataAve.excludeIndex));
dataAve.groupStePSE(2,:) = nanstd(dataAve.PSE(grpIdx{2} & ~dataAve.excludeIndex,:),1) ./ sqrt(sum(grpIdx{2} & ~dataAve.excludeIndex));
dataAve.groupStePSE(3,:) = nanstd(dataAve.PSE(grpIdx{3} & ~dataAve.excludeIndex,:),1) ./ sqrt(sum(grpIdx{3} & ~dataAve.excludeIndex));

% Ave / ste PSE Diff
dataAve.groupAveDiffPSE(1) = nanmean(dataAve.diffPSE(grpIdx{1} & ~dataAve.excludeIndex));
dataAve.groupAveDiffPSE(2) = nanmean(dataAve.diffPSE(grpIdx{2} & ~dataAve.excludeIndex));
dataAve.groupAveDiffPSE(3) = nanmean(dataAve.diffPSE(grpIdx{3} & ~dataAve.excludeIndex));
dataAve.groupSteDiffPSE(1) = nanstd(dataAve.diffPSE(grpIdx{1} & ~dataAve.excludeIndex)) ./ sqrt(sum(grpIdx{1} & ~dataAve.excludeIndex));
dataAve.groupSteDiffPSE(2) = nanstd(dataAve.diffPSE(grpIdx{2} & ~dataAve.excludeIndex)) ./ sqrt(sum(grpIdx{2} & ~dataAve.excludeIndex));
dataAve.groupSteDiffPSE(3) = nanstd(dataAve.diffPSE(grpIdx{3} & ~dataAve.excludeIndex)) ./ sqrt(sum(grpIdx{3} & ~dataAve.excludeIndex));

% Ave / ste catch accuracy
dataAve.groupAveCatch(1) = nanmean(dataAve.catchAveBlock(grpIdx{1}));
dataAve.groupAveCatch(2) = nanmean(dataAve.catchAveBlock(grpIdx{2}));
dataAve.groupAveCatch(3) = nanmean(dataAve.catchAveBlock(grpIdx{3}));
dataAve.groupSteCatch(1) = nanstd(dataAve.catchAveBlock(grpIdx{1})) ./ sqrt(sum(grpIdx{1}));
dataAve.groupSteCatch(2) = nanstd(dataAve.catchAveBlock(grpIdx{2})) ./ sqrt(sum(grpIdx{2}));
dataAve.groupSteCatch(3) = nanstd(dataAve.catchAveBlock(grpIdx{3})) ./ sqrt(sum(grpIdx{3}));
    

%% Do stats
% Take a t-test between the two groups (too few people in relatives group
% to do ANOVA I think...)
% Catch accuracy
% dataAve.stats.
statsRunIdx = [1 2; 1 3; 2 3];

% Catch accuracy
for iI=1:3   % For now, only really care about 1 3 (cont vs pwpp)
    for iJ=1:5    % For each condition {1: Larger-Background, 2: Larger-No Background,3: Smaller-Background, 4: Smaller-No Background, 5: Grand Average
        % Run 2KW between the three groups
        [dataAve.stats.catch.KW2.p(iI,iJ), dataAve.stats.catch.KW2.table{iI,iJ}, dataAve.stats.catch.KW2.stats{iI,iJ}] = ...
            kruskalwallis([dataAve.catch(options.grouping == statsRunIdx(iI,1),iJ)', dataAve.catch(options.grouping == statsRunIdx(iI,2),iJ)'],...
            [options.grouping(options.grouping == statsRunIdx(iI,1)) options.grouping(options.grouping == statsRunIdx(iI,2))], options.showStatsFig);

        % Run ttest
        [dataAve.stats.catch.ttest.sig(iI,iJ), dataAve.stats.catch.ttest.p(iI,iJ), ~, dataAve.stats.catch.ttest.stats{iI,iJ}] = ...
            ttest2(dataAve.catch(options.grouping==statsRunIdx(iI,1),iJ),dataAve.catch(options.grouping==statsRunIdx(iI,2),iJ));
    end
end

% Within each group: Hallway vs No Hallway
for iI=1:3   % For now, only really care about 1 3 (cont vs pwpp)
    %     % Run 2KW between the three groups
    %     [dataAve.stats.PSE_hallVsNoHall.KW2.p(iI), dataAve.stats.PSE_hallVsNoHall.KW2.table{iI}, dataAve.stats.PSE_hallVsNoHall.KW2.stats{iI}] = ...
    %         kruskalwallis([dataAve.PSE(options.grouping == iI & ~dataAve.excludeIndex,1)', dataAve.PSE(options.grouping == iI & ~dataAve.excludeIndex,2)'],...
    %         [ones([1 length(options.grouping(options.grouping == iI & ~dataAve.excludeIndex))]) ones([1 length(options.grouping(options.grouping == iI & ~dataAve.excludeIndex))])+1], options.showStatsFig);
    if options.norm_stats_data == 0
        % Run ttest
        [dataAve.stats.PSE_hallVsNoHall.ttest.sig(iI), dataAve.stats.PSE_hallVsNoHall.ttest.p(iI), ~, dataAve.stats.PSE_hallVsNoHall.ttest.stats{iI}] = ...
            ttest(dataAve.PSE(options.grouping==iI & ~dataAve.excludeIndex,1),dataAve.PSE(options.grouping==iI & ~dataAve.excludeIndex,2));
    elseif options.norm_stats_data == 1
        [dataAve.stats.PSE_hallVsNoHall.ttest.sig(iI), dataAve.stats.PSE_hallVsNoHall.ttest.p(iI), ~, dataAve.stats.PSE_hallVsNoHall.ttest.stats{iI}] = ...
            ttest(dataAve.PSE_norm(options.grouping==iI & ~dataAve.excludeIndex,1),dataAve.PSE_norm(options.grouping==iI & ~dataAve.excludeIndex,2));
    end
end

% Across Group: PSE values - No Hallway, Hallway
for iI=1:3   % For now, only really care about 1 3 (cont vs pwpp)
    for iJ=1:2    % For each condition (1: no hallway, 2: hallway)
        % Run 2KW between the three groups
        [dataAve.stats.PSE.KW2.p(iI,iJ), dataAve.stats.PSE.KW2.table{iI,iJ}, dataAve.stats.PSE.KW2.stats{iI,iJ}] = ...
            kruskalwallis([dataAve.PSE(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex,iJ)', dataAve.PSE(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex,iJ)'],...
            [options.grouping(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex) options.grouping(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex)], options.showStatsFig);

        % Run ttest
        [dataAve.stats.PSE.ttest.sig(iI,iJ), dataAve.stats.PSE.ttest.p(iI,iJ), ~, dataAve.stats.PSE.ttest.stats{iI,iJ}] = ...
            ttest2(dataAve.PSE(options.grouping==statsRunIdx(iI,1) & ~dataAve.excludeIndex,iJ),dataAve.PSE(options.grouping==statsRunIdx(iI,2) & ~dataAve.excludeIndex,iJ));
    end
end

% Across Group: PSE values - Difference (Hall - No Hall)
for iI=1:3   % For now, only really care about 1 3 (cont vs pwpp)
    if options.norm_stats_data == 0
        % Run 2KW between the three groups
        [dataAve.stats.diffPSE.KW2.p(iI), dataAve.stats.diffPSE.KW2.table{iI}, dataAve.stats.diffPSE.KW2.stats{iI}] = ...
            kruskalwallis([dataAve.diffPSE(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex), dataAve.diffPSE(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex)],...
            [options.grouping(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex) options.grouping(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex)], options.showStatsFig);

        % Run ttest
        [dataAve.stats.diffPSE.ttest.sig(iI), dataAve.stats.diffPSE.ttest.p(iI), ~, dataAve.stats.diffPSE.ttest.stats{iI}] = ...
            ttest2(dataAve.diffPSE(options.grouping==statsRunIdx(iI,1) & ~dataAve.excludeIndex),dataAve.diffPSE(options.grouping==statsRunIdx(iI,2) & ~dataAve.excludeIndex));

    elseif options.norm_stats_data == 1
        % Run 2KW between the three groups
        [dataAve.stats.diffPSE.KW2.p(iI), dataAve.stats.diffPSE.KW2.table{iI}, dataAve.stats.diffPSE.KW2.stats{iI}] = ...
            kruskalwallis([dataAve.diffPSE_norm(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex), dataAve.diffPSE_norm(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex)],...
            [options.grouping(options.grouping == statsRunIdx(iI,1) & ~dataAve.excludeIndex) options.grouping(options.grouping == statsRunIdx(iI,2) & ~dataAve.excludeIndex)], options.showStatsFig);

        % Run ttest
        [dataAve.stats.diffPSE.ttest.sig(iI), dataAve.stats.diffPSE.ttest.p(iI), ~, dataAve.stats.diffPSE.ttest.stats{iI}] = ...
            ttest2(dataAve.diffPSE_norm(options.grouping==statsRunIdx(iI,1) & ~dataAve.excludeIndex),dataAve.diffPSE_norm(options.grouping==statsRunIdx(iI,2) & ~dataAve.excludeIndex));
    end
end

%% Plot catch trial accuracy
options.beePointSize = 13;   % Size of the bee points in figures
options.PSEGraphTitle = {'Average PSE'};
options.catchLabel = {'Larger: Hall','Larger: No Hall','Smaller: Hall','Smaller: No Hall','Average'};
options.catchGraphTitle = {'Average Catch'};
options.type_labels = {'Hall','No Hall'};

if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.sizePSE.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.sizePSE.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.sizePSE.figSize = [0 0 ...
        figSize.sizePSE.aspectRatio];   % Size/postion of fig
    addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread'))

    % Average catch accuracy
    plotTitles = {'Larger: Hall','Larger: No Hall','Smaller: Hall','Smaller: No Hall','Grand Average'};
    subPlotIndex = {1,2,3,4,[5:6]};
    for iT = 1:5
        subplot(3,2,subPlotIndex{iT})
        hold on

        % Beeswarm
        x_val = [1 2 3];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        beePlot = plotSpread({dataAve.catch(grpIdx{1},iT),dataAve.catch(grpIdx{2},iT),dataAve.catch(grpIdx{3},iT)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb{iT} = boxplot(dataAve.catch(options.grouping~=0,iT),options.grouping(options.grouping~=0));
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',x_labels,'fontsize',axisLabelFontSize)
        set(hb{iT},'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        for iHB = 1:size(hb{iT},2)
            set(hb2((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'Color',options.col_list{4-iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb{iT},2)
            set(hbCurr((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hbCurr((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
        end

        % Plot acc cutoff line
        if iT == 5
            plot([0 4],[options.accCutoff options.accCutoff],'k--')
        end

        % Plot significance
        max_Y = 105;
        if options.plot_stats == 1
            if options.subj_group_def == 1
                % Plot 2-K-W for controls vs patients
                text(2.5,max_Y*.2,...
                    ['X2(' sprintf('%d',dataAve.stats.catch.KW2.table{2,iT}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{2,iT}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{2,iT}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs patients
                text(2.5,max_Y*.1,...
                    ['t(' sprintf('%d',dataAve.stats.catch.ttest.stats{2,iT}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.stats{2,iT}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.p(2,iT))],...
                    'fontsize',statsFontSize);
            elseif options.subj_group_def == 2
                % Plot 2-K-W for controls vs SZ
                text(2.5,max_Y*.4,...
                    ['X2(' sprintf('%d',dataAve.stats.catch.KW2.table{1,iT}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{1,iT}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{1,iT}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs SZ
                text(2.5,max_Y*.3,...
                    ['t(' sprintf('%d',dataAve.stats.catch.ttest.stats{1,iT}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.stats{1,iT}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.p(1,iT))],...
                    'fontsize',statsFontSize);

                % Plot 2-K-W for controls vs BP
                text(2.5,max_Y*.2,...
                    ['X2(' sprintf('%d',dataAve.stats.catch.KW2.table{2,iT}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{2,iT}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.KW2.table{2,iT}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs BP
                text(2.5,max_Y*.1,...
                    ['t(' sprintf('%d',dataAve.stats.catch.ttest.stats{2,iT}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.stats{2,iT}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.catch.ttest.p(2,iT))],...
                    'fontsize',statsFontSize);
            end
        end

        title(plotTitles{iT},'fontsize',titleFontSize)
        box off
        ylabel('Accuracy (% correct)','fontsize',axisTitleFontSize)
        set(gca,'ylim',[0 105])
        set(gca,'XColor','k','YColor','k')
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.sizePSE.figSize,'color','w')
end

%% Plot the PSE values for hallway vs no hallway for each group
if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.sizePSE.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.sizePSE.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.sizePSE.figSize = [0 0 ...
        figSize.sizePSE.aspectRatio];   % Size/postion of fig
    addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread'))
    for iSubj = 1:3   % 3 groups
        subplot(1,3,iSubj)
        hold on

        % Beeswarm
        x_val = [1 2];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        beePlot = plotSpread({dataAve.PSE(grpIdx{iSubj} & ~dataAve.excludeIndex,1),dataAve.PSE(grpIdx{iSubj} & ~dataAve.excludeIndex,2)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb{iSubj} = boxplot([dataAve.PSE(grpIdx{iSubj} & ~dataAve.excludeIndex,1),dataAve.PSE(grpIdx{iSubj} & ~dataAve.excludeIndex,2)],...
            [options.grouping(grpIdx{iSubj} & ~dataAve.excludeIndex),options.grouping(grpIdx{iSubj} & ~dataAve.excludeIndex)+1]);
        pause(0.5)
        set(gca,'XTick',1:2,'XTickLabel',{'Hallway','No Hallway'},'fontsize',axisLabelFontSize)
        set(hb{iSubj},'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        for iHB = 1:size(hb{iSubj},2)
            set(hb2((iHB)+2:2:end),'color',options.col_list{iSubj})
            set(hb2((iHB)+2:2:end),'MarkerEdgeColor',options.col_list{iSubj})
            set(hb3((iHB)+2:2:end),'MarkerEdgeColor',options.col_list{iSubj})
            set(hb3((iHB)+2:2:end),'MarkerFaceColor',options.col_list{iSubj})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb{iSubj},2)
            set(hbCurr((iHB)+2:2:end),'color',options.col_list{iSubj})
            set(hbCurr((iHB)+2:2:end),'MarkerEdgeColor',options.col_list{iSubj})
        end

        % Plot significance
        max_Y = 100;
        if options.plot_stats == 1
            % Plot ttest for controls vs patients
            if dataAve.stats.PSE_hallVsNoHall.ttest.p(iSubj) < 0.0001
                text(1.5,(max_Y*.8)+50,...
                    ['t(' sprintf('%d',dataAve.stats.PSE_hallVsNoHall.ttest.stats{iSubj}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE_hallVsNoHall.ttest.stats{iSubj}.tstat) ', p < 0.0001'],...
                    'fontsize',statsFontSize);
            else
                text(1.5,(max_Y*.8)+50,...
                    ['t(' sprintf('%d',dataAve.stats.PSE_hallVsNoHall.ttest.stats{iSubj}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE_hallVsNoHall.ttest.stats{iSubj}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE_hallVsNoHall.ttest.p(iSubj))],...
                    'fontsize',statsFontSize);
            end
        end

        title(x_labels_exclude{iSubj},'fontsize',titleFontSize)
        box off
        if iSubj == 1
            ylabel('Percieved Size (% of Ref)','fontsize',axisTitleFontSize)
        end
        set(gca,'ylim',[50 150])
        set(gca,'XColor','k','YColor','k')
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.sizePSE.figSize,'color','w')
end

%% Plot the PSE values (for each condition) across groups
if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.sizePSE.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.sizePSE.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.sizePSE.figSize = [0 0 ...
        figSize.sizePSE.aspectRatio];   % Size/postion of fig
    addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread'))
    for iSubj = 1:2   % W/ and w/out hallways present
        subplot(1,2,iSubj)
        hold on

        % Beeswarm
        x_val = [1 2 3];
        set(gca,'XColor','k','YColor','k')
        bee_bin_width = .1;
        bee_spread_width = .5;
        beePlot = plotSpread({dataAve.PSE(grpIdx{1} & ~dataAve.excludeIndex,iSubj),dataAve.PSE(grpIdx{2} & ~dataAve.excludeIndex,iSubj),dataAve.PSE(grpIdx{3} & ~dataAve.excludeIndex,iSubj)},...
            'binWidth', bee_bin_width,...
            'distributionColors', {[.8 .8 .8]},...
            'xValues', x_val,...
            'spreadWidth', bee_spread_width);
        set(beePlot{1},'MarkerSize',options.beePointSize)
        hold on

        % Boxplots
        hb{iSubj} = boxplot(dataAve.PSE(options.grouping~=0 & ~dataAve.excludeIndex,iSubj),...
            options.grouping(options.grouping~=0 & ~dataAve.excludeIndex));
        pause(0.5)
        set(gca,'XTick',1:3,'XTickLabel',x_labels_exclude,'fontsize',axisLabelFontSize)
        set(hb{iSubj},'linewidth',2)
        hb2 = findobj(gca,'type','line');
        hb3 = findobj(gca,'type','Outliers');
        for iHB = 1:size(hb{iSubj},2)
            set(hb2((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb2((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'MarkerFaceColor',options.col_list{4-iHB})
            set(hb3((iHB)+3:3:end),'Color',options.col_list{4-iHB})
        end
        hbCurr = findobj(gca,'type','line');
        for iHB = 1:size(hb{iSubj},2)
            set(hbCurr((iHB)+3:3:end),'color',options.col_list{4-iHB})
            set(hbCurr((iHB)+3:3:end),'MarkerEdgeColor',options.col_list{4-iHB})
        end

        % Plot significance
        max_Y = 100;
        if options.plot_stats == 1
            if options.subj_group_def == 1
                % Plot 2-K-W for controls vs patients
                text(2.5,(max_Y*.9)+50,...
                    ['X2(' sprintf('%d',dataAve.stats.PSE.KW2.table{2,iSubj}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{2,iSubj}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{2,iSubj}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs patients
                text(2.5,(max_Y*.8)+50,...
                    ['t(' sprintf('%d',dataAve.stats.PSE.ttest.stats{2,iSubj}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.stats{2,iSubj}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.p(2,iSubj))],...
                    'fontsize',statsFontSize);
            elseif options.subj_group_def == 2
                % Plot 2-K-W for controls vs SZ
                text(2.5,(max_Y*.9)+50,...
                    ['X2(' sprintf('%d',dataAve.stats.PSE.KW2.table{2,iSubj}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{2,iSubj}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{2,iSubj}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs SZ
                text(2.5,(max_Y*.8)+50,...
                    ['t(' sprintf('%d',dataAve.stats.PSE.ttest.stats{1,iSubj}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.stats{1,iSubj}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.p(1,iSubj))],...
                    'fontsize',statsFontSize);
                
                % Plot 2-K-W for controls vs BP
                text(2.5,(max_Y*.7)+50,...
                    ['X2(' sprintf('%d',dataAve.stats.PSE.KW2.table{1,iSubj}{2,3})  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{1,iSubj}{2,5}) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.KW2.table{1,iSubj}{2,6})],...
                    'fontsize',statsFontSize);

                % Plot ttest for controls vs BP
                text(2.5,(max_Y*.6)+50,...
                    ['t(' sprintf('%d',dataAve.stats.PSE.ttest.stats{2,iSubj}.df)  ') = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.stats{2,iSubj}.tstat) ', p = ' ...
                    sprintf('%1.3f',dataAve.stats.PSE.ttest.p(2,iSubj))],...
                    'fontsize',statsFontSize);
            end
        end

        title(options.type_labels{iSubj},'fontsize',titleFontSize)
        box off
        if iSubj == 1
            ylabel('Percieved Size (% of Ref)','fontsize',axisTitleFontSize)
        end
        set(gca,'ylim',[50 150])
        set(gca,'XColor','k','YColor','k')
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.sizePSE.figSize,'color','w')
end

%% Plot PSE differences (Hall minus No Hall)
if options.displayFigs
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.sizePSE.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.sizePSE.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.sizePSE.figSize = [0 0 ...
        figSize.sizePSE.aspectRatio];   % Size/postion of fig
    addpath(genpath('/home/shaw-raid/matlab_tools/mpsCode/plotSpread'))

    hold on

    % Beeswarm
    x_val = [1 2 3];
    set(gca,'XColor','k','YColor','k')
    bee_bin_width = .1;
    bee_spread_width = .5;
    beePlot = plotSpread({dataAve.diffPSE(grpIdx{1} & ~dataAve.excludeIndex),dataAve.diffPSE(grpIdx{2} & ~dataAve.excludeIndex),dataAve.diffPSE(grpIdx{3} & ~dataAve.excludeIndex)},...
        'binWidth', bee_bin_width,...
        'distributionColors', {[.8 .8 .8]},...
        'xValues', x_val,...
        'spreadWidth', bee_spread_width);
    set(beePlot{1},'MarkerSize',options.beePointSize)
    hold on

    % Boxplots
    hb = boxplot(dataAve.diffPSE(options.grouping~=0 & ~dataAve.excludeIndex),...
        options.grouping(options.grouping~=0 & ~dataAve.excludeIndex));
    pause(0.5)
    set(gca,'XTick',1:3,'XTickLabel',x_labels_exclude,'fontsize',axisLabelFontSize)
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

    max_Y = 50;
    if options.plot_stats == 1
        if options.subj_group_def == 1
            % Plot 2-K-W for controls vs patients
            text(2.5,max_Y*.9,...
                ['X2(' sprintf('%d',dataAve.stats.diffPSE.KW2.table{2}{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{2}{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{2}{2,6})],...
                'fontsize',statsFontSize);

            % Plot ttest for controls vs patients
            text(2.5,max_Y*.8,...
                ['t(' sprintf('%d',dataAve.stats.diffPSE.ttest.stats{2}.df)  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.stats{2}.tstat) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.p(2))],...
                'fontsize',statsFontSize);
        elseif options.subj_group_def == 2
            % Plot 2-K-W for controls vs SZ
            text(2.5,max_Y*.9,...
                ['X2(' sprintf('%d',dataAve.stats.diffPSE.KW2.table{2}{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{2}{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{2}{2,6})],...
                'fontsize',statsFontSize);

            % Plot ttest for controls vs SZ
            text(2.5,max_Y*.8,...
                ['t(' sprintf('%d',dataAve.stats.diffPSE.ttest.stats{1}.df)  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.stats{1}.tstat) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.p(1))],...
                'fontsize',statsFontSize);

            % Plot 2-K-W for controls vs BP
            text(2.5,max_Y*.7,...
                ['X2(' sprintf('%d',dataAve.stats.diffPSE.KW2.table{1}{2,3})  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{1}{2,5}) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.KW2.table{1}{2,6})],...
                'fontsize',statsFontSize);

            % Plot ttest for controls vs BP
            text(2.5,max_Y*.6,...
                ['t(' sprintf('%d',dataAve.stats.diffPSE.ttest.stats{2}.df)  ') = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.stats{2}.tstat) ', p = ' ...
                sprintf('%1.3f',dataAve.stats.diffPSE.ttest.p(2))],...
                'fontsize',statsFontSize);
        end
    end

    title([options.type_labels{1} ' - ' options.type_labels{2}],'fontsize',titleFontSize)
    box off
    ylabel('Difference in Percieved Size (% of Ref)','fontsize',axisTitleFontSize)
    set(gca,'ylim',[-10 50])
    set(gca,'XColor','k','YColor','k')

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.sizePSE.figSize,'color','w')
end

%% Symptom correlations - HM/HHY 20240401

% create subj_number list (required by get_syon_symptoms.m), minus exclusions
% subj_number = dataAve.subjNum(~dataAve.excludeIndex); 
subj_number = dataAve.subjNum; 

% create date_number list (required by get_syon_symptoms.m), minus exclusions
for iS = 1:length(datecode) % first, convert datecodes to datenums
    subj_datenum{iS} = datenum(datestr(datenum(datecode(iS),'mmddyy'),'mm/dd/yyyy')); 
end
date_restruct = cell2mat(subj_datenum);
% subj_date = date_restruct(~dataAve.excludeIndex); 
subj_date = date_restruct; 

if ~isempty(options.symptom_measure)
    
    symp_opt = [];
    symp_opt.subj_number = subj_number; 
    symp_opt.date_number = subj_date; 
    symp_opt.symptom_measure = options.symptom_measure;
    symp_opt.symp_date_limit = options.symp_date_limit;
    
    symp_data = get_syon_symptoms(symp_opt);
    
    clin_list = symp_data.clin_list;
    clin_time = symp_data.clin_time;
    clin_data_label = symp_data.clin_data_label;
    
    % Create list of PSE diffs to correlate
%     use_grp1_idx = (options.grouping == 1);
%     use_grp2_idx = (options.grouping == 2);
%     use_grp3_idx = (options.grouping == 3);

    clin_1 = (clin_list(options.grouping == 1 & ~dataAve.excludeIndex))';
    clin_2 = (clin_list(options.grouping == 2 & ~dataAve.excludeIndex))';
    clin_3 = (clin_list(options.grouping == 3 & ~dataAve.excludeIndex))';
    
    clin_allgroup = [clin_1 clin_2 clin_3];
    
    corr_clin = (clin_allgroup)';
    
    corr_1 = dataAve.diffPSE(options.grouping == 1 & ~dataAve.excludeIndex);
    corr_2 = dataAve.diffPSE(options.grouping == 2 & ~dataAve.excludeIndex);
    corr_3 = dataAve.diffPSE(options.grouping == 3 & ~dataAve.excludeIndex);
    
    corr_allgroup = [corr_1 corr_2 corr_3];
    
    corr_diffPSE = (corr_allgroup)';
    
    %corr_clin = clin_list;
    
    % 20240406 At this point, corr_clin is 71x1 and corr_diffPSE is 65x1
    % (doesn't contain relatives)...
    
    
    corr_idx = ~isnan(corr_clin) & ~isnan(corr_diffPSE);
    
    [r_val, p_val] = corr (corr_clin(corr_idx), corr_diffPSE(corr_idx),...
        'type', 'Spearman');

    dataAve.stats.symptom_corr.r = r_val;
    dataAve.stats.symptom_corr.p = p_val;
    dataAve.stats.symptom_corr.df = sum(corr_idx)-2;
    dataAve.stats.symptom_corr.type = 'Spearman';
    
if options.displayFigs == 1  
        
        % For threshold
        figure; hold on
        
        [poly_fit] = polyfit(corr_clin(corr_idx), corr_diffPSE(corr_idx), 1);
        
        fit_x = [min(corr_clin(corr_idx)) max(corr_clin(corr_idx))];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);
        y_range = [min(corr_diffPSE(corr_idx)) max(corr_diffPSE(corr_idx))];
        plot(fit_x,fit_y,'k-','linewidth',2)
        
        plot(corr_clin(corr_idx), corr_diffPSE(corr_idx),'ko',...
            'linewidth',2,'MarkerSize',8,'MarkerFaceColor', 'r')
        
        xlabel(clin_data_label,'color','k')
        ylabel('Difference in PSE (%)','color','k')
        
        range_x = max(corr_clin(corr_idx)) - min(corr_clin(corr_idx));
        range_y = max(corr_diffPSE(corr_idx)) - min(corr_diffPSE(corr_idx));
        text(max(corr_clin(corr_idx))-range_x*.2,max(corr_diffPSE(corr_idx)),...
            ['n = ' num2str(numel(corr_clin(corr_idx)))],'fontsize',18)
        text(max(corr_clin(corr_idx))-range_x*.2,max(corr_diffPSE(corr_idx))-range_y*.225,...
            ['r = ' num2str(round(100*r_val)/100)],'fontsize',18)
        text(max(corr_clin(corr_idx))-range_x*.2,max(corr_diffPSE(corr_idx))-range_y*.4,...
            ['p = ' num2str(round(100*p_val)/100)],'fontsize',18)
        
        set(gcf,'color','w','POS',[357 375 560 560])
        set(gca,'FontSize',18,'XColor','k','YColor','k')
        
        x_span = fit_x(2) - fit_x(1);
        y_span = y_range(2) - y_range(1);
        axis([fit_x(1)-0.1*x_span fit_x(2)+0.1*x_span ...
            y_range(1)-0.05*y_span y_range(2)+0.1*y_span]);
        
end
end