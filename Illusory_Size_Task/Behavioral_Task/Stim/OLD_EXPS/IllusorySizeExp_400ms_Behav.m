% Illusory size behavioral experiment (based on Murray et al, 2006).
% Participants are presented with 2 white balls (each with depth cues, i.e.
% shadows and shading) in a brick hallway (context), the top presented
% further along the hallway (larger with context) the bottom presented
% closer in the hallway (smaller). The part is asked to adjust the bottom
% to match the size of the top.

function [] = IllusorySizeExp_Behav(optionsString,subjid,runid)

clearvars -except optionsString subjid runid; close all; sca;

switch nargin
    case 1
        subjid = [];
        runid = [];
    case 2
        runid = [];
end

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
cd(fullfile(options.root_path,'Illusory_Size_Task\Behavioral_Task\Stim'));
% end mps 20190730

[optionsString,subjid,runid] = userInputDialogBox(optionsString);
subjid = [subjid '_400ms'];

% Setup options struct
options.compSetup = optionsString;
options.expName = 'Illusory_Size_Task';
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
%         options.screenNum = max(Screen('Screens')); % mps 20200328
%     load('Asus_VG248QE_vaCoglab_lightsoff_20190904.mat','displayInfo');
%     options.displayInfo = displayInfo;
end
options = localOptions(options);
options.displayFigs = 1;
options.practice.doPractice = 1;
options.practice.practiceBreak = 0;
options.analysisCheck = 0;
options.screenShot = 0;


%% Trial variables
% List variables to determine trial sequence
options.backgroundList = [1 2];   % 1=background 2=no background
options.backgroundNum = length(options.backgroundList);
options.stairList = [1 2 3];   % 3 staircases for each condition
options.stairNum = length(options.stairList);
options.catchNum = 10;   % Num catch trials per condition (10 each largest/smallest background/no background)

options.repetitions = 30;   % Number of trials in the staircase
options.practice.practiceRepetitions = 10;    % Number of practice trials/step

options.blockLength = options.stairNum*options.repetitions;   % Length of a block before adding catch trials

% 1=background; 2=no background
options.blockOrder = randi(2);   % Randomize which block comes first

% Make varlist
varList1 = repmat(fullfact([options.stairNum]),[options.repetitions 1]);   % varlist for first block
varList1(length(varList1)+1:length(varList1)+options.catchNum) = 4;   % Add catch trials numCatch each per condition per block 4=larger
varList1(length(varList1)+1:length(varList1)+options.catchNum) = 5;   % Add catch trials numCatch each per condition per block 5=smaller
varList1(:,2) = options.blockOrder;   % Background
varList2 = repmat(fullfact([options.stairNum]),[options.repetitions 1]);   % varlist for second block
varList2(length(varList2)+1:length(varList2)+options.catchNum) = 4;   % Add catch trials numCatch each per condition per block 4=larger
varList2(length(varList2)+1:length(varList2)+options.catchNum) = 5;   % Add catch trials numCatch each per condition per block 5=smaller
varList2(:,2) = 3-options.blockOrder;   % Background
options.varList = [varList1; varList2];   % total varList

% Scramble each block seperately
trialList1 = randperm(length(varList1))';
trialList2 = randperm(length(varList2))'+length(trialList1);
options.trialOrder = [trialList1; trialList2];
options.numTrials = length(options.varList);

% Give participants a break in between blocks
options.break_trials = options.numTrials/2+1;   % Break half way through

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

for i = 1:options.backgroundNum   % Number of conditions
    for j = 1:options.stairNum   % Number of staircases to setup
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

