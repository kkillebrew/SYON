% Present instructions, examples, and practice trials for the illusory size experiment.
%
% KWK - 20200811

function [options,data] = IllContExp_EEGPrac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;
pracTrialSwitch = 1;   % Switch for the practice trial walk through
pracTrialsBreak = 0;   % If esc during prac trials quit

% Set up practice
options.practice.numPracTrials = 5;
data.practice.rawdataPracticeEEG = zeros([options.practice.practiceRepetitions,7]);
data.practice.rawdataPracticeEEG(:,1) = 1:options.practice.practiceRepetitions;   % Trial num
data.practice.rawdataPracticeEEG(:,2) = randperm(options.practice.practiceRepetitions);
data.practice.rawdataPracticeEEG(:,3:4) = repmat(fullfact([2 2]),[options.practice.practiceRepetitions/4,1]);   % Background/distance
data.practice.rawdataPracticeEEG(:,5) =  repmat(fullfact([2]),[options.practice.practiceRepetitions/2,1]);   % Phase
data.practice.rawdataPracticeEEG(randperm(options.practice.practiceRepetitions,options.practice.numPracTrials),6) = 2;   % Task
data.practice.rawdataPracticeEEG(data.practice.rawdataPracticeEEG(:,6)==0,6) = 1;   % Task

options.practice.practiceBreak = 0;

