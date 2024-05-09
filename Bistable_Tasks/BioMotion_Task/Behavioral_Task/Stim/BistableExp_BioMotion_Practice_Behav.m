% Practice task and instructions for the biological motion task (using the control task).
% KWK - 20201104

function [options,data] = BistableExp_BioMotion_Practice_Behav(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

options.practice.practiceBreak = 0;

% First present instructions
while 1
    switch instSwitch
        
        case 1
            %% First instructions screen - Stimuli
            % Draw stim
            text1 = 'Here, you will see moving dots that line up to look like a walking person.';
            text2 = 'Notice the person can look like they are walking either towards or away from you.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            counter = 0;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                counter = counter+1;
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-400,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-350,options.fixCol);
                
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                 Screen('FillRect',options.windowNum,options.fixCol,...
%                     [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);  
%                 Screen('FillRect',options.windowNum,options.whiteCol,...
%                     [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                Screen('Flip',options.windowNum,...
                    (sync_time + options.time.flipTimes(1,counter))-options.flip_interval_correction);
                
                if counter >= length(options.PLW_stim.updateFlips)
                    sync_time = Screen('Flip',options.windowNum);
                    counter = 0;
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 2;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 2
            %% First instructions screen - Stimuli
            % Draw stim
            text1 = 'Your job is to judge whether the person is walking toward or away from you.';
            text2 = 'Press the UP ARROW if it is WALKING AWAY and the DOWN ARROW if it is WALKING TOWARDS you.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            counter = 0;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                counter = counter+1;
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-400,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-350,options.fixCol);
                
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                 Screen('FillRect',options.windowNum,options.fixCol,...
%                     [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);  
%                 Screen('FillRect',options.windowNum,options.whiteCol,...
%                     [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                Screen('Flip',options.windowNum,...
                    (sync_time + options.time.flipTimes(1,counter))-options.flip_interval_correction);
                
                if counter >= length(options.PLW_stim.updateFlips)
                    sync_time = Screen('Flip',options.windowNum);
                    counter = 0;
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 3;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 1;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 3
            %% Third instructions screen - Stimuli
            % Draw stim
            text1 = 'In the first part of the experiment there will also be moving white dots that pass behind the walker.';
            text2 = 'You should try to ignore these and just focus on the walker.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            counter = 0;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                counter = counter+1;
                
                % Draw control dots
                Screen('DrawDots',options.windowNum,[options.control.dotPosX; options.control.dotPosY],options.control.dotSize,options.whiteCol,options.screenCent');   % Draw moving dot stim
                
                
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                 Screen('FillRect',options.windowNum,options.fixCol,...
%                     [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);  
%                 Screen('FillRect',options.windowNum,options.whiteCol,...
%                     [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                
                % Draw mask
                Screen('DrawTexture',options.windowNum,options.control.occTex,[],...
                    [options.xc-(options.rect(4)/2) options.rect(2) options.xc+(options.rect(4)/2) options.rect(4)]);
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-400,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-350,options.fixCol);
                
                Screen('Flip',options.windowNum,...
                    (sync_time + options.time.flipTimes(1,counter))-options.flip_interval_correction);
                
                % Update position/size of dots based on speed
                options.control.dotRad = options.control.dotRad-options.control.dotSpeedPix;
                options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);
                
                % Update size of control dots
                options.control.dotRad(options.control.dotSize<1) = options.control.maxRad;
                options.control.dotSize(options.control.dotSize<1) = options.control.maxDotSize*options.PPD;
                options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
                options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);
                
                if counter >= length(options.PLW_stim.updateFlips)
                    sync_time = Screen('Flip',options.windowNum);
                    counter = 0;
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 4;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 2;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 4
            %% Fourth instructions screen - Stimuli
            % Draw stim
            text1 = 'The walker will be presented continuously for 2 minutes in each block.';
            text2 = 'You should respond at the beginning of the block and each time it appears to change direction.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            counter = 0;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                counter = counter+1;
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-400,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-350,options.fixCol);
                
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(counter),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                 Screen('FillRect',options.windowNum,options.fixCol,...
%                     [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);  
%                 Screen('FillRect',options.windowNum,options.whiteCol,...
%                     [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                Screen('Flip',options.windowNum,...
                    (sync_time + options.time.flipTimes(1,counter))-options.flip_interval_correction);
                
                if counter >= length(options.PLW_stim.updateFlips)
                    sync_time = Screen('Flip',options.windowNum);
                    counter = 0;
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 5;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 3;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 5
            %% Fourth instructions screen - Practice block
            % Draw stim
            text1 = 'Let''s do a practice block...';
            text2 = 'Please focus on the black dots that make up the walker and try to ignore everything else.';
            text3 = 'Remember to make your initial response as soon as the walker appears on the screen.';
            text4 = 'Let the experimenter know if you have any questions...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            textHeight3 = RectHeight(Screen('TextBounds',options.windowNum,text3));
            textWidth3 = RectWidth(Screen('TextBounds',options.windowNum,text3));
            textHeight4 = RectHeight(Screen('TextBounds',options.windowNum,text4));
            textWidth4 = RectWidth(Screen('TextBounds',options.windowNum,text4));      
            
            Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-500,options.fixCol);
            Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-450,options.fixCol);
            Screen('DrawText',options.windowNum,text3,options.xc-(textWidth3/2),options.yc-(textHeight3/2)-400,options.fixCol);
            Screen('DrawText',options.windowNum,text4,options.xc-(textWidth4/2),options.yc-(textHeight4/2)-350,options.fixCol);
            
            Screen('Flip',options.windowNum);
            
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 6;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 4;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 6
            for m=1:options.practice.numBlocks
                options.practice.time.sync_time(m) = Screen('Flip',options.windowNum);
                for n=1:options.practice.numFlips
                    
                    [~,~,keycode,~] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        options.practice.practiceBreak = 1;
                        break
                    end
                    
                    % Draw control dots
                    Screen('DrawDots',options.windowNum,[options.control.dotPosX; options.control.dotPosY],options.control.dotSize,options.whiteCol,options.screenCent');   % Draw moving dot stim
                    
                    % Draw PLW
                    Screen('DrawDots',options.windowNum,options.practice.PLW_stim.dotPos{options.practice.PLW_stim.updateFlips(n),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
                    Screen('DrawDots',options.windowNum,options.practice.PLW_stim.dotPos{options.practice.PLW_stim.updateFlips(n),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
                    Screen('DrawDots',options.windowNum,options.practice.PLW_stim.dotPos{options.practice.PLW_stim.updateFlips(n),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%                     Screen('FillRect',options.windowNum,options.fixCol,...
%                         [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);
%                     Screen('FillRect',options.windowNum,options.whiteCol,...
%                         [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
                    
                    % Draw mask
                    Screen('DrawTexture',options.windowNum,options.control.occTex,[],...
                        [options.xc-(options.rect(4)/2) options.rect(2) options.xc+(options.rect(4)/2) options.rect(4)]);
                    
                    [~, options.practice.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                        (options.practice.time.sync_time(m)+options.practice.time.flipTimes(m,n))-options.flip_interval_correction);
                    
                    % Monitor for responses
                    [~,~,keycode,~] = KbCheck(options.dev_id2);
                    if keycode(options.buttons.buttonDown)   % Walking toward
                        data.practice.rawdata(m,n,2) = 1;
                    elseif keycode(options.buttons.buttonUp)   % Walking away
                        data.practice.rawdata(m,n,2) = 2;
                    end
                    
                    if options.practice.switchIdx(n) == 1
                        % Update position/size of dots based on speed
                        options.control.dotRad = options.control.dotRad-options.control.dotSpeedPix;
                        options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);
                        
                        % Update size of control dots
                        options.control.dotRad(options.control.dotSize<1) = options.control.maxRad;
                        options.control.dotSize(options.control.dotSize<1) = options.control.maxDotSize*options.PPD;
                        options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
                        options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);
                    elseif options.practice.switchIdx(n) == 2
                        % Update position/size of dots based on speed
                        options.control.dotRad = options.control.dotRad+options.control.dotSpeedPix;
                        options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);
                        
                        % Update size of control dots
                        options.control.dotRad(options.control.dotSize>options.control.maxDotSize*options.PPD) = 1;
                        options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);
                        options.control.dotSize(options.control.dotSize<1) = 1;
                        options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
                        options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);
                    end
                                        
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonR)
                        instSwitch = 5;
                        breakSwitch = 1;
                        WaitSecs(.25);
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 13;
                        breakSwitch = 1;
                        WaitSecs(.25);
                        break
                    end
                    
                    % Escape
                    if breakSwitch == 1
                        break
                    end
                    
                end
            end
            
            % Set the timing values
            if breakSwitch ~= 1
                % Set the timing values
                for i=1:size(options.practice.time.flipTimesActual,1)
                    data.practice.rawdata(i,1:length(options.practice.time.flipTimesActual(i,:)),1) = options.practice.time.flipTimesActual(i,:) - options.practice.time.sync_time(i);
                end
                
                % Record the difference between predicted and actual flip times
                options.practice.time.flipDiffs = data.practice.rawdata(:,:,1) - options.practice.time.flipTimes(:,:);
                
                instSwitch = 12;
                
                cleanUp(options,data,1);
            end
            
            breakSwitch = 0;
            
        case 12
            %% Last screen of practice
            WaitSecs(.5);
            text1='Practice finished...';
            text2='Please let the experimenter know if you have any questions or concerns.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-300,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    breakSwitch = 1;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 5;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
        case 13
            %% Exit if escape is pressed
            options.practice.practiceBreak = 1;
            break
        otherwise
    end
end
% Reset the check variable
options.practice.practiceCheck = 0;
end




