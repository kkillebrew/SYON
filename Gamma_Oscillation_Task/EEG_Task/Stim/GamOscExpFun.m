function [] = GamOscExpFun(options,subjid)

clear all; close all;

%% Initialize
% Switch variables
eegComp = 0;
myComp = 0;
myLabComp = 1;

% Shuffle rng
rng('shuffle');

% Define colors
grayCol = [128 128 128];

% Define key names
KbName('UnifyKeyNames');
buttonEscape = KbName('escape');
buttonSpace = KbName('space');

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'GamOsc';

% get input
if eegComp == 1
    subjid = input('Enter Subject Code:','s');
    runid  = input('Enter Run:');
elseif myComp == 1 || myLabComp == 1
    subjid = 'test';
    runid = 1;
end

% Define paths
if eegComp == 1
    datadir = '';
elseif myComp == 1
    datadir = 'D:\SYON\Gamma Oscillation Task\Stim\';
elseif myLabComp == 1
    datadir = 'C:\Users\kkillebr\Google Drive\SYON\Gamma Oscillation Task\Stim\';
end
datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,runid);
datafile_full=sprintf('%s_full',datafile);

% check to see if this file exists
if exist(fullfile(datadir,[datafile '.mat']),'file')
    tmpfile = input('File exists.  Overwrite? y/n:','s');
    while ~ismember(tmpfile,{'n' 'y'})
        tmpfile = input('Invalid choice. File exists.  Overwrite? y/n:','s');
    end
    if strcmp(tmpfile,'n')
        display('Bye-bye...');
        return; % will need to start over for new input
    end
end

% Hide cursor/stop keyboard print
if eegComp == 1
    HideCursor;
    ListenChar(2);
end

if myComp == 1 || myLabComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
else
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);
end

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment/config
if eegComp == 1
    screenNum = 0;
    wInfoOrig = Screen('Resolution',screenNum);
    hz = wInfoOrig.hz;
    screenWide = 1024;
    screenHigh = 768;
    Screen('Resolution',screenNum,screenWide,screenHigh,hz);
elseif myComp == 1
    screenNum = 0;
    wInfoOrig = Screen('Resolution',screenNum);
    hz = wInfoOrig.hz;
    %     screenWide = wInfoOrig.width;
    %     screenHigh = wInfoOrig.height;
    screenWide = wInfoOrig.width;
    screenHigh = wInfoOrig.height;
%     Screen('Resolution',screenNum,screenWide,screenHigh,hz);
elseif myLabComp == 1
    screenNum = 1;
    wInfoOrig = Screen('Resolution',screenNum);
    hz = wInfoOrig.hz;
    screenWide = wInfoOrig.width;
    screenHigh = wInfoOrig.height;
%     screenWide = 1024;
%     screenHigh = 768;
%     Screen('Resolution',screenNum,screenWide,screenHigh,hz);
end

% Open window
% [w,rect] = Screen('OpenWindow',0,gray,[0 0 screenWide screenHigh]);
[w,rect] = Screen('OpenWindow',screenNum,grayCol,[0 0 screenWide screenHigh],[],[],[],8);
xc = rect(3)/2;
yc = rect(4)/2;

% PPD stuff
if myComp == 1
    mon_width_cm = 25;
    mon_dist_cm = 30;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (screenWide/mon_width_deg);
elseif myLabComp == 1
    mon_width_cm = 28;
    mon_dist_cm = 30;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (screenWide/mon_width_deg);
elseif eegComp == 1
    
end

% Sets your keyboard (only really matters when using more than 1)
[nums, names] = GetKeyboardIndices;
if myComp == 1 || myLabComp == 1
    dev_id=nums(1);
end

allowed_keys = zeros(1,256);
allowed_keys([buttonEscape buttonSpace]) = 1;

KbQueueCreate(dev_id, allowed_keys);
KbQueueStart(dev_id);
KbQueueFlush(dev_id);

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % Must have for alpha values for some reason

