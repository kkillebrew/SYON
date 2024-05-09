% Script for running the MR localizer for the illusory contour experiment.
% 20200109 - KWK

% Experiment for the illusory contour task for the SYON grant.

function [] = IllusorySizeExp_GrayCirc_BothPersp_fMRI()

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
cd(fullfile(options.root_path,'Illusory_Size_Task/fMRI_Task/Stim'));

options.displayFigs = 0;
options.escBreak = 0;
options.practice.doPractice = 0;
options.analysisCheck = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);

% Ask what condition...hallway or no hallway; upper left/lower right or lower left/upper right
% Open drop down list to select comp setup
condList1 = {'Hallway Present','Hallway Absent'};
initialValue1 = find(strcmp('Hallway Present',condList1));
[indx1,~] = listdlg('ListString',condList1,...
    'SelectionMode','single',...
    'InitialValue',initialValue1);
if ~isempty(indx1)
    options.hallPresType = condList1{indx1};
end
if strcmp(options.hallPresType,condList1{1})
    options.hallPresIdx = 1;
elseif strcmp(options.hallPresType,condList1{2})
    options.hallPresIdx = 2;
end

condList2 = {'Lower Left/Upper Right','Upper Left/Lower Right'};
initialValue2 = find(strcmp('Lower Left/Upper Right',condList2));
[indx2,~] = listdlg('ListString',condList2,...
    'SelectionMode','single',...
    'InitialValue',initialValue2);
if ~isempty(indx2)
    options.perspType = condList2{indx2};
end
if strcmp(options.perspType,condList2{1})
    options.perspIdx = 1;
elseif strcmp(options.perspType,condList2{2})
    options.perspIdx = 2;
end

% % FOR TESTING
% optionsString = 'CMRR';
% subjid = 'test';
% runid = 1;

options.compSetup = optionsString;
options.expName = 'Illusory_Size_Task';
options.expType = 'MR';   % For use in localOptions to look for scanner keyboard
options.expPath = fullfile(options.root_path,options.expName,'fMRI_Task');   % Path specific to the experiment

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
    %     load('3TB_20121213_CLUT.mat','displayInfo'); % KWK updated 20231010
    load('3TB_20231009_CLUT.mat','displayInfo');
    options.displayInfo = displayInfo;   
%     options.displayInfo.linearClut = 0:1/255:1;
else
    options.displayInfo.linearClut = 0:1/255:1;
end
options = localOptions(options);

% Update the datafile name to include the run type
if strcmp('Hallway Present',options.hallPresType)
    options.datafile = [options.datafile '_HallwayPresent'];
elseif strcmp('Hallway Absent',options.hallPresType)
    options.datafile = [options.datafile '_HallwayAbsent'];
end
if strcmp('Upper Left/Lower Right',options.perspType)
    options.datafile = [options.datafile '_LL_UR'];
elseif strcmp('Lower Left/Upper Right',options.perspType)
    options.datafile = [options.datafile '_UL_LR'];
end

% Switch keyboard definition depending on setup
if ~strcmp(options.compSetup,'CMRR')
    options.scanner_id = options.dev_id;
end

%% Trial Varialbes
% List variables to determine trial sequence
options.repetitions = 6;   % Number of times to present the ball vs blank stim
options.numCatch = 5;   % Number of catch trials (black box behind fixation)
options.flipRate = 4;   % Hz of flicker

% Timing variables in seconds
options.time.onTime = 10;
options.time.offTime = 10;

% Determine total time from scanner trigger % On + off + blank
options.time.totalTime = (options.repetitions*options.time.onTime) +...
    ((options.repetitions+1)*options.time.offTime);


% Randomly determine when the catch trials will be presented
catchTimeArray = 2:2:options.time.totalTime-2;
options.time.catchTimeRed = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.time.catchTimeRed);
options.time.catchTimeBlue = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.time.catchTimeBlue);
options.time.catchTimeGreen = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));
catchTimeArray = setdiff(catchTimeArray,options.time.catchTimeGreen);
options.time.catchTimeYellow = catchTimeArray(randperm(length(catchTimeArray),options.numCatch));

