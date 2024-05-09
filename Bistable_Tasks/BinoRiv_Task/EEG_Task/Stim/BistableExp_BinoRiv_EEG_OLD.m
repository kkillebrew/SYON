% Bistable biological motion task. Runs a 2 minute run of the bistable biological motion task. Participants are instructed to
% press the left or right mouse button when they see a change in motion direction.
% KWK - 20201005

function [] = BistableExp_BinoRiv_Behav()

clearvars -except optionsString subjid runid; close all; sca;

clear PsychHID; % Force new enumeration of devices.
clear KbCheck; % Clear persistent cache of keyboard devices.

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
if ~isfield(options,'hideMouse')
    options.hideMouse = 0; % Choose to hide the mouse cursor or not, default to hiding it
end
if ~isfield(options,'silenceKeyboard')
    options.silenceKeyboard = 0; % Choose to silence the keyboard or not, default to hiding it
end

addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'/Bistable_Tasks/BinoRiv_Task/EEG_Task/Stim'));
% end mps 20190730

% Open dialog box for easier user input
% Since they're running this script, we'll set some default params
optionsString = 'vaEEG';

options.displayFigs = 0;
options.practice.doPractice = 0;
options.practice.practiceBreak = 0;
options.analysisCheck = 0;
options.photodiodeTesting = 0;
options.signalPhotodiode = 1;
options.screenShot = 0;
options.eyeTracking = 0;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);
% optionsString = 'myComp';
% subjid = 'test';
% runid = 1;

% Initialize the eyetracker
if options.eyeTracking == 1
    % First find eyetracker
    options = findEyeTracker(options);
    
    % Next open the eye tracker manager to ensure correct head position
    options = openEyeTrackerManager_HeadPos(options);
end

% Setup options struct
options.compSetup = optionsString;
options.expName = 'BinoRiv_Task';
% options.expType = 'MR_Prac';   % For use in localOptions to look for scanner keyboardfff
options.expPath = fullfile(options.root_path,'/Bistable_Tasks/',options.expName,'/EEG_Task/');   % Path specific to the experiment % mps 20190730
options.eyeTrackingPath = '/Users/psphuser/Desktop/SchallmoLab/eyetracking/';
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

% ListenChar(2);
% 
% % Clock variables for datafile name
% options.el.datecode = datestr(now,'mmddyy');

% % ET Datafile name
% if options.eyeTracking == 1
%     options.el_datafile = ['BR_' options.el.datecode];
% end

% % Do calibration
% if options.eyeTracking == 1
%     [options] = setupCMRREyeTracking(options);
% end

% ListenChar(0);

%% Finish initilization

options = localOptions(options);

% Initialize the triggers
if options.eegRecording == 1
    config_io;
end

%% Trial parameters
options.runLength = 120;
options.practice.runLength = 30;

% Number of 2 minute blocks
options.numBlocks = 3;
options.control.numBlocks = 1;
options.practice.numBlocks = 1;

% Total number of screen flips
options.numFlips = options.wInfoNew.hz*options.runLength;
options.practice.numFlips = options.wInfoNew.hz*options.practice.runLength;

% Determine time incriments for increasing contrast (SSVEP)
options.flicker.flickerHz = 10;   % 
options.flicker.flickerDuration = 1/options.flicker.flickerHz;   % Time between contrast increases
options.flicker.flickerContrast = [.1 .6];   % Every time a change happens increase contrast

% Rawdata values
data.rawdata = zeros([options.numBlocks options.numFlips 3]);
data.control.rawdata = zeros([options.control.numBlocks options.numFlips 3]);
data.practice.rawdata = zeros([options.practice.numBlocks options.practice.numFlips 3]);

% Timing parameters
% Timing of screen flip relative to exp start
options.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.runLength,[options.numBlocks 1]);
options.control.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.runLength,[options.control.numBlocks 1]);
options.practice.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.practice.runLength,[options.practice.numBlocks 1]);

