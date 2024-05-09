

% Experiment for the illusory size task forf the SYON grant.

function [] = IllusorySizeExp_GrayCirc_BothPersp_EEG_EyeTrack()

clear all; close all; sca;

%% Initialize
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
cd(fullfile(options.root_path,'Illusory_Size_Task\EEG_Task\Stim'));

options.practice.practiceBreak = 0;
options.practice.practiceCheck = 1;   % Variable that tells exp to present the practice trials at start of block
options.practice.doPractice = 1;
options.displayFigs =0;
options.eegRecording = 1;
options.analysisCheck = 0;
options.photodiodeTesting = 0;
options.signalPhotodiode = 1;
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
options.expName = 'Illusory_Size_Task';
options.expPath = fullfile(options.root_path,options.expName,'\EEG_Task\');   % Path specific to the experiment
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

% Update the datafile name
options.datafile = [options.datafile '_GrayCirc_BothPersp'];

% Define mouse inputs
options.buttons.buttonLeftMouse = KbName('Left_Mouse');
options.buttons.buttonRightMouse = KbName('Right_Mouse');
options.buttons.buttonMiddleMouse  = KbName('Middle_Mouse');

% Define mouse
[mouseNums, mouseNames] = GetMouseIndices;
options.dev_id_mouse = mouseNums(1);

% Creat KbQueue
keyList = zeros([256 1]);
keyList([options.buttons.buttonLeftMouse options.buttons.buttonRightMouse options.buttons.buttonMiddleMouse]) = 1;
KbQueueCreate(options.dev_id_mouse,keyList);
KbQueueStart(options.dev_id_mouse);

% Initialize the triggers
if options.eegRecording == 1
    config_io;
end

%% Trial Varialbes
% List variables to determine trial sequence
options.illSizeList = [1 2];   % 1=Far ball; 2=close ball
options.illSizeNum = length(options.illSizeList);
options.hallwayList = [1 2];   % 1=hallway; 2=no hallway
options.hallwayNum = length(options.hallwayList);
options.phaseList = [1 2];   % Phase of chackerboard
options.phaseListNum = length(options.phaseList);
options.perspList = [1 2];   % Which perspective? 1-looking upper right, 2-looking upper left
options.perspNum = length(options.perspList);

options.repetitions = 100;   % Number of trials/condition
options.fixTrialRepetitions = 10;   % Number of fixation change trials/block
options.numBlocks = 4;   % Number of blocks/experiment

options.trialsPerBlock = options.repetitions+options.fixTrialRepetitions;

options.varList = zeros([options.trialsPerBlock*options.numBlocks,6]);   % Initialize varList

% Creat fixation change trial conditions
options.fixChangeVarList(:,1) = zeros([options.fixTrialRepetitions*options.numBlocks,1]);   % Block num
options.fixChangeVarList(:,2:3) = repmat(fullfact([options.illSizeNum options.hallwayNum]),[options.fixTrialRepetitions,1]);   % close/far and hallway/no hallway and perspective
options.fixChangeVarList(:,5) = repmat(fullfact([options.phaseListNum]),[(options.fixTrialRepetitions*options.numBlocks)/2 1]);   % Phase of checkerboard
options.fixChangeVarList(:,6) = zeros([options.fixTrialRepetitions*options.numBlocks,1])+2;   % Trial type (Fix change)
options.fixTrialNums = [randperm(options.trialsPerBlock, options.fixTrialRepetitions) ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock*2 ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock*3];
% Add in the change in perspective fixation change trials
% For all of the trials of a given condition (far hall; close hall; far no hall; close no hall) divide up the trials into
% close or far. 
for i=1:options.illSizeNum
    for j=1:options.hallwayNum
        options.fixChangeVarList([options.fixChangeVarList(:,2)==i & options.fixChangeVarList(:,3)==j],4) = randi(2,[options.fixTrialRepetitions 1]);
    end
end

options.varList(options.fixTrialNums,:) = options.fixChangeVarList;   % Assign fix change trials to proper trial spot

% Make a list of trials that are not fixation change trials
options.varList(options.varList(:,6)==0,6) = 1;
options.noFixTrialNums = find(options.varList(:,6)==1);

% Make varlist for each block and randomize trial order
for i=1:options.numBlocks
    options.varList(((i-1)*options.trialsPerBlock)+1:(i*options.trialsPerBlock),1) = i;   % Block number
    
    options.varList(options.noFixTrialNums(((i-1)*options.repetitions)+1:(i*options.repetitions)),2:3) = repmat(fullfact([options.illSizeNum options.hallwayNum]),...
        [options.repetitions/options.numBlocks 1]);   % close/far and hallway/no hallway
        
    options.varList(options.noFixTrialNums(((i-1)*options.repetitions)+1:(i*options.repetitions)),5) = repmat(fullfact(options.phaseListNum),[options.repetitions/2 1]);   % Phase of checkerboard
        
    options.trialOrder(((i-1)*options.trialsPerBlock)+1:(i*options.trialsPerBlock)) = randperm(options.trialsPerBlock)+((i-1)*options.trialsPerBlock);
end
% Add in the change in perspective fixation change trials
% For all of the trials of a given condition (far hall; close hall; far no hall; close no hall) divide up the trials into
% close or far. 
for i=1:options.illSizeNum
    for j=1:options.hallwayNum
        options.varList([options.varList(:,2)==i & options.varList(:,3)==j & options.varList(:,6)==1],4) = randi(2,[options.repetitions 1]);
    end
end

options.numTrials = length(options.varList);

% Give participants a break in between blocks
options.break_trials = round(options.numTrials/4+1:options.numTrials/4:options.numTrials);   % Breaks half way through each block
options.blockCount = 0;   % Count the current block
options.blockCountArray = [1 options.break_trials options.numTrials];

% Variable to track values on each trial
data.rawdata = zeros([length(options.varList),9]); 

%% Stim Variables
% Make fixation points
options.blackFixation = do_fixation(options);
options.fix.fixOuterOvalColor = options.blueCol;
options.blueFixation = do_fixation(options);
options.fixationRect = [options.xc - options.fix.fixSizeOuter/2*options.PPD,...
    options.yc - options.fix.fixSizeOuter/2*options.PPD,...
    options.xc + options.fix.fixSizeOuter/2*options.PPD,...
    options.yc + options.fix.fixSizeOuter/2*options.PPD];
options.blinkFixation = do_fixation_blink(options);

% Circle sizes
% Use predetermined size values (in % of far circle)
% Stim type - same check size or same check num
options.stimType = 'sameCheckNum';

% Stim sizes needed to load in
options.sizeArray = [1];   % Only need the 1:1 size for single ball stim

% Load in the coords of the circles on the textures and position of fixation
cd ../../Behavioral_Task/Stim/
loadedVars = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_noHallway_7degAlpha_FixLine_SingleCirc.mat'));
options.singleCirc.circCoordTex(1,1,:) = loadedVars.options.singleCirc.circ1CoordTex;
options.singleCirc.circCoordTex(1,2,:) = loadedVars.options.singleCirc.circ2CoordTex;
% Find fixation location
options.singleCirc.fixationLoc = loadedVars.options.singleCirc.fixationLoc;
clear loadedVars

% Load in premade texture arrays
cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall   % cd into the correct folder
for i=1:length(options.sizeArray)
    for j=1:2   % Load both phases
        for k=1:2   % Load both the close and far sphere stim
            if k==1
                whichSphere = 'close';
            elseif k==2
                whichSphere = 'far';
            end
            for p=1:2   % For no fix change trials and fix change trials
                if p==1
                   fixChange = ''; 
                elseif p==2
                    fixChange = 'fixChange_';
                end
                % Load hallway textures
                options.circTextureArray{1,i,j,k,p,1} = imread(sprintf('%s%.3f%s%s%s%s%s%s%d%s','./BallHallway_',...
                    options.sizeArray(i),'_',options.stimType,'_hallway_7degAlpha_',whichSphere,'_Texture_cyan_',fixChange,j,'.png'));
                
                % Load no hallway textures
                options.circTextureArray{2,i,j,k,p,1} = imread(sprintf('%s%.3f%s%s%s%s%s%s%d%s','./BallHallway_',...
                    options.sizeArray(i),'_',options.stimType,'_noHallway_7degAlpha_',whichSphere,'_Texture_cyan_',fixChange,j,'.png'));
                
                % Make the reverse perspective textures
                for h=1:3   % Flip the image to get the second persepctive
                    options.circTextureArray{1,i,j,k,p,2}(:,:,h) = flip(options.circTextureArray{1,i,j,k,p,1}(:,:,h),2);
                    options.circTextureArray{2,i,j,k,p,2}(:,:,h) = flip(options.circTextureArray{2,i,j,k,p,1}(:,:,h),2);
                end
                
                % Correct the color values in the textures for monitor being used
                options.circTextureArray{1,i,j,k,p,1} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i,j,k,p,1}+1).*255);
                options.circTextureArray{2,i,j,k,p,1} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i,j,k,p,1}+1).*255);
                options.circTextureArray{1,i,j,k,p,2} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i,j,k,p,2}+1).*255);
                options.circTextureArray{2,i,j,k,p,2} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i,j,k,p,2}+1).*255);
                
                % Pre-make all neccessary textures for faster drawing
                options.circTextures{1,i,j,k,p,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i,j,k,p,1});
                options.circTextures{2,i,j,k,p,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i,j,k,p,1});
                options.circTextures{1,i,j,k,p,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i,j,k,p,2});
                options.circTextures{2,i,j,k,p,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i,j,k,p,2});
            end
        end
    end
    
    for k=1:2   % Load both fixation types
        if k==1
           whichFix = 'cyan'; 
        elseif k==2
            whichFix = 'red';
        end
        
        % Load hallway fix only textures
        options.circTextureArray_fixOnly{1,i,k,1} = imread(sprintf('%s%.3f%s%s%s%s%s','./BallHallway_',...
            options.sizeArray(i),'_fixOnly_hallway_7degAlpha_close_Texture_',whichFix,'.png'));
        
        % Load no hallway fix only textures
        options.circTextureArray_fixOnly{2,i,k,1} = imread(sprintf('%s%.3f%s%s%s%s%s','./BallHallway_',...
            options.sizeArray(i),'_fixOnly_noHallway_7degAlpha_close_Texture_',whichFix,'.png'));
        
        % Make the reverse perspective textures
        for h=1:3   % Flip the image to get the second persepctive
            options.circTextureArray_fixOnly{1,i,k,2}(:,:,h) = flip(options.circTextureArray_fixOnly{1,i,k,1}(:,:,h),2);
            options.circTextureArray_fixOnly{2,i,k,2}(:,:,h) = flip(options.circTextureArray_fixOnly{2,i,k,1}(:,:,h),2);
        end
        
        % Correct the color values in the textures for monitor being used
        options.circTextureArray_fixOnly{1,i,k,1} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i,k,1}+1).*255);
        options.circTextureArray_fixOnly{2,i,k,1} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i,k,1}+1).*255);
        options.circTextureArray_fixOnly{1,i,k,2} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i,k,2}+1).*255);
        options.circTextureArray_fixOnly{2,i,k,2} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i,k,2}+1).*255);
        
        % Pre-make all neccessary textures for faster drawing
        options.circTextures_fixOnly{1,i,k,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i,k,1});
        options.circTextures_fixOnly{2,i,k,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i,k,1});
        options.circTextures_fixOnly{1,i,k,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i,k,2});
        options.circTextures_fixOnly{2,i,k,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i,k,2});
    end
