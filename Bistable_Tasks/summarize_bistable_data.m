function dataAve = summarize_bistable_data(options)
% usage: dataAve = analyze_SFM_data(options)
%
% KWK - 20230206

%%
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'top_dir')
    %     options.top_dir = '/home/shaw-raid1/data/psychophysics/SYON.git/Bistable_Tasks/';
        options.top_dir_master = 'E:\GitRepos\SYON.git\Bistable_Tasks\';
%     options.top_dir = 'C:\GitRepos\SYON.git\Bistable_Tasks\';
end
if ~isfield(options,'excludeRedcap')
    options.excludeRedcap = 1; % exclude subjects based on control task performance, 0 = no, 1 = yes
%     addpath(genpath('/home/shaw-raid1/matlab_tools/COP_analysis.git')) % Add path for redcap excludion function (in COP_analysis.git)
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 0;   % Plot figs in individual task scripts; 1 = on, 0 = off
end
if ~isfield(options,'displaySubjFigs')
    options.displaySubjFigs = 0; 
end
if ~isfield(options,'displaySummaryFigs')
    options.displaySummaryFigs = 1;   % Plot figs in this script
end
if ~isfield(options,'subj_group_def')
    options.subj_group_def = 1;
end
if ~isfield(options,'normalize')
    options.normalize = 1;   % Normalize the Hz data being analyzed (1=log; 0=non normalized)
end
if ~isfield(options,'normalize_plot')
    options.normalize_plot = 0;   % Normalize the Hz data being plotted (1=log; 0=non normalized)
end
if ~isfield(options,'showStatsFig')
    options.showStatsFig = 'off';   % Plot stats figs
end
if ~isfield(options,'plot_stats')
    options.plot_stats = 1;   % Plot stats on figures
end
if ~isfield(options,'corr_type')
    options.corr_type = 'Spearman';   % Type of correlation we want to use
end
if ~isfield(options,'includeRelatives')
    options.includeRelatives = 1;   % Include relatives (1) or not (0)
end
if ~isfield(options,'makeDemogTable')
    options.makeDemogTable = 1;   % Get demographics info (1) or not (0)
end

% If we're not looking at all 3 groups, set includeRelatives to 1
if options.subj_group_def ~= 1
    options.includeRelatives = 0;
end

% 
% addpath(genpath('/labs/srslab/data_main/SYON.git/Functions/'))
% options.curDur = '/labs/srslab/data_main/SYON.git/Bistable_Tasks/';
% 
% addpath(genpath('/home/shaw-raid1/data/psychophysics/SYON.git/Functions/'))
% options.curDur = '/home/shaw-raid1/data/psychophysics/SYON.git/Bistable_Tasks/';

addpath(genpath('E:\GitRepos\SYON.git\Functions'))
options.curDur = 'E:\GitRepos\SYON.git\Bistable_Tasks\';
options.sfmDir = 'E:\GitRepos\SYON.git\Bistable_Tasks\SFM_Task\';
options.bmDir = 'E:\GitRepos\SYON.git\Bistable_Tasks\BioMotion_Task\Behavioral_Task\Data';
options.brDir = 'E:\GitRepos\SYON.git\Bistable_Tasks\BinoRiv_Task\Behavioral_Task\Data\';

% addpath(genpath('C:\GitRepos\SYON.git\Functions'))
% options.curDur = 'C:\GitRepos\SYON.git\Bistable_Tasks\';

%% Calculate the switch rates / percept durations for each bistable task
% SFM
cd(options.sfmDir)
dataAve.SFM = analyze_SFM_data(options);

% Biological motion
cd(options.bmDir)
dataAve.BM = analyze_BM_data(options);

% Binocular rivalry
cd(options.brDir)
dataAve.BR = analyze_BR_data(options);

cd(options.curDur)

%% Look at demographic data for all subjects included (not just subj across all tasks)
% Create an index for subjects that are included across all data sets
dataAve.subjNum{1} = dataAve.SFM.B.subjNum;
dataAve.subjNum{2} = dataAve.BM.B.subjNum;
dataAve.subjNum{3} = dataAve.BR.B.subjNum;
[dataAve.demog.allSubjNum,uniqueHolder,~] = unique([dataAve.SFM.B.subjNum dataAve.BM.B.subjNum dataAve.BR.B.subjNum]);