% Load in premade texture arrays
for i=1:length(options.sizeArray)
    % Load hallway textures
    options.circTextureArray{1,i} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_',options.stimType,'_hallway_7degAlpha_Texture_1.png'));

    % Load no hallway textures
    options.circTextureArray{2,i} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_',options.stimType,'_noHallway_7degAlpha_Texture_1.png'));

    % Load hallway fix only textures
    options.circTextureArray_fixOnly{1,i} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_fixOnly_hallway_7degAlpha_Texture.png'));
    
    % Load no hallway fix only textures
    options.circTextureArray_fixOnly{2,i} = imread(sprintf('%s%.3f%s%s%s','./Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
        options.sizeArray(i),'_fixOnly_noHallway_7degAlpha_Texture.png'));
    
    % Correct the color values in the textures for monitor being used
    options.circTextureArray{1,i} = uint8(options.displayInfo.linearClut(options.circTextureArray{1,i}+1).*255);
    options.circTextureArray{2,i} = uint8(options.displayInfo.linearClut(options.circTextureArray{2,i}+1).*255);
    options.circTextureArray_fixOnly{1,i} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{1,i}+1).*255);
    options.circTextureArray_fixOnly{2,i} = uint8(options.displayInfo.linearClut(options.circTextureArray_fixOnly{2,i}+1).*255);
    
    % Pre-make all neccessary textures for faster drawing
    options.circTextures{1,i} = Screen('MakeTexture',options.windowNum,options.circTextureArray{1,i});
    options.circTextures{2,i} = Screen('MakeTexture',options.windowNum,options.circTextureArray{2,i});
    options.circTextures_fixOnly{1,i} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{1,i});
    options.circTextures_fixOnly{2,i} = Screen('MakeTexture',options.windowNum,options.circTextureArray_fixOnly{2,i});
end

% Texture coords
options.textureCoords = [options.xc-(size(options.circTextureArray{1,i},1)/2),options.yc-(size(options.circTextureArray{1,i},2)/2),...
    options.xc+(size(options.circTextureArray{1,i},1)/2),options.yc+(size(options.circTextureArray{1,i},2)/2)];

% Load in the fixation point coords in order to stabalize the fixation on the screen. 
optionsHolder = load('measuredSizesAndPositions_fixOnly_hallway_7degAlpha.mat');
options.fixLoc_hallway(1,:,:) = optionsHolder.options.fixationLoc;
optionsHolder = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_hallway_7degAlpha_1.mat'));
options.fixLoc_hallway(2,:,:) = optionsHolder.options.fixationLoc;

optionsHolder = load('measuredSizesAndPositions_fixOnly_noHallway_7degAlpha.mat');
options.fixLoc_noHallway(1,:,:) = optionsHolder.options.fixationLoc;
optionsHolder = load(sprintf('%s%s%s','measuredSizesAndPositions_',options.stimType,'_noHallway_7degAlpha_1.mat'));
options.fixLoc_noHallway(2,:,:) = optionsHolder.options.fixationLoc;
clear optionsHolder

% Find needed adjustment to keep fixation centered in x and y
for i=1:length(options.circTextureArray)
    options.fixLoc_hallway_Correction(1,1,:,i) = squeeze(options.fixLoc_hallway(2,i,:))' - [size(options.circTextureArray{1,i},1)/2 size(options.circTextureArray{1,i},2)/2];   % Hallway 
    options.fixLoc_hallway_Correction(1,2,:,i) = squeeze(options.fixLoc_hallway(1,i,:))' - [size(options.circTextureArray_fixOnly{1,i},1)/2 size(options.circTextureArray_fixOnly{1,i},2)/2];   % Hallway fix only
    
    options.fixLoc_hallway_Correction(2,1,:,i) = squeeze(options.fixLoc_hallway(2,i,:))' - [size(options.circTextureArray{1,i},1)/2 size(options.circTextureArray{1,i},2)/2];   % No hallway 
    options.fixLoc_hallway_Correction(2,2,:,i) = squeeze(options.fixLoc_hallway(1,i,:))' - [size(options.circTextureArray_fixOnly{1,i},1)/2 size(options.circTextureArray_fixOnly{1,i},2)/2];   % No hallway fix only

    % Add to texture coords
    options.textureCoords_Corrected(1,1,:,i) = [options.textureCoords(1)-options.fixLoc_hallway_Correction(1,1,1,i),...
        options.textureCoords(2)-options.fixLoc_hallway_Correction(1,1,2,i),...
        options.textureCoords(3)-options.fixLoc_hallway_Correction(1,1,1,i),...
        options.textureCoords(4)-options.fixLoc_hallway_Correction(1,1,2,i)];
    options.textureCoords_Corrected(1,2,:,i) = [options.textureCoords(1)-options.fixLoc_hallway_Correction(1,2,1,i),...
        options.textureCoords(2)-options.fixLoc_hallway_Correction(1,2,2,i),...
        options.textureCoords(3)-options.fixLoc_hallway_Correction(1,2,1,i),...
        options.textureCoords(4)-options.fixLoc_hallway_Correction(1,2,2,i)];
    options.textureCoords_Corrected(2,1,:,i) = [options.textureCoords(1)-options.fixLoc_hallway_Correction(2,1,1,i),...
        options.textureCoords(2)-options.fixLoc_hallway_Correction(2,1,2,i),...
        options.textureCoords(3)-options.fixLoc_hallway_Correction(2,1,1,i),...
        options.textureCoords(4)-options.fixLoc_hallway_Correction(2,1,2,i)];
    options.textureCoords_Corrected(2,2,:,i) = [options.textureCoords(1)-options.fixLoc_hallway_Correction(2,2,1,i),...
        options.textureCoords(2)-options.fixLoc_hallway_Correction(2,2,2,i),...
        options.textureCoords(3)-options.fixLoc_hallway_Correction(2,2,1,i),...
        options.textureCoords(4)-options.fixLoc_hallway_Correction(2,2,2,i)];    