options.time.catchTimeRed = sort(options.time.catchTimeRed);
options.time.catchTimeBlue = sort(options.time.catchTimeBlue);
options.time.catchTimeGreen = sort(options.time.catchTimeGreen);
options.time.catchTimeYellow = sort(options.time.catchTimeYellow);
clear catchTimeArray

% Type of block being presented (1=ball present; 2=ball absent)
options.blockType = zeros([1 (options.repetitions*2)+1]);
options.blockType(linspace(1,length(options.blockType),(length(options.blockType)/2)+1)) = 2;
options.blockType(options.blockType(:)==0) = 1;

% Timing variables in seconds
% Start of each block relative to scanner trigger onset
options.time.blockStart = linspace(0,options.time.totalTime-options.time.offTime,length(options.blockType));

% Switch times for each flip of the checkerboard (MxN), with M number of
% blocks and N number of flips at a rate of 4hz. Only care abouit flip times for 
% 'on' blocks every other second (ball present vs ball absent). (10 blocks x 5 seconds each block = 8 flips/sec and 40 flips/block)
for i=1:length(options.time.blockStart)
    % Time at which the phase of the checker will change (Hz rate)
    options.time.flipTimes(i,:) = linspace(options.time.blockStart(i),options.time.blockStart(i)+options.time.onTime,...
        options.flipRate*2*options.time.onTime);
    
    % Need a switch to determine what times the checker balls will be present (only every other second on 'ball present' trials)
    if mod(i,2)==1   % If an odd block number
        options.time.ballPresent(i,:) = zeros([1 options.time.onTime*options.flipRate*2]);
    elseif mod(i,2)==0
        options.time.ballPresent(i,:) = repmat([ones([1 options.flipRate*2]) zeros([1 options.flipRate*2])],[1 options.time.onTime/2]);
    end
end

% Variable to track values on each trial
% rawdata(1) = timing of catch
% rawdata(2) = type of catch
% rawdata(3) = response (1=yes 2=no)
% rawdata(4) = response time
options.time.catchTime = sort([options.time.catchTimeBlue options.time.catchTimeRed options.time.catchTimeGreen options.time.catchTimeYellow]);
data.rawdata = zeros([length(options.time.catchTime),4]);
data.rawdata(:,1) = options.time.catchTime;
options.catchType = zeros([length(options.time.catchTime) 1]);
options.catchType(ismember(options.time.catchTime,options.time.catchTimeRed)) = 1;
options.catchType(ismember(options.time.catchTime,options.time.catchTimeBlue)) = 2;
options.catchType(ismember(options.time.catchTime,options.time.catchTimeGreen)) = 3;
options.catchType(ismember(options.time.catchTime,options.time.catchTimeYellow)) = 4;
data.rawdata(:,2) = options.catchType;


%% Stim Variables
% Make fixation points
options.blackFixation = do_fixation(options);
options.fix.fixOuterOvalColor = options.greenCol;
options.greenFixation = do_fixation(options);
options.fix.fixOuterOvalColor = options.redCol;
options.redFixation = do_fixation(options);
options.fix.fixOuterOvalColor = options.blueCol;
options.blueFixation = do_fixation(options);
options.fix.fixOuterOvalColor = options.yellowCol;
options.yellowFixation = do_fixation(options);
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
options.sizeArray = [1];   % Only need the 1:1 size

% Load in the coords of the circles on the textures and position of fixation
cd ../../Behavioral_Task/Stim/
loadedVars = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_noHallway_7degAlpha_FixLine_SingleCirc.mat'));
options.singleCirc.circCoordTex(1,1,:) = loadedVars.options.singleCirc.circ1CoordTex;
options.singleCirc.circCoordTex(1,2,:) = loadedVars.options.singleCirc.circ2CoordTex;
% Find fixation location
options.singleCirc.fixationLoc = loadedVars.options.singleCirc.fixationLoc;
clear loadedVars