end
cd ../../../../../EEG_Task/Stim/

% Texture coords
options.textureCoords = [options.xc-(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc-(size(options.circTextureArray{1,i,j,k,p},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc+(size(options.circTextureArray{1,i,j,k,p},2)/2)];

% Find fixation loc in screen coords
options.singleCirc.fixationLocScreen = options.singleCirc.fixationLoc+...
    [options.xc-(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc-(size(options.circTextureArray{1,i,j,k,p},2)/2)];
options.singleCirc.fixationOffset = [options.xc options.yc]-options.singleCirc.fixationLocScreen;
% Texture coords - centered at fixation
options.textureCoords(1,:) = [options.xc-(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc-(size(options.circTextureArray{1,i,j,k,p},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc+(size(options.circTextureArray{1,i,j,k,p},2)/2)] +...
    [options.singleCirc.fixationOffset options.singleCirc.fixationOffset];
options.textureCoords(2,:) = [options.xc-(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc-(size(options.circTextureArray{1,i,j,k,p},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc+(size(options.circTextureArray{1,i,j,k,p},2)/2)] +...
    [-options.singleCirc.fixationOffset(1) options.singleCirc.fixationOffset(2) -options.singleCirc.fixationOffset(1) options.singleCirc.fixationOffset(2)];

% Make cirCoords for the opposite perspective
options.singleCirc.circCoordTex(2,1,:) = options.singleCirc.circCoordTex(1,1,:);
options.singleCirc.circCoordTex(2,2,:) = options.singleCirc.circCoordTex(1,2,:);
options.singleCirc.circCoordTex(2,1,[1 3]) = (abs(squeeze(options.singleCirc.circCoordTex(1,1,[3 1]))'-options.singleCirc.fixationLoc(1))+options.singleCirc.fixationLoc(1))-abs(options.singleCirc.fixationOffset(1))*2;
options.singleCirc.circCoordTex(2,2,[1 3]) = (options.singleCirc.fixationLoc(1)-abs(squeeze(options.singleCirc.circCoordTex(1,2,[3 1]))'-options.singleCirc.fixationLoc(1)))-abs(options.singleCirc.fixationOffset(1))*2;

% Determine timing variables for each trial
prestimTimes = linspace(.800,1.200,25);
options.time.prestimulusInterval = prestimTimes(randi(length(prestimTimes),[options.numTrials,1]));   % Hallway on; no circs (or no hallway no circs)
options.time.stimPresInterval = .200;   % Stim time (circs on)
options.time.poststimulusInterval = .400;   % Post stim baseline (hallway on; no circs)
blankTimes = linspace(.650,.850,20);
options.time.blankInterval = blankTimes(randi(length(blankTimes),[options.numTrials,1]));   % ITI (time between trials/responsetime)

% Set the port address
if options.eegRecording == 1
    options.address = hex2dec('A010');
end


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

%% Draw
[keyisdown, secs, keycode] = KbCheck(options.dev_id);
expStart = GetSecs;
for n=1:length(options.trialOrder)
    
    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
    
    % Check to see if we need to run practice trials
    if options.practice.doPractice == 1
        if n==1
            options.practice.practiceCheck = 1;
        end
        
        if options.practice.practiceCheck == 1
            if n==1
                if options.photodiodeTesting == 0
                    [options,data] = IllusorySizeExp_GrayCirc_BothPersp_EEGPrac(options,data);
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
        if options.photodiodeTesting == 0
            % Set up breaks in between blocks
            this_b = 0;
            for b = round(options.break_trials)
                if n == b
                    this_b = b;
                    break
                end
            end
            if this_b
                % display break message
                % Calculate accuracy for this block
                options.blockCount = options.blockCount + 1;
                data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),8))*100;
                data.blockRT(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),9));
                
                text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(options.blockCount),'% of trials correctly.');
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
                DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
                text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(options.blockCount),'s to respond on average. Good job!');
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
                DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);
                
                text1='Please take a break. Feel free to blink or move your eyes.';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,options.fixCol);
                text2='Please do not make any unnecessary movements.';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,options.fixCol);
                text3='You''re doing great!';
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
                    cd e:/SYON_EyeTracking/
%                     save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_',options.datecode,'_',options.blockCount),'etData')
                    save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_',options.datecode,'_',options.blockCount),'etData','gzData')
                    cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Size_Task/EEG_Task/Stim
                    
                    % Clear the ET save file to make memory for next block
                    clear etData gzDataHolder gzData
                    etData.etCounter = 0;
                    etData.blockStart = options.ETOptions.Tobii.get_system_time_stamp;
                end
            end
        end
        
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
    
        data.rawdata(n,1) = n;   % Trial order
        data.rawdata(n,2) = options.trialOrder(n);   % Trial number
        farCloseIdx = options.varList(options.trialOrder(n),2);   % 1=Far, 2=Closef
        data.rawdata(n,3) = farCloseIdx;
        hallwayIdx = options.varList(options.trialOrder(n),3);   % 1=Hallway, 2=no hallway
        data.rawdata(n,4) = hallwayIdx;
        perspIdx = options.varList(options.trialOrder(n),4);
        data.rawdata(n,5) = perspIdx;
        phaseIdx = options.varList(options.trialOrder(n),5);   % phase 1 and 2
        data.rawdata(n,6) = phaseIdx;
        fixChangeIdx = options.varList(options.trialOrder(n),6);   % 1=no fix change, 2=fix change
        data.rawdata(n,7) = fixChangeIdx;
        
        % SET PRIO WHILE PRESENTING STIM
        if options.eegRecording == 1
            priorityLevel=MaxPriority(options.windowNum);
            Priority(priorityLevel);
        end
        
        % Start with initial fixation before starting experiment
        if n==1
            Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            WaitSecs(1);
        end
        
        % Send trigger at beginning of block
        if options.eegRecording == 1
            if n==1 || n==options.break_trials(1) || n==options.break_trials(2) || n==options.break_trials(3)
                default = 15;
                outp(options.address,default);   % Send trigger
                WaitSecs(0.005);
                default = 0;
                outp(options.address,default);
            end
        end
        
        %% Start trial presentation
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        options.time.syncTime(n) = Screen('Flip',options.windowNum);
        
        % Start eyetracking
        if options.eyeTracking == 1
            options.ETOptions.eyeTracker.get_gaze_data();
        end
        
        % Present photodiode when hallway appears
        if options.photodiodeTesting == 1 || options.signalPhotodiode == 1
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
        end
        
        % Start with hallway no stim - 800-1200ms w/ cyan fix
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, options.time.blankOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.syncTime(n)) - options.flip_interval_correction);
        
        % Send hallway onset strigger  
        if options.eegRecording == 1
            options.default(n) = 16;   % Far hallway no chanage
            outp(options.address,options.default(n));   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);   % Clear the port
        end
        
        if options.photodiodeTesting == 1 || options.signalPhotodiode == 1
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
        end

        % Present target - 200ms w/ cyan fix
        % Present fix change trial if necessary
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        if fixChangeIdx == 1
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        elseif fixChangeIdx == 2
            Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
        end
        [~, options.time.stimOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.blankOnsetTime(n)+options.time.prestimulusInterval(n))-options.flip_interval_correction);
        
        % Send stim strigger  %%% UPDATED BY KWK 20190827 - Check at VA!
        switch fixChangeIdx
            case 1   % No fix change
                switch farCloseIdx
                    case 1   % Far
                        switch hallwayIdx
                            case 1   % Hallway
                                switch perspIdx
                                    case 1   % right
                                        options.default(n) = 111;   % Far hallway no change right
                                    case 2   % left
                                        options.default(n) = 112;    % Far hallway no change left
                                end
                            case 2   % No hallway
                                switch perspIdx
                                    case 1   % right
                                        options.default(n) = 113;   % Far no hallway no change right
                                    case 2   % left
                                        options.default(n) = 114;    % Far no hallway no change left
                                end
                        end
                    case 2   % Close
                        switch hallwayIdx
                            case 1   % Hallway
                                switch perspIdx
                                    case 1   % left
                                        options.default(n) = 121;   % Close hallway no change left
                                    case 2   % right
                                        options.default(n) = 122;    % Close hallway no change right
                                end
                            case 2   % No hallway
                                switch perspIdx
                                    case 1   % left
                                        options.default(n) = 123;   % Close no hallway no change left
                                    case 2   % right
                                        options.default(n) = 124;    % Close no hallway no change right
                                end
                        end
                end
            case 2      % Fix change
                switch farCloseIdx
                    case 1   % Far
                        switch hallwayIdx
                            case 1   % Hallway
                                switch perspIdx
                                    case 1   % right
                                        options.default(n) = 131;   % Far hallway change right
                                    case 2   % left
                                        options.default(n) = 132;    % Far hallway change left
                                end
                            case 2   % No hallway
                                switch perspIdx
                                    case 1   % right
                                        options.default(n) = 133;   % Far no hallway change right
                                    case 2   % left
                                        options.default(n) = 134;    % Far no hallway change left
                                end
                        end
                    case 2   % Close
                        switch hallwayIdx
                            case 1   % Hallway
                                switch perspIdx
                                    case 1   % left
                                        options.default(n) = 141;   % Close hallway change right
                                    case 2   % right
                                        options.default(n) = 142;    % Close hallway change left
                                end
                            case 2   % No hallway
                                switch perspIdx
                                    case 1   % left
                                        options.default(n) = 143;   % Close no hallway change right
                                    case 2   % right
                                        options.default(n) = 144;    % Close no hallway change left
                                end
                        end
                end
        end
        if options.eegRecording == 1
            outp(options.address,options.default(n));   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);   % Clear the port
        end
        
        if options.eyeTracking == 1
            
            % Counter for eyetracking struct
            etData.etCounter = etData.etCounter + 1;
            
            % From Tobii's website on 'simple psychtoolbox code' for Matlab
            % SDK
            % Event when startng to show the stimulus
            % Second value is the event marker first is the time stamp
            etData.events{1,etData.etCounter} = {options.ETOptions.Tobii.get_system_time_stamp, options.default(n)};
            
        end
        
        % Monitor for responses
        KbQueueStart(options.dev_id_mouse);
        
        % Present poststim hallway only - 400ms w/ cyan fix
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
            [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, options.time.stimOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.stimOnsetTime(n)+options.time.stimPresInterval)-options.flip_interval_correction);
        
        % Grab eyetracking data for this trial
        if options.eyeTracking == 1
            gzDataHolder.data{etData.etCounter} = options.ETOptions.eyeTracker.get_gaze_data();   % NOT SURE IF THIS WILL WORK NEED TO TEST - KWK 20210216
        end
        
        % Present ITI no hallway - 650-850 w/ red fix
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
        [~, options.time.ITIOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.stimOffsetTime(n)+options.time.poststimulusInterval)-options.flip_interval_correction);
        
        % Send hallway offset trigger  
        if options.eegRecording == 1
            options.default(n) = 17;   % Far hallway no chanage
            outp(options.address,options.default(n));   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);   % Clear the port
        end
        
        % Final screen
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
        Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
        [~, options.time.ITIOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.ITIOnsetTime(n)+options.time.blankInterval(n))-options.flip_interval_correction);
        
        % Check for response
        [options.response.pressed{n} options.response.firstPress{n} ...
            options.response.firstRelease{n} options.response.lastPress{n} options.response.lastRelease{n}] = KbQueueCheck(options.dev_id_mouse);
        
        % Determine if a response was made correctly (was it a fix change trial?)
        if fixChangeIdx == 1   % No fixation change
            if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                data.rawdata(n,8) = 0;
            else
                data.rawdata(n,8) = 1;
            end
        elseif fixChangeIdx == 2   % Fix change
            if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                data.rawdata(n,8) = 1;
            else
                data.rawdata(n,8) = 0;
            end
        end
        
        % Determine time response made relative to start of trial (response time)
        if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
            options.response.respTimeFirst(n) = options.response.firstPress{n}(options.buttons.buttonLeftMouse) - options.time.stimOnsetTime(n);
            data.rawdata(n,9) = options.response.respTimeFirst(n);
        else
            options.response.respTimeFirst(n) = NaN;
            data.rawdata(n,9) = NaN;
        end
        if options.response.lastPress{n}(options.buttons.buttonLeftMouse) > 0
            options.response.respTimeLast(n) = options.response.lastPress{n}(options.buttons.buttonLeftMouse) - options.time.stimOnsetTime(n);
        else
            options.response.respTimeLast(n) = NaN;
        end
        
        % Stop monitoring
        KbQueueStop(options.dev_id_mouse);
       
        % SET PRIO TO NORMAL
        if options.eegRecording == 1
            Priority(0);
        end
        
        if keycode(options.buttons.buttonEscape)
            sca;
            break
        end
        
        % SET PRIO TO NORMAL
        if options.eegRecording == 1
            Priority(0);
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