%% Trial variables
numTrials = 180;

% Variable to track values on each trial
% 1st col: Trial number
% 2nd col: Time of speed up onset
% 3rd col: Time of onset of relative to exp start
% 4th col: Onset of speed change relative to trial start
% 5th col: Response time (relative to onset of speed change)
rawdata = zeros([numTrials,5]);
rawdata(:,1) = 1:numTrials;

% Determine how long after stimulus onset the speedup occurs
% r = a + (b-a).*rand(100,1);
rawdata(:,2) = .75 + (3-.75) .* rand(numTrials,1);

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
initSize = 5;   % Diameter in DoVA
cycPerDeg = 3;   % Number of cycles/1 DoVA
pixPerCyc = PPD/cycPerDeg;   % Number of pixels in one cycle

% Velocity variables
contractVelocity = 2/3;  % .66 DoVA/sec
speedUpTime = rawdata(1,2);   % Time at which the speed up occurs
speedUpVel = 1;   % New velocity
totalTimeOnScreen = speedUpTime + .5;   % Max stim pres time in seconds
timeOnScreen = (totalTimeOnScreen-(totalTimeOnScreen-speedUpTime));   % Time present before speed up
speedUpTimeOnScreen = totalTimeOnScreen-speedUpTime;   % Amount of time the faster speed is presented

preStimInterval = 1.5;
feedBackInterval = 1;

%% Sin wave
% Total variables
totalDegs = initSize;   % Degrees in the circle
totalCyc = initSize * cycPerDeg;
circlesPerDeg = (PPD*cycPerDeg);   % "Sampling frequency" (circles/degree)
degPerCircle = 1/circlesPerDeg;   % degrees/circle, to calculate t

% Make a circular aperture same size as the circular grating to mask out
% the black background of the texture
Z = zeros(floor(initSize*PPD)); % create square matrix of zeroes
origin = [round((size(Z,2)-1)/2+1) round((size(Z,1)-1)/2+1)]; % "center" of the matrix
radius = (floor((initSize*PPD))/2)-6; % radius for a circle
[xx,yy] = meshgrid((1:size(Z,2))-origin(1),(1:size(Z,1))-origin(2)); % create x and y grid
Z(sqrt(xx.^2 + yy.^2) <= radius) = 1; % set points inside the radius equal to one
% imshow(Z); % show the "image"

