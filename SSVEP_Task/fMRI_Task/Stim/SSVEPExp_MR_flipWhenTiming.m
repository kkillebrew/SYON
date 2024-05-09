% Script for running the MR localizer for the illusory contour experiment.
% 20200109 - KWK

% Experiment for the illusory contour task for the SYON grant.

function [options,data] = SSVEPExp_MR_flipWhenTiming()

% clearvars -except optionsString subjid runid; close all; sca;
% switch nargin
%     case 1
%         subjid = [];
%         runid = [];
%     case 2
%         runid = [];
% end

clear all; close all;

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
optionsString = 'CMRR';

addpath(genpath(fullfile(options.root_path,'Functions')));
if strcmp(optionsString,'CMRR')
    cd(fullfile(options.root_path,'SSVEP_Task/fMRI_Task/Stim'));
else
    cd(fullfile(options.root_path,'SSVEP_Task\fMRI_Task\Stim'));
end

[optionsString,subjid,runid] = userInputDialogBox(optionsString);

% % FOR TESTING
% optionsString = 'CMRR';
% subjid = 'test';
% runid = 1;

options.compSetup = optionsString;
options.expName = 'SSVEP_Task';
options.expType = 'MR';   % For use in localOptions to look for scanner keyboard
options.expPath = fullfile(options.root_path,options.expName,'\fMRI_Task\');   % Path specific to the experiment
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
elseif strcmp(options.compSetup,'CMRR')
    load('3TB_20121213_CLUT.mat','displayInfo');
    options.displayInfo = displayInfo;
    %     options.displayInfo.linearClut = 0:1/255:1;
else
    options.displayInfo.linearClut = 0:1/255:1;
end

% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'UseGPGPUCompute', 'Auto');

options = localOptions(options);
options.escBreak = 0;

%% Trial Varialbes
% List variables to determine trial sequence
options.repetitions = 10;   % Number of times to present the 'on' and 'off' stim
options.blankRepetitions = 5;   % Number of times to present blank fixation blocks
options.numCatch = 10;   % Number of times the fixation will turn red and blue (fixation task trials)
options.flipRate = 4;   % Hz of flicker

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
options.instSwitch = 1;

% Timing variables in seconds
options.time.onTime = 10;
options.time.offTime = 10;
options.time.blankTime = 10;

% Determine total time from scanner trigger % On + off + blank
options.time.totalTime = (options.repetitions*options.time.onTime) +...
    (options.repetitions*options.time.offTime) +...
    (options.blankRepetitions*options.time.blankTime);

% Type of block being presented (1=on 2=off 2=blank)
options.blockType = zeros([1 (options.repetitions*2)+options.blankRepetitions]);
options.blockType(linspace(1,length(options.blockType),5)) = 3;
options.blockType(options.blockType==0) = repmat([1 2],[1 options.repetitions])';

% Timing variables in seconds
% Start of each block relative to scanner trigger onset
options.time.blockStart = linspace(0,options.time.totalTime-options.time.blankTime,length(options.blockType));

% Switch times for each flip of the checkerboard (MxN), with M number of
% blocks and N number of flips at a rate of 4hz (8 flips/second 80 flips/block).
catchTimeArray = [];
for i=1:length(options.time.blockStart)
    options.time.flipTimes(i,:) = linspace(options.time.blockStart(i),options.time.blockStart(i)+options.time.onTime,...
        options.flipRate*2*options.time.onTime);
    
    % Make a single dim array to grab times to present catch trials
    catchTimeArray = [catchTimeArray options.time.flipTimes(i,:)];
end

% Git rid of the first ~2s and last ~2s of time to present catch
catchTimeArray(1:20) = [];
catchTimeArray(length(catchTimeArray)-19:length(catchTimeArray)) = [];

