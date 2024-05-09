function [time_elapsed] = mps_PupilSize(subj,dummymode,roomNo)
% Created: mps 2015/07/10
%
% Usage - takes two arguments, subj = ID# of subject, inputs as a string
% dummymode = 0 to use the Eyelink, 1 to run without

%% Randomize conditions, do 10 trials at a time for each ...
%Screen('Preference', 'SkipSyncTests', 1);
%dataDir = 'C:\Users\Michael-Paul\Documents\MurrayLab\Autism\data';
%dataDir = 'C:\Documents and Settings\Psychophysics\Desktop\MichaelPaul\ASD\data';
dataDir = 'C:\MurrayLab\GABA\PupilSize\data';

Screen('Closeall'); % make sure no screens are open, could mess up the Hz measurement

% displayName = 'mpsLivingRoom_lightson_20130605'; % home
% displayName = 'ViewSonicVX924_UWroom75_lightson_20150320'; % my office
% displayName = 'ViewSonic_G90fB_CRT_27Jan15_simpleGamma_2p4161'; % use a simple gamma 
displayName = 'ViewSonic_PF790_CRT_Bits#_autoPlusPlus_lightsoff_20150526';

% calDir = 'C:\Documents and Settings\Psychophysics\Desktop\MichaelPaul\monitorCal';
% screenNumber = max(Screen('Screens')); % 2 for running on a Windows machine
% viewingDistance = 52; % cm
% screenSize = [35.8775 26.9875];

calDir = 'C:\MurrayLab\monitorCal';
screenNumber = 0; % max(Screen('Screens')); % 2 for running on a Windows machine
viewingDistance = 66; % was 52 in room 78; % cm
screenSize = [42 34]; % was [35.8775 26.9875];

addpath(genpath('C:\MurrayLab\palamedes1_7_0\Palamedes'))

b1 = 'LeftArrow'; % 'LeftArrow' on Mac, 'left' elsewhere
b2 = 'RightArrow'; % 'RightArrow' on Mac 
escKey = 'ESCAPE'; % 'ESCAPE' on Mac, 'esc' for others
pauseKey = 'space';
pracKey = 'Home';
textFontSize = 16;
textFontColor = [0 0 0];


if ~exist('subj','var'); subj = input('Please enter subject ID:  ','s'); end
%if ~exist('longInstructions','var'); longInstructions = input('Enter 1 to run through practice trials, 0 to skip practice trials:  '); end
if ~exist('dummymode','var'); dummymode = 0; % use this for running without a subject...
end
if ~exist('roomNo','var'); roomNo = input('Please enter room #: ','s'); % use this for running without a subject...
end

% Timing and staircase parameters
nRuns = 4; % # of times to go through
nTrialsEach = 10; % per run

%% Stimulus parameters

eccentricity = 0; % degrees from center, on horizontal meridian, not using this...

diskRadius = [6]; % degrees

stimDuration = 1; % sec

% whiteLum = 200;% cd/m2 these are the values I got from Maria...
% blackLum = 1;
% bgLum = 53;
whiteColor = 255;% index in CLUT, just use max, min, mean
blackColor = 0;
backgroundColor = 128;

setHz = 120; % check monitor later
%% Open screen and leave it open ...

% First, find out how big the monitor is and how far away it is, so we 
whiteLum = 106; % cd/m2
blackLum = 0.01; % probably better to report < 0.1
bgLum = 53;
% these data are stored in displayInfo.luminance, and reflect PR650
% measurements from calibration on 05/26/15

fixSize=10;

fixColor = [255 255 255]; % Fixation mark, 
%sounds for stim presentation and feedback
twit = sin(1:3:200); rightRate = 6000; stimRate = 5000; wrongRate = 4000;

% PsychImaging('PrepareConfiguration'); 

[w,rect] = Screen('OpenWindow',screenNumber,backgroundColor,[],[],2,0);
Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255,0);

