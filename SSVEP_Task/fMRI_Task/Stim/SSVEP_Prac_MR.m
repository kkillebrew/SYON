% Script for running the MR localizer for the illusory contour experiment.
% 20200109 - KWK

% Experiment for the illusory contour task for the SYON grant.

function [options,data] = SSVEP_Prac_MR()

% clearvars -except optionsString subjid runid; close all; sca;
% switch nargin
%     case 1
%         subjid = [];
%         runid = [];
%     case 2
%         runid = [];
% end

clear; 
close all;

clear PsychHID; % Force new enumeration of devices.
clear KbCheck; % Clear persistent cache of keyboard devices.

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
optionsString = 'CMRR_Psychophysics';

addpath(genpath(fullfile(options.root_path,'Functions')));
% if strcmp(optionsString,'CMRR_Psychophysics')
cd(fullfile(options.root_path,'SSVEP_Task/fMRI_Task/Stim'));
% else
% cd(fullfile(options.root_path,'SSVEP_Task\fMRI_Task\Stim'));
% end

options.escBreak = 0;
options.pracTrialEscBreak = 0;
options.pracFinished = 0;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);

% % FOR TESTING
% optionsString = 'CMRR_Psychophysics';
% subjid = 'test';
% runid = 1;

options.compSetup = optionsString;
options.expName = 'SSVEP_Task';   % UPDATE FOR PSYCHOPHYS COMP
options.expType = 'MR_Prac';   % For use in localOptions to look for scanner keyboard
options.expPath = fullfile(options.root_path,options.expName,'/fMRI_Task/');   % Path specific to the experiment

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
elseif strcmp(options.compSetup,'CMRR_Psychophysics')    % UPDATE FOR PSYCHOPHYS COMP
    load('lab_20130620_CLUT_105T.mat','displayInfo');
    options.displayInfo = displayInfo;
    %     options.displayInfo.linearClut = 0:1/255:1;
else
    options.displayInfo.linearClut = 0:1/255:1;
end
options = localOptions(options);

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
options.instSwitch = 1;

%% Trial Varialbes
% List variables to determine trial sequence
options.repetitions = 2;   % Number of times to present the 'on' and 'off' stim
options.blankRepetitions = 2;   % Number of times to present blank fixation blocks
options.numCatch = 5;   % Number of times the fixation will turn red and blue (fixation task trials)
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
options.blockType = [3 1 2 1 2 3];

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
options.fixSize = options.fix.fixSizeOuter/2;   % Fixation size in degrees
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
    yy - options.checkerboard.yc) <= ((options.fixSize+options.fixSizeCut)*options.PPD));

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

% Blank texture
options.checkerboard.blankTexArray = zeros([options.checkerboard.xDim,options.checkerboard.yDim]) + options.grayCol(1);
for i=1:2   % For both 'phases'
    options.checkerboard.blankTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.blankTexArray);
end

% Fixation location
% options.stim.fixLocs = options.fixationRect;

%% Present instructions
while options.escBreak ~= 1   % loop until escaped
    
    % Screen 1
    if options.escBreak ~= 1 && options.instSwitch == 1
        text2='Your task is to keep your eyes fixed';
        text3='on the black and white cross in the center of the screen.';
        
        while 1
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100,options.fixCol);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+150,options.fixCol);
            
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            
            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 2;
                break
            end
            
        end
    end
    
    % Screen 2
    if options.escBreak ~= 1 && options.instSwitch == 2
        timeNow2=GetSecs;
        colorFixSwitch=1;
        fixSwitch2=1;
        fixCol = options.whiteCol;   % Fixation color
        while 1
            
            text1='Sometimes the black circle will change color.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            
            % Draw the stim
