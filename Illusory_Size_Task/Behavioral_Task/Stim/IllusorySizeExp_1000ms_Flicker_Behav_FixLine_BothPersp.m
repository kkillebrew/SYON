% Illusory size behavioral experiment (based on Murray et al, 2006).
% Participants are presented with 2 white balls (each with depth cues, i.e.
% shadows and shading) in a brick hallway (context), the top presented
% further along the hallway (larger with context) the bottom presented
% closer in the hallway (smaller). The part is asked to adjust the bottom
% to match the size of the top.

function [] = IllusorySizeExp_1000ms_Flicker_Behav_FixLine_BothPersp()

clearvars -except optionsString subjid runid; close all; sca;
Screen('Preference', 'SkipSyncTests', 1);
% switch nargin
%     case 1
%         subjid = [];
%         runid = [];
%     case 2
%         runid = [];
% end

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
cd(fullfile(options.root_path,'Illusory_Size_Task','Behavioral_Task','Stim'));
% end mps 20190730

options.displayFigs = 0;
options.practice.doPractice = 1;
options.practice.practiceBreak = 0;
options.analysisCheck = 0;
options.screenShot = 0;
options.eyeTracking = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);
subjid = [subjid '_1000ms_Flicker_FixLine_BothPersp'];

% Setup options struct
options.compSetup = optionsString;
options.expName = 'Illusory_Size_Task';
options.expType = 'MR_Prac';   % For use in localOptions to look for scanner keyboard
options.expPath = fullfile(options.root_path,options.expName,'Behavioral_Task');   % Path specific to the experiment % mps 20190730
options.eyeTrackingPath = '/Users/psphuser/Desktop/SchallmoLab/eyetracking/';   %%%%%% NEED TO UPDATE THIS W/ CORRECT PATH NOT IN SYON.GIT
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
    %         options.screenNum = max(Screen('Screens')); % mps 20200328
    %     load('Asus_VG248QE_vaCoglab_lightsoff_20190904.mat','displayInfo');
    %     options.displayInfo = displayInfo;
end

%% Start eyetracking/calibration

ListenChar(2);

% Clock variables for datafile name
options.el.datecode = datestr(now,'mmddyy');

% ET Datafile name
if options.eyeTracking == 1
    options.el_datafile = ['SZ_' options.el.datecode];
end

% Do calibration
if options.eyeTracking == 1
    [options] = setupCMRREyeTracking(options);
end

ListenChar(0);

%% Finish initilization

% Turn off keyboard input
% ListenChar(2);   % Silence keyboard input

options = localOptions(options);

% Switch keyboard definition depending on setup
if ~strcmp(options.compSetup,'CMRR_Psychophysics')
    options.dev_id2 = options.dev_id;
end

% ET Datafile name
if options.eyeTracking == 1
    options.el_datafile = ['SZ' options.datecode];
end

% Turn keyboard input back on
% ListenChar(0);   % Silence keyboard input

%% Trial variables
% List variables to determine trial sequence
options.backgroundList = [1 2];   % 1=background 2=no background
options.backgroundNum = length(options.backgroundList);
options.stairList = [1 2];   % 2 staircases for each block (1=upper right, lower left; 2=upper left, lower right)
options.stairNum = length(options.stairList);
options.blockList = [1 2 3 4];   % Number of blocks
options.blockNum = length(options.blockList);
options.perspList = [1 2];   % 1=upper right, lower left; 2=upper left, lower right
options.perspNum = length(options.perspList);
options.catchNum = 10;   % Num catch trials per condition (10 each largest/smallest background/no background)

options.repetitions = 30;   % Number of trials in the staircase
options.practice.practiceRepetitions = 10;    % Number of practice trials/step

options.blockLength = options.stairNum*options.repetitions;   % Length of a block before adding catch trials

% 4 total blocks 1=block 1/3 background; 2=block 1/3 no background
% 1=background; 2=no background
options.blockOrder = randi(2);   % Randomize which block comes first
if options.blockOrder == 1
    options.blockArray = [1 2 1 2];
elseif options.blockOrder == 2
    options.blockArray = [2 1 2 1];
end

