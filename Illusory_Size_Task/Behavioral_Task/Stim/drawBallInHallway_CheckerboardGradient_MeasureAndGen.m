% Function to plot the ball in the hallway stim and overlay the circular gradient checkerboard. Allows user to load in all
% the various sized hallway textures generated in blender and measure each of the close/far spheres in each of thos
% textures before overlaying them w/ gradient checkerboard spheres.
%
% KWK - 20200325

%% Initialize
clear all;
% close all;

% Add the functions folder to path
addpath(genpath('../Functions/'));

ListenChar(0)

% Set PPD, if needed
options.displayInfo.linearClut = 0:1/255:1;
options.whiteCol = [255 255 255];
options.whiteCol = 255*options.displayInfo.linearClut(round(options.whiteCol)+1);

% PPD varialbes
options.mon_width_cm = 53;   % Width of the monitor (cm)

options.mon_dist_cm = 57;   % Viewing distance (cm)
options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
options.PPD = (1920/options.mon_width_deg);   % pixels per degree
% options.PPD = 38;

% Define keys
KbName('UnifyKeyNames');
options.buttons.buttonEscape = KbName('escape');
options.buttons.buttonEnter = KbName('return');
options.buttons.buttonRight = KbName('rightarrow');
options.buttons.buttonLeft = KbName('leftarrow');
options.buttons.buttonUp = KbName('uparrow');
options.buttons.buttonDown = KbName('downarrow');
options.buttons.buttonRightArrow = KbName('.>');
options.buttons.buttonLeftArrow = KbName(',<');
options.buttons.buttonR = KbName('r');

%     texSwitch = 1;   % Keep track of which phase the checkerboard is in
%     updateTex = 0;   % Is a phase switch needed?
measureSize = 1;   % If plot lines to measure ball sizes
redoTexSwitch = 0;   % Switch to redo the current texture if coverage isn't complete
lineSpeed = 1;   % Amount to move the lines each button press
quitSwitch = 0;   % Set to quit out of program
checkSizeSwitch = 2;   % 1=constant size checks; 2=constant num checks

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
% Need to figure out BASELINE size (where far ball and close ball are same physical size) based on angle (alpha) from camera.
% Can then figure out angles of MAX and MIN size of small ball relative to far ball.
% Can the calculate all angles between the MAX/MIN angles and BASELINE angle (and the corresponding sizes for those angles).
% Proportion of the sizes created here (ensuring that close ball is 25% of
% the size of the far ball in pixels i.e.) SHOULD be the same

% Array of sizes to be used in psychophysics
% options.sizePropArray = [.75:.025:.9 .91:.01:.99 1 1.01:.01:1.09 1.1:0.025:1.25];
% options.sizePropArray = [1 2];
options.sizePropArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];

% Image name array
for i=1:length(options.sizePropArray)
    options.ballHallImageList{i} = sprintf('%s%.3f%s','ballHallway_',options.sizePropArray(i),'_7degAlpha.png');
end

%% Draw stim on screen
[options.windowNum,options.rect] = Screen('OpenWindow',2,[128 128 128] );
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;