%% Start of experiment
[keyisdown, secs, keycode] = KbCheck(dev_id);
expStart = GetSecs;
% for n=1:numTrials
n=0;
while ~keycode(buttonEscape)
    n=n+1;
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    
    % 1st col: Trial number
    % 2nd col: Time of speed up onset
    % 3rd col: Time of onset of relative to exp start
    % 4th col: Onset of speed change relative to trial start
    % 5th col: Response time (relative to onset of speed change)
    
    % Create the initial circular sine wave grating using function circsine
    origDegs = 90;   % Initial phase of the sin wave
    imHolder = (circsine(initSize*PPD,pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*128;
    im(:,:,1) = imHolder;
    im(:,:,2) = imHolder;
    im(:,:,3) = imHolder;
    im(:,:,4) = Z*255;
    clear imHolder
    
    % What rate will the sin wave change at (in circle degrees). In other
    % words, how many degrees do you need to shift per screen flip given
    % the refresh rate?
    % 1 cycle = 360 degrees
    % 1 dova = 3 cycles = 1080 degrees
    % at .66 dova/s you have to move 720 degrees/s
    % at 1 dova/s you have to move 1080 degrees/s
    slowRate = (360*cycPerDeg*contractVelocity)/hz;
    fastRate = (360*cycPerDeg*speedUpVel)/hz;
    
    % Make the textures for the slow rate
    % Make one texture per screen flip
    % So if you present stim for 2 seconds total textures = 2*hz
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    for j=1:hz*timeOnScreen
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        
        % Draw image to a texture
        circTexture{j} = Screen('MakeTexture',w,im);
        
        % Update phase
        origDegs = origDegs + slowRate;
        
        % Update im
        clear imHolder
        imHolder = (circsine(initSize*PPD,pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*128;
        im(:,:,1) = imHolder;
        im(:,:,2) = imHolder;
        im(:,:,3) = imHolder;
        im(:,:,4) = Z*255;
                
    end
    
    % How many textures are present for the slow speed
    slowTexs = length(circTexture);
    
    % Make the textures for the fast rate
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    for j=length(circTexture)+1:(length(circTexture)+1) + (hz*speedUpTimeOnScreen)
        [keyisdown, secs, keycode] = KbQueueCheck(dev_id);
        
        % Draw image to a texture
        circTexture{j} = Screen('MakeTexture',w,im);
        
        % Update phase
        origDegs = origDegs + fastRate;
        
        % Update im
        clear im
        imHolder = (circsine(initSize*PPD,pixPerCyc,1,-1,deg2rad(origDegs),2,1)+1)*128;
        im(:,:,1) = imHolder;
        im(:,:,2) = imHolder;
        im(:,:,3) = imHolder;
        im(:,:,4) = Z*255;
        
    end
    
    % How many textures are present for the slow speed
    fastTexs = length(circTexture)-slowTexs;
    
    %% Draw
    
    % First present fixation for .5s
    Screen('FillRect',w,[0 0 0],[xc-5,yc-5,xc+5,yc+5]);
    Screen('Flip',w);
    
    WaitSecs(preStimInterval);
    
    % 3rd col: Time of onset of relative to exp start
    rawdata(n,3) = GetSecs - expStart;
    trialStart = GetSecs;
    
    for i=1:length(circTexture)
        
        Screen('DrawTexture',w,circTexture{i},[],[xc-((initSize*PPD)/2),yc-((initSize*PPD)/2),...
            xc+((initSize*PPD)/2),yc+((initSize*PPD)/2)]);
        Screen('Flip',w);
        
        % Check to see if this tex pres is the start of the speed change
        if i==slowTexs+1
           % 4th col: Onset of speed change relative to trial start 
           rawdata(n,4) = GetSecs - trialStart;
           
           % Start monitoring for key presses
           KbQueueFlush(dev_id);
           respTime = GetSecs;
        end
        
        % If speed up has happened check for response
        if i>=slowTexs+1
            [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
            if any(firstPress(buttonSpace))
                rawdata(n,5) = GetSecs-respTime;
            end
        end
        
    end
    
    % Wait a second between presentations
    if rawdata(n,5)==0   % If no response
        feedBackText = 'MISS';
    else   % If response w/in the time limit
        feedBackText = 'OK';
    end
    
    textHeight = RectHeight(Screen('TextBounds',w,feedBackText));
    DrawFormattedText(w,feedBackText,'center',yc-(textHeight/2)-5);
    Screen('FillRect',w,[0 0 0],[xc-5,yc-5,xc+5,yc+5]);
    Screen('Flip',w);
    WaitSecs(feedBackInterval);
    
    Screen('Close',cell2mat(circTexture(:)));
    
    clear circTexture im
    
    % Velocity variables
    speedUpTime = rawdata(n+1,2);   % Time at which the speed up occurs
    totalTimeOnScreen = speedUpTime + .5;   % Max stim pres time in seconds
    timeOnScreen = (totalTimeOnScreen-(totalTimeOnScreen-speedUpTime));   % Time present before speed up
    speedUpTimeOnScreen = totalTimeOnScreen-speedUpTime;   % Amount of time the faster speed is presented
    
end

% Save

Screen('CloseAll');

% Show cursor/turn on key input
if eegComp == 1
    ShowCursor;
    ListenChar(0);
end

% Reset screen resolution/ref rate
if eegComp == 1
    Screen('Resolution',screenNum,wInfoOrig.width,...
        wInfoOrig.height,wInfoOrig.hz);
end


end


