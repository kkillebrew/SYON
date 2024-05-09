% Bistable biological motion control task. Runs a 2 minute control run of the bistable biological motion task. Participants are instructed to
% press the left or right mouse button when they see a change in motion direction.
% KWK - 20201005

function [options,data] = BistableExp_BioMotion_Control_Behav(options,data)

%% Start the experiment
% Instructions/Start screen
% Last instructions before the experiment starts
text1='Now we will start the first block of the experiment.';
text2='Remember, ignore the moving white dots and pay attention to the small walking figure.';
text3='Press the DOWN ARROW for WALKING TOWARDS and UP ARROW for WALKING AWAY.';
text4='Please let the experimenter know if you have any questions or concerns.';
text5='Tell the experimenter when you are ready to continue...';
text6='LAST SCREEN BEFORE EXPERIMENT START!';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
DrawFormattedText(options.windowNum,text3,'center',options.yc-(textHeight/2)-50,options.whiteCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text4));
DrawFormattedText(options.windowNum,text4,'center',options.yc-(textHeight/2),options.whiteCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text5));
DrawFormattedText(options.windowNum,text5,'center',options.yc-(textHeight/2)+50,options.whiteCol);
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text6));
DrawFormattedText(options.windowNum,text6,'center',options.yc-(textHeight/2)+100,options.whiteCol);
Screen('Flip',options.windowNum);

while 1
    [~, ~, keycode] = KbCheck(options.dev_id);
    if keycode(options.buttons.buttonF)
        break
    end
    if keycode(options.buttons.buttonEscape)
        options.practice.practiceBreak = 1;
        break
    end
end

%% Draw the stimuli
% Start trial presentation
if options.practice.practiceBreak ~= 1
    for m=1:options.control.numBlocks
        
        [~, ~, keycode] = KbCheck(options.dev_id);
        if keycode(options.buttons.buttonEscape)
            options.practice.practiceBreak = 1;
            break
        end
        
        % Start eyetracking for this block
        if options.eyeTracking == 1
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording');
            % record a few samples before we actually start displaying
            % otherwise you may lose a few msec of data
            WaitSecs(1.1);
        end
        
        options.control.time.sync_time(m) = Screen('Flip',options.windowNum);
        for n=1:options.numFlips
            
            [~,~,keycode,~] = KbCheck(options.dev_id);
            if keycode(options.buttons.buttonEscape)
                options.practice.practiceBreak = 1;
                break
            end
            
            % Draw control dots
            Screen('DrawDots',options.windowNum,[options.control.dotPosX; options.control.dotPosY],options.control.dotSize,options.whiteCol,options.screenCent');   % Draw moving dot stim
            
            % Draw PLW
            Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},options.screenCent');   % Draw 'head'
            Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},options.screenCent');   % Draw 'left side'
            Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{options.PLW_stim.updateFlips(n),3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},options.screenCent');   % Draw 'right side'
%             Screen('FillRect',options.windowNum,options.fixCol,...
%                 [options.fixLoc(1)-options.fixSize options.fixLoc(2)-options.fixSize  options.fixLoc(1)+options.fixSize  options.fixLoc(2)+options.fixSize]);
%             Screen('FillRect',options.windowNum,options.whiteCol,...
%                 [options.fixLoc(1)-options.fixSize/2 options.fixLoc(2)-options.fixSize/2  options.fixLoc(1)+options.fixSize/2  options.fixLoc(2)+options.fixSize/2]);
            
            % Draw mask
            Screen('DrawTexture',options.windowNum,options.control.occTex,[],...
                [options.xc-(options.rect(4)/2) options.rect(2) options.xc+(options.rect(4)/2) options.rect(4)]);
            
            [~, options.control.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                (options.control.time.sync_time(m)+options.control.time.flipTimes(m,n))-options.flip_interval_correction);
            
            % Monitor for responses
            [~,~,keycode,~] = KbCheck(options.dev_id2);
            if keycode(options.buttons.buttonDown)   % Walking toward
                data.control.rawdata(m,n,2) = 1;
                
                % Send eyetracker trigger for each response made
                if options.eyeTracking == 1
                    et_message = '1 - Towards (Control)';
                    Eyelink('Message', et_message);
                end
            elseif keycode(options.buttons.buttonUp)   % Walking away
                data.control.rawdata(m,n,2) = 2;
                
                % Send eyetracker trigger for each response made
                if options.eyeTracking == 1
                    et_message = '2 - Away (Control)';
                    Eyelink('Message', et_message);
                end
            end
            
            if options.control.switchIdx(n) == 1
                % Update position/size of dots based on speed
                options.control.dotRad = options.control.dotRad-options.control.dotSpeedPix;
                options.control.dotSize = (options.control.maxDotSize*options.PPD).*(options.control.dotRad/options.control.maxRad);
                
                % Update size of control dots
                options.control.dotRad(options.control.dotSize<1) = options.control.maxRad;
                options.control.dotSize(options.control.dotSize<1) = options.control.maxDotSize*options.PPD;
                options.control.dotPosX = options.control.dotRad .* cosd(options.control.dotAngle);
                options.control.dotPosY = options.control.dotRad .* sind(options.control.dotAngle);
            elseif options.control.switchIdx(n) == 2
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
            
        end
        % End eyetracking for current block
        if options.eyeTracking == 1
            %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
            %             Eyelink('Message', et_message);
            
            WaitSecs(0.1);
            % stop the recording of eye-movements for the current trial
            Eyelink('StopRecording');
        end
        
        cleanUp(options,data,1);
    end
    
    
    [~,~,keycode,~] = KbCheck(options.dev_id);
    while ~keycode(options.buttons.buttonF) && ~keycode(options.buttons.buttonEscape)
        [~,~,keycode,~] = KbCheck(options.dev_id);
        text1 = 'The first portion of the experiment is finished.';
        text2 = 'Please tell experimenter.';
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
        DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,options.whiteCol);
        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text2));
        DrawFormattedText(options.windowNum,text2,'center',options.yc-(textHeight/2)-100,options.whiteCol);
        Screen('Flip',options.windowNum);
    end
    
%     % End eyetracking
%     if options.eyeTracking == 1
%         %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
%         %             Eyelink('Message', et_message);
%         
%         WaitSecs(0.1);
%         
%         stopCMRREyeTracking(options);
%     end
    
    % Set the timing values
    for i=1:size(options.control.time.flipTimesActual,1)
        data.control.rawdata(i,1:length(options.control.time.flipTimesActual(i,:)),1) = options.control.time.flipTimesActual(i,:) - options.control.time.sync_time(i);
    end
    
    % Record the difference between predicted and actual flip times
    options.control.time.flipDiffs = data.control.rawdata(:,:,1) - options.control.time.flipTimes(:,:);
    
    % Make the rawdata variable into a table so it's easier for others to read
    counter = 0;
    for j=1:size(data.control.rawdata,1)
        for i=1:size(data.control.rawdata,3)
            counter = counter+1;
            t(:,counter)=table(data.control.rawdata(j,:,i));
        end
        t.Properties.VariableNames(length(t.Properties.VariableNames)-1) = {['Time_B' num2str(j)]};
        t.Properties.VariableNames(length(t.Properties.VariableNames)) = {['Percept_B' num2str(j)]};
    end
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,fullfile(options.datadir,[options.datafile '_control']));
    
    % Set the stair struct and rawdata to a data struct to send to save
    data.control.rawdataT = t;
    
    % Save data before doing the analysis
    cleanUp(options,data,1);
end

end