dataAve.dateNum{1} = dataAve.SFM.B.dateNum;
dataAve.dateNum{2} = dataAve.BM.B.dateNum;
dataAve.dateNum{3} = dataAve.BR.B.dateNum;
dateHolder = [dataAve.SFM.B.dateNum dataAve.BM.B.dateNum dataAve.BR.B.dateNum];
dataAve.demog.allSubjDate = dateHolder(uniqueHolder);
clear uniqueHolder dateHolder

% Generate demographics table
if options.makeDemogTable == 1
    demogOptions.subj_number = dataAve.demog.allSubjNum;
    demogOptions.date_number = dataAve.demog.allSubjDate;
    demogOptions.subj_group_def = options.subj_group_def;
    
    demogOptions = make_syon_methods_table(demogOptions);
end


%% Grab the block averaged Hz and pur dur data across tasks for each subject

% Find common subjects across all 3 groups
dataAve.subjIdx{1} = zeros([length(dataAve.SFM.B.subjNum) 1]);
dataAve.subjIdx{2} = zeros([length(dataAve.BM.B.subjNum) 1]);
dataAve.subjIdx{3} = zeros([length(dataAve.BR.B.subjNum) 1]);
counter = 0;
for iSubj = 1:length(subjNumCombined)
    if sum(subjNumCombined(iSubj)==dataAve.SFM.B.subjNum)==1 & ...
            sum(subjNumCombined(iSubj)==dataAve.BM.B.subjNum)==1 & ...
            sum(subjNumCombined(iSubj)==dataAve.BR.B.subjNum)==1
        dataAve.subjIdx{1}(subjNumCombined(iSubj)==dataAve.SFM.B.subjNum) = 1;   % SFM
        dataAve.subjIdx{2}(subjNumCombined(iSubj)==dataAve.BM.B.subjNum) = 1;   % BM
        dataAve.subjIdx{3}(subjNumCombined(iSubj)==dataAve.BR.B.subjNum) = 1;   % BR

        % Make combined subject array
        counter = counter+1;
        dataAve.subjIdxCombined(counter) = subjNumCombined(iSubj);
    end
end

% Grab the Hz and pur dur data
for iSubj = 1:length(dataAve.subjIdxCombined)
    dataAve.switchRate(iSubj,1,:) = dataAve.SFM.B.switchRate(dataAve.SFM.B.subjNum==dataAve.subjIdxCombined(iSubj),:);
    dataAve.switchRate(iSubj,2,:) = dataAve.BM.B.switchRate(dataAve.BM.B.subjNum==dataAve.subjIdxCombined(iSubj),:);
    dataAve.switchRate(iSubj,3,:) = dataAve.BR.B.switchRate(dataAve.BR.B.subjNum==dataAve.subjIdxCombined(iSubj),:);

    dataAve.perDur(iSubj,1,:) = dataAve.SFM.B.perDurAve(dataAve.SFM.B.subjNum==dataAve.subjIdxCombined(iSubj),:);
    dataAve.perDur(iSubj,2,:) = dataAve.BM.B.perDurAve(dataAve.BM.B.subjNum==dataAve.subjIdxCombined(iSubj),:);
    dataAve.perDur(iSubj,3,:) = dataAve.BR.B.perDurAve(dataAve.BR.B.subjNum==dataAve.subjIdxCombined(iSubj),:);
end

% Average across blocks
dataAve.switchRateAve = nanmean(dataAve.switchRate,3);
dataAve.perDurAve = nanmean(dataAve.perDur,3);



%% Define groups
% 1 = controls, relatives, probands; 2 = controls, SZ, BP
group_def_opt = [];
group_def_opt.subj_group_def = options.subj_group_def;
group_def_opt.subj_number = dataAve.subjIdxCombined;

group_def_out = run_subj_group_def_SYON( group_def_opt ); % mps 20220127 changing how we use subj group def

% Set group colors/idxing from group_def_out to remain consistent w/ other
% analysis code group defs.
options.col_list{1} = group_def_out.use_colors_RGB{1};
options.col_list{2} = group_def_out.use_colors_RGB{2};
options.col_list{3} = group_def_out.use_colors_RGB{3};
options.grpIdx{1} = group_def_out.g1_idx;
options.grpIdx{2} = group_def_out.g2_idx;
options.grpIdx{3} = group_def_out.g3_idx;
options.grpLabel{1} = group_def_out.g1_label;
options.grpLabelShort{1} = group_def_out.g1_short;
options.grpLabel{2} = group_def_out.g2_label;
options.grpLabelShort{2} = group_def_out.g2_short;
options.grpLabel{3} = group_def_out.g3_label;
options.grpLabelShort{3} = group_def_out.g3_short;

