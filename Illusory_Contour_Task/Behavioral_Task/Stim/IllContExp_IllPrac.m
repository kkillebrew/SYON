% Present instructions, examples, and practice trials for the illusory
% condition of the illusory contour experiment.

function [options,data] = IllContExp_IllPrac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

data.practice.rawdataPracticeIll = zeros([options.practice.practiceRepetitions*options.practice.practiceAngleNum,3]);
options.practice.practiceBreak = 0;
nPracTrials = 0;

% First present instructions
while 1
    switch instSwitch
        
        case 1
            % First instructions screen
            text1 = 'You will see four white circles, each with a missing piece,';
            text2 = 'like a Pacman. For this block of the experiment, the circles';
            text3 = 'will be arranged so that the missing pieces form a square.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250);
            
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
                    instSwitch = 12;
                    break
                end
            end
            
        case 2
            % Second instructions screen
            for i=1:options.practice.practiceAngleList(1)
                
                % Update angle
                options.stim.overallTilt = options.stim.overallTilt+1;
                
                text4 = 'If we rotate the circles, you should notice that the square';
                text5 = 'looks ''wide'' (or like they are bulging)...';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
                DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-300);
                
                % Draw
                % Draw stim
                Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                    options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                    options.stim.circPositionArray',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
            end
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
                    instSwitch = 12;
                    break
                end
            end
            
        case 3
            % Second instructions screen part 2
%             options.stim.overallTilt = 0;
            for i=1:options.practice.practiceAngleList(1)*2
                
                % Update angle
                options.stim.overallTilt = options.stim.overallTilt-1;
                
%                 text4 = 'If we rotate the circles, you should notice that the square';
                text6 = '...or looks ''narrow'' (or like they are contracting) if we rotate in the other direction.';