end

%% Timing variables
% Total time spheres are on screen
options.stimPresTime = .4;

% Total time part has to response
options.responseTime = 1;

% Time of the blank screen before stim pres
options.blankOnsetTime = .5;

%% Practice
% Check to see if we need to run practice trials
if options.practice.doPractice == 1
    % Run practice
    [options,data] = IllSizeExp_Prac(options,data);
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
        stairIdx = options.varList(options.trialOrder(n),1);   % Determine what staircase you are on for this trial
        data.rawdata(n,4) = stairIdx;
        
        if stairIdx == 4   % Catch trial larger
            data.currSize(n) = options.sizeArray(end);
        elseif stairIdx==5   % Catch trial smaller
            data.currSize(n) = options.sizeArray(1);
        elseif stairIdx == 1 || stairIdx == 2 || stairIdx == 3   % Normal staircase
            data.currSize(n) = data.stair(backgroundIdx,stairIdx).xCurrent;
        end
        
        data.currSizeIdx(n) = find(options.sizeArray==data.currSize(n));
        data.rawdata(n,5) = data.currSize(n);
        
        if options.screenShot == 1
            data.currSizeIdx(n) = 15;
            backgroundIdx = 1;
        end
        
        %% Draw stim
        % Start trial presentation
        sync_time = Screen('Flip',options.windowNum);
        
        % Blank screen (fixation)
        Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{backgroundIdx,data.currSizeIdx(n)},[],squeeze(options.textureCoords_Corrected(backgroundIdx,2,:,data.currSizeIdx(n))));
