% Experiment for the illusory contour task for the SYON grant.

function [] = IllContExp_EEG()

clear all; close all; sca;
% switch nargin
%     case 1
%         subjid = [];
%         runid = [];
%     case 2
%         runid = [];
% end

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
cd(fullfile(options.root_path,'Illusory_Contour_Task\EEG_Task\Stim'));

options.practice.practiceBreak = 0;
options.practice.practiceCheck = 1;   % Variable that tells exp to present the practice trials at start of block
options.practice.doPractice = 1;
options.displayFigs =0;
options.eegRecording = 1;
options.analysisCheck = 0;
options.photodiodeTesting = 0;
options.signalPhotodiode = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);

options.compSetup = optionsString;
options.expName = 'Illusory_Contour_Task';
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

% Initialize the triggers
if options.eegRecording == 1
    config_io;
end

%% Trial Varialbes
% List variables to determine trial sequence
options.illFragList = [1 2];   % 1=illusory 2=fragmented
options.illFragNum = length(options.illFragList);
options.leftRightList = [1 2 3 4 5 6 7 8];   % For illusory: Even=thin; odd=fat. Frag: 1=ULF, 2=URF, 3=LLF, 4=LRF, 5=ULT, 6=URT, 7=LLT, 8=LRT
options.leftRightNum = length(options.leftRightList);

options.repetitions = 100;   % Number of trials/condition
options.practice.practiceRepetitions = 4;    % Number of practice trials/step
options.repMaskOnly = 50;   % Number of mask only trials

varList1 = repmat(fullfact([1 options.illFragNum]),[options.repetitions 1]);   % varlist for first half of exp (illusory or fragmented)
varList2 = repmat(fullfact([1 options.leftRightNum]),[options.repetitions*2/options.leftRightNum 1]);   % varlist for first half of exp (illusory or fragmented)
varList2(:,1) = 2;
options.varList = [varList1; varList2; ones(options.repMaskOnly,1)+2 ones(options.repMaskOnly,1)];   % Combine the two lists
options.numTrials = length(options.varList);