% Timing of flicker switches relative to exp start
options.flicker.flickerTimes = 1/options.wInfoNew.hz:options.flicker.flickerDuration:options.runLength;   % At what times do 'flips' occur
options.flicker.flickerFlipVals = zeros([1 size(options.time.flipTimes,2)])+options.flicker.flickerContrast(1);   % What contrast level will the stim be at for each flip
options.flicker.flickerLength = .058;   % Increase the contrast for 58ms before reducing again
options.flicker.flickerLength_NumFlips = round(options.flicker.flickerLength/(1/options.wInfoNew.hz));   % Number of screen flips to keep increase in contrast
for iI=1:length(options.flicker.flickerTimes)
    options.flicker.flickerFlipIdx(iI) = find(round(options.time.flipTimes(1,:),4)==round(options.flicker.flickerTimes(iI),4));   % Which # screen flip do we start each flicker flip
    
    % Starting at every flicker flip index, increase the contrast for
    % flickerLength_NumFlips number of flips
    options.flicker.flickerFlipVals(options.flicker.flickerFlipIdx(iI):...
        options.flicker.flickerFlipIdx(iI)+options.flicker.flickerLength_NumFlips) = options.flicker.flickerContrast(2);
end

% Determine what grating should be presented for each screen flip
% gratValue = randi(2);
for i=1:options.numFlips
    %     gratValue = 3-gratValue;
    gratValue = 3;
    options.gratValue(i) = gratValue;
end

% Determine the grating values for control task
% % Values used for first 4 subjs:
% options.control.switchTime = 5;   % number of seconds before a switch occurs
% options.control.switchTimeArray = 1:options.control.switchTime*options.wInfoNew.hz:options.numFlips;
% options.control.gratValue = [];
% gratValueChose = 1;
% for i=1:length(options.control.switchTimeArray)
%     gratValueChose = 3-gratValueChose;
%     gratValue = gratValueChose .* ones([options.control.switchTime*options.wInfoNew.hz 1]);
%     options.control.gratValue = [options.control.gratValue; gratValue];
% end
% Here are values used and how they were generated:
% Generate times based on first 3 control part switch rates: mean([0.1694,0.3667,0.3528]) = 0.2963Hz
% (1/0.2963)=3.75, generate switches every 3.75s w/ +/- .5:.1:1s jitter in each value
% options.control.switchTimeArray = round(3.75:3.75:120-3.75,3);
% jitterVals = .5:.1:1;
% jitterSigns = [-1 1];
% options.control.switchTimeArray = round(options.control.switchTimeArray + ...
%     (jitterVals(randi(length(jitterVals),[1 length(options.control.switchTimeArray)])) .* (jitterSigns(randi(2,[1 length(options.control.switchTimeArray)])))),3);
% Generated vals:
%  [2.95,8.2,12.25,15.6,19.55, 21.7,26.95,30.5,34.25,36.8,40.65 ,44.1,48.05,53.5,57.15,59.2,64.35,66.5,71.85,76,78.15,83.2,85.75,90.8,...
%     94.35,98,102.15,105.7,109.55,111.8,115.45]
options.control.switchTimesArray = [0 round([2.95,8.2,12.25,15.6,19.55,21.7,26.95,30.5,34.25,36.8,40.65,44.1,...
    48.05,53.5,57.15,59.2,64.35,66.5,71.85,76,78.15,83.2,85.75,90.8,...
    94.35,98,102.15,105.7,109.55,111.8,115.45] .* options.wInfoNew.hz) options.wInfoNew.hz*options.runLength];
options.control.gratValue = [];
gratValueChose = 1;
for iI=1:length(options.control.switchTimesArray)-1
    options.control.gratValue = [options.control.gratValue...
        zeros([1 options.control.switchTimesArray(iI+1) - options.control.switchTimesArray(iI)]) + gratValueChose];
    gratValueChose = 3-gratValueChose;
end