%         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,2,:,data.currSizeIdx(n))));
        
        [~, blankOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time)-options.flip_interval_correction);
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s%d%s','illSizeBlank_',data.currSizeIdx(n),'_',backgroundIdx,'.png'));
        end
                
        %         % Fixation
        %         Screen('FillOval',options.windowNum,options.whiteCol,[options.xc-3 options.yc-3 options.xc+3 options.yc+3])
        %
        %         % Draw top circle (always constant size)
        %         Screen('DrawTexture',options.windowNum,options.circTextures(ceil(length(data.xL)/2)),[],squeeze(options.circCoords(1,ceil(length(data.xL)/2),:)));
        %
        %         % Draw bottom circle (different sizes)
        %         Screen('DrawTexture',options.windowNum,options.circTextures(find(data.xL==data.currSize(n))),[],squeeze(options.circCoords(2,find(data.xL==data.currSize(n)),:)));
        %
        % Draw sizes on screen so you know you are displaying the right thing
        %         text1 = sprintf('%d',data.xL(ceil(length(data.xL)/2)));
        %         text2 = sprintf('%d',data.xL(find(data.xL==data.currSize(n))));
        %         textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        %         DrawFormattedText(options.windowNum,text1,'center',...
        %             squeeze(options.circCoords(1,ceil(length(data.xL)/2),2))-(textHeight/2)-20,[0 0 0]);
        %         textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        %         DrawFormattedText(options.windowNum,text2,'center',...
        %             squeeze(options.circCoords(2,find(data.xL==data.currSize(n)),2))-(textHeight/2)-20,[0 0 0]);
        
        % Draw texture
        Screen('DrawTexture',options.windowNum,options.circTextures{backgroundIdx,data.currSizeIdx(n)},[],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
%         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
        
        [~, stimOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time+options.blankOnsetTime)-options.flip_interval_correction);
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s%d%s','illSizeStim_',data.currSizeIdx(n),'_',backgroundIdx,'.png'));
        end
        
        % Wait for response
        text1='Was the top-right (RIGHT MOUSE) or bottom-left (LEFT MOUSE) sphere bigger?';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
        
        [~, responseOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (stimOnsetTime+options.stimPresTime)-options.flip_interval_correction);
        
        if options.screenShot == 1
            % GetImage call. Alter the rect argument to change the location of the screen shot
            imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
            imwrite(imageArray,sprintf('%s%d%s','illSizeResp_',data.currSizeIdx(n),'.png'));
        end
        
        % Record response
        [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
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
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            
            switch responseBreak
                case 0   % If no response recorded
                    if buttonsHolder(3) == 1   % Top
                        data.rawdata(n,6) = 1;   % Record response
                        data.rawdata(n,7) = GetSecs-stimOnsetTime;   % RT
                        responseBreak = 1;
                    elseif buttonsHolder(1) == 1   % Bottom
                        data.rawdata(n,6) = 2;   % Record response
                        data.rawdata(n,7) = GetSecs-stimOnsetTime;   % RT
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
        if data.rawdata(n,6) == 1   % Chose top
            data.rawdata(n,8) = 0;   % Chose test (constant size)
        elseif data.rawdata(n,6) == 2   % Chose bottom
            data.rawdata(n,8) = 1;   % Chose ref (changing size)
%         elseif data.rawdata(n,6) == 0   % Didn't respond
%             data.rawdata(n,8) = 0;
        end
        
        if stairIdx == 4 || stairIdx == 5   % Catch trial - don't update staircase
        elseif stairIdx == 1 || stairIdx == 2 || stairIdx == 3    % Update the staircase
            data.stair(backgroundIdx,stairIdx) = PAL_AMPM_updatePM(data.stair(backgroundIdx,stairIdx),data.rawdata(n,8));
        end
        
        if keycode(options.buttons.buttonEscape) || escapeSwitch == 1
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
    t.Properties.VariableNames = {'PresOrder','TrialNumber','Background','StairNum',...
        'CurrSize','Response','ReactionTIme','Stair_Update'};
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,sprintf('%s%s%s',options.datadir,options.datafile,'.txt'));
    
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
        cond_label{1} = 'Background';
        cond_label{2} = 'NoBackground';
        
        for i=1:options.backgroundNum   % Num conditions (background/no background)
            
            if options.displayFigs == 1; figure; end % mps 20190730
            for j=1:size(data.stair,2)   % Num staircases - 2 for each condition
                
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
            
            % Plot the two psychometric fits on the same plot
            subplot(1,4,1); hold on;
            x_val = .5:.025:1.5;
            plot([x_val(1) x_val(end)],[data.thresh.thresh_pct data.thresh.thresh_pct],'k-');
            % Shape
            x_val = .5:.025:1.5;
            shapePlot = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(1).paramsFit(:)),x_val),['r' plot_lines{1}],...
                'linewidth',2);
            plot([data.thresh.ave(1).thresh_refit data.thresh.ave(1).thresh_refit],[0 1],...
                ['r' plot_lines{2}],'linewidth',2);
            axis([.5 1.5 -0.05 1.05])
            box off
            title('Background-No Background');
            set(gca,'fontsize',12)
            % No shape
            x_val = .5:.025:1.5;
            noShapePlot = plot(x_val,data.thresh.PF(squeeze(data.thresh.ave(2).paramsFit(:)),x_val),['b' plot_lines{1}],...
                'linewidth',2);
            plot([data.thresh.ave(2).thresh_refit data.thresh.ave(2).thresh_refit],[0 1],...
                ['b' plot_lines{2}],'linewidth',2);
            axis([.5 1.5 -0.05 1.05])
            box off
            title('Background-No Background');
            set(gca,'fontsize',12)
            legend([shapePlot,noShapePlot],{'Background' 'No Background'},'location','northwest');
            
            % Plot the combined thresh in bargraph for shape/noshape
            subplot(1,4,2); hold on;
            combinedBar(1) = bar(1,[data.thresh.ave(1).thresh_refit]);
            combinedBar(1).FaceColor = [1 0 0];
            combinedBar(2) = bar(2,[data.thresh.ave(2).thresh_refit]);
            combinedBar(2).FaceColor = [0 0 1];
