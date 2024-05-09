% Set options local to your setup (i.e., monitor res, ref rate, dev_ids,
% PPD, monitor callibration files, etc.)
% 2019-06-28
%
% Usage:
% [options,rawdata] = GamOscExp(options [,subjID] [,runID])
%
% Make sure to run in the same folder as the included functions folder.
%
% Input:
% options: 
%   Struct containing initialization options for monitor/computer/keyboard/
%   experiment. Included fields for this script are: 
%       compSetup
%       expName
%       expPath
%
% Output:
% options:
%   Structure including the params of the experiment. Includes monitor and
%   setup options.

function [options] = localOptions(options)

%% Check for input and setup input variables

if ~isfield(options,'compSetup')
    error('No computer setup provided.')
end

if ~isfield(options,'expName')
   error('No experiment name provided.')
end

if ~isfield(options,'expPath')
    error('No experiment path provided.')
end
if ~isfield(options,'hideMouse')
    options.hideMouse = 1; % Choose to hide the mouse cursor or not, default to hiding it
end
if ~isfield(options,'silenceKeyboard')
    options.silenceKeyboard = 1; % Choose to silence the keyboard or not, default to hiding it
end

%% General setup options

% Define key names
KbName('UnifyKeyNames');
options.buttons.buttonEscape = KbName('escape');
options.buttons.buttonSpace = KbName('space');
options.buttons.buttonRight = KbName('rightarrow');
options.buttons.buttonLeft = KbName('leftarrow');
options.buttons.buttonDown = KbName('downarrow');
options.buttons.buttonUp = KbName('uparrow');
options.buttons.buttonR = KbName('r');
options.buttons.buttonF = KbName('f');
options.buttons.buttonN = KbName('n');
options.buttons.buttonY = KbName('y');
options.buttons.button1 = KbName('1!');
options.buttons.button2 = KbName('2@');
options.buttons.button3 = KbName('3#');
options.buttons.button4 = KbName('4$');

% SCANNER KEYS
options.buttons.scannerR = KbName('r');
options.buttons.scannerG = KbName('g');
options.buttons.scannerB = KbName('b');
options.buttons.scannerY = KbName('y');
options.buttons.scannerTrigger = KbName('t');

% Shuffle rng
rng('default');
rng('shuffle');

% Define colors
options.grayCol = [128 128 128];
options.fixCol = [0 0 0];
options.whiteCol = [255 255 255];
options.redCol = [255 0 0];
options.blueCol = [0 0 255];
options.greenCol = [0 255 0];
options.yellowCol = [255 215 0];

% Clock variables for datafile name
options.c = clock;
options.time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',options.c(2),options.c(3),...
    options.c(1),options.c(4),options.c(5),options.c(6)); % month/day/year hour:min:sec
options.datecode = datestr(now,'mmddyy');

% Sets your keyboard (only really matters when using more than 1)
[nums, names] = GetKeyboardIndices;
if ~isfield(options,'expType')
    options.dev_id=nums(1);
    options.scanner_id=nums(1);
    
    % Setup the Kb Queue
%     allowed_keys = zeros(1,256);
%     allowed_keys([options.buttons.buttonEscape options.buttons.buttonSpace options.buttons.buttonRight...
%         options.buttons.buttonLeft options.buttons.buttonUp options.buttons.scannerR options.buttons.scannerG options.buttons.scannerB ...
%         options.buttons.scannerY options.buttons.scannerTrigger]) = 1;

    options.buttons.allowed_keys_dev = zeros(1,256);
    options.buttons.allowed_keys_dev([options.buttons.buttonY options.buttons.buttonN options.buttons.buttonF options.buttons.buttonR options.buttons.scannerR options.buttons.scannerG options.buttons.scannerB ...
        options.buttons.scannerY options.buttons.scannerTrigger options.buttons.buttonSpace options.buttons.buttonEscape]) = 1;
    
    options.buttons.allowed_keys_scanner = zeros(1,256);
    options.buttons.allowed_keys_scanner([options.buttons.buttonY options.buttons.buttonN options.buttons.buttonF options.buttons.buttonR options.buttons.scannerR options.buttons.scannerG options.buttons.scannerB ...
        options.buttons.scannerY options.buttons.scannerTrigger]) = 1;