% Make varlist
% Block 1
varList1 = repmat(fullfact([options.perspNum]),[options.repetitions 1]);   % varlist for first block
varList1(length(varList1)+1:length(varList1)+options.catchNum,1) = 3;   % Add catch trials numCatch each per condition per block 3=larger
varList1(length(varList1)+1:length(varList1)+options.catchNum,1) = 4;   % Add catch trials numCatch each per condition per block 4=smaller
varList1(:,2) = options.blockArray(options.blockList(1));   % Background
varList1(:,3) = options.blockList(1);   % Block
varList1(:,4) = repmat(fullfact([2]),[length(varList1)/2,1]);   % Perspectice 1=upper right, lower left; 2=upper left, lower right
% Block 2
varList2 = repmat(fullfact([options.perspNum]),[options.repetitions 1]);   % varlist for first block
varList2(length(varList2)+1:length(varList2)+options.catchNum,1) = 3;   % Add catch trials numCatch each per condition per block 3=larger
varList2(length(varList2)+1:length(varList2)+options.catchNum,1) = 4;   % Add catch trials numCatch each per condition per block 4=smaller
varList2(:,2) = options.blockArray(options.blockList(2));   % Background
varList2(:,3) = options.blockList(2);   % Block
varList2(:,4) = repmat(fullfact([2]),[length(varList2)/2,1]);   % Perspectice 1=upper right, lower left; 2=upper left, lower right
% Block 3
varList3 = repmat(fullfact([options.perspNum]),[options.repetitions 1]);   % varlist for first block
varList3(length(varList3)+1:length(varList3)+options.catchNum,1) = 3;   % Add catch trials numCatch each per condition per block 3=larger
varList3(length(varList3)+1:length(varList3)+options.catchNum,1) = 4;   % Add catch trials numCatch each per condition per block 4=smaller
varList3(:,2) = options.blockArray(options.blockList(3));   % Background
varList3(:,3) = options.blockList(3);   % Block
varList3(:,4) = repmat(fullfact([2]),[length(varList3)/2,1]);   % Perspectice 1=upper right, lower left; 2=upper left, lower right
% Block 4
varList4 = repmat(fullfact([options.perspNum]),[options.repetitions 1]);   % varlist for first block
varList4(length(varList4)+1:length(varList4)+options.catchNum,1) = 3;   % Add catch trials numCatch each per condition per block 3=larger
varList4(length(varList4)+1:length(varList4)+options.catchNum,1) = 4;   % Add catch trials numCatch each per condition per block 4=smaller
varList4(:,2) = options.blockArray(options.blockList(4));   % Background
varList4(:,3) = options.blockList(4);   % Block
varList4(:,4) = repmat(fullfact([2]),[length(varList4)/2,1]);   % Perspectice 1=upper right, lower left; 2=upper left, lower right
% Combine varlists
options.varList = [varList1; varList2; varList3; varList4];   % total varList

% Scramble each block seperately
trialList1 = randperm(length(varList1))';
trialList2 = randperm(length(varList2))'+length(trialList1);
trialList3 = randperm(length(varList3))'+length(trialList1)+length(trialList2);
trialList4 = randperm(length(varList4))'+length(trialList1)+length(trialList2)+length(trialList3);
options.trialOrder = [trialList1; trialList2;trialList3; trialList4];
options.numTrials = length(options.varList);

% Give participants a break in between blocks
options.break_trials = options.numTrials/4+1:options.numTrials/4:options.numTrials;   % Break for each block
% Lets not give inbetween block feedback, b/c there is no 'right' or 'wrong' (well there is but, we don't want them to
% necessarily be veridical, we want their perceptual response). 

% Preallocate rawdata
data.rawdata = zeros([options.numTrials 8]);

% Size array
options.sizeArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];

%% Setup the stiarcase using palamedes
clear stair
data.psyFunc = @PAL_Logistic; %psychometric function to fit
data.guessrate = 0.04; % gamma value (baseline - labeled as ) for fitting   % kwk changed 20190830
data.lapserate = 0.04; % probability of making an error during response, damien suggests 4% for naive subj
data.xL = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];   % Sizes (in % of far circle)
data.aL = .5:.005:1.5; % threshold prior range   % kwk = new range used w/ wider lum value range 20190925
% data.bL = exp(-1:.2:6); % slope prior range
data.bL = exp(-3:.2:4);

