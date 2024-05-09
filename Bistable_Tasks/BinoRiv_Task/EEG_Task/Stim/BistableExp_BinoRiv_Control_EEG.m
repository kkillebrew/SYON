% Bistable biological motion control task. Runs a 2 minute control run of the bistable biological motion task. Participants are instructed to
% press the left or right mouse button when they see a change in motion direction.
% KWK - 20201005

function [options,data] = BistableExp_BinoRiv_Control_Behav(options,data)

%% Start the experiment
% Instructions/Start screen
% Last instructions before the experiment starts
text1='Now we will start the first block of the experiment.';
text2='Press the LEFT ARROW for BLUE LINES, RIGHT ARROW for RED LINES, and DOWN ARROW for MIXED.';
text3='Please let the experimenter know if you have any questions or concerns.';
text4='Tell the experimenter when you are ready to continue...';
text5='LAST SCREEN BEFORE EXPERIMENT START!';
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
            
            data.control.rawdata(m,n,3) = options.control.gratValue(n);
            
            Screen('DrawTexture',options.windowNum,options.sp.frame.frameTexture);
            
            switch data.control.rawdata(m,n,3)
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
            
            [~, options.control.time.flipTimesActual(m,n), ~, ~, ~] = Screen('Flip',options.windowNum,...
                (options.control.time.sync_time(m)+options.control.time.flipTimes(m,n))-options.flip_interval_correction);
            
            [~,~,keycode,~] = KbCheck(options.dev_id2);
            if keycode(options.buttons.buttonLeft)   % left red
                data.control.rawdata(m,n,2) = 1;
                
                % Send eyetracker trigger for each response made
                if options.eyeTracking == 1
                    et_message = '1 - Left/Blue (Control)';
                    Eyelink('Message', et_message);
                end
            elseif keycode(options.buttons.buttonRight)   % right blue
                data.control.rawdata(m,n,2) = 2;
                
                % Send eyetracker trigger for each response made
                if options.eyeTracking == 1
                    et_message = '2 - Right/Red (Control)';
                    Eyelink('Message', et_message);
                end
            elseif keycode(options.buttons.buttonDown)   % Either
                data.control.rawdata(m,n,2) = 3;
                
                % Send eyetracker trigger for each response made
                if options.eyeTracking == 1
                    et_message = '3 - Either/Both (Control)';
                    Eyelink('Message', et_message);
                end
            end
        end
        
        % End eyetracking for current block
        if options.eyeTracking == 1
            %             et_message = ['Room # = ' roomNo];   %%%%%%%% WILL NEED TO CHANGE THIS
            %             Eyelink('Message', et_message);
            
            WaitSecs(0.1);
            % stop the recording of eye-movements for the current block
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
        t.Properties.VariableNames(length(t.Properties.VariableNames)) = {['GratingType_B' num2str(j)]};
    end
    
    % Save the text file for use w/ other programs not Matlab
    writetable(t,fullfile(options.datadir,[options.datafile '_control']));
    
    % Set the stair struct and rawdata to a data struct to send to save
    data.control.rawdataT = t;
    
    % Save data before doing the analysis
    cleanUp(options,data,1);
end

end







