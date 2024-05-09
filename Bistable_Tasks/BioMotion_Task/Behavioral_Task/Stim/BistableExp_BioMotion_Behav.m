% Bistable biological motion task. Runs 30s practice, 1 x 2 minute control task, 3 x 2 minute run of the bistable biological 
% motion task. Participants are instructed to press the left or right mouse button when they see a change in motion direction.
% KWK - 20201005

function [] = BistableExp_BioMotion_Behav()

clearvars -except optionsString subjid runid; close all; sca;

clear PsychHID; % Force new enumeration of devices.
clear KbCheck; % Clear persistent cache of keyboard devices.

% Screen('Preference', 'SkipSyncTests', 1);

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

addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'/Bistable_Tasks/BioMotion_Task/Behavioral_Task/Stim'));
% end mps 20190730

% Open dialog box for easier user input
% Since they're running this script, we'll set some default params
optionsString = 'CMRR_Psychophysics';

options.displayFigs = 1;
options.practice.doPractice = 1;
options.practice.practiceBreak = 0;
options.analysisCheck = 1;
options.screenShot = 0;
options.eyeTracking = 1;
[optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);
% optionsString = 'myComp';
% subjid = 'test';
% runid = 1;

% Setup options struct
options.compSetup = optionsString;
options.expName = 'BioMotion_Task';
options.expType = 'MR_Prac';   % For use in localOptions to look for scanner keyboard
options.expPath = fullfile(options.root_path,'/Bistable_Tasks/',options.expName,'/Behavioral_Task/');   % Path specific to the experiment % mps 20190730
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

ListenChar(2);

% Clock variables for datafile name
options.el.datecode = datestr(now,'mmddyy');

% ET Datafile name
if options.eyeTracking == 1
    options.el_datafile = ['BM_' options.el.datecode];
end

% Do calibration
if options.eyeTracking == 1
    [options] = setupCMRREyeTracking(options);
end

ListenChar(0);

%% Finish initilization
options = localOptions(options);

% Switch keyboard definition depending on setup
if ~strcmp(options.compSetup,'CMRR_Psychophysics')
    options.dev_id2 = options.dev_id;
end

% Screen center coords
options.screenCent = [options.xc; options.yc];

%% Trial variables
% Total length of the run
options.runLength = 120;   % Seconds
options.practice.runLength = 30;   % Seconds

% Number of 2 minute blocks
options.numBlocks = 3;
options.control.numBlocks = 1;
options.practice.numBlocks = 1;

% Total number of screen flips
options.numFlips = options.wInfoNew.hz*options.runLength;
options.practice.numFlips = options.wInfoNew.hz*options.practice.runLength;

% Rawdata - one array total number of screen flips - monitor every screen flip
data.rawdata = zeros([options.numBlocks options.numFlips 2]);
data.control.rawdata = zeros([options.control.numBlocks options.numFlips 2]);
data.practice.rawdata = zeros([options.practice.numBlocks options.practice.numFlips 2]);

% Timing values
% Timing of screen flip relative to exp start
options.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.runLength,[options.numBlocks 1]);
options.control.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.runLength,[options.control.numBlocks 1]);
options.practice.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.practice.runLength,[options.practice.numBlocks 1]);

%% Ggenerate pointlight display data using 3D coordinates file
% Load in PLW point locations
options.PLW_stim.filename = '07_01.data3d.txt';% input data file
% scale size of PLW (distance between dots)
options.PLW_stim.scale1 = 25;
% image size (not sure what this is...KWK)
options.PLW_stim.imagex = 1;
% Dot diameter
options.PLW_stim.pointSize = .15*options.PPD;
%it appears the joint numbers are arranged in a series like 26 27 28.
%Order of joints: head; l shoulder; l elbow, l hand; r shoulder; r elbow; r
%hand; l hip; l knee; l foot; r hip; r knee; r foot;
% 0 for head, 1 for left parts and 2 for right parts of PLW.
options.PLW_stim.mapping = [0 1 1 1 2 2 2 1 1 1 2 2 2];

% reading in bvh files
options.PLW_stim.readData = PLWread(options.PLW_stim.filename);

