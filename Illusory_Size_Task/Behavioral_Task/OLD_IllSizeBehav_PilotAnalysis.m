% Average the pilot data for the various size task behavioral tasks. 

% Data files for each task
taskData{1}.dataFileList = {'CT_1000ms_Flicker_Illusory_Size_Task_001','James_1000ms_Flicker_Illusory_Size_Task_001',...
    'KK_Pilot_1000ms_Flicker_Illusory_Size_Task_001','mps_1000ms_Flicker_Illusory_Size_Task_001',...
    'MT_1000ms_Flicker_Illusory_Size_Task_001','S_test_HM_1000ms_Flicker_Illusory_Size_Task_001'};   % 1000ms Flicker task
taskData{2}.dataFileList = {'CT_400ms_Illusory_Size_Task_001','James_400ms_Illusory_Size_Task_001',...
    'KK_Pilot_400msStimPres_Illusory_Size_Task_001','mps_400__400ms_Illusory_Size_Task_001',...
    'MT_400ms_Illusory_Size_Task_001','S_test_HM_400ms_Illusory_Size_Task_001'};   % 400ms task
taskData{3}.dataFileList = {'CT_200ms_Illusory_Size_Task_001','mps_200ms_Illusory_Size_Task_001',...
    'MT_200ms_Illusory_Size_Task_001','KK_200ms_Illusory_Size_Task_001','S_test_HM_200ms_Illusory_Size_Task_001'};   % 200ms task

% Data files to use to compare line and dot fix tasks
taskDataFixCompare{1}.dataFileList = {'KK_200ms_Illusory_Size_Task_001'};   % 200ms dot fix 
taskDataFixCompare{2}.dataFileList = {'KK_200ms_FixLine_Illusory_Size_Task_001'};   % 200ms line fix
taskDataFixCompare{3}.dataFileList = {'KK_Pilot_1000ms_Flicker_Illusory_Size_Task_001'};   % 1000ms flicker dot fix
taskDataFixCompare{4}.dataFileList = {'KK_1000ms_Flicker_FixLine_Illusory_Size_Task_001'};   % 1000ms flicker line fix

PSEGraphTitle = {'1000ms Flicker Average PSE','400ms Average PSE','200ms Average PSE'};
catchLabel = {'Larger Hallway','Larger No Hallway','Smaller Hallway','Smaller No Hallway','Average'};
catchGraphTitle = {'1000ms Flicker Average Catch','400ms Average Catch','200ms Average Catch'};