% Determine the tilt angle jitter on each trial (between -.5,-.25,0,.25,.5)
options.stim.thresholdJitterList = [-.5 -.25 0 .25 .5];
% Fat
options.varList(options.varList(:,1)==1 & options.varList(:,2)==1,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions/length(options.stim.thresholdJitterList),1]);
% Thin
options.varList(options.varList(:,1)==1 & options.varList(:,2)==2,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==1,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==2,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==3,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==4,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==5,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==6,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==7,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% Fragmented 1
options.varList(options.varList(:,1)==2 & options.varList(:,2)==8,3) =...
    repmat((1:length(options.stim.thresholdJitterList))',[options.repetitions*2/options.leftRightNum/length(options.stim.thresholdJitterList),1]);
% No mask
options.varList(options.varList(:,1)==3,3) = randi(length(options.stim.thresholdJitterList),[options.repMaskOnly 1]);

% Randomized trial order
options.trialOrder = randperm(length(options.varList))';

% Give participants a break in between blocks
options.break_trials = round(options.numTrials/4+1:options.numTrials/4:options.numTrials);   % Breaks half way through each block
blockCount = 0;   % Count the current block
blockCountArray = [1 options.break_trials options.numTrials];

% Set up the trial sequence for the practice trials
options.practice.practiceAngleList = [10 8 6 4 2];
options.practice.practiceAngleNum = length(options.practice.practiceAngleList);
options.practice.practiceStimTimeList = [3.2 1.6 .8 .4 .2];
options.practice.practiceStimTimeNum = length(options.practice.practiceStimTimeList);
% 1=Fragmented or illusory 2= Fat/thin counter/clockwise
options.practice.varListPractice(:,1:2) = repmat(fullfact([2 2]),[options.practice.practiceRepetitions*options.practice.practiceAngleNum/4 1]);
options.practice.varListPractice(:,3) = zeros([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1]);
options.practice.varListPractice(:,4) = zeros([options.practice.practiceAngleNum*options.practice.practiceRepetitions,1]);
counter = 1;
for j=1:options.practice.practiceAngleNum
    for i=1:options.practice.practiceRepetitions
        options.practice.varListPractice(counter,3) = j;
        options.practice.varListPractice(counter,4) = j;
        
        counter = counter+1;
    end
end

% Randomize the first two rows of varListPractice
pracRandList = 1:options.practice.practiceRepetitions:length(options.practice.varListPractice);
counter = 0;
for i=pracRandList
    counter = counter+1;
    pracRandIdx(counter,:) = i:i+(options.practice.practiceAngleNum-2);
    pracRandIdx2(counter,:) = randperm(length(pracRandIdx(counter,:)))+(i-1);
    options.practice.varListPractice(pracRandIdx(counter,:),1:2) = [options.practice.varListPractice(pracRandIdx2(counter,:),1)...
        options.practice.varListPractice(pracRandIdx2(counter,:),2)];
end

% Variable to track values on each trial
data.rawdata = zeros([length(options.varList),12]); 
data.practice.rawdataPractice = zeros([length(options.practice.varListPractice),11]);

% Load in the threshold file
if exist(fullfile('../../IllContThresh.mat'),'file')
    load('../../IllContThresh','IllContThresh');
else
   % Send error is no threshold file exists
   error('No threshold file found. Make sure you are in the /Stim directory.');
end

% Check to see if the current participant exists in the file
if any(strcmp(options.subjID, {IllContThresh(:).subjID}))
    % Overall tilt
    options.stim.threshold = IllContThresh(strcmp(options.subjID, {IllContThresh(:).subjID})).thresh;
else
    % Send error if participant doesn't have a 
    error(['No threshold value for ',options.subjID,'. Make sure subject id matches that in the threshold file.']);
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
options.stim.circDia = 1.5;   % Diameter of the circle
options.stim.circDist = 4.5;   % Distance between the center points of each circle

% Illusory angle variables - the initial angle each of the texture is rotated
options.stim.texAngleIllusory(1) = 0;   % Upper left
options.stim.texAngleIllusory(2) = 0;   % Upper right
options.stim.texAngleIllusory(3) = 270;   % Lower left
options.stim.texAngleIllusory(4) = 90;   % Lower right
% Fragmented angle variables - the initial angle each of the texture is rotated
% All upper left (from illusory cond)
options.stim.texAngleFragmented(1,1) = options.stim.texAngleIllusory(1);   % Upper left
options.stim.texAngleFragmented(1,2) = options.stim.texAngleIllusory(1);   % Upper right
options.stim.texAngleFragmented(1,3) = options.stim.texAngleIllusory(1);   % Lower left
options.stim.texAngleFragmented(1,4) = options.stim.texAngleIllusory(1);   % Lower right
% All upper right (from illusory cond)
options.stim.texAngleFragmented(2,1) = options.stim.texAngleIllusory(2);   % Upper left
options.stim.texAngleFragmented(2,2) = options.stim.texAngleIllusory(2);   % Upper right
options.stim.texAngleFragmented(2,3) = options.stim.texAngleIllusory(2);   % Lower left
options.stim.texAngleFragmented(2,4) = options.stim.texAngleIllusory(2);   % Lower right
% All lower left (from illusory cond)
options.stim.texAngleFragmented(3,1) = options.stim.texAngleIllusory(3);   % Upper left
options.stim.texAngleFragmented(3,2) = options.stim.texAngleIllusory(3);   % Upper right
options.stim.texAngleFragmented(3,3) = options.stim.texAngleIllusory(3);   % Lower left
options.stim.texAngleFragmented(3,4) = options.stim.texAngleIllusory(3);   % Lower right
% All upper left (from illusory cond)
options.stim.texAngleFragmented(4,1) = options.stim.texAngleIllusory(4);   % Upper left
options.stim.texAngleFragmented(4,2) = options.stim.texAngleIllusory(4);   % Upper right
options.stim.texAngleFragmented(4,3) = options.stim.texAngleIllusory(4);   % Lower left
options.stim.texAngleFragmented(4,4) = options.stim.texAngleIllusory(4);   % Lower right

% Make a switch variable array that deteremines what texture you will use.
% Since we are not using both textures, we have to assigne which textures
% go w/ which angle.
options.stim.texChoseIdxIll(:) = [1 2 1 2];
options.stim.texChoseIdxFrag(1,:) = [1 1 1 1];
options.stim.texChoseIdxFrag(2,:) = [2 2 2 2];
options.stim.texChoseIdxFrag(3,:) = [1 1 1 1];
options.stim.texChoseIdxFrag(4,:) = [2 2 2 2];

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

% Make a texture for the mask only trials
maskTexArray(:,:,1) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(1);
maskTexArray(:,:,2) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(2);
maskTexArray(:,:,3) = zeros(ceil(options.stim.circDia*options.PPD)) + options.grayCol(3);
options.stim.maskOnlyTex = Screen('MakeTexture',options.windowNum,maskTexArray);

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

% The sign of the rotation is always relative to the first inducer.
% Values to multiple options.stim.overallTilt by to get the correct rotation angle for each of the 4 inducers
options.stim.texAngleTilt(1,:) = [1 -1 -1 1];
options.stim.texAngleTilt(2,:) = [1 1 1 1];

% Amount of tilt we apply to all textures relative to starting position
options.stim.overallTilt = 0;   

% Timing variables in seconds
blankTimes = linspace(.800,1.200,25);
options.stim.blankInterval = blankTimes(randi(length(blankTimes),[options.numTrials,1]));   % RANDOMIZE BETWEEN 800-1200 MS   linspace(800,1200,25)
options.stim.blankIntervalPrac = 1.000;
options.stim.stimPresInterval = .2;
options.stim.isiInterval = .05;
options.stim.maskInterval = .3;
options.stim.respInterval = 1.5;

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
            cd ../../
            if n==1
                if options.photodiodeTesting == 0
                    [options,data] = IllContExp_EEGPrac(options,data);
                end
            end
            cd ./EEG_Task/Stim/
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
        for b = round(options.break_trials)
            if n == b
                this_b = b;
                break
            end
        end
        if this_b
            % Calculate accuracy for this block
            blockCount = blockCount + 1;
            data.blockAcc(blockCount) = nanmean(data.rawdata(blockCountArray(blockCount):blockCountArray(blockCount+1),11))*100;
            data.blockRT(blockCount) = nanmean(data.rawdata(blockCountArray(blockCount):blockCountArray(blockCount+1),10));
            
            text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(blockCount),'% of trials correctly.');
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
            text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(blockCount),'s to respond on average. Good job!');
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2),options.fixCol);
            
            % display break message
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
        
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
    
        data.rawdata(n,1) = n;   % Trial order
        data.rawdata(n,2) = options.trialOrder(n);   % Trial number
        illFragIdx = options.varList(options.trialOrder(n),1);   % Illusory or framented condition
        data.rawdata(n,3) = illFragIdx;
        fatThinIdx = options.varList(options.trialOrder(n),2);   % presenting fat/thin or right/left for this trial
        data.rawdata(n,4) = fatThinIdx;
                
        % Choose the starting rotation angle of the textures.
        switch illFragIdx
            case 1
                texAngle = options.stim.texAngleIllusory;
            case 2
                if fatThinIdx == 1 || fatThinIdx == 5
                    texAngle = options.stim.texAngleFragmented(1,:);
                elseif fatThinIdx == 2 || fatThinIdx == 6
                    texAngle = options.stim.texAngleFragmented(2,:);
                elseif fatThinIdx == 3 || fatThinIdx == 7
                    texAngle = options.stim.texAngleFragmented(3,:);
                elseif fatThinIdx == 4 || fatThinIdx == 8
                    texAngle = options.stim.texAngleFragmented(4,:);
                end
            case 3
                texAngle = options.stim.texAngleIllusory;   % Doesn't really matter what this is set to as the pacmen won't be presented
        end
    
        % Choose whether you are looking for fat/right or thin/left
        switch illFragIdx
            case 1
                options.stim.overallTilt = options.stim.threshold(illFragIdx);
                switch fatThinIdx   % Chenged by KWK 20190910
                    case 1   % Fat 
                    case 2   % Thin 
                        options.stim.overallTilt = options.stim.overallTilt*(-1);
                end
            case 2
                options.stim.overallTilt = options.stim.threshold(illFragIdx);
                if fatThinIdx <=4
                else
                    options.stim.overallTilt = options.stim.overallTilt*(-1);
                end
            case 3
                options.stim.overallTilt = options.stim.threshold(1);
                options.stim.overallTilt = options.stim.overallTilt*(-1);
        end
        
        % Chose what textures to draw
        switch illFragIdx
            case 1
                texChoseIdx = options.stim.texChoseIdxIll;
            case 2
                if fatThinIdx == 1 || fatThinIdx == 5
                    texChoseIdx = options.stim.texChoseIdxFrag(1,:);
                elseif fatThinIdx == 2 || fatThinIdx == 6
                    texChoseIdx = options.stim.texChoseIdxFrag(2,:);
                elseif fatThinIdx == 3 || fatThinIdx == 7
                    texChoseIdx = options.stim.texChoseIdxFrag(3,:);
                elseif fatThinIdx == 4 || fatThinIdx == 8
                    texChoseIdx = options.stim.texChoseIdxFrag(4,:);
                end
            case 3
                texChoseIdx = options.stim.texChoseIdxIll;   % Doesn't really matter what this is set to as the pacmen won't be presented
        end
        
        % SET PRIO WHILE PRESENTING STIM
        if options.eegRecording == 1
            priorityLevel=MaxPriority(options.windowNum);
            Priority(priorityLevel);
        end
        
        % Start trial presentation
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        sync_time = Screen('Flip',options.windowNum);
        
        % Start with blank screen
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, blankOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (sync_time) - options.flip_interval_correction);
        
        % Draw stim
        if illFragIdx ~= 3
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(texChoseIdx(1)) options.stim.inducerTex(texChoseIdx(2))...
                options.stim.inducerTex(texChoseIdx(3)) options.stim.inducerTex(texChoseIdx(4))],[],...
                options.stim.circPositionArray',texAngle+(options.stim.overallTilt.*options.stim.texAngleTilt(illFragIdx,:))+options.varList(n,3));
        elseif illFragIdx == 3
            Screen('DrawTextures',options.windowNum,[options.stim.maskOnlyTex options.stim.maskOnlyTex options.stim.maskOnlyTex options.stim.maskOnlyTex],[],...
            options.stim.circPositionArray');
        end
        
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        
        % If photodiode testing, show white square in bottom right of
        % screen.
        if options.photodiodeTesting == 1 || options.signalPhotodiode == 1
%             Screen('FillRect',options.windowNum,options.whiteCol,[(options.xc*2)-40 (options.yc*2)-40 (options.xc*2) (options.yc*2)]);
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
        end
        
        
        [~, stimOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (blankOnsetTime+options.stim.blankInterval(n))-options.flip_interval_correction);
        
        % Send stim strigger  %%% UPDATED BY KWK 20190827 - Check at VA!
        if options.eegRecording == 1
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
            elseif illFragIdx == 3
                options.default(n) = 14;
            end
            outp(options.address,options.default(n));   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);   % Clear the port
        end
        
        % ISI
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, isiOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.stimPresInterval+stimOnsetTime)-options.flip_interval_correction);
        
        % Mask
        Screen('DrawTextures',options.windowNum,[options.stim.maskTex options.stim.maskTex options.stim.maskTex options.stim.maskTex],[],...
            options.stim.circPositionArray');
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        
        % If photodiode testing, show white square in bottom right of
        % screen.
        if options.photodiodeTesting == 1  || options.signalPhotodiode == 1
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
        end
        
        [~, maskOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.isiInterval+isiOnsetTime)-options.flip_interval_correction);
        
        % Mask Trigger
        if options.eegRecording == 1
            default = 12;
            outp(options.address,default);   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.address,default);
        end
        
        % Mask offset
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        [~, maskOffsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.stim.maskInterval+maskOnsetTime)-options.flip_interval_correction);
               
        % SET PRIO TO NORMAL
        if options.eegRecording == 1
            Priority(0);
        end
        
        % Response
        responseBreak = 0;
        % Response screen
        feedBackText = 'Fat, No Square, or Thin?';
        
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
        DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-100);
        Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
        [~, respOnset, ~, ~, ~] = Screen('Flip',options.windowNum);
        
