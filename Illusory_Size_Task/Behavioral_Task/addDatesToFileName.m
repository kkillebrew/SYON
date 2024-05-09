% Read in each behavioral data file and resave it with the correct date/time using
% options.time_stamp. Will want to update how the file name gets created and add on
% the actual date/time so that we can better use these data in the future.

function [] = addDatesToFileName()

options.curDur = '/labs/srslab/data_main/SYON.git/Illusory_Size_Task/Behavioral_Task/';

% Grab in subject datafile names/info
options.taskData.dataFileList = dir('./Data/S*_1000ms_Flicker_FixLine_BothPersp_Illusory_Size_Task_MR_Prac_*.mat');
% Ensure all the files are actually data files and not tests/pilots
holderName = {options.taskData.dataFileList.name};
holderName = cellfun(@(x) x(1:8), holderName, 'UniformOutput', false);
holderNum = cellfun(@(x) x(2:8), holderName, 'UniformOutput', false);
% Returns a number for each subject that indexes where in the string
% (holderName{iI}) the patter shown in the second input begins. It checks
% each input in holderName for the patter (letter digit digit ...). Any
% value w/ a '0' or empty in the output means that file is not correct and
% should be tossed.
holderTaskData = regexp(holderName, '\w\d\d\d\d\d\d\d','once');
holderTaskDataIdx = cellfun('isempty',holderTaskData);
options.taskData.dataFileList(holderTaskDataIdx) = [];
options.taskData.subjID = holderName(~holderTaskDataIdx);
options.taskData.subjNum = cellfun(@str2num,holderNum(~holderTaskDataIdx));
clear holderName holderTaskData holderTaskDataIdx

for iJ=1:length(options.taskData.dataFileList)

    % Load in data file for the participant
    dataHolder = load(options.taskData.dataFileList(iJ),'options');
    timeHolder = datetime(options.time_stamp,'InputFormat','MM/dd/yyyy HH:mm:ss');


    clear dataHolder options
end




