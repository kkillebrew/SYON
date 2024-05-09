% Script for running the MR localizer for the illusory contour experiment.
% 20200109 - KWK

% Experiment for the illusory contour task for the SYON grant.

function [] = IllContExp_MR()

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
% if strcmp(optionsString,'CMRR')
cd(fullfile(options.root_path,'Illusory_Contour_Task/fMRI_Task/Stim'));
% else
% cd(fullfile(options.root_path,'Illusory_Contour_Task/fMRI_Task/Stim'));
% end

options.displayFigs = 0;
options.escBreak = 0;
options.practice.doPractice = 0;
options.analysisCheck = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);

% % FOR TESTING
% optionsString = 'CMRR';
% subjid = 'test';
% runid = 1;

options.compSetup = optionsString;
options.expName = 'Illusory_Contour_Task';
options.expType = 'MR';   % For use in localOptions to look for scanner keyboard
if strcmp(optionsString,'CMRR')
    options.expPath = fullfile(options.root_path,options.expName,'/fMRI_Task/');   % Path specific to the experiment
else
    options.expPath = fullfile(options.root_path,options.expName,'\fMRI_Task\');   % Path specific to the experiment
end
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

% Switch keyboard definition depending on setup
if ~strcmp(options.compSetup,'CMRR')
    options.scanner_id = options.dev_id;
end

%% Trial Varialbes
% List variables to determine trial sequence
options.repetitions = 10;   % Number of times to present the 'on' and 'off' stim
options.blankRepetitions = 5;   % Number of times to present blank fixation blocks
options.numCatch = 10;   % Number of times the fixation will turn red and blue (fixation task trials)
options.flipRate = 4;   % Hz of flicker

% Timing variables in seconds
options.time.onTime = 10;
options.time.offTime = 10;
options.time.blankTime = 10;

% Determine total time from scanner trigger % On + off + blank
options.time.totalTime = (options.repetitions*options.time.onTime) +...
    (options.repetitions*options.time.offTime) +...
    (options.blankRepetitions*options.time.blankTime);

% Randomly determine when the catch trials will be presented
catchTimeArray = 2:2:options.time.totalTime-2;
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

% Type of block being presented (1=on 2=off 2=blank)
options.blockType = zeros([1 (options.repetitions*2)+options.blankRepetitions]);
options.blockType(linspace(1,length(options.blockType),5)) = 3;
% blockTypeChose = [1 2];   % randomize the order of on/off presentation
options.blockType(options.blockType==0) = repmat([1 2],[1 options.repetitions])';

% Timing variables in seconds
% Start of each block relative to scanner trigger onset
options.time.blockStart = linspace(0,options.time.totalTime-options.time.blankTime,length(options.blockType));

% Switch times for each flip of the checkerboard (MxN), with M number of
% blocks and N number of flips at a rate of 4hz (8 flips/second 80 flips/block).
for i=1:length(options.time.blockStart)
    options.time.flipTimes(i,:) = linspace(options.time.blockStart(i),options.time.blockStart(i)+options.time.onTime,...
        options.flipRate*2*options.time.onTime);
end

% Set up the trial sequence for the practice trials
% For practice just run one cycle of the experiment and present 4 catch
% trials.

% Variable to track values on each trial
% rawdata(1) = timing of catch
% rawdata(2) = type of catch (1=red 2=blue 3=green 4=yellow)
% rawdata(3) = response (1=yes 2=no)
% rawdata(4) = response time
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

% Size variables
options.stim.circDia = 1.5;   % Diameter of the circle
options.stim.circDist = 4.5;   % Distance between the center points of each circle
options.stim.circBarGap = .25;   % Distance between the contour rect and inducer
options.checkerboard.checkSize = .5;   % Size of checks
options.stim.contourLength = round(options.PPD*(options.stim.circDist-((options.stim.circBarGap*2)+options.stim.circDia)));   % Length of contour stim
options.stim.contourWidth = round(options.PPD*1);   % Width of contour stim

% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.circDia/2)*options.PPD);
options.checkerboard.yc = round((options.stim.circDia/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.circDia)*options.PPD);
options.checkerboard.yDim = round((options.stim.circDia)*options.PPD);
options.checkerboard.radius = round((options.stim.circDia/2)*options.PPD);

% Make the textures
% Blank texture
options.checkerboard.blankTexArray = zeros([options.checkerboard.xDim,options.checkerboard.yDim]) + options.grayCol(1);
for i=1:2   % For both 'phases'
    options.checkerboard.blankTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.blankTexArray);
