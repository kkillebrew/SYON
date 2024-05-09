% Psychophysical experiment for the illusory contour task for the SYON grant.

function[] = IllContExp_Behav_EyeTrack()

clear all; close all; sca;
tic;
% switch nargin
%     case 1
%         subjid = [];
%         runid = [];
%     case 2
%         runid = [];
% end

%% Initialize
% start mps edit 20190730
curr_path = pwd;
match_folder_name = 'SYON.git';
path_idx = strfind(curr_path,match_folder_name);
if ~isempty(path_idx)
    options.root_path = curr_path(1:path_idx+length(match_folder_name)-1);
else
    error(['Can''t find folder ' match_folder_name ' in current directory list!']);
end

% Open dialog box for easier user input
% Since they're running this script, we'll set some default params
optionsString = 'vaEEG';

addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'Illusory_Contour_Task\Behavioral_Task\Stim'));
% end mps 20190730

options.displayFigs = 1;
options.practice.doPractice = 1;
options.practice.practiceBreak = 0;
options.analysisCheck = 1;
options.eyeTracking = 1;
options.etCalib = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);

% Initialize the eyetracker
if options.eyeTracking == 1
    % First find eyetracker
    options = findEyeTracker(options);
    
    % Next open the eye tracker manager to ensure correct head position
    options = openEyeTrackerManager_HeadPos(options);
end