%         KbQueueFlush(options.dev_id);   % Clear KB queue to check for responses
        while 1
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            % While the total time is less than time elapsed keep looping
            time_now = GetSecs;
            response_check = (time_now - respOnset) > options.stim.respInterval;
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            % Use this for mouse clicks
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            switch response_check
                case 0
                    switch responseBreak
                        case 0
%                             % For keyboard input
%                             if any(firstPress(options.buttons.buttonLeft))   % fat
%                                 data.rawdata(n,7) = 1;   % Record response
%                                 data.rawdata(n,8) = firstPress(options.buttons.buttonLeft)-respOnset;   % Response time
%                                 responseBreak = 1;
%                             end
%                             if any(firstPress(options.buttons.buttonRight))   % thin
%                                 data.rawdata(n,7) = 2;   % Record response
%                                 data.rawdata(n,8) = firstPress(options.buttons.buttonRight)-respOnset;   % Response time
%                                 responseBreak = 1;
%                             end
%                             if any(firstPress(options.buttons.buttonUp))   % No square
%                                 data.rawdata(n,7) = 3;   % Record response
%                                 data.rawdata(n,8) = firstPress(options.buttons.buttonUp)-respOnset;   % Response time
%                                 responseBreak = 1;
%                             end
                            % For mouse input
                            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                            if buttonsHolder(1)==1   % fat - left key
                                data.rawdata(n,7) = 1;   % Record response
                                data.rawdata(n,8) = GetSecs-respOnset;   % Time from response screen onset to response
                                data.rawdata(n,9) = GetSecs-sync_time;   % Time from exp start to response
                                data.rawdata(n,10) = GetSecs - stimOnsetTime;   % Time from stim onset to response
                                responseBreak = 1;
                                
                                if options.eegRecording == 1
                                    default = 13;
                                    outp(options.address,default);   % Send trigger
                                    WaitSecs(0.005);
                                    default = 0;
                                    outp(options.address,default);
                                end
                            elseif buttonsHolder(3)==1   % thin - right key
                                data.rawdata(n,7) = 2;   % Record response
                                data.rawdata(n,8) = GetSecs-respOnset;   % Time from response screen onset to response
                                data.rawdata(n,9) = GetSecs-sync_time;   % Time from exp start to response
                                data.rawdata(n,10) = GetSecs - stimOnsetTime;   % Time from stim onset to response
                                responseBreak = 1;
                                
                                if options.eegRecording == 1
                                    default = 13;
                                    outp(options.address,default);   % Send trigger
                                    WaitSecs(0.005);
                                    default = 0;
                                    outp(options.address,default);
                                end
                            elseif buttonsHolder(2)==1   % No square - scroll wheel
                                data.rawdata(n,7) = 3;   % Record response
                                data.rawdata(n,8) = GetSecs-respOnset;   % Time from response screen onset to response
                                data.rawdata(n,9) = GetSecs-sync_time;   % Time from exp start to response
                                data.rawdata(n,10) = GetSecs - stimOnsetTime;   % Time from stim onset to response
                                responseBreak = 1;
                                
                                if options.eegRecording == 1
                                    default = 13;
                                    outp(options.address,default);   % Send trigger
                                    WaitSecs(0.005);
                                    default = 0;
                                    outp(options.address,default);
                                end
                            end
                        case 1