end

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.circMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.circMask = options.checkerboard.circMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.radius;

% UL Texture
options.checkerboard.ULMask = options.checkerboard.circMask;
options.checkerboard.ULMask(options.checkerboard.xc:options.checkerboard.xDim,...
    options.checkerboard.yc:options.checkerboard.yDim) = 0;
options.checkerboard.maskHolder = options.checkerboard.ULMask;
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.ULTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.ULTexArray{i}(options.checkerboard.ULMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.ULTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.ULTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% UR Texture
options.checkerboard.URMask = options.checkerboard.circMask;
options.checkerboard.URMask(options.checkerboard.xc:options.checkerboard.xDim,...
    1:options.checkerboard.yc) = 0;
options.checkerboard.maskHolder = options.checkerboard.URMask;
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.URTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.URTexArray{i}(options.checkerboard.URMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.URTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.URTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% LL Texture
options.checkerboard.LLMask = options.checkerboard.circMask;
options.checkerboard.LLMask(1:options.checkerboard.xc,...
    options.checkerboard.yc:options.checkerboard.yDim) = 0;
options.checkerboard.maskHolder = options.checkerboard.LLMask;
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.LLTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.LLTexArray{i}(options.checkerboard.LLMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.LLTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.LLTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% LR Texture
options.checkerboard.LRMask = options.checkerboard.circMask;
options.checkerboard.LRMask(1:options.checkerboard.xc,...
    1:options.checkerboard.yc) = 0;
options.checkerboard.maskHolder = options.checkerboard.LRMask;
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.LRTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.LRTexArray{i}(options.checkerboard.LRMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.LRTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.LRTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

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

% Contour variables
% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = options.stim.contourLength;
options.checkerboard.yDim = options.stim.contourLength;

% Contour texture
options.checkerboard.contourMask = ones([options.stim.contourLength options.stim.contourLength]);
options.checkerboard.contourMask(:,1:round(options.stim.contourLength/2)-round(options.stim.contourWidth/2)) = 0;
options.checkerboard.contourMask(:,round(options.stim.contourLength/2)+round(options.stim.contourWidth/2):options.stim.contourLength) = 0;
options.checkerboard.maskHolder = options.checkerboard.contourMask;
options = createCheckerboard(options);
options.checkerboard.contourTexArray = options.checkerboard.texArrayHolder;
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.contourTexArray{i}(options.checkerboard.contourMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.contourTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.contourTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Contour coords
% Upper
options.stim.contourPositionArray(1,:) = [options.stim.circPositionArray(1,1)+((options.stim.circDia+options.stim.circBarGap)*options.PPD),...
    (options.stim.circPositionArray(1,2)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.stim.circPositionArray(2,1)-(options.stim.circBarGap*options.PPD),...
    (options.stim.circPositionArray(1,2)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD)];
% Right
options.stim.contourPositionArray(2,:) = [(options.stim.circPositionArray(2,1)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc-floor(options.stim.contourLength/2),...
    (options.stim.circPositionArray(2,1)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc+floor(options.stim.contourLength/2)];
% Lower
options.stim.contourPositionArray(3,:) = [options.stim.circPositionArray(1,1)+((options.stim.circDia+options.stim.circBarGap)*options.PPD),...
    (options.stim.circPositionArray(3,2)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.stim.circPositionArray(2,1)-(options.stim.circBarGap*options.PPD),...
    (options.stim.circPositionArray(3,2)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD)];
% Left
options.stim.contourPositionArray(4,:) = [(options.stim.circPositionArray(1,1)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc-floor(options.stim.contourLength/2),...
    (options.stim.circPositionArray(1,1)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc+floor(options.stim.contourLength/2)];

%% Draw
% Randomly determine which phase checkerboard to start w/
checkSwitch = randi(2);
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
    Screen('TextSize',options.windowNum,35);
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
    Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.circPositionArray(1,:),0);
    Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.circPositionArray(2,:),0);
    Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.circPositionArray(3,:),0);
    Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.circPositionArray(4,:),0);
    
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
                        checkSwitch = 3-checkSwitch;
                        flipCount = flipCount+1;
                        
                        if options.blockType(blockCount-1) == 1   % 'On type'
                            texHolder{1} = options.checkerboard.ULTex{checkSwitch};
                            texHolder{2} = options.checkerboard.URTex{checkSwitch};
                            texHolder{3} = options.checkerboard.LLTex{checkSwitch};
                            texHolder{4} = options.checkerboard.LRTex{checkSwitch};
                            
                            posHolder(1,:) = options.stim.circPositionArray(1,:);
                            posHolder(2,:) = options.stim.circPositionArray(2,:);
                            posHolder(3,:) = options.stim.circPositionArray(3,:);
                            posHolder(4,:) = options.stim.circPositionArray(4,:);
                            
                            rotationHolder(1) = 0;
                            rotationHolder(2) = 0;
                            rotationHolder(3) = 0;
                            rotationHolder(4) = 0;
                        elseif options.blockType(blockCount-1) == 2   % 'Off type'
                            texHolder{1} = options.checkerboard.contourTex{checkSwitch};
                            texHolder{2} = options.checkerboard.contourTex{checkSwitch};
                            texHolder{3} = options.checkerboard.contourTex{checkSwitch};
                            texHolder{4} = options.checkerboard.contourTex{checkSwitch};
                            
                            posHolder(1,:) = options.stim.contourPositionArray(1,:);
                            posHolder(2,:) = options.stim.contourPositionArray(2,:);
                            posHolder(3,:) = options.stim.contourPositionArray(3,:);
                            posHolder(4,:) = options.stim.contourPositionArray(4,:);
                            
                            rotationHolder(1) = 90;
                            rotationHolder(2) = 0;
                            rotationHolder(3) = 90;
                            rotationHolder(4) = 0;
                        elseif options.blockType(blockCount-1) == 3   % 'Blank type'
                            texHolder{1} = options.checkerboard.blankTex{checkSwitch};
                            texHolder{2} = options.checkerboard.blankTex{checkSwitch};
                            texHolder{3} = options.checkerboard.blankTex{checkSwitch};
                            texHolder{4} = options.checkerboard.blankTex{checkSwitch};
                            
                            posHolder(1,:) = options.stim.circPositionArray(1,:);
                            posHolder(2,:) = options.stim.circPositionArray(2,:);
                            posHolder(3,:) = options.stim.circPositionArray(3,:);
                            posHolder(4,:) = options.stim.circPositionArray(4,:);
                            
                            rotationHolder(1) = 0;
                            rotationHolder(2) = 0;
                            rotationHolder(3) = 0;
                            rotationHolder(4) = 0;
                        end
                        
                        % Draw the stim
                        Screen('DrawTexture',options.windowNum,texHolder{1},[],posHolder(1,:),rotationHolder(1));
                        Screen('DrawTexture',options.windowNum,texHolder{2},[],posHolder(2,:),rotationHolder(2));
                        Screen('DrawTexture',options.windowNum,texHolder{3},[],posHolder(3,:),rotationHolder(3));
                        Screen('DrawTexture',options.windowNum,texHolder{4},[],posHolder(4,:),rotationHolder(4));
                        
                        if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                                ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+1) % If catch trial
                            if options.catchType(catchCounter)==1
                                Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                            elseif options.catchType(catchCounter)==2
                                Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                            elseif options.catchType(catchCounter)==3
                                Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                            elseif options.catchType(catchCounter)==4
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
        if catchCounter <= length(options.catchTime)
            if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                    ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+2)
                if catchSwitch == 1
                    
                    % Check for key presses
                    [~, ~, keycode] = KbCheck(options.scanner_id);
                    
                    % Check catch trial type (red/blue)
                    if options.catchType(catchCounter)==1
                        if keycode(options.buttons.scannerR)
                            disp('r')
                            data.rawdata(catchCounter,3) = 1;
                            data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                            catchSwitch = 0;
                        end
                    elseif options.catchType(catchCounter)==2
                        if keycode(options.buttons.scannerB)
                            disp('b')
                            data.rawdata(catchCounter,3) = 1;
                            data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                            catchSwitch = 0;
                        end
                    elseif options.catchType(catchCounter)==3
                        if keycode(options.buttons.scannerR) || keycode(options.buttons.scannerB)   % Monitor for any buttons press
                            disp('g')
                            data.rawdata(catchCounter,3) = 1;
                            data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                            catchSwitch = 0;
                        end
                    elseif options.catchType(catchCounter)==4
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
        
        % Count up the counter the first time you enter the condiditional
        if catchCounter < length(options.catchTime)
            if (GetSecs - options.time.expStart) > options.catchTime(catchCounter)+2
                catchCounter = catchCounter+1;
                catchSwitch = 1;
                
                % Save
%                 cleanUp(options,data,1);
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