%             Screen('FillOval',options.windowNum,fixCol,options.stim.fixLocs);
            
            fixSwitch = (GetSecs-timeNow2) > 1;
            if fixSwitch
                timeNow2 = GetSecs;
                fixSwitch2 = 3-fixSwitch2;
                switch fixSwitch2
                    case 1
                        switch colorFixSwitch
                            case 1
                                colorFixSwitch = 2;
                                Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                            case 2
                                colorFixSwitch = 3;
                                Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                            case 3
                                colorFixSwitch = 4;
                                Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                            case 4
                                colorFixSwitch = 1;
                                Screen('DrawTexture',options.windowNum,options.yellowFixation,[],options.fixationRect);   % present fixation
                        end
                    case 2
                        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                end
                DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                Screen('Flip',options.windowNum);
            end
            

            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 1;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 3;
                break
            end
        end
    end
    
    % Screen 3
    if options.escBreak ~= 1 && options.instSwitch == 3
        timeNow2=GetSecs;
        fixSwitch2=1;
        while 1
            fixSwitch = (GetSecs-timeNow2) > 1;
            if fixSwitch
                fixSwitch2 = 3-fixSwitch2;
                timeNow2 = GetSecs;
            end
            switch fixSwitch2
                case 1
                    Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                    text2='PRESS RED';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
                case 2
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            end
            
            text1='When it changes to RED, press the red (RIGHT) button.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            
            % Draw the stim
            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 2;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 4;
                break
            end
        end
    end
    
    % Screen 4
    if options.escBreak ~= 1 && options.instSwitch == 4
        timeNow2=GetSecs;
        fixSwitch2=1;
        while 1
            fixSwitch = (GetSecs-timeNow2) > 1;
            if fixSwitch
                fixSwitch2 = 3-fixSwitch2;
                timeNow2 = GetSecs;
            end
            switch fixSwitch2
                case 1
                    Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                    text2='PRESS BLUE';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
                case 2
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            end
            
            text1='When it changes to BLUE, press the blue (LEFT) button.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            
            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 3;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 5;
                break
            end
        end
    end
    
    % Screen 5
    if options.escBreak ~= 1 && options.instSwitch == 5
        text1='Let''s do some practice...';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
        
        Screen('Flip',options.windowNum);
        
        while 1
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 4;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 6;
                break
            end
        end
    end
    
    % Screen 6
    if options.escBreak ~= 1 && options.instSwitch == 6
        pracEsc=0;
        prevScreen = 0;
        blueRedPracStart = GetSecs;
        data.blueRedPrac = zeros([5 1]);
        timeNow2=GetSecs;
        colorFixSwitch=1;
        fixSwitch2=1;
        blueRedPracCounter=0;
        fixCol = options.whiteCol;   % Fixation color
        clear KbCheck; % Clear persistent cache of keyboard devices.
        clear PsychHID; % Force new enumeration of devices.
        while 1
            if pracEsc == 1
                text1='Restart practice (Space)? Show previous screen (r)? Or end practice (ESC)?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                
                Screen('Flip',options.windowNum);
                
                while 1
                    
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        WaitSecs(.5);
                        options.escBreak = 1;
                        pracEsc = 0;
                        break
                    elseif keycode(options.buttons.buttonSpace)
                        WaitSecs(.5);
                        pracEsc = 0;
                        blueRedPracStart = GetSecs;
                        data.blueRedPrac = zeros([5 1]);
                        timeNow2=GetSecs;
                        colorFixSwitch=1;
                        fixSwitch2=1;
                        blueRedPracCounter=0;
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    elseif keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        pracEsc = 0;
                        prevScreen = 1;
                        options.instSwitch = 5;
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    end
                end
                
            elseif options.escBreak ~= 1 && prevScreen == 0
                while (GetSecs-blueRedPracStart) < 12
                    
                    % If esc during prac, ask to restart or to quit practice
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        WaitSecs(.5);
                        pracEsc = 1;
                        break
                    end
                    
                    fixSwitch = (GetSecs-timeNow2) > 1;
                    if fixSwitch
                        timeNow2 = GetSecs;
                        fixSwitch2 = 3-fixSwitch2;
                        switch fixSwitch2
                            case 1
                                switch colorFixSwitch
                                    case 1
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 2;
                                        Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                                    case 2
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 1;
                                        Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                                end
                            case 2
                                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                        
                        end
                        
                        Screen('Flip',options.windowNum);
                    end
                    
                    % Monitor for button presses
                    % Check for key presses
                    %                     [~, ~, keycode] = KbCheck(options.dev_id);
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    
                    % Check catch trial type (red/blue)

                    if blueRedPracCounter>0
                        switch colorFixSwitch
                            case 2
                                if keycode(options.buttons.button4) || keycode(options.buttons.scannerR)
                                    %                                 text1='Red';
                                    %                                 textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                    %                                 DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                    data.blueRedPrac(blueRedPracCounter) = 1;
                                end
                            case 1
                                if keycode(options.buttons.button1) || keycode(options.buttons.scannerB)
                                    %                                 text1='Blue';
                                    %                                 textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                    %                                 DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                    data.blueRedPrac(blueRedPracCounter) = 1;
                                end
                        end
                    end
                end
            end
            % If you run through all prac trials break out of loop
            if blueRedPracCounter==5 || options.escBreak || prevScreen == 1
                break
            end
        end
        
        if options.escBreak ~= 1  && prevScreen == 0
            % Behavrioral analysis
            % Average accuracy
            % First look at accuracy of b/r trials
            data.blueRedPracAcc = (sum(data.blueRedPrac)/length(data.blueRedPrac))*100;
                        
            % Display accuracy
            text1=sprintf('%s%d%s','Your practice accuracy was: ',data.blueRedPracAcc,' %');
            text2='Repeat practice trials (r)?';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
            
            Screen('Flip',options.windowNum);
            WaitSecs(.5);
            
            while 1
                
                
                [~, ~, keycode] = KbCheck(-3);
                if keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    options.instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    WaitSecs(.5);
                    options.escBreak = 1;
                    break
                elseif keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    options.instSwitch = 7;
                    break
                end
            end
        end
    end
    
    % Screen 7
    if options.escBreak ~= 1 && options.instSwitch == 7
        timeNow2=GetSecs;
        fixSwitch2=1;
        colorFixSwitch = 1;
        while 1
            fixSwitch = (GetSecs-timeNow2) > 1;
            if fixSwitch
                fixSwitch2=3-fixSwitch2;
                if fixSwitch2==1
                    colorFixSwitch = 3-colorFixSwitch;
                end
                timeNow2 = GetSecs;
            end
            switch fixSwitch2
                case 1
                    switch colorFixSwitch
                        case 1
                            Screen('DrawTexture',options.windowNum,options.yellowFixation,[],options.fixationRect);   % present fixation
                        case 2
                            Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                    end
                    text2='NO PRESS';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
                case 2
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            end
            
            text1='If it changes to green or yellow, don''t press any buttons.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);

            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 6;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 8;
                break
            end
        end
    end
    
    % Screen 8
    if options.escBreak ~= 1 && options.instSwitch == 8
        text1='Let''s do some practice...';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
        
        Screen('Flip',options.windowNum);
        
        while 1
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 7;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 9;
                break
            end
        end
    end
    
    % Screen 9
    if options.escBreak ~= 1 && options.instSwitch == 9
        prevScreen = 0;
        pracEsc=0;
        blueRedPracStart = GetSecs;
        data.yellowGreenPrac = zeros([10 1]);
        timeNow2=GetSecs;
        colorFixSwitch=1;
        fixSwitch2=1;
        blueRedPracCounter=0;
        fixCol = options.whiteCol;   % Fixation color
        
        clear KbCheck; % Clear persistent cache of keyboard devices.
        clear PsychHID; % Force new enumeration of devices.
        while 1
            if pracEsc == 1
                text1='Restart practice (Space)? Show previous screen (r)? Or end practice (ESC)?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                
                Screen('Flip',options.windowNum);
                
                while 1
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        WaitSecs(.5);
                        options.escBreak = 1;
                        pracEsc = 0;
                        break
                    elseif keycode(options.buttons.buttonSpace)
                        WaitSecs(.5);
                        pracEsc = 0;
                        blueRedPracStart = GetSecs;
                        data.yellowGreenPrac = zeros([10 1]);
                        timeNow2=GetSecs;
                        colorFixSwitch=1;
                        fixSwitch2=1;
                        blueRedPracCounter=0;
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    elseif keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        pracEsc = 0;
                        prevScreen = 1;
                        options.instSwitch = 8;
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    end
                end
                
            elseif options.escBreak ~= 1 && prevScreen == 0
                while (GetSecs-blueRedPracStart) < 22
                    
                    % If esc during prac, ask to restart or to quit practice
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        WaitSecs(.5);
                        pracEsc = 1;
                        break
                    end
                    
                    fixSwitch = (GetSecs-timeNow2) > 1;
                    if fixSwitch
                        timeNow2 = GetSecs;
                        fixSwitch2 = 3-fixSwitch2;
                        wrongAnsSwitch=0;
                        switch fixSwitch2
                            case 1
                                switch colorFixSwitch
                                    case 1
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 3;
                                        Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                                        data.yelloGreenType(blueRedPracCounter) = 1;
                                    case 2
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 4;
                                        Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                                        data.yelloGreenType(blueRedPracCounter) = 2;
                                    case 3
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 2;
                                        Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                                        data.yelloGreenType(blueRedPracCounter) = 3;
                                    case 4
                                        blueRedPracCounter = blueRedPracCounter+1;
                                        colorFixSwitch = 1;
                                        Screen('DrawTexture',options.windowNum,options.yellowFixation,[],options.fixationRect);   % present fixation
                                        data.yelloGreenType(blueRedPracCounter) = 4;
                                end
                            case 2
                                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                        end
                        % Draw the stim                        
                        Screen('Flip',options.windowNum);
                    end
                    
                    % Monitor for button presses
                    % Check for key presses
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    
                    % Check catch trial type (red/blue)
                    if blueRedPracCounter>0
                        switch colorFixSwitch
                            case 3
                                if keycode(options.buttons.button4) || keycode(options.buttons.scannerR)
                                    text1='Red';
                                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                    DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                    data.yellowGreenPrac(blueRedPracCounter) = 1;
                                end
                            case 4
                                if keycode(options.buttons.button1) || keycode(options.buttons.scannerB)
                                    text1='Blue';
                                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                    DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                    data.yellowGreenPrac(blueRedPracCounter) = 1;
                                end
                            case 2
                                if keycode(options.buttons.button1) || keycode(options.buttons.button4) || keycode(options.buttons.scannerB) || keycode(options.buttons.scannerR)
                                    data.yellowGreenPrac(blueRedPracCounter) = 0;
                                    wrongAnsSwitch=1;
                                else
                                    if wrongAnsSwitch==1
                                        text1='Green';
                                        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                        data.yellowGreenPrac(blueRedPracCounter) = 1;
                                    end
                                end
                            case 1
                                if keycode(options.buttons.button1) || keycode(options.buttons.button4) || keycode(options.buttons.scannerB) || keycode(options.buttons.scannerR)
                                    data.yellowGreenPrac(blueRedPracCounter) = 0;
                                    wrongAnsSwitch=1;
                                else
                                    if wrongAnsSwitch==1
                                        text1='Yellow';
                                        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                                        data.yellowGreenPrac(blueRedPracCounter) = 1;
                                    end
                                end
                        end
                    end
                end
            end
            % If you run through all prac trials break out of loop
            if blueRedPracCounter==10 || options.escBreak || prevScreen == 1
                break
            end
        end
        if options.escBreak ~= 1 && prevScreen == 0
            % Behavrioral analysis
            % Average accuracy
            % First look at accuracy of b/r trials
            data.yellowGreenPracAcc1 = (sum(data.yellowGreenPrac(data.yelloGreenType==1 | data.yelloGreenType==2))/length(data.yellowGreenPrac(data.yelloGreenType==1 | data.yelloGreenType==2)))*100;
            data.yellowGreenPracAcc2 = (sum(~data.yellowGreenPrac(data.yelloGreenType==3 | data.yelloGreenType==4))/length(data.yellowGreenPrac(data.yelloGreenType==1 | data.yelloGreenType==2)))*100;
            data.yellowGreenPracAcc = ((sum(data.yellowGreenPrac(data.yelloGreenType==1 | data.yelloGreenType==2))+...
                sum(~data.yellowGreenPrac(data.yelloGreenType==3 | data.yelloGreenType==4)))/...
                (length(data.yellowGreenPrac(data.yelloGreenType==1 | data.yelloGreenType==2))+...
                length(~data.yellowGreenPrac(data.yelloGreenType==3 | data.yelloGreenType==4))))*100;
            
            % Display accuracy
            text1=sprintf('%s%d%s','Your practice accuracy was: ',data.yellowGreenPracAcc,' %');
            text2='Repeat practice trials (r)?';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
            
            Screen('Flip',options.windowNum);
            WaitSecs(.5);
            
            while 1
                
                
                [~, ~, keycode] = KbCheck(-3);
                if keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    options.instSwitch = 9;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    WaitSecs(.5);
                    options.escBreak = 1;
                    break
                elseif keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    options.instSwitch = 10;
                    break
                end
            end
        end
    end
    
    % Screen 10
    if options.escBreak ~= 1 && options.instSwitch == 10
        text1='You may also see a flickering checkerboard inside four circles...';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        
        checkSwitch = 1;
        startTime = GetSecs;
        while 1
            flipCheck = (GetSecs - startTime) > .25;   % Switch every 250 ms
            switch flipCheck
                case 1
                    checkSwitch = 3-checkSwitch;
                    startTime = GetSecs;
            end
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            
            % Draw the stim
            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(1,:));
            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(2,:));
            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(3,:));
            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(4,:));
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 11;
                break
            end
            if keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 9;
                break
            end
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            end
        end
    end
    
    % Screen 11
    if options.escBreak ~= 1 && options.instSwitch == 11
        text1='Or in one large circle.';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        
        checkSwitch = 1;
        startTime = GetSecs;
        while 1
            flipCheck = (GetSecs - startTime) > .25;   % Switch every 250 ms
            switch flipCheck
                case 1
                    checkSwitch = 3-checkSwitch;
                    startTime = GetSecs;
            end
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            
            % Draw the stim
            Screen('DrawTexture',options.windowNum,options.checkerboard.surrCircTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 12;
                break
            end
            if keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 10;
                break
            end
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            end
        end
    end
    
    % Screen 12
    if options.escBreak ~= 1 && options.instSwitch == 12
        text1='These will be presetned in 10s blocks, mixed in with blank blocks.';
        text2='Your task is still the same: keep your eyes fixed';
        text3='on the black and white cross in the center of the screen, and respond to the color changes.';
        
        timeNow1=GetSecs;
        timeNow2=GetSecs;
        checkSwitch=1;
        colorFixSwitch=1;
        fixSwitch2=1;
        fixCol = options.whiteCol;   % Fixation color
        while 1
            flipSwitch = (GetSecs-timeNow1) > .25;
            switch flipSwitch
                case 1
                    timeNow1=GetSecs;
                    checkSwitch=3-checkSwitch;
            end
            fixSwitch = (GetSecs-timeNow2) > 1;
            if fixSwitch
                timeNow2 = GetSecs;
                fixSwitch2 = 3-fixSwitch2;
                switch fixSwitch2
                    case 1
                        switch colorFixSwitch
                            case 1
                                colorFixSwitch = 2;
                                Screen('DrawTexture',options.windowNum,options.redFixation,[],options.fixationRect);   % present fixation
                            case 2
                                colorFixSwitch = 3;
                                Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                            case 3
                                colorFixSwitch = 4;
                                Screen('DrawTexture',options.windowNum,options.greenFixation,[],options.fixationRect);   % present fixation
                            case 4
                                colorFixSwitch = 1;
                                Screen('DrawTexture',options.windowNum,options.yellowFixation,[],options.fixationRect);   % present fixation
                        end
                    case 2
                        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,options.fixCol);
                
                % Draw the stim
                Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(1,:));
                Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(2,:));
                Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(3,:));
                Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(4,:));
                
                Screen('Flip',options.windowNum);
            end
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 11;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 13;
                break
            end
            
        end
    end
    
    % Screen 13
    % Last instructions before the practice starts
    if options.escBreak ~= 1 && options.instSwitch == 13
        WaitSecs(.5);
        text1='LAST SCREEN BEFORE PRACTICE TRIALS!';
        text2='Let''s do some practice blocks.';
        text3='We''ll start with a blank block where no checkerboard shapes will appear.';
        text4='Then, we''ll do two practice blocks of each of the checkerboard stimuli.';
        text5='It will end with one more blank block.';
        text6='Please let the experimenter know if you ave any questions.';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
        DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
        DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+250,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
        DrawFormattedText(options.windowNum,text5,'center',(textHeight/2)+300,options.fixCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
        DrawFormattedText(options.windowNum,text6,'center',(textHeight/2)+350,options.fixCol);
        
        Screen('Flip',options.windowNum);
        
        % KbQueueFlush(options.dev_id);
        while 1
            
            
            [~, ~, keycode] = KbCheck(-3);
            if keycode(options.buttons.buttonEscape)
                WaitSecs(.5);
                options.escBreak = 1;
                break
            elseif keycode(options.buttons.buttonR)
                WaitSecs(.5);
                options.instSwitch = 12;
                break
            elseif keycode(options.buttons.buttonF)
                WaitSecs(.5);
                options.instSwitch = 14;
                break
            end
        end
    end
    
    
    %% Start prac trials
    % Screen 14
    if options.escBreak ~= 1 && options.instSwitch == 14
        % Randomly determine which phase checkerboard to start w/
        checkSwitch = randi(2);
        blockCount = 2;
        flipCount = 1;
        catchCounter = 1;
        catchSwitch = 1;
        prevScreen = 0;
        
        clear KbCheck; % Clear persistent cache of keyboard devices.
        clear PsychHID; % Force new enumeration of devices.
        
        WaitSecs(.5);
        
        % SET PRIO WHILE PRESENTING STIM
        priorityLevel=MaxPriority(options.windowNum);
        Priority(priorityLevel);
        
        % If they press esc during prac trial, give the option to restart prac
        % trials or exit from practice.
        while 1
            if options.pracTrialEscBreak == 1 && options.pracFinished ~= 1
                text1='Restart practice (Space)? Show previous screen (r)? Or end practice (ESC)?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
                
                Screen('Flip',options.windowNum);
                
                while 1
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        options.escBreak = 1;
                        options.pracTrialEscBreak = 1;
                        break
                    elseif keycode(options.buttons.buttonSpace)
                        % Reset practice trial variables
                        % Randomly determine which phase checkerboard to start w/
                        checkSwitch = randi(2);
                        blockCount = 2;
                        flipCount = 1;
                        catchCounter = 1;
                        catchSwitch = 1;
                        
                        % Reset prac data
                        data.rawdata = zeros([length(options.catchTime),4]);
                        data.rawdata(:,1) = options.catchTime;
                        options.catchType = zeros([length(options.catchTime) 1]);
                        options.catchType(ismember(options.catchTime,options.catchTimeRed)) = 1;
                        options.catchType(ismember(options.catchTime,options.catchTimeBlue)) = 2;
                        options.catchType(ismember(options.catchTime,options.catchTimeGreen)) = 3;
                        options.catchType(ismember(options.catchTime,options.catchTimeYellow)) = 4;
                        data.rawdata(:,2) = options.catchType;
                        
                        options.pracTrialEscBreak = 0;
                        
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    elseif keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        options.pracTrialEscBreak = 0;
                        prevScreen = 1;
                        options.instSwitch = 13;
                        
                        clear KbCheck; % Clear persistent cache of keyboard devices.
                        clear PsychHID; % Force new enumeration of devices.
                        break
                    end
                end
                
            elseif options.pracTrialEscBreak ~= 1 && prevScreen == 0 && options.pracFinished ~= 1
                % Draw the stim
                Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
                
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                
                % Experiment start
                options.time.expStart = Screen('Flip',options.windowNum);
                
                options.time.scannerTriggerNum = 1;
                options.time.scannerTriggerTime = GetSecs - options.time.expStart;
                while 1
                    
                    
                    
                    [~, ~, keycode] = KbCheck(-3);
                    if keycode(options.buttons.buttonEscape)
                        WaitSecs(.5);
                        options.pracTrialEscBreak = 1;
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
                                            
                                            % Draw the stim
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(1,:));
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(2,:));
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(3,:));
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{checkSwitch},[],options.stim.centCircPositionArray(4,:));
                                            
                                        case 2   % 'Off type' - Surround
                                            
                                            % Draw the stim
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.surrCircTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
                                            
                                        case 3   % 'Blank type'
                                            
                                            % Draw the stim
                                            Screen('DrawTexture',options.windowNum,options.checkerboard.blankTex{checkSwitch},[],options.stim.surrCircPositionArray(1,:));
                                            
                                    end
                                    
                                    if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                                            ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+1) % If catch trial
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
                    if catchCounter <= length(options.catchTime)
                        if ((GetSecs - options.time.expStart) > options.catchTime(catchCounter)) && ...
                                ((GetSecs - options.time.expStart) < options.catchTime(catchCounter)+2)
                            switch catchSwitch
                                case 1
                                    
                                    % Check for key presses
                                    
                                    
                                    [~, ~, keycode] = KbCheck(-3);
                                    
                                    % Check catch trial type (red/blue)
                                    switch options.catchType(catchCounter)
                                        case 1
                                            if keycode(options.buttons.button4)  || keycode(options.buttons.scannerR)
                                                %                                             disp('r')
                                                data.rawdata(catchCounter,3) = 1;
                                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                                catchSwitch = 0;
                                            end
                                        case 2
                                            if keycode(options.buttons.button1) || keycode(options.buttons.scannerB)
                                                %                                             disp('b')
                                                data.rawdata(catchCounter,3) = 1;
                                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                                catchSwitch = 0;
                                            end
                                        case 3
                                            if keycode(options.buttons.button4) || keycode(options.buttons.button1) || keycode(options.buttons.scannerB) || keycode(options.buttons.scannerR)   % Monitor for any buttons press
                                                %                                             disp('g')
                                                data.rawdata(catchCounter,3) = 1;
                                                data.rawdata(catchCounter,4) = (GetSecs-options.time.expStart) - options.time.flipTimesActual(blockCount-1,flipCount-1);
                                                catchSwitch = 0;
                                            end
                                        case 4
                                            if keycode(options.buttons.button4) || keycode(options.buttons.button1) || keycode(options.buttons.scannerB) || keycode(options.buttons.scannerR)
                                                %                                             disp('y')
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
                        end
                    end
                    
                    
                end
            end
            % If you run through all prac trials break out of loop
            if options.escBreak || prevScreen == 1 || catchCounter == size(data.rawdata,1)
                break
            end
        end
        
        if options.escBreak ~= 1 && prevScreen == 0
            Priority(0);
            
            % Behavrioral analysis
            % Average accuracy
            % First look at accuracy of b/r trials
            data.aveAccRB = sum(data.rawdata(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2)),3))/length(find(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2))))*100;
            % Then look at accuracy of g/y trials
            data.aveAccYG = sum(~data.rawdata(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4)),3))/length(find(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4))))*100;
            % Look at total accuracy
            data.aveAccTotal = ((sum(data.rawdata(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2)),3))+...
                sum(~data.rawdata(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4)),3)))/...
                (length(find(((data.rawdata(:,2)==1)|(data.rawdata(:,2)==2))))+...
                length(find(((data.rawdata(:,2)==3)|(data.rawdata(:,2)==4))))))*100;
            
            
            % Average response time
            data.aveRT = nanmean(data.rawdata(:,4));
            
            % Display accuracy
            text1=sprintf('%s%d%s','Your practice accuracy was: ',data.aveAccTotal,' %');
            text2='Repeat practice trials?';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+100,options.fixCol);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+150,options.fixCol);
            
            Screen('Flip',options.windowNum);
            WaitSecs(.5);
            
            while 1
                
                
                [~, ~, keycode] = KbCheck(-3);
                if keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    options.pracTrialEscBreak = 1;
                    break
                elseif keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    options.pracTrialEscBreak = 1;
                    options.pracFinished = 1;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    WaitSecs(.5);
                    options.escBreak = 1;
                    options.pracTrialEscBreak = 1;
                    options.pracFinished = 1;
                    break
                end
            end
        end
        % If the practie finished then break
        if options.pracFinished == 1
            break
        end
    end
end

%% End and cleanup
if options.escBreak ~=1
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

    %Screen 15
    % Last instructions before the practice starts
    WaitSecs(.5);
%     text1='LAST SCREEN!';
    text2='In the fMRI scanner, you will see different checkerboard shapes,';
    text3='but your task will always be the same: keep your eyes fixed on the';
    text4='center black and white cross and respond RIGHT when the circle turns RED';
    text5='and LEFT when it turns BLUE.';
    text6='Please let the experimenter know if you have any questions.';
%     textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
%     DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+200,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+150,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
    DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+200,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
    DrawFormattedText(options.windowNum,text5,'center',(textHeight/2)+250,options.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
    DrawFormattedText(options.windowNum,text6,'center',(textHeight/2)+300,options.fixCol);

    Screen('Flip',options.windowNum);

    WaitSecs(2);

    KbWait(-3);
end

% End exp screen
text1 = 'Practice finished...';
DrawFormattedText(options.windowNum,text1,'center',options.yc-250);
Screen('Flip',options.windowNum);
KbWait(-3);

% SAVE
cleanUp(options,data);

end



