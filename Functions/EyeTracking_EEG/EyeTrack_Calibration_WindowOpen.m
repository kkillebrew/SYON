% Sample eye tracker callibration code from tobii pro webiste:
% http://developer.tobiipro.com/matlab/matlab-sdk-reference-guide.html

function [options] = EyeTrack_Calibration_WindowOpen(options)

% clear all; close all;

% Record partiticpant values
% options.ETOptions.subjID = options.subjID;
% options.expName = options.expName;
% options.datecode = options.datecode;

% Make a subjid and exp name for testing porpoises
% options.ETOptions.subjID = 'test';
% options.expName = 'testExp';
% options.datecode = datestr(now,'mmddyy');

%% options.ETOptions.eyeTracker setup
% start mps edit 20190730
% curr_path = pwd;
% match_folder_name = 'SYON.git';
% path_idx = strfind(curr_path,match_folder_name);
% if ~isempty(path_idx)
%     options.root_path = curr_path(1:path_idx+length(match_folder_name)-1);
% else
%     error(['Can''t find folder ' match_folder_name ' in current directory list!']);
% end
% addpath(genpath(fullfile(options.root_path,'Functions')));
% KbName('UnifyKeyNames');
% options.buttons.buttonEscape = KbName('escape');
% options.buttons.buttonY = KbName('y');
% options.buttons.buttonN = KbName('n');




%% Calibration setup
% Create a screen based calibration object which contains functions for
% managing calibrations. - KWK 20200106
options.ETOptions.calib = ScreenBasedCalibration(options.ETOptions.eyeTracker);

% Start calibration
options.ETOptions.calib.enter_calibration_mode()
%
% % For testingn
% [maxStddev, minSamples, maxDeviation, maxDuration] =...
%     Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);   % Sync test w/ monitor
%
% % Screen info
% options.screenNum = 1;
% options.wInfoOrig = Screen('Resolution',options.screenNum);
% options.wInfoNew.hz = options.wInfoOrig.hz;
% options.wInfoNew.width = options.wInfoOrig.width;
% options.wInfoNew.height = options.wInfoOrig.height;
% Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);