%             combinedBar.CData(1,:) = [1 0 0];
%             combinedBar.CData(2,:) = [0 0 1];
            hold on
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2]);
            set(gca,'XTickLabel',{'Background' 'No Background'})
            set(gca,'XTickLabelRotation',45);
%             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Combined Background-No Background PSE')
            
            % Plot the mean/std across the 4 staircases
            data.thresh.thresh_refit_mean(1) = nanmean(data.thresh.thresh_refit(1,:));
            data.thresh.thresh_refit_mean(2) = nanmean(data.thresh.thresh_refit(2,:));
            data.thresh.thresh_refit_ste(1) = ste(data.thresh.thresh_refit(1,:));
            data.thresh.thresh_refit_ste(2) = ste(data.thresh.thresh_refit(2,:));
            
            subplot(1,4,3); hold on;
            meanBar(1) = bar(1,[data.thresh.thresh_refit_mean(1)]);
            meanBar(1).FaceColor = [1 0 0];
            meanBar(2) = bar(2,[data.thresh.thresh_refit_mean(2)]);
            meanBar(2).FaceColor = [0 0 1];
            errorbar([data.thresh.thresh_refit_mean(1) data.thresh.thresh_refit_mean(2)],...
                [data.thresh.thresh_refit_ste(1) data.thresh.thresh_refit_ste(2)],'.k');
%             meanBar.FaceColor = 'flat';
%             meanBar.CData(1,:) = [1 0 0];
%             meanBar.CData(2,:) = [0 0 1];
            hold on
            plot(get(gca,'xlim'),[data.xL(round(length(data.xL)/2)) data.xL(round(length(data.xL)/2))],'k-')
            ylim([.5 1.5])
            set(gca,'YTick',[.5:.25:1.5]);
            set(gca,'XTick',[1 2]);
            set(gca,'XTickLabel',{'Background' 'No Background'})
            set(gca,'XTickLabelRotation',45);
%             xtickangle(45)
            set(gca,'fontsize',12)
            set(gcf,'color','w')
            box off
            title('Mean Background-No Background PSE')
            
            % Calculate and plot catch trial accuracy
            data.largerCatchBack = (sum(data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),8))/...
                length(data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),8)))*100;   % Larger catch hallway
            data.largerCatchNoBack = (sum(data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==2),8))/...
                length(data.rawdata((data.rawdata(:,4)==4 & data.rawdata(:,3)==1),8)))*100;   % Larger catch no hallway
            data.smallerCatchBack = (sum(~data.rawdata((data.rawdata(:,4)==5 & data.rawdata(:,3)==1),8))/...
                length(~data.rawdata((data.rawdata(:,4)==5 & data.rawdata(:,3)==1),8)))*100;   % Smaller catch hallway
            data.smallerCatchNoBack = (sum(~data.rawdata((data.rawdata(:,4)==5 & data.rawdata(:,3)==2),8))/...
                length(~data.rawdata((data.rawdata(:,4)==5 & data.rawdata(:,3)==2),8)))*100;   % Smaller catch no hallway 
            
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





