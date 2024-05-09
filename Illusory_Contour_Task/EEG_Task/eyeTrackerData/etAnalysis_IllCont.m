% Script to analyze eyetracking data from VA EEG setup. 
% KWK - 20210216

%% First load in the data
% Determine number of blocks (will allign w/ # of ET files)

% Load in eyetracking data
load('./gazeData_KK_ET_test_Illusory_Contour_Task_021521.mat');

% Transfer values from struct to easier to use arrays
for i=1:length(gazeData.data)
    % Grab left/right eye values
    leftEyeHolder = {gazeData.data{i}.LeftEye};
    rightEyeHolder = {gazeData.data{i}.RightEye};
    sysTimeHolder = {gazeData.data{i}.SystemTimeStamp};
    for j=1:length(leftEyeHolder)
        data{i}.leftEye.gazePoint(j,:) = leftEyeHolder{j}.GazePoint.OnDisplayArea;
        data{i}.leftEye.validity(j,:) = leftEyeHolder{j}.GazePoint.Validity;
    end
    for j=1:length(rightEyeHolder)
        data{i}.rightEye.gazePoint(j,:) = rightEyeHolder{j}.GazePoint.OnDisplayArea;
        data{i}.rightEye.validity(j,:) = rightEyeHolder{j}.GazePoint.Validity;
    end
    for j=1:length(sysTimeHolder)
       data{i}.sysTime(j) = sysTimeHolder{j};   % This system time stamp is from the data collection computer in microseconds
    end
end

%% Preprocessing

% Length of each trial
% Collecting data for blank, stim, isi, and mask; want to grab data for it
% all. 
trialLength = 

% Segment
% Grab events
for i = 1:length(gazeData.events)
    eventIdx(i) = gazeData.events{i}{2};
    eventTime(i) = gazeData.events{i}{1};
end

% Segment into trials

% Identify artifacts



%% Plot