%%These 2 lines are for working on the psychophysics iMac in Elliott
%%can make some stimuli.  And open it up and get the number of pixels.
%%Use this with a Bits++ box
% [w,rect] = BitsPlusPlus('OpenWindowBits++',screenNumber);
% BitsPlusPlus('LoadIdentityClut',w);
%%While we're at it, set clutScale to 2, since we'll be working w/ low
%%contrast gratings, and set the look-up table w/ the right resolution.
clutScale = 0; % leave this in here for now in case we ever go back to a machine with Bits++
% displayInfo = caoBitsPlusMakeClut(displayInfo,clutScale);
scaleLuminance = 128;

load(fullfile(calDir,displayName))
screenSubtent = 2*atand([screenSize(1)/2 screenSize(2)/2]/viewingDistance);
pixelsPerDegree = mean(rect(3:4)./screenSubtent); % really should check to see if they're too much different
Screen('LoadNormalizedGammaTable',w,displayInfo.linearClut,0);
Screen('FillRect',w,backgroundColor);
Screen('Flip',w);
HideCursor

% and figure out where fixation is
fixRect = CenterRect([0 0 fixSize fixSize],rect);
%% make stimuli

     hz = FrameRate(w);
    if round(hz) ~= setHz
        error(['Wrong monitor referesh rate, should be ' num2str(setHz) '!'])
    end
    
    displayInfo.frameDuration = 1/hz;
    adjustFlip = displayInfo.frameDuration/2;
    
        imgSize = round(pixelsPerDegree*13);
    [x y] = meshgrid(1:imgSize,1:imgSize);
    x = (x-imgSize/2)/pixelsPerDegree;
    y = (y-imgSize/2)/pixelsPerDegree;
    
    stim = double(sqrt(x.^2 + y.^2) < diskRadius);

% and go back and figure out where to put the 2 stimuli
% find the center of the screen ...
stimRect = CenterRect([0 0 imgSize imgSize],rect);


%% Set up eye tracking...

    instructions = {'Now we are going to calibrate',...
        'and test the eye tracking camera.', ...
        'Please keep your head still',...
        'on the chin rest from now on.', ...
        'A small dot will appear on the screen,',...
        'please keep your eyes focused on it.', ...
        '', ...
        'Press Enter to continue.'};
    
    try
        %Screen('DrawTexture',w,stim_idx);
        Screen('FillRect',w,fixColor,fixRect);
        %screenCenter = centerRect([0 0 1 1],rect);
        for iT = 1:length(instructions)
            Screen('DrawText',w,instructions{iT},100,50+50*iT);
        end
        
        %text = ['Run ' num2str(iRun) ' of ' num2str(nRuns) '. Press any key when ready.'];
        %text = (['Pedestal = ' num2str(pedestalContrast(1)) '. Press any key when ready.']);
        
        %Screen('DrawText',w,text,screenCenter(3)-100,screenCenter(4),[0 0 0]);
        %disp(['Using linear clut from ' displayName ])
        %Screen('LoadNormalizedGammaTable', w, displayInfo.linearClut);
        Screen('Flip',w);
        keyIsDown = 0;
        while ~keyIsDown
            [keyIsDown secs keyCode]= KbCheck(-1);  %% wait for subject ready
            if strcmp(escKey,KbName(keyCode));
                Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255);
                Screen('Flip',w);
                WaitSecs(.03)
                Screen('CloseAll');
                return
            end
        end
        Screen('FillRect',w,backgroundColor);
        Screen('FillRect',w,255,fixRect);
        Screen('Flip',w);
    catch
        Screen('closeall')
        error('Couldn''t run intro to eye tracker!');
    end
    
    %close(stim_idx);
    WaitSecs(1);


% STEP 2
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(w);
% Disable key output to Matlab w:
%ListenChar(2);

el.calibrationfailedsound = 1;				% no sounds indicating success of calibration
el.calibrationsuccesssound = 1;