% Load in subject data
figure(1)
figure(2)
for i=1:length(taskData)
    for j=1:length(taskData{i}.dataFileList)
        
        % Load data file
        dataHolder = load(taskData{i}.dataFileList{j},'data');
        
        taskData{i}.PSE(j,:) = dataHolder.data.thresh.thresh_refit_mean;   % Average PSE per participant
        taskData{i}.catch(j,:)  = [dataHolder.data.largerCatchBack dataHolder.data.largerCatchNoBack... 
            dataHolder.data.smallerCatchBack dataHolder.data.smallerCatchNoBack dataHolder.data.catchAve];
        
        clear dataHolder
    end
    
    % Take the average PSE across participants
    taskData{i}.avePSE = nanmean(taskData{i}.PSE,1);
    taskData{i}.stdPSE = nanstd(taskData{i}.PSE,1);
    
    % Take a difference between the two PSE values
    taskData{i}.diffPSE = taskData{i}.PSE(:,1) - taskData{i}.PSE(:,2);
    taskData{i}.aveDiffPSE = nanmean(taskData{i}.diffPSE,1);
    taskData{i}.stdDiffPSE = nanstd(taskData{i}.diffPSE,1);
    
    % Take the average catch accuracy
    taskData{i}.aveCatch = nanmean(taskData{i}.catch,1);
    taskData{i}.stdCatch = nanstd(taskData{i}.catch,1);
    
    % Take a t-test between the two groups
    
    % Plot the average PSEs
    figure(1)
    subplot(1,3,i)
    hold on
    meanBar(1) = bar(1,taskData{i}.avePSE(1));
    meanBar(1).FaceColor = [1 0 0];
    meanBar(2) = bar(2,taskData{i}.avePSE(2));
    meanBar(2).FaceColor = [0 0 1];
    meanBar(3) = bar(3,taskData{i}.aveDiffPSE);
    meanBar(3).FaceColor = [0 1 0];
    hold on
    errorbar([taskData{i}.avePSE(1) taskData{i}.avePSE(2) taskData{i}.aveDiffPSE],...
        [taskData{i}.stdPSE(1) taskData{i}.stdPSE(2) taskData{i}.stdDiffPSE],'.k')
    plot(get(gca,'xlim'),[1 1],'k-')
    ylim([0 1.25])
    set(gca,'YTick',[0:.25:1.25]);
    set(gca,'XTick',[1 2 3]);
    set(gca,'XTickLabel',{'Background' 'No Background','Difference'})
    set(gca,'XTickLabelRotation',45);
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    box off
    ylabel('');
    title(sprintf('%s%s%d%s',PSEGraphTitle{i},' (n=',length(taskData{i}.dataFileList),')'))
    
    % Plot the average catch
    figure(2)
    subplot(1,3,i)
    bar(taskData{i}.aveCatch);
    hold on
    errorbar(taskData{i}.aveCatch,taskData{i}.stdCatch,'.k');
    ylim([0 110])
    set(gca,'YTick',[0:10:110]);
    set(gca,'XTick',[1:5]);
    set(gca,'XTickLabel',{'Larger Hallway','Larger No Hallway','Smaller Hallway','Smaller No Hallway','Average'})
    set(gca,'XTickLabelRotation',45);
    %             xtickangle(45)
    set(gca,'fontsize',12)
    set(gcf,'color','w')
    box off
    title(sprintf('%s%s%d%s',catchGraphTitle{i},' (n=',length(taskData{i}.dataFileList),')'))
    
end

% Compare data from different fixation tasks
for i=1:length(taskDataFixCompare)
    for j=1:length(taskDataFixCompare{i}.dataFileList)
        
        % Load data file
        dataHolder = load(taskDataFixCompare{i}.dataFileList{j},'data');
        
        taskDataFixCompare{i}.PSE(j,:) = dataHolder.data.thresh.thresh_refit_mean;   % Average PSE per participant
        taskDataFixCompare{i}.catch(j,:)  = [dataHolder.data.largerCatchBack dataHolder.data.largerCatchNoBack... 
            dataHolder.data.smallerCatchBack dataHolder.data.smallerCatchNoBack dataHolder.data.catchAve];
        
        clear dataHolder
    end
end

% Take the difference for each participant
aveFixCompare.diffPSE(1,:,:) = taskDataFixCompare{2}.PSE - taskDataFixCompare{1}.PSE;
aveFixCompare.diffPSE(2,:,:) = taskDataFixCompare{4}.PSE - taskDataFixCompare{3}.PSE;

% % Take the differnce between the 2 fixation conditions for ecah version
% aveFixCompare.aveDiffPSE = squeeze(nanmean(aveFixCompare.diffPSE,2));
% aveFixCompare.aveDiffPSE(2,:) = taskDataFixCompare{4}.avePSE - taskDataFixCompare{3}.avePSE;

% Plot
figure(3)
subplot(1,2,1)
bar([taskDataFixCompare{2}.PSE(1,1),taskDataFixCompare{1}.PSE(1,1),aveFixCompare.diffPSE(1,1,1);...
    taskDataFixCompare{2}.PSE(1,2),taskDataFixCompare{1}.PSE(1,2),aveFixCompare.diffPSE(1,1,2)]);
hold on
errorbar(taskData{i}.aveCatch,taskData{i}.stdCatch,'.k');
ylim([0 110])
set(gca,'YTick',[0:10:110]);
set(gca,'XTick',[1:5]);
set(gca,'XTickLabel',{'Larger Hallway','Larger No Hallway','Smaller Hallway','Smaller No Hallway','Average'})
set(gca,'XTickLabelRotation',45);
%             xtickangle(45)
set(gca,'fontsize',12)
set(gcf,'color','w')
box off
title(sprintf('%s%s%d%s',catchGraphTitle{i},' (n=',length(taskData{i}.dataFileList),')'))