% % How to figure out slope: Make sure there is a full range of potential
% % slopes in the psychometric curve from almost flat to almost  square wave.
% x = .5:.005:1.5;
% slopes = exp(-2:.2:5);
% clear y
% for iY = 1:numel(slopes)
%     y(:,iY) = PAL_Logistic([1 slopes(iY) 0.04 0.04],x);
% end
% figure; hold on; plot(repmat(x',[1 size(y,2)]),y)
% % figure; hold on; plot(x,y(:,1))
% hold on
% plot(x,y(:,end))

for i = 1:options.blockNum   % 4 total blocks
    for j = 1:options.stairNum   % Number of staircases to setup (2 stairs / block; 4 blocks total)
        data.stair(i,j) = PAL_AMPM_setupPM('priorAlphaRange',data.aL,...
            'priorBetaRange',data.bL,...
            'stimRange',data.xL,...
            'gamma',data.guessrate,...
            'lambda',data.lapserate,...
            'PF',data.psyFunc,...
            'numTrials',options.repetitions,...
            'gammaEQlambda',1); % creates psi data structure
    end
end


%% Stim Variables
% Circle sizes
% Use predetermined size values (in % of far circle)
% Stim type - same check size or same check num
options.stimType = 'sameCheckNum';

% Load in the position and sizing values to generate both persps
loadedVars = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_noHallway_7degAlpha_FixLine_1.mat'));
% Find fixation location
options.singleCirc.fixationLoc = loadedVars.options.fixationLoc;
clear loadedVars

% Load in premade texture arrays
for i=1:length(options.sizeArray)
    for j=1:2   % Load both phases
        % Load hallway textures
        options.circTextureArray{1,i,j,1} = imread(sprintf('%s%.3f%s%s%s%d%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
            options.sizeArray(i),'_',options.stimType,'_hallway_7degAlpha_Texture_FixLine_',j,'.png'));
        
        % Load no hallway textures
        options.circTextureArray{2,i,j,1} = imread(sprintf('%s%.3f%s%s%s%d%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
            options.sizeArray(i),'_',options.stimType,'_noHallway_7degAlpha_Texture_FixLine_',j,'.png'));
        
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
    options.circTextureArray_fixOnly{1,i,1} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_fixOnly_hallway_7degAlpha_Texture_FixLine.png'));
    
    % Load no hallway fix only textures
    options.circTextureArray_fixOnly{2,i,1} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_fixOnly_noHallway_7degAlpha_Texture_FixLine.png'));
    
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

% Texture coords
options.textureCoords = [options.xc-(size(options.circTextureArray{1,i,j},1)/2),options.yc-(size(options.circTextureArray{1,i,j},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j},1)/2),options.yc+(size(options.circTextureArray{1,i,j},2)/2)];


%% Timing variables
% Total time spheres are on screen
options.stimPresTime = 1;

% Total time part has to response
options.responseTime = 1;

% Time of the blank screen before stim pres
options.blankOnsetTime = .5;

% Flicker rate info
options.hz = 4;
options.flickerRate = 1/(options.hz*2);
options.flickerTimes = 0:options.stimPresTime/(options.hz*2):options.stimPresTime;   % Flicker times relative to trial start


%% Practice
% Check to see if we need to run practice trials
if options.practice.doPractice == 1
    % Run practice
    [options,data] = IllSizeExp_Flicker_FixLine_Prac(options,data);
elseif options.practice.doPractice ~= 1
    % Last instructions before the experiment starts
    WaitSecs(.5);
    text1='Now we will start the experiment.';
    text2='Please let the experimenter know if you have any questions or concerns.';
    text3='Tell the experimenter when you are ready to continue...';
    text4='LAST SCREEN BEFORE EXPERIMENT START!';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
    DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.whiteCol);
    Screen('Flip',options.windowNum);
    
    [~, ~, keycode] = KbCheck(options.dev_id);
    while 1
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonF)
            break
        end
        if keycode(options.buttons.buttonEscape)
            options.practice.practiceBreak = 1;
            break
        end
    end
end

% Start eyetracking for the experiment
if options.eyeTracking == 1
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(1.1);
end