el.helptext='Press RETURN to toggle camera image';
el.helptext=[el.helptext '\n' 'Press C to Calibrate'];
el.helptext=[el.helptext '\n' 'Press V to Validate'];
el.helptext=[el.helptext '\n' 'Press D to Drift Correct only'];
el.helptext=[el.helptext '\n' 'Press A to Auto-adjust levels'];
el.helptext=[el.helptext '\n' ''];
el.helptext=[el.helptext '\n' 'Press ESC to exit and begin experiment'];

EyelinkUpdateDefaults(el);

% STEP 3
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
%    cleanup;  % cleanup function
    
    Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255);
    Screen('Flip',w);
    WaitSecs(.03)
    Screen('CloseAll');
    return;
end

[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
el_folder = 'C:\MurrayLab\GABA\PupilSize\data\eyetracking';
el_files = dir(fullfile(el_folder,[subj 'p*']));
edfFile=[subj 'p' num2str(length(el_files)+1) '.edf'];
Eyelink('Openfile', edfFile);

% whileCorrection = 1;
% while whileCorrection
%     doEyetrackCorrection = input('Press 1 to calibrate eye tracker (first run), 2 for drift correction (later runs), or 0 to skip: ');
%     if doEyetrackCorrection == 1
%         % STEP 4
%         % Calibrate the eye tracker
         EyelinkDoTrackerSetup(el);
%         whileCorrection = 0;
%     elseif doEyetrackCorrection == 2
%         % do a final check of calibration using driftcorrection
%         EyelinkDoDriftCorrection(el);
%         whileCorrection = 0;
%     elseif doEyetrackCorrection == 0
%         whileCorrection = 0;
%     end
% end

% STEP 5
% start recording eye position
%     Eyelink('StartRecording');
%     % record a few samples before we actually start displaying
%     WaitSecs(0.1);
%     % mark zero-plot time in data file
%     Eyelink('Message', 'SYNCTIME');
%     stopkey=KbName('space');
%     eye_used = -1;

imageList = {'StimScreenShot.bmp'};
imgfile= char(imageList(1));

[width, height]=Screen('WindowSize', screenNumber);

Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
% set calibration type.
Eyelink('command', 'calibration_type = HV9');
% set parser (conservative saccade thresholds)

if v == 2
    Eyelink('command', 'select_parser_configuration 0');
    Eyelink('command', 'scene_camera_gazemap = NO');
else if v > 2
        Eyelink('command', 'select_parser_configuration 0');
    else
        Eyelink('command', 'saccade_velocity_threshold = 35');
        Eyelink('command', 'saccade_acceleration_threshold = 9500');
    end
end

Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');



Eyelink('Command', 'set_idle_mode');
% clear tracker display and draw box at center
Eyelink('Command', 'clear_screen 0')
Eyelink('command', 'draw_box %d %d %d %d 15', round(width/2-fixSize/2), round(height/2-fixSize/2), round(width/2+fixSize/2), round(height/2+fixSize/2)); % draw a box for the fixation mark on the host PC

Eyelink('command', 'draw_box %d %d %d %d 15', round(width/2-pixelsPerDegree*diskRadius(1)), round(height/2-pixelsPerDegree*diskRadius(1)), round(width/2+pixelsPerDegree*diskRadius(1)), round(height/2+pixelsPerDegree*diskRadius(1)));

%transfer image to host
%         transferimginfo=imfinfo(imgfile);
%
%         % image file should be 24bit or 32bit bitmap
%         % parameters of ImageTransfer:
%         % imagePath, xPosition, yPosition, width, height, trackerXPosition, trackerYPosition, xferoptions
%         transferStatus =  Eyelink('ImageTransfer',transferimginfo.Filename,0,0,transferimginfo.Width,transferimginfo.Height,round(width/2-transferimginfo.Width/2),round(height/2-transferimginfo.Height/2),4);
%          if transferStatus ~= 0
%             fprintf('Transfer image to host failed\n');
%          end


%% Now start looping  - task


for runNo = 1:nRuns
    if runNo > 1
        WaitSecs(0.1);
        Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
        Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
        WaitSecs(0.05);
        
        EyelinkDoTrackerSetup(el);
        WaitSecs(0.05);
    end
    
            Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording');
        % record a few samples before we actually start displaying
        % otherwise you may lose a few msec of data
        WaitSecs(1.1);
    
    instructions = {['Run ' num2str(runNo) ' of ' num2str(nRuns) '.'],...
        'Now you will see a flashing circle', ...
        'It will change from black to white many times.', ...
        'It is important for you to keep your eyes still.', ...
        'Please keep your eyes at the center of the screen.', ...
        'Press Enter to continue.'};

    Screen('TextSize',w,textFontSize);
    Screen('TextColor',w,textFontColor);
    for iT = 1:length(instructions)
        Screen('DrawText',w,instructions{iT},100,50+50*iT);
    end
    Screen('FillRect',w,fixColor,fixRect); % put up fixation mark

    Screen('Flip',w);
    pause(0.2);
    keyIsDown = 0;
    while ~keyIsDown
        [keyIsDown keyTime keyCode] = KbCheck;
        response = KbName(keyCode);
        if strcmp(response,escKey);  % cancels psychophysics 
            disp('We are interrupting early.');
            Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255,2);
            Screen('Flip',w);
            pause(0.3);
            Screen('Closeall');
            mpsCloseEL(edfFile,el_folder);
            return;end
    end
    
        useColors = [blackColor whiteColor];
        nextFlip = GetSecs + stimDuration;
        
        for iTrial = 1:nTrialsEach+1 % do an extra 1/2 for black
            
            clear draw_stim
            
            if iTrial < 11
                useStim = [1 2];
            else useStim = 1;
            end
            
            for iStim = useStim % black then white, end on black
                
                stimColor = useColors(iStim) - 128;
                draw_stim = Screen('MakeTexture',w,stim.*stimColor + backgroundColor);
                
                et_message = ['Run' num2str(runNo) 'Trial' num2str(iTrial) '_Stim' num2str(iStim) '_on'];

                Screen('DrawTexture',w,draw_stim,[],stimRect);
                Screen('FillRect',w,backgroundColor,fixRect); % put up fixation mark
                thisFlip = Screen('Flip',w,nextFlip - adjustFlip);
                tic
                Eyelink('Message', et_message);

                time_elapsed(runNo,iTrial,iStim) = toc;
                nextFlip = thisFlip + stimDuration;
                
                [keyIsDown keyTime keyCode] = KbCheck;
                response = KbName(keyCode);
                if strcmp(response,escKey);  % cancels psychophysics
                    disp('We are interrupting early.');
                    Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255,2);
                    Screen('Flip',w);
                    pause(0.3);
                    Screen('Closeall');
                    mpsCloseEL(edfFile,el_folder);
                    return;end
                
                Screen('Close',draw_stim)
            end
            
    end   % trial loop
    et_message = ['Room # = ' roomNo];
    Eyelink('Message', et_message);
    
            WaitSecs(0.1);
        % stop the recording of eye-movements for the current trial
        Eyelink('StopRecording');
        
end % run loop
%% let's leave the screen and bits++ in a nice state: linearize it all -
Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./256,2);
Screen('Flip',w);
pause(.03);
Screen('Closeall');

%% close eyetracker
mpsCloseEL(edfFile,el_folder);
end
%%
function mpsCloseEL(edfFile,el_folder);

% STEP 7
% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
%Eyelink('StopRecording');
Eyelink('CloseFile');
% download data file
try
    fprintf('Receiving data file ''%s''\n', edfFile );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        movefile(edfFile,el_folder)
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, el_folder );
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', edfFile );
    rdf;
end

% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
end