elseif strcmp(options.expType,'MR') || strcmp(options.expType,'MR_Prac')
    %     options.dev_id = nums(strcmp(names,'SCANNER_STIM_PRES_KEYBOARD_NAME'));   % UPDATE W/ CORRECT NAMES
    %     options.scanner_id = nums(strcmp(names,'SCANNER_BUTTON_BOX_NAME'));
    
    % COMMENT OUT WHEN AT SCANNER
    if strcmp(options.compSetup,'CMRR') 
        options.dev_id = nums(strcmp(names,'Apple Keyboard'));   % Control keyboard
        options.scanner_id = nums(strcmp(names,'932'));   % Button box
%         options.scanner_id = nums(strcmp(names,'DVI DualView KVM'));   % Button box
    elseif strcmp(options.compSetup,'CMRR_Psychophysics')
        options.dev_id = nums(strcmp(names,'Dell USB Keyboard'));   % Stim comps
        options.dev_id2 = nums(strcmp(names,'DELL USB Keyboard'));   % Stim keyboard
        options.scanner_id = nums(strcmp(names,'Trainer (R1391)'));   % Button box
    else
        options.dev_id=nums(1);
        options.scanner_id=nums(1);
    end
    
    options.buttons.allowed_keys_dev = zeros(1,256);
    options.buttons.allowed_keys_dev([options.buttons.buttonY options.buttons.buttonN options.buttons.scannerR options.buttons.scannerG options.buttons.scannerB ...
        options.buttons.scannerY options.buttons.scannerTrigger options.buttons.buttonSpace options.buttons.buttonEscape]) = 1;
    
    options.buttons.allowed_keys_scanner = zeros(1,256);
    options.buttons.allowed_keys_scanner([options.buttons.scannerR options.buttons.scannerG options.buttons.scannerB ...
        options.buttons.scannerY options.buttons.scannerTrigger]) = 1;
    
%     KbQueueCreate(options.dev_id, options.buttons.allowed_keys_dev);
%     KbQueueStart(options.dev_id);
%     KbQueueFlush(options.dev_id);
%     
%     KbQueueCreate(options.scanner_id, options.buttons.allowed_keys_scanner);
%     KbQueueStart(options.scanner_id);
%     KbQueueFlush(options.scanner_id);
end

%% Computer specific setup options

if strcmp(options.compSetup,'vaEEG')
    
    %% VA EEG setup
    options.datadir = fullfile(options.expPath,'Data');   % Data directory 
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
    
    % Screen info
    options.screenNum = 2;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
    Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);
    
    % Throw error if monitor RR not at 120Hz
    if options.wInfoNew.hz ~= 120
        error('Monitor refresh rate not set to 120Hz. Exiting now.');
    end
    
    % PPD varialbes
    options.mon_width_cm = 53;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
    % Load in the monitor callibration file and CLUT (color look up table)
    [options.wInfoOrig.CLUT,~,~] = Screen('ReadNormalizedGammaTable',options.screenNum);