% calculate the discrete dots along each limb
options.PLW_stim.readData.thet = 90;  %to rotate along the first axis
%to rotate across xyz
% options.PLW_stim.readData.xyzseq = [1 3 2];   % To invert
options.PLW_stim.readData.xyzseq = [1 3 2];   % To invert
[options.PLW_stim.dotx, options.PLW_stim.doty] = PLWtransform(options.PLW_stim.readData, options.PLW_stim.scale1, options.PLW_stim.imagex, -1);

% Invert the PLW
options.PLW_stim.dotx = options.PLW_stim.dotx.*-1;
options.PLW_stim.doty = options.PLW_stim.doty.*-1;

% Determine max/min height and width of PLW
options.PLW_stim.maxX = max(options.PLW_stim.dotx(:,4)+options.xc);   % Max position of the left hand
options.PLW_stim.maxY = min([min(options.PLW_stim.doty(:,10)+options.yc) min(options.PLW_stim.doty(:,13)+options.yc)]);   % Min position of the feet
options.PLW_stim.minX = min(options.PLW_stim.dotx(:,7)+options.xc);   % Min position of the right hand
options.PLW_stim.minY = max(options.PLW_stim.doty(:,1)+options.yc);   % Max position of the head

% options.PLW_stim.gcolor = {[0 0 0],[0 0 255],[255 0 0]};
options.PLW_stim.gcolor = {[0 0 0],[0 0 0],[0 0 0]};

% Determine the number and time of updates to the PLW over the course of the run
options.PLW_stim.cycleNum = 130;   % Number of PLW updates in one cycle
options.PLW_stim.cycleTime = 1;   % Amount of time it takes to complete one walking cycle
options.PLW_stim.totalCycles = options.runLength/options.PLW_stim.cycleTime;   % Total cycles in one run
options.PLW_stim.lengthLoop = options.PLW_stim.cycleNum*options.PLW_stim.totalCycles;
options.practice.PLW_stim.totalCycles = options.practice.runLength/options.PLW_stim.cycleTime;   % Total cycles in one practice run
options.practice.PLW_stim.lengthLoop = options.PLW_stim.cycleNum*options.practice.PLW_stim.totalCycles;

% Determine the postion of the points for each screen flip for a 2 minute run
options.PLW_stim.dotloop = modloop(1:options.PLW_stim.lengthLoop, size(options.PLW_stim.dotx,1));
options.practice.PLW_stim.dotloop = modloop(1:options.practice.PLW_stim.lengthLoop, size(options.PLW_stim.dotx,1));

% Make array of individual PLW dot positions over time
count=0;
for f=1:options.PLW_stim.lengthLoop  % two for accuracy
    count=count+1;
    % signal parts
    for grouping = 0 : 2
        options.PLW_stim.dotPos{f,grouping+1} = [options.PLW_stim.dotx(options.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping);...
            options.PLW_stim.doty(options.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping)];
    end
end

% Make array of individual PLW dot positions over time for the practice run
count=0;
for f=1:options.practice.PLW_stim.lengthLoop  % two for accuracy
    count=count+1;
    % signal parts
    for grouping = 0 : 2
        options.practice.PLW_stim.dotPos{f,grouping+1} = [options.PLW_stim.dotx(options.practice.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping);...
            options.PLW_stim.doty(options.practice.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping)];
    end
end

% Determine what dot pos values should be presented on every flip
% (For fast monitors, you will most likely present every dot pos but not update every frame,
% but for slower monitors, you will most likely skip some dot pos and still present every frame)
options.PLW_stim.updateFlips = round(linspace(1,options.PLW_stim.lengthLoop,options.numFlips));
options.practice.PLW_stim.updateFlips = round(linspace(1,options.practice.PLW_stim.lengthLoop,options.practice.numFlips));

% Determine position of fixation
options.fixLoc = [mean([options.PLW_stim.maxX options.PLW_stim.minX]) mean([options.PLW_stim.maxY options.PLW_stim.minY])]; 

