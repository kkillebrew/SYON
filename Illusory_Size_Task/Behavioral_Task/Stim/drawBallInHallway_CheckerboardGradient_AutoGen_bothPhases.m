% Function to plot the ball in the hallway stim and overlay the circular gradient checkerboard. Loads in all the various
% sized hallway textures generated in blender and auto-places the gradient checkerboard spheres based on sizes measured
% previously. Creates no hallway textures for both checkerboard types. Also adds in a fixation. MUST have a copy of
% 'measuredSizesAndPosition_XdegAlpha.mat' save in /Stim folder.
%
% KWK - 20200325

%% Initialize
clear all;
% close all;

% Add the functions folder to path
addpath(genpath('../Functions/'));

ListenChar(0)

% Load in the previously calculated options (sizes/positions)
prevSizePosOptions = 'measuredSizesAndPositions_sameCheckNum_7degAlpha.mat';
load(prevSizePosOptions);
% options = rmfield(options,'buttons');
options.prevSizePosOptions = prevSizePosOptions;

% Set PPD, if needed
options.displayInfo.linearClut = 0:1/255:1;
options.whiteCol = [255 255 255];
options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);
options.fixCol = [0 255 255];
options.fixColSingle = [0 255 255;255 0 0];

% PPD varialbes
options.mon_width_cm = 53;   % Width of the monitor (cm)

options.mon_dist_cm = 57;   % Viewing distance (cm)
options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
options.PPD = (1920/options.mon_width_deg);   % pixels per degree

% Define keys
KbName('UnifyKeyNames');
options.buttons.buttonEscape = KbName('escape');

saveSwitchIdx = input('Would you like to save new images and overwrite (y or n)? ','s');
while 1
    if strcmp(saveSwitchIdx,'yes') || strcmp(saveSwitchIdx,'Yes') || strcmp(saveSwitchIdx,'y') || strcmp(saveSwitchIdx,'Y')
        saveSwitch = 1;   % Set switch to save/overwrite
        break
    elseif strcmp(saveSwitchIdx,'no') || strcmp(saveSwitchIdx,'No') || strcmp(saveSwitchIdx,'n') || strcmp(saveSwitchIdx,'N')
        saveSwitch = 0;
        break
    elseif ~ismember(saveSwitchIdx,{'n' 'N' 'no' 'No' 'y' 'Y' 'yes' 'Yes'})
        clear saveSwitchIdx
        saveSwitchIdx = input('Invalid choice. Would you like to save new images and overwrite (y or n)? ','s');
    end
end

%% Constant variables
% Calculate fixation line
% First calculate the fixation points (center points) between the centers of the far and close spheres for the largest and
% smallest fixation points.
options.fixationInfo.fixationLocSmallSphere(:) = [(options.circ2CenterTexX(1)+options.circ1CenterTexX(1))/2 ...
    (options.circ1CenterTexY(1)+options.circ2CenterTexY(1))/2];
options.fixationInfo.fixationLocLargeSphere(:) = [(options.circ2CenterTexX(end)+options.circ1CenterTexX(end))/2 ...
    (options.circ1CenterTexY(end)+options.circ2CenterTexY(end))/2];

% Grab info of center points and bottom point of largest and smallest close sphere
options.fixationInfo.centerSmallSphere = [options.circ1CenterTexX(1) options.circ1CenterTexY(1)];
options.fixationInfo.bottomSmallSphere = [options.fixationInfo.centerSmallSphere(1)...
    options.fixationInfo.centerSmallSphere(2)+options.circ1Radius(1)];
options.fixationInfo.centerLargeSphere = [options.circ1CenterTexX(end) options.circ1CenterTexY(end)];
options.fixationInfo.bottomLargeSpehre = [options.fixationInfo.centerLargeSphere(1)...
    options.fixationInfo.centerLargeSphere(2)+options.circ1Radius(end)];

% Grab info of center point and bottom point of far sphere
options.fixationInfo.centerFarSphere = [options.circ2CenterTexX(1) options.circ2CenterTexY(1)];
options.fixationInfo.bottomFarSphere = [options.fixationInfo.centerFarSphere(1)...
    options.fixationInfo.centerFarSphere(2)+options.circ2Radius(1)];

% Top of fixation line is center point between x centers of the two center point lines
options.fixationLoc(1) = options.fixationInfo.fixationLocLargeSphere(1);
options.fixationLoc(2) = options.fixationInfo.fixationLocLargeSphere(2);
options.fixationLoc(3) = options.fixationInfo.fixationLocSmallSphere(1);
options.fixationLoc(4) = options.fixationInfo.fixationLocSmallSphere(2);