% Load in premade texture arrays
cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim   % cd into the correct folder
for i=1:length(options.sizeArray)
    for j=1:2   % Load both phases
        fixChange = '';
        % Load hallway textures
        options.circTextureArray{1,i,j,1} = imread(sprintf('%s%.3f%s%s%s%s%d%s','./BallHallway_',...
            options.sizeArray(i),'_',options.stimType,'_hallway_7degAlpha_Texture_cyan_',fixChange,j,'.png'));
        
        % Load no hallway textures
        options.circTextureArray{2,i,j,1} = imread(sprintf('%s%.3f%s%s%s%s%d%s','./BallHallway_',...
            options.sizeArray(i),'_',options.stimType,'_noHallway_7degAlpha_Texture_cyan_',fixChange,j,'.png'));
        
        % Make the reverse perspective textures
        for h=1:3   % Flip the image to get the second persepctive
            options.circTextureArray{1,i,j,2}(:,:,h) = flip(options.circTextureArray{1,i,j,1}(:,:,h),2);
            options.circTextureArray{2,i,j,2}(:,:,h) = flip(options.circTextureArray{2,i,j,1}(:,:,h),2);
        end
        
        % Correct the color values in the textures for monitor being used
        options.circTextureArray{1,i,j,1} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i,j,1}+1).*255);
        options.circTextureArray{2,i,j,1} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i,j,1}+1).*255);
        options.circTextureArray{1,i,j,2} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i,j,2}+1).*255);
        options.circTextureArray{2,i,j,2} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i,j,2}+1).*255);
        
        % Pre-make all neccessary textures for faster drawing
        options.circTextures{1,i,j,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i,j,1});
        options.circTextures{2,i,j,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i,j,1});
        options.circTextures{1,i,j,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i,j,2});
        options.circTextures{2,i,j,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i,j,2});
    end
    
    % Load hallway fix only textures
    fixChange = '';
    options.circTextureArray_fixOnly{1,i,1} = imread(sprintf('%s%.3f%s%s%s','./BallHallway_',...
        options.sizeArray(i),'_fixOnly_hallway_7degAlpha_Texture_cyan',fixChange,'.png'));
    
    % Load no hallway fix only textures
    options.circTextureArray_fixOnly{2,i,1} = imread(sprintf('%s%.3f%s%s%s','./BallHallway_',...
        options.sizeArray(i),'_fixOnly_noHallway_7degAlpha_Texture_cyan',fixChange,'.png'));
    
    % Make the reverse perspective textures
    for h=1:3   % Flip the image to get the second persepctive
        options.circTextureArray_fixOnly{1,i,2}(:,:,h) = flip(options.circTextureArray_fixOnly{1,i,1}(:,:,h),2);
        options.circTextureArray_fixOnly{2,i,2}(:,:,h) = flip(options.circTextureArray_fixOnly{2,i,1}(:,:,h),2);
    end
    
    % Correct the color values in the textures for monitor being used
    options.circTextureArray_fixOnly{1,i,1} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i,1}+1).*255);
    options.circTextureArray_fixOnly{2,i,1} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i,1}+1).*255);
    options.circTextureArray_fixOnly{1,i,2} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i,2}+1).*255);
    options.circTextureArray_fixOnly{2,i,2} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i,2}+1).*255);
    
    % Pre-make all neccessary textures for faster drawing
    options.circTextures_fixOnly{1,i,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i,1});
    options.circTextures_fixOnly{2,i,1} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i,1});
    options.circTextures_fixOnly{1,i,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i,2});
    options.circTextures_fixOnly{2,i,2} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i,2});
end
cd ../../../../../fMRI_Task/Stim/

% Texture coords
options.textureCoords = [options.xc-(size(options.circTextureArray{1,i,j},1)/2),options.yc-(size(options.circTextureArray{1,i,j},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j},1)/2),options.yc+(size(options.circTextureArray{1,i,j},2)/2)];

% Find fixation loc in screen coords
options.singleCirc.fixationLocScreen = options.singleCirc.fixationLoc+...
    [options.xc-(size(options.circTextureArray{1,i,j},1)/2),options.yc-(size(options.circTextureArray{1,i,j},2)/2)];
options.singleCirc.fixationOffset = [options.xc options.yc]-options.singleCirc.fixationLocScreen;
% Texture coords - centered at fixation
options.textureCoords(1,:) = [options.xc-(size(options.circTextureArray{1,i,j},1)/2),options.yc-(size(options.circTextureArray{1,i,j},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j},1)/2),options.yc+(size(options.circTextureArray{1,i,j},2)/2)] +...
    [options.singleCirc.fixationOffset options.singleCirc.fixationOffset];
