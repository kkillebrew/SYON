% Runs a resting state task.
% By default runs 3 runs of 45s for eyes open and eyes closed. Then quickly
% analyzes saved data.
% KWK - 20240327

function [data,options] = restingTask(options)

%% Initialize
curr_path = pwd;
match_folder_name = 'SYON.git';
path_idx = strfind(curr_path,match_folder_name);
if ~exist('options','var') % parameters
    options = [];
end
if ~isfield(options,'restingOnly')
    options.restingOnly = 0;
end
if options.restingOnly == 0
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
    if ~isfield(options,'eegRecording')
        options.eegRecording = 1;
    end
    if ~isfield(options,'photodiodeTesting')
        options.photodiodeTesting = 0;
    end
    if ~isfield(options,'signalPhotodiode')
        options.signalPhotodiode = 1;
    end
    if ~isfield(options,'screenShot')
        options.screenShot = 0;
    end
    if ~isfield(options,'eyeTracking')
        options.eyeTracking = 0;
    end
    if ~isfield(options,'analysisCheck')
        options.analysisCheck = 0;
    end
    if ~isfield(options,'numBlocks')
        options.numBlocks = 3;
    end
    if ~isfield(options,'eyeOpenClose')
        options.eyeOpenClose = [1 2];   % 1 = eyes open; 2 = eyes closed
    end
    if ~isfield(options,'optionsString')
        % Open dialog box for easier user input
        % Since they're running this script, we'll set some default params
        optionsString = 'vaEEG';
        
        [optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options);
        % optionsString = 'myComp';
        % subjid = 'test';
        % runid = 1;
    else
        optionsString = options.optionsString;
        subjid = options.subjid;
        runid = options.runid;
    end
    
    options.compSetup = optionsString;
    options.expName = 'RestingEEG';
    % options.expType = 'MR_Prac';   % For use in localOptions to look for scanner keyboardfff
    options.expPath = fullfile(options.root_path,'/Bistable_Tasks/BinoRiv_Task/EEG_Task/');   % Path specific to the experiment % mps 20190730
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
    
    options = localOptions(options);
    
    % Initialize the triggers
    if options.eegRecording == 1
        config_io;
    end
end

%% Trial parameters
options.runLength = 45;

% Both set at top of code now
% Number of 45 s blocks
% options.numBlocks = 3;
% Eyes open / closed condition
% options.eyeOpenClose = [1 2];   % 1 = eyes open; 2 = eyes closed

% Total number of screen flips
options.numFlips = options.wInfoNew.hz*options.runLength;

% Rawdata values
data.rawdata = repmat(options.eyeOpenClose,[1 options.numBlocks]);

% Timing parameters
% Timing of screen flip relative to exp start
options.time.flipTimes = repmat(1/options.wInfoNew.hz:1/options.wInfoNew.hz:options.runLength,[options.numBlocks*length(options.eyeOpenClose) 1]);

%% Stimulus parameters
% Make fixation points
options.blackFixation = do_fixation(options);
options.fixationRect = [options.xc - options.fix.fixSizeOuter/2*options.PPD,...
    options.yc - options.fix.fixSizeOuter/2*options.PPD,...
    options.xc + options.fix.fixSizeOuter/2*options.PPD,...
    options.yc + options.fix.fixSizeOuter/2*options.PPD];
options.blinkFixation = do_fixation_blink(options);

if options.restingOnly == 0
    % Set the port adress
    if options.eegRecording == 1
        options.addressOut = hex2dec('A010');
        options.addressIn = hex2dec('C010'); % may need to be C000, was "status" channels in Presentation, 4-bit
        object=io64;
        status=io64(object);
    end
end

%% Start the experiment
% Instructions/Start screen
if options.restingOnly == 0
    % Last instructions before the experiment starts
    text1='Every 45s you will hear a beep followed by instructions to either open or close your eyes.';
    text2='When your eyes are open, you will see a blank screen with a small dot in the center.';
    text3='Keep your eyes fixed on the center dot.';
    text4='This will happen a total of 6 times. Please start with your eyes open.';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
    DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.whiteCol);
    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
    Screen('Flip',options.windowNum);
    
    while 1
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonF)
            break
        end
    end
    WaitSecs(1);
    
    % Start EEG recording screen
    text1='Experimenter please start new resting EEG recording (Name: SUBJID_RestingEEG).';
    text2='Turn volume up!';
    text3='LAST SCREEN BEFORE EXPERIMENT START!';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
    Screen('Flip',options.windowNum);
    
    fprintf('%s%s%s%s\n','EEG Filename: ',options.subjid,'_',options.expName)
    fprintf('%s\n','Turn up volume!')
    
    while 1
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonF)
            break
        end
    end
    WaitSecs(1);