dataAve.group_def = group_def_out;
clear group_def_out

dataAve.grouping = zeros([1 numel(dataAve.subjNum)]);
dataAve.grouping(options.grpIdx{1}) = 1;
dataAve.grouping(options.grpIdx{2}) = 2;
dataAve.grouping(options.grpIdx{3}) = 3;

options.x_labels = {[options.grpLabelShort{1} ', n=' num2str(sum(options.grpIdx{1}))],...
    [options.grpLabelShort{2} ', n=' num2str(sum(options.grpIdx{2}))],...
    [options.grpLabelShort{3} ', n=' num2str(sum(options.grpIdx{3}))]};


%% Correlate the data across tasks
corrGroups = {[1 1] [1 2] [1 3];...
    [2 1] [2 2] [2 3];...
    [3 1] [3 2] [3 3]};
options.taskLabels = {'SFM','BM','BR'};


if options.subj_group_def == 1
    %% Do for all groups
    for iCorrs1 = 1:size(corrGroups,1)
        for iCorrs2 = 1:size(corrGroups,2)
            %% Correlate for all subjects
            [dataAve.stats.corrs.allSubj.r{iCorrs1,iCorrs2}, dataAve.stats.corrs.allSubj.p{iCorrs1,iCorrs2}] = ...
                corr(dataAve.switchRateAve(dataAve.grouping~=0,corrGroups{iCorrs1,iCorrs2}(1)), ...
                dataAve.switchRateAve(dataAve.grouping~=0,corrGroups{iCorrs1,iCorrs2}(2)), 'type', options.corr_type);
            
            %% Correlate for all PwPP
            [dataAve.stats.corrs.PwPP.r{iCorrs1,iCorrs2}, dataAve.stats.corrs.PwPP.p{iCorrs1,iCorrs2}] = ...
                corr(dataAve.switchRateAve(dataAve.grouping==3,corrGroups{iCorrs1,iCorrs2}(1)), ...
                dataAve.switchRateAve(dataAve.grouping==3,corrGroups{iCorrs1,iCorrs2}(2)), 'type', options.corr_type);

            %% Correlate for all controls
            [dataAve.stats.corrs.cont.r{iCorrs1,iCorrs2}, dataAve.stats.corrs.cont.p{iCorrs1,iCorrs2}] = ...
                corr(dataAve.switchRateAve(dataAve.grouping==1,corrGroups{iCorrs1,iCorrs2}(1)), ...
                dataAve.switchRateAve(dataAve.grouping==1,corrGroups{iCorrs1,iCorrs2}(2)), 'type', options.corr_type);
        end
    end

    %% Plot all subjects
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRateCorrs.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRateCorrs.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRateCorrs.figSize = [0 0 ...
        figSize.switchRateCorrs.aspectRatio];   % Size/postion of fig

    % Plot the heatmap
    subplot(4,3,1:9)
    imagesc(cell2mat(dataAve.stats.corrs.allSubj.r))
    hold on
    set(gca,'XTick',[1 2 3],'XTickLabel',options.taskLabels,...
        'YTick',[1 2 3],'YTickLabel',options.taskLabels,...
        'YDir','reverse','fontsize',axisLabelFontSize,...
        'clim',[-1 1]);

    %     % Change color of axis labels to match group colors
    %     % Y labels
    %     % get the current tick labels
    %     ticklabels = get(gca,'YTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'YTickLabel', ticklabels_new);
    %     % X labels
    %     clear ticklabels ticklabels_new
    %     % get the current tick labels
    %     ticklabels = get(gca,'XTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'XTickLabel', ticklabels_new);

    colorbar

    % Plot the p values in their respective squares
    if options.plot_stats == 1
        for iI = 1:3
            for iJ = 1:3
                text(iI-.1,iJ-.05,sprintf('%s%1.2f%s','r = ',dataAve.stats.corrs.allSubj.r{iI,iJ},','));
                text(iI-.1,iJ+.05,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.allSubj.p{iI,iJ}));
            end
        end
    end

    title(sprintf('%s%d%s','Switch Rate Correlations (All Subjects=',sum(dataAve.grouping~=0),')'),'fontsize',titleFontSize)
    box off
    set(gca,'XColor','k','YColor','k')


    % Plot individual task scatterplots
    scatterGroups = [1 2; 1 3; 2 3];
    for iScatter = 1:size(scatterGroups,1)
        % Calculate trend line
        data1 = dataAve.switchRateAve(:,scatterGroups(iScatter,1),:);
        data2 = dataAve.switchRateAve(:,scatterGroups(iScatter,2),:);
        [poly_fit] = polyfit(data1,data2,1);
        fit_x = [min(data1) max(data1)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);

        % Plot
        subplot(4,3,9+iScatter)
        % Controls
        scatter(data1(dataAve.grouping==1), data2(dataAve.grouping==1),[],options.col_list{1})
        hold on
        % Relatives
        scatter(data1(dataAve.grouping==2), data2(dataAve.grouping==2),[],options.col_list{2})
        % PwPP
        scatter(data1(dataAve.grouping==3), data2(dataAve.grouping==3),[],options.col_list{3})

        % Plot fit line
        plot(fit_x,fit_y,'k-','LineWidth',2)

        % Plot correlation
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.1,sprintf('%s%1.3f%s','r = ',dataAve.stats.corrs.allSubj.r{scatterGroups(iScatter,1),scatterGroups(iScatter,2)},','));
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.2,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.allSubj.p{scatterGroups(iScatter,1),scatterGroups(iScatter,2)}));

        title(sprintf('%s%s%s',options.taskLabels{scatterGroups(iScatter,1)},' vs ',options.taskLabels{scatterGroups(iScatter,2)}))

        set(gca,'xlim',[0 max(data1)],'ylim',[0 max(data2)])
        xlabel(options.taskLabels{scatterGroups(iScatter,1)})
        ylabel(options.taskLabels{scatterGroups(iScatter,2)})
        box off
        set(gca,'XColor','k','YColor','k')

        clear data1 data2 poly_fit fit_x fit_y
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRateCorrs.figSize,'color','w')


    %% Plot PwPP
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRateCorrs.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRateCorrs.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRateCorrs.figSize = [0 0 ...
        figSize.switchRateCorrs.aspectRatio];   % Size/postion of fig

    % Plot the heatmap
    subplot(4,3,1:9)
    imagesc(cell2mat(dataAve.stats.corrs.PwPP.r))
    hold on
    set(gca,'XTick',[1 2 3],'XTickLabel',options.taskLabels,...
        'YTick',[1 2 3],'YTickLabel',options.taskLabels,...
        'YDir','reverse','fontsize',axisLabelFontSize,...
        'clim',[-1 1]);

    %     % Change color of axis labels to match group colors
    %     % Y labels
    %     % get the current tick labels
    %     ticklabels = get(gca,'YTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'YTickLabel', ticklabels_new);
    %     % X labels
    %     clear ticklabels ticklabels_new
    %     % get the current tick labels
    %     ticklabels = get(gca,'XTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'XTickLabel', ticklabels_new);

    colorbar

    % Plot the p values in their respective squares
    if options.plot_stats == 1
        for iI = 1:3
            for iJ = 1:3
                text(iI-.1,iJ-.05,sprintf('%s%1.2f%s','r = ',dataAve.stats.corrs.PwPP.r{iI,iJ},','));
                text(iI-.1,iJ+.05,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.PwPP.p{iI,iJ}));
            end
        end
    end

    title(sprintf('%s%d%s','Switch Rate Correlations (PwPP=',sum(dataAve.grouping==3),')'),'fontsize',titleFontSize)
    box off
    set(gca,'XColor','k','YColor','k')


    % Plot individual task scatterplots
    scatterGroups = [1 2; 1 3; 2 3];
    for iScatter = 1:size(scatterGroups,1)
        % Calculate trend line
        data1 = dataAve.switchRateAve(dataAve.grouping==3,scatterGroups(iScatter,1));
        data2 = dataAve.switchRateAve(dataAve.grouping==3,scatterGroups(iScatter,2));
        [poly_fit] = polyfit(data1,data2,1);
        fit_x = [min(data1) max(data1)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);

        % Plot
        subplot(4,3,9+iScatter)
        % PwPP
        scatter(data1, data2,[],options.col_list{3})
        hold on

        % Plot fit line
        plot(fit_x,fit_y,'k-','LineWidth',2)

        % Plot correlation
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.1,sprintf('%s%1.3f%s','r = ',dataAve.stats.corrs.PwPP.r{scatterGroups(iScatter,1),scatterGroups(iScatter,2)},','));
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.2,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.PwPP.p{scatterGroups(iScatter,1),scatterGroups(iScatter,2)}));

        title(sprintf('%s%s%s',options.taskLabels{scatterGroups(iScatter,1)},' vs ',options.taskLabels{scatterGroups(iScatter,2)}))

        set(gca,'xlim',[0 max(data1)],'ylim',[0 max(data2)])
        xlabel(options.taskLabels{scatterGroups(iScatter,1)})
        ylabel(options.taskLabels{scatterGroups(iScatter,2)})
        box off
        set(gca,'XColor','k','YColor','k')

        clear data1 data2 poly_fit fit_x fit_y
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRateCorrs.figSize,'color','w')

    %% Plot controls
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRateCorrs.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRateCorrs.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRateCorrs.figSize = [0 0 ...
        figSize.switchRateCorrs.aspectRatio];   % Size/postion of fig

    % Plot the heatmap
    subplot(4,3,1:9)
    imagesc(cell2mat(dataAve.stats.corrs.cont.r))
    hold on
    set(gca,'XTick',[1 2 3],'XTickLabel',options.taskLabels,...
        'YTick',[1 2 3],'YTickLabel',options.taskLabels,...
        'YDir','reverse','fontsize',axisLabelFontSize,...
        'clim',[-1 1]);

    %     % Change color of axis labels to match group colors
    %     % Y labels
    %     % get the current tick labels
    %     ticklabels = get(gca,'YTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'YTickLabel', ticklabels_new);
    %     % X labels
    %     clear ticklabels ticklabels_new
    %     % get the current tick labels
    %     ticklabels = get(gca,'XTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'XTickLabel', ticklabels_new);

    colorbar

    % Plot the p values in their respective squares
    if options.plot_stats == 1
        for iI = 1:3
            for iJ = 1:3
                text(iI-.1,iJ-.05,sprintf('%s%1.2f%s','r = ',dataAve.stats.corrs.cont.r{iI,iJ},','));
                text(iI-.1,iJ+.05,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.cont.p{iI,iJ}));
            end
        end
    end

    title(sprintf('%s%d%s','Switch Rate Correlations (Controls=',sum(dataAve.grouping==1),')'),'fontsize',titleFontSize)
    box off
    set(gca,'XColor','k','YColor','k')


    % Plot individual task scatterplots
    scatterGroups = [1 2; 1 3; 2 3];
    for iScatter = 1:size(scatterGroups,1)
        % Calculate trend line
        data1 = dataAve.switchRateAve(dataAve.grouping==1,scatterGroups(iScatter,1));
        data2 = dataAve.switchRateAve(dataAve.grouping==1,scatterGroups(iScatter,2));
        [poly_fit] = polyfit(data1,data2,1);
        fit_x = [min(data1) max(data1)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);

        % Plot
        subplot(4,3,9+iScatter)
        % Controls
        scatter(data1, data2,[],options.col_list{1})
        hold on

        % Plot fit line
        plot(fit_x,fit_y,'k-','LineWidth',2)

        % Plot correlation
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.1,sprintf('%s%1.3f%s','r = ',dataAve.stats.corrs.cont.r{scatterGroups(iScatter,1),scatterGroups(iScatter,2)},','));
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.2,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.cont.p{scatterGroups(iScatter,1),scatterGroups(iScatter,2)}));

        title(sprintf('%s%s%s',options.taskLabels{scatterGroups(iScatter,1)},' vs ',options.taskLabels{scatterGroups(iScatter,2)}))

        set(gca,'xlim',[0 max(data1)],'ylim',[0 max(data2)])
        xlabel(options.taskLabels{scatterGroups(iScatter,1)})
        ylabel(options.taskLabels{scatterGroups(iScatter,2)})
        box off
        set(gca,'XColor','k','YColor','k')

        clear data1 data2 poly_fit fit_x fit_y
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRateCorrs.figSize,'color','w')