%% Control stimuli variables
% Variables for moving dots
options.control.maxDotSize = .5;   % Radius of dots at max size in dova
options.control.numDots = 50;   % Number of dots present at any time
options.control.dotSpeedDegs = 2.5;   % Dot speed (how fast the dots will move per second in dova)
options.control.dotSpeedPix = (options.control.dotSpeedDegs*options.PPD)/options.wInfoNew.hz;   % How many pixels do you need to move per screen flip

% Max radius of dots from screen center
options.control.maxRadDeg = 7;
options.control.maxRad = options.control.maxRadDeg*options.PPD;
options.control.maxVisRadDeg = 6;   % Cutoff for visible dots
options.control.maxVisRad = options.control.maxVisRadDeg*options.PPD;

% Determine the location of angle of the dot relative to PLW center
options.control.dotAngle = randperm(360,options.control.numDots);

% Determine the radius from the center point each dot is
options.control.dotRad = randperm(round(options.control.maxRad),options.control.numDots);

% Determine the starting position of each of the dots
% x = xCenter + radius * cosd(theta);
% y = yCenter + radius * sind(theta);
options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);

% Determine the size of the dots as a function of their distance from max
options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);

% Update size of control dots that are too small
options.control.dotRad(options.control.dotSize<1) = options.control.maxRad;
options.control.dotSize(options.control.dotSize<1) = options.control.maxDotSize*options.PPD;
options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);

% Make a window texture to occlude dots too far away
options.control.occTexArray(:,:,1:3) = zeros([options.rect(4) options.rect(4) 3]);
options.control.occTexArray(:,:,1) = options.control.occTexArray(:,:,1) + options.grayCol(1);
options.control.occTexArray(:,:,2) = options.control.occTexArray(:,:,2) + options.grayCol(2);
options.control.occTexArray(:,:,3) = options.control.occTexArray(:,:,3) + options.grayCol(3);
options.control.occTexArray(:,:,4) = false([options.rect(4) options.rect(4)]);
[xx,yy] = meshgrid(1:options.rect(4),1:options.rect(4));
options.control.occTexArray(:,:,4) = ~(options.control.occTexArray(:,:,4) | hypot(xx - options.yc,...
    yy - options.yc) <= round(options.control.maxVisRad));
options.control.occTexArray(:,:,4) = options.control.occTexArray(:,:,4).*options.whiteCol(3);
options.control.occTex = Screen('MakeTexture',options.windowNum,options.control.occTexArray);

% Determine time of switches
% KWK - 20211111 - Generating switch times based on control subject performance. Will want to keep the same switch times
% across all participants. 
% Values used for first 4 subjs:
% options.control.switchTimesRange = 10:10:110;
% options.control.switchIdx = repmat([ones([1 10*options.wInfoNew.hz]) ones([1 10*options.wInfoNew.hz])+1],[1 6]);
% Here are values used and how they were generated:
% Generate times based on first 3 control part switch rates: mean([0.02778,0.03056,0.075]) = 0.0444Hz
% 1/0.0444=22.523, generate switches every 22.523s w/ +/- 2:.1:3s jitter in each value
% switchTimesRange = round(22.523:22.523:120,3);
% jitterVals = 2:.1:3;
% jitterSigns = [-1 1];
% switchTimesRange = round(switchTimesRange + ...
%     (jitterVals(randi(length(jitterVals),[1 length(switchTimesRange)])) .* (jitterSigns(randi(2,[1 length(switchTimesRange)])))),3);
% Generated vals:
% [20.323,47.246,64.669,92.492,115.52]
options.control.switchTimesRange = [0 round([20.323,47.246,64.669,92.492,115.52] .* options.wInfoNew.hz) options.wInfoNew.hz*options.runLength];
% Generate switch index
options.control.switchIdx = [];
switchHolder = 1;
for iI=1:length(options.control.switchTimesRange)-1
    options.control.switchIdx = [options.control.switchIdx...
        zeros([1 options.control.switchTimesRange(iI+1) - options.control.switchTimesRange(iI)]) + switchHolder];
    switchHolder = 3-switchHolder;
end

% Determine time of switches
options.practice.switchTimesRange = 10:10:30;
options.practice.switchIdx = [ones([1 10*options.wInfoNew.hz]) ones([1 10*options.wInfoNew.hz])+1 ones([1 10*options.wInfoNew.hz])];