% Make the rawdata variable into a table so it's easier for others to read
for i=1:size(data.rawdata,2)
    t(:,i)=table(data.rawdata(:,i));
end

t.Properties.VariableNames = {'PresOrder','TrialNumber','Far_Close',...
    'Hallway','Perspective','Phase','Catch_Trial','Response','Response_Time'};

% Save the text file for use w/ other programs not Matlab
writetable(t,fullfile(options.datadir,options.datafile));

data.rawdataT = t;

% End exp screen
% Calculate accuracy for last block
options.blockCount = options.blockCount + 1;
data.blockAcc(options.blockCount) = nanmean(data.rawdata(options.blockCountArray(options.blockCount):options.blockCountArray(options.blockCount+1),8))*100;
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
    cd e:/SYON_EyeTracking/
%     save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_',options.datecode,'_',options.blockCount),'etData')
    save(sprintf('%s%s%s%s%s%s%s%d','etData_',options.subjID,'_',options.expName,'_',options.datecode,'_',options.blockCount),'etData','gzData')
    cd c:/Users/'EEG Task Computer'/Desktop/SYON.git/Illusory_Size_Task/EEG_Task/Stim
    
    % Clear the ET save file to make memory for next block
    clear etData gzDataHolder gzData
end

%% Finish experiment
cleanUp(options,data);

end




