% Present instructions, examples, and practice trials for the gamma
% oscillation experiment.

function [options,data] = GamOscExpPractice(options,data)

%% Present instructions and examples

% Switch variable to keep track of which step in the instructions you are
% on. Allows the user to go forward or backward in the instructions
% process.
instSwitch = 1;
breakSwitch = 0;

data.practice.rawdataPractice = zeros([options.practice.numPracTrials,1]);
options.practice.practiceBreak = 0;
nPracTrials = 0;

while 1
    switch instSwitch
        case 1
            % First instructions screen
            text1 = 'For each trial, you will see a circular grating, presented below.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            % Make sine wave for instructions
            origDegsPrac = 90;   % Initial phase of the sin wave
            imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
            imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
            im(:,:,1) = imHolder;
            im(:,:,2) = imHolder;
            im(:,:,3) = imHolder;
            im(:,:,4) = options.stim.Z*255;
            clear imHolder
            circTexturePrac = Screen('MakeTexture',options.windowNum,im);
            Screen('DrawTexture',options.windowNum,circTexturePrac,[],[options.xc-((options.stim.initSize*options.PPD)/2),...
                options.yc-((options.stim.initSize*options.PPD)/2),options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            clear circTexturePrac keycode
            
        case 2
            
            % Second instructions screen
            text2 = 'The stripes will be moving towards the center...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            options.practice.timeOnScreenPrac = options.stim.pixPerCyc;
            slowRatePrac = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
            fastRatePrac = (360*options.stim.cycPerDeg*1.5)/options.wInfoNew.hz;
            % Make the textures for the slow rate
            % Make one texture per screen flip
            for j=1:(options.practice.timeOnScreenPrac*2)
                % Draw image to a texture
                circTexturePrac{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + slowRatePrac;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            counter = 0;
            WaitSecs(.5);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                counter = counter+1;
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-150,[0 0 0]);
                Screen('DrawTexture',options.windowNum,circTexturePrac{counter},[],[options.xc-((options.stim.initSize*options.PPD)/2),...
                    options.yc-((options.stim.initSize*options.PPD)/2),options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                Screen('Flip',options.windowNum);
                if counter >= length(circTexturePrac)
                    counter = 0;
                end
                if keycode(options.buttons.buttonF)
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            clear keycode
            
        case 3
            
            % Third instructions screen
            text3 = 'After a few moments, the speed will increase...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            options.practice.timeOnScreenPrac = 2;
            options.practice.speedUpTimeOnScreenPrac = 1;
            origDegsPrac = 90;
            % Make the textures for the slow rate
            % Make one texture per screen flip
            for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                % Draw image to a texture
                circTexturePrac{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + slowRatePrac;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            % Make the textures for the fast rate
            for j=length(circTexturePrac)+1:(length(circTexturePrac)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                % Draw image to a texture
                circTexturePrac{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + fastRatePrac;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            counter = 0;
            WaitSecs(.5);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                counter = counter+1;
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-150,[0 0 0]);
                Screen('DrawTexture',options.windowNum,circTexturePrac{counter},[],[options.xc-((options.stim.initSize*options.PPD)/2),...
                    options.yc-((options.stim.initSize*options.PPD)/2),options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                Screen('Flip',options.windowNum);
                if counter >= length(circTexturePrac)
                    counter = 0;
                end
                if keycode(options.buttons.buttonSpace)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonF)
                    instSwitch = 4;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 2;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            clear keycode circTexturePrac
            
        case 4
            
            % Fourth instrcutions screen
            text4 = 'Your job is to press the LEFT MOUSE button as soon as possible after the speed up occurs.';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            origDegsPrac = 90;
            % Make the textures for the slow rate
            % Make one texture per screen flip
            for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                % Draw image to a texture
                circTexturePrac{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + slowRatePrac;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            slowNumPrac = length(circTexturePrac);
            % Make the textures for the fast rate
            for j=length(circTexturePrac)+1:(length(circTexturePrac)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                % Draw image to a texture
                circTexturePrac{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + fastRatePrac;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            counter = 0;
            WaitSecs(.5);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                counter = counter+1;
                DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2)-150,[0 0 0]);
                Screen('DrawTexture',options.windowNum,circTexturePrac{counter},[],[options.xc-((options.stim.initSize*options.PPD)/2),...
                    options.yc-((options.stim.initSize*options.PPD)/2),options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                if counter >= slowNumPrac+1 && counter <= slowNumPrac+30
                    DrawFormattedText(options.windowNum,'PRESS','center','center',[255 0 0]);
                end
                Screen('Flip',options.windowNum);
                if counter >= length(circTexturePrac)
                    counter = 0;
                end
                if keycode(options.buttons.buttonSpace)
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonF)
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 3;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            clear keycode
            
            
        case 5
            %% Initial practice trial - easy
            WaitSecs(.5);
            text1='Remember to keep your eyes focused on the black square in the middle.';
            text2='Some trials will be difficult, just try and do your best!';
            text3='We''ll start with a practice trial where the speed up is fast.';
            text4='Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),[0 0 0]);
            
            Screen('Flip',options.windowNum);
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
                    instSwitch = 14;
                    break
                end
            end
            
            
        case 6
            % Create the initial circular sine wave grating using function circsine
            rawdataHolder = 0;   % Response variable
            origDegsPrac = 90;   % Initial phase of the sin wave
            imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
            imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
            im(:,:,1) = imHolder;
            im(:,:,2) = imHolder;
            im(:,:,3) = imHolder;
            im(:,:,4) = options.stim.Z*255;
            clear imHolder
            
            % What rate will the sin wave change at (in circle degrees). In other
            % words, how many degrees do you need to shift per screen flip given
            % the refresh rate?
            slowRate = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
            fastRate = (360*options.stim.cycPerDeg*1.5)/options.wInfoNew.hz;
            
            % Make the textures for the slow rate
            % Make one texture per screen flip
            % So if you present stim for 2 seconds total textures = 2*hz
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                % Draw image to a texture
                circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + slowRate;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            % How many textures are present for the slow speed
            slowTexs = length(circTexture);
            
            % Make the textures for the fast rate
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            for j=length(circTexture)+1:(length(circTexture)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                % Draw image to a texture
                circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + fastRate;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            % How many textures are present for the slow speed
            fastTexs = length(circTexture)-slowTexs;
            
            % Draw
            % First present fixation for .5s
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            WaitSecs(options.stim.preStimIntervalPrac);
            % 3rd col: Time of onset of relative to exp start
            trialStart = GetSecs;
            for i=1:length(circTexture)
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                
                Screen('DrawTexture',options.windowNum,circTexture{i},[],[options.xc-((options.stim.initSize*options.PPD)/2),options.yc-((options.stim.initSize*options.PPD)/2),...
                    options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                Screen('Flip',options.windowNum);
                
                % Check to see if this tex pres is the start of the speed change
                if i==slowTexs+1
                    % 4th col: Onset of speed change relative to trial start
                    % Start monitoring for key presses
%                     KbQueueFlush(options.dev_id);
                    respTime = GetSecs;
                end
                
                % If speed up has happened check for response
                if i>=slowTexs+1
%                     [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(options.dev_id);
%                     if any(firstPress(options.buttons.buttonSpace))
%                         rawdataHolder = GetSecs-respTime;
%                     end
                    % Use this for button box
%                     options.responseData(n) = io64(object,options.addressIn);
%                     options.responseData(n) = inp(options.addressIn);
                    % Use this for mouse clicks
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    if buttonsHolder(1) == 1   % Only checks for left button
                        rawdataHolder = GetSecs-respTime;
                    end
                end
                
            end
            if instSwitch ~= 12
                if rawdataHolder==0   % If no response
                    feedBackText1 = 'MISS';
                    feedBackText2 = 'You did not press the left mouse button on time.';
                    rawdataHolder = NaN;   % If no response make NaN
                else   % If response w/in the time limit
                    feedBackText1 = 'OK';
                    feedBackText2 = sprintf('%s%.02f%s','You pressed the left mouse button in ',rawdataHolder,' seconds.');
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText1));
                DrawFormattedText(options.windowNum,feedBackText1,'center',options.yc-(textHeight/2)-5,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText2));
                DrawFormattedText(options.windowNum,feedBackText2,'center',options.yc-(textHeight/2)+100,[0 0 0]);
%                 Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonSpace)
                        instSwitch = 7;
                        break
                    elseif keycode(options.buttons.buttonF)
                        instSwitch = 7;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 4;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                end
            end
            Screen('Close',cell2mat(circTexture(:)));
            clear circTexture slowTexs fastTexs
            
        case 7
            %% Initial practice trial - hard (normal)
            WaitSecs(.5);
            text1='Now we''ll do another practice trial. The change will be a little harder to see.';
            text2='Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 8;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 5;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            
        case 8
            
            % Create the initial circular sine wave grating using function circsine
            rawdataHolder = 0;   % Response variable
            origDegsPrac = 90;   % Initial phase of the sin wave
            imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
            imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
            im(:,:,1) = imHolder;
            im(:,:,2) = imHolder;
            im(:,:,3) = imHolder;
            im(:,:,4) = options.stim.Z*255;
            clear imHolder
            
            % What rate will the sin wave change at (in circle degrees). In other
            % words, how many degrees do you need to shift per screen flip given
            % the refresh rate?
            slowRate = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
            fastRate = (360*options.stim.cycPerDeg*1)/options.wInfoNew.hz;
            
            % Make the textures for the slow rate
            % Make one texture per screen flip
            % So if you present stim for 2 seconds total textures = 2*hz
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                % Draw image to a texture
                circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + slowRate;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            % How many textures are present for the slow speed
            slowTexs = length(circTexture);
            
            % Make the textures for the fast rate
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            for j=length(circTexture)+1:(length(circTexture)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                % Draw image to a texture
                circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                % Update phase
                origDegsPrac = origDegsPrac + fastRate;
                % Update im
                clear imHolder
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
            end
            % How many textures are present for the slow speed
            fastTexs = length(circTexture)-slowTexs;
            
            % Draw
            % First present fixation for .5s
            Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
            Screen('Flip',options.windowNum);
            WaitSecs(options.stim.preStimIntervalPrac);
            % 3rd col: Time of onset of relative to exp start
            trialStart = GetSecs;
            for i=1:length(circTexture)
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
                
                Screen('DrawTexture',options.windowNum,circTexture{i},[],[options.xc-((options.stim.initSize*options.PPD)/2),options.yc-((options.stim.initSize*options.PPD)/2),...
                    options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                Screen('Flip',options.windowNum);
                
                % Check to see if this tex pres is the start of the speed change
                if i==slowTexs+1
                    % 4th col: Onset of speed change relative to trial start
                    % Start monitoring for key presses
%                     KbQueueFlush(options.dev_id);
                    respTime = GetSecs;
                end
                
                % If speed up has happened check for response
                if i>=slowTexs+1
%                     [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(options.dev_id);
%                     if any(firstPress(options.buttons.buttonSpace))
%                         rawdataHolder = GetSecs-respTime;
%                     end
                    [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                    if buttonsHolder(1) == 1   % Only checks for left button
                        rawdataHolder = GetSecs-respTime;
                    end
                end
                
            end
            
            if instSwitch ~= 14
                if rawdataHolder==0   % If no response
                    feedBackText1 = 'MISS';
                    feedBackText2 = 'You did not press the left mouse button on time.';
                    rawdataHolder = NaN;   % If no response make NaN
                else   % If response w/in the time limit
                    feedBackText1 = 'OK';
                    feedBackText2 = sprintf('%s%.02f%s','You pressed the left mouse button in ',rawdataHolder,' seconds.');
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText1));
                DrawFormattedText(options.windowNum,feedBackText1,'center',options.yc-(textHeight/2)-5,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText2));
                DrawFormattedText(options.windowNum,feedBackText2,'center',options.yc-(textHeight/2)+100,[0 0 0]);
                Screen('FillRect',options.windowNum,[0 0 0],[options.xc-5,options.yc-5,options.xc+5,options.yc+5]);
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonSpace)
                        instSwitch = 9;
                        break
                    elseif keycode(options.buttons.buttonF)
                        instSwitch = 9;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 7;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                end
            end
            
            Screen('Close',cell2mat(circTexture(:)));
            clear circTexture slowTexs fastTexs rawdataHolder
            
            
        case 9
            WaitSecs(.5);
            text1='Now let''s do some more practice trials.';
            text2='We''ll do three more trials at this speed.';
            text3='Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,[0 0 0]);
            
            Screen('Flip',options.windowNum);
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
                    instSwitch = 14;
                    break
                end
            end
            
        case 10
            %% Practice trials (3)
            for n=1:3
                % Create the initial circular sine wave grating using function circsine
                origDegsPrac = 90;   % Initial phase of the sin wave
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
                clear imHolder
                
                % Reset data holder var
                rawdataHolder = 0;
                
                % What rate will the sin wave change at (in circle degrees). In other
                % words, how many degrees do you need to shift per screen flip given
                % the refresh rate?
                data.practice.slowRate = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
                data.practice.fastRate = (360*options.stim.cycPerDeg*1)/options.wInfoNew.hz;
                
                % Make the textures for the slow rate
                % Make one texture per screen flip
                % So if you present stim for 2 seconds total textures = 2*hz
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    % Draw image to a texture
                    circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                    % Update phase
                    origDegsPrac = origDegsPrac + slowRate;
                    % Update im
                    clear imHolder
                    imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                    imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                    im(:,:,1) = imHolder;
                    im(:,:,2) = imHolder;
                    im(:,:,3) = imHolder;
                    im(:,:,4) = options.stim.Z*255;
                end
                % How many textures are present for the slow speed
                slowTexs = length(circTexture);
                
                % Make the textures for the fast rate
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                for j=length(circTexture)+1:(length(circTexture)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    % Draw image to a texture
                    circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                    % Update phase
                    origDegsPrac = origDegsPrac + fastRate;
                    % Update im
                    clear imHolder
                    imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                    imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                    im(:,:,1) = imHolder;
                    im(:,:,2) = imHolder;
                    im(:,:,3) = imHolder;
                    im(:,:,4) = options.stim.Z*255;
                end
                % How many textures are present for the slow speed
                fastTexs = length(circTexture)-slowTexs;
                
                % Draw
                % First present fixation for .5s
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.preStimIntervalPrac);
                % 3rd col: Time of onset of relative to exp start
                trialStart = GetSecs;
                for i=1:length(circTexture)
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    if instSwitch == 14
                        break
                    end
                    
                    Screen('DrawTexture',options.windowNum,circTexture{i},[],[options.xc-((options.stim.initSize*options.PPD)/2),options.yc-((options.stim.initSize*options.PPD)/2),...
                        options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                    Screen('Flip',options.windowNum);
                    
                    % Check to see if this tex pres is the start of the speed change
                    if i==slowTexs+1
                        % 4th col: Onset of speed change relative to trial start
                        % Start monitoring for key presses
%                         KbQueueFlush(options.dev_id);
                        respTime = GetSecs;
                    end
                    
                    % If speed up has happened check for response
                    if i>=slowTexs+1
%                         [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(options.dev_id);
%                         if any(firstPress(options.buttons.buttonSpace))
%                             rawdataHolder = GetSecs-respTime;
%                         end
                        [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                        if buttonsHolder(1) == 1   % Only checks for left button
                            rawdataHolder = GetSecs-respTime;
                        end
                    end
                    
                end
                
                if instSwitch == 14
                    break
                end
                
                if rawdataHolder==0   % If no response
                    feedBackText1 = 'MISS';
                    feedBackText2 = 'You did not press the left mouse button on time.';
                    rawdataHolder = NaN;   % If no response make NaN
                else   % If response w/in the time limit
                    feedBackText1 = 'OK';
                    feedBackText2 = sprintf('%s%.02f%s','You pressed the left mouse button in ',rawdataHolder,' seconds.');
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText1));
                DrawFormattedText(options.windowNum,feedBackText1,'center',options.yc-(textHeight/2)-5,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText2));
                DrawFormattedText(options.windowNum,feedBackText2,'center',options.yc-(textHeight/2)+100,[0 0 0]);
                Screen('FillRect',options.windowNum,[0 0 0],[options.xc-5,options.yc-5,options.xc+5,options.yc+5]);
                Screen('Flip',options.windowNum);
                
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonSpace)
                        instSwitch = 11;
                        break
                    elseif keycode(options.buttons.buttonF)
                        instSwitch = 11;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 9;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                end
                
                if instSwitch == 14
                    break
                end
                
                Screen('Close',cell2mat(circTexture(:)));
                clear circTexture slowTexs fastTexs
            end
            
        case 11
            WaitSecs(.5);
            text1='Now we''ll do 10 practice trials that are like what you''ll do in the real experiment.';
            text2='Each trial will start 1s after the end of the last trial. They will be much faster paced,';
            text3='and will not wait for you to respond. Let the experimenter know when you are ready...';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    instSwitch = 12;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 9;
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end           
            
        case 12
            %% Practice trials (10)
            for n=nPracTrials+1:options.practice.numPracTrials+nPracTrials
                % Create the initial circular sine wave grating using function circsine
                origDegsPrac = 90;   % Initial phase of the sin wave
                imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                im(:,:,1) = imHolder;
                im(:,:,2) = imHolder;
                im(:,:,3) = imHolder;
                im(:,:,4) = options.stim.Z*255;
                clear imHolder
                
                % What rate will the sin wave change at (in circle degrees). In other
                % words, how many degrees do you need to shift per screen flip given
                % the refresh rate?
                data.practice.slowRate = (360*options.stim.cycPerDeg*options.stim.contractVelocity)/options.wInfoNew.hz;
                data.practice.fastRate = (360*options.stim.cycPerDeg*1)/options.wInfoNew.hz;
                
                % Make the textures for the slow rate
                % Make one texture per screen flip
                % So if you present stim for 2 seconds total textures = 2*hz
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                for j=1:options.wInfoNew.hz*options.practice.timeOnScreenPrac
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    % Draw image to a texture
                    circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                    % Update phase
                    origDegsPrac = origDegsPrac + slowRate;
                    % Update im
                    clear imHolder
                    imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                    imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                    im(:,:,1) = imHolder;
                    im(:,:,2) = imHolder;
                    im(:,:,3) = imHolder;
                    im(:,:,4) = options.stim.Z*255;
                end
                % How many textures are present for the slow speed
                slowTexs = length(circTexture);
                
                % Make the textures for the fast rate
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                for j=length(circTexture)+1:(length(circTexture)+1) + (options.wInfoNew.hz*options.practice.speedUpTimeOnScreenPrac)
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    % Draw image to a texture
                    circTexture{j} = Screen('MakeTexture',options.windowNum,im);
                    % Update phase
                    origDegsPrac = origDegsPrac + fastRate;
                    % Update im
                    clear imHolder
                    imHolder = (circsine(options.stim.initSize*options.PPD,options.stim.pixPerCyc,1,-1,deg2rad(origDegsPrac),2,1)+1)*127.5;
                    imHolder = 255*options.displayInfo.linearClut(round(imHolder)+1);
                    im(:,:,1) = imHolder;
                    im(:,:,2) = imHolder;
                    im(:,:,3) = imHolder;
                    im(:,:,4) = options.stim.Z*255;
                end
                % How many textures are present for the slow speed
                fastTexs = length(circTexture)-slowTexs;
                
                % Draw
                % First present fixation for .5s
                Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
                Screen('Flip',options.windowNum);
                WaitSecs(options.stim.preStimIntervalPrac);
                % 3rd col: Time of onset of relative to exp start
                trialStart = GetSecs;
                for i=1:length(circTexture)
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                    if instSwitch == 14
                        break
                    end
                    
                    Screen('DrawTexture',options.windowNum,circTexture{i},[],[options.xc-((options.stim.initSize*options.PPD)/2),options.yc-((options.stim.initSize*options.PPD)/2),...
                        options.xc+((options.stim.initSize*options.PPD)/2),options.yc+((options.stim.initSize*options.PPD)/2)]);
                    Screen('Flip',options.windowNum);
                    
                    % Check to see if this tex pres is the start of the speed change
                    if i==slowTexs+1
                        % 4th col: Onset of speed change relative to trial start
                        % Start monitoring for key presses
%                         KbQueueFlush(options.dev_id);
                        respTime = GetSecs;
                    end
                    
                    % If speed up has happened check for response
                    if i>=slowTexs+1
                        % Use this for mouse clicks
                        [~,~,buttonsHolder,~,~,~] = GetMouse(options.windowNum);
                        if buttonsHolder(1) == 1   % Only checks for left button
                            data.practice.rawdataPractice(n) = GetSecs-respTime;
                        end
                    end
                    
                end
                
                if instSwitch == 14
                    break
                end
                
                if data.practice.rawdataPractice(n)==0   % If no response
                    feedBackText1 = 'MISS';
                    feedBackText2 = 'You did not press the left mouse button on time.';
                    data.practice.rawdataPractice(n) = NaN;   % If no response make NaN
                else   % If response w/in the time limit
                    feedBackText1 = 'OK';
                    feedBackText2 = sprintf('%s%.02f%s','You pressed the left mouse button in ',data.practice.rawdataPractice(n),' seconds.');
                end
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText1));
                DrawFormattedText(options.windowNum,feedBackText1,'center',options.yc-(textHeight/2)-5,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,feedBackText2));
                DrawFormattedText(options.windowNum,feedBackText2,'center',options.yc-(textHeight/2)+100,[0 0 0]);
                Screen('FillRect',options.windowNum,[0 0 0],[options.xc-5,options.yc-5,options.xc+5,options.yc+5]);
                Screen('Flip',options.windowNum);
                
                time_now = GetSecs;
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    
                    if GetSecs > time_now+1
                        break
                    end
                    
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonSpace)
                        instSwitch = 10;
                        break
                    elseif keycode(options.buttons.buttonF)
                        instSwitch = 10;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 8;
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                end
                
                Screen('Close',cell2mat(circTexture(:)));
                clear circTexture slowTexs fastTexs
            end
            
            if instSwitch ~= 14
                WaitSecs(.5);
                text1='Practice trials complete...';
                text2='Would you like to do more practice trials? (Press ''R'')';
                text3='Otherwise, let the experimenter know when you are ready...';
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
                DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
                DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
                textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,[0 0 0]);
                
                Screen('Flip',options.windowNum);
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                    if keycode(options.buttons.buttonF)
                        instSwitch = 13;
                        break
                    elseif keycode(options.buttons.buttonR)
                        instSwitch = 11;
                        % If this is an additional round of prac trials, add more rows to prac rawdata
                        nPracTrials = length(data.practice.rawdataPractice);
                        data.practice.rawdataPractice(nPracTrials+1:nPracTrials+options.practice.numPracTrials) = zeros([options.practice.numPracTrials 1]);
                        break
                    elseif keycode(options.buttons.buttonEscape)
                        instSwitch = 14;
                        break
                    end
                end
            end
            
        case 13
            %% Present instructions one more time before the start of block to
            % ensure there is no confusion.
            WaitSecs(.5);
            text1='Now we will start the experiment.';
            text2='Please let the experimenter know if you have any questions or concerns.';
            text3='It will take about 18 minutes total, with breaks every six minutes.';
            text5='Please try your best to blink ONLY when the small white cross appears before the circular grating appears.';
            text6='Lastly, during some trials there will be no speed change. Make sure to not respond during these trials.';
            text7='LAST SCREEN BEFORE EXPERIMENT START!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
            DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
            DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
            DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
            DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+50,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
            DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)+100,[0 0 0]);
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text7));
            DrawFormattedText(options.windowNum,text7,'center',options.yc-(textHeight/2)+150,[0 0 0]);
            
            Screen('Flip',options.windowNum);
            [keyisdown, secs, keycode] = KbCheck(options.dev_id);
            while 1
                [keyisdown, secs, keycode] = KbCheck(options.dev_id);
                if keycode(options.buttons.buttonF)
                    breakSwitch = 1;
                    break
                elseif keycode(options.buttons.buttonR)
                    instSwitch = 11;
                    % If this is an additional round of prac trials, add more rows to prac rawdata
                    nPracTrials = length(data.practice.rawdataPractice);
                    data.practice.rawdataPractice(nPracTrials+1:nPracTrials+options.practice.numPracTrials) = zeros([options.practice.numPracTrials 1]);
                    break
                elseif keycode(options.buttons.buttonEscape)
                    instSwitch = 14;
                    break
                end
            end
            
            if breakSwitch == 1
                break
            end
            
        case 14
            %% Exit if escape is pressed
            options.practice.practiceBreak = 1;
            break
        otherwise
    end
end
% Reset the check variable
options.practice.practiceCheck = 0;

end