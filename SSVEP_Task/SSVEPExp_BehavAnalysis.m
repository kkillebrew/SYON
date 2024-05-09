
SSVEPData = readtable('Kyle_Test-SSVEP.log','FileType','text');   % Load in the data file

SSVEPDataCell = table2cell(SSVEPData);
taskTrialIdx = find([SSVEPDataCell{:,2}]==5);   % Find the task trial triggers

% Find the indices where the participant responded
for i=1:length(SSVEPDataCell)
    if strfind(SSVEPDataCell{i,1},'Response')
        responseIdxHolder(i) = 1;
    else
        responseIdxHolder(i) = 0;
    end
end
responseIdx = find(responseIdxHolder);

% Go through the taskTrial array and find the closest response that is < 20
% away (which will give you the first response if there are mulitple
% responses but give you no response if there is nothing w/in 20) which 
% will give you accuracy. Then grab the timestamp of the taskTrialIdx and 
% responseIdx and take the difference which gives respose time. 
rtCounter = 0;
for i=1:length(taskTrialIdx)
    [holderDiff(i),holderIdx(i)] = min(abs(responseIdx-taskTrialIdx(i)));
    
    % Find the index for the next 3 (start of next trial) after the start of taskTrialIdx(i). If
    % that value is greater than holderIdx, then they did not respond for
    % the current task trial and count it as a 0 for accuracy. 
    counter = 0;
    while 1
        counter = counter+1;
        if SSVEPDataCell{taskTrialIdx(i)+counter,2} == 3
            respDiff = counter;
            break
        end
    end
    if respDiff >= 20
       acc(i) = 0; 
    else
        acc(i) = 1;
    end
    
    
    % For trials the part responded to find the timestamps for responseIdx(holderIdx) and taskTrialIdx(i)
    % First grab the string in SSVEPDataCell that contains the timestamp
    if acc(i) == 1
        rtCounter = rtCounter + 1;
        timeTaskStr = SSVEPDataCell(taskTrialIdx(i),4);
        timeResponseStr = SSVEPDataCell(responseIdx(holderIdx(i)),1);
        
        % Now pull out the timestamp from these strings and make it a double
        findSpaces = find(isspace(timeTaskStr{1})==1);
        timeTask(i) = str2double(timeTaskStr{1}(findSpaces(1)+1:findSpaces(2)-1));   % Find the first arrow in the string and grab the number until you hit the next arrow
        findSpaces = find(isspace(timeResponseStr{1})==1);
        timeResponse(i) = str2double(timeResponseStr{1}(findSpaces(4)+1:findSpaces(5)-1));
        
        % Take the difference and divide by 1000 to get RT in seconds
        reactionTime(i) = (timeResponse(i) - timeTask(i))/10000;
    end
end

% Find accuracy
aveAcc = (sum(acc)/length(acc))*100;

% Find average reaction time
aveReactionTime = mean(reactionTime);
steReactionTime = std(reactionTime)/sqrt(length(reactionTime)-1);

% Plot
figure();hold on;
subplot(1,2,1)
bar(aveAcc)
title('Average Accuracy')
ylabel('% of times participants responded after a fixation change');

subplot(1,2,2)
bar(aveReactionTime);
hold on
errorbar(aveReactionTime,steReactionTime,'.k');
title('Average Reaction Time')
ylabel('Reaction Time (s)')