% First present instructions
while 1
    switch instSwitch
        
        case 1
            %% First instructions screen - close background
            text1 = 'Here, you will see balls presented in a hallway.';
            text2 = 'Some will appear close.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,1,1},[],options.textureCoords);
            Screen('Flip',options.windowNum);
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
        case 2
            %% Far background
            text1 = 'Some will appear far.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,2,1},[],options.textureCoords);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
        case 3
            
            %% Close no background
            text1 = 'Sometimes the balls will appear with no background.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,1,1},[],options.textureCoords);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
        case 4
            
            %% Far no background
            text1 = 'These will appear above and to the right or below and to the left of the center dot.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,2,1},[],options.textureCoords);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if keycode(options.buttons.buttonF)
                    instSwitch = 5;
                    break
                elseif buttonsHolder(2) == 1
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
        case 5
            
            %% Example task stim
            WaitSecs(.5);
            text1='Your task is to press the left mouse button each time you see';
            text2='a black square appear behind the center dot.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400,[0 0 0]);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,1,2},[],options.textureCoords);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            startTime = GetSecs;
            whatImage = 2;
            while 1
                
                timeNow = GetSecs;
                imSwitch = timeNow-startTime > 1;
                switch imSwitch
                    case 1
                        switch whatImage
                            case 1
                                Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,1,2},[],options.textureCoords);
                                whatImage = 2;
                            case 2
                                Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,1,1},[],options.textureCoords);
                                whatImage = 3;
                            case 3
                                Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,2,2},[],options.textureCoords);
                                whatImage = 4;
                            case 4
                                Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,2,1},[],options.textureCoords);
                                whatImage = 5;
                            case 5
                                Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,1,2},[],options.textureCoords);
                                whatImage = 6;
                            case 6
                                Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,1,1},[],options.textureCoords);
                                whatImage = 7;
                            case 7
                                Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,2,2},[],options.textureCoords);
                                whatImage = 8;
                            case 8
                                Screen('DrawTexture',options.windowNum,options.circTextures{2,1,1,2,1},[],options.textureCoords);
                                whatImage = 1;
                            otherwise
                        end
                        
                        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                        DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400,[0 0 0]);
                        Screen('Flip',options.windowNum);
                        
                        startTime = GetSecs;
                        
                    otherwise
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
        case 6
            
            %% Show example trial
            
            switch pracTrialSwitch
                case 1
                    % First screen
                    WaitSecs(.5);
                    text1='Each trial will be fast.';
                    text2='Make sure you press the mouse as fast as you can each time you see the black square.';
                    text3='Every trial will start with a red center circle.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-500,[0 0 0]);
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-400,[0 0 0]);
                    
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{1,1,2},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            pracTrialSwitch = 2;
                            break
                        elseif keycode(options.buttons.buttonR)
                            pracTrialSwitch = 1;
                            instSwitch = 5;
                            break
                        elseif keycode(options.buttons.buttonEscape)
                            pracTrialSwitch = 5;
                            instSwitch = 9;
                            break
                        end
                    end
                    
                case 2
                    
                    % Second screen
                    WaitSecs(.5);
                    text1='After a brief delay, this will turn blue.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                    
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{1,1,1},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            pracTrialSwitch = 3;
                            break
                        elseif keycode(options.buttons.buttonR)
                            pracTrialSwitch = 1;
                            break
                        elseif keycode(options.buttons.buttonEscape)
                            pracTrialSwitch = 5;
                            instSwitch = 9;
                            break
                        end
                    end
                    
                case 3
                    
                    % Third screen
                    WaitSecs(.5);
                    text1='After another brief delay, the balls will appear.';
                    text2='The square will appear here.';
                    text3='There will not always be a square for every trial.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-500,[0 0 0]);
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                    DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-400,[0 0 0]);
                    
                    Screen('DrawTexture',options.windowNum,options.circTextures{1,1,1,1,2},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            pracTrialSwitch = 4;
                            break
                        elseif keycode(options.buttons.buttonR)
                            pracTrialSwitch = 2;
                            break
                        elseif keycode(options.buttons.buttonEscape)
                            pracTrialSwitch = 5;
                            instSwitch = 9;
                            break
                        end
                    end
                    
                case 4
                    
                    % Fourth screen
                    WaitSecs(.5);
                    text1='Then the balls will go away, and a brief time will pass before the start of the next trial.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                    
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{1,1,1},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            pracTrialSwitch = 5;
                            break
                        elseif keycode(options.buttons.buttonR)
                            pracTrialSwitch = 3;
                            break
                        elseif keycode(options.buttons.buttonEscape)
                            pracTrialSwitch = 5;
                            instSwitch = 9;
                            break
                        end
                    end
                    
                case 5
                    
                    % Fifth screen
                    WaitSecs(.5);
                    text1='Make sure you respond as quickly as possible after you see a square.';
                    text2='Now lets do some practice trials. Let the experimenter know when you are ready.';
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                    DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400,[0 0 0]);
                    
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{1,1,1},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    
                    % Last screen
                    while 1
                        [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                        if keycode(options.buttons.buttonF)
                            pracTrialSwitch = 1;
                            instSwitch = 7;
                            break
                        elseif keycode(options.buttons.buttonR)
                            pracTrialSwitch = 4;
                            break
                        elseif keycode(options.buttons.buttonEscape)
                            instSwitch = 9;
                            break
                        end
                    end
                    
                otherwise
            end
            
        case 7
            
            %% Practice trials
            options.practice.expStart = GetSecs;
            for counter=1:length(data.practice.rawdataPracticeEEG(:,2))

                n = data.practice.rawdataPracticeEEG(counter,2);
                
                % Determine conditions
                farCloseIdx = data.practice.rawdataPracticeEEG(n,3);   % 1=Far, 2=Close
                hallwayIdx = data.practice.rawdataPracticeEEG(n,4);   % 1=Hallway, 2=Close
                phaseIdx = data.practice.rawdataPracticeEEG(n,5);   % phase 1 and 2
                fixChangeIdx = data.practice.rawdataPracticeEEG(n,6);   % 1=no fix change, 2=fix change
                
                % Start with initial red fixation before starting experiment
                if n==1
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{hallwayIdx,1,2},[],options.textureCoords);
                    Screen('Flip',options.windowNum);
                    WaitSecs(1);
                end
                
                % Start trial presentation
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{hallwayIdx,1,1},[],options.textureCoords);
                options.practice.time.syncTime(n) = Screen('Flip',options.windowNum);
                
                % Start with hallway no stim - 800-1200ms w/ cyan fix
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{hallwayIdx,1,1},[],options.textureCoords);
                [~, options.practice.time.blankOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.practice.time.syncTime(n)) - options.flip_interval_correction);
                
                % Present target - 200ms w/ cyan fix
                % Present fix change trial if necessary
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx},[],options.textureCoords);
                [~, options.practice.time.stimOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.practice.time.blankOnsetTime(n)+options.time.prestimulusInterval(n))-options.flip_interval_correction);
                
                % Monitor for responses
                KbQueueStart(options.dev_id_mouse);
                
                % Present poststim hallway only - 400ms w/ cyan fix
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{hallwayIdx,1,1},[],options.textureCoords);
                [~, options.practice.time.stimOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.practice.time.stimOnsetTime(n)+options.time.stimPresInterval)-options.flip_interval_correction);
                
                % Present ITI no hallway - 650-850 w/ red fix
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2},[],options.textureCoords);
                [~, options.practice.time.ITIOnsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.practice.time.stimOffsetTime(n)+options.time.poststimulusInterval)-options.flip_interval_correction);
                
                % Final screen
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2},[],options.textureCoords);
                [~, options.practice.time.ITIOffsetTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (options.practice.time.ITIOnsetTime(n)+options.time.blankInterval(n))-options.flip_interval_correction);
                
                % Check for response
                [options.practice.response.pressed{n} options.practice.response.firstPress{n} ...
                    options.practice.response.firstRelease{n} options.practice.response.lastPress{n}...
                    options.practice.response.lastRelease{n}] = KbQueueCheck(options.dev_id_mouse);
                
                % Determine if a response was made correctly (was it a fix change trial?)
                if fixChangeIdx == 1   % No fixation change
                    if options.practice.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                        data.practice.rawdataPracticeEEG(n,7) = 0;
                    else
                        data.practice.rawdataPracticeEEG(n,7) = 1;
                    end
                elseif fixChangeIdx == 2   % Fix change
                    if options.practice.response.firstPress{n}(options.buttons.buttonLeftMouse) > 0
                        data.practice.rawdataPracticeEEG(n,7) = 1;
                    else
                        data.practice.rawdataPracticeEEG(n,7) = 0;
                    end
                end
                
                % Stop monitoring
                KbQueueStop(options.dev_id_mouse);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    pracTrialsBreak = 1;
                    break
                end
                
            end
            
            if pracTrialsBreak == 0
                % Calculate accuracy
                data.practice.aveAcc = sum(data.practice.rawdataPracticeEEG(:,7)) / length(data.practice.rawdataPracticeEEG(:,7));
                
                % End prac trials screen
                WaitSecs(.5);
                text1='End of practice trials.';
                text2=sprintf('%s%1.1f%s','Accuracy: ',data.practice.aveAcc*100,'%');
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400,[0 0 0]);
                Screen('Flip',options.windowNum);
                
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        instSwitch = 8;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        data.practice.rawdataPracticeEEG = zeros([options.practice.practiceRepetitions,7]);
                        data.practice.rawdataPracticeEEG(:,1) = 1:options.practice.practiceRepetitions;   % Trial num
                        data.practice.rawdataPracticeEEG(:,2) = randperm(options.practice.practiceRepetitions);
                        data.practice.rawdataPracticeEEG(:,3:4) = repmat(fullfact([2 2]),[options.practice.practiceRepetitions/4,1]);   % Background/distance
                        data.practice.rawdataPracticeEEG(:,5) =  repmat(fullfact([2]),[options.practice.practiceRepetitions/2,1]);   % Phase
                        data.practice.rawdataPracticeEEG(randperm(options.practice.practiceRepetitions,options.practice.numPracTrials),6) = 2;   % Task
                        data.practice.rawdataPracticeEEG(data.practice.rawdataPracticeEEG(:,6)==0,6) = 1;   % Task
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 9;
                        break
                    end
                end
            end
            
        case 8
            
            %% Last instructions before the experiment starts
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='Remember to keep your eyes focused on the circle in the middle.';
            text4='Let the experimenter know when you''re ready...';
            text5='LAST SCREEN BEFORE EXPERIMENT START!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-250,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+200,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 7;
                    data.practice.rawdataPracticeEEG = zeros([options.practice.practiceRepetitions,7]);
                    data.practice.rawdataPracticeEEG(:,1) = 1:options.practice.practiceRepetitions;   % Trial num
                    data.practice.rawdataPracticeEEG(:,2) = randperm(options.practice.practiceRepetitions);
                    data.practice.rawdataPracticeEEG(:,3:4) = repmat(fullfact([2 2]),[options.practice.practiceRepetitions/4,1]);   % Background/distance
                    data.practice.rawdataPracticeEEG(:,5) =  repmat(fullfact([2]),[options.practice.practiceRepetitions/2,1]);   % Phase
                    data.practice.rawdataPracticeEEG(randperm(options.practice.practiceRepetitions,options.practice.numPracTrials),6) = 2;   % Task
                    data.practice.rawdataPracticeEEG(data.practice.rawdataPracticeEEG(:,6)==0,6) = 1;   % Task
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
        case 9
            %% Exit if escape is pressed
            options.practice.practiceBreak = 1;
            break
            
        otherwise
            
    end
end
end