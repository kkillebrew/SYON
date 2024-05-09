% Gamma oscillation experiment.
% 2019-06-28
%
% Usage:
% [options,rawdata] = GamOscExp(options [,subjID] [,runID])
%
% Make sure to run in the same folder as the included functions folder.
%
% Input:
% options:
%   String that contains the computer setup label. I.e. 'vaEEG', 'labComp',
%   'arcEEG', etc.
% subjID:
%   Optional string variable containing the participants ID. If left empty,
%   and on lab/personal comp, will set subjID to 'Test'. If 'Test' is set
%   as subjID, will enable certain params, like hide cursor and listen
%   char. If on an EEG comp, will probe for subjID input.
% runID:
%   Optional string variable containing the run number. If left empty on a
%   lab/personal comp, will set runID to 1. If on an EEG comp, will probe.
%
% Output:
% options:
%   Structure including the params of the experiment. Includes monitor and
%   setup options.
% rawdata:
%   Table containing output data and condition variables.

function [] = GamOscExp(optionsString,subjid,runid)

clearvars -except optionsString subjid runid; close all; sca;

switch nargin
    case 1
        subjid = [];
        runid = [];
    case 2
        runid = [];
end

%% Initialize
% start mps edit 20190730
curr_path = pwd;
match_folder_name = 'SYON.git';
path_idx = strfind(curr_path,match_folder_name);
if ~isempty(path_idx)
    options.root_path = curr_path(1:path_idx+length(match_folder_name)-1);
else
    error(['Can''t find folder ' match_folder_name ' in current directory list!']);
end

addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'Gamma_Oscillation_Task\Stim'));
% end mps 20190730

