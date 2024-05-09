function eyelink_code_for_kyle

%% open screen
Screen('Preference', 'SkipSyncTests', 1);
screenNumber = max(Screen('Screens'));
backgroundColor = 127.5;
[w, rect] = Screen('OpenWindow', screenNumber, backgroundColor);
Screen('LoadNormalizedGammaTable', w, (0:255)'*ones(1,3)./255,0);
Screen('FillRect',w,backgroundColor);
Screen('Flip',w);

fixSize=10;
fixColor = [255 255 255]; % Fixation mark, 
fixRect = CenterRect([0 0 fixSize fixSize],rect);

imgSize = 200; % pixels
stimRect = CenterRect([0 0 imgSize imgSize],rect);

blankDur = 1; % sec
stimDur = 4; % sec
escKey = 'esc'; % 'ESCAPE' on Mac, 'esc' for others
%% Set up eye tracking...
instructions = {'Now we are going to calibrate',...
    'and test the eye tracking camera.', ...
    'Please keep your head still',...
    'on the chin rest from now on.', ...
    'A small dot will appear on the screen,',...
    'please keep your eyes focused on it.', ...
    '', ...
    'Press Enter to continue.'};

Screen('FillRect',w,fixColor,fixRect);
for iT = 1:length(instructions)
    Screen('DrawText',w,instructions{iT},100,50+50*iT);
end
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
Screen('FillRect',w,fixColor,fixRect);
Screen('Flip',w);

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

[v, vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
el_folder = 'PATH TO YOUR DATA!!!';
el_files = dir(fullfile(el_folder,[subj '*.edf'])); % check for previous files
edfFile=[subj num2str(length(el_files)+1) '.edf']; % add this file, increment the numbering
Eyelink('Openfile', edfFile);


% STEP 4
% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);


% STEP 5
% get ready to record

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
% clear tracker display
Eyelink('Command', 'clear_screen 0')

% draw a box on the eye tracker screen for the fixation mark
Eyelink('command', 'draw_box %d %d %d %d 15', round(width/2-fixSize/2), round(height/2-fixSize/2), round(width/2+fixSize/2), round(height/2+fixSize/2)); % draw a box for the fixation mark on the host PC

% draw a box on the eye tracker screen for the stimulus position
Eyelink('command', 'draw_box %d %d %d %d 15', round(width/2-imgSize/2), round(height/2-imgSize/2), round(width/2+imgSize/2), round(height/2+imgSize/2));

%% start recording
iTrial = 1;
% make the stimulus
stim = repmat(255, [imgSize imgSize]);
draw_stim = Screen('MakeTexture',w,stim);


Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
WaitSecs(1.1);

% put up a blank screen and record time
Screen('PutImage', w, backgroundColor ,stimRect);
Screen('FillRect',w,fixColor,fixRect);

thisFlip = Screen('Flip',w);
nextFlip = thisFlip + blankDur;

% put up the stimulus
Screen('DrawTexture',w,draw_stim,[],stimRect);
thisFlip = Screen('Flip',w,nextFlip);

et_message = ['Stim' num2str(iTrial) '_on'];
Eyelink('Message', et_message);

nextFlip = thisFlip + stimDur;

% look for a key press, if you get one, quit early
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
        return;
    end
end

% put back up the blank screen
Screen('PutImage', w, backgroundColor ,stimRect);
thisFlip = Screen('Flip',w,nextFlip);

et_message = ['Stim' num2str(iTrial) '_off'];
Eyelink('Message', et_message);


% after all stimuli have been presented...
WaitSecs(0.1);
% stop the recording of eye-movements
Eyelink('StopRecording');

%% close eyetracker
mpsCloseEL(edfFile,el_folder);

end

%% separate function to close eye tracker
function mpsCloseEL(edfFile,el_folder)

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