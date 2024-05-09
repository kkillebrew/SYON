options.displayFigs = 1; % show figures

options.estimate_lapse_from_catch = 0; % do we estimate the upper asymptote for 
% accuracy based on performance on catch trials, or just assume a fixed
% value?
thresh_pct = 0.5; % pct correct to evaluate for threshold
min_lapse = 0.033; % this is the lowest we'll ever set the lapse rate, 
% regardless of catch performance. Since there's 30 catch trials,
% this conservatively assumes everyone will miss 1/30...
max_thresh = 50; % maximum theoretical threshold, exclude if outside
min_thresh = -50;

plot_symbols = {'o','s','^'};
plot_lines = {'-','--','-.'};

data_dir = pwd; % put me somewhere!

subject_dirs = {'test_data_for_kyle'}; % placeholder for a list of subject files...
subj_name{1} = 'test';
cond_label{1} = 'cond1';
cond_label{2} = 'cond2';
cond_label{3} = 'cond3';

nCond = 3;
nRuns = 3;
thresh_refit = nan(numel(subject_dirs),nCond,nRuns);
thresh_old = nan(numel(subject_dirs),nCond,nRuns);
slope_refit = nan(numel(subject_dirs),nCond,nRuns);
catch_accuracy = nan(numel(subject_dirs),nRuns);

h_wait = waitbar(0,'Loading subject data, please wait...','name','(task name)');

for iS = 1:length(subject_dirs)
    
    waitbar((iS-1)/length(subject_dirs),h_wait,['Loading subject data, please wait... ']);
    
    for iR = 1:nRuns   % NUM STAIRCASES?
        if options.displayFigs == 1; figure; end
        
        load(fullfile(data_dir,'test_data_for_kyle.mat'));
        stair = output.stair;
        catch_accuracy(iS,iR) = nanmean(stair(length(stair)).response); % last condition 
        % in stair structure are catch trials (fixed stimulus intensity,
        % low difficulty) -- use this to assess task engagement.
        
        for iC = 1:length(stair)-1 % for all conditions except for the catch trials
            clear numPos outOfNum
            stimLevels = unique(stair(iC).x(1:end-1)); % all unique stimulus intensity values
            for iX = 1:length(stimLevels)
                find_x = find(stair(iC).x(1:end-1) == stimLevels(iX)); % find the indices
                numPos(iX) = length(find(stair(iC).response(find_x) == 1)); % how many were correctly responded to
                outOfNum(iX) = length(find_x); % how many total?
            end
            
            old_params = [stair(iC).threshold(end) stair(iC).slope(end) ...
                stair(iC).guess(end) stair(iC).lapse(end)]; % parameters estimated during the task
            
            searchGrid.alpha = stair.priorAlphaRange; % this is the range for fitting, same as during the task
            searchGrid.beta = stair.priorBetaRange;
            searchGrid.gamma = stair.gamma;
            if options.estimate_lapse_from_catch % if we are estimating this from catch performance
                searchGrid.lambda = max([1-mean(catch_accuracy(iS,:)) min_lapse]);
            else % else assume fixed value used during task
                searchGrid.lambda = stair.lambda;
            end
            paramsFree = [1 1 0 0]; % which parameters to fit, (1 = threshold, 2 = slope, 3 = 
            
            PF = @PAL_Logistic; % which psychometric function to use
            
            [paramsFit LL exitFlag fit_output] = PAL_PFML_Fit(stimLevels, numPos, ...
                outOfNum, searchGrid, paramsFree, PF); % do the fitting
            
            thresh_old(iS,iC,iR) = PF(old_params,thresh_pct,'inverse'); % figure out threshold, based on criterion accuracy %
            thresh_refit(iS,iC,iR) = PF(paramsFit,thresh_pct,'inverse');
            slope_refit(iS,iC,iR) = paramsFit(2);
            
            if thresh_refit(iS,iC,iR) > max_thresh || ...
                    thresh_refit(iS,iC,iR) < min_thresh
                thresh_refit(iS,iC,iR) = NaN; % exclude this data, outside theoretical max range
            end
            
            if options.displayFigs == 1 % plot some figures
                subplot(1,length(stair),iC); hold on % one subplot per condition
                for iX = 1:length(stimLevels) % plot raw data (accuracy vs. stimulus intensity, larger symbols for more trials)
                    plot(stimLevels(iX),numPos(iX)/outOfNum(iX),...
                        ['g' plot_symbols{1}],'MarkerSize',outOfNum(iX)+2,...
                        'linewidth',2);
                end
                x_val = -50:0.01:50;
                plot([x_val(1) x_val(end)],[thresh_pct thresh_pct],'k--') % threshold fiducial line
                
%                 plot(x_val,PF(old_params,x_val),['c' plot_lines{1}])

                plot(x_val,PF(paramsFit,x_val),['b' plot_lines{1}],...
                    'linewidth',2) % plot refit psychometric function
                
%                 plot([thresh_old(iS,iC,iR) thresh_old(iS,iC,iR)],[0 1],...
%                     ['m' plot_lines{1}])

                plot([thresh_refit(iS,iC,iR) thresh_refit(iS,iC,iR)],[0 1],...
                    ['r'  plot_lines{1}],'linewidth',2) % plot refit threshold
                
                axis([-20 20 -0.05 1.05])
                box off
                if iC == 1
                    title([subj_name{iS} ...
                        ' run ' num2str(iR) ...
                        ' ' cond_label{iC}])
                    ylabel('Accuracy')
                else
                    title(cond_label{iC})
                end
                set(gca,'fontsize',12)
            end
        end
        if options.displayFigs == 1
            subplot(1,length(stair),length(stair)); hold on
            bar(1,catch_accuracy(iS,iR));
            axis([0.5 1.5 -.05 1.05])
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title(cond_label{3})
        end
    end
end