options.textureCoords(2,:) = [options.xc-(size(options.circTextureArray{1,i,j},1)/2),options.yc-(size(options.circTextureArray{1,i,j},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j},1)/2),options.yc+(size(options.circTextureArray{1,i,j},2)/2)] +...
    [-options.singleCirc.fixationOffset(1) options.singleCirc.fixationOffset(2) -options.singleCirc.fixationOffset(1) options.singleCirc.fixationOffset(2)];

% Make cirCoords for the opposite perspective
options.singleCirc.circCoordTex(2,1,:) = options.singleCirc.circCoordTex(1,1,:);
options.singleCirc.circCoordTex(2,2,:) = options.singleCirc.circCoordTex(1,2,:);
options.singleCirc.circCoordTex(2,1,[1 3]) = (abs(squeeze(options.singleCirc.circCoordTex(1,1,[3 1]))'-options.singleCirc.fixationLoc(1))+options.singleCirc.fixationLoc(1))-abs(options.singleCirc.fixationOffset(1))*2;
options.singleCirc.circCoordTex(2,2,[1 3]) = (options.singleCirc.fixationLoc(1)-abs(squeeze(options.singleCirc.circCoordTex(1,2,[3 1]))'-options.singleCirc.fixationLoc(1)))-abs(options.singleCirc.fixationOffset(1))*2;

% % Fixation size in dova
% options.fixSize = .3;

%% Draw
% Randomly determine which phase checkerboard to start w/
phaseIdx = randi(2);
% Hallway present or absent
if options.hallPresIdx == 1   % Hallway present
    hallwayIdx = 1;
elseif options.hallPresIdx == 2   % Hallway absent
    hallwayIdx = 2;
end
% Which perspective
if options.perspIdx == 1   % Hallway present
    perspIdx = 1;
elseif options.perspIdx == 2   % Hallway absent
    perspIdx = 2;
end
blockCount = 2;
flipCount = 1;
catchCounter = 1;
catchSwitch = 1;

% Check to see if we need to run practice trials
if options.practice.doPractice == 1
    % HERE INSTEAD OF RUNNING SEPERATE PRAC TRIALS, RUN 1 CYCLE
    % OF STIM W/ 4 CATCH TRIALS.
    %                 [options,data] = IllContExp_EEGPrac(options,data);
end

% Last instructions before the experiment starts
WaitSecs(.5);
Screen('TextSize',options.windowNum,35);
text1='Press LEFT for BLUE and RIGHT for RED';
text2='Now we will start the experiment.';
text3='Let the experimenter know if you have any questions.';
text4='Press any key when you are ready to continue.';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,options.fixCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+250,options.fixCol);
Screen('Flip',options.windowNum);

WaitSecs(1);
KbWait(options.scanner_id);

clear lastPressScanner lastPressDev

WaitSecs(.5);

% SET PRIO WHILE PRESENTING STIM
priorityLevel=MaxPriority(options.windowNum);
Priority(priorityLevel);

if options.escBreak ~= 1
    Screen('TextSize',options.windowNum,40);
    text1='Press LEFT for BLUE and RIGHT for RED';
    text2='Waiting for scanner...';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
    Screen('Flip',options.windowNum);
    
    % HERE WAIT FOR SCANNER TO START EXPERIMENT
    % KbQueueFlush(options.dev_id);
    % KbQueueFlush(options.scanner_id);
    while 1
        [~, ~, keycode] = KbCheck(-1);
        if keycode(options.buttons.buttonEscape)
            options.escBreak = 1;
            break
        end
        %     [~, ~, keycode] = KbCheck(options.scanner_id);
        if keycode(options.buttons.scannerTrigger)
            break
        end
    end
end

if options.escBreak ~= 1
    % Draw the stim
    Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,1,perspIdx},[],options.textureCoords(perspIdx,:));
    Screen('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
        [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
    Screen('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
        [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
    Screen('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
        [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
    Screen('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
        [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
%     fixColChange = options.whiteCol;   % Fixation
    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        
    % Experiment start
    options.time.expStart = Screen('Flip',options.windowNum);
    
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
                        flipCount = flipCount+1;
                        
                        if options.blockType(blockCount-1) == 1   % 'Balls present'
                            phaseIdx = 3-phaseIdx;
                        elseif options.blockType(blockCount-1) == 2   % 'Balls absent' - don't care about flipping phases
                        end
                        
                        if options.blockType(blockCount-1) == 1   % 'Balls present'
                            if options.time.ballPresent(blockCount-1,flipCount-1) == 1
                                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,perspIdx},[],options.textureCoords(perspIdx,:));
                                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                            elseif options.time.ballPresent(blockCount-1,flipCount-1) == 0
                                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,1,perspIdx},[],options.textureCoords(perspIdx,:));
                                Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                                Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
                                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                            end
                        elseif options.blockType(blockCount-1) == 2   % 'Balls absent'
                            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,1,perspIdx},[],options.textureCoords(perspIdx,:));
                            Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
                                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,1,:))'+[-1 -2 1 -2]+...
                                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                            Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
                                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,2,:))'+[-1 -2 1 -2]+...
                                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                        end
                        
                        % If catch trial
                        if ((GetSecs - options.time.expStart) > options.time.catchTime(catchCounter)) && ...
                                ((GetSecs - options.time.expStart) < options.time.catchTime(catchCounter)+1) % If catch trial
                            switch options.catchType(catchCounter)
                                case 1
                                    Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                                case 2
                                    Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                                case 3
                                    Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                                case 4
                                    Screen('DrawTexture',options.windowNum,options.yellowFixation,[],options.fixationRect);   % present fixation
                            end
                        else
                            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                        end
                        
                        % Flip at the correct time - record the actual time of the flip
                        Screen('Flip',options.windowNum);
                        options.time.flipTimesActual(blockCount-1,flipCount-1) = GetSecs-options.time.expStart;
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
        if catchCounter <= length(options.time.catchTime)
            if ((GetSecs - options.time.expStart) > options.time.catchTime(catchCounter)) && ...
                    ((GetSecs - options.time.expStart) < options.time.catchTime(catchCounter)+2)
                if catchSwitch == 1
                    % Check for key presses
                    [~, ~, keycode] = KbCheck(options.scanner_id);
                    
                    % Check catch trial type (red/blue)
                    switch options.catchType(catchCounter)
                        case 1
                            if keycode(options.buttons.scannerR)
                                disp('r')
                                data.rawdata(catchCounter,3) = 1;
                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                catchSwitch = 0;
                            end
                        case 2
                            if keycode(options.buttons.scannerB)
                                disp('b')
                                data.rawdata(catchCounter,3) = 1;
                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                catchSwitch = 0;
                            end
                        case 3
                            if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)   % Monitor for any buttons press
                                disp('g')
                                data.rawdata(catchCounter,3) = 1;
                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                catchSwitch = 0;
                            end
                        case 4
                            if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)
                                disp('y')
                                data.rawdata(catchCounter,3) = 1;
                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                catchSwitch = 0;
                            end
                    end
                end
            end
        end
        
        % Count up the counter the first time you enter the condiditional+
        if catchCounter < length(options.time.catchTime)
            if (GetSecs - options.time.expStart) > options.time.catchTime(catchCounter)+2
                catchCounter = catchCounter+1;
                catchSwitch = 1;
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
    
    % Display accuracy on Matlab command line
    fprintf('%s%d\n','RB: ',data.aveAccRB)
    fprintf('%s%d\n','YG: ',data.aveAccYG)
    
end

%% End experiment
% End exp screen
text1 = 'Experiment finished...';
DrawFormattedText(options.windowNum,text1,'center',options.yc-250);
Screen('Flip',options.windowNum);

Priority(0);

% Make the rawdata variable into a table so it's easier for others to read
for i=1:size(data.rawdata,2)
    t(:,i)=table(data.rawdata(:,i));
end

% rawdata(1) = timing of catch
% rawdata(2) = type of catch (1=red 2=blue)
% rawdata(3) = response (1=yes 2=no)
% rawdata(4) = response time
t.Properties.VariableNames = {'CatchTime','CatchType','Accuracy','ResponseTime'};

% Save the text f ile for use w/ other programs not Matlab
writetable(t,fullfile(options.datadir,options.datafile));

data.rawdataT = t;

KbWait(options.dev_id);

%% Finish experiment
cleanUp(options,data);

end