% Variable to track values on each trial
% rawdata(1) = timing of catch
% rawdata(2) = type of catch (1=red 2=blue 3=green 4=yellow)
% rawdata(3) = response (1=yes 2=no)
% rawdata(4) = response time
% Randomly determine when the catch trials will be presented
options.catchTimeRed = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.catchTimeRed);
options.catchTimeBlue = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.catchTimeBlue);
options.catchTimeGreen = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.catchTimeGreen);
options.catchTimeYellow = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));

options.catchTimeRed = sort(options.catchTimeRed);
options.catchTimeBlue = sort(options.catchTimeBlue);
options.catchTimeGreen = sort(options.catchTimeGreen);
options.catchTimeYellow = sort(options.catchTimeYellow);
clear catchTimeArray

options.catchTime = sort([options.catchTimeBlue options.catchTimeRed options.catchTimeGreen options.catchTimeYellow]);
data.rawdata = zeros([length(options.catchTime),4]);
data.rawdata(:,1) = options.catchTime;
options.catchType = zeros([length(options.catchTime) 1]);
options.catchType(ismember(options.catchTime,options.catchTimeRed)) = 1;
options.catchType(ismember(options.catchTime,options.catchTimeBlue)) = 2;
options.catchType(ismember(options.catchTime,options.catchTimeGreen)) = 3;
options.catchType(ismember(options.catchTime,options.catchTimeYellow)) = 4;
data.rawdata(:,2) = options.catchType;

%% Stimulus variables
% Size variables
options.stim.centCircDia = 1;   % Diameter of the center circs
options.stim.centCircTexSize = options.stim.centCircDia*2;   % Size of the texture
options.stim.surrCircDia = 8;   % Diameter of the surround circ
options.stim.surrCircTexSize = options.stim.surrCircDia*2;   % Size of the texture
options.stim.circDistY1 = 1.7101;   % Distance between top circles and screen center in x
options.stim.circDistX1 = 4.6985;   % Distance between top circles and screen center in y
options.stim.circDistY2 = 3.5355;   % Distance between bottomw circles and screen center in x
options.stim.circDistX2 = 3.5355;   % Distance betwegien top/bottom circles and screen center in y
options.stim.gap = options.stim.centCircDia/16;   % Distance between the center / surround stim
options.stim.blurSD = 0.05;   % SD of the gaussian
options.checkerboard.checkSize = .5;   % Size of checks
options.fixSize = .3;   % Fixation size in degrees
options.fixSizeCut = .05;   % extra cutout of fixation in mask

% Make the center textures
% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.centCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.centCircTexSize/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.centCircTexSize)*options.PPD);
options.checkerboard.yDim = round((options.stim.centCircTexSize)*options.PPD);
options.checkerboard.centRadius = round((options.stim.centCircDia/2)*options.PPD);

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.centCircMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.centCircMask = options.checkerboard.centCircMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.centRadius;

% Center circles checkerboard texture
options.checkerboard.maskHolder = options.checkerboard.centCircMask;
options.checkerboard.gaussFilt = fspecial('gaussian',length(options.checkerboard.maskHolder)+1,options.stim.blurSD*options.PPD);   % Create the gaussian portion of the mask
options.checkerboard.maskHolder = conv2(double(options.checkerboard.maskHolder),double(options.checkerboard.gaussFilt),'same');
% options.checkerboard.maskHolder(options.checkerboard.maskHolder<=.1) = 0;
options = createCheckerboard(options); %   Combine checkerboard and mask
for i=1:2   % For both phases of the checkerboard
    cirTexHolder(:,:,1) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,2) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,3) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,4) = (options.checkerboard.maskHolder*options.whiteCol(1));
    options.checkerboard.centCircTexArray{i} = cirTexHolder;   % Make background transparent
    
    options.checkerboard.centCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.centCircTexArray{i});
    
    clear cirTexHolder
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder','gaussFilt'});   % Clear holders