% [options.ETOptions.windowNum,options.ETOptions.rect] = Screen('OpenWindow',options.ETOptions.screenNum,[128 128 128],...
%     [0 0 options.ETOptions.wInfoNew.width options.ETOptions.wInfoNew.height],[],[],[],8);
% if exist('options.ETOptions')==1
%     if isfield(options,'windowNum')
%     else
%         [options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,[128 128 128],...
%             [],[],[],[],8);
%     end
% else
%     [options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,[128 128 128],...
%             [],[],[],[],8);
% end
%
% options.xc = options.rect(3)/2;
% options.yc = options.rect(4)/2;
%
% % Alpha blending
% Screen('BlendFunction',options.windowNum, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % Must have for alpha values for some reason
%
% % PPD varialbes
% options.mon_width_cm = 53;   % Width of the monitor (cm)
% options.mon_dist_cm = 57;   % Viewing distance (cm)
% options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
% options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree

% Number of calibration points (currently a 5 point calibration, presumably
% can do more?) - KWK 20200106
% options.ETOptions.pointsToCollect = [[0.5,0.5];[0.1,0.1];[0.1,0.9];[0.9,0.1];[0.9,0.9]];
options.ETOptions.pointsToCollect = [[0.5,0.5];[0.1,0.1];[0.1,0.9];[0.9,0.1];[0.9,0.9]];
options.ETOptions.pointsToCollectPix = options.ETOptions.pointsToCollect.*[options.rect(3),options.rect(4)];
options.ETOptions.poitnsToCollectDoVA = options.ETOptions.pointsToCollect./options.PPD;

% Radius of the callibration fixation points in pixels
options.ETOptions.calFixSize = options.PPD/4;   % 1/4 degree of visual angle

% Radius of the gaze plot in pixels
gazePlotSize = 5;

% Locations of the fixation point in pixels
for i=1:size(options.ETOptions.pointsToCollect)
    options.ETOptions.calFixLoc(i,:,:) = [options.ETOptions.pointsToCollectPix(i,1)-options.ETOptions.calFixSize...
        options.ETOptions.pointsToCollectPix(i,2)-options.ETOptions.calFixSize...
        options.ETOptions.pointsToCollectPix(i,1)+options.ETOptions.calFixSize...
        options.ETOptions.pointsToCollectPix(i,2)+options.ETOptions.calFixSize];
end

% Setup switches to run/rerun calibration
options.ETOptions.runCalibSwitch = 0;
options.ETOptions.reCalibrateSwitch = 0;

%% Run the calibration script
while options.ETOptions.runCalibSwitch == 0
    
    [~, ~, keycode] = KbCheck;
    if keycode(options.buttons.buttonEscape)
        break
    end
    
    % Clear out old variables for new calibration
    clear collect_result
    
    % When collecting data a point should be presented on the screen in the
    % appropriate position.
    for i=1:size(options.ETOptions.pointsToCollect,1)
        
        [~, ~, keycode] = KbCheck;
        if keycode(options.buttons.buttonEscape)
            break
        end
        
        % If recalibrating discard data for each point before collecting
        % new one.
        if options.ETOptions.reCalibrateSwitch == 1
            options.ETOptions.calib.discard_data(options.ETOptions.pointsToCollect(i,:));
        end
        
        % Present the dot on the screen at the correct location.
        % options.ETOptions.pointsToCollect are in proportions of the screen size (.1 = 10% of
        % screen width/height)
        Screen('FillOval',options.windowNum,[255 0 0],squeeze(options.ETOptions.calFixLoc(i,:,:)));
        Screen('Flip',options.windowNum);
        
        % Wait for the participant to fixate then press a key
        if i==1
            KbWait;
        else
            pause(1);
        end
        
        % Collect the result
        % collect_data adds data to the calibration 'buffer' for one point
        % 'Collect_results' variable indicates the status of calibration
        % for both (status) or for left/right eye individually
        % (statusrighteye). (1=succes for both, 2=for left, 3=for right)
        collect_result(i) = options.ETOptions.calib.collect_data(options.ETOptions.pointsToCollect(i,:));
        fprintf('Point [%.2f,%.2f] Collect Result: %s\n',options.ETOptions.pointsToCollect(i,:),num2str(collect_result(i).value));
        
        while collect_result(i).value==0
            [~, ~, keycode] = KbCheck;
            if keycode(options.buttons.buttonEscape)
                break
            end
            
            text1 = 'Failure, look again!';
            textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
            DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+150,[0 0 0]);
            Screen('FillOval',options.windowNum,[255 0 0],squeeze(options.ETOptions.calFixLoc(i,:,:)));
            Screen('Flip',options.windowNum);
            
            options.ETOptions.calib.discard_data(options.ETOptions.pointsToCollect(i,:));
            
            %             KbWait;
            %             KbReleaseWait;
            
            collect_result(i) = options.ETOptions.calib.collect_data(options.ETOptions.pointsToCollect(i,:));
            fprintf('Point [%.2f,%.2f] Collect Result: %s\n',options.ETOptions.pointsToCollect(i,:),num2str(collect_result(i).value));
        end
        
    end
    
    calibration_result = options.ETOptions.calib.compute_and_apply();   % Maybe you need to use collect_result instead of options.ETOptions.calib?
    options.ETOptions.calibrationStatus = calibration_result.Status.value.value;
    fprintf('Calibration Status: %s\n',num2str(calibration_result.Status.value.value));
    % fprintf('Calibration Status: %s\n',char(calibration_result.Status));   % What's in the examplecode...try out?...doesn't work...
    
    
    %% Check to see how the calibration did/re-run calibration
    % Plot results on screen and decide if rerun
    % Display the success status of the calibration
    if calibration_result.Status.value.value==1   % CHECK THIS VALUE, WHAT VALUE = SUCCES VS FAILURE
        text1='Calibration Success!';
    elseif calibration_result.Status.value.value==0
        text1='Calibration Failure!';
    end
    
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',(textHeight/2)+150,[0 0 0]);
    
    text3='Rerun calibration? Yes (y) or No (n).';
    %     textHeight = RectHeight(Screen('TextBounds',options.ETOptions.windowNum,text2));
    %     DrawFormattedText(options.ETOptions.windowNum,text2,'center',(textHeight/2)+200,options.ETOptions.fixCol);
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
    DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,[0 0 0]);
    
    if calibration_result.Status.value.value == 0   % If failure auto re-run
    elseif calibration_result.Status.value.value == 1   % If success ask if repeat
        for i=1:length(calibration_result.CalibrationPoints)
            Screen('DrawDots',options.windowNum,calibration_result.CalibrationPoints(i).PositionOnDisplayArea.*[options.rect(3),options.rect(4)], 30*.05, options.fixCol,[],2);
            
            for j=1:length(calibration_result.CalibrationPoints(i).RightEye)
                if calibration_result.CalibrationPoints(i).LeftEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
                    Screen('DrawDots', options.windowNum, calibration_result.CalibrationPoints(i).LeftEye(j).PositionOnDisplayArea.*[options.rect(3),options.rect(4)], 30*0.3, options.greenCol, [], 2);
                    Screen('DrawLines', options.windowNum, ([calibration_result.CalibrationPoints(i).LeftEye(j).PositionOnDisplayArea; calibration_result.CalibrationPoints(i).PositionOnDisplayArea].*[options.rect(3),options.rect(4)])', 2, options.greenCol, [0 0], 2);
                end
                if calibration_result.CalibrationPoints(i).RightEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
                    Screen('DrawDots', options.windowNum, calibration_result.CalibrationPoints(i).RightEye(j).PositionOnDisplayArea.*[options.rect(3),options.rect(4)], 30*0.3, options.redCol, [], 2);
                    Screen('DrawLines', options.windowNum, ([calibration_result.CalibrationPoints(i).RightEye(j).PositionOnDisplayArea; calibration_result.CalibrationPoints(i).PositionOnDisplayArea].*[options.rect(3),options.rect(4)])', 2, options.redCol, [0 0], 2);
                end
            end
            
        end
    end
    
    Screen('Flip',options.windowNum);
    
    while 1
        [~, ~, keycode] = KbCheck;
        if keycode(options.buttons.buttonEscape)
            break
        end
        
        if keycode(options.buttons.buttonY)
            % Rerun calibration
            options.ETOptions.reCalibrateSwitch = 1;
            
            % break out of while
            WaitSecs(.5);
            break
        elseif keycode(options.buttons.buttonN)
            options.ETOptions.runCalibSwitch = 1;
            options.ETOptions.reCalibrateSwitch = 0;
            options.ETOptions.calib.leave_calibration_mode();
            WaitSecs(.5);
            break
        end
        
    end
    
    %% If not, plot the gaze location in real time to double check the calibration.
    % Decide based on plotted realtime gaze if you want to re-run
    % Collect gaze data
    endExpSwitch = 0;
    if options.ETOptions.reCalibrateSwitch == 0
        while 1
            result = options.ETOptions.eyeTracker.get_gaze_data();   % Second call returns an array of gaze data objects collected over the duration
            
            [~, ~, keycode] = KbCheck;
            if keycode(options.buttons.buttonEscape) || options.ETOptions.reCalibrateSwitch == 1
                break
            end
            
            if isa(result,'SteamError')
                disp('Error');
                
            elseif isa(result,'GazeData')
                while 1   % Continuously loop until key is pressed
                    %         WaitSecs(.05);
                    
                    %         gazeData(length(gazeData)+1) = options.ETOptions.eyeTracker.get_gaze_data();   % Starts data collection
                    gazeData = options.ETOptions.eyeTracker.get_gaze_data();
                    
                    if isempty(gazeData)
                    else
                        % Grab the most recent gazeData object
                        currGaze = gazeData(end);
                        
                        % Take the average position between left and right eyes.
                        aveGazePos = mean([currGaze.LeftEye.GazePoint.OnDisplayArea; currGaze.RightEye.GazePoint.OnDisplayArea],1);
                        aveGazePos = aveGazePos.*[options.rect(3) options.rect(4)];
                        aveGazePos = double(aveGazePos);
                        aveGazePos = [aveGazePos(1)-gazePlotSize...
                            aveGazePos(2)-gazePlotSize...
                            aveGazePos(1)+gazePlotSize...
                            aveGazePos(2)+gazePlotSize];
                        
                        leftGazePos = [currGaze.LeftEye.GazePoint.OnDisplayArea];
                        leftGazePos = double(leftGazePos).*[options.rect(3) options.rect(4)];
                        leftGazePos = [leftGazePos(1)-gazePlotSize...
                            leftGazePos(2)-gazePlotSize...
                            leftGazePos(1)+gazePlotSize...
                            leftGazePos(2)+gazePlotSize];
                        
                        rightGazePos = [currGaze.RightEye.GazePoint.OnDisplayArea];
                        rightGazePos = double(rightGazePos).*[options.rect(3) options.rect(4)];
                        rightGazePos = [rightGazePos(1)-gazePlotSize...
                            rightGazePos(2)-gazePlotSize...
                            rightGazePos(1)+gazePlotSize...
                            rightGazePos(2)+gazePlotSize];
                        
                        % Plot the most recent result in gazeData
                        text3='Rerun calibration? Yes (y) or No (n).';
                        textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
                        DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,[0 0 0]);
                        Screen('FillOval',options.windowNum,options.redCol,leftGazePos);
                        Screen('FillOval',options.windowNum,options.blueCol,rightGazePos);
                        Screen('Flip',options.windowNum);
                    end
                    % Monitor for button presses, if pressed break
                    [~, ~, keycode, ~] = KbCheck;
                    if keycode(options.buttons.buttonEscape) || keycode(options.buttons.buttonN)
                        endExpSwitch = 1;
                        break
                    elseif keycode(options.buttons.buttonY)
                        options.ETOptions.reCalibrateSwitch = 1;
                        break
                    end
                end
            end
            
            
            if endExpSwitch == 1
                break
            end
        end
        
        % Stop collecting data
        options.ETOptions.eyeTracker.stop_gaze_data();
    end
    
end

%% Calibration validation
%% Plot the calibration results (calibration plot - http://developer.tobiipro.com/commonconcepts/calibration.html)
if options.ETOptions.reCalibrateSwitch == 0
    myFig1 = figure('Name','Calibration Results','NumberTitle','off');
    
    % Turn off axis
    % set(gca,'visible','off')
    set(gca,'xtick',[])
    
    % Set axis limits
    xlim([0 options.rect(3)]);
    ylim([0 options.rect(4)]);
    
    xticks(options.PPD:options.PPD*2:options.rect(3));
    yticks(options.PPD:options.PPD*2:options.rect(4));
    
    xticklabels(1:2:floor(options.rect(3)/options.PPD));
    yticklabels(1:2:floor(options.rect(4)/options.PPD));
    
    % Plot circles at the correct positions on the figure
    hold on
    for i=1:size(options.ETOptions.pointsToCollect,1)   % Skip 1, is a 0,0 point for some reason...
        % Useful Matlab fnunciton for plotting circles on figure
        viscircles(options.ETOptions.pointsToCollectPix(i,:),options.ETOptions.calFixSize,'Color','k');
        
        % Use the values in calibration_result to plot the values on the graph in
        % the correct circles.
        for j=1:length(calibration_result.CalibrationPoints(i).LeftEye)
            options.ETOptions.calibrationPlotResults(i).leftEyePoints(j,:) = calibration_result.CalibrationPoints(i).LeftEye(j).PositionOnDisplayArea;
            options.ETOptions.calibrationPlotResults(i).leftEyePointsValidity(j) = calibration_result.CalibrationPoints(i).LeftEye(j).Validity.value;
            
            if options.ETOptions.calibrationPlotResults(i).leftEyePointsValidity(j)==1
                plot([options.ETOptions.calibrationPlotResults(i).leftEyePoints(j,1)*options.rect(3),options.ETOptions.pointsToCollectPix(i,1)*options.rect(3)],...
                    [options.ETOptions.calibrationPlotResults(i).leftEyePoints(j,2)*options.rect(4),options.ETOptions.pointsToCollectPix(i,2)*options.rect(4)],'g.')
            end
        end
        for j=1:length(calibration_result.CalibrationPoints(i).RightEye)
            options.ETOptions.calibrationPlotResults(i).rightEyePoints(j,:) = calibration_result.CalibrationPoints(i).RightEye(j).PositionOnDisplayArea;
            options.ETOptions.calibrationPlotResults(i).rightEyePointsValidity(j) = calibration_result.CalibrationPoints(i).RightEye(j).Validity.value;
            
            if options.ETOptions.calibrationPlotResults(i).rightEyePointsValidity(j)==1
                plot([options.ETOptions.calibrationPlotResults(i).rightEyePoints(j,1)*options.rect(3),options.ETOptions.pointsToCollectPix(i,1)*options.rect(3)],...
                    [options.ETOptions.calibrationPlotResults(i).rightEyePoints(j,2)*options.rect(4),options.ETOptions.pointsToCollectPix(i,2)*options.rect(4)],'r.')
            end
        end
    end
    
    % % For replotting saved data:
    % for i=2:size(options.ETOptions.pointsToCollect,1)+1   % Skip 1, is a 0,0 point for some reason...
    %     % Useful Matlab fnunciton for plotting circles on figure
    %     viscircles(options.ETOptions.pointsToCollectPix(i-1,:),options.ETOptions.calFixSize,'Color','k');
    %
    %     % Use the values in calibration_result to plot the values on the graph in
    %     % the correct circles.
    %     for j=1:size(options.ETOptions.calibrationPlotResults(i).leftEyePoints,1)
    %         if options.ETOptions.calibrationPlotResults(i).leftEyePointsValidity(j)==1
    %             plot([options.ETOptions.calibrationPlotResults(i).leftEyePoints(j,1)*options.rect(3),options.ETOptions.pointsToCollectPix(i-1,1)*options.rect(3)],...
    %                 [options.ETOptions.calibrationPlotResults(i).leftEyePoints(j,2)*options.rect(4),options.ETOptions.pointsToCollectPix(i-1,2)*options.rect(4)],'g.')
    %         end
    %     end
    %     for j=1:size(options.ETOptions.calibrationPlotResults(i).rightEyePoints,1)
    %         if options.ETOptions.calibrationPlotResults(i).rightEyePointsValidity(j)==1
    %             plot([options.ETOptions.calibrationPlotResults(i).rightEyePoints(j,1)*options.rect(3),options.ETOptions.pointsToCollectPix(i-1,1)*options.rect(3)],...
    %                 [options.ETOptions.calibrationPlotResults(i).rightEyePoints(j,2)*options.rect(4),options.ETOptions.pointsToCollectPix(i-1,2)*options.rect(4)],'r.')
    %         end
    %     end
    % end
    
    myFig2 = figure('Name','Validation Results','NumberTitle','off',...
        'Position',[100 100 500 500]);
    if calibration_result.Status == CalibrationStatus.Success
        points = calibration_result.CalibrationPoints;
        
        number_points = size(points,2);
        
        for i=2:number_points
            plot(points(i).PositionOnDisplayArea(1),points(i).PositionOnDisplayArea(2),'ok','LineWidth',10);
            mapping_size = size(points(i).RightEye,2);
            set(gca, 'YDir', 'reverse');
            axis([-0.2 1.2 -0.2 1.2]);
            hold on;
            for j=1:mapping_size
                if points(i).LeftEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
                    plot(points(i).LeftEye(j).PositionOnDisplayArea(1), points(i).LeftEye(j).PositionOnDisplayArea(2),'-xr','LineWidth',3);
                end
                if points(i).RightEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
                    plot(points(i).RightEye(j).PositionOnDisplayArea(1),points(i).RightEye(j).PositionOnDisplayArea(2),'xb','LineWidth',3);
                end
            end
            
        end
    end
end

%% Last screen and save
% Plot the most recent result in gazeData
text3='Eyetracking calibration finished! Press any button to continue...';
textHeight = RectHeight(Screen('TextBounds',options.windowNum,text3));
DrawFormattedText(options.windowNum,text3,'center',(textHeight/2)+200,[0 0 0]);
Screen('Flip',options.windowNum);

% Save the calibration file if needed later
options.calibData = options.ETOptions.eyeTracker.retrieve_calibration_data();

options.ETOptions.calibration_path = sprintf('%s%s%s%s%s','e:/SYON_Eyetracking/ETCalib_',options.subjID,'_',options.datecode,'.mat');

fid = fopen(options.ETOptions.calibration_path,'w');

fwrite(fid,options.calibData);

fclose(fid);

% % Save calibration plot
% savefig(sprintf('%s%s%s%s','../../../../SYON_Eyetracking/eyeTrackerCalibration_',options.subjID,'_',options.datecode));
% close(myFig1);
% 
% % Save validation plot
% savefig(sprintf('%s%s%s%s','../../../../SYON_Eyetracking/eyeTrackerValidation_',options.subjID,'_',options.datecode));
% close(myFig2);

KbWait;


end