% Starts eyetracking for the eyelink at the CMRR.
% KWK - 20201015

function [options] = setupCMRREyeTracking(options)

[maxStddev, minSamples, maxDeviation, maxDuration] =...
        Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor

% Open new window
[options.windowNum, options.rect] = Screen('OpenWindow',1);   % Specifcally for use @ cmrr psychophysics
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;
options.fixCol = [0 0 0];
options.whiteCol = [255 255 255];
options.grayCol = [127 127 127];
options.buttons.buttonEscape = KbName('escape');
options.fixSize = 3;

%STEP 1
% Initialize 
instructions = {'Now we are going to calibrate',...
    'and test the eye tracking camera.', ...
    'Please keep your head still',...
    'on the chin rest from now on.', ...
    'A small dot will appear on the screen,',...
    'please keep your eyes focused on it.', ...
    '', ...
    'Press Enter to continue.'};

% try
    %Screen('DrawTexture',w,stim_idx);
    Screen('FillRect',options.windowNum,options.fixCol,[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]);
    %screenCenter = centerRect([0 0 1 1],rect);
    for iT = 1:length(instructions)
        Screen('DrawText',options.windowNum,instructions{iT},100,50+50*iT);
    end
    
    %text = ['Run ' num2str(iRun) ' of ' num2str(nRuns) '. Press any key when ready.'];
    %text = (['Pedestal = ' num2str(pedestalContrast(1)) '. Press any key when ready.']);
    
    %Screen('DrawText',w,text,screenCenter(3)-100,screenCenter(4),[0 0 0]);
    %disp(['Using linear clut from ' displayName ])
    %Screen('LoadNormalizedGammaTable', w, displayInfo.linearClut);
    Screen('Flip',options.windowNum);
    keyIsDown = 0;
    while ~keyIsDown
        [keyIsDown, ~, keyCode]= KbCheck(-1);  %% wait for subject ready
        if keyCode(options.buttons.buttonEscape)
%             Screen('LoadNormalizedGammaTable', options.windowNum, (0:255)'*ones(1,3)./255);
%             Screen('Flip',options.windowNum);
%             WaitSecs(.03)
%             Screen('CloseAll');
            return
        end
    end
    Screen('FillRect',options.windowNum,options.grayCol);
    Screen('FillRect',options.windowNum,options.whiteCol,[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]);
    Screen('Flip',options.windowNum);
% catch
%     Screen('closeall')
%     error('Couldn''t run intro to eye tracker!');
% end

%close(stim_idx);
WaitSecs(1);


% STEP 2
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
options.el=EyelinkInitDefaults(options.windowNum);
% Disable key output to Matlab w:
%ListenChar(2);

options.el.calibrationfailedsound = 1;				% no sounds indicating success of calibration
options.el.calibrationsuccesssound = 1;

options.el.helptext='Press RETURN to toggle camera image';
options.el.helptext=[options.el.helptext '\n' 'Press C to Calibrate'];
options.el.helptext=[options.el.helptext '\n' 'Press V to Validate'];
options.el.helptext=[options.el.helptext '\n' 'Press D to Drift Correct only'];
options.el.helptext=[options.el.helptext '\n' 'Press A to Auto-adjust levels'];
options.el.helptext=[options.el.helptext '\n' ''];
options.el.helptext=[options.el.helptext '\n' 'Press ESC to exit and begin experiment'];

EyelinkUpdateDefaults(options.el);


% STEP 3
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if ~EyelinkInit(0, 1)
    fprintf('Eyelink Init aborted.\n');
%    cleanup;  % cleanup function
    
%     Screen('LoadNormalizedGammaTable', options.windowNum, (0:255)'*ones(1,3)./255);
    Screen('Flip',options.windowNum);
    WaitSecs(.03)
%     Screen('CloseAll');
    return;
end

[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
options.el_folder = options.eyeTrackingPath;   %%%%%%%%%%%% UPDATE FOR CMRR
options.el_files = dir(fullfile(options.el_folder,options.el_datafile));
options.edfFile=[options.el_datafile '.edf'];
Eyelink('Openfile', datestr(now,'mmddyy'));

% whileCorrection = 1;
% while whileCorrection
%     doEyetrackCorrection = input('Press 1 to calibrate eye tracker (first run), 2 for drift correction (later runs), or 0 to skip: ');
%     if doEyetrackCorrection == 1
%         % STEP 4
%         % Calibrate the eye tracker
         EyelinkDoTrackerSetup(options.el);
%         whileCorrection = 0;
%     elseif doEyetrackCorrection == 2
%         % do a final check of calibration using driftcorrection
%         EyelinkDoDriftCorrection(options.el);
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

% [options.rect(3), options.rect(4)]=Screen('WindowSize', screenNumber);

Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, options.rect(3)-1, options.rect(4)-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, options.rect(3)-1, options.rect(4)-1);
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

% NEEDS X1Y1 X2Y2 OF FIXATION SQUARE
% Eyelink('command', 'draw_box %d %d %d %d 15', round(options.rect(3)/2-[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]/2),...
%     round(options.rect(4)/2-[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]/2),...
%     round(options.rect(3)/2+[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]/2),...
%     round(options.rect(4)/2+[options.xc-options.fixSize options.yc-options.fixSize options.xc+options.fixSize options.yc+options.fixSize]/2)); % draw a box for the fixation mark on the host PC

% NEEDS X1Y1 X2Y2 OF STIMULI
% Eyelink('command', 'draw_box %d %d %d %d 15', round(options.rect(3)/2-pixelsPerDegree*diskRadius(1)), round(options.rect(4)/2-pixelsPerDegree*diskRadius(1)), round(options.rect(3)/2+pixelsPerDegree*diskRadius(1)), round(options.rect(4)/2+pixelsPerDegree*diskRadius(1)));


Screen('CloseAll');





end