%% Expeirmnet start
escapeSwitch = 0;
for n=1:length(options.trialOrder)
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
            
            % Stop eyetracking for break
            if options.eyeTracking == 1
                %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
                %             Eyelink('Message', et_message);
                
                WaitSecs(0.1);
                % stop the recording of eye-movements for the current trial
                Eyelink('StopRecording');
            end
            
            % display break message
            text1='Please take a break. Feel free to blink or move your eyes.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
            text2='You''re doing great!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
            text3='Let the experimenter know when you are ready to continue...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
            Screen('Flip',options.windowNum);
            WaitSecs(1);
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    break;
                end
            end
            
            % Start eyetracking for this block
            if options.eyeTracking == 1
                Eyelink('Command', 'set_idle_mode');
                WaitSecs(0.05);
                Eyelink('StartRecording');
                % record a few samples before we actually start displaying
                % otherwise you may lose a few msec of data
                WaitSecs(1.1);
            end
            
        end
        
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
        
        % Setup initial rawdata values
        data.rawdata(n,1) = n;   % Trial order
        data.rawdata(n,2) = options.trialOrder(n);   % Trial number
        backgroundIdx = options.varList(options.trialOrder(n),2);   % 1=shape targ, no shape ref 2=no shape targ, no shape ref
        data.rawdata(n,3) = backgroundIdx;
        stairIdx = options.varList(options.trialOrder(n),1);   % Determine what staircase (which perspective) you are on for this trial
        data.rawdata(n,4) = stairIdx;
        blockIdx = options.varList(options.trialOrder(n),3);   % What block are you in?
        data.rawdata(n,5) = blockIdx;
        perspIdx = options.varList(options.trialOrder(n),4);
        data.rawdata(n,6) = perspIdx;
        
        if stairIdx == 3   % Catch trial larger
            data.currSize(n) = options.sizeArray(end);
        elseif stairIdx == 4   % Catch trial smaller
            data.currSize(n) = options.sizeArray(1);
        elseif stairIdx == 1 || stairIdx == 2   % Normal staircase
            data.currSize(n) = data.stair(blockIdx,stairIdx).xCurrent;
        end
        
        data.currSizeIdx(n) = find(options.sizeArray==data.currSize(n));
        data.rawdata(n,7) = data.currSize(n);
        
        if options.screenShot == 1
            data.currSizeIdx(n) = 15;
            backgroundIdx = 1;
        end
        
        %% Draw stim
        % Start trial presentation
        sync_time = Screen('Flip',options.windowNum);
        
        % Send eyetracker trigger for trial start
        if options.eyeTracking == 1
            et_message = '1 - Trial Start';
            Eyelink('Message', et_message);
        end
        
        % Blank screen (fixation)
        % For the behavioral task we don't want to present the gray circle first b/c it presents additional time for them to
        % process the size of the circle, which you don't want in a psychophysiscs task.
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{backgroundIdx,data.currSizeIdx(n),perspIdx},[],squeeze(options.textureCoords));
        %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,2,:,data.currSizeIdx(n))));
        
        [~, blankOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time)-options.flip_interval_correction);
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s%d%s','illSizeBlank_',data.currSizeIdx(n),'_',backgroundIdx,'.png'));
        end
        
        % Start time for next flip
        % Draw texture
        phaseSwitch = 1;
        Screen('DrawTexture',options.windowNum,options.circTextures{backgroundIdx,data.currSizeIdx(n),phaseSwitch,perspIdx},[],squeeze(options.textureCoords));
        %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
        
        [~, options.stimOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time+options.blankOnsetTime)-options.flip_interval_correction);
        
        flipCounter = 2;
        while 1
            trialCheck = (GetSecs - options.stimOnsetTime(n)) > options.stimPresTime-.001;   % When total time excedes run time stop
            switch trialCheck
                case 0
                    flipTest = (GetSecs-options.stimOnsetTime(n))>options.flickerTimes(flipCounter);
                    switch flipTest
                        case 1   % Redraw
                            phaseSwitch = 3-phaseSwitch;
                            
                            % Draw texture
                            Screen('DrawTexture',options.windowNum,options.circTextures{backgroundIdx,data.currSizeIdx(n),phaseSwitch,perspIdx},...
                                [],squeeze(options.textureCoords));
                            %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
                            
                            Screen('Flip',options.windowNum);
                            
                            flipCounter = flipCounter+1;
                    end
                case 1
                    break
            end
        end
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s%d%s','illSizeStim_',data.currSizeIdx(n),'_',backgroundIdx,'.png'));
        end
        
        % Wait for response
        text1='Was the left (LEFT KEY) or right (RIGHT KEY) sphere bigger?';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
        
        [~, responseOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stimOnsetTime(n)+options.stimPresTime)-options.flip_interval_correction);
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s','illSizeResp_',data.currSizeIdx(n),'.png'));
        end
        
        % Record response
        %         [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
        [~, ~, keycode] = KbCheck(options.dev_id2);
        responseBreak = 0;
        %         startTime = GetSecs;
        %         timeNow = GetSecs;
        %         while timeNow-(startTime+options.responseTime) <= 0
        while 1
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                escapeSwitch = 1;
                break
            end
            
            % Update timing variable
            %             timeNow = GetSecs;
            
            % Check for mouse press
            %             [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            %             [~,~,keycode,~] = KbCheck(-3);
            [~, ~, keycode] = KbCheck(options.dev_id2);
            switch responseBreak
                case 0   % If no response recorded
                    %                     if buttonsHolder(3) == 1   % Top
                    

                    
                    if keycode(options.buttons.buttonRight)
                        if perspIdx == 1   % upper right/lower left
                            data.rawdata(n,8) = 1;   % Record response
                        elseif perspIdx == 2   % upper left/lower right
                            data.rawdata(n,8) = 2;   % Record response
                        end
                        data.rawdata(n,9) = GetSecs-options.stimOnsetTime(n);   % RT
                        responseBreak = 1;
                        %                     elseif buttonsHolder(1) == 1   % Bottom
                    elseif keycode(options.buttons.buttonLeft)
                        if perspIdx == 1   % upper right/lower left
                            data.rawdata(n,8) = 2;   % Record response
                        elseif perspIdx == 2   % upper left/lower right
                            data.rawdata(n,8) = 1;   % Record response
                        end
                        data.rawdata(n,9) = GetSecs-options.stimOnsetTime(n);   % RT
                        responseBreak = 1;
                    end
                case 1
                    break
                otherwise
            end
        end
        
        [~, ~, keycode] = KbCheck ;
        if keycode(options.buttons.buttonEscape) || escapeSwitch == 1
            escapeSwitch = 1;
            break
        end
        
        % Reset screen
        % Fixation
        %         Screen('FillOval',options.windowNum,options.whiteCol,[options.xc-3 options.yc-3 options.xc+3 options.yc+3]);
        
        Screen('Flip',options.windowNum);
        
        % Did they chose the test (bottom/variable size) or ref (top/constant size)?
        if data.rawdata(n,8) == 1   % Chose top
            data.rawdata(n,10) = 0;   % Chose test (constant size)
        elseif data.rawdata(n,8) == 2   % Chose bottom
            data.rawdata(n,10) = 1;   % Chose ref (changing size)
            %         elseif data.rawdata(n,6) == 0   % Didn't respond
            %             data.rawdata(n,8) = 0;
        end
        
        if stairIdx == 3 || stairIdx == 4   % Catch trial - don't update staircase
        elseif stairIdx == 1 || stairIdx == 2    % Update the staircase
            data.stair(blockIdx,stairIdx) = PAL_AMPM_updatePM(data.stair(blockIdx,stairIdx),data.rawdata(n,10));
        end
        
        if keycode(options.buttons.buttonEscape) || escapeSwitch == 1
            
            % End eyetracking for this experiment
            if options.eyeTracking == 1
                %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
                %             Eyelink('Message', et_message);
                
                WaitSecs(0.1);
                % stop the recording of eye-movements for the current trial
                Eyelink('StopRecording');
            end
            
            options.practice.practiceBreak = 1;
            Screen('CloseAll');
            break
        end
        
    else
        break
    end
    
    % If screen shot then break
    if options.screenShot == 1
        break
    end
    
    % If you've reached the end of the experiment turn on analysis switch
    if n==length(options.trialOrder)
        sca
        options.analysisCheck = 1;
    end
end

% End eyetracking
if options.eyeTracking == 1
    %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
    %             Eyelink('Message', et_message);
    
    WaitSecs(0.1);
    
    stopCMRREyeTracking(options);
end

% Save
optionsSave = options;
optionsSave = rmfield(optionsSave,{'circTextureArray','circTextureArray_fixOnly','circTextures_fixOnly','circTextures'});
cleanUp(optionsSave,data);
clear optionsSave

% [~, ~, keycode] = KbCheck ;
% if keycode(options.buttons.buttonEscape) || escapeSwitch == 1
%     Screen('CloseAll');
% end

%% Calculate threshold and save to threshold file
% If they finished the experiment
if options.practice.practiceBreak ~= 1
    
    % Make the rawdata variable into a table so it's easier for others to read
    for i=1:size(data.rawdata,2)
        t(:,i)=table(data.rawdata(:,i));
    end
    t.Properties.VariableNames = {'PresOrder','TrialNumber','Background','StairNum','BlockNum','PerspNum'...
        'CurrSize','Response','ReactionTIme','Stair_Update'};
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,fullfile(options.datadir,options.datafile));
    
    % Set the stair struct and rawdata to a data struct to send to save
    data.rawdataT = t;
    
    % Save data before doing the analysis
    optionsSave = options;
    optionsSave = rmfield(optionsSave,{'circTextureArray','circTextureArray_fixOnly','circTextures_fixOnly','circTextures'});
    cleanUp(optionsSave,data);
    clear optionsSave
    
    %% Analysis
    if options.analysisCheck == 1
        data.thresh.estimate_lapse_from_catch = 0; % do we estimate the upper asymptote for
        % accuracy based on performance on catch trials, or just assume a fixed
        % value?
        data.thresh.thresh_pct = 0.5; % pct correct to evaluate for threshold % kwk changed 20190909
        data.thresh.min_lapse = 0.04; % this is the lowest we'll ever set the lapse rate,
        % regardless of catch performance. Since there's 30 catch trials,
        % this conservatively assumes everyone will miss 1/30...
        data.thresh.max_thresh =  1.5; % maximum theoretical threshold, exclude if outside % kwk 20190909
        data.thresh.min_thresh = .5; % kwk 20190909
        
        data.thresh.paramsFree = [1 1 0 0]; % which parameters to fit, (1 = threshold, 2 = slope, 3 = guess rate, 4 = lapse rate
        data.thresh.PF = @PAL_Logistic; % which psychometric function to use
        
        plot_symbols = {'o','s','^'};
        plot_lines = {'-','--','-.'};
        if options.blockOrder == 1
            cond_label{1} = 'Background';
            cond_label{2} = 'NoBackground';
            cond_label{3} = 'Background';
            cond_label{4} = 'NoBackground';
        elseif options.blockOrder == 2
            cond_label{1} = 'NoBackground';
            cond_label{2} = 'Background';
            cond_label{3} = 'NoBackground';
            cond_label{4} = 'Background';
        end
        
        for i=1:options.blockNum   % Num blocks
            
            if options.displayFigs == 1; figure; end % mps 20190730
            for j=1:size(data.stair,2)   % Num staircases - 2 for each block (1 UL/LR, 1 LL/UR
                
                clear numPos outOfNum catchAccArrayHolder
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
                data.thresh.searchGrid(i,j).gamma = data.stair(i,j).guess(end);
                %                     data.thresh.searchGrid(i,j).gamma = 0.5;
                if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
                    data.thresh.searchGrid(i,j).lambda = max([1-mean(data.thresh.catch_accuracy(i)) data.thresh.min_lapse]);
                else % else assume fixed value used during task
                    data.thresh.searchGrid(i,j).lambda = data.stair(i,j).lapse(end);
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
                    subplot(1,size(data.stair,2)*size(data.stair,3)+1,j); hold on % one subplot per staircase
                    for iX = 1:numel(data.thresh.stimLevels{i,j}) % plot raw data (accuracy vs. stimulus intensity, larger symbols for more trials)
                        plot(data.thresh.stimLevels{i,j}(iX),data.thresh.numPos{i,j}(iX)/data.thresh.outOfNum{i,j}(iX),...
                            ['g' plot_symbols{1}],'MarkerSize',data.thresh.outOfNum{i,j}(iX)+2,...
                            'linewidth',2);
                    end
                    x_val = .5:.025:1.5;   % X-axis array
                    plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-'); % threshold fiducial line
                    
                    %                 plot(x_val,PF(old_params,x_val),['c' plot_lines{1}])
                    
                    plot(x_val,data.thresh.PF(squeeze(data.thresh.paramsFit(i,j,:)),x_val),['b' plot_lines{1}],...
                        'linewidth',2); % plot refit psychometric function
                    
                    %                 plot([thresh_old(iS,iC,iR) thresh_old(iS,iC,iR)],[0 1],...
                    %                     ['m' plot_lines{1}])
                    
                    plot([data.thresh.thresh_refit(i,j) data.thresh.thresh_refit(i,j)],[0 1],...
                        ['r'  plot_lines{1}],'linewidth',2) % plot refit threshold
                    
                    axis([.5 1.5 -0.05 1.05])
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
            for j=1:size(data.stair,2)   % Num staircases - 2 blocks 2 stairs each
                data.thresh.ave(i).xComb = [data.thresh.ave(i).xComb data.stair(i,j).x(1:end-1)];
                data.thresh.ave(i).responseComb = [data.thresh.ave(i).responseComb data.stair(i,j).response];
            end
            data.thresh.ave(i).stimLevels = unique(data.thresh.ave(i).xComb);
            
            for k=1:length(data.thresh.ave(i).stimLevels)
                find_x = find(data.thresh.ave(i).xComb == data.thresh.ave(i).stimLevels(k));   % Find the indices
                data.thresh.ave(i).numPos(k) = length(find(data.thresh.ave(i).responseComb(find_x) == 1));   % How many were correctly responded to
                data.thresh.ave(i).outOfNum(k) = length(find_x);   % How many total
            end
            
            data.thresh.ave(i).searchGrid.alpha = data.stair(i,1,1).priorAlphaRange;
            data.thresh.ave(i).searchGrid.beta = data.stair(i,1,1).priorBetaRange;
            data.thresh.ave(i).searchGrid.gamma = data.stair(i,1,1).guess(end);
            if data.thresh.estimate_lapse_from_catch % if we are estimating this from catch performance
                data.thresh.ave(i).searchGrid.lambda = max([1-mean(data.thresh.catch_accuracy(i)) data.thresh.min_lapse]);
            else % else assume fixed value used during task
                data.thresh.ave(i).searchGrid.lambda = data.stair(i,1,1).lapse(end);
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
                subplot(1,size(data.stair,2)*size(data.stair,3)+1,size(data.stair,2)*size(data.stair,3)+1); hold on
                
                % Plot rawdata acc
                for j=1:numel(data.thresh.ave(i).stimLevels)
                    plot(data.thresh.ave(i).stimLevels(j),data.thresh.ave(i).numPos(j)/data.thresh.ave(i).outOfNum(j),...
                        ['g' plot_symbols{1}],'MarkerSize',data.thresh.ave(i).outOfNum(j)+2,'linewidth',2)
                end
                
                % Thresh fiducial line
                x_val = .5:.025:1.5;
                plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
                
                % Refit psychometric function
                plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(i).paramsFit(:)),x_val),['b' plot_lines{1}],...
                    'linewidth',2);
                
                % Refit threshold
                plot([data.thresh.ave(i).thresh_refit data.thresh.ave(i).thresh_refit],[0 1],...
                    ['r' plot_lines{2}],'linewidth',2);
                
                axis([.5 1.5 -0.05 1.05])
                box off
                
                title([cond_label{i} ' - Combined']);
                set(gca,'fontsize',12)
                
            end
        end
        
        % Plot comparison graph
        if options.displayFigs == 1; figure;
            
            % Plot the four psychometric fits on the same plot
            subplot(1,4,1); hold on;
            plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
            x_val = .5:.025:1.5;
            if options.blockOrder == 1
                lineCol = {'r' 'b' 'r' 'b'};
                lineTypeTitle = {'Background-1','NoBackground-1','Background-2','NoBackground-2'};
                faceColor = [1 0 0; 0 0 1; 1 0 0; 0 0 1];
                barOrder = [1 3 2 4];
            elseif options.blockOrder == 2
                lineCol = {'b' 'r' 'b' 'r'};
                lineTypeTitle = {'NoBackground-1','Background-1','NoBackground-2','Background-2'};
                faceColor = [0 0 1; 1 0 0; 0 0 1; 1 0 0];
                barOrder = [2 4 1 3];
            end
            for k=1:options.blockNum
                blockPlot(k) = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(k).paramsFit(:)),x_val),[lineCol{k} plot_lines{1}],...
                    'linewidth',2);
                plot([data.thresh.ave(k).thresh_refit data.thresh.ave(k).thresh_refit],[0 1],...
                    [lineCol{k} plot_lines{2}],'linewidth',2);
            end
            axis([.5 1.5 -0.05 1.05])
            box off
            title('Background-No Background');
            set(gca,'fontsize',12)
            legend(blockPlot(:),lineTypeTitle,'location','northwest');
            
            % Plot the combined thresh in bargraph for shape/noshape
            subplot(1,4,2); hold on;
            for k=1:options.blockNum
                combinedBar(k) = bar(k,[data.thresh.ave(barOrder(k)).thresh_refit]);
                combinedBar(k).FaceColor = faceColor(barOrder(k),:);
                hold on
            end
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2 3 4]);
            set(gca,'XTickLabel',lineTypeTitle(barOrder))
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Combined Background-No Background PSE')
            
            % Plot the mean/std across the 4 staircases
            data.thresh.thresh_refit_mean(barOrder(1:2)) = nanmean(data.thresh.thresh_refit(barOrder(1:2),:));
            data.thresh.thresh_refit_mean(barOrder(3:4)) = nanmean(data.thresh.thresh_refit(barOrder(3:4),:));
            data.thresh.thresh_refit_ste(barOrder(1:2)) = ste(data.thresh.thresh_refit(barOrder(1:2),:));
            data.thresh.thresh_refit_ste(barOrder(3:4)) = ste(data.thresh.thresh_refit(barOrder(3:4),:));
            
            subplot(1,4,3); hold on;
            for k=1:options.blockNum
                meanBar(k) = bar(k,[data.thresh.thresh_refit_mean(barOrder(k))]);
                meanBar(k).FaceColor = faceColor(barOrder(k),:);
                meanErrorbar(k) = errorbar(k,data.thresh.thresh_refit_mean(barOrder(k)),...
                    data.thresh.thresh_refit_ste(barOrder(k)),'.k');
            end
            hold on
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2 3 4]);
            set(gca,'XTickLabel',lineTypeTitle(barOrder))
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Mean Background-No Background PSE')
            
            % Calculate and plot catch trial accuracy
            data.largerCatchBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10))/...
                length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==1),10)))*100;   % Larger catch hallway
            data.largerCatchNoBack = (sum(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10))/...
                length(data.rawdata((data.rawdata(:,4)==3 & data.rawdata(:,3)==2),10)))*100;   % Larger catch no hallway
            data.smallerCatchBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10))/...
                length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),10)))*100;   % Smaller catch hallway
            data.smallerCatchNoBack = (sum(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10))/...
                length(~data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),10)))*100;   % Smaller catch no hallway
            
            data.catchAve = nanmean([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);
            data.catchSTD = std([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack]);
            
            subplot(1,4,4); hold on;
            bar([data.largerCatchBack data.largerCatchNoBack data.smallerCatchBack data.smallerCatchNoBack data.catchAve]);
            hold on
            errorbar(5,data.catchAve,data.catchSTD,'.k');
            ylim([0 110])
            set(gca,'YTick',[0:10:110]);
            set(gca,'XTick',[1:5]);
            set(gca,'XTickLabel',{'Larger Hallway','Larger No Hallway','Smaller Hallway','Smaller No Hallway','Average'})
            set(gca,'XTickLabelRotation',45);
            %             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Average Catch Trial Accuracy')
        end
        
        optionsSave = options;
        optionsSave = rmfield(optionsSave,{'circTextureArray','circTextureArray_fixOnly','circTextures_fixOnly','circTextures'});
        cleanUp(optionsSave,data,1);
        clear optionsSave
    end
end


end