options.compSetup = optionsString;
options.expName = 'Illusory_Contour_Task';
options.expPath = fullfile(options.root_path,options.expName,'\Behavioral_Task\');   % Path specific to the experiment % mps 20190730
options = getSubjRun(options,subjid,runid);
if strcmp(options.compSetup,'vaEEG')
    load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
    options.displayInfo = displayInfo;
elseif strcmp(options.compSetup,'arcEEG')
    load('Asus_VG248QE_EEGlab_lightsoff_20190613.mat','displayInfo');
    options.displayInfo = displayInfo;
elseif strcmp(options.compSetup,'vaCoglab')
    load('Asus_VG248QE_vaCoglab_lightsoff_20190904.mat','displayInfo');
    options.displayInfo = displayInfo;
else
    options.displayInfo.linearClut = 0:1/255:1;
end
options = localOptions(options);

%% Trial variables
% List variables to determine trial sequence
options.illFragList = [1 2];   % 1=illusory 2=fragmented
options.illFragNum = length(options.illFragList);
options.fatThinList = [1 2];   % 1=fat/left 2=thin/right
options.fatThinNum = length(options.fatThinList);
options.stairList = [1 2 3 4];   % 3 staircases for each condition
options.stairNum = length(options.stairList);

options.repetitions = 30;   % Number of trials in the staircase
options.practice.practiceRepetitions = 4;    % Number of practice trials/step

varList1 = repmat(fullfact([1 options.stairNum options.fatThinNum]),[options.repetitions/2 1]);   % varlist for first half of exp (illusory or fragmented)
varList2 = repmat(fullfact([1 options.stairNum options.fatThinNum]),[options.repetitions/2 1]);   % varlist for first half of exp (illusory or fragmented)
varList2(:,1) = 2;

% Determine which condition comes first based on the counter balancing file
% Check to see if the CB file has been created, if not create it, else load it in.
if exist(fullfile('../../IllContCounterBalance_2degDiam_6degDis_Behav.mat'),'file')
    load('../../IllContCounterBalance_2degDiam_6degDis_Behav','IllContCounterBalance');
else
    IllContCounterBalance.subjNum = options.subjID;
    IllContCounterBalance.condOrder = randi(2);
    save('../../IllContCounterBalance_2degDiam_6degDis_Behav','IllContCounterBalance');
end

% Check to see if this participant is already in the CB file, and if so use
% the condOrder previously assigned to them.
if any(strcmp(options.subjID, {IllContCounterBalance(:).subjNum}))
    options.condOrder = IllContCounterBalance(strcmp(options.subjID, {IllContCounterBalance(:).subjNum})).condOrder;
else
    % Set values in CB file
    numSubjsRun = length(IllContCounterBalance);
    IllContCounterBalance(numSubjsRun+1).subjNum = options.subjID;
    prevCondOrder = IllContCounterBalance(numSubjsRun).condOrder;
    if prevCondOrder == 1
        options.condOrder = 2;
    elseif prevCondOrder == 2
        options.condOrder = 1;
    end
    IllContCounterBalance(numSubjsRun+1).condOrder = options.condOrder;
    save('../../IllContCounterBalance_2degDiam_6degDis_Behav','IllContCounterBalance');
end

if options.condOrder == 1
    options.varList = [varList1; varList2];   % Combine the two lists
elseif options.condOrder == 2
    options.varList = [varList2; varList1];
end

% Randomized trial order for each varlist seperately
trialOrder1 = randperm(length(varList1))';
trialOrder2 = randperm(length(varList2))' + length(varList1);
options.trialOrder = [trialOrder1; trialOrder2];   % Combine the two lists
options.numTrials = length(options.trialOrder);

% Give participants a break in between blocks
options.break_trials = [options.numTrials/4+1 options.numTrials*3/4+1];   % Breaks half way through each block
options.blockCount = 0;   % Count the current block
options.blockCountArray = [1 options.break_trials(1) length(options.trialOrder)/2+1 options.break_trials(2) options.numTrials];

% Set up the trial sequence for the practice trials
options.practice.practiceAngleList = [20 18 16 14 12];
options.practice.practiceAngleNum = length(options.practice.practiceAngleList);
options.practice.practiceStimTimeList = [3.2 1.6 .8 .4 .2];
options.practice.practiceStimTimeNum = length(options.practice.practiceStimTimeList);
varListPractice1(:,1) = ones([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1]);
varListPractice1(:,2) = zeros([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1]);
varListPractice1(:,3) = zeros([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1]);
counter = 1;
for j=1:options.practice.practiceAngleNum
    for i=1:options.practice.practiceRepetitions
        varListPractice1(counter,2) = j;
        varListPractice1(counter,3) = j;
        
        counter = counter+1;
    end
end
varListPractice2(:,1) = ones([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1])+1;
varListPractice2(:,2) = varListPractice1(:,2);
varListPractice2(:,3) = varListPractice1(:,3);

if options.condOrder == 1
    options.practice.varListPractice = [varListPractice1; varListPractice2];   % Combine the two lists
elseif options.condOrder == 2
    options.practice.varListPractice = [varListPractice2; varListPractice1];
end

options.practice.trialOrderPractice = 1:length(options.practice.varListPractice);

clear varListPractice1 varListPractice2 varList1 varList2 trialOrder1 trialOrder2

% Variable to track values on each trial
data.rawdata = zeros([length(options.varList),11]);
data.practice.rawdataPractice = zeros([length(options.practice.varListPractice),11]);

options.practice.practiceCheck = 1;   % Variable that tells exp to present the practice trials at start of block

% Setup the stiarcase using palamedes
data.psyFunc = @PAL_Logistic; %psychometric function to fit
data.guessrate = 0.5; % gamma value (baseline) for fitting
data.lapserate = 0.04; % probability of making an error during response, damien suggests 4% for naive subj
data.xL = [.5:.25:6 6.5:.5:15 16:20]; % range of tilt angles to use
data.aL = .5:.5:20; % threshold prior range
data.bL = exp(-4:.2:3); % slope prior range

for i = 1:options.illFragNum   % Number of staircases to setup
    for j = 1:options.stairNum
        data.stair(i,j) = PAL_AMPM_setupPM('priorAlphaRange',data.aL,...
            'priorBetaRange',data.bL,...
            'stimRange',data.xL,...
            'gamma',data.guessrate,...
            'lambda',data.lapserate,...
            'PF',data.psyFunc,...
            'numTrials',options.repetitions,...
            'gammaEQlambda',0); % creates psi data structure % mps 20190730 setting gammaEQlambda = 0
    end
end

%% Stimulus variables
% Make fixation points
options.blackFixation = do_fixation(options);
options.fixationRect = [options.xc - options.fix.fixSizeOuter/2*options.PPD,...
    options.yc - options.fix.fixSizeOuter/2*options.PPD,...
    options.xc + options.fix.fixSizeOuter/2*options.PPD,...
    options.yc + options.fix.fixSizeOuter/2*options.PPD];
options.blinkFixation = do_fixation_blink(options);

% Size variables
options.stim.circDia = 2;   % Diameter of the circle
options.stim.circDist = 6;   % Distance between the center points of each circle

% Illusory angle variables - the initial angle each of the texture is rotated
options.stim.texAngleIllusory(1) = 0;   % Upper left
options.stim.texAngleIllusory(2) = 0;   % Upper right
options.stim.texAngleIllusory(3) = 270;   % Lower left
options.stim.texAngleIllusory(4) = 90;   % Lower right
% Fragmented angle variables - the initial angle each of the texture is rotated
options.stim.texAngleFragmented(1) = 45;   % Upper left
options.stim.texAngleFragmented(2) = 315;   % Upper right
options.stim.texAngleFragmented(3) = 45;   % Lower left
options.stim.texAngleFragmented(4) = 315;   % Lower right

% Make two textures, for left and right, to draw the inducers onto
texArray(:,:,1) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(1);
texArray(:,:,2) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(2);
texArray(:,:,3) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(3);
options.stim.inducerTex(1) = Screen('MakeTexture',options.windowNum,texArray);
options.stim.inducerTex(2) = Screen('MakeTexture',options.windowNum,texArray);
% Draw a circle w/ overlapped gray square on both textures in correct
% position
Screen('FillOval',options.stim.inducerTex(1),options.whiteCol,[0 0 ceil(options.stim.circDia*options.PPD) ceil(options.stim.circDia*options.PPD)]);
Screen('FillRect',options.stim.inducerTex(1),options.grayCol,[ceil((options.stim.circDia*options.PPD)/2) ceil((options.stim.circDia*options.PPD)/2)...
    ceil((options.stim.circDia*options.PPD)) ceil((options.stim.circDia*options.PPD))]);
Screen('FillOval',options.stim.inducerTex(2),options.whiteCol,[0 0 ceil(options.stim.circDia*options.PPD) ceil(options.stim.circDia*options.PPD)]);
Screen('FillRect',options.stim.inducerTex(2),options.grayCol,[0 ceil((options.stim.circDia*options.PPD)/2)...
    ceil((options.stim.circDia*options.PPD)/2) ceil(options.stim.circDia*options.PPD)]);

% Make a texture for the mask
maskTexArray(:,:,1) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(1);
maskTexArray(:,:,2) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(2);
maskTexArray(:,:,3) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(3);
options.stim.maskTex = Screen('MakeTexture',options.windowNum,maskTexArray);
% Draw four complete circles (mask)
Screen('FillOval',options.stim.maskTex,options.whiteCol,[0 0 ceil(options.stim.circDia*options.PPD) ceil(options.stim.circDia*options.PPD)]);

% Position of each of the 4 inducers
options.stim.circPositionArray(1,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(2,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(3,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)-(( options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(4,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)];

% Overall tilt
% The sign of the rotation is always relative to the first inducer.
options.stim.overallTilt = 0;   % Amount of tilt we apply to all textures relative to starting position
% Values to multiple options.stim.overallTilt by to get the correct rotation angle for each of the 4 inducers
options.stim.texAngleTilt(1,:) = [1 -1 -1 1];
options.stim.texAngleTilt(2,:) = [1 1 1 1];

% Timing variables in seconds
options.stim.blankInterval = 1;
options.stim.stimPresInterval = .2;
options.stim.isiInterval = .05;
options.stim.maskInterval = .3;
options.stim.respInterval = 1.5;

%% Setup / Calibrate Eyetracker
if options.eyeTracking == 1
    
    % Start calibration
    % Make the calibration file
    options.calibration_path = sprintf('%s%s%s%s%s%s','../../../../SYON_Eyetracking/ETCalib_',options.subjID,'_',options.datecode,'.mat');
    
    % First check to see if there is a calibration file for the subject
    % already.
    if options.etCalib == 0   % Based on user input can check if they want to do calibration
        
        if isfile(options.calibration_path)
            
            text1='Calibration file found. Would you like to load existing calibration? (y or n)';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.fixCol);
            Screen('Flip',options.windowNum);
            
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonY)   % If yes, then load in the existing calibration file.
                    options.calib_data = options.ETOptions.eyeTracker.retrieve_calibration_data();
                    
                    fid = fopen(optinos.calibration_path,'w');
                    fwrite(fid,options.calib_data);
                    fclose(fid);
                    
                    options.ETOptions.eyeTracker.apply_calibration_data(options.calib_data)
                    break
                elseif keycode(options.buttons.buttonN)   % If no, then just start experiment...
                    break
                end
            end
        else   % If there is no calibration file, and they chose not to run, then just start experiment...
        end
    else
        if isfile(options.calibration_path)
            
            text1='Calibration file found. Would you like to run the calibration again? (y or n)';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.fixCol);
            Screen('Flip',options.windowNum);
            
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonY)   % If yes, then rerun calibration.
                    % Start calibration
                    options = EyeTrack_Calibration_WindowOpen(options);
                    break
                elseif keycode(options.buttons.buttonN)   % If no, then load existing calibration.
                    options.calib_data = options.ETOptions.eyeTracker.retrieve_calibration_data();
                    
                    fid = fopen(options.calibration_path,'w');
                    fwrite(fid,options.calib_data);
                    fclose(fid);
                    
                    options.ETOptions.eyeTracker.apply_calibration_data(options.calib_data)
                    break
                end
            end
        else   % If there is no calibration file, then run calibration
            % Start calibration
            options = EyeTrack_Calibration_WindowOpen(options);
        end
        
    end
    
    % Initialize ET variables
    etData.etCounter = 0;
    etData.blockStart = options.ETOptions.Tobii.get_system_time_stamp;
    
