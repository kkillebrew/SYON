% Experiment for the illusory size task for the SYON grant.

function [] = IllusorySizeExp_GrayCirc_EEG()

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

[optionsString,subjid,runid] = userInputDialogBox(optionsString);

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
options.practice.practiceBreak = 0;
options.practice.practiceCheck = 1;   % Variable that tells exp to present the practice trials at start of block
options.practice.doPractice = 0;
options.displayFigs =0;
options.eegRecording = 0;
options.analysisCheck = 0;
options.photodiodeTesting = 0;

% Update the datafile name
options.datafile = [options.datafile '_GrayCirc'];

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

options.repetitions = 100;   % Number of trials/condition
options.fixTrialRepetitions = 10;   % Number of fixation change trials/block
options.numBlocks = 4;   % Number of blocks/experiment

options.practice.practiceRepetitions = 20;    % Number of practice trials

options.trialsPerBlock = options.repetitions+options.fixTrialRepetitions;

options.varList = zeros([options.trialsPerBlock*options.numBlocks,5]);   % Initialize varList

% Creat fixation change trial conditions
options.fixChangeVarList(:,1) = zeros([options.fixTrialRepetitions*options.numBlocks,1]);   % Block num
options.fixChangeVarList(:,2:3) = repmat(fullfact([options.illSizeNum options.hallwayNum]),[options.fixTrialRepetitions,1]);   % close/far and hallway/no hallway
options.fixChangeVarList(:,4) = repmat(fullfact([options.phaseListNum]),[(options.fixTrialRepetitions*options.numBlocks)/2 1]);   % Phase of checkerboard
options.fixChangeVarList(:,5) = zeros([options.fixTrialRepetitions*options.numBlocks,1])+2;   % Trial type (Fix change)
options.fixTrialNums = [randperm(options.trialsPerBlock, options.fixTrialRepetitions) ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock*2 ...
    randperm(options.trialsPerBlock, options.fixTrialRepetitions)+options.trialsPerBlock*3];

options.varList(options.fixTrialNums,:) = options.fixChangeVarList;   % Assign fix change trials to proper trial spot

% Make a list of trials that are not fixation change trials
options.varList(options.varList(:,5)==0,5) = 1;
options.noFixTrialNums = find(options.varList(:,5)==1);

% Make varlist for each block and randomize trial order
for i=1:options.numBlocks
    options.varList(((i-1)*options.trialsPerBlock)+1:(i*options.trialsPerBlock),1) = i;   % Block number
    
    options.varList(options.noFixTrialNums(((i-1)*options.repetitions)+1:(i*options.repetitions)),2:3) = repmat(fullfact([options.illSizeNum options.hallwayNum]),...
        [options.repetitions/options.numBlocks 1]);   % close/far and hallway/no hallway
        
    options.varList(options.noFixTrialNums(((i-1)*options.repetitions)+1:(i*options.repetitions)),4) = repmat(fullfact(options.phaseListNum),[options.repetitions/2 1]);   % Phase of checkerboard
        
    options.trialOrder(((i-1)*options.trialsPerBlock)+1:(i*options.trialsPerBlock)) = randperm(options.trialsPerBlock)+((i-1)*options.trialsPerBlock);
end

options.numTrials = length(options.varList);

% Give participants a break in between blocks
options.break_trials = round(options.numTrials/4+1:options.numTrials/4:options.numTrials);   % Breaks half way through each block

% Variable to track values on each trial
data.rawdata = zeros([length(options.varList),8]); 

%% Stim Variables
% Circle sizes
% Use predetermined size values (in % of far circle)
% Stim type - same check size or same check num
options.stimType = 'sameCheckNum';

% Stim sizes needed to load in
options.sizeArray = [1];   % Only need the 1:1 size for single ball stim