%     Screen('LoadNormalizedGammaTable',options.screenNum,repmat([0:1/255:1]',[1 3]),0);   % First load in a linear CLUT because we are superstitious
    % Will look in the functions folder for the mon cal file
%     load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
%     options.displayInfo = displayInfo;
%     Screen('LoadNormalizedGammaTable',options.screenNum,options.displayInfo.linearClut,0);

    % Set the gray value using the new CLUT
%     if ~isfield(options.displayInfo,'linearClut')
%         options.displayInfo.linearClut = 0:1/255:1;
%     end
    options.grayCol = 255*options.displayInfo.linearClut(round(options.grayCol)+1);
    options.fixCol = 255*options.displayInfo.linearClut(round(options.fixCol)+1);
    options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
    options.redCol =  255*options.displayInfo.linearClut(round(options.redCol)+1);
    options.blueCol  =  255*options.displayInfo.linearClut(round(options.blueCol)+1);
    options.greenCol =  255*options.displayInfo.linearClut(round(options.greenCol)+1);
    options.yellowCol  =  255*options.displayInfo.linearClut(round(options.yellowCol)+1);

    
elseif strcmp(options.compSetup,'CMRR')
    
    options.datadir = fullfile(options.expPath,'Data');   % Data directory 
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
    
    % Screen info
    options.screenNum = 0;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
    Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);
    
    % PPD varialbes
    options.mon_width_cm = 49.5;   % Width of the monitor (cm)
    options.mon_dist_cm = 102.2;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
    % Load in the monitor callibration file and CLUT (color look up table)
    [options.wInfoOrig.CLUT,~,~] = Screen('ReadNormalizedGammaTable',options.screenNum);
%     Screen('LoadNormalizedGammaTable',options.screenNum,repmat([0:1/255:1]',[1 3]),0);   % First load in a linear CLUT because we are superstitious
    % Will look in the functions folder for the mon cal file
%     load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
%     options.displayInfo = displayInfo;
%     Screen('LoadNormalizedGammaTable',options.screenNum,options.displayInfo.linearClut,0);

    % Set the gray value using the new CLUT
%     if ~isfield(options.displayInfo,'linearClut')
%         options.displayInfo.linearClut = 0:1/255:1;
%     end
    options.grayCol = 255*options.displayInfo.linearClut(round(options.grayCol)+1);
    options.fixCol = 255*options.displayInfo.linearClut(round(options.fixCol)+1);
    options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
    options.redCol =  255*options.displayInfo.linearClut(round(options.redCol)+1);
    options.blueCol  =  255*options.displayInfo.linearClut(round(options.blueCol)+1);
    options.greenCol =  255*options.displayInfo.linearClut(round(options.greenCol)+1);
    options.yellowCol  =  255*options.displayInfo.linearClut(round(options.yellowCol)+1);
    
elseif strcmp(options.compSetup,'CMRR_Psychophysics')
    
    options.datadir = fullfile(options.expPath,'Data');   % Data directory
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
    
    % Screen info
    options.screenNum = 1;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    %     options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.hz = 60;   % set manually, matlab 'Resolution' not finding it for some reason....
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
    Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);
    
    % PPD varialbes
    options.mon_width_cm = 53;   % Width of the monitor (cm)
    options.mon_dist_cm = 70;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
    % Load in the monitor callibration file and CLUT (color look up table)
    [options.wInfoOrig.CLUT,~,~] = Screen('ReadNormalizedGammaTable',options.screenNum);
    %     Screen('LoadNormalizedGammaTable',options.screenNum,repmat([0:1/255:1]',[1 3]),0);   % First load in a linear CLUT because we are superstitious
    % Will look in the functions folder for the mon cal file
    %     load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
    %     options.displayInfo = displayInfo;
    %     Screen('LoadNormalizedGammaTable',options.screenNum,options.displayInfo.linearClut,0);
    
    % Set the gray value using the new CLUT
    %     if ~isfield(options.displayInfo,'linearClut')
    %         options.displayInfo.linearClut = 0:1/255:1;
    %     end
    options.grayCol = 255*options.displayInfo.linearClut(round(options.grayCol)+1);
    options.fixCol = 255*options.displayInfo.linearClut(round(options.fixCol)+1);
    options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
    options.redCol =  255*options.displayInfo.linearClut(round(options.redCol)+1);
    options.blueCol  =  255*options.displayInfo.linearClut(round(options.blueCol)+1);
    options.greenCol =  255*options.displayInfo.linearClut(round(options.greenCol)+1);
    options.yellowCol  =  255*options.displayInfo.linearClut(round(options.yellowCol)+1);
    
elseif strcmp(options.compSetup,'vaCoglab')
    
    
    %% VA CogLab setup
    % UPDATE THIS AT VA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    options.datadir = fullfile(options.expPath,'Data');   % Data directory
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
    
    % Screen info
    options.screenNum = 0;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
    Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);
    
    % PPD varialbes
    options.mon_width_cm = 53;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
    % Load in the monitor callibration file and CLUT (color look up table)
    [options.wInfoOrig.CLUT,~,~] = Screen('ReadNormalizedGammaTable',options.screenNum);
    %     Screen('LoadNormalizedGammaTable',options.screenNum,repmat([0:1/255:1]',[1 3]),0);   % First load in a linear CLUT because we are superstitious
    % Will look in the functions folder for the mon cal file
    %     load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
    %     options.displayInfo = displayInfo;
    %     Screen('LoadNormalizedGammaTable',options.screenNum,options.displayInfo.linearClut,0);
    
    % Set the gray value using the new CLUT
    %     if ~isfield(options.displayInfo,'linearClut')
    %         options.displayInfo.linearClut = 0:1/255:1;
    %     end
    options.grayCol = 255*options.displayInfo.linearClut(round(options.grayCol)+1);
    options.fixCol = 255*options.displayInfo.linearClut(round(options.fixCol)+1);
    options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
    options.redCol =  255*options.displayInfo.linearClut(round(options.redCol)+1);
    options.blueCol  =  255*options.displayInfo.linearClut(round(options.blueCol)+1);
    options.greenCol =  255*options.displayInfo.linearClut(round(options.greenCol)+1);
    options.yellowCol  =  255*options.displayInfo.linearClut(round(options.yellowCol)+1);
    
elseif strcmp(options.compSetup,'arcEEG')
    
    %% ARC EEG setup
    options.datadir = sprintf('%s','D:/SchallmoLab/',options.expPath,'Data/');   % Data directory 
    [maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
    
    % Screen info
    options.screenNum = 0;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
    Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);
    
    % PPD varialbes
    options.mon_width_cm = 53;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
    % Load in the monitor callibration file and CLUT (color look up table)
    [options.wInfoOrig.CLUT,~,~] = Screen('ReadNormalizedGammaTable',options.screenNum);
    % Will look in the functions folder for the mon cal file
    %     load('Asus_VG248QE_EEGlab_lightsoff_20190613.mat','displayInfo');
    %     options.displayInfo = displayInfo;
    %     Screen('LoadNormalizedGammaTable',options.screenNum,options.displayInfo.linearClut,0);
    
    options.grayCol = 255*options.displayInfo.linearClut(round(options.grayCol)+1);
    options.fixCol = 255*options.displayInfo.linearClut(round(options.fixCol)+1);
    options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
    options.redCol =  255*options.displayInfo.linearClut(round(options.redCol)+1);
    options.blueCol  =  255*options.displayInfo.linearClut(round(options.blueCol)+1);
    options.greenCol =  255*options.displayInfo.linearClut(round(options.greenCol)+1);
    options.yellowCol  =  255*options.displayInfo.linearClut(round(options.yellowCol)+1);
    
elseif strcmp(options.compSetup,'labComp')
    
    %% Lab computer setup
    options.datadir = fullfile(options.expPath,'Data');   % Data directory  % mps 20190730
    Screen('Preference', 'SkipSyncTests', 1);   % Skip sync test w/ monitor
    
    % Screen info
    options.screenNum = 1;
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
%     Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);

    % PPD varialbes
    options.mon_width_cm = 28;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
elseif strcmp(options.compSetup,'myComp')
    
    %% My computer setup
    options.datadir = fullfile(options.expPath,'Data');   % Data directory  % mps 20190730
    Screen('Preference', 'SkipSyncTests', 1);   % Skip sync test w/ monitor
    
    % Screen info
    numScreens = Screen('Screens');
    if length(numScreens) == 3
        options.screenNum = 2;
    elseif length(numScreens) == 2
        options.screenNum = 1;
    end
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
%     Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);

    % PPD varialbes
    options.mon_width_cm = 28;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
elseif strcmp(options.compSetup,'MPSComp')
    
    %% MPS computer setup
    options.datadir = fullfile(options.expPath,'Data');   % Data directory  % mps 20190730
    Screen('Preference', 'SkipSyncTests', 1);   % Skip sync test w/ monitor
    
    % Screen info
%     numScreens = Screen('Screens');
%     if numScreens == 3
%         options.screenNum = 2;
%     elseif numScreens == 2
%         options.screenNum = 1;
%     end
    options.screenNum = max(Screen('Screens')); % mps 20200328
    options.wInfoOrig = Screen('Resolution',options.screenNum);
    options.wInfoNew.hz = options.wInfoOrig.hz;
    options.wInfoNew.width = options.wInfoOrig.width;
    options.wInfoNew.height = options.wInfoOrig.height;
%     Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);

    % PPD varialbes
    options.mon_width_cm = 28;   % Width of the monitor (cm)
    options.mon_dist_cm = 57;   % Viewing distance (cm)
    options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
    options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree
    
end

if isfield(options,'expType')
    options.datafile = sprintf('%s_%s_%s_%03d',options.subjID,options.expName,options.expType,options.runID);
else
    options.datafile = sprintf('%s_%s_%03d',options.subjID,options.expName,options.runID);
end

% check to see if this file exists
cd ../Data
fileCheckArray = dir;
cd ../Stim/
% if exist(fullfile(options.datadir,[options.datafile '.mat']),'file')
if any(strcmp({fileCheckArray(:).name}, sprintf('%s%s',options.datafile,'.mat')))
    tmpfile = input('File exists.  Overwrite? y/n:','s');
    while ~ismember(tmpfile,{'n' 'y'})
        tmpfile = input('Invalid choice. File exists.  Overwrite? y/n:','s');
    end
    if strcmp(tmpfile,'n')
        display('Bye-bye...');
        return; % will need to start over for new input
    end
end

%% Open window and set monitor specific variables
if strcmp(options.expName,'Object_Luminance_Task')
    [options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,options.fixCol,...
        [0 0 options.wInfoNew.width options.wInfoNew.height],[],[],[],8);
elseif strcmp(options.compSetup,'myComp')
    [options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,options.grayCol,...
        [],[],[],[],8);
else
    [options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,options.grayCol,...
        [0 0 options.wInfoNew.width options.wInfoNew.height],[],[],[],8);
end
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;

% Alpha blending
Screen('BlendFunction',options.windowNum, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % Must have for alpha values for some reason

% measure the frame rate
% Used to ensure very accurate stimulus onset and duration timing
options.frame_rate = Screen('FrameRate',options.windowNum); % in seconds.  this is what the operating system is set to, does not work on some systems (e.g., lcd or laptops)
options.flip_interval = Screen('GetFlipInterval',options.windowNum); % in seconds.  this is an actual measurement, should work on all systems
options.flip_interval_correction = options.flip_interval/4; % this should work even on laptops that don't return a FrameRate value

% Fixation variables
options.fix.fixSizeOuter = .6;  % In dova
options.fix.fixSizeInner = .2;
options.fix.fixRectX = options.fix.fixSizeOuter/2 * options.PPD;
options.fix.fixRectY = options.fix.fixSizeOuter/2 * options.PPD;
options.fix.fixCrossColor = options.whiteCol;
options.fix.fixInnerOvalColor = options.fixCol;
options.fix.fixOuterOvalColor = options.fixCol;
options.fix.fixColorBlink = options.fixCol;

if options.hideMouse==1
    HideCursor;   % Hide cursor
end
if options.silenceKeyboard==1
    ListenChar(2);   % Silence keyboard input
end

end