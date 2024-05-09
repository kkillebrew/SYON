% Practice task and instructions for the biological motion task (using the control task).
% KWK - 20201104

function [options,data] = BistableExp_BinoRiv_Practice_Behav(options,data)

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
            text1 = 'Here, you will see alternating red and blue diagonal lines in a circle at the center of the screen.';
            text2 = 'Your job is to keep your eyes fixed on the cross in the center of the screen,';
            text3 = 'and press the LEFT ARROW if you see the BLUE lines or the RIGHT ARROW if you see the RED lines.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            textHeight3 = RectHeight(Screen('TextBounds',options.windowNum,text3));
            textWidth3 = RectWidth(Screen('TextBounds',options.windowNum,text3));
            counter = 1;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                if GetSecs >= sync_time+2
                    sync_time = GetSecs;
                    counter = 3-counter;
                end
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-450,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-400,options.fixCol);
                Screen('DrawText',options.windowNum,text3,options.xc-(textWidth3/2),options.yc-(textHeight3/2)-350,options.fixCol);
                
                switch counter
                    case 1
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.right.gratingAnnTexture,...
                            [],options.sp.right.gratingAnnRect);
                    case 2
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.left.gratingAnnTexture,...
                            [],options.sp.left.gratingAnnRect);
                end
                
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                
                Screen('Flip',options.windowNum);
                
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
            %% Second instructions screen - Stimuli
            % Draw stim
            text1 = 'Sometimes you may also see a mixture of the two.';
            text2 = 'In this case you will press the DOWN ARROW.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            while 1
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-450,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-400,options.fixCol);
                
                Screen('DrawTexture',options.windowNum,...
                    options.sp.both.gratingAnnTexture,...
                    [],options.sp.both.gratingAnnRect);
                
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                
                Screen('Flip',options.windowNum);
                
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
            text1 = 'The lines will be presented continuously for 2 minutes in each block.';
            text2 = 'You should respond at the beginning of the block and each time it appears to change.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textWidth2 = RectWidth(Screen('TextBounds',options.windowNum,text2));
            counter = 1;
            sync_time = Screen('Flip',options.windowNum);
            while 1
                if GetSecs >= sync_time+2
                    sync_time = GetSecs;
                    counter = 3-counter;
                end
                
                Screen('DrawText',options.windowNum,text1,options.xc-(textWidth/2),options.yc-(textHeight/2)-450,options.fixCol);
                Screen('DrawText',options.windowNum,text2,options.xc-(textWidth2/2),options.yc-(textHeight2/2)-400,options.fixCol);
                
                switch counter
                    case 1
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.right.gratingAnnTexture,...
                            [],options.sp.right.gratingAnnRect);
                    case 2
                        Screen('DrawTexture',options.windowNum,...
                            options.sp.left.gratingAnnTexture,...
                            [],options.sp.left.gratingAnnRect);
                end
                
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                
                Screen('Flip',options.windowNum);
                
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
            %% Fourth instructions screen - Practice block
            % Draw stim
            text1 = 'Let''s do a practice block...';
            text2 = 'Please keep your eyes fixed on the cross in the center of the screen.';
            text3 = 'Remember to make your initial response as soon as the lines appears on the screen.';
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
            for m=1:options.practice.numBlocks
                options.practice.time.sync_time(m) = Screen('Flip',options.windowNum);
                for n=1:options.practice.numFlips
                    
                    [~,~,keycode,~] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        options.practice.practiceBreak = 1;
                        break
                    end
                    
                    data.practice.rawdata(m,n,3) = options.practice.gratValue(n);
                    
                    Screen('DrawTexture',options.windowNum,options.sp.frame.frameTexture);
                    
                    switch data.practice.rawdata(m,n,3)
                        case 1
                            Screen('DrawTexture',options.windowNum,...
                                options.sp.right.gratingAnnTexture,...
                                [],options.sp.right.gratingAnnRect);
                        case 2
                            Screen('DrawTexture',options.windowNum,...
                                options.sp.left.gratingAnnTexture,...
                                [],options.sp.left.gratingAnnRect);
                        case 3
                            Screen('DrawTexture',options.windowNum,...
                                options.sp.both.gratingAnnTexture,...
                                [],options.sp.both.gratingAnnRect);
                    end
                    
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                    
                    [~, options.practice.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                        (options.practice.time.sync_time(m)+options.practice.time.flipTimes(m,n))-options.flip_interval_correction);
                    
                    % Monitor for responses
                    [~,~,keycode,~] = KbCheck(options.dev_id2);
                    if keycode(options.buttons.buttonLeft)   % left red
                        data.practice.rawdata(m,n,2) = 1;
                    elseif keycode(options.buttons.buttonRight)   % right blue
                        data.practice.rawdata(m,n,2) = 2;
                    elseif keycode(options.buttons.buttonDown)   % Either
                        data.practice.rawdata(m,n,2) = 3;
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