% Array of sizes to be used in psychophysics
% options.sizePropArray = [.75:.025:.9 .91:.01:.99 1 1.01:.01:1.09 1.1:0.025:1.25];
% options.sizePropArray = [1 2];
options.sizePropArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];

options.fixSize = 3;   % Pen width of fixation line
options.fixSquareSize = 2;   % Extra size to add to the square behind fixation for fix change trials

measureSize = 1;   % If plot lines to measure ball sizes
quitSwitch = 0;   % Set to quit out of program
checkSizeSwitch = 1;   % 1=constant size checks; 2=constant num checks
genPhaseSwitch = 1;   % Generate both phases of the checkerboard
% Array to tell script what stim to generate;
% 1st=same size checks, 2nd=same num checks, 3rd=same size no hallway, 4th=same num no hallway; 5th=fix only
stimTypeArray = [1 1 1 1 1 1];
% stimTypeArray = [0 0 0 0 1 1];

%% Create stim, draw stim on screen, save textures
[options.windowNum,options.rect] = Screen('OpenWindow',2,[128 128 128] );
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;

% Alpha blending
Screen('BlendFunction',options.windowNum, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % Must have for alpha values for some reason
m=0;
escBreak=0;
while m<length(stimTypeArray)
    
    m=m+1;
    
    %% Determine what types of stim to draw
    if m==1
        if stimTypeArray(1)==0
            m=2;
        elseif stimTypeArray(1)==1
            % Set the correct background stim (hallway)
            % Image name array
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = sprintf('%s%.3f%s','BallHallway_',options.sizePropArray(i),'_7degAlpha.png');
            end
            
            % Set the correct checkerboard stim (same size)
            checkSizeSwitch = 1;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_sameCheckSize_hallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_sameCheckSize_hallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = 'BallHallway_0.1000_7degAlpha_close.png';
            options.singleCirc.ballHallImageList{2} = 'BallHallway_0.1000_7degAlpha_far.png';
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckSize_hallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckSize_hallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = 'BallHallway_1.000_7degAlpha.png';
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_sameCheckSize_hallway_7degAlpha_Texture');
            
        end
    end
    if m==2
        if stimTypeArray(2)==0
            m=3;
        elseif stimTypeArray(2)==1
            % Set the correct background stim (hallway)
            % Image name array
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = sprintf('%s%.3f%s','BallHallway_',options.sizePropArray(i),'_7degAlpha.png');
            end
            
            % Set the correct checkerboard stim (same num)
            checkSizeSwitch = 2;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_sameCheckNum_hallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_sameCheckNum_hallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = 'BallHallway_0.1000_7degAlpha_close.png';
            options.singleCirc.ballHallImageList{2} = 'BallHallway_0.1000_7degAlpha_far.png';
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckNum_hallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckNum_hallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = 'BallHallway_1.000_7degAlpha.png';
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_sameCheckNum_hallway_7degAlpha_Texture');
            
        end
    end
    if m==3
        if stimTypeArray(3)==0
            m=4;
        elseif stimTypeArray(3)==1
            % Set the correct background stim (no hallway)
            % Image name array
            exampleImageDir = sprintf('%s%.3f%s','BallHallway_',options.sizePropArray(1),'_7degAlpha.png');
            options = createBlankTexture(options,exampleImageDir);
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = options.blankTexDir;
            end
            
            % Set the correct checkerboard stim (same size)
            checkSizeSwitch = 1;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_sameCheckSize_noHallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_sameCheckSize_noHallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = options.blankTexDir;
            options.singleCirc.ballHallImageList{2} = options.blankTexDir;
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckSize_noHallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckSize_noHallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = options.blankTexDir;
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_sameCheckSize_noHallway_7degAlpha_Texture');
            
        end
    end
    if m==4
        if stimTypeArray(4)==0
            m=5;
        elseif stimTypeArray(4)==1
            % Set the correct background stim (no hallway)
            % Image name array
            exampleImageDir = sprintf('%s%.3f%s','BallHallway_',options.sizePropArray(1),'_7degAlpha.png');
            options = createBlankTexture(options,exampleImageDir);
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = options.blankTexDir;
            end
            
            % Set the correct checkerboard stim (same num)
            checkSizeSwitch = 2;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_sameCheckNum_noHallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_sameCheckNum_noHallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = options.blankTexDir;
            options.singleCirc.ballHallImageList{2} = options.blankTexDir;
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckNum_noHallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_sameCheckNum_noHallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = options.blankTexDir;
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_sameCheckNum_noHallway_7degAlpha_Texture');
            
        end
    end
    if m==5   % Fixation only w/ hallway
        if stimTypeArray(5)==0
            m=6;
        elseif stimTypeArray(5)==1
            % Set the correct background stim (hallway)
            % Image name array
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = sprintf('%s%.3f%s','BallHallway_HallwayOnly_7degAlpha.png');
            end
            
            % Set the correct checkerboard stim (same num)
            checkSizeSwitch = 2;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_fixOnly_hallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_fixOnly_hallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = sprintf('%s%.3f%s','BallHallway_HallwayOnly_7degAlpha.png');
            options.singleCirc.ballHallImageList{2} = sprintf('%s%.3f%s','BallHallway_HallwayOnly_7degAlpha.png');
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_fixOnly_hallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_fixOnly_hallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = sprintf('%s%.3f%s','BallHallway_HallwayOnly_7degAlpha.png');
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_fixOnly_hallway_7degAlpha_Texture');
            
        end
    end
    if m==6   % Fixation only w/out hallway
        if stimTypeArray(6)==0
            break
        elseif stimTypeArray(5)==1
            % Set the correct background stim (no hallway)
            % Image name array
            exampleImageDir = sprintf('%s%.3f%s','ballHallway_HallwayOnly_7degAlpha.png');
            options = createBlankTexture(options,exampleImageDir);
            for i=1:length(options.sizePropArray)
                options.ballHallImageList{i} = options.blankTexDir;
            end
            
            % Set the correct checkerboard stim (same num)
            checkSizeSwitch = 2;   % 1=constant size checks; 2=constant num checks
            
            % Set the output destination and filename
            options.outputFileName = './measuredSizesAndPositions_fixOnly_noHallway_7degAlpha';
            for i=1:length(options.sizePropArray)
                options.outputImageName{i} = sprintf('%s%.3f%s',...
                    './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',...
                    options.sizePropArray(i),'_fixOnly_noHallway_7degAlpha_Texture');
            end
            
            % Set single circ values
            % Images to load
            options.singleCirc.ballHallImageList{1} = options.blankTexDir;
            options.singleCirc.ballHallImageList{2} = options.blankTexDir;
            % Output image name and destination
            options.singleCirc.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_fixOnly_noHallway_7degAlpha_close_Texture');
            options.singleCirc.outputImageName{2} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/BallHallway_',...
                1.000,'_fixOnly_noHallway_7degAlpha_far_Texture');
            
            % Set MR stim values
            % Images to load
            options.MRStim.ballHallImageList{1} = options.blankTexDir;
            % Output image name and destination
            options.MRStim.outputImageName{1} = sprintf('%s%.3f%s',...
                './Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/BallHallway_',...
                1.000,'_fixOnly_noHallway_7degAlpha_Texture');
            
        end
    end
    
    %% Create stim
    n=0;
    while n<length(options.sizePropArray)   % Use while counter instead, to allow redo of tex drawing
        
        n=n+1;
        
        % If generating both phases of checkerboard
        if m<5
            if genPhaseSwitch==1
                genPhaseCount = 2;
                whichPhase = 1;
            elseif genPhaseSwitch==0
                genPhaseCount = 1;
            end
        else
            genPhaseCount = 1;
        end
        
        for p=1:genPhaseCount
            if quitSwitch == 0
                %% Load hallway stim
                cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/
                options.ballHallImageArray{n} = imread(options.ballHallImageList{n});
                cd ../../
                
                options.ballHallImSizeX = size(options.ballHallImageArray{n},1);
                options.ballHallImSizeY = size(options.ballHallImageArray{n},2);
                
                %% Make and draw stim
                if m<5   % If fixation only
                    
                    % Make the checkerboard textures
                    optionsHolder = options;
                    optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n);
                    options.checkerboard = optionsHolder.checkerboard;
                    clear optionsHolder
                    
                    % Make the texturex
                    tex1 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,1).texArray{p});
                    tex2 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,2).texArray{p});
                    
                    % Draw checkerboard stim
                    Screen('DrawTexture',options.windowNum,tex1,[],options.circ1CoordScreen(n,:));
                    Screen('DrawTexture',options.windowNum,tex2,[],options.circ2CoordScreen(n,:));
                    
                    % Create hallway texture
                    [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                    arrayHolder1 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                    arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.circ1CenterTexX(n),...
                        yy - options.circ1CenterTexY(n)) <= options.circ1Radius(n));
                    [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                    arrayHolder2 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                    arrayHolder2 = ~(arrayHolder2 | hypot(xx - options.circ2CenterTexX(n),...
                        yy - options.circ2CenterTexY(n)) <= options.circ2Radius(n));
                    
                    % Combine the two alpha arrays
                    options.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder1).*double(arrayHolder2));
                end
                
                % Remake the texture
                texHallway = Screen('MakeTexture',options.windowNum,options.ballHallImageArray{n});
                
                % Use calculated fixation position and draw line...fixation caculated using max height (largest size close
                % sphere) and min height (smallest size close sphere) of fixation dot placements.
                %                 % Calculate fixation location (halfway between center points of both spheres
                %                 options.fixationLoc(n,:) = [(options.circ2CenterTexX(n)+options.circ1CenterTexX(n))/2 ...
                %                     (options.circ1CenterTexY(n)+options.circ2CenterTexY(n))/2];
                
                % Add in fixation
                %                 Screen('FillOval',texHallway,[0 255 0],[options.fixationLoc(n,1)-options.fixSize,options.fixationLoc(n,2)-options.fixSize,...
                %                     options.fixationLoc(n,1)+options.fixSize,options.fixationLoc(n,2)+options.fixSize]);
                Screen('DrawLine',texHallway,options.fixCol,...
                    options.fixationLoc(1),options.fixationLoc(2),options.fixationLoc(3),options.fixationLoc(4),options.fixSize);
                
                % Draw texture hallway
                Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                    options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                
                Screen('Flip',options.windowNum);
                
                WaitSecs(.1);
                
                %% Escape check and save
                % Check for escape
                [~,~,keycode,~] = KbCheck();
                if keycode(options.buttons.buttonEscape)
                    escBreak = 1;
                    break
                end
                
                % Save
                if saveSwitch == 1
                    % Save the images and locations
                    % Grab the screen at the size of the texture that includes the balls
                    imageArray.image = Screen('GetImage',options.windowNum,[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                        options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                    if m<5
                        imwrite(imageArray.image,sprintf('%s%s%d%s',options.outputImageName{n},'_FixLine_',p,'.png'))
                    else
                        imwrite(imageArray.image,sprintf('%s%s',options.outputImageName{n},'_FixLine.png'))
                    end
                end
            end
            
            if escBreak==1
                break
            end
            
            if saveSwitch == 1
                % Save the calculated/measured values
                if m<5
                    save(sprintf('%s%s%d',options.outputFileName,'_FixLine_',p),'options')
                else
                    save(sprintf('%s%s',options.outputFileName,'_FixLine'),'options')
                end
            end
        end
        
        if escBreak==1
            break
        end
        
    end
    
    %% Calculate/create the single circ stim
    % Set size of far ball
    options.singleCirc.circ2Size = options.circ2Size(1);
    options.singleCirc.circ2SizeDeg = options.circ2SizeDeg(1);
    options.singleCirc.circ2Radius = options.circ2Radius(1);
    
    % Set the size value of the close ball (Same size as previously calculated far ball size)
    options.singleCirc.circ1Size = options.singleCirc.circ2Size;
    options.singleCirc.circ1SizeDeg = options.singleCirc.circ2SizeDeg;
    options.singleCirc.circ1Radius = options.circ2Radius(1);
    
    % Make the checkerboard textures
    optionsHolder = options.singleCirc;
    % Re-set some other values that createCheckerboardTexutres needs
    optionsHolder.PPD = options.PPD;
    optionsHolder.whiteCol = options.whiteCol;
    optionsHolder.displayInfo.linearClut = options.displayInfo.linearClut;
    optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,1);
    options.singleCirc.checkerboard = optionsHolder.checkerboard;
    clear optionsHolder
    
    for n=1:2   % For close and far stim
        
        % Deteremine if you want to draw both phases
        if genPhaseSwitch==1
            genPhaseCount = 2;
            whichPhase = 1;
        elseif genPhaseSwitch==0
            genPhaseCount = 1;
        end
        
        for p=1:genPhaseCount
            
            if quitSwitch == 0
                % Load in single circ textures
                cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/SingleBall/
                options.singleCirc.ballHallImageArray{n} = imread(options.singleCirc.ballHallImageList{n});
                cd ../../../
                
                options.singleCirc.ballHallImSizeX = size(options.singleCirc.ballHallImageArray{n},1);
                options.singleCirc.ballHallImSizeY = size(options.singleCirc.ballHallImageArray{n},2);
                
                % Make the texturex (only need 1; if n=1, close ball; if n=2, far ball)
                tex1 = Screen('MakeTexture',options.windowNum,options.singleCirc.checkerboard(1,1).texArray{p});
                
                %% IF plotting the first value ask for user input to get position values of close sphere
                if m==1 && n==1 && p==1
                    
                    % Set position
                    options.singleCirc.circ2CoordScreen = options.circ2CoordScreen(1,:);
                    options.singleCirc.circ2CoordTex = options.circ2CoordTex(1,:);
                    options.singleCirc.circ2CenterTexX = options.circ2CenterTexX(1);
                    options.singleCirc.circ2CenterTexY = options.circ2CenterTexY(1);
                    
                    % We'll set the initial pos for the close ball at the same for the far ball (doesn't really
                    % matter since it's getting moved anyway).
                    options.singleCirc.circ1CoordScreen = options.circ2CoordScreen(1,:);
                    options.singleCirc.circ1CoordTex = options.circ2CoordTex(1,:);
                    options.singleCirc.circ1CenterTexX = options.circ2CenterTexX(1);
                    options.singleCirc.circ1CenterTexY = options.circ2CenterTexY(1);
                    
                    [~,~,keycode,~] = KbCheck();
                    while ~keycode(options.buttons.buttonEnter)
                        
                        %% Escape check and save
                        % Check for escape
                        [~,~,keycode,~] = KbCheck();
                        if keycode(options.buttons.buttonEscape)
                            escBreak = 1;
                            quitSwitch = 1;
                            break
                        end
                        
                        % Draw checkerboard stim
                        Screen('DrawTexture',options.windowNum,tex1,[],options.singleCirc.circ1CoordScreen);   % Close
                        
                        % Create hallway texture
                        [xx,yy] = meshgrid(1:options.singleCirc.ballHallImSizeX,1:options.singleCirc.ballHallImSizeY);
                        arrayHolder1 = zeros([options.singleCirc.ballHallImSizeX,options.singleCirc.ballHallImSizeY]);
                        arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.singleCirc.circ1CenterTexX,...
                            yy - options.singleCirc.circ1CenterTexY) <= options.singleCirc.circ1Radius);
                        
                        % Combine the two alpha arrays
                        %                             options.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder1).*double(arrayHolder2));
                        options.singleCirc.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder1));
                        
                        % Remake the texture
                        texHallway = Screen('MakeTexture',options.windowNum,options.singleCirc.ballHallImageArray{n});
                        
                        % Add in fixation
                        % Calculate fixation location (halfway between center points of both spheres
                        options.singleCirc.fixationLoc(n,:) = [(options.singleCirc.circ2CenterTexX+options.singleCirc.circ1CenterTexX)/2 ...
                            (options.singleCirc.circ1CenterTexY+options.singleCirc.circ2CenterTexY)/2];
                        
                        % Add in fixation
                        Screen('FillOval',texHallway,options.fixCol,[options.singleCirc.fixationLoc(n,1)-options.fixSize,options.singleCirc.fixationLoc(n,2)-options.fixSize,...
                            options.singleCirc.fixationLoc(n,1)+options.fixSize,options.singleCirc.fixationLoc(n,2)+options.fixSize]);
                        %                             Screen('DrawLine',texHallway,[0 255 0],...
                        %                                 options.fixationLoc(1),options.fixationLoc(2),options.fixationLoc(3),options.fixationLoc(4),options.fixSize);
                        
                        % Draw texture hallway
                        Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.singleCirc.ballHallImSizeX/2, options.yc - options.singleCirc.ballHallImSizeY/2,...
                            options.xc + options.singleCirc.ballHallImSizeX/2, options.yc + options.singleCirc.ballHallImSizeY/2]);
                        
                        Screen('Flip',options.windowNum);
                        
                        % Look for up/down or left/right commands to change position
                        [~,~,keycode,~] = KbCheck();
                        if keycode(options.buttons.buttonLeft)
                            options.singleCirc.circ1CoordScreen = options.singleCirc.circ1CoordScreen + [-2 0 -2 0];
                            options.singleCirc.circ1CoordTex = options.singleCirc.circ1CoordTex + [-2 0 -2 0];
                        end
                        if keycode(options.buttons.buttonRight)
                            options.singleCirc.circ1CoordScreen = options.singleCirc.circ1CoordScreen + [2 0 2 0];
                            options.singleCirc.circ1CoordTex = options.singleCirc.circ1CoordTex + [2 0 2 0];
                        end
                        if keycode(options.buttons.buttonUp)
                            options.singleCirc.circ1CoordScreen = options.singleCirc.circ1CoordScreen + [0 -2 0 -2];
                            options.singleCirc.circ1CoordTex = options.singleCirc.circ1CoordTex + [0 -2 0 -2];
                        end
                        if keycode(options.buttons.buttonDown)
                            options.singleCirc.circ1CoordScreen = options.singleCirc.circ1CoordScreen + [0 2 0 2];
                            options.singleCirc.circ1CoordTex = options.singleCirc.circ1CoordTex + [0 2 0 2];
                        end
                        
                        % Update the position of the circ so the hallway texture gets updated
                        % Circ center points in the hallway texture space
                        options.singleCirc.circ1CenterTexX = nanmean([options.singleCirc.circ1CoordTex(3),options.singleCirc.circ1CoordTex(1)]);
                        options.singleCirc.circ1CenterTexY = nanmean([options.singleCirc.circ1CoordTex(4),options.singleCirc.circ1CoordTex(2)]);
                        
                    end
                end
                
                %% Make and draw stim
                %                 if m<5
                fixColCount=2;   % For the checker stim make 2 stim w/ 2 diff fixation colors (for MR and EEG)
                %                 else
                %                     fixColCount=1;
                %                 end
                for r=1:2   % For checker stim, make 2 versions, 1 with black square behind fixation, one without (for fix change trials)
                    for q=1:fixColCount   % Make 2 stim, 1 w/ red fixation and 1 w/ cyan fixation
                        if m<5
                            if n==1
                                %                         % Make the checkerboard textures
                                %                         optionsHolder = options.singleCirc;
                                %                         % Re-set some other values that createCheckerboardTexutres needs
                                %                         optionsHolder.PPD = options.PPD;
                                %                         optionsHolder.whiteCol = options.whiteCol;
                                %                         optionsHolder.displayInfo.linearClut = options.displayInfo.linearClut;
                                %                         optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n);
                                %                         options.singleCirc.checkerboard = optionsHolder.checkerboard;
                                %                         clear optionsHolder
                                
                                % Make the texturex
                                tex1 = Screen('MakeTexture',options.windowNum,options.singleCirc.checkerboard(1,1).texArray{p});
                                
                                % Draw checkerboard stim
                                Screen('DrawTexture',options.windowNum,tex1,[],options.singleCirc.circ1CoordScreen(:));
                                
                                % Create hallway texture
                                [xx,yy] = meshgrid(1:options.singleCirc.ballHallImSizeX,1:options.singleCirc.ballHallImSizeY);
                                arrayHolder1 = zeros([options.singleCirc.ballHallImSizeX,options.singleCirc.ballHallImSizeY]);
                                arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.singleCirc.circ1CenterTexX,...
                                    yy - options.singleCirc.circ1CenterTexY) <= options.singleCirc.circ1Radius);
                                
                                % Combine the two alpha arrays
                                options.singleCirc.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder1));
                            elseif n==2
                                %                         % Make the checkerboard textures
                                %                         optionsHolder = options.singleCirc;
                                %                         % Re-set some other values that createCheckerboardTexutres needs
                                %                         optionsHolder.PPD = options.PPD;
                                %                         optionsHolder.whiteCol = options.whiteCol;
                                %                         optionsHolder.displayInfo.linearClut = options.displayInfo.linearClut;
                                %                         optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n);
                                %                         options.singleCirc.checkerboard = optionsHolder.checkerboard;
                                %                         clear optionsHolder
                                
                                % Make the texturex
                                tex1 = Screen('MakeTexture',options.windowNum,options.singleCirc.checkerboard(1,2).texArray{p});
                                
                                % Draw checkerboard stim
                                Screen('DrawTexture',options.windowNum,tex1,[],options.singleCirc.circ2CoordScreen(:));
                                
                                % Create hallway texture
                                [xx,yy] = meshgrid(1:options.singleCirc.ballHallImSizeX,1:options.singleCirc.ballHallImSizeY);
                                arrayHolder2 = zeros([options.singleCirc.ballHallImSizeX,options.singleCirc.ballHallImSizeY]);
                                arrayHolder2 = ~(arrayHolder2 | hypot(xx - options.singleCirc.circ2CenterTexX,...
                                    yy - options.singleCirc.circ2CenterTexY) <= options.singleCirc.circ2Radius);
                                
                                % Combine the two alpha arrays
                                options.singleCirc.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder2));
                            end
                        end
                        
                        % Remake the texture
                        texHallway = Screen('MakeTexture',options.windowNum,options.singleCirc.ballHallImageArray{n});
                        
                        % Add in fixation parts
                        % Calculate fixation location (halfway between center points of both spheres
                        options.singleCirc.fixationLoc(:) = [(options.singleCirc.circ2CenterTexX+options.singleCirc.circ1CenterTexX)/2 ...
                            (options.singleCirc.circ1CenterTexY+options.singleCirc.circ2CenterTexY)/2];
                        
                        % Add in black square behind fixation
                        if r==1
                        elseif r==2
                            Screen('FillRect',texHallway,[0 0 0],...
                                [options.singleCirc.fixationLoc(1)-(options.fixSize+options.fixSquareSize),...
                                options.singleCirc.fixationLoc(2)-(options.fixSize+options.fixSquareSize),...
                                options.singleCirc.fixationLoc(1)+(options.fixSize+options.fixSquareSize),...
                                options.singleCirc.fixationLoc(2)+(options.fixSize+options.fixSquareSize)]);
                        end
                        
                        % Add in fixation
                        Screen('FillOval',texHallway,options.fixColSingle(q,:),[options.singleCirc.fixationLoc(1)-options.fixSize,options.singleCirc.fixationLoc(2)-options.fixSize,...
                            options.singleCirc.fixationLoc(1)+options.fixSize,options.singleCirc.fixationLoc(2)+options.fixSize]);
                        %                             Screen('DrawLine',texHallway,[0 255 0],...
                        %                                 options.fixationLoc(1),options.fixationLoc(2),options.fixationLoc(3),options.fixationLoc(4),options.fixSize);
                        
                        
                        % Draw texture hallway
                        Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.singleCirc.ballHallImSizeX/2, options.yc - options.singleCirc.ballHallImSizeY/2,...
                            options.xc + options.singleCirc.ballHallImSizeX/2, options.yc + options.singleCirc.ballHallImSizeY/2]);
                        
                        Screen('Flip',options.windowNum);
                        
                        WaitSecs(.1);
                        
                        % Save
                        if saveSwitch == 1
                            % Save the images and locations
                            % Grab the screen at the size of the texture that includes the balls
                            imageArray.image = Screen('GetImage',options.windowNum,[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                                options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                            if m<5
                                if r==1
                                    if q==1
                                        imwrite(imageArray.image,sprintf('%s%s%d%s',options.singleCirc.outputImageName{n},'_cyan_',p,'.png'));
                                    elseif q==2
                                        imwrite(imageArray.image,sprintf('%s%s%d%s',options.singleCirc.outputImageName{n},'_red_',p,'.png'));
                                    end
                                elseif r==2
                                    if q==1
                                        imwrite(imageArray.image,sprintf('%s%s%d%s',options.singleCirc.outputImageName{n},'_cyan_fixChange_',p,'.png'));
                                    elseif q==2
                                        imwrite(imageArray.image,sprintf('%s%s%d%s',options.singleCirc.outputImageName{n},'_red_fixChange_',p,'.png'));
                                    end
                                end
                            else
                                if r==1   % Don't save black square no checker stim
                                    if q==1
                                        imwrite(imageArray.image,sprintf('%s%s',options.singleCirc.outputImageName{n},'_cyan.png'));
                                    elseif q==2
                                        imwrite(imageArray.image,sprintf('%s%s',options.singleCirc.outputImageName{n},'_red.png'));
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if escBreak==1
                break
            end
            
        end
        
        if escBreak==1
            break
        end
        
    end
    
    %% Calculate/create the 1:1 stim for the MR task
    % Use same size/position values determined for single ball stim
    
    % Deteremine if you want to draw both phases
    if genPhaseSwitch==1
        genPhaseCount = 2;
        whichPhase = 1;
    elseif genPhaseSwitch==0
        genPhaseCount = 1;
    end
    
    for p=1:genPhaseCount
        
        if quitSwitch == 0
            % Load in single circ textures
            cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/MRStim/
            options.MRStim.ballHallImageArray = imread(options.MRStim.ballHallImageList{1});
            cd ../../../
            
            options.MRStim.ballHallImSizeX = size(options.MRStim.ballHallImageArray,1);
            options.MRStim.ballHallImSizeY = size(options.MRStim.ballHallImageArray,2);
            
            %% Make and draw stim
            fixColCount=2;   % For the checker stim make 2 stim w/ 2 diff fixation colors (for MR and EEG)
            for r=1:2   % For checker stim, make 2 versions, 1 with black square behind fixation, one without (for fix change trials)
                for q=1:fixColCount   % Make 2 stim, 1 w/ red fixation and 1 w/ cyan fixation
                    if m<5

                        % Make the texturex
                        tex1 = Screen('MakeTexture',options.windowNum,options.singleCirc.checkerboard(1,1).texArray{p});
                        tex2 = Screen('MakeTexture',options.windowNum,options.singleCirc.checkerboard(1,2).texArray{p});
                        
                        % Draw checkerboard stim
                        Screen('DrawTexture',options.windowNum,tex1,[],options.singleCirc.circ1CoordScreen(:));
                        Screen('DrawTexture',options.windowNum,tex2,[],options.singleCirc.circ2CoordScreen(:));
                        
                        % Create hallway texture
                        [xx,yy] = meshgrid(1:options.singleCirc.ballHallImSizeX,1:options.singleCirc.ballHallImSizeY);
                        arrayHolder1 = zeros([options.singleCirc.ballHallImSizeX,options.singleCirc.ballHallImSizeY]);
                        arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.singleCirc.circ1CenterTexX,...
                            yy - options.singleCirc.circ1CenterTexY) <= options.singleCirc.circ1Radius);
                        
                        [xx,yy] = meshgrid(1:options.singleCirc.ballHallImSizeX,1:options.singleCirc.ballHallImSizeY);
                        arrayHolder2 = zeros([options.singleCirc.ballHallImSizeX,options.singleCirc.ballHallImSizeY]);
                        arrayHolder2 = ~(arrayHolder2 | hypot(xx - options.singleCirc.circ2CenterTexX,...
                            yy - options.singleCirc.circ2CenterTexY) <= options.singleCirc.circ2Radius);
                        
                        % Combine the two alpha arrays
                        options.MRStim.ballHallImageArray(:,:,4) = 255*(double(arrayHolder1).*double(arrayHolder2));
                    end
                    
                    % Remake the texture
                    texHallway = Screen('MakeTexture',options.windowNum,options.MRStim.ballHallImageArray);
                    
                    % Add in fixation parts
                    % Calculate fixation location (halfway between center points of both spheres
                    options.singleCirc.fixationLoc(:) = [(options.singleCirc.circ2CenterTexX+options.singleCirc.circ1CenterTexX)/2 ...
                        (options.singleCirc.circ1CenterTexY+options.singleCirc.circ2CenterTexY)/2];
                    
                    % Add in black square behind fixation
                    if r==1
                    elseif r==2
                        Screen('FillRect',texHallway,[0 0 0],...
                            [options.singleCirc.fixationLoc(1)-(options.fixSize+options.fixSquareSize),...
                            options.singleCirc.fixationLoc(2)-(options.fixSize+options.fixSquareSize),...
                            options.singleCirc.fixationLoc(1)+(options.fixSize+options.fixSquareSize),...
                            options.singleCirc.fixationLoc(2)+(options.fixSize+options.fixSquareSize)]);
                    end
                    
                    % Add in fixation
                    Screen('FillOval',texHallway,options.fixColSingle(q,:),[options.singleCirc.fixationLoc(1)-options.fixSize,options.singleCirc.fixationLoc(2)-options.fixSize,...
                        options.singleCirc.fixationLoc(1)+options.fixSize,options.singleCirc.fixationLoc(2)+options.fixSize]);
                    
                    % Draw texture hallway
                    Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.singleCirc.ballHallImSizeX/2, options.yc - options.singleCirc.ballHallImSizeY/2,...
                        options.xc + options.singleCirc.ballHallImSizeX/2, options.yc + options.singleCirc.ballHallImSizeY/2]);
                    
                    Screen('Flip',options.windowNum);
                    
                    WaitSecs(.1);
                    
                    % Save
                    if saveSwitch == 1
                        % Save the images and locations
                        % Grab the screen at the size of the texture that includes the balls
                        imageArray.image = Screen('GetImage',options.windowNum,[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                            options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                        if m<5
                            if r==1
                                if q==1
                                    imwrite(imageArray.image,sprintf('%s%s%d%s',options.MRStim.outputImageName{1},'_cyan_',p,'.png'));
                                elseif q==2
                                    imwrite(imageArray.image,sprintf('%s%s%d%s',options.MRStim.outputImageName{1},'_red_',p,'.png'));
                                end
                            elseif r==2
                                if q==1
                                    imwrite(imageArray.image,sprintf('%s%s%d%s',options.MRStim.outputImageName{1},'_cyan_fixChange_',p,'.png'));
                                elseif q==2
                                    imwrite(imageArray.image,sprintf('%s%s%d%s',options.MRStim.outputImageName{1},'_red_fixChange_',p,'.png'));
                                end
                            end
                        else
                            if r==1   % Don't save black square no checker stim
                                if q==1
                                    imwrite(imageArray.image,sprintf('%s%s',options.MRStim.outputImageName{1},'_cyan.png'));
                                elseif q==2
                                    imwrite(imageArray.image,sprintf('%s%s',options.MRStim.outputImageName{1},'_red.png'));
                                end
                            elseif r==2
                                if q==1
                                    imwrite(imageArray.image,sprintf('%s%s',options.MRStim.outputImageName{1},'_cyan_fixChange.png'));
                                elseif q==2
                                    imwrite(imageArray.image,sprintf('%s%s',options.MRStim.outputImageName{1},'_red_fixChange.png'));
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if escBreak==1
            break
        end
        
    end
    
    if escBreak==1
        break
    end
    
    %% Final save of all values
    if saveSwitch == 1
        % Save the calculated/measured values
        save(sprintf('%s%s',options.outputFileName,'_FixLine_SingleCirc'),'options')
    end
    
    
    if escBreak==1
        break
    end
    
end

ListenChar()
Screen('CloseAll');