options.compSetup = optionsString;
options.expName = 'Gamma_Oscillation_Task';
options.expPath = fullfile(options.root_path,options.expName,'\');   % Path specific to the experiment % mps 20190730
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
options.practice.doPractice = 0;
options.practice.practiceBreak = 0;
options.displayFigs = 1;
options.eegRecording = 0;
options.analysisCheck = 0;

% Initialize the triggers
if options.eegRecording == 1
    config_io;
end

%% Trial variables
options.numTrials = 180;
options.practice.numPracTrials = 10;

% Variable to track values on each trial
% 1st col: Trial number
% 2nd col: Time of speed up onset
% 3rd col: Time of onset of relative to exp start
% 4th col: Onset of speed change relative to trial start
% 5th col: Response time (relative to onset of speed change)
data.rawdata = zeros([options.numTrials,7]);
data.rawdata(:,1) = 1:options.numTrials;

% Determine how long after stimulus onset the speedup occurs
% r = a + (b-a).*rand(100,1);
data.rawdata(:,2) = 1 + (2.5-1) .* rand(options.numTrials,1);

% Give participants a break in between blocks
options.break_trials = options.numTrials/3+1:options.numTrials/3:options.numTrials;   % Give a break every third of the experiment  

%% Stimulus variables
% Define the sine wave to create the circle

% Example sine wave
% fs = 512;                    % Sampling frequency (samples per second)
% dt = 1/fs;                   % seconds per sample
% StopTime = 0.25;             % seconds
% t = (0:dt:StopTime-dt)';     % seconds
% F = 60;                      % Sine wave frequency (hertz)
% data = sin(2*pi*F*t);

% Initial variables
options.stim.initSize = 5;   % Diameter in DoVA
options.stim.cycPerDeg = 3;   % Number of cycles/1 DoVA
options.stim.pixPerCyc = options.PPD/options.stim.cycPerDeg;   % Number of pixels in one cycle

% Velocity variables
options.stim.contractVelocity = 2/3;  % .66 DoVA/sec
options.stim.speedUpTime = data.rawdata(1,2);   % Time at which the speed up occurs
options.stim.speedUpVel = 1;   % New velocity
options.stim.totalTimeOnScreen = options.stim.speedUpTime + 1;   % Max stim pres time in seconds
options.stim.timeOnScreen = (options.stim.totalTimeOnScreen-(options.stim.totalTimeOnScreen-options.stim.speedUpTime));   % Time present before speed up
options.stim.speedUpTimeOnScreen = options.stim.totalTimeOnScreen-options.stim.speedUpTime;   % Amount of time the faster speed is presented

% MAKE PRESTIM VARIABLE FROM 1.25-1.75   % KWK - We decided to make this
% variable even though it's different from original paper, so participants
% won't predict stim onset.
preStimList = 1.25:.01:1.75;
options.stim.preStimInterval =  preStimList(randi(length(preStimList),[options.numTrials,1]));
options.stim.feedBackInterval = 1;

% Make a circular aperture same size as the circular grating to mask out
% the black background of the texture
options.stim.Z = zeros(floor(options.stim.initSize*options.PPD)); % create square matrix of zeroes
options.stim.origin = [round((size(options.stim.Z,2)-1)/2+1) round((size(options.stim.Z,1)-1)/2+1)]; % "center" of the matrix
options.stim.radius = (floor((options.stim.initSize*options.PPD))/2)-6; % radius for a circle
[options.stim.xx,options.stim.yy] = meshgrid((1:size(options.stim.Z,2))-options.stim.origin(1),(1:size(options.stim.Z,1))-options.stim.origin(2)); % create x and y grid
options.stim.Z(sqrt(options.stim.xx.^2 + options.stim.yy.^2) <= options.stim.radius) = 1; % set points inside the radius equal to one
% imshow(Z); % show the "image"

% Set the port adress
if options.eegRecording == 1
    options.addressOut = hex2dec('A010');
    options.addressIn = hex2dec('C010'); % may need to be C000, was "status" channels in Presentation, 4-bit
    object=io64;
    status=io64(object);
end

%% Start of experiment
[keyisdown, secs, keycode] = KbCheck(options.dev_id);
expStart = GetSecs;
% for n=1:options.numTrials
n=0;
% while ~keycode(options.buttons.buttonEscape)
while n==0
    
    imCounter = 0;
    
    n = n+1;
    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
    if keycode(options.buttons.buttonEscape)
        break
    end
    respSwitch = 0;
    
    %% Present practice and instructions
    % Check to see if we need to run practice trials/present instructions
    if options.practice.doPractice == 1
        if n==1
            options.practice.practiceCheck = 1;
        end
        if options.practice.practiceCheck == 1
            [options,data] = GamOscExpPractice(options,data);
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
        
        %% Create stim
        % 1st col: Trial number
        % 2nd col: Time of speed up onset
        % 3rd col: Time of onset of relative to exp start
        % 4th col: Onset of speed change relative to trial start
        % 5th col: Response time (relative to onset of speed change)
        
        % Create the initial circular sine wave grating using function circsine
        origDegs = 90;   % Initial phase of the sin wave
        imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*127.5;
%         options.displayInfo.linearClut = 0:1/255:1;
        imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
        
        im(:,:,1) = imHolder;
        im(:,:,2) = imHolder;
        im(:,:,3) = imHolder;
        im(:,:,4) = options.stim.Z*255;
        clear imHolder
        
        % What rate will the sin wave change at (in circle degrees). In other
        % words, how many degrees do you need to shift per screen flip given
        % the refresh rate?
        % 1 cycle = 360 degrees
        % 1 dova = 3 cycles = 1080 degrees
        % at .66 dova/s you have to move 720 degrees/s
        % at 1 dova/s you have to move 1080 degrees/s
        slowRate = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
        fastRate = (360*options.stim.cycPerDeg*options.stim.speedUpVel)/options.wInfoNew.hz;
        
        % Make the textures for the slow rate
        % Make one texture per screen flip
        % So if you present stim for 2 seconds total textures = 2*hz
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        for j=1:options.wInfoNew.hz*options.stim.timeOnScreen
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            % Draw image to a texture
            circTexture{j} = Screen('MakeTexture',options.windowNum,im);
            
            % Update phase
            origDegs = origDegs + slowRate;
            
            % Update im
            clear imHolder
            imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*127.5;
            imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
            im(:,:,1) = imHolder;
            im(:,:,2) = imHolder;
            im(:,:,3) = imHolder;
            im(:,:,4) = options.stim.Z*255;
            
        end
        
        % How many textures are present for the slow speed
        slowTexs = length(circTexture);
        
        % Make the textures for the fast rate
        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
        for j=length(circTexture)+1:(length(circTexture)+1) + (options.wInfoNew.hz*options.stim.speedUpTimeOnScreen)
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            % Draw image to a texture
            circTexture{j} = Screen('MakeTexture',options.windowNum,im);
            
            % Update phase
            origDegs = origDegs + fastRate;
            
            % Update im
            clear im
            imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*127.5;
            imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
            im(:,:,1) = imHolder;
            im(:,:,2) = imHolder;
            im(:,:,3) = imHolder;
            im(:,:,4) = options.stim.Z*255;
            
        end
        
        % How many textures are present for the slow speed
        fastTexs = length(circTexture)-slowTexs;
        
        %% Draw
        
        % SET PRIO WHILE PRESENTING STIM
        if options.eegRecording == 1
            priorityLevel=MaxPriority(options.windowNum);
            Priority(priorityLevel);
        end
        
        % First present fixation for .5s
        Screen('FillRect',options.windowNum,options.fixCol,[options.xc-5,options.yc-5,options.xc+5,options.yc+5]);        
        Screen('Flip',options.windowNum);        
        
        imCounter = imCounter + 1;
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
        % imwrite is a Matlab function, not a PTB-3 function
        eval(sprintf('%s%d%s','imwrite(imageArray,''GamOscStim',imCounter,'.jpg'')'))
        
        WaitSecs(options.stim.preStimInterval(n));
        
        % 3rd col: Time of onset of relative to exp start
            data.rawdata(n,3) = GetSecs - expStart;
        options.trialStart(n) = GetSecs;
        
        % Send stim strigger
        if options.eegRecording == 1
            default = 2;
            outp(options.addressOut, default);   % Send trigger
            WaitSecs(0.005);
            default = 0;
            outp(options.addressOut, default);   % Clear the port
        end
        
        for i=1:length(circTexture)
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            Screen('DrawTexture',options.windowNum,circTexture{i},[],[options.xc-((options.stim.initSize*options.PPD)/2),options.yc-((options.stim.initSize*options.PPD)/2),...
                options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
            
            Screen('Flip',options.windowNum);
            
            if i==1
                imCounter = imCounter + 1;
                % GetImage call. Alter the rect argument to change the location of the screen shot
                imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
                % imwrite is a Matlab function, not a PTB-3 function
                eval(sprintf('%s%d%s','imwrite(imageArray,''GamOscStim',imCounter,'.jpg'')'))
            end
            
            % Check to see if this tex pres is the start of the speed change
            if i==slowTexs+1
                
                % Send speed up trigger
                if options.eegRecording == 1
                    default = 3;
                    outp(options.addressOut, default);   % Send trigger
                    WaitSecs(0.005);
                    default = 0;
                    outp(options.addressOut, default);   % Clear the port
                end
                
                % 4th col: Onset of speed change relative to trial start
                data.rawdata(n,4) = GetSecs - options.trialStart(n);
                
                % Start monitoring for key presses
                KbQueueFlush(options.dev_id);
                respTime = GetSecs;
            end
            
            % If speed up has happened check for response
            if i>=slowTexs+1
                if options.eegRecording == 1
                    % Use this for button box
%                     options.responseData(n) = io64(object,options.addressIn);
%                     options.responseData(n) = inp(options.addressIn);
                    % Use this for mouse clicks
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    if buttonsHolder(1) == 1   % Only checks for left button.
                        
                        % Send response locked trigger
                        if respSwitch~=1
                            if options.eegRecording == 1
                                default = 4;
                                outp(options.addressOut, default);   % Send trigger
                                WaitSecs(0.005);
                                default = 0;
                                outp(options.addressOut, default);   % Clear the port
                                respSwitch=1;
                            end
                        end
                        
                        data.rawdata(n,5) = GetSecs-respTime;
                    end
                else
                    %                     [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(options.dev_id);
                    %                     if any(firstPress(options.buttons.buttonSpace))
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    if buttonsHolder(1) == 1   % Only checks for left button.
                        data.rawdata(n,5) = GetSecs-respTime;
                        data.rawdata(n,6) = GetSecs-options.trialStart(n);
                    end
                end
            end
            
        end
        
        respSwitch = 0;
        % Wait a second between presentations
        if data.rawdata(n,5)==0   % If no response
            feedBackText = 'MISS';
            data.rawdata(n,5) = NaN;   % If no response make NaN
            data.rawdata(n,6) = NaN;
        else   % If response w/in the time limit
            feedBackText = 'OK';
        end
        
        % Store the prestim interval
        data.rawdata(n,7) =  options.stim.preStimInterval(n);
        
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
        DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-5,options.fixCol);
        Screen('FillRect',options.windowNum,options.fixCol,[options.xc-5,options.yc-5,options.xc+5,options.yc+5]);
        Screen('Flip',options.windowNum);
        
        imCounter = imCounter + 1;
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
        % imwrite is a Matlab function, not a PTB-3 function
        eval(sprintf('%s%d%s','imwrite(imageArray,''GamOscStim',imCounter,'.jpg'')'))
        
        WaitSecs(options.stim.feedBackInterval);
        
        % SET PRIO TO NORMAL
        if options.eegRecording == 1
            Priority(0);
        end
        
        Screen('Close',cell2mat(circTexture(:)));
        
        clear circTexture im
        
        % Velocity variables
        if n < options.numTrials
            options.stim.speedUpTime = data.rawdata(n+1,2);   % Time at which the speed up occurs
            options.stim.totalTimeOnScreen = options.stim.speedUpTime + .5;   % Max stim pres time in seconds
            options.stim.timeOnScreen = (options.stim.totalTimeOnScreen-(options.stim.totalTimeOnScreen-options.stim.speedUpTime));   % Time present before speed up
            options.stim.speedUpTimeOnScreen = options.stim.totalTimeOnScreen-options.stim.speedUpTime;   % Amount of time the faster speed is presented
        end
        
        % Save after each trial
        cleanUp(options,data,1);
    else
        break
    end
    
    if n==length(options.numTrials)
        options.analysisCheck = 1;
    end
    
end

%% Finish experiment

% Behavrioral analysis
if options.analysisCheck == 1
    cd ../Data/
    data = GamOscExp_BehavAnalysis(options,data);
    cd ../Stim/
end

% Make the data.rawdata variable into a table so it's easier for others to read
for i=1:size(data.rawdata,2)
    t(:,i)=table(data.rawdata(:,i));
end
t.Properties.VariableNames = {'TrialNumber','SpeedUpTimeCalc',...
    'TrialStart','SpeedUpTimeAct','RespScreenOnset_to_Resp','StimOnset_to_Resp','Prestim_Interval'};

% Save the text file for use w/ other programs not Matlab
writetable(t,sprintf('%s%s%s',options.datadir,options.datafile,'.txt'));

data.rawdataT = t;

% End exp screen
text1 = 'Experiment finished...';
text2 = 'Please tell experimenter.';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-250);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-200);
Screen('Flip',options.windowNum);
KbWait;

cleanUp(options,data);

end



