% Present instructions, examples, and practice trials for the illusory
% condition of the illusory contour experiment.

function [options,data] = IllContExp_EEGPrac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

data.practice.rawdataPracticeEEG = zeros([options.practice.practiceRepetitions*options.practice.practiceAngleNum,3]);
options.practice.practiceBreak = 0;
nPracTrials = 0;

% Randomly determine which direction will be chosen for the
% fragmented condition
texAngle = options.stim.texAngleFragmented(randi(4),:);

% First present instructions
while 1
    switch instSwitch
        
        case 1
            % First instructions screen
            text1 = 'Here, you will see four Pacmen that make a square, just like before.';
            text2 = 'Some will appear ''wide'' or like they are bulging.';
            text3 = 'Some will appear ''narrow'' or like they are contracting.';
            text4 = 'Just like before, you will press the LEFT MOUSE button if it looks ''wide''';
            text5 = 'and the RIGHT MOUSE button if it looks ''narrow''.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-400);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-350);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-300);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-250);
            
            % Draw stim
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray',options.stim.texAngleIllusory);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 8;
                    break
                end
            end
            
        case 2
            % No square condition
            text4 = 'Sometimes, no square will appear...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350);
            
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
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
                    instSwitch = 8;
                    break
                end
            end
            
        case 3
            
            text4 = 'Sometimes, no square will appear...';
            text5 = 'Instead, the four circles will all be pointed in the same direction.';
            text6 = 'In this case, you will press the MIDDLE MOUSE key, for ''no square''.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-300);      
            
            texChoseIdx = options.stim.texChoseIdxFrag(randi(4),:);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(texChoseIdx(1)) options.stim.inducerTex(texChoseIdx(2))...
                options.stim.inducerTex(texChoseIdx(3)) options.stim.inducerTex(texChoseIdx(4))],[],...
                options.stim.circPositionArray',texAngle+(options.stim.overallTilt.*options.stim.texAngleTilt(2,:)));
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
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
                    instSwitch = 8;
                    break
                end
            end
            
        case 4
            text4 = 'Sometimes, no square will appear...';
            text5 = 'Instead, the four circles will all be pointed in the same direction.';
            text6 = 'In this case, you will press the MIDDLE MOUSE key, for ''no square''.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-300);   
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)-250); 
            
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(texChoseIdx(1)) options.stim.inducerTex(texChoseIdx(2))...
                options.stim.inducerTex(texChoseIdx(3)) options.stim.inducerTex(texChoseIdx(4))],[],...
                options.stim.circPositionArray',texAngle+...
                (options.stim.overallTilt.*options.stim.texAngleTilt(2,:)));
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
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
                    instSwitch = 8;
                    break
                end
            end            
            
        case 5
            
            WaitSecs(.5);
            text1='Now, let''s do some practice trials...';
            text2='The trials will slowly become more difficult.';
            text3='Please keep your eyes fixed on the black square in the center of the screen.';
            text4='Sometimes the task will be difficult, and it''s ok if you need to guess. Just try your best!';
            text5='Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-200,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 8;
                    break
                end
            end
            
        case 6
            
            % Make a holder varlist variable
            clear varListPracHolder pracCounter
            varListPracHolder = options.practice.varListPractice;
            pracCounter = 0;
            
            for n=nPracTrials+1:length(varListPracHolder)+nPracTrials
                
                pracCounter = pracCounter+1;
                
                % Which condi is this trial
                switch varListPracHolder(pracCounter,1)
                    case 1
                         texChoseIdx = options.stim.texChoseIdxIll;
                         texAngle = options.stim.texAngleIllusory;
                    case 2
                         texChoseIdx = options.stim.texChoseIdxFrag(randi(4),:);
                         texAngle = options.stim.texAngleFragmented(randi(4),:);
                end
                
                options.stim.overallTilt = options.practice.practiceAngleList(varListPracHolder(pracCounter,3));   % Tilt angle
                switch varListPracHolder(pracCounter,2)
                    case 1   % Fat
                        tiltDir = 1;
                    case 2   % Thin
                        tiltDir = -1;
                end
                data.practice.rawdataPracticeEEG(n,1) = tiltDir;
                options.stim.overallTilt = options.stim.overallTilt * tiltDir;    % Tilt direction
                
                % Start with blank screen
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.blankIntervalPrac);
                
                % Draw stim
                Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(texChoseIdx(1)) options.stim.inducerTex(texChoseIdx(2))...
                    options.stim.inducerTex(texChoseIdx(3)) options.stim.inducerTex(texChoseIdx(4))],[],...
                    options.stim.circPositionArray',texAngle+...
                    (options.stim.overallTilt.*options.stim.texAngleTilt(varListPracHolder(pracCounter,1),:)));
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.practice.practiceStimTimeList(varListPracHolder(pracCounter,4)));
                
                % ISI
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.isiInterval);
                
                % Mask
                Screen('DrawTextures',options.windowNum,[options.stim.maskTex options.stim.maskTex options.stim.maskTex options.stim.maskTex],[],...
                    options.stim.circPositionArray');
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.maskInterval);
                
                % Mask offset
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                % Response
                feedBackText = 'Wide, No Square, or Narrow?';
                instHelpText = 'Left Mouse Button, Middle Mouse Button, or Right Mouse Button';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
                DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-100);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,instHelpText));
                DrawFormattedText(options.windowNum,instHelpText,'center',options.yc-(textHeight/2)-50,[0 0 0]);
                Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    if buttonsHolder(1) == 1
                        % Determine if they got it right
                        data.practice.rawdataPracticeEEG(n,2) = 1;   % Reported left tilt
                        if varListPracHolder(pracCounter,1) == 1   % Illusory
                            if tiltDir == 1   % Left tilted
                                data.practice.rawdataPracticeEEG(n,3) = 1;   % Correct
                            elseif tiltDir == -1   % Right tilted
                                data.practice.rawdataPracticeEEG(n,3) = 0;
                            end
                        elseif varListPracHolder(pracCounter,1) == 2   % Fragmented
                            data.practice.rawdataPracticeEEG(n,3) = 0;
                        end
                        break
                    elseif buttonsHolder(3) == 1
                        % Determine if they got it right
                        data.practice.rawdataPracticeEEG(n,2) = 2;   % Reported right tilt
                        if varListPracHolder(pracCounter,1) == 1   % Illusory
                            if tiltDir == 1   % Left tilted
                                data.practice.rawdataPracticeEEG(n,3) = 0;   % Correct
                            elseif tiltDir == -1   % Right tilted
                                data.practice.rawdataPracticeEEG(n,3) = 1;
                            end
                        elseif varListPracHolder(pracCounter,1) == 2   % Fragmented
                            data.practice.rawdataPracticeEEG(n,3) = 0;
                        end
                        break
                    elseif buttonsHolder(2) == 1
                        % Determine if they got it right
                        data.practice.rawdataPracticeEEG(n,2) = 3;   % Reported no square 
                        if varListPracHolder(pracCounter,1) == 2   % Frag condition
                            data.practice.rawdataPracticeEEG(n,3) = 1;   % Incorrect
                        elseif varListPracHolder(pracCounter,1) == 1   % Ill condition
                            data.practice.rawdataPracticeEEG(n,3) = 0;
                        end
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 5;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 8;
                        breakSwitch = 1;
                        break
                    end
                end
                
                % Feedback
                if data.practice.rawdataPracticeEEG(n,3) == 1
                    feedBackText = 'OK';
                elseif data.practice.rawdataPracticeEEG(n,3) == 0
                    feedBackText = 'MISS';
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
                DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-5);
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.respInterval);
                
                % Escape
                if breakSwitch == 1
                    break
                end
                
            end
            
            if breakSwitch ~= 1
                WaitSecs(.5);
                text1='Practice trials complete...';
                text2='For the practice trials it told you if you got it right or wrong but it won''t during the experiment.';
                text3='Let the experimenter know when you''re ready...';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,[0 0 0]);
                
                Screen('Flip',options.windowNum);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        instSwitch = 7;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 5;
                        % If this is an additional round of prac trials, add more rows to prac rawdata
                        nPracTrials = length(data.practice.rawdataPracticeEEG);
                        data.practice.rawdataPracticeEEG(nPracTrials+1:nPracTrials+length(varListPracHolder),:) =...
                            zeros([length(varListPracHolder) 3]);
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 8;
                        break
                    end
                end
            end
            
            breakSwitch = 0;
            
        case 7
            
            % Last instructions before the experiment starts
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='Remember to keep your eyes focused on the black square in the middle.';
            text4='Lastly, remember to wait until the response screen appears to make you response!';
            text5='LAST SCREEN BEFORE EXPERIMENT START!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-200,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+150,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 5;
                    nPracTrials = length(data.practice.rawdataPracticeEEG);
                    data.practice.rawdataPracticeEEG(nPracTrials+1:nPracTrials+length(varListPracHolder),:) =...
                        zeros([length(varListPracHolder) 3]);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 8;
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
        case 8
            %% Exit if escape is pressed
            options.practice.practiceBreak = 1;
            break
            
        otherwise
    end
end
% Reset the check variable
options.practice.practiceCheck = 0;
end