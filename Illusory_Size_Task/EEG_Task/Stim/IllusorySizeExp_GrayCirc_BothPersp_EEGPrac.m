% Practice task for illusory size experiment.
% KWK - 20201103

function [options,data] = IllusorySizeExp_GrayCirc_BothPersp_EEGPrac(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;
 
% Setup practice trial structure
options.practice.varList = repmat(fullfact([options.illSizeNum options.hallwayNum options.perspNum]),[2 1]);   % Close/far, hallway/no hallway, UL;LR/UR;LL
options.practice.varList(:,size(options.practice.varList,2)+1) = [ones([length(options.practice.varList)/2,1]); ones([length(options.practice.varList)/2,1])+1];   % Half fixation change, half no fixation change

options.practice.numTrials = length(options.practice.varList);   % Num practice trials
options.practice.trialOrder = randperm(options.practice.numTrials);   % Trial order

data.practice.rawdataPractice = zeros([options.practice.numTrials,2]);
data.practice.rawdataPractice(:,1) = options.practice.varList(options.practice.trialOrder,4);

options.practice.practiceBreak = 0;

% First present instructions
while 1
    switch instSwitch
        
        case 1
            %% First instructions screen - Stimuli
            text1 = 'Here, you will see a checkerboard either in the upper right, lower left, upper left, or lower right part of the screen.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 2;
            farCloseIdx = 1;
            perspIdx = 1;
            updateSwitch = 2;   % Change the perspective and farClose idx every 2 seconds
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            
            % Draw stim
            updateTime = GetSecs;   % Start time
            while 1
                
                % Change stim every 2 seconds               
                if updateTime+2 <= GetSecs
                    updateTime = GetSecs; 
                    
                    switch updateSwitch
                        case 1
                            farCloseIdx = 1;
                            perspIdx = 1;
                            updateSwitch = 2;
                        case 2
                            farCloseIdx = 2;
                            perspIdx = 1;
                            updateSwitch = 3;
                        case 3
                            farCloseIdx = 1;
                            perspIdx = 2;
                            updateSwitch = 4;
                        case 4
                            farCloseIdx = 2;
                            perspIdx = 2;
                            updateSwitch = 1;
                    end
                    
                    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
                    Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
                    Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                        [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                    Screen('Flip',options.windowNum);
                end
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 3;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 10;
                    WaitSecs(.25);
                    break
                end
            end
            
%         case 2
%             %% Second instructions screen
%             text1 = 'These checkerboards will be flickering.';
%             textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
%             
%             % Change hallway type, circ location
%             phaseIdx = 1;
%             hallwayIdx = 2;
%             farCloseIdx = 1;
%             perspIdx = 1;
%             updateSwitch = 2;   % Change the perspective and farClose idx every 2 seconds
%             
%             DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
%             Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
%             Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
%                 [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
%             Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
%             Screen('Flip',options.windowNum);
% 
%             % Draw stim
%             updateTime = GetSecs;   % Start time
%             phaseTime = GetSecs;   
%             while 1
%                 
%                 % Change phase every .25 seconds
%                 if phaseTime+.25 <= GetSecs
%                     phaseTime = GetSecs;
%                     phaseIdx = 3-phaseIdx;
%                 end 
%                 
%                 % Change stim every 2 seconds               
%                 if updateTime+2 <= GetSecs
%                     updateTime = GetSecs; 
%                     
%                     switch updateSwitch
%                         case 1
%                             farCloseIdx = 1;
%                             perspIdx = 1;
%                             updateSwitch = 2;
%                         case 2
%                             farCloseIdx = 2;
%                             perspIdx = 1;
%                             updateSwitch = 3;
%                         case 3
%                             farCloseIdx = 1;
%                             perspIdx = 2;
%                             updateSwitch = 4;
%                         case 4
%                             farCloseIdx = 2;
%                             perspIdx = 2;
%                             updateSwitch = 1;
%                     end
%                 end
%                 
%                 DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
%                 Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
%                 Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
%                     [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
%                 Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
%                 Screen('Flip',options.windowNum);
%                 
%                 [keyisdown, secs, keycode] = KbCheck(options.dev_id);
%                 if keycode(options.buttons.buttonF)
%                     instSwitch = 3;
%                     WaitSecs(.25);
%                     break
%                 elseif keycode(options.buttons.buttonR)
%                     instSwitch = 1;
%                     WaitSecs(.25);
%                     break
%                 elseif keycode(options.buttons.buttonEscape)
%                     instSwitch = 13;
%                     WaitSecs(.25);
%                     break
%                 end
%             end
            
        case 3
            %% Third instructions screen
            text1 = 'Sometimes these checkerboards will appear in a brick hallway.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            updateSwitch = 2;   % Change the perspective and farClose idx every 2 seconds
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            updateTime = GetSecs;   % Start time
            phaseTime = GetSecs;   
            while 1
                
%                 % Change phase every .25 seconds
%                 if phaseTime+.25 <= GetSecs
%                     phaseTime = GetSecs;
%                     phaseIdx = 3-phaseIdx;
%                 end 
                
                % Change stim every 2 seconds               
                if updateTime+2 <= GetSecs
                    updateTime = GetSecs; 
                    
                    switch updateSwitch
                        case 1
                            farCloseIdx = 1;
                            perspIdx = 1;
                            updateSwitch = 2;
                        case 2
                            farCloseIdx = 2;
                            perspIdx = 1;
                            updateSwitch = 3;
                        case 3
                            farCloseIdx = 1;
                            perspIdx = 2;
                            updateSwitch = 4;
                        case 4
                            farCloseIdx = 2;
                            perspIdx = 2;
                            updateSwitch = 1;
                    end
                end
                
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 4;
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
            
        case 4
            
            %% Fourth instructions screen
            text1 = 'Your job will be to keep your eyes fixed on the black and white cross in the center of the screen,';
            text2 = 'and press the LEFT MOUSE KEY whenever it changes from black to blue.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 1;
            updateSwitch = 2;   % Change the perspective and farClose idx every 2 seconds
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            updateTime = GetSecs;   % Start time
            phaseTime = GetSecs;   
            while 1
                
%                 % Change phase every .25 seconds
%                 if phaseTime+.25 <= GetSecs
%                     phaseTime = GetSecs;
%                     phaseIdx = 3-phaseIdx;
%                 end 
                
                % Change stim every 2 seconds               
                if updateTime+2 <= GetSecs
                    updateTime = GetSecs; 
                    
                    if fixChangeIdx == 1
                        fixChangeIdx = 2;
                    elseif fixChangeIdx == 2
                        fixChangeIdx = 1;
                    end
                    
                    if fixChangeIdx == 1
                        switch updateSwitch
                            case 1
                                farCloseIdx = 1;
                                perspIdx = 1;
                                updateSwitch = 2;
                            case 2
                                farCloseIdx = 2;
                                perspIdx = 1;
                                updateSwitch = 3;
                            case 3
                                farCloseIdx = 1;
                                perspIdx = 2;
                                updateSwitch = 4;
                            case 4
                                farCloseIdx = 2;
                                perspIdx = 2;
                                updateSwitch = 1;
                        end
                    end
                end
                
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
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
            %% Fifth instructions screen - start of example trial
            text1 = 'Each trial will start with a screen containing no checkerboard and a gray circle';
            text2 = 'at the location the checkerboard will appear, on top of either an empty hallway or a gray screen.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 1;
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
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
            %% Sixth instructions screen
            text1 = 'Then the checkerboard will very briefly appear.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 1;
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            phaseTime = GetSecs;   
            while 1
                
%                 % Change phase every .25 seconds
%                 if phaseTime+.25 <= GetSecs
%                     phaseTime = GetSecs;
%                     phaseIdx = 3-phaseIdx;
%                 end 
                
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 7;
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
            
        case 7
            %% Seventh instructions screen
            text1 = 'Occasionally during this time, the black square will appear behind the center blue circle.';
            text2 = 'This is when you should respond by clicking the LEFT MOUSE KEY.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 2;
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            phaseTime = GetSecs;   
            while 1
                
%                 % Change phase every .25 seconds
%                 if phaseTime+.25 <= GetSecs
%                     phaseTime = GetSecs;
%                     phaseIdx = 3-phaseIdx;
%                 end 
                
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 8;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 6;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 8
            % Eigth instructions screen
            text1 = 'Next, another screen with only a gray circle will appear.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 1;
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 9;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 7;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 9;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 9
            %% Ninth instructions screen
            text1 = 'Lastly, the fixation will change from blue to the letter ''B'' for a brief time, before the next trial starts.';
            text2 = 'You should try to ONLY blink when you see this ''B''.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            
            % Change hallway type, circ location
            phaseIdx = 1;
            hallwayIdx = 1;
            farCloseIdx = 1;
            perspIdx = 1;
            fixChangeIdx = 1;
            
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-400);
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-350);
            Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
            Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);

            % Draw stim
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 10;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 8;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 10
            %% Tenth instructions screen
            text1 = 'Now lets do some practice trials.';
            text2 = 'Remember to keep your eyes fixed on the small central circle.';
            text3 = 'Let the experimenter know if you have any questions.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            textHeight2 = RectHeight(Screen('TextBounds',options.windowNum,text2));
            textHeight3 = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-450);
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight2/2)-400);
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight3/2)-350);
            Screen('Flip',options.windowNum);

            % Draw stim
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 11;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 9;
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 13;
                    WaitSecs(.25);
                    break
                end
            end
            
        case 11
            %% Practice trials
            % Draw stim
            for n=1:options.practice.numTrials
                
                % Change hallway type, circ location
                phaseIdx = 1;
                hallwayIdx = options.practice.varList(options.practice.trialOrder(n),2);
                farCloseIdx = options.practice.varList(options.practice.trialOrder(n),1);
                perspIdx = options.practice.varList(options.practice.trialOrder(n),3);
                fixChangeIdx = options.practice.varList(options.practice.trialOrder(n),4);
                
                % Start with initial red fixation before starting experiment
                if n==1
                    Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                    Screen('Flip',options.windowNum);
                    WaitSecs(1);
                end
                
                % Start trial presentation
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                syncTime = Screen('Flip',options.windowNum);
                
                % Start with hallway no stim - 800-1200ms w/ cyan fix
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                [~, blankOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (syncTime) - options.flip_interval_correction);
                
                % Present target - 200ms w/ cyan fix
                % Present fix change trial if necessary
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,fixChangeIdx,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                if fixChangeIdx == 1
                    Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                elseif fixChangeIdx == 2
                    Screen('DrawTexture',options.windowNum,options.blueFixation,[],options.fixationRect);   % present fixation
                end
                [~, stimOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (blankOnsetTime+1)-options.flip_interval_correction);
                
                % Monitor for responses
                KbQueueStart(options.dev_id_mouse);
                
                % Present poststim hallway only - 400ms w/ cyan fix
                Screen('DrawTexture',options.windowNum,options.circTextures{hallwayIdx,1,3-phaseIdx,farCloseIdx,1,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen ('FillOval',options.windowNum,options.grayCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen ('FrameOval',options.windowNum,options.fixCol,squeeze(options.singleCirc.circCoordTex(perspIdx,farCloseIdx,:))'+[-1 -2 1 -2]+...
                    [options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2) options.textureCoords(perspIdx,1) options.textureCoords(perspIdx,2)]);
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                [~, stimOffsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (stimOnsetTime+.200)-options.flip_interval_correction);
                
                % Present ITI no hallway - 650-850 w/ red fix
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
                [~, ITIOnsetTime, ~, ~, ~] = Screen('Flip',options.windowNum,...
                    (stimOffsetTime+.400)-options.flip_interval_correction);
                
                % Final screen
                Screen('DrawTexture',options.windowNum,options.circTextures_fixOnly{2,1,2,perspIdx},[],options.textureCoords(perspIdx,:));
                Screen('DrawTexture',options.windowNum,options.blinkFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum,...
                    (ITIOnsetTime+.750)-options.flip_interval_correction);
                
                % Check for response
                [pressed firstPress firstRelease lastPress lastRelease] = KbQueueCheck(options.dev_id_mouse);
                
                % Determine if a response was made correctly (was it a fix change trial?)
                if fixChangeIdx == 1   % No fixation change
                    if firstPress(options.buttons.buttonLeftMouse) > 0
                        data.practice.rawdataPractice(n,2) = 0;
                    else
                        data.practice.rawdataPractice(n,2) = 1;
                    end
                elseif fixChangeIdx == 2   % Fix change
                    if firstPress(options.buttons.buttonLeftMouse) > 0
                        data.practice.rawdataPractice(n,2) = 1;
                    else
                        data.practice.rawdataPractice(n,2) = 0;
                    end
                end
                
                % Stop monitoring
                KbQueueStop(options.dev_id_mouse);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonR)
                    instSwitch = 10;
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
            
            % Present accuracy
            if breakSwitch ~= 1
                data.practice.practiceAcc = mean(data.practice.rawdataPractice(:,2))*100;
                
                WaitSecs(.5);
                text1='Practice trials complete...';
                text2=sprintf('%s%1.0f','Accuracy: ',data.practice.practiceAcc);
                text3='Let the experimenter know when you''re ready to continue...';
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
                        instSwitch = 12;
                        WaitSecs(.25);
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 10;
                        WaitSecs(.25);
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 13;
                        WaitSecs(.25);
                        break
                    end
                end
            end
            
            breakSwitch = 0;
            
        case 12
            %% Last instructions before the experiment starts
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='Remember to keep your eyes focused on the black square in the middle.';
            text4='There will be 4 blocks of trials each 6 minutes long. There will be breaks in between blocks.';
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
                    WaitSecs(.25);
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 10;
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



