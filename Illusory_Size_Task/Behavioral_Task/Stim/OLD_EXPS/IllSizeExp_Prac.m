% Present instructions, examples, and practice trials for the illusory
% condition of the illusory contour experiment.

function [options,data] = IllSizeExp_Prac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

% Prealocate rawdata
data.practice.rawdataPractice = zeros([options.practice.practiceRepetitions*2,4]);
data.practice.rawdataPractice(1:length(data.practice.rawdataPractice)/2,1) = 2;   % No background
data.practice.rawdataPractice(length(data.practice.rawdataPractice)/2+1:length(data.practice.rawdataPractice),1) = 1;   % Background
% Circ size (make it fairly easy, w/ both small and large examples)
data.practice.rawdataPractice(1:length(data.practice.rawdataPractice)/2,2) = [1:options.practice.practiceRepetitions/2 ...
    length(options.circTextures):-1:length(options.circTextures)-((options.practice.practiceRepetitions/2)-1)];
data.practice.rawdataPractice(length(data.practice.rawdataPractice)/2+1:length(data.practice.rawdataPractice),2) = [1:options.practice.practiceRepetitions/2 ...
    length(options.circTextures):-1:length(options.circTextures)-((options.practice.practiceRepetitions/2)-1)];
data.practice.rawdataPractice(1:options.practice.practiceRepetitions,:) = data.practice.rawdataPractice(randperm(options.practice.practiceRepetitions),:);
data.practice.rawdataPractice(options.practice.practiceRepetitions+1:options.practice.practiceRepetitions*2,:) = ...
    data.practice.rawdataPractice(randperm(options.practice.practiceRepetitions)+options.practice.practiceRepetitions,:);

options.practice.practiceBreak = 0;