end

%% Draw stimuli
[keyisdown, secs, keycode] = KbCheck(options.dev_id);
expStart = GetSecs;
for n=1:length(options.trialOrder)
    
    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
    
    % Check to see if we need to run practice trials
    if options.practice.doPractice == 1
        if n==1 || n==length(options.trialOrder)/2+1
            options.practice.practiceCheck = 1;
        end
        
        if options.practice.practiceCheck == 1
            % Present instructions and examples
            if options.condOrder == 1   % If illusory first
                if n==1
                    [options,data] = IllContExp_IllPrac(options,data);
                elseif n==length(options.trialOrder)/2+1
                    % Calculate accuracy for this block
                    options.blockCount = options.blockCount + 1;
                    data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),10))*100;
                    data.blockRT(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),9));
                    
                    text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(options.blockCount),'% of trials correctly.');
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
                    DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
                    text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(options.blockCount),'s to respond on average. Good job!');
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
                    DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);
                    
                    % display break message
                    text1='Please take a break. Feel free to blink or move your eyes.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,options.fixCol);
                    text2='You''re doing great!';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,options.fixCol);
                    text3='We''re finished with the ''wide'' and ''narrow'' trials!';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,options.fixCol);
                    text4='Let the experimenter know when you are ready to continue...';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                    DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-200,options.fixCol);
                    Screen('Flip',options.windowNum);
                    WaitSecs(1);
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            break;
                        end
                    end
                    
                    % Save teh ET data if collecting
                    if options.eyeTracking == 1
                        
                        % First reformat the ET data from its Tobii object format
                        for i = 1:length(gzDataHolder)
                            if ~isempty(gzDataHolder.data{i})
                                deviceTimeHolder = double(cell2mat({gzDataHolder.data{i}.DeviceTimeStamp}));
                                gzData{i}.DeviceTimeStamp = deviceTimeHolder;
                                
                                clear deviceTimeHolder
                            else
                                gzData{i}.DeviceTimeStamp = [];
                            end
                            
                            if ~isempty(gzDataHolder.data{i})
                                systemTimeHolder = double(cell2mat({gzDataHolder.data{i}.SystemTimeStamp}));
                                gzData{i}.SystemTimeStamp = systemTimeHolder;
                                
                                clear systemTimeHolder
                            else
                                gzData{i}.SystemTimeStamp = [];
                            end
                            
                            if ~isempty(gzDataHolder.data{i})
                                leftEyeHolder = {gzDataHolder.data{i}(:).LeftEye};
                                rightEyeHolder = {gzDataHolder.data{i}(:).RightEye};
                                
                                for j = 1:length(leftEyeHolder)
                                    gzData{i}.LeftEye.GazePoint(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                                    gzData{i}.LeftEye.GazePoint(j,:).OnDisplayArea = double(leftEyeHolder{j}.GazePoint.OnDisplayArea);
                                    gzData{i}.LeftEye.GazeOrigin(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                                    gzData{i}.LeftEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                                    gzData{i}.LeftEye.PointValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                                    gzData{i}.LeftEye.OriginValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                                    gzData{i}.LeftEye.Pupil(j,:) = double(leftEyeHolder{j}.Pupil.Diameter);
                                    gzData{i}.LeftEye.PupilValidity(j,:) = double(leftEyeHolder{j}.Pupil.Validity.value);
                                    
                                    gzData{i}.RightEye.GazePoint(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                                    gzData{i}.RightEye.GazePoint(j,:).OnDisplayArea = double(rightEyeHolder{j}.GazePoint.OnDisplayArea);
                                    gzData{i}.RightEye.GazeOrigin(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                                    gzData{i}.RightEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                                    gzData{i}.RightEye.PointValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                                    gzData{i}.RightEye.OriginValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                                    gzData{i}.RightEye.Pupil(j,:) = double(rightEyeHolder{j}.Pupil.Diameter);
                                    gzData{i}.RightEye.PupilValidity(j,:) = double(rightEyeHolder{j}.Pupil.Validity.value);
                                end
                                
                                clear leftEyeHolder rightEyeHolder
                            else
                                gzData{i}.LeftEye.GazePoint.InUserCoordinateSystem = [];
                                gzData{i}.LeftEye.GazePoint.OnDisplayArea = [];
                                gzData{i}.LeftEye.GazeOrigin.InUserCoordinateSystem = [];
                                gzData{i}.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                                gzData{i}.LeftEye.PointValidity = [];   % Validity for gaze point
                                gzData{i}.LeftEye.OriginValidity = [];   % Validity for origin point
                                gzData{i}.LeftEye.Pupil = [];
                                gzData{i}.LeftEye.PupilValidity = [];
                                
                                gzData{i}.RightEye.GazePoint.InUserCoordinateSystem = [];
                                gzData{i}.RightEye.GazePoint.OnDisplayArea = [];
                                gzData{i}.RightEye.GazeOrigin.InUserCoordinateSystem = [];
                                gzData{i}.RightEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                                gzData{i}.RightEye.PointValidity = [];   % Validity for gaze point
                                gzData{i}.RightEye.OriginValidity = [];   % Validity for origin point
                                gzData{i}.RightEye.Pupil = [];
                                gzData{i}.RightEye.PupilValidity = [];
                            end
                            
                        end
                        
                        cd e:/SYON_Eyetracking/
                        % Not sure why saving twice w/ etData and etData/gzData, commented out first save and cd back into relevant stim folder - KWK 20211012 
%                         save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData')
                        %                         cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/EEG_Task/Stim
                        save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData','gzData')
%                         cd ../../Behavioral_Task/Stim
                        cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/Behavioral_Task/Stim
                        
                        % Clear the ET save file to make memory for next block
                        clear etData gzDataHolder gzData
                        etData.etCounter = 0;
                        etData.blockStart = options.ETOptions.Tobii.get_system_time_stamp;
                    end
                    
                    [options,data] = IllContExp_FragPrac(options,data);
                end
            elseif options.condOrder == 2   % If fragmented first
                if n==1
                    [options,data] = IllContExp_FragPrac(options,data);
                elseif n==length(options.trialOrder)/2+1
                    % Calculate accuracy for this block
                    options.blockCount = options.blockCount + 1;
                    data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),10))*100;
                    data.blockRT(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),9));
                    
                    text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(options.blockCount),'% of trials correctly.');
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
                    DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
                    text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(options.blockCount),'s to respond on average. Good job!');
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
                    DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);
                    
                    % display break message
                    text1='Please take a break. Feel free to blink or move your eyes.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,options.fixCol);
                    text2='You''re doing great!';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,options.fixCol);
                    text3='We''re finished with the ''left'' and ''right'' trials!';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,options.fixCol);
                    text4='Let the experimenter know when you are ready to continue...';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                    DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-200,options.fixCol);
                    Screen('Flip',options.windowNum);
                    WaitSecs(1);
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            break;
                        end
                    end
                    
                    % Save teh ET data if collecting
                    if options.eyeTracking == 1
                        % First reformat the ET data from its Tobii object format
                        for i = 1:length(gzDataHolder)
                            if ~isempty(gzDataHolder.data{i})
                                deviceTimeHolder = double(cell2mat({gzDataHolder.data{i}.DeviceTimeStamp}));
                                gzData{i}.DeviceTimeStamp = deviceTimeHolder;
                                
                                clear deviceTimeHolder
                            else
                                gzData{i}.DeviceTimeStamp = [];
                            end
                            
                            if ~isempty(gzDataHolder.data{i})
                                systemTimeHolder = double(cell2mat({gzDataHolder.data{i}.SystemTimeStamp}));
                                gzData{i}.SystemTimeStamp = systemTimeHolder;
                                
                                clear systemTimeHolder
                            else
                                gzData{i}.SystemTimeStamp = [];
                            end
                            
                            if ~isempty(gzDataHolder.data{i})
                                leftEyeHolder = {gzDataHolder.data{i}(:).LeftEye};
                                rightEyeHolder = {gzDataHolder.data{i}(:).RightEye};
                                
                                for j = 1:length(leftEyeHolder)
                                    gzData{i}.LeftEye.GazePoint(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                                    gzData{i}.LeftEye.GazePoint(j,:).OnDisplayArea = double(leftEyeHolder{j}.GazePoint.OnDisplayArea);
                                    gzData{i}.LeftEye.GazeOrigin(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                                    gzData{i}.LeftEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                                    gzData{i}.LeftEye.PointValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                                    gzData{i}.LeftEye.OriginValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                                    gzData{i}.LeftEye.Pupil(j,:) = double(leftEyeHolder{j}.Pupil.Diameter);
                                    gzData{i}.LeftEye.PupilValidity(j,:) = double(leftEyeHolder{j}.Pupil.Validity.value);
                                    
                                    gzData{i}.RightEye.GazePoint(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                                    gzData{i}.RightEye.GazePoint(j,:).OnDisplayArea = double(rightEyeHolder{j}.GazePoint.OnDisplayArea);
                                    gzData{i}.RightEye.GazeOrigin(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                                    gzData{i}.RightEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                                    gzData{i}.RightEye.PointValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                                    gzData{i}.RightEye.OriginValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                                    gzData{i}.RightEye.Pupil(j,:) = double(rightEyeHolder{j}.Pupil.Diameter);
                                    gzData{i}.RightEye.PupilValidity(j,:) = double(rightEyeHolder{j}.Pupil.Validity.value);
                                end
                                
                                clear leftEyeHolder rightEyeHolder
                            else
                                gzData{i}.LeftEye.GazePoint.InUserCoordinateSystem = [];
                                gzData{i}.LeftEye.GazePoint.OnDisplayArea = [];
                                gzData{i}.LeftEye.GazeOrigin.InUserCoordinateSystem = [];
                                gzData{i}.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                                gzData{i}.LeftEye.PointValidity = [];   % Validity for gaze point
                                gzData{i}.LeftEye.OriginValidity = [];   % Validity for origin point
                                gzData{i}.LeftEye.Pupil = [];
                                gzData{i}.LeftEye.PupilValidity = [];
                                
                                gzData{i}.RightEye.GazePoint.InUserCoordinateSystem = [];
                                gzData{i}.RightEye.GazePoint.OnDisplayArea = [];
                                gzData{i}.RightEye.GazeOrigin.InUserCoordinateSystem = [];
                                gzData{i}.RightEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                                gzData{i}.RightEye.PointValidity = [];   % Validity for gaze point
                                gzData{i}.RightEye.OriginValidity = [];   % Validity for origin point
                                gzData{i}.RightEye.Pupil = [];
                                gzData{i}.RightEye.PupilValidity = [];
                            end
                            
                        end
                        
                        % Not sure why saving twice w/ etData and etData/gzData, commented out first save and cd back into relevant stim folder - KWK 20211012 
                        cd e:/SYON_Eyetracking/
%                         save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData')
%                         cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/EEG_Task/Stim
                        save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData','gzData')
                        cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/Behavioral_Task/Stim
                        
                        % Clear the ET save file to make memory for next block
                        clear etData gzDataHolder gzData
                        etData.etCounter = 0;
                        etData.blockStart = options.ETOptions.Tobii.get_system_time_stamp;
                    end
                    
                    [options,data] = IllContExp_IllPrac(options,data);
                end
            end
        end
    elseif n==1 && options.practice.doPractice ~= 1
        % Last instructions before the experiment starts
        WaitSecs(.5);
        text1='Now we will start the experiment.';
        text2='Please let the experimenter know if you have any questions or concerns.';
        text3='Tell the experimenter when you are ready to continue...';
        text4='LAST SCREEN BEFORE EXPERIMENT START!';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
        DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
        DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.fixCol);
        Screen('Flip',options.windowNum);
        
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        while 1
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonF)
                break
            end
            if keycode(options.buttons.buttonEscape)
                options.practice.practiceBreak = 1;
                break
            end
        end
    end
    
    % If someone escapes in the practice function quit the main exp too.
    if options.practice.practiceBreak ~= 1
        
        % Set up breaks in between blocks
        this_b = 0;
        for b = options.break_trials
            if n == b
                this_b = b;
                break
            end
        end
        if this_b
            % Calculate accuracy for this block
            options.blockCount = options.blockCount + 1;
            data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),10))*100;
            data.blockRT(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),9));
            
            text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(options.blockCount),'% of trials correctly.');
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
            text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(options.blockCount),'s to respond on average. Good job!');
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);
            
            % display break message
            text1='Please take a break. Feel free to blink or move your eyes.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,options.fixCol);
            text2='You''re doing great!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,options.fixCol);
            text3='Let the experimenter know when you are ready to continue...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,options.fixCol);
            Screen('Flip',options.windowNum);
            WaitSecs(1);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    break;
                end
            end
            
            % Save teh ET data if collecting
            if options.eyeTracking == 1
                % First reformat the ET data from its Tobii object format
                for i = 1:length(gzDataHolder.data)
                    if ~isempty(gzDataHolder.data{i})
                        deviceTimeHolder = double(cell2mat({gzDataHolder.data{i}.DeviceTimeStamp}));
                        gzData{i}.DeviceTimeStamp = deviceTimeHolder;
                        
                        clear deviceTimeHolder
                    else
                        gzData{i}.DeviceTimeStamp = [];
                    end
                    
                    if ~isempty(gzDataHolder.data{i})
                        systemTimeHolder = double(cell2mat({gzDataHolder.data{i}.SystemTimeStamp}));
                        gzData{i}.SystemTimeStamp = systemTimeHolder;
                        
                        clear systemTimeHolder
                    else
                        gzData{i}.SystemTimeStamp = [];
                    end
                    
                    if ~isempty(gzDataHolder.data{i})
                        leftEyeHolder = {gzDataHolder.data{i}(:).LeftEye};
                        rightEyeHolder = {gzDataHolder.data{i}(:).RightEye};
                        
                        for j = 1:length(leftEyeHolder)
                            gzData{i}.LeftEye.GazePoint(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                            gzData{i}.LeftEye.GazePoint(j,:).OnDisplayArea = double(leftEyeHolder{j}.GazePoint.OnDisplayArea);
                            gzData{i}.LeftEye.GazeOrigin(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                            gzData{i}.LeftEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                            gzData{i}.LeftEye.PointValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                            gzData{i}.LeftEye.OriginValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                            gzData{i}.LeftEye.Pupil(j,:) = double(leftEyeHolder{j}.Pupil.Diameter);
                            gzData{i}.LeftEye.PupilValidity(j,:) = double(leftEyeHolder{j}.Pupil.Validity.value);
                            
                            gzData{i}.RightEye.GazePoint(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                            gzData{i}.RightEye.GazePoint(j,:).OnDisplayArea = double(rightEyeHolder{j}.GazePoint.OnDisplayArea);
                            gzData{i}.RightEye.GazeOrigin(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                            gzData{i}.RightEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                            gzData{i}.RightEye.PointValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                            gzData{i}.RightEye.OriginValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                            gzData{i}.RightEye.Pupil(j,:) = double(rightEyeHolder{j}.Pupil.Diameter);
                            gzData{i}.RightEye.PupilValidity(j,:) = double(rightEyeHolder{j}.Pupil.Validity.value);
                        end
                        
                        clear leftEyeHolder rightEyeHolder
                    else
                        gzData{i}.LeftEye.GazePoint.InUserCoordinateSystem = [];
                        gzData{i}.LeftEye.GazePoint.OnDisplayArea = [];
                        gzData{i}.LeftEye.GazeOrigin.InUserCoordinateSystem = [];
                        gzData{i}.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                        gzData{i}.LeftEye.PointValidity = [];   % Validity for gaze point
                        gzData{i}.LeftEye.OriginValidity = [];   % Validity for origin point
                        gzData{i}.LeftEye.Pupil = [];
                        gzData{i}.LeftEye.PupilValidity = [];
                        
                        gzData{i}.RightEye.GazePoint.InUserCoordinateSystem = [];
                        gzData{i}.RightEye.GazePoint.OnDisplayArea = [];
                        gzData{i}.RightEye.GazeOrigin.InUserCoordinateSystem = [];
                        gzData{i}.RightEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
                        gzData{i}.RightEye.PointValidity = [];   % Validity for gaze point
                        gzData{i}.RightEye.OriginValidity = [];   % Validity for origin point
                        gzData{i}.RightEye.Pupil = [];
                        gzData{i}.RightEye.PupilValidity = [];
                    end
                    
                end
                
                % Not sure why saving twice w/ etData and etData/gzData, commented out first save and cd back into relevant stim folder - KWK 20211012 
                cd e:/SYON_Eyetracking/
%                 save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData')
%                 cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/EEG_Task/Stim
                save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData','gzData')
                cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/Behavioral_Task/Stim
                
                % Clear the ET save file to make memory for next block
                clear etData gzDataHolder gzData
                etData.etCounter = 0;
                etData.blockStart = options.ETOptions.Tobii.get_system_time_stamp;
            end
        end
        
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
        
        data.rawdata(n,1) = n;   % Trial order
        data.rawdata(n,2) = options.trialOrder(n);   % Trial number
        illFragIdx = options.varList(options.trialOrder(n),1);   % Illusory or framented condition
        data.rawdata(n,3) = illFragIdx;
        fatThinIdx = options.varList(options.trialOrder(n),3);   % presenting fat/thin or right/left for this trial
        data.rawdata(n,4) = fatThinIdx;
        stairIdx = options.varList(options.trialOrder(n),2);   % Determine what staircase you are on for this trial
        data.rawdata(n,5) = stairIdx;
        
        % Choose the starting rotation angle of the textures.
        %     illFragIdx = 2;
        switch illFragIdx
            case 1
                texAngle = options.stim.texAngleIllusory;
            case 2
                texAngle = options.stim.texAngleFragmented;
        end
        
        % Choose the amount of tilt offset from start
        if stairIdx == 4
            options.stim.overallTilt = data.xL(end);   % For the 4th staircase, we just want to use max value. (catch trials)
        else
            options.stim.overallTilt = data.stair(illFragIdx,stairIdx).xCurrent;
        end
        
        % Choose whether you are looking for fat/right or thin/left
        %     fatThinIdx = 2;
        if fatThinIdx==1   % Fat/left
        elseif fatThinIdx==2   % Thin/right
            options.stim.overallTilt = options.stim.overallTilt*(-1);
        end
        
        % Start trial presentation
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        sync_time = Screen('Flip',options.windowNum);
        
        % Start eyetracking
        if options.eyeTracking == 1
            options.ETOptions.eyeTracker.get_gaze_data();
        end
        
        % Start with blank screen
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, blankOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time) - options.flip_interval_correction);
        
        % Draw stim
        Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2) options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
            options.stim.circPositionArray',texAngle+(options.stim.overallTilt.*options.stim.texAngleTilt(illFragIdx,:)));
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, stimOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (blankOnsetTime+options.stim.blankInterval)-options.flip_interval_correction);
        
        if options.eyeTracking == 1
            
            if illFragIdx == 1   % Illusory condition
                if fatThinIdx == 1
                    options.default(n) = 2;   % Fat
                elseif fatThinIdx == 2
                    options.default(n) = 3;   % Thin
                end
            elseif illFragIdx == 2   % Fragmented condition
                switch fatThinIdx
                    case 1
                        options.default(n) = 4;
                    case 2
                        options.default(n) = 5;
                    case 3
                        options.default(n) = 6;
                    case 4
                        options.default(n) = 7;
                    case 5
                        options.default(n) = 8;
                    case 6
                        options.default(n) = 9;
                    case 7
                        options.default(n) = 10;
                    case 8
                        options.default(n) = 11;
                end
            end
            
            % Counter for eyetracking struct
            etData.etCounter = etData.etCounter + 1;
            
            % From Tobii's website on 'simple psychtoolbox code' for Matlab
            % SDK
            % Event when startng to show the stimulus
            % Second value is the event marker first is the time stamp
            etData.events{1,etData.etCounter} = {options.ETOptions.Tobii.get_system_time_stamp, };
            
        end
        
        % ISI
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, isiOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.stimPresInterval+stimOnsetTime)-options.flip_interval_correction);
        
        % Mask
        Screen('DrawTextures',options.windowNum,[options.stim.maskTex options.stim.maskTex options.stim.maskTex options.stim.maskTex],[],...
            options.stim.circPositionArray');
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, maskOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.isiInterval+isiOnsetTime)-options.flip_interval_correction);
        
        % Mask offset
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, maskOffsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.maskInterval+maskOnsetTime)-options.flip_interval_correction);
        
        
        % Response
        responseBreak = 0;
        % Response screen
        if illFragIdx==1   % Illusory condition
            feedBackText = 'Wide or Narrow?';
        elseif illFragIdx==2   % Fragmented condition
            feedBackText = 'Left or Right?';
        end
        
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
        DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-100);
        Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
        [~, respOnset, ~, ~, ~] = Screen('Flip',options.windowNum);
        
        % Grab eyetracking data for this trial
        if options.eyeTracking == 1
            gzDataHolder.data{etData.etCounter} = options.ETOptions.eyeTracker.get_gaze_data();   % NOT SURE IF THIS WILL WORK NEED TO TEST - KWK 20210216
        end
        
        while 1
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            
            switch responseBreak
                case 0
                    %                     if any(firstPress(options.buttons.buttonLeft))   % Left facing/fat
                    %                         data.rawdata(n,8) = 1;   % Record response
                    %                         data.rawdata(n,9) = firstPress(options.buttons.buttonLeft)-respOnset;   % Response time
                    %                         responseBreak = 1;
                    %                     end
                    %                     if any(firstPress(options.buttons.buttonRight))   % Right facing/thin
                    %                         data.rawdata(n,8) = 2;   % Record response
                    %                         data.rawdata(n,9) = firstPress(options.buttons.buttonRight)-respOnset;   % Response time
                    %                         responseBreak = 1;
                    %                     end
                    if buttonsHolder(1) == 1   % Left facing/fat
                        data.rawdata(n,8) = 1;   % Record response
                        data.rawdata(n,9) = GetSecs-respOnset;   % Response time
                        responseBreak = 1;
                    elseif buttonsHolder(3) == 1   % Right facing/thin
                        data.rawdata(n,8) = 2;   % Record response
                        data.rawdata(n,9) = GetSecs-respOnset;   % Response time
                        responseBreak = 1;
                    end
                case 1
                    break
                otherwise
            end
            %                 case 1
            %                     break
            %             end
        end
        
        % If no response, make nan
        if data.rawdata(n,8)==0 && data.rawdata(n,9)==0
            data.rawdata(n,8) = NaN;   % NaN=no response
            data.rawdata(n,9) = NaN;
        end
        
        % Record timing and response
        data.rawdata(n,6) = sync_time - expStart;   % Stim pres time relative to exp start
        data.rawdata(n,7) = isiOnsetTime - stimOnsetTime;   % Stim pres length
        
        % Determine correct/incorrect for this trial to update the
        % staircase
        if illFragIdx == 1   % Illusory condition
            if  fatThinIdx == 1   % Fat
                if data.rawdata(n,8) == 1   % Responded fat
                    % Was fat they responded fat
                    data.rawdata(n,10) = 1;
                elseif data.rawdata(n,8) == 2   % Responded thin
                    % Was fat they responded thin
                    data.rawdata(n,10) = 0;
                end
            elseif fatThinIdx == 2   % Thin
                if data.rawdata(n,8) == 1   % Responded fat
                    % Was thin they responded fat
                    data.rawdata(n,10) = 0;
                elseif data.rawdata(n,8) == 2   % Responded thin
                    % Was thin they responded thin
                    data.rawdata(n,10) = 1;
                end
            end
        elseif illFragIdx == 2   % Fragmented condition
            if  fatThinIdx == 1   % Left facing
                if data.rawdata(n,8) == 1   % Responded left
                    data.rawdata(n,10) = 1;
                elseif data.rawdata(n,8) == 2   % Responded right
                    data.rawdata(n,10) = 0;
                end
            elseif fatThinIdx == 2   % Right facing
                if data.rawdata(n,8) == 1   % Responded left
                    data.rawdata(n,10) = 0;
                elseif data.rawdata(n,8) == 2   % Responded right
                    data.rawdata(n,10) = 1;
                end
            end
        end
        
        if stairIdx == 4
            data.rawdata(n,11) = data.xL(end);
        else
            data.rawdata(n,11) = data.stair(illFragIdx,stairIdx).xCurrent;
        end
        
        % Update the staircase
        data.stair(illFragIdx,stairIdx) = PAL_AMPM_updatePM(data.stair(illFragIdx,stairIdx),data.rawdata(n,10));
        
        
        % Close open textures
        %         Screen('Close',[options.stim.inducerTex(1), options.stim.inducerTex(2), options.stim.maskTex]');
        
        if keycode(options.buttons.buttonEscape)
            break
        end
        
        % Save
        cleanUp(options,data,1)
        
    else
        break
    end
    
    if n==length(options.trialOrder)
        options.analysisCheck = 1;
    end
    
end

%% Calculate threshold and save to threshold file
% If they finished the experiment
if options.practice.practiceBreak ~= 1
    
    % Make the rawdata variable into a table so it's easier for others to read
    for i=1:size(data.rawdata,2)
        t(:,i)=table(data.rawdata(:,i));
    end
    t.Properties.VariableNames = {'PresOrder','TrialNumber','Illusory_Fragmented',...
        'Fat_Thin','StairNum','StimPresTime','StimPresLength','Response','ReationTime','Accuracy','StepLevel'};
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,fullfile(options.datadir,options.datafile));
    
    % Set the stair struct and rawdata to a data struct to send to save
    data.rawdataT = t;
    
    % Save data before doing the analysis
    cleanUp(options,data,1)
    
    if options.analysisCheck == 1
        data.thresh.estimate_lapse_from_catch = 1; % do we estimate the upper asymptote for
        % accuracy based on performance on catch trials, or just assume a fixed
        % value?
        data.thresh.thresh_pct = 0.8; % pct correct to evaluate for threshold % mps 20190730 changing to 0.8
        data.thresh.min_lapse = 0.033; % this is the lowest we'll ever set the lapse rate,
        % regardless of catch performance. Since there's 30 catch trials,
        % this conservatively assumes everyone will miss 1/30...
        data.thresh.max_thresh = data.xL(end); % maximum theoretical threshold, exclude if outside % mps 20190730 max = 20
        data.thresh.min_thresh = 0; % mps 20190730 min = 0
        
        data.thresh.paramsFree = [1 1 0 0]; % which parameters to fit, (1 = threshold, 2 = slope, 3 =
        data.thresh.PF = @PAL_Logistic; % which psychometric function to use
        
        plot_symbols = {'o','s','^'};
        plot_lines = {'-','--','-.'};
        cond_label{1} = 'Illusory';
        cond_label{2} = 'Fragmented';
        
        
        for i=1:options.illFragNum   % Num conditions
            if options.displayFigs == 1; figure; end % mps 20190730
            for j=1:size(data.stair,2)-1   % Num staircases
                
                data.thresh.catch_accuracy(i,j) = nanmean(data.stair(i,length(data.stair)).response);   % Determine catch trial accuracy
                
                clear numPos outOfNum
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
                data.thresh.searchGrid(i,j).gamma = 0.5;
                if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
                    data.thresh.searchGrid(i,j).lambda = max([1-mean(data.thresh.catch_accuracy(i,j)) data.thresh.min_lapse]);
                else % else assume fixed value used during task
                    data.thresh.searchGrid(i,j).lambda = data.stair(i,j).lambda;
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
                    subplot(1,length(data.stair)+1,j); hold on % one subplot per condition
                    for iX = 1:numel(data.thresh.stimLevels{i,j}) % plot raw data (accuracy vs. stimulus intensity, larger symbols for more trials)
                        plot(data.thresh.stimLevels{i,j}(iX),data.thresh.numPos{i,j}(iX)/data.thresh.outOfNum{i,j}(iX),...
                            ['g' plot_symbols{1}],'MarkerSize',data.thresh.outOfNum{i,j}(iX)+2,...
                            'linewidth',2);
                    end
                    x_val = 0:0.01:data.xL(end);
                    plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-'); % threshold fiducial line
                    
                    %                 plot(x_val,PF(old_params,x_val),['c' plot_lines{1}])
                    
                    plot(x_val,data.thresh.PF(squeeze(data.thresh.paramsFit(i,j,:)),x_val),['b' plot_lines{1}],...
                        'linewidth',2); % plot refit psychometric function
                    
                    %                 plot([thresh_old(iS,iC,iR) thresh_old(iS,iC,iR)],[0 1],...
                    %                     ['m' plot_lines{1}])
                    
                    plot([data.thresh.thresh_refit(i,j) data.thresh.thresh_refit(i,j)],[0 1],...
                        ['r'  plot_lines{1}],'linewidth',2) % plot refit threshold
                    
                    axis([0 10 -0.05 1.05])
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
            for j=1:size(data.stair,2)-1
                data.thresh.ave(i).xComb = [data.thresh.ave(i).xComb data.stair(i,j).x(1:end-1)];
                data.thresh.ave(i).responseComb = [data.thresh.ave(i).responseComb data.stair(i,j).response];
            end
            data.thresh.ave(i).stimLevels = unique(data.thresh.ave(i).xComb);
            
            for k=1:length(data.thresh.ave(i).stimLevels)
                find_x = find(data.thresh.ave(i).xComb == data.thresh.ave(i).stimLevels(k));   % Find the indices
                data.thresh.ave(i).numPos(k) = length(find(data.thresh.ave(i).responseComb(find_x) == 1));   % How many were correctly responded to
                data.thresh.ave(i).outOfNum(k) = length(find_x);   % How many total
            end
            
            data.thresh.ave(i).searchGrid.alpha = data.stair(1,1).priorAlphaRange;
            data.thresh.ave(i).searchGrid.beta = data.stair(1,1).priorBetaRange;
            data.thresh.ave(i).searchGrid.gamma = 0.5;
            if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
                data.thresh.ave(i).searchGrid.lambda = max([1-mean(data.thresh.catch_accuracy(i,j)) data.thresh.min_lapse]);
            else % else assume fixed value used during task
                data.thresh.ave(i).searchGrid.lambda = data.stair(1,1).lambda;
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
                subplot(1,length(data.stair)+1,length(data.stair)); hold on
                
                % Plot rawdata acc
                for j=1:numel(data.thresh.ave(i).stimLevels)
                    plot(data.thresh.ave(i).stimLevels(j),data.thresh.ave(i).numPos(j)/data.thresh.ave(i).outOfNum(j),...
                        ['g' plot_symbols{1}],'MarkerSize',data.thresh.ave(i).outOfNum(j)+2,'linewidth',2)
                end
                
                % Thresh fiducial line
                x_val = 0:0.01:data.xL(end);
                plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
                
                % Refit psychometric function
                plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(i).paramsFit(:)),x_val),['b' plot_lines{1}],...
                    'linewidth',2);
                
                % Refit threshold
                plot([data.thresh.ave(i).thresh_refit data.thresh.ave(i).thresh_refit],[0 1],...
                    ['r' plot_lines{i}],'linewidth',2);
                
                axis([0 10 -0.05 1.05])
                box off
                
                title([cond_label{i} ' - Combined']);
                set(gca,'fontsize',12)
                
                % Plot catch acc
                subplot(1,length(data.stair)+1,length(data.stair)+1); hold on
                bar(1,nanmean(data.thresh.catch_accuracy(i,:),2));
                errorbar(1,nanmean(data.thresh.catch_accuracy(i,:),2),...
                    nanstd(data.thresh.catch_accuracy(i,:),0,2)/...
                    sqrt(numel(data.thresh.catch_accuracy(i,:))));
                axis([0.5 1.5 -.05 1.05])
                set(gca,'fontsize',12)
                set(gcf,'color','w')
                box off
                title('Catch')
            end
        end
        
        % Save the threshold value to the threshold file
        % Check to see if the threshold file has been created, if not create it, else load it in.
        if exist(fullfile('../../IllContThresh.mat'),'file')
            load('../../IllContThresh','IllContThresh');
            % Set values in thresh file
            numSubjsRun = length(IllContThresh);
            IllContThresh(numSubjsRun+1).subjID = options.subjID;
            IllContThresh(numSubjsRun+1).thresh_refit = data.thresh.thresh_refit;   % Threshs from all stairs
            IllContThresh(numSubjsRun+1).thresh_refit_ave = mean(data.thresh.thresh_refit,2);   % Thresh averaged between the 3 stairs
            IllContThresh(numSubjsRun+1).thresh = [data.thresh.ave(1).thresh_refit data.thresh.ave(2).thresh_refit];   % Thresh calculated using all data points from all 3 stairs
            save('../../IllContThresh','IllContThresh');
        else
            IllContThresh.subjID = options.subjID;   % SubjID
            IllContThresh.thresh_refit = data.thresh.thresh_refit;   % Threshs from all stairs
            IllContThresh.thresh_refit_ave = mean(data.thresh.thresh_refit,2);   % Thresh averaged between the 3 stairs
            IllContThresh.thresh = [data.thresh.ave(1).thresh_refit data.thresh.ave(2).thresh_refit];   % Thresh calculated using all data points from all 3 stairs
            save('../../IllContThresh','IllContThresh');
        end
        
    end