elseif options.subj_group_def == 2
    %% Do for seperate PwPP groups
    for iCorrs1 = 1:size(corrGroups,1)
        for iCorrs2 = 1:size(corrGroups,2)
            %% Correlate for scz
            [dataAve.stats.corrs.SCZ.r{iCorrs1,iCorrs2}, dataAve.stats.corrs.SCZ.p{iCorrs1,iCorrs2}] = ...
                corr(dataAve.switchRateAve(dataAve.grouping==2,corrGroups{iCorrs1,iCorrs2}(1)), ...
                dataAve.switchRateAve(dataAve.grouping==2,corrGroups{iCorrs1,iCorrs2}(2)), 'type', options.corr_type);
            
            %% Correlate for all BP
            [dataAve.stats.corrs.BP.r{iCorrs1,iCorrs2}, dataAve.stats.corrs.BP.p{iCorrs1,iCorrs2}] = ...
                corr(dataAve.switchRateAve(dataAve.grouping==3,corrGroups{iCorrs1,iCorrs2}(1)), ...
                dataAve.switchRateAve(dataAve.grouping==3,corrGroups{iCorrs1,iCorrs2}(2)), 'type', options.corr_type);

        end
    end

    %% Plot SCZ
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRateCorrs.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRateCorrs.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRateCorrs.figSize = [0 0 ...
        figSize.switchRateCorrs.aspectRatio];   % Size/postion of fig

    % Plot the heatmap
    subplot(4,3,1:9)
    imagesc(cell2mat(dataAve.stats.corrs.SCZ.r))
    hold on
    set(gca,'XTick',[1 2 3],'XTickLabel',options.taskLabels,...
        'YTick',[1 2 3],'YTickLabel',options.taskLabels,...
        'YDir','reverse','fontsize',axisLabelFontSize,...
        'clim',[-1 1]);

    %     % Change color of axis labels to match group colors
    %     % Y labels
    %     % get the current tick labels
    %     ticklabels = get(gca,'YTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'YTickLabel', ticklabels_new);
    %     % X labels
    %     clear ticklabels ticklabels_new
    %     % get the current tick labels
    %     ticklabels = get(gca,'XTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'XTickLabel', ticklabels_new);

    colorbar

    % Plot the p values in their respective squares
    if options.plot_stats == 1
        for iI = 1:3
            for iJ = 1:3
                text(iI-.1,iJ-.05,sprintf('%s%1.2f%s','r = ',dataAve.stats.corrs.SCZ.r{iI,iJ},','));
                text(iI-.1,iJ+.05,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.SCZ.p{iI,iJ}));
            end
        end
    end

    title(sprintf('%s%d%s','Switch Rate Correlations (SCZ=',sum(dataAve.grouping==2),')'),'fontsize',titleFontSize)
    box off
    set(gca,'XColor','k','YColor','k')


    % Plot individual task scatterplots
    scatterGroups = [1 2; 1 3; 2 3];
    for iScatter = 1:size(scatterGroups,1)
        % Calculate trend line
        data1 = dataAve.switchRateAve(dataAve.grouping==2,scatterGroups(iScatter,1));
        data2 = dataAve.switchRateAve(dataAve.grouping==2,scatterGroups(iScatter,2));
        [poly_fit] = polyfit(data1,data2,1);
        fit_x = [min(data1) max(data1)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);

        % Plot
        subplot(4,3,9+iScatter)
        % Controls
        scatter(data1, data2,[],options.col_list{2})
        hold on

        % Plot fit line
        plot(fit_x,fit_y,'k-','LineWidth',2)

        % Plot correlation
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.1,sprintf('%s%1.3f%s','r = ',dataAve.stats.corrs.SCZ.r{scatterGroups(iScatter,1),scatterGroups(iScatter,2)},','));
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.2,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.SCZ.p{scatterGroups(iScatter,1),scatterGroups(iScatter,2)}));

        title(sprintf('%s%s%s',options.taskLabels{scatterGroups(iScatter,1)},' vs ',options.taskLabels{scatterGroups(iScatter,2)}))

        set(gca,'xlim',[0 max(data1)],'ylim',[0 max(data2)])
        xlabel(options.taskLabels{scatterGroups(iScatter,1)})
        ylabel(options.taskLabels{scatterGroups(iScatter,2)})
        box off
        set(gca,'XColor','k','YColor','k')

        clear data1 data2 poly_fit fit_x fit_y
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRateCorrs.figSize,'color','w')

    %% Plot BP
    figure(); hold on
    % Set font sizes
    titleFontSize = 12;
    axisTitleFontSize = 12;
    axisLabelFontSize = 10;
    statsFontSize = 10;
    % Set figure size
    figSize.switchRateCorrs.baseSize = get(0,'Screensize');   % Base size in pixels
    figSize.switchRateCorrs.aspectRatio = [6.5 5];   % Aspect ratio
    figSize.switchRateCorrs.figSize = [0 0 ...
        figSize.switchRateCorrs.aspectRatio];   % Size/postion of fig

    % Plot the heatmap
    subplot(4,3,1:9)
    imagesc(cell2mat(dataAve.stats.corrs.BP.r))
    hold on
    set(gca,'XTick',[1 2 3],'XTickLabel',options.taskLabels,...
        'YTick',[1 2 3],'YTickLabel',options.taskLabels,...
        'YDir','reverse','fontsize',axisLabelFontSize,...
        'clim',[-1 1]);

    %     % Change color of axis labels to match group colors
    %     % Y labels
    %     % get the current tick labels
    %     ticklabels = get(gca,'YTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'YTickLabel', ticklabels_new);
    %     % X labels
    %     clear ticklabels ticklabels_new
    %     % get the current tick labels
    %     ticklabels = get(gca,'XTickLabel');
    %     % prepend a color for each tick label
    %     ticklabels_new = cell(size(ticklabels));
    %     for iI = 1:length(ticklabels)
    %         ticklabels_new{iI} = [sprintf('%s%d%s%d%s%d%s','\color[rgb]{',options.col_list{iI}(1),' ',options.col_list{iI}(2),' ',options.col_list{iI}(3),' ','} ') ticklabels{iI}];
    %     end
    %     % set the tick labels
    %     set(gca, 'XTickLabel', ticklabels_new);

    colorbar

    % Plot the p values in their respective squares
    if options.plot_stats == 1
        for iI = 1:3
            for iJ = 1:3
                text(iI-.1,iJ-.05,sprintf('%s%1.2f%s','r = ',dataAve.stats.corrs.BP.r{iI,iJ},','));
                text(iI-.1,iJ+.05,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.BP.p{iI,iJ}));
            end
        end
    end

    title(sprintf('%s%d%s','Switch Rate Correlations (BP=',sum(dataAve.grouping==2),')'),'fontsize',titleFontSize)
    box off
    set(gca,'XColor','k','YColor','k')


    % Plot individual task scatterplots
    scatterGroups = [1 2; 1 3; 2 3];
    for iScatter = 1:size(scatterGroups,1)
        % Calculate trend line
        data1 = dataAve.switchRateAve(dataAve.grouping==3,scatterGroups(iScatter,1));
        data2 = dataAve.switchRateAve(dataAve.grouping==3,scatterGroups(iScatter,2));
        [poly_fit] = polyfit(data1,data2,1);
        fit_x = [min(data1) max(data1)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);

        % Plot
        subplot(4,3,9+iScatter)
        % Controls
        scatter(data1, data2,[],options.col_list{3})
        hold on

        % Plot fit line
        plot(fit_x,fit_y,'k-','LineWidth',2)

        % Plot correlation
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.1,sprintf('%s%1.3f%s','r = ',dataAve.stats.corrs.BP.r{scatterGroups(iScatter,1),scatterGroups(iScatter,2)},','));
        text(max(data1)-max(data1)*.1,max(data2)-max(data2)*.2,sprintf('%s%1.2f','p = ',dataAve.stats.corrs.BP.p{scatterGroups(iScatter,1),scatterGroups(iScatter,2)}));

        title(sprintf('%s%s%s',options.taskLabels{scatterGroups(iScatter,1)},' vs ',options.taskLabels{scatterGroups(iScatter,2)}))

        set(gca,'xlim',[0 max(data1)],'ylim',[0 max(data2)])
        xlabel(options.taskLabels{scatterGroups(iScatter,1)})
        ylabel(options.taskLabels{scatterGroups(iScatter,2)})
        box off
        set(gca,'XColor','k','YColor','k')

        clear data1 data2 poly_fit fit_x fit_y
    end

    set(gcf,'Units','inches')
    set(gcf,'Position',figSize.switchRateCorrs.figSize,'color','w')

end

end