%% Start instructions
while 1
    switch instSwitch
        
        case 1
            %% Screen 1
            text1 = 'You will see two balls in the lower left and upper right parts of the screen.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1},[],...
                squeeze(options.textureCoords_Corrected(2,1,:,1)));
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    WaitSecs(.5);
                    instSwitch =  11;
                    break
                end
            end
            
        case 2
            %% Screen 2
            text1 = 'Your job is to judge which of the two balls is larger.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1},[],...
                squeeze(options.textureCoords_Corrected(2,1,:,1)));
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch =  11;
                    break
                end
            end
            
        case 3
            %% Screen 3
            text1 = 'If the upper right ball is larger, press the RIGHT MOUSE BUTTON.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1},[],...
                squeeze(options.textureCoords_Corrected(2,1,:,1)));
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if keycode(options.buttons.buttonF) || buttonsHolder(3)
                    WaitSecs(.5);
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch =  11;
                    break
                end
            end
            
            
        case 4
            %% Screen 4
            text1 = 'If the lower left ball is larger, press the LEFT MOUSE BUTTON.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            Screen('DrawTexture',options.windowNum,options.circTextures{2,length(options.circTextures)},[],...
                squeeze(options.textureCoords_Corrected(2,1,:,length(options.circTextures))));
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                if keycode(options.buttons.buttonF) || buttonsHolder(1)
                    WaitSecs(.5);
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 11;
                    break
                end
            end
            
            
        case 5
            %% Screen 5
            text1 = 'Let''s do some practice trials.';
            text2 = 'There will be 10 total. You can take as long as you need to respond, but try to respond as quickly as possible.';
            text3 = 'Please keep your eyes fixed on the small green dot at the center of the screen.';
            text4 = 'Sometimes it may be difficult. That''s ok, just try and do your best.';
            text5 = 'Let the experimenter know when you are ready.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+150);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+200);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',(textHeight/2)+250);
            
            % Draw
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    instSwitch = 6;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 11;
                    break
                end
            end
            
            
        case 6
            %% Screen 6
            for n=1:length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==2))
                
                % Blank screen (fixation)
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2)},[],...
                    squeeze(options.textureCoords_Corrected(data.practice.rawdataPractice(n,1),2,:,data.practice.rawdataPractice(n,2))));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.blankOnsetTime);
                
                % Blank screen (fixation)
                Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2)},[],...
                    squeeze(options.textureCoords_Corrected(data.practice.rawdataPractice(n,1),1,:,data.practice.rawdataPractice(n,2))));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.stimPresTime);
                
                % Response
                text1='Was the top-right (RIGHT MOUSE) or bottom-left (LEFT MOUSE) sphere bigger?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                Screen('Flip',options.windowNum);
                
                responseBreak = 0;
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                while 1
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    
                    switch responseBreak
                        case 0   % If no response recorded
                            if buttonsHolder(3) == 1   % Top right
                                data.practice.rawdataPractice(n,3) = 1;   % Record response
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Bottom was larger
                                    data.practice.rawdataPractice(n,4) = 0;
                                elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Top was larger
                                    data.practice.rawdataPractice(n,4) = 1;
                                end
                                    
                                responseBreak = 1;
                            elseif buttonsHolder(1) == 1   % Bottom left
                                data.practice.rawdataPractice(n,3) = 2;   % Record response
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Bottom was larger
                                    data.practice.rawdataPractice(n,4) = 1;
                                elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Top was larger
                                    data.practice.rawdataPractice(n,4) = 0;
                                end
                                
                                responseBreak = 1;
                            end
                        case 1
                            break
                        otherwise
                    end
                    
                    [~, ~, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        instSwitch = 5;
                        
                        % Reset practice
                        data.practice.rawdataPractice(1:length(data.practice.rawdataPractice),3:4) =...
                            zeros([length(data.practice.rawdataPractice),2]);
                        
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 11;
                        breakSwitch = 1;
                        break
                    end
                end
                
                if breakSwitch == 1
                    break
                end
            end
            
            if breakSwitch == 0
                % Calculate and display accuracy
                data.practice.noHallwayAccuracy = (sum(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==2,4)) /...
                    length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==2,4)))*100;
                
                text1 = sprintf('%s%d%s%d%s','You got ',sum(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==2,4)),...
                    ' out of ',length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==2,4)),' correct.');
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                
                Screen('Flip',options.windowNum);
                
                while 1
                    [~, ~, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        WaitSecs(.5);
                        instSwitch = 7;
                        break
                    elseif keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        instSwitch = 5;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 11;
                        break
                    end
                end
                
            elseif breakSwitch == 1
                breakSwitch = 0;
                Screen('Flip',options.windowNum);
            end            
            
        case 7
            %% Screen 7
            text1='For half of the trials, the balls will be in a brick hallway.';
            text2='Your task is still the same, judge which ball appears larger.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100);
            
            % Draw stimuli
            Screen('DrawTexture',options.windowNum,options.circTextures{1,1},[],...
                squeeze(options.textureCoords_Corrected(1,1,:,1)));
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    instSwitch = 8;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 11;
                    break
                end
            end
            
        case 8
            %% Screen 8
            text1 = 'Let''s do some practice trials with the hallway.';
            text2 = 'There will be 10 total. You can take as long as you need to respond, but try to respond as quickly as possible.';
            text3 = 'Please keep your eyes fixed on the small green dot at the center of the screen.';
            text4 = 'Sometimes it may be difficult. That''s ok, just try and do your best.';
            text5 = 'Let the experimenter know when you are ready.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+150);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+200);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',(textHeight/2)+250);
            
            % Draw
            Screen('Flip',options.windowNum);
            
            [~, ~, keycode] = KbCheck(options.dev_id);
            while 1
                [~, ~, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    instSwitch = 9;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 7;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 11;
                    break
                end
            end
            
        case 9
            %% Screen 9
            % Hallway practice
            for n=options.practice.practiceRepetitions+1:options.practice.practiceRepetitions+length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==1))
                
                % Blank screen (fixation)
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2)},[],...
                    squeeze(options.textureCoords_Corrected(data.practice.rawdataPractice(n,1),2,:,data.practice.rawdataPractice(n,2))));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.blankOnsetTime);
                
                % Blank screen (fixation)
                Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2)},[],...
                    squeeze(options.textureCoords_Corrected(data.practice.rawdataPractice(n,1),1,:,data.practice.rawdataPractice(n,2))));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.stimPresTime);
                
                % Response
                text1='Was the top-right (RIGHT MOUSE) or bottom-left (LEFT MOUSE) sphere bigger?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                Screen('Flip',options.windowNum);
                
                responseBreak = 0;
                [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                while 1
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    
                    switch responseBreak
                        case 0   % If no response recorded
                            if buttonsHolder(3) == 1   % Top right
                                data.practice.rawdataPractice(n,3) = 1;   % Record response
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Bottom was larger
                                    data.practice.rawdataPractice(n,4) = 0;
                                elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Top was larger
                                    data.practice.rawdataPractice(n,4) = 1;
                                end
                                    
                                responseBreak = 1;
                            elseif buttonsHolder(1) == 1   % Bottom left
                                data.practice.rawdataPractice(n,3) = 2;   % Record response
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Bottom was larger
                                    data.practice.rawdataPractice(n,4) = 1;
                                elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Top was larger
                                    data.practice.rawdataPractice(n,4) = 0;
                                end
                                
                                responseBreak = 1;
                            end
                        case 1
                            break
                        otherwise
                    end
                    
                    [~, ~, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        instSwitch = 8;
                        
                        % Reset practice
                        data.practice.rawdataPractice(options.practice.practiceRepetitions+1:length(data.practice.rawdataPractice),3:4) =...
                            zeros([options.practice.practiceRepetitions,2]);
                        
                        breakSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 11;
                        breakSwitch = 1;
                        break
                    end
                end
                
                if breakSwitch == 1
                    break
                end
            end
            
            if breakSwitch == 0
                % Calculate and display accuracy
                data.practice.hallwayAccuracy = (sum(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==1,4)) /...
                    length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==1,4)))*100;
                
                text1 = sprintf('%s%d%s%d%s','You got ',sum(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==1,4)),...
                    ' out of ',length(data.practice.rawdataPractice(data.practice.rawdataPractice(:,1)==1,4)),' correct.');
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                
                Screen('Flip',options.windowNum);
                
                while 1
                    [~, ~, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        WaitSecs(.5);
                        instSwitch = 10;
                        break
                    elseif keycode(options.buttons.buttonR)
                        WaitSecs(.5);
                        instSwitch = 8;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 11;
                        break
                    end
                end
                
            elseif breakSwitch == 1
                breakSwitch = 0;
                Screen('Flip',options.windowNum);
            end
            
            
            
        case 10
            %% Screen 10
             % Last instructions before the experiment starts
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='Remember to keep your eyes focused on the black square in the middle.';
            text4='Let the experimenter know when you''re ready...';
            text5='LAST SCREEN BEFORE EXPERIMENT START!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',(textHeight/2)+200,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',(textHeight/2)+250,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    WaitSecs(.5);
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonR)
                    WaitSecs(.5);
                    instSwitch = 9;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 11;
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
            
        case 11
            %% If you press escape
            options.practice.practiceBreak = 1;
            break
            
        otherwise
            break
    end

end

end