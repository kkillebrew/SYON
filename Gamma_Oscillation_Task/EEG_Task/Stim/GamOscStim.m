clear all; close all;

%% Initialize
% Switch variables
eegComp = 0;
myComp = 1;

% Shuffle rng
rng('shuffle');

% Define colors
gray = [128 128 128];

% Define key names
KbName('UnifyKeyNames');
buttonEscape = KbName('escape');

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'GamOsc';

% get input
if eegComp == 1
    subjid = input('Enter Subject Code:','s');
    runid  = input('Enter Run:');
elseif myComp == 1
    subjid = 'test';
    runid = 1;
end

% Define paths
if eegComp == 1
    datadir = '';
elseif myComp == 1
    datadir = 'D:\SYON\Gamma Oscillation Task\';
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

if myComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
else
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);
end

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment/config
wInfoOrig = Screen('Resolution',0);
if eegComp == 1
    hz = wInfoOrig.hz;
    screenWide = 1024;
    screenHigh = 768;
    screenNum = 0;
    Screen('Resolution',screenNum,screenWide,screenHigh,hz);
elseif myComp == 1
    hz = wInfoOrig.hz;
    %     screenWide = wInfoOrig.width;
    %     screenHigh = wInfoOrig.height;
    screenWide = 1024;
    screenHigh = 768;
    screenNum = 0;
%     Screen('Resolution',screenNum,screenWide,screenHigh,hz);
end

% Open window
% [w,rect] = Screen('OpenWindow',0,gray,[0 0 screenWide screenHigh]);
[w,rect] = Screen('OpenWindow',0,gray,[],[],[],[],1);
xc = rect(3)/2;
yc = rect(4)/2;

% PPD stuff
if myComp == 1
    mon_width_cm = 25;
    mon_dist_cm = 30;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (screenWide/mon_width_deg);
end

% Sets your keyboard (only really matters when using more than 1)
[nums, names] = GetKeyboardIndices;
if myComp == 1
    dev_id=nums(1);
end

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
totalTimeOnScreen = 3.5;   % Max stim pres time in seconds
contractVelocity = 2/3;  % .66 DoVA/sec
speedUpTime = 2;   % Time at which the speed up occurs
speedUpVel = 1;   % New velocity
timeOnScreen = (totalTimeOnScreen-(totalTimeOnScreen-speedUpTime));   % Time present before speed up
speedUpTimeOnScreen = totalTimeOnScreen-speedUpTime;   % Amount of time the faster speed is presented

%% Sin wave
% Total variables
totalDegs = initSize;   % Degrees in the circle
totalCyc = initSize * cycPerDeg;
circlesPerDeg = (PPD*cycPerDeg);   % "Sampling frequency" (circles/degree)
degPerCircle = 1/circlesPerDeg;   % degrees/circle, to calculate t

% Sine wave variables
f = cycPerDeg;   % Frequency
a = 128;   % Amplitude
t = (0:degPerCircle:totalDegs-degPerCircle)';   % Samples

% Define the sin wave
sinWave = (a .*sin((2*pi*f*t)-deg2rad(90))) + 128;   % Start at 0
% plot(t,sinWave)   % Should have num DoVA on x axis, amplitude on y, and totalCyc number of peaks

%% Create textures for each stim presentation frame/Draw stim
% W/ 60Hz and 3.5s stimulus pres tim we need 210 textures (60/s)
[keyisdown, secs, keycode] = KbCheck(dev_id);
counter = 1;
while ~keycode(buttonEscape)
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    
    % Reset the sin wave
    sinWave = (a .*sin((2*pi*f*t)-deg2rad(90))) + 128;   % Start at 0
    
    % What rate will the sin wave change at (in circle degrees). In other
    % words, how many degrees do you need to shift per screen flip given
    % the refresh rate?
    % 1 cycle = 360 degrees
    % 1 dova = 3 cycles = 1080 degrees
    % at .66 dova/s you have to move 720 degrees/s
    % at 1 dova/s you have to move 1080 degrees/s
    slowRate = (360*cycPerDeg*contractVelocity)/hz;
    fastRate = (360*cycPerDeg*speedUpVel)/hz;
    origDegs = 270;   % Initial phase of the sin wave
    
    % Make the textures for the slow rate
    % Make one texture per screen flip
    % So if you present stim for 2 seconds total textures = 2*hz
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    for j=1:hz*timeOnScreen
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        
        % Make the texture
        circTexture{j} = Screen('MakeTexture',w,...
            ones(length(sinWave))+128);   % Texture that will be drawn
        
        % Initial framed circle location
        x1 = 0;
        y1 = 0;
        x2 = length(sinWave);
        y2 = length(sinWave);
        
        % Draw the framed circles onto the current texture
        for i=1:length(sinWave)/2
            
            Screen('FrameOval',circTexture{j},[sinWave(i) sinWave(i)...
                sinWave(i)],[x1 y1 x2 y2]);
            
            % Update the location variables
            x1 = x1+1;
            y1 = y1+1;
            x2 = x2-1;
            y2 = y2-1;
            
        end
        
        % Update the sin wave
        origDegs = origDegs - slowRate;
        sinWave = (a .*sin((2*pi*f*t)+deg2rad(origDegs))) + 128;
        
    end
    
    % Make the textures for the fast rate
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    for j=length(circTexture)+1:(length(circTexture)+1) + (hz*speedUpTimeOnScreen)
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        
        % Make the texture
        circTexture{j} = Screen('MakeTexture',w,...
            ones(length(sinWave))+128);   % Texture that will be drawn
        
        % Initial framed circle location
        x1 = 0;
        y1 = 0;
        x2 = length(sinWave);
        y2 = length(sinWave);
        
        % Draw the framed circles onto the current texture
        for i=1:length(sinWave)/2
            
            Screen('FrameOval',circTexture{j},[sinWave(i) sinWave(i)...
                sinWave(i)],[x1 y1 x2 y2]);
            
            % Update the location variables
            x1 = x1+1;
            y1 = y1+1;
            x2 = x2-1;
            y2 = y2-1;
            
        end
        
        % Update the sin wave
        origDegs = origDegs - fastRate;
        sinWave = (a .*sin((2*pi*f*t)+deg2rad(origDegs))) + 128;
        
    end
    
    %% Draw
    tic
    
    for i=1:length(circTexture)
        Screen('DrawTexture',w,circTexture{i},[],[xc-((initSize)*circlesPerDeg),yc-((initSize)*circlesPerDeg),...
            xc+((initSize)*circlesPerDeg),yc+((initSize)*circlesPerDeg)])
        Screen('FillRect',w,[255 0 0],[xc-5,yc-5,xc+5,yc+5]);
        Screen('Flip',w);
        
        
    end
       
    this(counter) = toc;
    counter = counter+1;
    
    % Wait a second between presentations
    WaitSecs(1);
    
    clear circTexture sinWave
    
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