% Add in random both switches
options.control.numBothGrat = 5;   % Number of times the combined grating appears
% Time was 2; changed to 1.5 to accomidate for shorter grating times - KWK 20211111
options.control.bothGratTime = 1.5;   % Legnth of time the combined grating stays on the screen
% Make sure none of them are +/- the length of time they are on the screen for
options.control.bothGratTimeChose = options.control.bothGratTime:options.control.bothGratTime*2:options.runLength;
options.control.bothTimeArray = options.control.bothGratTimeChose(randperm(length(options.control.bothGratTimeChose),options.control.numBothGrat));
% Update grat value array to draw both grats
for i=1:length(options.control.bothTimeArray)
    options.control.gratValue(options.control.bothTimeArray(i)*options.wInfoNew.hz:...
        (options.control.bothTimeArray(i)*options.wInfoNew.hz)+(options.control.bothGratTime*options.wInfoNew.hz)) = 3;
end

% Determine the grating values for practice task
options.practice.gratValue = [];
gratValueChose = randi(2);
options.practice.switchTime = 5;   % number of seconds before a switch occurs
options.practice.switchTimeArray = 1:options.practice.switchTime*options.wInfoNew.hz:options.practice.numFlips;
for i=1:length(options.practice.switchTimeArray)
    gratValueChose = 3-gratValueChose;
    gratValue = gratValueChose .* ones([options.practice.switchTime*options.wInfoNew.hz 1]);
    options.practice.gratValue = [options.practice.gratValue; gratValue];
end
% Add in random both switches
options.practice.numBothGrat = 2;   % Number of times the combined grating appears
options.practice.bothGratTime = 2;   % Legnth of time the combined grating stays on the screen
% Make sure none of them are +/- the length of time they are on the screen for
options.practice.bothGratTimeChose = options.practice.bothGratTime:options.practice.bothGratTime*2:options.practice.runLength;
options.practice.bothTimeArray = options.practice.bothGratTimeChose(randperm(length(options.practice.bothGratTimeChose),options.practice.numBothGrat));
% Update grat value array to draw both grats
for i=1:length(options.practice.bothTimeArray)
    options.practice.gratValue(options.practice.bothTimeArray(i)*options.wInfoNew.hz:...
        (options.practice.bothTimeArray(i)*options.wInfoNew.hz)+(options.practice.bothGratTime*options.wInfoNew.hz)) = 3;
end

%% Stimulus parameters
% Make fixation points
options.blackFixation = do_fixation(options);
options.fixationRect = [options.xc - options.fix.fixSizeOuter/2*options.PPD,...
    options.yc - options.fix.fixSizeOuter/2*options.PPD,...
    options.xc + options.fix.fixSizeOuter/2*options.PPD,...
    options.yc + options.fix.fixSizeOuter/2*options.PPD];
options.blinkFixation = do_fixation_blink(options);

% general values
options.sp.gratPhase = 2*pi*rand(1, 2);   % Determine a random phase
options.sp.gratSize = 5.75*options.PPD;   % DoVA radius; changed to match Cuello diameter of 11.5 - KWK 20230808
[options.sp.xx, options.sp.yy] = meshgrid(-options.sp.gratSize:options.sp.gratSize, -options.sp.gratSize:options.sp.gratSize);
[options.sp.theta, options.sp.rr] = cart2pol(options.sp.xx, options.sp.yy);
options.sp.backGroundLum = 127.5;   % Color of background - single value
options.sp.meanLuminance = 127.5;   % Mean color of the grating
% options.sp.backGroundLum = options.grayCol(1);   % Color of background - single value
% options.sp.meanLuminance = options.grayCol(1);   % Mean color of the grating
options.sp.eyeAdjust = 0;