end

if options.restingOnly == 1
    % Last instructions before the experiment starts
    text1='You will hear a beep followed by instructions to close your eyes.';
    text2='You will keep your eyes closed for 45s after hearing the beep.';
    text3='Let the experimenter know when you are ready.';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
    Screen('Flip',options.windowNum);
    
    while 1
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonF)
            break
        end
    end
end

% Start the task
if options.restingOnly==0
    blockStartTriggers = [11 21 12 22 13 23];
elseif options.restingOnly==1
    blockStartTriggers = [21];
end
for iBlock = 1:length(data.rawdata)
    % Display 'Open Eyes' or 'Close Eyes' for first 3 seconds
    if data.rawdata(iBlock) == 1
        text1='EYES OPEN.';
    elseif data.rawdata(iBlock) == 2
        text1='EYES CLOSED.';
    end
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
    Screen('Flip',options.windowNum);
    WaitSecs(3);
    
    % Play the tone for 2s
    Beeper(400,'med',2);
    
    % Send a trigger at the beginning of each block
    if options.eegRecording == 1
        default = blockStartTriggers(iBlock);
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
    
    options.time.sync_time(iBlock) = Screen('Flip',options.windowNum);
    for n=1:options.numFlips
        
        [~,~,keycode,~] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            break
        end
                
        Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
        
        % Present white square for photodiode
        % Always present the white square for photodiode timing
        % measurements
        if options.photodiodeTesting == 1 || options.signalPhotodiode == 1
            if n == 1
            Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-80 (options.yc*2)-80 (options.xc*2)-40 (options.yc*2)-40]);
            %                 Screen('FillRect',options.windowNum,[255 255 255],[(options.xc*2)-40 (options.yc)-20 (options.xc*2) (options.yc*2)-100]);
            end
        end
        
        [~, options.time.flipTimesActual(iBlock,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
            (options.time.sync_time(iBlock)+options.time.flipTimes(iBlock,n))-options.flip_interval_correction);
    end
    
    % SET PRIO TO NORMAL
    if options.eegRecording == 1
        Priority(0);
    end
    
    if options.restingOnly == 0
        cleanUp(options,data,1);
    end
    
end

% End screen 
% Play the tone for 2s at very end to let them know to open eyes
Beeper(400,'med',2);
if options.restingOnly == 0
    
    % Stop recording
    [~,~,keycode,~] = KbCheck(options.dev_id);
    while ~keycode(options.buttons.buttonF) && ~keycode(options.buttons.buttonEscape)
        [~,~,keycode,~] = KbCheck(options.dev_id);
        text1 = 'Experimenter please stop recording and save file!';
        text2 = 'Press any key when file has been saved.';
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

%% Run the FFT on the resting data to get IPAF
if options.analysisCheck == 1 && options.restingOnly == 0
    fprintf('%s\n','Calculating IPAF...');
    
    % First search for resting EEG file that should have just been saved
    options.restEEGPath = ['Z:\data_staging\SYON_EEG\' options.subjid '\'];
    
    % Add FFT analysis path
    ftPath = 'C:\Users\EEG Task Computer\Desktop\SYON.git\Bistable_Tasks\BinoRiv_Task\EEG_Task\Data';
    addpath(ftPath)

    dispWarning = 1;
    while 1
        if isfile([options.restEEGPath options.subjid '_RestingEEG.bdf'])
            break
        else
            if dispWarning == 1
                warning('No resting EEG file found. Please save EEG file to ''Z:\data_staging\SYON_EEG\SXXXXXXX\SXXXXXXX_RestingEEG.bdf''')
                dispWarning = 0;
            end
        end
    end
    
    % Run resting FFT analysis
    [data.IPAF] = restingFFTAnalysis(options);    
end


end