%                             break   % KWK make sure the response screen
%                             is on the screen for the full resp_time and
%                             not breaking early 20190905
                        otherwise
                    end
                case 1
                    break
            end
        end
        
        % If no response, make nana
        if data.rawdata(n,7)==0 && data.rawdata(n,8)==0
            data.rawdata(n,7) = NaN;   % NaN=no response
            data.rawdata(n,8) = NaN;
            data.rawdata(n,9) = NaN;
            data.rawdata(n,10) = NaN;
        end
        
        % Record timing and response
        data.rawdata(n,5) = sync_time - expStart;   % Stim pres time relative to exp start
        data.rawdata(n,6) = isiOnsetTime - stimOnsetTime;   % Stim pres length
        
        % Determine correct/incorrect for this trial 
        if data.rawdata(n,3) == 1   % Illusory condition
            if  data.rawdata(n,4) == 1   % Fat
                if data.rawdata(n,7) == 1   % Responded fat
                    % Was fat they responded fat
                    data.rawdata(n,11) = 1;
                elseif data.rawdata(n,7) == 2   % Responded thin
                    % Was fat they responded thin
                    data.rawdata(n,11) = 0;
                end
            elseif data.rawdata(n,4) == 2   % Thin
                if data.rawdata(n,7) == 1   % Responded fat
                    % Was thin they responded fat
                    data.rawdata(n,11) = 0;
                elseif data.rawdata(n,7) == 2   % Responded thin
                    % Was thin they responded thin
                    data.rawdata(n,11) = 1;
                end
            end
        elseif data.rawdata(n,3) == 2   % Fragmented condition
            % Was it not a square?
            % Did they respond not a square?
            if data.rawdata(n,7) == 3
               data.rawdata(n,11) = 1;
            else
                data.rawdata(n,11) = 0;
            end
        elseif data.rawdata(n,3) == 3
            if data.rawdata(n,7) == 3
                data.rawdata(n,11) = 1;
            else
                data.rawdata(n,11) = 0;
            end
        end
        
        % Record the value of the tilt angle
        data.rawdata(n,12) = options.stim.overallTilt;
        
        if keycode(options.buttons.buttonEscape)
            sca;
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