end

toc

% End exp screenf
% Calculate accuracy for last block
options.blockCount = options.blockCount + 1;
data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),10))*100;
data.blockRT(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),9));

text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(options.blockCount),'% of trials correctly.');
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(options.blockCount),'s to respond on average. Good job!');
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);

text1 = 'Experiment finished...';
text2 = 'Please tell experimenter.';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',options.yc-350);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',options.yc-300);
Screen('Flip',options.windowNum);
KbWait;

% Save teh ET data if collecting
if options.eyeTracking == 1
    
    % Stop eyetracking
    options.ETOptions.eyeTracker.stop_gaze_data();
    
    % First reformat the ET data from its Tobii object format
    for i = 1:length(gzDataHolder.data)
        if ~isempty(gzDataHolder.data{i})
            deviceTimeHolder = double(cell2mat({gzDataHolder.data{i}.DeviceTimeStamp}));
            gzData{i}.DeviceTimeStamp = deviceTimeHolder;
            
            clear deviceTimeHolder
        else
            gzData{i}.DeviceTimeStamp = [];
        end
        
        if ~isempty(gzDataHolder.data{i})
            systemTimeHolder = double(cell2mat({gzDataHolder.data{i}.SystemTimeStamp}));
            gzData{i}.SystemTimeStamp = systemTimeHolder;
            
            clear systemTimeHolder
        else
            gzData{i}.SystemTimeStamp = [];
        end
        
        if ~isempty(gzDataHolder.data{i})
            leftEyeHolder = {gzDataHolder.data{i}(:).LeftEye};
            rightEyeHolder = {gzDataHolder.data{i}(:).RightEye};
            
            for j = 1:length(leftEyeHolder)
                gzData{i}.LeftEye.GazePoint(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                gzData{i}.LeftEye.GazePoint(j,:).OnDisplayArea = double(leftEyeHolder{j}.GazePoint.OnDisplayArea);
                gzData{i}.LeftEye.GazeOrigin(j,:).InUserCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                gzData{i}.LeftEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(leftEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                gzData{i}.LeftEye.PointValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                gzData{i}.LeftEye.OriginValidity(j,:) = double(leftEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                gzData{i}.LeftEye.Pupil(j,:) = double(leftEyeHolder{j}.Pupil.Diameter);
                gzData{i}.LeftEye.PupilValidity(j,:) = double(leftEyeHolder{j}.Pupil.Validity.value);
                
                gzData{i}.RightEye.GazePoint(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazePoint.InUserCoordinateSystem);
                gzData{i}.RightEye.GazePoint(j,:).OnDisplayArea = double(rightEyeHolder{j}.GazePoint.OnDisplayArea);
                gzData{i}.RightEye.GazeOrigin(j,:).InUserCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);
                gzData{i}.RightEye.GazeOrigin(j,:).InTrackBoxCoordinateSystem = double(rightEyeHolder{j}.GazeOrigin.InTrackBoxCoordinateSystem);
                gzData{i}.RightEye.PointValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for gaze point
                gzData{i}.RightEye.OriginValidity(j,:) = double(rightEyeHolder{j}.GazeOrigin.InUserCoordinateSystem);   % Validity for origin point
                gzData{i}.RightEye.Pupil(j,:) = double(rightEyeHolder{j}.Pupil.Diameter);
                gzData{i}.RightEye.PupilValidity(j,:) = double(rightEyeHolder{j}.Pupil.Validity.value);
            end
            
            clear leftEyeHolder rightEyeHolder
        else
            gzData{i}.LeftEye.GazePoint.InUserCoordinateSystem = [];
            gzData{i}.LeftEye.GazePoint.OnDisplayArea = [];
            gzData{i}.LeftEye.GazeOrigin.InUserCoordinateSystem = [];
            gzData{i}.LeftEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
            gzData{i}.LeftEye.PointValidity = [];   % Validity for gaze point
            gzData{i}.LeftEye.OriginValidity = [];   % Validity for origin point
            gzData{i}.LeftEye.Pupil = [];
            gzData{i}.LeftEye.PupilValidity = [];
            
            gzData{i}.RightEye.GazePoint.InUserCoordinateSystem = [];
            gzData{i}.RightEye.GazePoint.OnDisplayArea = [];
            gzData{i}.RightEye.GazeOrigin.InUserCoordinateSystem = [];
            gzData{i}.RightEye.GazeOrigin.InTrackBoxCoordinateSystem = [];
            gzData{i}.RightEye.PointValidity = [];   % Validity for gaze point
            gzData{i}.RightEye.OriginValidity = [];   % Validity for origin point
            gzData{i}.RightEye.Pupil = [];
            gzData{i}.RightEye.PupilValidity = [];
        end
        
    end
    
    % Not sure why saving twice w/ etData and etData/gzData, commented out first save and cd back into relevant stim folder - KWK 20211012 
    cd e:/SYON_Eyetracking/
%     save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData')
%     cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/EEG_Task/Stim
    save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_Behav_',options.datecode,'_',options.blockCount),'etData','gzData')
    cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Contour_Task/Behavioral_Task/Stim
    
    % Clear the ET save file to make memory for next block
    clear etData gzDataHolder gzData
end

%% Finish experiment
cleanUp(options,data);

end





