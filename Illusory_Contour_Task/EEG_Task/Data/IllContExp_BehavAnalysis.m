% Function to look at behavrioral accuracy and average reaction time for
% the illusory contour experiment. 20190913

function [data] = IllContExp_BehavAnalysis(options,data)


%% First look at behavioral accuracy 
% Behav acc for fat
data.behavAcc(1) = round((sum([data.rawdata(:,3)==1 & data.rawdata(:,4)==1 & data.rawdata(:,11)==1])/sum(data.rawdata(:,3)==1 & data.rawdata(:,4)==1)) * 100,2);

% Behav acc for thin
data.behavAcc(2) = round((sum([data.rawdata(:,3)==1 & data.rawdata(:,4)==2 & data.rawdata(:,11)==1])/sum(data.rawdata(:,3)==1 & data.rawdata(:,4)==2)) * 100,2);

% Behav acc for fragmented
data.behavAcc(3) = round((sum([data.rawdata(:,3)==2 & data.rawdata(:,11)==1])/sum(data.rawdata(:,3)==1)) * 100,2);

% Behav acc for mask only
data.behavAcc(4) = round((sum([data.rawdata(:,3)==3 & data.rawdata(:,11)==1])/sum(data.rawdata(:,3)==3)) * 100,2);


%% Look at reaction time
% Reaction time for fat
data.respTime(1) = nanmean(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==1 & data.rawdata(:,11)==1],10));   % Should never be > .5 s
data.respTimeSTE(1) = nanstd(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==1 & data.rawdata(:,11)==1],10))/...
    sqrt(length(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==1 & data.rawdata(:,11)==1])));

% Reaction time for thin
data.respTime(2) = nanmean(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==2 & data.rawdata(:,11)==1],10));   % Should never be > .5 s
data.respTimeSTE(2) = nanstd(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==2 & data.rawdata(:,11)==1],10))/...
    sqrt(length(data.rawdata([data.rawdata(:,3)==1 & data.rawdata(:,4)==2 & data.rawdata(:,11)==1])));

% Reaction time for fragmented
data.respTime(3) = nanmean(data.rawdata([data.rawdata(:,3)==2 & data.rawdata(:,11)==1],10));   % Should never be > .5 s
data.respTimeSTE(3) = nanstd(data.rawdata([data.rawdata(:,3)==2 & data.rawdata(:,11)==1],10))/...
    sqrt(length(data.rawdata([data.rawdata(:,3)==2 & data.rawdata(:,11)==1])));

% Reaction time for mask only
data.respTime(4) = nanmean(data.rawdata([data.rawdata(:,3)==3 & data.rawdata(:,11)==1],10));   % Should never be > .5 s
data.respTimeSTE(4) = nanstd(data.rawdata([data.rawdata(:,3)==3 & data.rawdata(:,11)==1],10))/...
    sqrt(length(data.rawdata([data.rawdata(:,3)==3 & data.rawdata(:,11)==1])));


%% Plot data
if options.displayFigs == 1; figure; hold on;
    
    % Plot behav acc
    subplot(1,2,1)
    bar(data.behavAcc(:),'b')
    title('Behavioral Accuracy')
    axis([0.5 4.5 0 100])
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    xticklabels({'Fat','Thin','Fragmented','Mask Only'});
    box off
    
    % Plot avearage reaction times
    subplot(1,2,2)
    bar(data.respTime(:),'b')
    hold on
    errorbar(data.respTime(:),data.respTimeSTE(:),'.k')
    title('Reaction Time')
    axis([0.5 4.5 0 1.5])
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    xticklabels({'Fat','Thin','Fragmented','Mask Only'});
    box off
    
end



% Save to group behavioral file as well


end