for iI=1:2   % Make different versions of each of the gratings with seperate contrast values (for the 'flicker')
    options.sp.contrast = options.flicker.flickerContrast(iI);
    
    holderOptions.sp = options.sp;
    holderOptions.PPD = options.PPD;
    if iI==2
       rmfield(holderOptions.sp,'left');
       rmfield(holderOptions.sp,'right');
       rmfield(holderOptions.sp,'both');
    end
    
    % Generate gratings for left and right eye
    holderOptions = genLeftRightGrating(holderOptions);
    options.sp.left(iI) = holderOptions.sp.left;
    options.sp.right(iI) = holderOptions.sp.right;
    clear holderOptions
    
    % Make the combined grating
    options.sp.both(iI).gratingAnn = options.sp.right(iI).gratingAnn+options.sp.left(iI).gratingAnn;
    % Cut off the inner and outer portions of the annulus
    options.sp.both(iI).gratingAnn(options.sp.left(iI).rr<options.sp.left(iI).eccentricity(1) | options.sp.left(iI).rr>options.sp.left(iI).eccentricity(2)) = options.sp.backGroundLum;
    options.sp.both(iI).center = [round(size(options.sp.left(iI).gratingAnn,1)/2), round(size(options.sp.both(iI).gratingAnn,2)/2)];
    % options.sp.both.gratingAnn((options.sp.both.center(1)-1:options.sp.both.center(1)+1),(options.sp.both.center(2)-1:options.sp.both.center(2)+1)) = 0;
    % options.sp.both.gratingAnn((options.sp.both.center(1) - 10):(options.sp.both.center(1) + 10), (options.sp.both.center(2)-1):(options.sp.both.center(2)+1)) = 0;
    % options.sp.both.gratingAnn((options.sp.both.center(1)-1):(options.sp.both.center(1)+1), (options.sp.both.center(2) - 10):(options.sp.both.center(2) + 10)) = 0;

    % Convert color of grating to updated display options
    for i=1:size(options.sp.left(iI).gratingAnn,1)
        for j=1:size(options.sp.left(iI).gratingAnn,2)
            for k=1:size(options.sp.left(iI).gratingAnn,3)
                options.sp.left(iI).gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.left(iI).gratingAnn(i,j,k)+1))*255;
                options.sp.right(iI).gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.right(iI).gratingAnn(i,j,k)+1))*255;
                options.sp.both(iI).gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.both(iI).gratingAnn(i,j,k)+1))*255;
            end
        end
    end

    % Make grating rects
    options.sp.left(iI).gratingAnnRect = CenterRect(([-1 -1 1 1] * max(options.sp.left(iI).eccentricity)),options.rect);
    options.sp.right(iI).gratingAnnRect = CenterRect(([-1 -1 1 1] * max(options.sp.right(iI).eccentricity)),options.rect);
    options.sp.both(iI).gratingAnnRect = options.sp.left(iI).gratingAnnRect;

    % Make grating texture
    options.sp.left(iI).gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.left(iI).gratingAnn);
    options.sp.right(iI).gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.right(iI).gratingAnn);
    options.sp.both(iI).gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.both(iI).gratingAnn);
end

% Generate frame
options = genFrame(options);

% Make frame texture
options.sp.frame.frameTexture = Screen('MakeTexture', options.windowNum, options.sp.frame.frame);


% Set the port adress
if options.eegRecording == 1
    options.addressOut = hex2dec('A010');
    options.addressIn = hex2dec('C010'); % may need to be C000, was "status" channels in Presentation, 4-bit
    object=io64;
    status=io64(object);
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

%% Start the experiment
% Instructions/Start screen

% Check to see if we need to run practice trials
if options.practice.doPractice == 1
    % Run practice
    [options,data] = BistableExp_BinoRiv_Practice_Behav(options,data);
    
     if options.practice.practiceBreak ~= 1
        % Run control task
        [options,data] = BistableExp_BinoRiv_Control_Behav(options,data);
        
        % Last instructions before the experiment starts
        text1='Now we will start the main experiment.';
        text2='Remember, your task is still the same, press the LEFT ARROW for BLUE LINES, RIGHT ARROW for RED LINES, and DOWN ARROW for MIXED.';
        text3='Please let the experimenter know if you have any questions or concerns.';
        text4='Tell the experimenter when you are ready to continue...';
        text5='LAST SCREEN BEFORE EXPERIMENT START!';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
        DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
        DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
        DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+50,options.whiteCol);
        Screen('Flip',options.windowNum);
        
        %     WaitSecs(.5);
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
elseif options.practice.doPractice == 0
    % Last instructions before the experiment starts
    text1='Now we will start the experiment.';
    text2='Remember, LEFT ARROW = RED/LEFT TILT, RIGHT ARROW = BLUE/RIGHT TILE, and DOWN ARROW = MIXED.';
    text3='Please let the experimenter know if you have any questions or concerns.';
    text4='Tell the experimenter when you are ready to continue...';
    text5='LAST SCREEN BEFORE EXPERIMENT START!';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
    DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
    DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+50,options.whiteCol);
    Screen('Flip',options.windowNum);
    
    %     WaitSecs(.5);
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


