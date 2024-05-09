% Function to look at behavrioral accuracy and average reaction time for
% the gamma oscillation experiment. 20190913

function [data] = GamOscExp_BehavAnalysis(options,data)

% First calculate accuracy: Percent trials correctly responded (non catch)
data.behavAcc = round((sum(~isnan(data.rawdata(data.rawdata(:,3)==1,7)))/length(data.rawdata(data.rawdata(:,3)==1))) * 100,2);

% Calculate catch trial accuracy: Did they respond if there was no speed up
data.behavAccCatch = round((sum(~data.rawdata(data.rawdata(:,3)==2,7))/length(data.rawdata(data.rawdata(:,3)==2))) * 100,2);

% Calculate average response time. Time it took the participant to respond
% after the onset of the speed up.
data.respTime = nanmean(data.rawdata(data.rawdata(:,3)==1,5));   % Should never be > .5 s
data.respTimeSTE = nanstd(data.rawdata(data.rawdata(:,3)==1,5))/sqrt(length(data.rawdata(data.rawdata(:,3)==1)));



% Plot data
if options.displayFigs == 1; figure; hold on;
    
    % Behavioral acc
    subplot(1,3,1)
    bar(data.behavAcc,'b')
    title('Behavioral Accuracy')
    axis([0.5 1.5 0 100])
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    ylabel('% Of Trials Responded In Time')
    box off
    
    % Reaction time
    subplot(1,3,2)
    bar(data.respTime,'b')
    hold on
    errorbar(data.respTime,data.respTimeSTE,'.k')
    title('Reaction Time')
    axis([0.5 1.5 0 .6])
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    ylabel('Seconds')
    box off
    
    % Catch trial acc
    subplot(1,3,3)
    bar(data.behavAccCatch,'b')
    title('Catch Trial Accuracy')
    axis([0.5 1.5 0 100])
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    ylabel('% Of Catch Trials No Response Was Made')
    box off

end


% Save to group behavioral file as well



end