% Stimuli for the illusory contour task for the SYON grant. 

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
buttonRight = KbName('rightarrow');
buttonLeft = KbName('leftarrow');

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
[w,rect] = Screen('OpenWindow',screenNum,grayCol,[0 0 screenWide screenHigh]);
% [w,rect] = Screen('OpenWindow',1,grayCol,[0 0 screenWide screenHigh],[],[],[],8);
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
% List variables to determine trial sequence
illusoryList = [1 2];   % 1=illusory 2=fragmented
illusoryNum = length(illusoryList);
fatThinList = [1 2];   % If illusory 1=fat 2=thin or if fragmented 1=left 2=right tilted
fatThinNum = length(fatThinList);

%% Stimulus variables
% Size variables
circDia = 1.5;   % Diameter of the circle
circDist = 4.5;   % Distance between the center points of each circle

% Illusory angle variables - the initial angle each of the texture is rotated
texAngleIllusory(1) = 0;   % Upper left
texAngleIllusory(2) = 0;   % Upper right
texAngleIllusory(3) = 270;   % Lower left
texAngleIllusory(4) = 90;   % Lower right
% Fragmented angle variables - the initial angle each of the texture is rotated
texAngleFragmented(1) = 45;   % Upper left
texAngleFragmented(2) = 315;   % Upper right
texAngleFragmented(3) = 45;   % Lower left
texAngleFragmented(4) = 315;   % Lower right

% Make two textures, for left and right, to draw the inducers onto
texArray(:,:,1) = zeros(ceil(circDia*PPD)) + grayCol(1);
texArray(:,:,2) = zeros(ceil(circDia*PPD)) + grayCol(2);
texArray(:,:,3) = zeros(ceil(circDia*PPD)) + grayCol(3);
inducerTex(1) = Screen('MakeTexture',w,texArray);
inducerTex(2) = Screen('MakeTexture',w,texArray);

% Draw a circle w/ overlapped gray square on both textures in correct
% position
Screen('FillOval',inducerTex(1),[255 255 255],[0 0 ceil(circDia*PPD) ceil(circDia*PPD)]);
Screen('FillRect',inducerTex(1),grayCol,[ceil((circDia*PPD)/2) ceil((circDia*PPD)/2)...
    ceil((circDia*PPD)) ceil((circDia*PPD))]);
Screen('FillOval',inducerTex(2),[255 255 255],[0 0 ceil(circDia*PPD) ceil(circDia*PPD)]);
Screen('FillRect',inducerTex(2),grayCol,[0 ceil((circDia*PPD)/2)...
    ceil((circDia*PPD)/2) ceil(circDia*PPD)]);
 
% Position of each of the 4 inducers
circPositionArray(1,:) = [xc-ceil((circDia*PPD)/2)-((circDist/2)*PPD) yc-ceil((circDia*PPD)/2)-((circDist/2)*PPD)...
    xc+ceil((circDia*PPD)/2)-((circDist/2)*PPD) yc+ceil((circDia*PPD)/2)-((circDist/2)*PPD)];
circPositionArray(2,:) = [xc-ceil((circDia*PPD)/2)+((circDist/2)*PPD) yc-ceil((circDia*PPD)/2)-((circDist/2)*PPD)...
    xc+ceil((circDia*PPD)/2)+((circDist/2)*PPD) yc+ceil((circDia*PPD)/2)-((circDist/2)*PPD)];
circPositionArray(3,:) = [xc-ceil((circDia*PPD)/2)-(( circDist/2)*PPD) yc-ceil((circDia*PPD)/2)+((circDist/2)*PPD)...
    xc+ceil((circDia*PPD)/2)-((circDist/2)*PPD) yc+ceil((circDia*PPD)/2)+((circDist/2)*PPD)];
circPositionArray(4,:) = [xc-ceil((circDia*PPD)/2)+((circDist/2)*PPD) yc-ceil((circDia*PPD)/2)+((circDist/2)*PPD)...
    xc+ceil((circDia*PPD)/2)+((circDist/2)*PPD) yc+ceil((circDia*PPD)/2)+((circDist/2)*PPD)];

% Overall tilt
% The sign of the rotation is always relative to the first inducer.
overallTilt = 0;   % Amount of tilt we apply to all textures relative to starting position
% Values to multiple overallTilt by to get the correct rotation angle for each of the 4 inducers
texAngleTilt = [1 -1 -1 1];

%% Draw stimuli
[keyisdown, secs, keycode] = KbCheck(dev_id);
while 1
    
%     illFragIdx = rawdata(n,2);
    
    texAngle = texAngleIllusory;
    
    Screen('DrawTextures',w,[inducerTex(1) inducerTex(2) inducerTex(1) inducerTex(2)],[],...
        circPositionArray',texAngle+(overallTilt.*texAngleTilt));
    Screen('FillOval',w,[0 0 0],[xc-2 yc-2 xc+2 yc+2]);
    
    Screen('Flip',w);
        
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    if keycode(buttonLeft) && overallTilt > -15
        overallTilt = overallTilt - 1;   % rotate first inducer counter clockwise
    elseif keycode(buttonRight) && overallTilt < 15
        overallTilt = overallTilt + 1;   % rotate first inducer clockwise
    end
    overallTilt
    if keycode(buttonEscape)
        sca
        break
    end
end