% Load in the coords of the circles on the textures
cd ../../Behavioral_Task/Stim/
loadedVars = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_noHallway_7degAlpha_FixLine_SingleCirc.mat'));
options.singleCirc.circCoordTex(1,:) = loadedVars.options.singleCirc.circ1CoordTex;
options.singleCirc.circCoordTex(2,:) = loadedVars.options.singleCirc.circ2CoordTex;
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
                options.circTextureArray{1,i,j,k,p} = imread(sprintf('%s%.3f%s%s%s%s%s%s%d%s','./BallHallway_',...
                    options.sizeArray(i),'_',options.stimType,'_hallway_7degAlpha_',whichSphere,'_Texture_cyan_',fixChange,j,'.png'));
                
                % Load no hallway textures
                options.circTextureArray{2,i,j,k,p} = imread(sprintf('%s%.3f%s%s%s%s%s%s%d%s','./BallHallway_',...
                    options.sizeArray(i),'_',options.stimType,'_noHallway_7degAlpha_',whichSphere,'_Texture_cyan_',fixChange,j,'.png'));
                
                % Correct the color values in the textures for monitor being used
                options.circTextureArray{1,i,j,k,p} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i,j,k,p}+1).*255);
                options.circTextureArray{2,i,j,k,p} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i,j,k,p}+1).*255);
                
                % Pre-make all neccessary textures for faster drawing
                options.circTextures{1,i,j,k,p} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i,j,k,p});
                options.circTextures{2,i,j,k,p} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i,j,k,p});
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
        options.circTextureArray_fixOnly{1,i,k} = imread(sprintf('%s%.3f%s%s%s%s%s','./BallHallway_',...
            options.sizeArray(i),'_fixOnly_hallway_7degAlpha_close_Texture_',whichFix,'.png'));
        
        % Load no hallway fix only textures
        options.circTextureArray_fixOnly{2,i,k} = imread(sprintf('%s%.3f%s%s%s%s%s','./BallHallway_',...
            options.sizeArray(i),'_fixOnly_noHallway_7degAlpha_close_Texture_',whichFix,'.png'));
        
        % Correct the color values in the textures for monitor being used
        options.circTextureArray_fixOnly{1,i,k} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i,k}+1).*255);
        options.circTextureArray_fixOnly{2,i,k} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i,k}+1).*255);
        
        % Pre-make all neccessary textures for faster drawing
        options.circTextures_fixOnly{1,i,k} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i,k});
        options.circTextures_fixOnly{2,i,k} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i,k});
    end
end
cd ../../../../../EEG_Task/Stim/