%                 textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
%                 DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
                DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)-300);
                
                % Draw
                % Draw stim
                Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                    options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                    options.stim.circPositionArray',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
            end
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
                    instSwitch = 12;
                    break
                end
            end
            
        case 4
                                    
            text8 = 'Your task is to judge whether the square is ''wide'' (bulging) or ''narrow'' (contracting).';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text8));
            DrawFormattedText(options.windowNum,text8,'center',options.yc-(textHeight/2)-350);
            
            % Draw stim
            % Draw each stimuli, 'wide' on the right, and 'narrow' on the left
            % Wide
            options.stim.overallTilt = -options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'+[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
            % Narrow
            options.stim.overallTilt = options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'-[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));            
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
        case 5
            
            text9 = 'If it appears ''wide'' you''ll press the LEFT MOUSE button.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text9));
            DrawFormattedText(options.windowNum,text9,'center',options.yc-(textHeight/2)-350);
            
            % Draw stim
            % Draw each stimuli, 'wide' on the right, and 'narrow' on the left
            % Wide
            options.stim.overallTilt = -options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'+[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
            % Narrow
            options.stim.overallTilt = options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'-[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));            
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            redTexArray = zeros([10 10 3]);
            redTexArray(:,:,1) = options.redCol(1);
            redTex = Screen('MakeTexture',options.windowNum,redTexArray);
            Screen('DrawTexture',options.windowNum,redTex,[],...
                [options.stim.circPositionArray(1,1:2)'; options.stim.circPositionArray(4,3:4)']-[400 0 400 0]',...
                [],[],.15);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if keycode(options.buttons.buttonF)
                    instSwitch = 6;
                    break
                elseif buttonsHolder(1) == 1
                    instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
        case 6
            
            text10 = 'If it appears ''narrow'' you''ll press the RIGHT MOUSE button';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text10));
            DrawFormattedText(options.windowNum,text10,'center',options.yc-(textHeight/2)-350);
            
            % Draw stim
            % Draw each stimuli, 'wide' on the right, and 'narrow' on the left
            % Wide
            options.stim.overallTilt = -options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'+[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
            % Narrow
            options.stim.overallTilt = options.practice.practiceAngleList(1);
            Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2)...
                options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                options.stim.circPositionArray'-[400 0 400 0]',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));            
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            redTexArray = zeros([10 10 3]);
            redTexArray(:,:,1) = options.redCol(1);
            redTex = Screen('MakeTexture',options.windowNum,redTexArray);
            Screen('DrawTexture',options.windowNum,redTex,[],...
                [options.stim.circPositionArray(1,1:2)'; options.stim.circPositionArray(4,3:4)']+[400 0 400 0]',...
                [],[],.15);
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if keycode(options.buttons.buttonF)
                    instSwitch = 7;
                    break
                elseif buttonsHolder(3) == 1
                    instSwitch = 7;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
        case 7
            %% Initial practice trial - easy
            WaitSecs(.5);
            text1='We''ll start with an example.';
            text2='Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 8;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
        case 8
            
            % Update tilt angle
            options.stim.overallTilt = 0;
            
            WaitSecs(.5);
            text1='First, you''ll see a blank screen...';
            text2='You should try to blink only during this screen, when you see the ''B'' at the center of the screen.';
            text3='This will be followed by the brief presentation of the Pacmen...';
            text4='Followed by another brief blank screen...';
            text5='Followed by a presentation of four fully filled in circles in the place of the Pacmen...';
            text6='Lastly, a response screen will appear to allow you to respond...';
            
            % Start with blank screen
            Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            Screen('Flip',options.windowNum);
            WaitSecs(.5);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 7;
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    breakSwitch = 1;
                    break
                end
            end
            
            % Draw stim
            if breakSwitch == 0
                options.stim.overallTilt = -options.practice.practiceAngleList(1);
                Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2) options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                    options.stim.circPositionArray',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                Screen('Flip',options.windowNum);
                WaitSecs(.5);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        breakSwitch = 1;
                        break
                    end
                end
            end
            
            % ISI
            if breakSwitch == 0
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                Screen('Flip',options.windowNum);
                WaitSecs(.5);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        breakSwitch = 1;
                        break
                    end
                end
            end
            
            % Mask
            if breakSwitch == 0
                Screen('DrawTextures',options.windowNum,[options.stim.maskTex options.stim.maskTex options.stim.maskTex options.stim.maskTex],[],...
                    options.stim.circPositionArray');
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
                DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                Screen('Flip',options.windowNum);
                WaitSecs(.5);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        breakSwitch = 1;
                        break
                    end
                end
            end
            
            % Response
            if breakSwitch == 0
                feedBackText = 'Wide or Narrow?';
                instHelpText = 'Left MOUSE button or Right MOUSE button';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText));
                DrawFormattedText(options.windowNum,feedBackText,'center',options.yc-(textHeight/2)-100);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
                DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,instHelpText));
                DrawFormattedText(options.windowNum,instHelpText,'center',options.yc-(textHeight/2)-50,[0 0 0]);
                Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(.5);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        instSwitch = 9;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        breakSwitch = 1;
                        break
                    end
                end
            end
            
            breakSwitch = 0;
            
        case 9
            
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
                    instSwitch = 10;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 7;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
        case 10
            
            tiltDirList = [-1 1];   % List for randomly determining what the tilt direction will be            
            % Make a varlist for fragmented cond only using varListPractice
            clear varListPracHolder pracCounter
            varListPracHolder = options.practice.varListPractice(options.practice.varListPractice(:,1)==1,:);
            pracCounter = 0;
            
            for n=nPracTrials+1:length(varListPracHolder)+nPracTrials
                
                pracCounter = pracCounter + 1;
                options.stim.overallTilt = options.practice.practiceAngleList(varListPracHolder(pracCounter,2));   % Tilt angle
                tiltDir = tiltDirList(randi(2));
                data.practice.rawdataPracticeIll(n,1) = tiltDir;
                options.stim.overallTilt = options.stim.overallTilt * tiltDir;    % Tilt direction
                
                % Start with blank screen
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.blankInterval);
                
                % Draw stim
                Screen('DrawTextures',options.windowNum,[options.stim.inducerTex(1) options.stim.inducerTex(2) options.stim.inducerTex(1) options.stim.inducerTex(2)],[],...
                    options.stim.circPositionArray',options.stim.texAngleIllusory+(options.stim.overallTilt.*options.stim.texAngleTilt(1,:)));
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.practice.practiceStimTimeList(varListPracHolder(pracCounter,3)));
                
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
                feedBackText = 'Wide or Narrow?';
                instHelpText = 'Left MOUSE button or Right MOUSE button';
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
%                     if keycode(options.buttons.buttonLeft)
                    if buttonsHolder(1) == 1
                        % Determine if they got it right
                        data.practice.rawdataPracticeIll(n,2) = 1;   % Reported left tilt
                        if tiltDir == 1   % Left tilted
                            data.practice.rawdataPracticeIll(n,3) = 1;   % Correct
                        elseif tiltDir == -1   % Right tilted
                            data.practice.rawdataPracticeIll(n,3) = 0;
                        end
                        break
                    elseif buttonsHolder(3) == 1
                        % Determine if they got it right
                        data.practice.rawdataPracticeIll(n,2) = 2;   % Reported right tilt
                        if tiltDir == 1   % Left tilted
                            data.practice.rawdataPracticeIll(n,3) = 0;   % Correct
                        elseif tiltDir == -1   % Right tilted
                            data.practice.rawdataPracticeIll(n,3) = 1;
                        end
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 9;
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        breakSwitch = 1;
                        break
                    end
                end
                
                % Feedback
                if data.practice.rawdataPracticeIll(n,3) == 1
                    feedBackText = 'OK';
                elseif data.practice.rawdataPracticeIll(n,3) == 0
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
                data.practice.practiceAccuracy = round((sum(data.practice.rawdataPracticeIll(:,3)) / numel(data.practice.rawdataPracticeIll(:,3))) * 100);
                text1=sprintf('%s%d%s','Practice trials complete... Accuracy: ',data.practice.practiceAccuracy,'%');
                text2='For the practice trials it told you if you got it right or wrong but it won''t during the experiment.';
                text3='There will be 2 blocks of trials. Each block will take 4 minutes and there will be a break between each block.';
                text4='Let the experimenter know when you''re ready...';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-250,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
                DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-200,[0 0 0]);
                
                Screen('Flip',options.windowNum);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        instSwitch = 11;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 9;
                        % If this is an additional round of prac trials, add more rows to prac rawdata
                        nPracTrials = length(data.practice.rawdataPracticeIll);
                        data.practice.rawdataPracticeIll(nPracTrials+1:nPracTrials+length(varListPracHolder),:) =...
                            zeros([length(varListPracHolder) 3]);
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 12;
                        break
                    end
                end
            end
            
            breakSwitch = 0;
            
        case 11
            
            % Last instructions before the experiment starts
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='Remember to keep your eyes focused on the black square in the middle.';
            text4='Let the experimenter know when you''re ready...';
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
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 9;
                    nPracTrials = length(data.practice.rawdataPracticeIll);
                    data.practice.rawdataPracticeIll(nPracTrials+1:nPracTrials+length(varListPracHolder),:) =...
                        zeros([length(varListPracHolder) 3]);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 12;
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
        case 12
            %% Exit if escape is pressed
            options.practice.practiceBreak = 1;
            break
            
        otherwise
    end
end
% Reset the check variable
options.practice.practiceCheck = 0;
end