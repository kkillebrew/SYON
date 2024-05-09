if options.analysisCheck == 1
    data.thresh.estimate_lapse_from_catch = 0; % do we estimate the upper asymptote for
    % accuracy based on performance on catch trials, or just assume a fixed
    % value?
    data.thresh.thresh_pct = 0.5; % pct correct to evaluate for threshold % kwk changed 20190909
    data.thresh.min_lapse = 0.04; % this is the lowest we'll ever set the lapse rate,
    % regardless of catch performance. Since there's 30 catch trials,
    % this conservatively assumes everyone will miss 1/30...
    data.thresh.max_thresh =  8.125; % maximum theoretical threshold, exclude if outside % kwk 20190909
    data.thresh.min_thresh = 4.875; % kwk 20190909
    
    data.thresh.paramsFree = [1 1 0 0]; % which parameters to fit, (1 = threshold, 2 = slope, 3 =
    data.thresh.PF = @PAL_Logistic; % which psychometric function to use
    
    plot_symbols = {'o','s','^'};
    plot_lines = {'-','--','-.'};
    cond_label{1} = 'NoBackground';
    cond_label{2} = 'Background';
    
    for i=1:options.backgroundNum   % Num conditions (background/no background)
        
        if options.displayFigs == 1; figure; end % mps 20190730
        for j=1:size(data.stair,2)   % Num staircases - 2 for each condition
            
            clear numPos outOfNum catchAccArrayHolder
            data.thresh.stimLevels{i,j} = unique(data.stair(i,j).x(1:end-1)); % all unique stimulus intensity values
            for k = 1:length(data.thresh.stimLevels{i,j})
                find_x = find(data.stair(i,j).x(1:end-1) == data.thresh.stimLevels{i,j}(k)); % find the indices
                data.thresh.numPos{i,j}(k) = length(find(data.stair(i,j).response(find_x) == 1)); % how many were correctly responded to
                data.thresh.outOfNum{i,j}(k) = length(find_x); % how many total?
            end
            
            data.thresh.old_params(i,j,:) = [data.stair(i,j).threshold(end) data.stair(i,j).slope(end) ...
                data.stair(i,j).guess(end) data.stair(i,j).lapse(end)]; % parameters estimated during the task
            
            data.thresh.searchGrid(i,j).alpha = data.stair(i,j).priorAlphaRange; % this is the range for fitting, same as during the task
            data.thresh.searchGrid(i,j).beta = data.stair(i,j).priorBetaRange;
            data.thresh.searchGrid(i,j).gamma = data.stair(i,j).priorGammaRange;
            %                     data.thresh.searchGrid(i,j).gamma = 0.5;
            if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
                data.thresh.searchGrid(i,j).lambda = max([1-mean(data.thresh.catch_accuracy(i)) data.thresh.min_lapse]);
            else % else assume fixed value used during task
                data.thresh.searchGrid(i,j).lambda = data.stair(i,j).priorLambdaRange;
            end
            
            [data.thresh.paramsFit(i,j,:), ~, ~, ~] = PAL_PFML_Fit(data.thresh.stimLevels{i,j}, squeeze(data.thresh.numPos{i,j}), ...
                squeeze(data.thresh.outOfNum{i,j}), data.thresh.searchGrid(i,j), data.thresh.paramsFree, data.thresh.PF); % do the fitting
            
            data.thresh.thresh_old(i,j) = data.thresh.PF(squeeze(data.thresh.old_params(i,j,:)),data.thresh.thresh_pct,'inverse'); % figure out threshold, based on criterion accuracy %
            data.thresh.thresh_refit(i,j) = data.thresh.PF(squeeze(data.thresh.paramsFit(i,j,:)),data.thresh.thresh_pct,'inverse');
            data.thresh.slope_refit(i,j) = data.thresh.paramsFit(2);
            
            if data.thresh.thresh_refit(i,j) > data.thresh.max_thresh || ...
                    data.thresh.thresh_refit(i,j) < data.thresh.min_thresh
                data.thresh.thresh_refit(i,j) = NaN; % exclude this data, outside theoretical max range
            end
            
            % plot some figures
            if options.displayFigs == 1
                subplot(1,size(data.stair,2)*size(data.stair,3)+2,j); hold on % one subplot per staircase
                for iX = 1:numel(data.thresh.stimLevels{i,j}) % plot raw data (accuracy vs. stimulus intensity, larger symbols for more trials)
                    plot(data.thresh.stimLevels{i,j}(iX),data.thresh.numPos{i,j}(iX)/data.thresh.outOfNum{i,j}(iX),...
                        ['g' plot_symbols{1}],'MarkerSize',data.thresh.outOfNum{i,j}(iX)+2,...
                        'linewidth',2);
                end
                x_val = 4.875:.125:8.125;   % X-axis array
                plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-'); % threshold fiducial line
                
                %                 plot(x_val,PF(old_params,x_val),['c' plot_lines{1}])
                
                plot(x_val,data.thresh.PF(squeeze(data.thresh.paramsFit(i,j,:)),x_val),['b' plot_lines{1}],...
                    'linewidth',2); % plot refit psychometric function
                
                %                 plot([thresh_old(iS,iC,iR) thresh_old(iS,iC,iR)],[0 1],...
                %                     ['m' plot_lines{1}])
                
                plot([data.thresh.thresh_refit(i,j) data.thresh.thresh_refit(i,j)],[0 1],...
                    ['r'  plot_lines{1}],'linewidth',2) % plot refit threshold
                
                axis([4.875 8.125 -0.05 1.05])
                box off
                if j == 1
                    title([options.subjID ...
                        ' run ' sprintf('%d',options.runID) ...
                        ' ' cond_label{i}])
                    ylabel('Accuracy')
                else
                    title(cond_label{i})
                end
                set(gca,'fontsize',12)
                
            end
        end
        
        
        % Now calculate the threshold by combining all the staircase
        % values and recalculting the thresh w/ all stair data points.
        data.thresh.ave(i).xComb = [];
        data.thresh.ave(i).responseComb = [];
        for j=1:size(data.stair,2)   % Num staircases - 2 blocks 2 stairs each
            data.thresh.ave(i).xComb = [data.thresh.ave(i).xComb data.stair(i,j).x(1:end-1)];
            data.thresh.ave(i).responseComb = [data.thresh.ave(i).responseComb data.stair(i,j).response];
        end
        data.thresh.ave(i).stimLevels = unique(data.thresh.ave(i).xComb);
        
        for k=1:length(data.thresh.ave(i).stimLevels)
            find_x = find(data.thresh.ave(i).xComb == data.thresh.ave(i).stimLevels(k));   % Find the indices
            data.thresh.ave(i).numPos(k) = length(find(data.thresh.ave(i).responseComb(find_x) == 1));   % How many were correctly responded to
            data.thresh.ave(i).outOfNum(k) = length(find_x);   % How many total
        end
        
        data.thresh.ave(i).searchGrid.alpha = data.stair(i,1,1).priorAlphaRange;
        data.thresh.ave(i).searchGrid.beta = data.stair(i,1,1).priorBetaRange;
        data.thresh.ave(i).searchGrid.gamma = data.stair(i,1,1).priorGammaRange;
        if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
            data.thresh.ave(i).searchGrid.lambda = max([1-mean(data.thresh.catch_accuracy(i)) data.thresh.min_lapse]);
        else % else assume fixed value used during task
            data.thresh.ave(i).searchGrid.lambda = data.stair(i,1,1).priorLambdaRange;
        end
        
        [data.thresh.ave(i).paramsFit(:),~,~,~] = PAL_PFML_Fit(data.thresh.ave(i).stimLevels,squeeze(data.thresh.ave(i).numPos),...
            squeeze(data.thresh.ave(i).outOfNum),data.thresh.ave(i).searchGrid,data.thresh.paramsFree,data.thresh.PF);
        
        data.thresh.ave(i).thresh_refit = data.thresh.PF(squeeze(data.thresh.ave(i).paramsFit(:)),data.thresh.thresh_pct,'inverse');
        data.thresh.ave(i).slope_refit = data.thresh.ave(i).paramsFit(2);
        
        if data.thresh.ave(i).thresh_refit > data.thresh.max_thresh || ...
                data.thresh.ave(i).thresh_refit < data.thresh.min_thresh
            data.thresh.ave(i).thresh_refit = NaN;   % exclude this data, outside theoretical max range
        end
        
        % Plot some figs
        if options.displayFigs == 1
            subplot(1,size(data.stair,2)*size(data.stair,3)+2,size(data.stair,2)*size(data.stair,3)+1); hold on
            
            % Plot rawdata acc
            for j=1:numel(data.thresh.ave(i).stimLevels)
                plot(data.thresh.ave(i).stimLevels(j),data.thresh.ave(i).numPos(j)/data.thresh.ave(i).outOfNum(j),...
                    ['g' plot_symbols{1}],'MarkerSize',data.thresh.ave(i).outOfNum(j)+2,'linewidth',2)
            end
            
            % Thresh fiducial line
            x_val = 4.875:.125:8.125;
            plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
            
            % Refit psychometric function
            plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(i).paramsFit(:)),x_val),['b' plot_lines{1}],...
                'linewidth',2);
            
            % Refit threshold
            plot([data.thresh.ave(i).thresh_refit data.thresh.ave(i).thresh_refit],[0 1],...
                ['r' plot_lines{2}],'linewidth',2);
            
            axis([4.875 8.125 -0.05 1.05])
            box off
            
            title([cond_label{i} ' - Combined']);
            set(gca,'fontsize',12)
            
        end
    end
    
    % Plot comparison graph
    if options.displayFigs == 1; figure;
        
        % Plot the two psychometric fits on the same plot
        subplot(1,3,1); hold on;
        plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
        % Shape
        x_val = 4.875:.125:8.125;
        shapePlot = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(1).paramsFit(:)),x_val),['r' plot_lines{1}],...
            'linewidth',2);
        plot([data.thresh.ave(1).thresh_refit data.thresh.ave(1).thresh_refit],[0 1],...
            ['r' plot_lines{2}],'linewidth',2);
        axis([4.875 8.125 -0.05 1.05])
        box off
        title('Background-No Background');
        set(gca,'fontsize',12)
        % No shape
        x_val = 4.875:.125:8.125;
        noShapePlot = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(2).paramsFit(:)),x_val),['b' plot_lines{1}],...
            'linewidth',2);
        plot([data.thresh.ave(2).thresh_refit data.thresh.ave(2).thresh_refit],[0 1],...
            ['b' plot_lines{2}],'linewidth',2);
        axis([4.875 8.125 -0.05 1.05])
        box off
        title('Background-No Background');
        set(gca,'fontsize',12)
        legend([shapePlot,noShapePlot],{'Background' 'No Background'},'location','northwest');
        
        % Plot the combined thresh in bargraph for shape/noshape
        subplot(1,3,2); hold on;
        combinedBar = bar([data.thresh.ave(1).thresh_refit data.thresh.ave(2).thresh_refit]);
        combinedBar.FaceColor = 'flat';
        combinedBar.CData(1,:) = [1 0 0];
        combinedBar.CData(2,:) = [0 0 1];
        hold on
        plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
        ylim([4.875 8.125])
        yticks(4.875:1:8.125)
        xticks([1 2]);
        xticklabels({'Background' 'No Background'})
        set(gca,'fontsize',12)
        set(gcf,'color','w')
        box off
        title('Combined Background-No Background PSE')
        
        % Plot the mean/std across the 4 staircases
        data.thresh.thresh_refit_mean(1) = nanmean(data.thresh.thresh_refit(1,:));
        data.thresh.thresh_refit_mean(2) = nanmean(data.thresh.thresh_refit(2,:));
        data.thresh.thresh_refit_ste(1) = ste(data.thresh.thresh_refit(1,:));
        data.thresh.thresh_refit_ste(2) = ste(data.thresh.thresh_refit(2,:));
        
        subplot(1,3,3); hold on;
        meanBar = bar([data.thresh.thresh_refit_mean(1) data.thresh.thresh_refit_mean(2)]);
        errorbar([data.thresh.thresh_refit_mean(1) data.thresh.thresh_refit_mean(2)],...
            [data.thresh.thresh_refit_ste(1) data.thresh.thresh_refit_ste(2)],'.k');
        meanBar.FaceColor = 'flat';
        meanBar.CData(1,:) = [1 0 0];
        meanBar.CData(2,:) = [0 0 1];
        hold on
        plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
        ylim([4.875 8.125])
        yticks(4.875:1:8.125)
        xticks([1 2]);
        xticklabels({'Shape' 'No Shape'})
        set(gca,'fontsize',12)
        set(gcf,'color','w')
        box off
        title('Mean Shape-No Shape PSE')
        
    end
end