% Coord points of the center circles
% Upper left
options.stim.centCircPositionArray(1,:) = [(options.xc-((options.stim.circDistX1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc-((options.stim.circDistX1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Upper right
options.stim.centCircPositionArray(2,:) = [(options.xc+((options.stim.circDistX1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc+((options.stim.circDistX1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Lower right
options.stim.centCircPositionArray(3,:) = [(options.xc-((options.stim.circDistX2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc-((options.stim.circDistX2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Lower left
options.stim.centCircPositionArray(4,:) = [(options.xc+((options.stim.circDistX2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc+((options.stim.circDistX2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];

% Make the surround texture
% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.surrCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.surrCircTexSize/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.surrCircTexSize)*options.PPD);   % MUST NAME THIS xDim OR FUNC WILL NOT RECOGNIZE
options.checkerboard.yDim = round((options.stim.surrCircTexSize)*options.PPD);
options.checkerboard.surrRadius = round((options.stim.surrCircDia/2)*options.PPD);

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.surrCircMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.surrCircMask = options.checkerboard.surrCircMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.surrRadius;

for i=1:4
    % Make a new holder mask
    surrCircMaskHolder = zeros(length(options.checkerboard.surrCircMask));
    
    % CHANGE THIS TO MAKE IT THE CENTER OF THE CIRCLES IN THE SURR CIRCLES
    % SPACE
    if i==1
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)-((options.stim.circDistX1/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)-((options.stim.circDistY1/2)*options.PPD);
    elseif i==2
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)+((options.stim.circDistX1/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)-((options.stim.circDistY1/2)*options.PPD);
    elseif i==3
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)+((options.stim.circDistX2/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)+((options.stim.circDistY2/2)*options.PPD);
    elseif i==4
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)-((options.stim.circDistX2/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)+((options.stim.circDistY2/2)*options.PPD);
    end
    
    % Add in to the surr texture
    surrCircMaskHolder = ~(surrCircMaskHolder | hypot(xx - options.checkerboard.xc,...
        yy - options.checkerboard.yc) <= options.checkerboard.centRadius);
    
    options.checkerboard.surrCircMask = options.checkerboard.surrCircMask.*surrCircMaskHolder;
    
    clear surrCircMaskHolder
end

% Add in small circ to the center for fixation
surrCircMaskHolder = zeros(length(options.checkerboard.surrCircMask));

options.checkerboard.xc = (options.checkerboard.xDim)/2;
options.checkerboard.yc = (options.checkerboard.yDim)/2;

surrCircMaskHolder = ~(surrCircMaskHolder | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= ((options.fixSize)*options.PPD));

options.checkerboard.surrCircMask = options.checkerboard.surrCircMask.*surrCircMaskHolder;

clear surrCircMaskHolder

% Center circles checkerboard texture
options.checkerboard.maskHolder = options.checkerboard.surrCircMask;
options.checkerboard.gaussFilt = fspecial('gaussian',length(options.checkerboard.maskHolder)+1,options.stim.blurSD*options.PPD);   % Create the gaussian portion of the mask
options.checkerboard.maskHolder = conv2(options.checkerboard.maskHolder,options.checkerboard.gaussFilt,'same');
options = createCheckerboard(options); %   Combine checkerboard and mask
for i=1:2   % For both phases of the checkerboard
    
    cirTexHolder(:,:,1) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,2) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,3) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,4) = (options.checkerboard.maskHolder*options.whiteCol(1));
    options.checkerboard.surrCircTexArray{i} = cirTexHolder;   % Make background transparent
    
    options.checkerboard.surrCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.surrCircTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Reset center points
options.checkerboard.xc = round((options.stim.surrCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.surrCircTexSize/2)*options.PPD);

% Coord points of the surr circles
% Upper left
options.stim.surrCircPositionArray(1,:) = [options.xc-((options.stim.surrCircTexSize/2)*options.PPD)...
    options.yc-((options.stim.surrCircTexSize/2)*options.PPD)...
    options.xc+((options.stim.surrCircTexSize/2)*options.PPD)...
    options.yc+((options.stim.surrCircTexSize/2)*options.PPD)];

% % Blank texture
% options.checkerboard.blankTexArray = zeros([options.checkerboard.xDim,options.checkerboard.yDim]) + options.grayCol(1);
% for i=1:2   % For both 'phases'
%     options.checkerboard.blankTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.blankTexArray);
% end

% Fixation location
options.stim.fixLocs = [options.xc-((options.fixSize-options.fixSizeCut)*options.PPD)/2 options.yc-((options.fixSize-options.fixSizeCut)*options.PPD)/2 ...
    options.xc+((options.fixSize-options.fixSizeCut)*options.PPD)/2 options.yc+((options.fixSize-options.fixSizeCut)*options.PPD)/2];

%% Draw
% % Randomly determine which phase checkerboard to start w/
% checkSwitch = randi(2);
% blockCount = 2;
% flipCount = 1;
% catchCounter = 1;
% catchSwitch = 1;

% % Check to see if we need to run practice trials
% if options.pracSwitch == 1
%     % For practice, we want to run 2 of each block (forground/background)
%     % w/ 5 of each of the tasks (R,B,G,Y)
%     % Save their accuracy data but name ('_Prac')
%     % Also implement eye tracking - USE MPS CODE
%     % Make it a function
%     [options,data.pracData] = SSVEP_Prac_MR(options);
% end

% Last instructions before the experiment starts
WaitSecs(.5);
text1='Now we will start the experiment.';
text2='Please let the experimenter know if you have any questions or concerns.';
text3='Tell the experimenter when you are ready to continue...';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.fixCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.fixCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.fixCol);
Screen('Flip',options.windowNum);

% KbQueueFlush(options.dev_id);
while 1
    [~, ~, keycode] = KbCheck(options.dev_id);
    if keycode(options.buttons.buttonEscape)
        options.escBreak = 1;
        break
    end
    if keycode(options.buttons.scannerTrigger)
        break
    end
end

clear lastPressScanner lastPressDev

WaitSecs(.5);

% SET PRIO WHILE PRESENTING STIM
priorityLevel=MaxPriority(options.windowNum);
Priority(priorityLevel);

if options.escBreak ~= 1
    text1='Waiting for scanner...';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2),options.fixCol);
    Screen('Flip',options.windowNum);
    
    % HERE WAIT FOR SCANNER TO START EXPERIMENT
    % KbQueueFlush(options.dev_id);
    while 1
        [~, ~, keycode] = KbCheck(-1);
        if keycode(options.buttons.buttonEscape)
            options.escBreak = 1;
            break
        end
        %         [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.scannerTrigger)
            break
        end
    end
end

if options.escBreak ~= 1
    catchCounter = 1;
    blockCounter = 2;
    flipSwitch = 1;
    stimOnsetTime = [];
    
    % Draw the stim
    Screen('FillRect',options.windowNum,options.grayCol,options.stim.surrCircPositionArray(1,:));
    
    Screen('FillOval',options.windowNum,options.whiteCol,options.stim.fixLocs);   % Fixation
    
    % Experiment start
    [~,options.time.expStart,~,~] = Screen('Flip',options.windowNum);
    
    for m=1:length(options.time.flipTimes,1)
        
        if options.escBreak == 1
            break
        end
        
        for n=1:length(options.time.flipTime,2)
            
            if options.escBreak == 1
                break
            end
            
            % Keep looping until the screen flips
            while 1
                if isempty(stimOnsetTime)
                    
                    [~, ~, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        options.escBreak = 1;
                        break
                    end
                    
                    % Check which block you're in
                    if options.time.blockStart(blockCounter) == options.time.flipTimes(m,n)
                        blockCounter=blockCounter+1;
                    end
                    % Check which type of stim to present based on what
                    % block you're in
                    switch options.blockType(blockCounter)
                        case 1   % 'On type' - Center
                                for i=1:2
                                    options.checkerboard.centCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.centCircTexArray{i});
                                end
                                
                                % Draw the stim
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(1,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(2,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(3,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(4,:));
                                
                            case 2   % 'Off type' - Surround
                                for i=1:2
                                    options.checkerboard.surrCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.surrCircTexArray{i});
                                end
                                
                                % Draw the stim
                                Screen('DrawTextures',options.windowNum,options.checkerboard.surrCircTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
                                
                            case 3   % 'Blank type'
                                
                                % Draw the stim
                                Screen('FillRect',options.windowNum,options.grayCol,options.stim.surrCircPositionArray(1,:));
                    end                    
                    
                    % Check for catch trial
                    if data.rawdata(catchCounter,1) == options.time.flipTimes(m,n)
                        [~, ~, keycode] = KbCheck(options.scanner_id);
                        switch data.rawdata(catchCounter,2)
                            case 1
                                if keycode(options.buttons.scannerR)
                                    %                                     disp('r')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 2
                                if keycode(options.buttons.scannerB)
                                    %                                     disp('b')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 3
                                if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)   % Monitor for any buttons press
                                    %                                     disp('g')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 4
                                if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)
                                    %                                     disp('y')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                                
                        end
                        catchCounter = catchCounter+1;
                    end
                    
                    % Also monitor for scanner triggers and record the time of each
                    % relative to exp start
                    [~, ~, keycode] = KbCheck(options.scanner_id);
                    if keycode(options.buttons.scannerTrigger)
                        options.time.scannerTriggerNum = options.time.scannerTriggerNum+1;
                        options.time.scannerTriggerTime(options.time.scannerTriggerNum) = GetSecs-options.time.expStart;
                    end
                    
                else
                    % Reset stimOnsetTime
                    stimOnsetTime = [];
                    
                    % Update flipSwitch
                    flipSwitch = 3-flipSwitch;
                    
                    break
                end
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    
    options.time.scannerTriggerNum = 1;
    options.time.scannerTriggerTime = GetSecs - options.time.expStart;
    while 1
        
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            options.escBreak = 1;
            break
        end
        
        % Start trial presentation
        % Check to see if we need to switch stim
        timeNow = GetSecs;
        runCheck = (timeNow - options.time.expStart) > options.time.totalTime;   % When total time excedes run time stop
        switch runCheck
            case 0
                
                % Check if it's time to switch the phase of checker
                flipCheck = (timeNow - options.time.expStart) > options.time.flipTimes(blockCount-1,flipCount);
                switch flipCheck
                    case 1
                        checkSwitch = 3-checkSwitch;
                        flipCount = flipCount+1;
                        switch options.blockType(blockCount-1)
                            
                            case 1   % 'On type' - Center
                                for i=1:2
                                    options.checkerboard.centCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.centCircTexArray{i});
                                end
                                
                                % Draw the stim
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(1,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(2,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(3,:));
                                Screen('DrawTextures',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(4,:));
                                
                            case 2   % 'Off type' - Surround
                                for i=1:2
                                    options.checkerboard.surrCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.surrCircTexArray{i});
                                end
                                
                                % Draw the stim
                                Screen('DrawTextures',options.windowNum,options.checkerboard.surrCircTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
                                
                            case 3   % 'Blank type'
                                
                                % Draw the stim
                                Screen('FillRect',options.windowNum,options.grayCol,options.stim.surrCircPositionArray(1,:));
                                
                        end
                        
                        if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                                ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+1) % If catch trial
                            switch options.catchType(catchCounter)
                                case 1
                                    Screen('FillOval',options.windowNum,options.redCol,options.stim.fixLocs);   % Fixation
                                case 2
                                    Screen('FillOval',options.windowNum,options.blueCol,options.stim.fixLocs);   % Fixation
                                case 3
                                    Screen('FillOval',options.windowNum,options.greenCol,options.stim.fixLocs);   % Fixation
                                case 4
                                    Screen('FillOval',options.windowNum,options.yellowCol,options.stim.fixLocs);   % Fixation
                            end
                        else
                            Screen('FillOval',options.windowNum,options.whiteCol,options.stim.fixLocs);   % Fixation
                        end
                        
                        % Flip at the correct time - record the actual time of the flip
                        Screen('Flip',options.windowNum);
                        options.time.flipTimesActual(blockCount-1,flipCount-1) = GetSecs-options.time.expStart;
                        Screen('Close');
                end
                
                % Check if it's time to switch blocks
                blockCheck = (timeNow - options.time.expStart) > options.time.blockStart(blockCount-1)+options.time.onTime;
                switch blockCheck
                    case 1
                        blockCount = blockCount+1;
                        flipCount = 1;
                end
                
            case 1
                break
        end
        
        % If this is a catch presentation, monitor for button press for 2
        % seconds post trial onset.
        if catchCounter <= length(options.catchTime)
            if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                    ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+2)
                switch catchSwitch
                    case 1
                        
                        % Check for key presses
                        [~, ~, keycode] = KbCheck(options.scanner_id);
                        
                        % Check catch trial type (red/blue)
                        switch options.catchType(catchCounter)
                            case 1
                                if keycode(options.buttons.scannerR)
                                    %                                     disp('r')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 2
                                if keycode(options.buttons.scannerB)
                                    %                                     disp('b')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 3
                                if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)   % Monitor for any buttons press
                                    %                                     disp('g')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                            case 4
                                if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)
                                    %                                     disp('y')
                                    data.rawdata(catchCounter,3) = 1;
                                    data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                    catchSwitch = 0;
                                end
                        end
                end
            end
        end
        
        % Count up the counter the first time you enter the condiditional
        if catchCounter < length(options.catchTime)
            if (GetSecs - options.time.expStart) > options.catchTime(catchCounter)+2
                catchCounter = catchCounter+1;
                catchSwitch = 1;
                
                % Save
                cleanUp(options,data,1);
            end
        end
        
        % Also monitor for scanner triggers and record the time of each
        % relative to exp start
        [~, ~, keycode] = KbCheck(options.scanner_id);
        if keycode(options.buttons.scannerTrigger)
            options.time.scannerTriggerNum = options.time.scannerTriggerNum+1;
            options.time.scannerTriggerTime(options.time.scannerTriggerNum) = GetSecs-options.time.expStart;
        end
        
    end
    
    Priority(0);
    
    % Save
    cleanUp(options,data,1);
    
    % Behavrioral analysis
    % Average accuracy
    % First look at accuracy of b/r trials
    data.aveAccRB = sum(data.rawdata(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2)),3))/length(find(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2))))*100;
    % Then look at accuracy of g/y trials
    data.aveAccYG = sum(~data.rawdata(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4)),3))/length(find(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4))))*100;
    
    % Average response time
    data.aveRT = nanmean(data.rawdata(:,4));
    
end

% Make the rawdata variable into a table so it's easier for others to read
for i=1:size(data.rawdata,2)
    t(:,i)=table(data.rawdata(:,i));
end

% rawdata(1) = timing of catch
% rawdata(2) = type of catch (1=red 2=blue)
% rawdata(3) = response (1=yes 2=no)
% rawdata(4) = response time
t.Properties.VariableNames = {'CatchTime','CatchType','Accuracy','ResponseTime'};

% Save the text file for use w/ other programs not Matlab
writetable(t,sprintf('%s%s%s',options.datadir,options.datafile,'.txt'));

data.rawdataT = t;

% End exp screen
text1 = 'Experiment finished...';
DrawFormattedText(options.windowNum,text1,'center',options.yc-250);
Screen('Flip',options.windowNum);
KbWait(options.dev_id);

%% Finish experiment
cleanUp(options,data);

end