%% Start the experiment
% Instructions/Start screen
% Check to see if we need to run practice trials
if options.practice.doPractice == 1
    % Run practice
    [options,data] = BistableExp_BioMotion_Practice_Behav(options,data);
    
    if options.practice.practiceBreak ~= 1
        % Run control task
        [options,data] = BistableExp_BioMotion_Control_Behav(options,data);
        
        % Last instructions before the experiment starts
        text1='Now we will start the main experiment.';
        text2='For the rest of the blocks, there won''t be the moving white dots.';
        text3='Remember, your task is still the same, press the DOWN ARROW for WALKING TOWARDS and UP ARROW for WALKING AWAY.';
        text4='Please let the experimenter know if you have any questions or concerns.';
        text5='Tell the experimenter when you are ready to continue...';
        text6='LAST SCREEN BEFORE EXPERIMENT START!';
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
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
        DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)+100,options.whiteCol);
        Screen('Flip',options.windowNum);
        
    end
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
    
elseif options.practice.doPractice == 0
    % Last instructions before the experiment starts
    text1='Now we will start the main experiment.';
    text2='Remember, DOWN ARROW = WALKING TOWARDS and UP ARROW = WALKING AWAY.';
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
        
        % Start eyetracking for this block
        if options.eyeTracking == 1
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording');
            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data
            WaitSecs(1.1);
        end
        
        if options.practice.practiceBreak ~= 1
            options.time.sync_time(m) = Screen('Flip',options.windowNum);
            for n=1:options.numFlips
                
                [~,~,keycode,~] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    options.practice.practiceBreak = 1;
                    break
                end
                
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                 Screen('FillRect',options.windowNum,options.fixCol,...
%                     [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);  
%                 Screen('FillRect',options.windowNum,options.whiteCol,...
%                     [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                [~, options.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.time.sync_time(m)+options.time.flipTimes(m,n))-options.flip_interval_correction);
                
                
                % Monitor for responses
                [~,~,keycode,~] = KbCheck(options.dev_id2);
                if keycode(options.buttons.buttonDown)   % Walking toward
                    data.rawdata(m,n,2) = 1;
                    
                    % Send eyetracker trigger for each response made
                    if options.eyeTracking == 1
                        et_message = '1 - Towards';
                        Eyelink('Message', et_message);
                    end
                elseif keycode(options.buttons.buttonUp)   % Walking away
                    data.rawdata(m,n,2) = 2;
                    
                    % Send eyetracker trigger for each response made
                    if options.eyeTracking == 1
                        et_message = '2 - Away';
                        Eyelink('Message', et_message);
                    end
                    %         elseif keycode(options.buttons.buttonLeft)   % Neither
                    %             data.rawdata(n,2) = 3;
                    %
                    %             % Send eyetracker trigger for each response made
                    %             if options.eyeTracking == 1
                    %                 et_message = '3 - Either';
                    %                 Eyelink('Message', et_message);
                    %             end
                end
            end
        end
        % End eyetracking for current block
        if options.eyeTracking == 1
            %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
            %             Eyelink('Message', et_message);
            
            WaitSecs(0.1);
            % stop the recording of eye-movements for the current trial
            Eyelink('StopRecording');
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
    if n==options.numFlips && m==options.numBlocks
        sca
        options.analysisCheck = 1;
    end
    
    cleanUp(options,data,1);
end

% End eyetracking
if options.eyeTracking == 1
    %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
    %             Eyelink('Message', et_message);
    
    WaitSecs(0.1);
    
    stopCMRREyeTracking(options);
end

% If they finished the experiment
if options.practice.practiceBreak ~= 1
    
    % Set the timing values
    for i=1:size(options.time.flipTimesActual,1)
        data.rawdata(i,1:length(options.time.flipTimesActual(i,:)),1) = options.time.flipTimesActual(i,:) - options.time.sync_time(i);
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
        t.Properties.VariableNames(length(t.Properties.VariableNames)-1) = {['Time_B' num2str(j)]};
        t.Properties.VariableNames(length(t.Properties.VariableNames)) = {['Percept_B' num2str(j)]};
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