% Behavrioral analysis
if options.analysisCheck == 1
    cd ../Data/
    data = IllContExp_BehavAnalysis(options,data);
    cd ../Stim/
end

% Make the rawdata variable into a table so it's easier for others to read
for i=1:size(data.rawdata,2)
    t(:,i)=table(data.rawdata(:,i));
end

t.Properties.VariableNames = {'PresOrder','TrialNumber','Illusory_Fragmented',...
    'Fat_Thin','StimPresTime','StimPresLength','Response','RespScreenOnset_to_Resp','ExpStartOnset_to_Resp','StimOnset_to_Resp',...
    'Accuracy','StepLevel'};

% Save the text file for use w/ other programs not Matlab
writetable(t,fullfile(options.datadir,options.datafile));

data.rawdataT = t;

% End exp screen
% Calculate accuracy for this block
blockCount = blockCount + 1;
data.blockAcc(blockCount) = nanmean(data.rawdata(blockCountArray(blockCount):blockCountArray(blockCount+1),11))*100;
data.blockRT(blockCount) = nanmean(data.rawdata(blockCountArray(blockCount):blockCountArray(blockCount+1),10));

text5 = sprintf('%s%.1f%s','You answered ',data.blockAcc(blockCount),'% of trials correctly.');
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-50,options.fixCol);
text6 = sprintf('%s%.3f%s','It took you ',data.blockRT(blockCount),'s to respond on average. Good job!');
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

%% Finish experiment
cleanUp(options,data);


end




