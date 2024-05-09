% Present instructions, examples, and practice trials for the illusory
% condition of the illusory contour experiment.

function [options,data] = IllSizeExp_Flicker_FixLine_Prac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

% Prealocate rawdata
data.practice.rawdataPractice = zeros([options.practice.practiceRepetitions*2,5]);
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
% Chose perspective
data.practice.rawdataPractice(:,5) = repmat(fullfact([2]),[length(data.practice.rawdataPractice)/2 1]);

options.practice.practiceBreak = 0;

%% Start instructions
while 1
    switch instSwitch
        
        case 1
            %% Screen 1
            text1 = 'You will see two balls in the lower and upper parts of the screen.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            phaseSwitch = 1;
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
            Screen('Flip',options.windowNum);
            
            currTime = GetSecs;
            while 1
                flipTest = (GetSecs-currTime)>options.flickerRate;
                switch flipTest
                    case 1   % Redraw
                        phaseSwitch = 3-phaseSwitch;
                        currTime = GetSecs;
                        
                        % Draw texture
                        Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
                        Screen('Flip',options.windowNum);
                end
                
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
            phaseSwitch = 1;
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
            Screen('Flip',options.windowNum);
            
            currTime = GetSecs;
            while 1
                flipTest = (GetSecs-currTime)>options.flickerRate;
                switch flipTest
                    case 1   % Redraw
                        phaseSwitch = 3-phaseSwitch;
                        currTime = GetSecs;
                        
                        % Draw texture
                        Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
                        Screen('Flip',options.windowNum);
                end
                
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
            text1 = 'If the right ball is larger, press the RIGHT ARROW.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
            
            % Draw stim
            phaseSwitch = 1;
            Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
            Screen('Flip',options.windowNum);
            
            currTime = GetSecs;
            while 1
                flipTest = (GetSecs-currTime)>options.flickerRate;
                switch flipTest
                    case 1   % Redraw
                        phaseSwitch = 3-phaseSwitch;
                        currTime = GetSecs;
                        
                        % Draw texture
                        Screen('DrawTexture',options.windowNum,options.circTextures{2,1,phaseSwitch},[],squeeze(options.textureCoords));
                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
                        Screen('Flip',options.windowNum);
                end
                
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
            text1 = 'If the left ball is larger, press the LEFT ARROW.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);

            % Draw stim
            phaseSwitch = 1;
            Screen('DrawTexture',options.windowNum,options.circTextures{2,length(options.circTextures),phaseSwitch},[],...
                            squeeze(options.textureCoords));
            Screen('Flip',options.windowNum);
            
            currTime = GetSecs;
            while 1
                flipTest = (GetSecs-currTime)>options.flickerRate;
                switch flipTest
                    case 1   % Redraw
                        phaseSwitch = 3-phaseSwitch;
                        currTime = GetSecs;
                        
                        % Draw texture
                        Screen('DrawTexture',options.windowNum,options.circTextures{2,length(options.circTextures),phaseSwitch},[],...
                            squeeze(options.textureCoords));
                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
                        Screen('Flip',options.windowNum);
                end
                
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
            text3 = 'Make sure you wait until after the balls disappear to respond. Sometimes, if you respond too early, the next trial won''t start.';
            text4 = 'Please keep your eyes fixed on the blue line at the center of the screen.';
            text5 = 'Sometimes it may be difficult. That''s ok, just try and do your best.';
            text6 = 'Let the experimenter know when you are ready.';
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
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',(textHeight/2)+300);
            
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
                    data.practice.rawdataPractice(n,2),data.practice.rawdataPractice(n,5)},[],...
                    squeeze(options.textureCoords));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.blankOnsetTime);

                % Start time for next flip
                % Draw texture
                phaseSwitch = 1;
                Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2),phaseSwitch,data.practice.rawdataPractice(n,5)},[],...
                    squeeze(options.textureCoords));
                %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
                Screen('Flip',options.windowNum);
                
                stimOnsetTime = GetSecs;
                flipCounter = 2;
                while 1
                    trialCheck = (GetSecs - stimOnsetTime) > options.stimPresTime-.001;   % When total time excedes run time stop
                    switch trialCheck
                        case 0
                            flipTest = (GetSecs-stimOnsetTime)>options.flickerTimes(flipCounter);
                            switch flipTest
                                case 1   % Redraw
                                    phaseSwitch = 3-phaseSwitch;
                                    
                                    % Draw texture
                                    Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                                        data.practice.rawdataPractice(n,2),phaseSwitch,data.practice.rawdataPractice(n,5)},[],...
                                        squeeze(options.textureCoords));
                                    %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
                                    
                                    Screen('Flip',options.windowNum);
                                    
                                    flipCounter = flipCounter+1;
                            end
                        case 1
                            break
                    end
                end
                
                % Response
                text1='Was the left (LEFT ARROW) or right (RIGHT ARROW) sphere bigger?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                Screen('Flip',options.windowNum);
                
                responseBreak = 0;
                [~, ~, keycode] = KbCheck(options.dev_id2);
                while 1
                    [~, ~, keycode] = KbCheck(options.dev_id2);
                    
                    switch responseBreak
                        case 0   % If no response recorded
                            if keycode(options.buttons.buttonRight)   % right
                                
                                if data.practice.rawdataPractice(n,5) == 1   % upper right/lower left
                                    data.practice.rawdataPractice(n,3) = 1;   % Record response
                                elseif data.practice.rawdataPractice(n,5) == 2   % upper left/lower right
                                    data.practice.rawdataPractice(n,3) = 2;   % Record response
                                end
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,3) == 1   % Chose standard
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    end
                                elseif data.practice.rawdataPractice(n,3) == 2   % Chose target
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    end
                                end
                                    
                                responseBreak = 1;
                            elseif keycode(options.buttons.buttonLeft)   % left
                                
                                if data.practice.rawdataPractice(n,5) == 1   % upper right/lower left
                                    data.practice.rawdataPractice(n,3) = 2;   % Record response
                                elseif data.practice.rawdataPractice(n,5) == 2   % upper left/lower right
                                    data.practice.rawdataPractice(n,3) = 1;   % Record response
                                end
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,3) == 1   % Chose standard
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    end
                                elseif data.practice.rawdataPractice(n,3) == 2   % Chose target
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    end
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

            % Draw stim
            phaseSwitch = 1;
            Screen('DrawTexture',options.windowNum,options.circTextures{1,1,phaseSwitch},[],squeeze(options.textureCoords));
            Screen('Flip',options.windowNum);
            
            currTime = GetSecs;
            while 1
                flipTest = (GetSecs-currTime)>options.flickerRate;
                switch flipTest
                    case 1   % Redraw
                        phaseSwitch = 3-phaseSwitch;
                        currTime = GetSecs;
                        
                        % Draw texture
                        Screen('DrawTexture',options.windowNum,options.circTextures{1,1,phaseSwitch},[],squeeze(options.textureCoords));
                        DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+50);
                        DrawFormattedText(options.windowNum,text2,'center',(textHeight/2)+100);
                        Screen('Flip',options.windowNum);
                end
                
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
            text3 = 'Make sure you wait until after the balls disappear to respond. Sometimes, if you respond too early, the next trial won''t start.';
            text4 = 'Please keep your eyes fixed on the blue line at the center of the screen.';
            text5 = 'Sometimes it may be difficult. That''s ok, just try and do your best.';
            text6 = 'Let the experimenter know when you are ready.';
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
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',(textHeight/2)+300);
            
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
                    data.practice.rawdataPractice(n,2),data.practice.rawdataPractice(n,5)},[],...
                    squeeze(options.textureCoords));
                Screen('Flip',options.windowNum);
                
                WaitSecs(options.blankOnsetTime);
                
                % Start time for next flip
                % Draw texture
                phaseSwitch = 1;
                Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                    data.practice.rawdataPractice(n,2),phaseSwitch,data.practice.rawdataPractice(n,5)},[],...
                    squeeze(options.textureCoords));
                %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
                Screen('Flip',options.windowNum);
                
                stimOnsetTime = GetSecs;
                flipCounter = 2;
                while 1
                    trialCheck = (GetSecs - stimOnsetTime) > options.stimPresTime-.001;   % When total time excedes run time stop
                    switch trialCheck
                        case 0
                            flipTest = (GetSecs-stimOnsetTime)>options.flickerTimes(flipCounter);
                            switch flipTest
                                case 1   % Redraw
                                    phaseSwitch = 3-phaseSwitch;
                                    
                                    % Draw texture
                                    Screen('DrawTexture',options.windowNum,options.circTextures{data.practice.rawdataPractice(n,1),...
                                        data.practice.rawdataPractice(n,2),phaseSwitch,data.practice.rawdataPractice(n,5)},[],...
                                        squeeze(options.textureCoords));
                                    %         Screen('FrameRect',options.windowNum,[255 0 0],squeeze(options.textureCoords_Corrected(backgroundIdx,1,:,data.currSizeIdx(n))));
                                    
                                    Screen('Flip',options.windowNum);
                                    
                                    flipCounter = flipCounter+1;
                            end
                        case 1
                            break
                    end
                end
                
                % Response
                text1='Was the left (LEFT ARROW) or right (RIGHT ARROW) sphere bigger?';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
                Screen('Flip',options.windowNum);
                
                responseBreak = 0;
                [~, ~, keycode] = KbCheck(options.dev_id2);
                while 1
                    [~, ~, keycode] = KbCheck(options.dev_id2);
                    
                    switch responseBreak
                        case 0   % If no response recorded
                            if keycode(options.buttons.buttonRight)   % Right
                                
                                if data.practice.rawdataPractice(n,5) == 1   % upper right/lower left
                                    data.practice.rawdataPractice(n,3) = 1;   % Record response
                                elseif data.practice.rawdataPractice(n,5) == 2   % upper left/lower right
                                    data.practice.rawdataPractice(n,3) = 2;   % Record response
                                end
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,3) == 1   % Chose standard
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    end
                                elseif data.practice.rawdataPractice(n,3) == 2   % Chose target
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    end
                                end
                                
                                responseBreak = 1;
                            elseif keycode(options.buttons.buttonLeft)   % Left
                                
                                if data.practice.rawdataPractice(n,5) == 1   % upper right/lower left
                                    data.practice.rawdataPractice(n,3) = 2;   % Record response
                                elseif data.practice.rawdataPractice(n,5) == 2   % upper left/lower right
                                    data.practice.rawdataPractice(n,3) = 1;   % Record response
                                end
                                
                                
                                % Calculate accuracy
                                if data.practice.rawdataPractice(n,3) == 1   % Chose standard
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    end
                                elseif data.practice.rawdataPractice(n,3) == 2   % Chose target
                                    if data.practice.rawdataPractice(n,2) > length(options.circTextures)/2   % Target was larger
                                        data.practice.rawdataPractice(n,4) = 1;
                                    elseif data.practice.rawdataPractice(n,2) < length(options.circTextures)/2   % Standard was larger
                                        data.practice.rawdataPractice(n,4) = 0;
                                    end
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