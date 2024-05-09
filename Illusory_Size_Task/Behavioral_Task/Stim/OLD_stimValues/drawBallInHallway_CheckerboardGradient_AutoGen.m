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
options = rmfield(options,'buttons');
options.prevSizePosOptions = prevSizePosOptions;

% Set PPD, if needed
options.displayInfo.linearClut = 0:1/255:1;
options.whiteCol = [255 255 255];
options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);

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
% Array of sizes to be used in psychophysics
% options.sizePropArray = [.75:.025:.9 .91:.01:.99 1 1.01:.01:1.09 1.1:0.025:1.25];
% options.sizePropArray = [1 2];
options.sizePropArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];

options.fixSize = 3;

measureSize = 1;   % If plot lines to measure ball sizes
quitSwitch = 0;   % Set to quit out of program
checkSizeSwitch = 1;   % 1=constant size checks; 2=constant num checks
genPhaseSwitch = 1;   % Generate both phases of the checkerboard
% Array to tell script what stim to generate; 
% 1st=same size checks, 2nd=same num checks, 3rd=same size no hallway, 4th=same num no hallway; 5th=fix only
% stimTypeArray = [1 1 1 1 1 1];
stimTypeArray = [0 0 0 0 1 1];

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
                    options.sizePropArray(i),'_sameCheckSize_hallway_7degAlpha_Texture.png');
            end
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
                    options.sizePropArray(i),'_sameCheckNum_hallway_7degAlpha_Texture.png');
            end
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
                    options.sizePropArray(i),'_sameCheckSize_noHallway_7degAlpha_Texture.png');
            end
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
                    options.sizePropArray(i),'_sameCheckNum_noHallway_7degAlpha_Texture.png');
            end
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
                    options.sizePropArray(i),'_fixOnly_hallway_7degAlpha_Texture.png');
            end
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
                    options.sizePropArray(i),'_fixOnly_noHallway_7degAlpha_Texture.png');
            end
        end
    end
    
    %% Create stim
    n=0;
    while n<length(options.sizePropArray)   % Use while counter instead, to allow redo of tex drawing
        if quitSwitch == 0
            
            n=n+1;
            
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
                tex1 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,1).texArray{1});
                tex2 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,2).texArray{1});
                
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
            
            % Calculate fixation location (halfway between center points of both spheres
            options.fixationLoc(n,:) = [(options.circ2CenterTexX(n)+options.circ1CenterTexX(n))/2 ...
                 (options.circ1CenterTexY(n)+options.circ2CenterTexY(n))/2];
            
            % Add in fixation
            Screen('FillOval',texHallway,[0 255 0],[options.fixationLoc(n,1)-options.fixSize,options.fixationLoc(n,2)-options.fixSize,...
                options.fixationLoc(n,1)+options.fixSize,options.fixationLoc(n,2)+options.fixSize]);
            
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
                imwrite(imageArray.image,options.outputImageName{n})
            end
        end
        
        if escBreak==1
            break
        end
        
        if saveSwitch == 1
            % Save the calculated/measured values
            save(options.outputFileName,'options')
        end
    end
end

ListenChar()
Screen('CloseAll');