%% Draw the stimuli
% Start trial presentation
if options.practice.practiceBreak ~= 1
    for m=1:options.numBlocks
        
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            options.practice.practiceBreak = 1;
            break
        end
        
        % Present break screen
        if m>1
            text1 = sprintf('%s%d%s%d%s','Part ',m-1,' of ',options.numBlocks,' finished!');
            text2 = 'Let the experimenter know when you are ready.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
            
            Screen('Flip',options.windowNum);
            
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
        
%         % Start eyetracking for this block
%         if options.eyeTracking == 1
%             Eyelink('Command', 'set_idle_mode');
%             WaitSecs(0.05);
%             Eyelink('StartRecording');
%             % record a few samples before we actually start displaying
%             % otherwise you may lose a few msec of data
%             WaitSecs(1.1);
%         end

        % Start eyetracking
        if options.eyeTracking == 1
            options.ETOptions.eyeTracker.get_gaze_data();
        end

        % Send a trigger at the beginning of each block
        if options.eegRecording == 1
            default = 4;
            outp(options.addressOut, default);   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.addressOut, default);   % Clear the port
        end

        % SET PRIO WHILE PRESENTING STIM
        if options.eegRecording == 1
            priorityLevel=MaxPriority(options.windowNum);
            Priority(priorityLevel);
        end
        
        if options.practice.practiceBreak ~= 1
            options.time.sync_time(m) = Screen('Flip',options.windowNum);
            for n=1:options.numFlips
                
                [~,~,keycode,~] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    break
                end
                
                data.rawdata(m,n,3) = options.gratValue(n);
                if options.flicker.flickerFlipVals(n) == options.flicker.flickerContrast(1)
                    contrastHolder = 1;
                elseif options.flicker.flickerFlipVals(n) == options.flicker.flickerContrast(2)
                    contrastHolder = 2;
                end

                Screen('DrawTexture',options.windowNum,options.sp.frame.frameTexture);

                switch data.rawdata(m,n,3)
                    case 1
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.right(contrastHolder).gratingAnnTexture,...
                            [],options.sp.right(contrastHolder).gratingAnnRect);
                    case 2
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.left(contrastHolder).gratingAnnTexture,...
                            [],options.sp.left(contrastHolder).gratingAnnRect);
                    case 3
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.both(contrastHolder).gratingAnnTexture,...
                            [],options.sp.both(contrastHolder).gratingAnnRect);
                end

                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation

                % Present white square for photodiode 
                if contrastHolder==2
                    % Always present the white square for photodiode timing
                    % measurements
                    if options.photodiodeTesting == 1 || options.signalPhotodiode == 1
                        Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
                        %                 Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-40 (options.yc)-20 (options.xc*2) (options.yc*2)-100]);
                    end
                    if options.eegRecording
                        default = 1;
                        outp(options.addressOut, default);   % Send trigger
                        WaitSecs(0.005);
                        default = 0;
                        outp(options.addressOut, default);   % Clear the port
                    end
                end

                [~, options.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.time.sync_time(m)+options.time.flipTimes(m,n))-options.flip_interval_correction);

                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if buttonsHolder(1) == 1   % Left red
                    data.rawdata(m,n,2) = 1;

                    %                     % Send eyetracker trigger for each response made
                    %                     if options.eyeTracking == 1
                    %                         et_message = '1 - Left/Blue';
                    %                         Eyelink('Message', et_message);
                    %                     end

                    % Send response locked trigger
                    if options.eegRecording == 1
                        default = 6;
                        outp(options.addressOut, default);   % Send trigger
                        WaitSecs(0.005);
                        default = 0;
                        outp(options.addressOut, default);   % Clear the port
                        respSwitch=1;
                    end
                elseif buttonsHolder(1) == 2   % Right blue
                    data.rawdata(m,n,2) = 2;

                    %                     % Send eyetracker trigger for each response made
                    %                     if options.eyeTracking == 1
                    %                         et_message = '2 - Right/Red';
                    %                         Eyelink('Message', et_message);
                    %                     end

                    % Send response locked trigger
                    if options.eegRecording == 1
                        default = 7;
                        outp(options.addressOut, default);   % Send trigger
                        WaitSecs(0.005);
                        default = 0;
                        outp(options.addressOut, default);   % Clear the port
                        respSwitch=1;
                    end
                elseif buttonsHolder(1) == 3   % Either
                    data.rawdata(m,n,2) = 3;

                    %                     % Send eyetracker trigger for each response made
                    %                     if options.eyeTracking == 1
                    %                         et_message = '3 - Either/Both';
                    %                         Eyelink('Message', et_message);
                    %                     end
                    % Send response locked trigger
                    if options.eegRecording == 1
                        default = 8;
                        outp(options.addressOut, default);   % Send trigger
                        WaitSecs(0.005);
                        default = 0;
                        outp(options.addressOut, default);   % Clear the port
                        respSwitch=1;
                    end
                end
            end
        end

        %         % End eyetracking for current block
        %         if options.eyeTracking == 1
        %             %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
        %             %             Eyelink('Message', et_message);
        %
        %             WaitSecs(0.1);
        %             % stop the recording of eye-movements for the current trial
        %             Eyelink('StopRecording');
        %         end

        % SET PRIO TO NORMAL
        if options.eegRecording == 1
            Priority(0);
        end
        
        cleanUp(options,data,1);
        
    end
    
    [~,~,keycode,~] = KbCheck(options.dev_id);
    while ~keycode(options.buttons.buttonF) && ~keycode(options.buttons.buttonEscape)
        [~,~,keycode,~] = KbCheck(options.dev_id);
        text1 = 'Experiment finished.';
        text2 = 'Please tell experimenter.';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
        Screen('Flip',options.windowNum);
    end
    
    % If you've reached the end of the experiment turn on analysis switch
    if n==options.numFlips
        sca
        options.analysisCheck = 1;
    end