% Alpha blending
Screen('BlendFunction',options.windowNum, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   % Must have for alpha values for some reason

circ2AdjustArray = [0 0 0 0];   % Array to adjust the far circ during first texture measurments
n=0;
while n<length(options.sizePropArray)   % Use while counter instead, to allow redo of tex drawing
    if quitSwitch == 0
        
        n=n+1;
        
        % Add switch to redo measurements for this texture. If 'r' start over.
        % Clear out all relevant variables for this texture.
        if redoTexSwitch == 1
            n=n-1;   % Reset counter
            
            redoTexSwitch = 0;
        end
        
        %% Load hallway stim
        cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/
        options.ballHallImageArray{n} = imread(options.ballHallImageList{n});
        cd ../../
        
        % Add in alpha layer to image to manipulate later
        % options.ballHallImageArray{n}(:,:,4) = zeros([size(options.ballHallImageArray{n},1),size(options.ballHallImageArray{n},2)])+255;
        
        options.ballHallImSizeX = size(options.ballHallImageArray{n},1);
        options.ballHallImSizeY = size(options.ballHallImageArray{n},2);
        
        texHallway = Screen('MakeTexture',options.windowNum,options.ballHallImageArray{n});
        
        %     tex1 = Screen('MakeTexture',options.windowNum,options.checkerboard.texArray{1});
        %     tex2 = Screen('MakeTexture',options.windowNum,options.checkerboard.texArray{2});
        
        %         tex = Screen('MakeTexture',options.windowNum,options.checkerboard.texArray{1});    % Holder tex for different phase
        
        if n==1
            maxLineSwitch = 5;  % Determine how many lines you need to draw depending on what texture you're drawing
        else
            maxLineSwitch = 3;  % Determine how many lines you need to draw depending on what texture you're drawing
        end
        
        if measureSize == 1
            
            whichLineSwitch = 1;   % Keep track of which lines are plotted during ball measuring
            
            % Initial values for each of the 4 lines
            % Bottom width
            options.lineX1(n,1) = (options.ballHallImSizeX/4)-40;
            options.lineY1(n,1) = (options.ballHallImSizeX*(3/4));
            options.lineX2(n,1) = (options.ballHallImSizeX/4)+40;
            options.lineY2(n,1) = (options.ballHallImSizeX*(3/4));
            
            % Bottom height
            options.lineX1(n,2) = (options.ballHallImSizeX/4);
            options.lineY1(n,2) = (options.ballHallImSizeY*(3/4))-40;
            options.lineX2(n,2) = (options.ballHallImSizeX/4);
            options.lineY2(n,2) = (options.ballHallImSizeY*(3/4))+40;
            
            % Top width
            options.lineX1(n,3) = (options.ballHallImSizeX*(3/4))-40;
            options.lineY1(n,3) = (options.ballHallImSizeY/4);
            options.lineX2(n,3) = (options.ballHallImSizeX*(3/4))+40;
            options.lineY2(n,3) = (options.ballHallImSizeY/4);
            
            % Top height
            options.lineX1(n,4) = (options.ballHallImSizeX*(3/4));
            options.lineY1(n,4) = (options.ballHallImSizeY/4)-40;
            options.lineX2(n,4) = (options.ballHallImSizeX*(3/4));
            options.lineY2(n,4) = (options.ballHallImSizeY/4)+40;
        end
        %             timeNow = GetSecs;
        while 1
            %         if GetSecs-timeNow > .5
            %             timeNow = GetSecs;
            %             updateTex = 1;
            %             texSwitch = 3-texSwitch;
            %         end
            %         if updateTex == 1
            %             if texSwitch == 1
            %                 tex = tex1;
            %             elseif texSwitch == 2
            %                 tex = tex2;
            %             end
            %             updateTex = 0;
            %         end
            
            % If measuring sizes of balls
            if measureSize==1
                % Draw some adjustable lines on the screen to record the position
                % and size of the balls in the image.
                if whichLineSwitch == 1
                    Screen('DrawLine',texHallway,[0 255 0],options.lineX1(n,whichLineSwitch),options.lineY1(n,whichLineSwitch),options.lineX2(n,whichLineSwitch),options.lineY2(n,whichLineSwitch),5);   % Make the line green for bottom left
                elseif whichLineSwitch == 2
                    Screen('DrawLine',texHallway,[0 255 0],options.lineX1(n,whichLineSwitch),options.lineY1(n,whichLineSwitch),options.lineX2(n,whichLineSwitch),options.lineY2(n,whichLineSwitch),5);   % Make the line green for bottom left
                elseif whichLineSwitch == 3
                    Screen('DrawLine',texHallway,[255 0 0],options.lineX1(n,whichLineSwitch),options.lineY1(n,whichLineSwitch),options.lineX2(n,whichLineSwitch),options.lineY2(n,whichLineSwitch),5);   % Make the line red for top right
                elseif whichLineSwitch == 4
                    Screen('DrawLine',texHallway,[255 0 0],options.lineX1(n,whichLineSwitch),options.lineY1(n,whichLineSwitch),options.lineX2(n,whichLineSwitch),options.lineY2(n,whichLineSwitch),5);   % Make the line red for top right
                end
                
                %% Only measure far sphere on the first iteration! Use that measurement for the rest!
                % If any other value, only measure the close sphere, and use the calculated values for the far sphere from first measurement.
                
                % Update line position and size based on user input
                [~,~,keycode,~] = KbCheck();
                
                if whichLineSwitch==1 || whichLineSwitch==3
                    %% Move  horizontal lines
                    if keycode(options.buttons.buttonUp)   % Move line up
                        if options.lineY1(n,whichLineSwitch)>10 && options.lineY1(n,whichLineSwitch)<options.ballHallImSizeY-10 && options.lineY2(n,whichLineSwitch)>10 && options.lineY2(n,whichLineSwitch)<options.ballHallImSizeY-10
                            options.lineY1(n,whichLineSwitch) = options.lineY1(n,whichLineSwitch)-lineSpeed;
                            options.lineY2(n,whichLineSwitch) = options.lineY2(n,whichLineSwitch)-lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonDown)   % Move line down
                        if options.lineY1(n,whichLineSwitch)>10 && options.lineY1(n,whichLineSwitch)<options.ballHallImSizeY-10 && options.lineY2(n,whichLineSwitch)>10 && options.lineY2(n,whichLineSwitch)<options.ballHallImSizeY-10
                            options.lineY1(n,whichLineSwitch) = options.lineY1(n,whichLineSwitch)+lineSpeed;
                            options.lineY2(n,whichLineSwitch) = options.lineY2(n,whichLineSwitch)+lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonRight)   % Move right coord right
                        if options.lineX2(n,whichLineSwitch)>10 && options.lineX2(n,whichLineSwitch)<options.ballHallImSizeX-10
                            options.lineX2(n,whichLineSwitch) = options.lineX2(n,whichLineSwitch)+lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonLeft)   % Move right coord left
                        if options.lineX2(n,whichLineSwitch)>10 && options.lineX2(n,whichLineSwitch)<options.ballHallImSizeX-10
                            if options.lineX2(n,whichLineSwitch)-10 > options.lineX1(n,whichLineSwitch)
                                options.lineX2(n,whichLineSwitch) = options.lineX2(n,whichLineSwitch)-lineSpeed;
                            end
                        end
                    end
                    if keycode(options.buttons.buttonRightArrow)   % Move left coord right
                        if options.lineX1(n,whichLineSwitch)>10 && options.lineX1(n,whichLineSwitch)<options.ballHallImSizeX-10
                            if options.lineX1(n,whichLineSwitch)+10 < options.lineX2(n,whichLineSwitch)
                                options.lineX1(n,whichLineSwitch) = options.lineX1(n,whichLineSwitch)+lineSpeed;
                            end
                        end
                    end
                    if keycode(options.buttons.buttonLeftArrow)   % Move left coord left
                        if options.lineX1(n,whichLineSwitch)>10 && options.lineX1(n,whichLineSwitch)<options.ballHallImSizeX-10
                            options.lineX1(n,whichLineSwitch) = options.lineX1(n,whichLineSwitch)-lineSpeed;
                        end
                    end
                elseif whichLineSwitch==2 || whichLineSwitch==4
                    %% Move vertical lines
                    if keycode(options.buttons.buttonUp)   % Move top coord up
                        if options.lineY1(n,whichLineSwitch)>10 && options.lineY1(n,whichLineSwitch)<options.ballHallImSizeY-10
                            options.lineY1(n,whichLineSwitch) = options.lineY1(n,whichLineSwitch)-lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonDown)   % Move top coord down
                        if options.lineY1(n,whichLineSwitch)>10 && options.lineY1(n,whichLineSwitch)<options.ballHallImSizeY-10
                            if options.lineY1(n,whichLineSwitch)+10<options.lineY2(n,whichLineSwitch)
                                options.lineY1(n,whichLineSwitch) = options.lineY1(n,whichLineSwitch)+lineSpeed;
                            end
                        end
                    end
                    if keycode(options.buttons.buttonRight)   % Move line right
                        if options.lineX2(n,whichLineSwitch)>10 && options.lineX2(n,whichLineSwitch)<options.ballHallImSizeX-10 && options.lineX1(n,whichLineSwitch)>10 && options.lineX1(n,whichLineSwitch)<options.ballHallImSizeX-10
                            options.lineX1(n,whichLineSwitch) = options.lineX1(n,whichLineSwitch)+lineSpeed;
                            options.lineX2(n,whichLineSwitch) = options.lineX2(n,whichLineSwitch)+lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonLeft)   % Move line left
                        if options.lineX2(n,whichLineSwitch)>10 && options.lineX2(n,whichLineSwitch)<options.ballHallImSizeX-10 && options.lineX1(n,whichLineSwitch)>10 && options.lineX1(n,whichLineSwitch)<options.ballHallImSizeX-10
                            options.lineX1(n,whichLineSwitch) = options.lineX1(n,whichLineSwitch)-lineSpeed;
                            options.lineX2(n,whichLineSwitch) = options.lineX2(n,whichLineSwitch)-lineSpeed;
                        end
                    end
                    if keycode(options.buttons.buttonLeftArrow)   % Move bottom coord up
                        if options.lineY2(n,whichLineSwitch)>10 && options.lineY2(n,whichLineSwitch)<options.ballHallImSizeY-10
                            if options.lineY2(n,whichLineSwitch)-10 > options.lineY1(n,whichLineSwitch)
                                options.lineY2(n,whichLineSwitch) = options.lineY2(n,whichLineSwitch)-lineSpeed;
                            end
                        end
                    end
                    if keycode(options.buttons.buttonRightArrow)   % Move bottom coord down
                        if options.lineY2(n,whichLineSwitch)>10 && options.lineY2(n,whichLineSwitch)<options.ballHallImSizeY-10
                            options.lineY2(n,whichLineSwitch) = options.lineY2(n,whichLineSwitch)+lineSpeed;
                        end
                    end
                end
                
                %% Once the measurement is done, hit enter to lock in and move to next measurement
                if keycode(options.buttons.buttonEnter)
                    
                    WaitSecs(1);
                    
                    whichLineSwitch=whichLineSwitch+1;
                    
                    %% If on the any other hallway stim (n>1), only measure and record/plot the close ball
                    % Plot the checkerboard stim over the relevant ball to check size
                    if whichLineSwitch==3
                        % Circ radius - if the height is slightly larger than width
                        % or vice versa, account for that and draw largest circ
                        % possible.
                        if options.lineX2(n,1)-options.lineX1(n,1) > options.lineY2(n,2)-options.lineY1(n,2)   % Width > height
                            
                            % Calculate and store circle coords based on line measuremnts in hallway texture space
                            options.circ1CoordTex(n,1) = options.lineX1(n,1);   % Circ x1
                            options.circ1CoordTex(n,2) = options.lineY1(n,2);   % Circ y1
                            options.circ1CoordTex(n,3) = options.lineX2(n,1);   % Circ x2
                            options.circ1CoordTex(n,4) = options.lineY1(n,2) + (options.lineX2(n,1)-options.lineX1(n,1));   % Circ y2
                            
                        elseif options.lineX2(n,1)-options.lineX1(n,1) < options.lineY2(n,2)-options.lineY1(n,2)   % Height > width
                            
                            % Calculate and store circle coords based on line measuremnts in hallway texture space
                            options.circ1CoordTex(n,1) = options.lineX1(n,1);   % Circ x1
                            options.circ1CoordTex(n,2) = options.lineY1(n,2);   % Circ y1
                            options.circ1CoordTex(n,3) = options.lineX1(n,1) + (options.lineY2(n,2)-options.lineY1(n,2));   % Circ x2
                            options.circ1CoordTex(n,4) = options.lineY2(n,2);   % Circ y2
                            
                        elseif options.lineX2(n,1)-options.lineX1(n,1) == options.lineY2(n,2)-options.lineY1(n,2)   % Height = width
                            
                            % Calculate and store circle coords based on line measuremnts in hallway texture space
                            options.circ1CoordTex(n,1) = options.lineX1(n,1);   % Circ x1
                            options.circ1CoordTex(n,2) = options.lineY1(n,2);   % Circ y1
                            options.circ1CoordTex(n,3) = options.lineX2(n,1);   % Circ x2
                            options.circ1CoordTex(n,4) = options.lineY2(n,2);   % Circ y2
                            
                        end
                        
                        % If n>1 auto set the new circ2(n) values to circ2(1) values
                        if n>1
                            % Top width
                            options.lineX1(n,3) = options.lineX1(1,3);
                            options.lineY1(n,3) = options.lineY1(1,3);
                            options.lineX2(n,3) = options.lineX2(1,3);
                            options.lineY2(n,3) = options.lineY2(1,3);
                            
                            % Top height
                            options.lineX1(n,4) = options.lineX1(1,4);
                            options.lineY1(n,4) = options.lineY1(1,4);
                            options.lineX2(n,4) = options.lineX2(1,4);
                            options.lineY2(n,4) = options.lineY2(1,4);
                            
                            % Coords in hallway texture space
                            options.circ2CoordTex(n,1) = options.circ2CoordTex(1,1);   % Circ x1
                            options.circ2CoordTex(n,2) = options.circ2CoordTex(1,2);   % Circ y1
                            options.circ2CoordTex(n,3) = options.circ2CoordTex(1,3);   % Circ x2
                            options.circ2CoordTex(n,4) = options.circ2CoordTex(1,4);   % Circ y2
                            
                            % Circ center points in the hallway texture space
                            options.circ2CenterTexX(n) = options.circ2CenterTexX(1);
                            options.circ2CenterTexY(n) = options.circ2CenterTexY(1);
                            
                            % Calculate size
                            options.circ2Size(n) = options.circ2Size(1);
                            
                            % Calculate radius
                            options.circ2Radius(n) = options.circ2Radius(1);
                            
                            % Circ coords in screen space
                            options.circ2CenterX_ScreenSpace(n) = options.circ2CenterX_ScreenSpace(1);
                            options.circ2CenterY_ScreenSpace(n) = options.circ2CenterY_ScreenSpace(1);
                            
                            options.circ2CoordScreen(n,1) = options.circ2CoordScreen(1,1);   % Circ x1
                            options.circ2CoordScreen(n,2) = options.circ2CoordScreen(1,2);   % Circ y1
                            options.circ2CoordScreen(n,3) = options.circ2CoordScreen(1,3);   % Circ x2
                            options.circ2CoordScreen(n,4) = options.circ2CoordScreen(1,4);   % Circ y2
                        end
                        
                        % Circ center points in the hallway texture space
                        options.circ1CenterTexX(n) = nanmean([options.circ1CoordTex(n,3),options.circ1CoordTex(n,1)]);
                        options.circ1CenterTexY(n) = nanmean([options.circ1CoordTex(n,4),options.circ1CoordTex(n,2)]);
                        
                        % Calculate size
                        options.circ1Size(n) = (options.circ1CoordTex(n,3)-options.circ1CoordTex(n,1));
                        
                        % Calculate radius
                        options.circ1Radius(n) = options.circ1Size(n)/2;
                        
                        % Remake the hallway texture alpha layer, making the area
                        % where the ball is to be drawn tranparent.
                        [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                        arrayHolder1 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                        arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.circ1CenterTexX(n),...
                            yy - options.circ1CenterTexY(n)) <= options.circ1Radius(n)).*255;
                        
                        % Circ coords in screen space
                        options.circ1CenterX_ScreenSpace(n) = options.xc - ((options.ballHallImSizeX/2) - options.circ1CenterTexX(n));
                        options.circ1CenterY_ScreenSpace(n) = options.yc - ((options.ballHallImSizeY/2) - options.circ1CenterTexY(n));
                        
                        options.circ1CoordScreen(n,1) = options.circ1CenterX_ScreenSpace(n) - options.circ1Radius(n);   % Circ x1
                        options.circ1CoordScreen(n,2) = options.circ1CenterY_ScreenSpace(n) - options.circ1Radius(n);   % Circ y1
                        options.circ1CoordScreen(n,3) = options.circ1CenterX_ScreenSpace(n) + options.circ1Radius(n);   % Circ x2
                        options.circ1CoordScreen(n,4) = options.circ1CenterY_ScreenSpace(n) + options.circ1Radius(n);   % Circ y2
                        
                        [~,~,keycode,~] = KbCheck();
                        if keycode(options.buttons.buttonEnter)
                            WaitSecs(1);
                            break
                        end
                        if keycode(options.buttons.buttonEscape)
                            quitSwitch = 1;
                            break
                        end
                    end
                    
                    if keycode(options.buttons.buttonR)
                        WaitSecs(1);
                        redoTexSwitch = 1;
                        break
                    end
                    
                    %% When you reach the end (after measuring all needed lines) plot both
                    if whichLineSwitch==maxLineSwitch
                        
                        %% If on the first hallway stim (n=1), measure and record/plot the far ball
                        if n==1
                            if whichLineSwitch==5
                                % Circ radius - if the height is slightly larger than width
                                % or vice versa, account for that and draw largest circ
                                % possible.
                                if options.lineX2(n,3)-options.lineX1(n,3) > options.lineY2(n,4)-options.lineY1(n,4)   % Width > height
                                    
                                    % Calculate and store circle coords based on line measuremnts in hallway texture space
                                    options.circ2CoordTex(n,1) = options.lineX1(n,3);   % Circ x1
                                    options.circ2CoordTex(n,2) = options.lineY1(n,4);   % Circ y1
                                    options.circ2CoordTex(n,3) = options.lineX2(n,3);   % Circ x2
                                    options.circ2CoordTex(n,4) = options.lineY1(n,4) + (options.lineX2(n,3)-options.lineX1(n,3));   % Circ y2
                                    
                                elseif options.lineX2(n,3)-options.lineX1(n,3) < options.lineY2(n,4)-options.lineY1(n,4)   % Height > width
                                    
                                    % Calculate and store circle coords based on line measuremnts in hallway texture space
                                    options.circ2CoordTex(n,1) = options.lineX1(n,3);   % Circ x1
                                    options.circ2CoordTex(n,2) = options.lineY1(n,4);   % Circ y1
                                    options.circ2CoordTex(n,3) = options.lineX1(n,3) + (options.lineY2(n,4)-options.lineY1(n,4));   % Circ x2
                                    options.circ2CoordTex(n,4) = options.lineY2(n,4);   % Circ y2
                                    
                                elseif options.lineX2(n,3)-options.lineX1(n,3) == options.lineY2(n,4)-options.lineY1(n,4)   % Height = width
                                    
                                    % Calculate and store circle coords based on line measuremnts in hallway texture space
                                    options.circ2CoordTex(n,1) = options.lineX1(n,3);   % Circ x1
                                    options.circ2CoordTex(n,2) = options.lineY1(n,4);   % Circ y1
                                    options.circ2CoordTex(n,3) = options.lineX2(n,3);   % Circ x2
                                    options.circ2CoordTex(n,4) = options.lineY2(n,4);   % Circ y2
                                    
                                end
                                
                                % Circ center points in the hallway texture space
                                options.circ2CenterTexX(n) = nanmean([options.circ2CoordTex(n,3),options.circ2CoordTex(n,1)]);
                                options.circ2CenterTexY(n) = nanmean([options.circ2CoordTex(n,4),options.circ2CoordTex(n,2)]);
                                
                                % Calculate size
                                options.circ2Size(n) = (options.circ2CoordTex(n,3)-options.circ2CoordTex(n,1));
                                
                                % Calculate radius
                                options.circ2Radius(n) = options.circ2Size(n)/2;
                                
                                % Circ coords in screen space
                                options.circ2CenterX_ScreenSpace(n) = options.xc - ((options.ballHallImSizeX/2) - options.circ2CenterTexX(n));
                                options.circ2CenterY_ScreenSpace(n) = options.yc - ((options.ballHallImSizeY/2) - options.circ2CenterTexY(n));
                                options.circ2CoordScreen(n,1) = options.circ2CenterX_ScreenSpace(n) - options.circ2Radius(n);   % Circ x1
                                options.circ2CoordScreen(n,2) = options.circ2CenterY_ScreenSpace(n) - options.circ2Radius(n);   % Circ y1
                                options.circ2CoordScreen(n,3) = options.circ2CenterX_ScreenSpace(n) + options.circ2Radius(n);   % Circ x2
                                options.circ2CoordScreen(n,4) = options.circ2CenterY_ScreenSpace(n) + options.circ2Radius(n);   % Circ y2
                            end
                        end
                        
                        %% Recalculate the size of the close ball if it is the
                        % incorrect size, proportionally to the far ball.
                        closeCircSizeHolder = options.circ2Size(n)*options.sizePropArray(n);   % Make a variable that has the expected size of the close ball (close ball = percentage of far ball)
                        if closeCircSizeHolder <= options.circ1Size(n)+2  && closeCircSizeHolder >= options.circ1Size(n)-2   % IF w/in a couple pixels of the correct size don't worry about it
                        else   % If far outside the correct size, set the size of the close ball to the correct size
                            
                            % Recalculate size and radius
                            options.circ1Size(n) = closeCircSizeHolder;
                            options.circ1Radius(n) = options.circ1Size(n)/2;
                            
                            % Re-calculate the positions using the new size value (in screen space)
                            options.circ1CoordScreen(n,1) = options.circ1CenterX_ScreenSpace(n)-options.circ1Radius(n);
                            options.circ1CoordScreen(n,2) = options.circ1CenterY_ScreenSpace(n)-options.circ1Radius(n);
                            options.circ1CoordScreen(n,3) = options.circ1CenterX_ScreenSpace(n)+options.circ1Radius(n);
                            options.circ1CoordScreen(n,4) = options.circ1CenterY_ScreenSpace(n)+options.circ1Radius(n);
                            
                            % Re-calculate the positions using the new size value (in tex space - will need to keep updated for later adjustments)
                            options.circ1CoordTex(n,1) = options.circ1CenterTexX(n)-options.circ1Radius(n);
                            options.circ1CoordTex(n,2) = options.circ1CenterTexY(n)-options.circ1Radius(n);
                            options.circ1CoordTex(n,3) = options.circ1CenterTexX(n)+options.circ1Radius(n);
                            options.circ1CoordTex(n,4) = options.circ1CenterTexY(n)+options.circ1Radius(n);
                            
                            % Remake the hallway texture alpha layer, making the area
                            % where the ball is to be drawn tranparent.
                            [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                            arrayHolder1 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                            arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.circ1CenterTexX(n),...
                                yy - options.circ1CenterTexY(n)) <= options.circ1Radius(n)).*255;
                        end
                        
                        %% Make the final texture, including cutouts for both spheres
                        % Make a holder alpha array to draw the far sphere,
                        % that we can combine with the already existing close
                        % sphere alpha array to make the final texture alpha
                        % layer.
                        [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                        arrayHolder2 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                        arrayHolder2 = ~(arrayHolder2 | hypot(xx - options.circ2CenterTexX(n),...
                            yy - options.circ2CenterTexY(n)) <= options.circ2Radius(n));
                        
                        % Combine the two alpha arrays
                        options.ballHallImageArray{n}(:,:,4) = arrayHolder1/255;   % Reset alpha layer to arrayHolder1, incase it change from above
                        options.ballHallImageArray{n}(:,:,4) = 255*(double(options.ballHallImageArray{n}(:,:,4)).*double(arrayHolder2));   % Combine w/ new arrayHolder2
                        
                        % Close the other texHallway before remaking
                        Screen('Close',texHallway);
                        
                        % Remake the texture
                        texHallway = Screen('MakeTexture',options.windowNum,options.ballHallImageArray{n});
                        
                        
                        %% Create the two checkerboard texures using the size variables
                        % Determine the sizes of each of the two textures in DoVA
                        options.circ1SizeDeg(n) = options.circ1Size(n)/options.PPD;
                        options.circ2SizeDeg(n) = options.circ2Size(n)/options.PPD;
                        
                        % Create the textures
                        optionsHolder = options;
                        optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n);
                        options.checkerboard = optionsHolder.checkerboard;
                        clear optionsHolder
                        
                        % Make the texturex
                        tex1 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,1).texArray{1});
                        tex2 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,2).texArray{1});
                        
                        %% Adjust overall position and size for both balls
                        % Now that we've calculated positions and sizes for both
                        % balls, make sure that they are the correct proportion.
                        % (According to a proportion list:
                        % -50% of far ball size to +50% of far ball size)
                        % options.sizePropArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1.025:.025:1.2 1.25:.05:1.5];
                        % Which ball are you adjusting...only adjust far ball if n==1
                        if n==1
                            ballAdjustSwitch = 1;   % Switch for adjust which ball you're adjusting
                            sizePosSwitch = 1;   % Switch for adjusting size or position
                        elseif n>1
                            ballAdjustSwitch = 2;   % Switch for adjust which ball you're adjusting
                            sizePosSwitch = 2;   % Switch for adjusting size or position
                        end
                        while 1
                            
                            % Draw checkerboard stim
                            Screen('DrawTexture',options.windowNum,tex1,[],options.circ1CoordScreen(n,:));
                            Screen('DrawTexture',options.windowNum,tex2,[],options.circ2CoordScreen(n,:));
                            
                            % Draw hallway stim
                            Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                                options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                            
                            Screen('Flip',options.windowNum);
                            
                            [~,~,keycode,~] = KbCheck();
                            if ~isempty(keycode)
                                
                                % Adjust entire ball using keys
                                % For position:
                                %   Up/Down moves entire ball up/down
                                %   Right/Left moves entire ball left/right
                                % For size:
                                %   Up/down increases entire area
                                %   Up adds m to x2/y2
                                %   Down subtracts m from x1/y1
                                if ballAdjustSwitch == 1   % Adjust far ball (only when n==1)
                                    %% Adjust far sphere first
                                    if n==1
                                        %% First adjust for size, then position
                                        % Move sphere up/Increase size
                                        if keycode(options.buttons.buttonUp)
                                            if sizePosSwitch == 1   % Adjust for size
                                                circ2AdjustArray(1:4) = circ2AdjustArray(1:4) + [-1 -1 1 1];
                                            elseif sizePosSwitch == 2   % Adjust for position
                                                circ2AdjustArray([2 4]) = circ2AdjustArray([2 4]) + [-1 -1];
                                            end
                                        end
                                        % Move sphere down/Decrease size
                                        if keycode(options.buttons.buttonDown)
                                            if sizePosSwitch == 1   % Adjust for size
                                                circ2AdjustArray(1:4) = circ2AdjustArray(1:4) + [1 1 -1 -1];
                                            elseif sizePosSwitch == 2   % Adjust for position
                                                circ2AdjustArray([2 4]) = circ2AdjustArray([2 4]) + [1 1];
                                            end
                                        end
                                        % Move sphere left
                                        if keycode(options.buttons.buttonLeft)
                                            if sizePosSwitch == 2   % Adjust for position
                                                circ2AdjustArray([1 3]) = circ2AdjustArray([1 3]) + [-1 -1];
                                            end
                                        end
                                        % Move sphere right
                                        if keycode(options.buttons.buttonRight)
                                            if sizePosSwitch == 2   % Adjust for position
                                                circ2AdjustArray([1 3]) = circ2AdjustArray([1 3]) + [1 1];
                                            end
                                        end
                                        
                                        %% Recreate far sphere size/position/coord variables to include new values
                                        % Top width
                                        options.lineX1(1,3) = options.lineX1(1,3) + circ2AdjustArray(1);
                                        options.lineY1(1,3) = options.lineY1(1,3) + circ2AdjustArray(2);
                                        options.lineX2(1,3) = options.lineX2(1,3) + circ2AdjustArray(3);
                                        options.lineY2(1,3) = options.lineY2(1,3) + circ2AdjustArray(4);
                                        
                                        % Top height
                                        options.lineX1(1,4) = options.lineX1(1,4) + circ2AdjustArray(1);
                                        options.lineY1(1,4) = options.lineY1(1,4) + circ2AdjustArray(2);
                                        options.lineX2(1,4) = options.lineX2(1,4) + circ2AdjustArray(3);
                                        options.lineY2(1,4) = options.lineY2(1,4) + circ2AdjustArray(4);
                                        
                                        % Coords in hallway texture space
                                        options.circ2CoordTex(1,:) = options.circ2CoordTex(1,:) + circ2AdjustArray(:)';
                                        
                                        % Circ center points in the hallway texture space
                                        options.circ2CenterTexX(1) = nanmean([options.circ2CoordTex(1,3),options.circ2CoordTex(1,1)]);
                                        options.circ2CenterTexY(1) = nanmean([options.circ2CoordTex(1,4),options.circ2CoordTex(1,2)]);
                                        
                                        % Calculate size
                                        options.circ2Size(1) = (options.circ2CoordTex(1,3)-options.circ2CoordTex(1,1));
                                        
                                        % Calculate radius
                                        options.circ2Radius(n) = options.circ2Size(1)/2;
                                        
                                        % Circ coords in screen space
                                        options.circ2CenterX_ScreenSpace(1) = options.xc - ((options.ballHallImSizeX/2) - options.circ2CenterTexX(1));
                                        options.circ2CenterY_ScreenSpace(1) = options.yc - ((options.ballHallImSizeY/2) - options.circ2CenterTexY(1));
                                        
                                        % Coords in hallway screen space
                                        options.circ2CoordScreen(1,:) = options.circ2CoordScreen(1,:) +  circ2AdjustArray(:)';
                                        
                                        % Remake the hallway texture alpha layer, making the area
                                        % where the ball is to be drawn tranparent.
                                        [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                                        arrayHolder2 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                                        arrayHolder2 = ~(arrayHolder2 | hypot(xx - options.circ2CenterTexX(n),...
                                            yy - options.circ2CenterTexY(n)) <= options.circ2Radius(n));
                                        
                                        %% Recreate close sphere size/position/coord variables to include new values
                                        % B/c we are potentially adjusting the size of the far ball here, we want to also
                                        % make sure we change the values of the the close ball to keep the proportions
                                        % correct, as well as update all the size/position/coords for the far ball.
                                        closeCircSizeHolder = options.circ2Size(n)*options.sizePropArray(n);   % Make a variable that has the expected size of the close ball (close ball = percentage of far ball)
                                        
                                        % Recalculate size and radius
                                        options.circ1Size(n) = closeCircSizeHolder;
                                        options.circ1Radius(n) = options.circ1Size(n)/2;
                                        
                                        % Re-calculate the positions using the new size value (in screen space)
                                        options.circ1CoordScreen(n,1) = options.circ1CenterX_ScreenSpace(n)-options.circ1Radius(n);
                                        options.circ1CoordScreen(n,2) = options.circ1CenterY_ScreenSpace(n)-options.circ1Radius(n);
                                        options.circ1CoordScreen(n,3) = options.circ1CenterX_ScreenSpace(n)+options.circ1Radius(n);
                                        options.circ1CoordScreen(n,4) = options.circ1CenterY_ScreenSpace(n)+options.circ1Radius(n);
                                        
                                        % Re-calculate the positions using the new size value (in tex space - will need to keep updated for later adjustments)
                                        options.circ1CoordTex(n,1) = options.circ1CenterTexX(n)-options.circ1Radius(n);
                                        options.circ1CoordTex(n,2) = options.circ1CenterTexY(n)-options.circ1Radius(n);
                                        options.circ1CoordTex(n,3) = options.circ1CenterTexX(n)+options.circ1Radius(n);
                                        options.circ1CoordTex(n,4) = options.circ1CenterTexY(n)+options.circ1Radius(n);
                                        
                                        % Remake the hallway texture alpha layer, making the area
                                        % where the ball is to be drawn tranparent.
                                        [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                                        arrayHolder1 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                                        arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.circ1CenterTexX(n),...
                                            yy - options.circ1CenterTexY(n)) <= options.circ1Radius(n)).*255;
                                        
                                        % Reset the adjustment counter
                                        circ2AdjustArray = [0 0 0 0];
                                    else
                                        ballAdjustSwitch = 2;   % If n>1 skip far ball
                                    end
                                end
                                
                                if ballAdjustSwitch == 2   % Adjust close ball
                                    %% Adjust close sphere next
                                    %% First adjust for size, then position
                                    % Move sphere up/Increase size
                                    if keycode(options.buttons.buttonUp)
                                        if sizePosSwitch == 2   % Adjust for position
                                            options.circ1CoordScreen(n,[2 4]) = options.circ1CoordScreen(n,[2 4]) + [-1 -1];
                                            options.circ1CoordTex(n,[2 4]) = options.circ1CoordTex(n,[2 4]) + [-1 -1];
                                        end
                                    end
                                    % Move sphere down/Decrease size
                                    if keycode(options.buttons.buttonDown)
                                        if sizePosSwitch == 2   % Adjust for position
                                            options.circ1CoordScreen(n,[2 4]) = options.circ1CoordScreen(n,[2 4]) + [1 1];
                                            options.circ1CoordTex(n,[2 4]) = options.circ1CoordTex(n,[2 4]) + [1 1];
                                        end
                                    end
                                    % Move sphere left
                                    if keycode(options.buttons.buttonLeft)
                                        if sizePosSwitch == 2   % Adjust for position
                                            options.circ1CoordScreen(n,[1 3]) = options.circ1CoordScreen(n,[1 3]) + [-1 -1];
                                            options.circ1CoordTex(n,[1 3]) = options.circ1CoordTex(n,[1 3]) + [-1 -1];
                                        end
                                    end
                                    % Move sphere right
                                    if keycode(options.buttons.buttonRight)
                                        if sizePosSwitch == 2   % Adjust for position
                                            options.circ1CoordScreen(n,[1 3]) = options.circ1CoordScreen(n,[1 3]) + [1 1];
                                            options.circ1CoordTex(n,[1 3]) = options.circ1CoordTex(n,[1 3]) + [1 1];
                                        end
                                    end
                                    
                                    %% Recreate arrays and position variables to include new values
                                    % Recalculate the size and radius
                                    options.circ1Size(n) = (options.circ1CoordScreen(n,3)-options.circ1CoordScreen(n,1));
                                    options.circ1Radius(n) = options.circ1Size(n)/2;
                                    
                                    % Recalculate circ center points in texture space
                                    options.circ1CenterTexX(n) = nanmean([options.circ1CoordTex(n,3),options.circ1CoordTex(n,1)]);
                                    options.circ1CenterTexY(n) = nanmean([options.circ1CoordTex(n,4),options.circ1CoordTex(n,2)]);
                                    
                                    % Remake the hallway texture alpha layer, making the area
                                    % where the ball is to be drawn tranparent.
                                    [xx,yy] = meshgrid(1:options.ballHallImSizeX,1:options.ballHallImSizeY);
                                    arrayHolder1 = zeros([options.ballHallImSizeX,options.ballHallImSizeY]);
                                    arrayHolder1 = ~(arrayHolder1 | hypot(xx - options.circ1CenterTexX(n),...
                                        yy - options.circ1CenterTexY(n)) <= options.circ1Radius(n));
                                end
                                
                                %% When you hit enter switch to close ball
                                if keycode(options.buttons.buttonEnter)
                                    WaitSecs(1);
                                    % Use enter key for each step
                                    if ballAdjustSwitch==1
                                        if n==1
                                            if sizePosSwitch==1
                                                sizePosSwitch = 2;
                                            elseif sizePosSwitch == 2
                                                ballAdjustSwitch = 2;   % Switch to close
                                            end
                                        end
                                    elseif ballAdjustSwitch==2
                                        ballAdjustSwitch=3;
                                    end
                                end
                                
                                %% Remake the hallway texture
                                % Combine the two
                                options.ballHallImageArray{n}(:,:,4) = 255*(double(arrayHolder1).*double(arrayHolder2));
                                
                                % Close the other texHallway before remaking
                                Screen('Close',texHallway);
                                
                                % Remake the texture
                                texHallway = Screen('MakeTexture',options.windowNum,options.ballHallImageArray{n});
                                
                                %% Remake the checkerboard textures
                                % Determine the sizes of each of the two textures in DoVA
                                options.circ1SizeDeg(n) = options.circ1Size(n)/options.PPD;
                                options.circ2SizeDeg(n) = options.circ2Size(n)/options.PPD;
                                
                                % Create the textures
                                optionsHolder = options;
                                optionsHolder = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n);
                                options.checkerboard = optionsHolder.checkerboard;
                                clear optionsHolder
                                
                                % Make the texturex
                                tex1 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,1).texArray{1});
                                tex2 = Screen('MakeTexture',options.windowNum,options.checkerboard(n,2).texArray{1});
                            end
                            
                            clear keycode
                            
                            [~,~,keycode,~] = KbCheck();
                            if ballAdjustSwitch == 3   % When done with both balls, move onto next texture
                                WaitSecs(1);
                                break
                            end
                            if keycode(options.buttons.buttonEscape)
                                quitSwitch = 1;
                                break
                            end
                            % Add switch to redo. If 'r', go back and redo
                            % measurements for this stim.
                            if keycode(options.buttons.buttonR) || redoTexSwitch == 1
                                WaitSecs(1);
                                redoTexSwitch = 1;
                                break
                            end
                        end
                    end
                end
            end
            
            [~,~,keycode,~] = KbCheck();
            if keycode(options.buttons.buttonEscape)
                quitSwitch = 1;
                WaitSecs(1);
                break
            end
            if keycode(options.buttons.buttonR) || redoTexSwitch == 1
                WaitSecs(1);
                redoTexSwitch = 1;
                break
            end
            
            % If you've finished measuring and adjusting break out of draw loop and move to next texture
            if whichLineSwitch==maxLineSwitch
                break
            end
            
            Screen('DrawTexture',options.windowNum,texHallway,[],[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
            
            Screen('Flip',options.windowNum);
            
            if measureSize==1
                % Close and remake texutre
                Screen('Close',texHallway);
                texHallway = Screen('MakeTexture',options.windowNum,options.ballHallImageArray{n});
            end
        end
        
        if redoTexSwitch == 0
            if saveSwitch == 1
                % Save the images and locations
                % Grab the screen at the size of the texture that includes the balls
                imageArray.image = Screen('GetImage',options.windowNum,[options.xc - options.ballHallImSizeX/2, options.yc - options.ballHallImSizeY/2,...
                    options.xc + options.ballHallImSizeX/2, options.yc + options.ballHallImSizeY/2]);
                if checkSizeSwitch == 1
                    imwrite(imageArray.image,sprintf('%s%.3f%s',...
                        './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',options.sizePropArray(n),'_sameCheckSize_7degAlpha_Texture.png'));
                elseif checkSizeSwitch == 2
                    imwrite(imageArray.image,sprintf('%s%.3f%s',...
                        './Ball_In_Hallway_Stimuli/ballHallwayTextures/BallHallway_',options.sizePropArray(n),'_sameCheckNum_7degAlpha_Texture.png'));
                end
            end
        end
    else
        break
    end
    
    if saveSwitch == 1
        if checkSizeSwitch == 1
            % Save the calculated/measured values
            save('./measuredSizesAndPositions_sameCheckSize_7degAlpha','options')
        elseif checkSizeSwitch == 2
            % Save the calculated/measured values
            save('./measuredSizesAndPositions_sameCheckNum_7degAlpha','options')
        end
    end
    
end



ListenChar()
Screen('CloseAll');