% Texture coords
options.textureCoords = [options.xc-(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc-(size(options.circTextureArray{1,i,j,k,p},2)/2),...
    options.xc+(size(options.circTextureArray{1,i,j,k,p},1)/2),options.yc+(size(options.circTextureArray{1,i,j,k,p},2)/2)];

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
                    [options,data] = IllusorySizeExp_EEGPrac(options,data);
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
        if options.photodiodeTesting == 1
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
                text1='Please take a break. Feel free to blink or move your eyes.';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.fixCol);
                text2='Please do not make any unnecessary movements.';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.fixCol);
                text3='You''re doing great!';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.fixCol);
                text4='Let the experimenter know when you are ready to continue...';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.fixCol);
                Screen('Flip',options.windowNum);
                WaitSecs(1);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        break;
                    end
                end
            end
        end
        
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
    
        data.rawdata(n,1) = n;   % Trial order
        data.rawdata(n,2) = options.trialOrder(n);   % Trial number
        farCloseIdx = options.varList(options.trialOrder(n),2);   % 1=Far, 2=Close
        data.rawdata(n,3) = farCloseIdx;
        hallwayIdx = options.varList(options.trialOrder(n),3);   % 1=Hallway, 2=no hallway
        data.rawdata(n,4) = hallwayIdx;
        phaseIdx = options.varList(options.trialOrder(n),4);   % phase 1 and 2
        data.rawdata(n,5) = phaseIdx;
        fixChangeIdx = options.varList(options.trialOrder(n),5);   % 1=no fix change, 2=fix change
        data.rawdata(n,6) = fixChangeIdx;
        
        % SET PRIO WHILE PRESENTING STIM
        if options.eegRecording == 1
            priorityLevel=MaxPriority(options.windowNum);
            Priority(priorityLevel);
        end
        
        % Start with initial red fixation before starting experiment
        if n==1
            Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2},[],options.textureCoords);
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
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1},[],options.textureCoords);
        switch hallwayIdx
            case 1
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
            case 2
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
        end
        options.time.syncTime(n) = Screen('Flip',options.windowNum);
        
        % Start with hallway no stim - 800-1200ms w/ cyan fix
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1},[],options.textureCoords);
        switch hallwayIdx
            case 1
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
            case 2
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
        end
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
        
        if options.photodiodeTesting == 1
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-40 (options.yc*2)-40 (options.xc*2) (options.yc*2)]);
        end

        % Present target - 200ms w/ cyan fix
        % Present fix change trial if necessary
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,fixChangeIdx},[],options.textureCoords);
        [~, options.time.stimOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.blankOnsetTime(n)+options.time.prestimulusInterval(n))-options.flip_interval_correction);
        
        % Send stim strigger 
        if options.eegRecording == 1
            switch fixChangeIdx
                case 1   % No fix change
                    switch farCloseIdx
                        case 1   % Far
                            switch hallwayIdx
                                case 1   % Hallway
                                    options.default(n) = 111;   % Far hallway no chanage
                                case 2   % No hallway
                                    options.default(n) = 112;   % Far no hallway no chanage
                            end
                        case 2   % Close
                            switch hallwayIdx
                                case 1   % Hallway
                                    options.default(n) = 121;   % Close hallway no chanage
                                case 2   % No hallway
                                    options.default(n) = 122;   % Close no hallway no chanage
                            end
                    end
                case 2      % Fix change
                    switch farCloseIdx
                        case 1   % Far
                            switch hallwayIdx
                                case 1   % Hallway
                                    options.default(n) = 211;   % Far hallway chanage
                                case 2   % No hallway
                                    options.default(n) = 212;   % Far no hallway chanage
                            end
                        case 2   % Close
                            switch hallwayIdx
                                case 1   % Hallway
                                    options.default(n) = 221;   % Close hallway chanage
                                case 2   % No hallway
                                    options.default(n) = 222;   % Close no hallway chanage
                            end
                    end                    
            end
               
            outp(options.address,options.default(n));   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);   % Clear the port
        end
        
        % Monitor for responses
        KbQueueStart(options.dev_id_mouse);
        
        % Present poststim hallway only - 400ms w/ cyan fix
        Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,1},[],options.textureCoords);
        switch hallwayIdx
            case 1
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
            case 2
                Screen ('FillOval',options.windowNum,options.grayCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,options.singleCirc.circCoordTex(farCloseIdx,:)+[-2 -2 2 2]+...
                    [options.textureCoords(1) options.textureCoords(2) options.textureCoords(1) options.textureCoords(2)]);
        end
        [~, options.time.stimOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.stimOnsetTime(n)+options.time.stimPresInterval)-options.flip_interval_correction);
        
        % Present ITI no hallway - 650-850 w/ red fix
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2},[],options.textureCoords);
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
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2},[],options.textureCoords);
        [~, options.time.ITIOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.ITIOnsetTime(n)+options.time.blankInterval(n))-options.flip_interval_correction);
        
        % Check for response
        [options.response.pressed{n} options.response.firstPress{n} ...
            options.response.firstRelease{n} options.response.lastPress{n} options.response.lastRelease{n}] = KbQueueCheck(options.dev_id_mouse);
        
        % Determine if a response was made correctly (was it a fix change trial?)
        if fixChangeIdx == 1   % No fixation change
            if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                data.rawdata(n,7) = 0;
            else
                data.rawdata(n,7) = 1;
            end
        elseif fixChangeIdx == 2   % Fix change
            if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                data.rawdata(n,7) = 1;
            else
                data.rawdata(n,7) = 0;
            end
        end
        
        % Determine time response made relative to start of trial (response time)
        if options.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
            options.response.respTimeFirst(n) = options.response.firstPress{n}(options.buttons.buttonLeftMouse) - options.time.stimOnsetTime(n);
            data.rawdata(n,8) = options.response.respTimeFirst(n);
        else
            options.response.respTimeFirst(n) = NaN;
            data.rawdata(n,8) = NaN;
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

% % Make the rawdata variable into a table so it's easier for others to read
% for i=1:size(data.rawdata,2)
%     t(:,i)=table(data.rawdata(:,i));
% end
% 
% t.Properties.VariableNames = {'PresOrder','TrialNumber','Illusory_Fragmented',...
%     'Fat_Thin','StimPresTime','StimPresLength','Response','RespScreenOnset_to_Resp','ExpStartOnset_to_Resp','StimOnset_to_Resp',...
%     'Accuracy','StepLevel'};
% 
% % Save the text file for use w/ other programs not Matlab
% writetable(t,sprintf('%s%s%s',options.datadir,options.datafile,'.txt'));
% 
% data.rawdataT = t;

% End exp screen
text1 = 'Experiment finished...';
text2 = 'Please tell experimenter.';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',options.yc-250);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',options.yc-200);
Screen('Flip',options.windowNum);
KbWait;

%% Finish experiment
cleanUp(options,data);

end