end

% % End eyetracking
% if options.eyeTracking == 1
%     %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
%     %             Eyelink('Message', et_message);
%     
%     WaitSecs(0.1);
%     
%     stopCMRREyeTracking(options);
% end

% If they finished the experiment
if options.practice.practiceBreak ~= 1
    
    % Set the timing values
    for i=1:size(options.time.flipTimesActual,1)
        data.rawdata(i,1:length(options.time.flipTimesActual),1) = options.time.flipTimesActual(i,:) - options.time.sync_time(i);
    end
    
    % Record the difference between predicted and actual flip times
    options.time.flipDiffs = data.rawdata(:,:,1) - options.time.flipTimes(:,:);
    
    % Make the rawdata variable into a table so it's easier for others to read
    counter = 0;
    for j=1:size(data.rawdata,1)
        for i=1:size(data.rawdata,3)
            counter = counter+1;
            t(:,counter)=table(data.rawdata(j,:,i));
        end
        t.Properties.VariableNames(length(t.Properties.VariableNames)-2) = {['Time_B' num2str(j)]};
        t.Properties.VariableNames(length(t.Properties.VariableNames)-1) = {['Percept_B' num2str(j)]};
        t.Properties.VariableNames(length(t.Properties.VariableNames)) = {['GratingType_B' num2str(j)]};
    end
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,fullfile(options.datadir,options.datafile));
    
    % Set the stair struct and rawdata to a data struct to send to save
    data.rawdataT = t;
    
    % Save data before doing the analysis
    cleanUp(options,data);
    
    %% Do analysis
    if options.analysisCheck == 1
        
        % Find the time for each change  in percept for each block
        for j=1:size(data.rawdata,1)
            percHolder = 0;
            counter = 0;
            for i=1:size(data.rawdata,2)
                
                % Look for a change in response
                if data.rawdata(j,i,2) ~= 0 && data.rawdata(j,i,2) ~= percHolder
                    percHolder = data.rawdata(j,i,2);
                    
                    % Record the time and type
                    counter = counter+1;
                    data.percSwitch{j}(counter) = data.rawdata(j,i,2);
                    data.percSwitchTime{j}(counter) = data.rawdata(j,i,1);
                    
                end
            end
            
            % Determine swtich rate
            data.switchRate(j) = length(data.percSwitch{j})/options.runLength;
        end
        
        % Analyze control data if run
        if options.practice.doPractice == 1
            % Find the time for each change  in percept for each block
            for j=1:size(data.control.rawdata,1)
                percHolder = 0;
                counter = 0;
                for i=1:size(data.control.rawdata,2)
                    
                    % Look for a change in response
                    if data.control.rawdata(j,i,2) ~= 0 && data.control.rawdata(j,i,2) ~= percHolder
                        percHolder = data.control.rawdata(j,i,2);
                        
                        % Record the time and type
                        counter = counter+1;
                        data.control.percSwitch{j}(counter) = data.control.rawdata(j,i,2);
                        data.control.percSwitchTime{j}(counter) = data.control.rawdata(j,i,1);
                        
                    end
                end
                
                % Determine swtich rate
                data.control.switchRate(j) = length(data.control.percSwitch{j})/options.runLength;
            end
        end
        
        if options.displayFigs == 1
            figure()
            
            % Display time series (change in percept over time)
            subplot(3,4,1:3)
            plot(data.rawdata(1,:,2));
            title('Switches Over Time');
            xlabel('Time (s)');
            ylabel('Percept (1=Towards, 2=Away)');
            set(gca,'XTick',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength],...
                'XTickLabels',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength]./options.wInfoNew.hz);
            subplot(3,4,5:7)
            plot(data.rawdata(2,:,2));
            title('Switches Over Time');
            xlabel('Time (s)');
            ylabel('Percept (1=Towards, 2=Away)');
            set(gca,'XTick',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength],...
                'XTickLabels',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength]./options.wInfoNew.hz);
            subplot(3,4,9:11)
            plot(data.rawdata(3,:,2));
            title('Switches Over Time');
            xlabel('Time (s)');
            ylabel('Percept (1=Towards, 2=Away)');
            set(gca,'XTick',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength],...
                'XTickLabels',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength]./options.wInfoNew.hz);
            
            % Display switch rate (Hz)
            subplot(3,4,[4 8 12]);
            bar([data.switchRate nanmean(data.switchRate)]);
            hold on 
            errorbar(length([data.switchRate nanmean(data.switchRate)]),nanmean(data.switchRate),nanstd(data.switchRate),'.k')
            title('Switche Rate');
            ylabel('Switch Rate (Hz)');
            % Make xtick labels
            for i=1:length(data.switchRate)
               xLab{i} = num2str(i); 
            end
            set(gca,'XTickLabels',{xLab{:},'Average'});
            set(gca,'YLim',[0 1.5],'YTick',[0:.2:1.5])
            
            if options.practice.doPractice == 1
                figure()
                
                subplot(1,4,1:3)
                plot(data.control.rawdata(1,:,2));
                title('Switches Over Time');
                xlabel('Time (s)');
                ylabel('Percept (1=Towards, 2=Away)');
                set(gca,'XTick',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength],...
                    'XTickLabels',[0:20*options.wInfoNew.hz:options.wInfoNew.hz*options.runLength]./options.wInfoNew.hz);
                
                % Display switch rate (Hz)
                subplot(1,4,4);
                bar(data.control.switchRate);
                hold on
                title('Switche Rate');
                ylabel('Switch Rate (Hz)');
                % Make xtick labels
                for i=1:length(data.control.switchRate)
                    xLab{i} = num2str(i);
                end
                set(gca,'XTickLabels',{xLab{:}});
                set(gca,'YLim',[0 1.5],'YTick',[0:.2:1.5])
            end
            
        end
    end
    
else
    cleanUp(options,data);
end



end








