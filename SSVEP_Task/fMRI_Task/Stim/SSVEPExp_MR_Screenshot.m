
clear all; close all;

options.screenShotSwitch = 0;

% Gray color
options.grayCol = [128 128 128];
options.whiteCol = [255 255 255];

% PPD
options.PPD = 50;

if options.screenShotSwitch == 1
    % For screen shot
    imCounter = 0;
end

%% Stim variables
% From MPS SSVEP stim gen code
% y_ecc_upper = 1.7101; % this is upper
% x_ecc_upper = 4.6985;
%
% y_ecc_lower = 3.5355; % lower
% x_ecc_lower = 3.5355;
%
% diag_ecc_upper = sqrt(x_ecc_upper^2+y_ecc_upper^2);
% diag_ecc_lower = sqrt(x_ecc_lower^2+y_ecc_lower^2);
%
% diskRadius = 1.0; % degrees
% surroundRadius = 8;
% blurr_SD = 0.05;
%
% circleRadius = diskRadius + 1/16; % degrees, size of the circle to reduce uncertainty, similar to Petrov 2009
% circleCon = .15; % 1% contrast
% circleWidth = .04; % 1.2 arcmin wide, about 2 pixel

% Size variables
options.stim.centCircDia = 1;   % Diameter of the center circs
options.stim.centCircTexSize = options.stim.centCircDia*2;   % Size of the texture
options.stim.surrCircDia = 8;   % Diameter of the surround circ
options.stim.surrCircTexSize = options.stim.surrCircDia*2;   % Size of the texture
options.stim.circDistY1 = 1.7101;   % Distance between top circles and screen center in x
options.stim.circDistX1 = 4.6985;   % Distance between top circles and screen center in y
options.stim.circDistY2 = 3.5355;   % Distance between bottomw circles and screen center in x
options.stim.circDistX2 = 3.5355;   % Distance betwegien top/bottom circles and screen center in y
options.stim.gap = options.stim.centCircDia/16;   % Distance between the center / surround stim
options.stim.blurSD = 0.05;   % SD of the gaussian
options.checkerboard.checkSize = .5;   % Size of checks

% Open window and set some variables to draw for demo
[options.windowNum,options.rect] = Screen('OpenWindow',1,[128 128 128]);
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', options.windowNum, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% Make the center textures
% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.centCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.centCircTexSize/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.centCircTexSize)*options.PPD);
options.checkerboard.yDim = round((options.stim.centCircTexSize)*options.PPD);
options.checkerboard.centRadius = round((options.stim.centCircDia/2)*options.PPD);

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.centCircMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.centCircMask = options.checkerboard.centCircMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.centRadius;

% Center circles checkerboard texture
options.checkerboard.maskHolder = options.checkerboard.centCircMask;
options.checkerboard.gaussFilt = fspecial('gaussian',length(options.checkerboard.maskHolder)+1,options.stim.blurSD*options.PPD);   % Create the gaussian portion of the mask
options.checkerboard.maskHolder = conv2(options.checkerboard.maskHolder,options.checkerboard.gaussFilt,'same');
% options.checkerboard.maskHolder(options.checkerboard.maskHolder<=.1) = 0;
options = createCheckerboard(options); %   Combine checkerboard and mask
for i=1:2   % For both phases of the checkerboard
    cirTexHolder(:,:,1) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,2) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,3) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,4) = (options.checkerboard.maskHolder*options.whiteCol(1));
    options.checkerboard.centCircTexArray{i} = cirTexHolder;   % Make background transparent
    
    options.checkerboard.centCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.centCircTexArray{i});
    
    clear cirTexHolder
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder','gaussFilt'});   % Clear holders

% Coord points of the center circles
% Upper left
options.stim.centCircPositionArray(1,:) = [(options.xc-((options.stim.circDistX1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc-((options.stim.circDistX1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Upper right
options.stim.centCircPositionArray(2,:) = [(options.xc+((options.stim.circDistX1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc+((options.stim.circDistX1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc-((options.stim.circDistY1/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Lower right
options.stim.centCircPositionArray(3,:) = [(options.xc-((options.stim.circDistX2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc-((options.stim.circDistX2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];
% Lower left
options.stim.centCircPositionArray(4,:) = [(options.xc+((options.stim.circDistX2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))-((options.stim.centCircTexSize/2)*options.PPD)...
    (options.xc+((options.stim.circDistX2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)...
    (options.yc+((options.stim.circDistY2/2)*options.PPD))+((options.stim.centCircTexSize/2)*options.PPD)];

%% Make the surround texture
% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.surrCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.surrCircTexSize/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.surrCircTexSize)*options.PPD);   % MUST NAME THIS xDim OR FUNC WILL NOT RECOGNIZE
options.checkerboard.yDim = round((options.stim.surrCircTexSize)*options.PPD);
options.checkerboard.surrRadius = round((options.stim.surrCircDia/2)*options.PPD);

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.surrCircMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.surrCircMask = options.checkerboard.surrCircMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.surrRadius;

for i=1:4
    % Make a new holder mask
    surrCircMaskHolder = zeros(length(options.checkerboard.surrCircMask));
    
    % CHANGE THIS TO MAKE IT THE CENTER OF THE CIRCLES IN THE SURR CIRCLES
    % SPACE
    if i==1
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)-((options.stim.circDistX1/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)-((options.stim.circDistY1/2)*options.PPD);
    elseif i==2
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)+((options.stim.circDistX1/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)-((options.stim.circDistY1/2)*options.PPD);
    elseif i==3
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)+((options.stim.circDistX2/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)+((options.stim.circDistY2/2)*options.PPD);
    elseif i==4
        options.checkerboard.xc = ((options.checkerboard.xDim)/2)-((options.stim.circDistX2/2)*options.PPD);
        options.checkerboard.yc = ((options.checkerboard.yDim)/2)+((options.stim.circDistY2/2)*options.PPD);
    end
   
    % Add in to the surr texture
    surrCircMaskHolder = ~(surrCircMaskHolder | hypot(xx - options.checkerboard.xc,...
        yy - options.checkerboard.yc) <= options.checkerboard.centRadius);
    
    options.checkerboard.surrCircMask = options.checkerboard.surrCircMask.*surrCircMaskHolder;
    
    clear surrCircMaskHolder
end

% Center circles checkerboard texture
options.checkerboard.maskHolder = options.checkerboard.surrCircMask;
options.checkerboard.gaussFilt = fspecial('gaussian',length(options.checkerboard.maskHolder)+1,options.stim.blurSD*options.PPD);   % Create the gaussian portion of the mask
options.checkerboard.maskHolder = conv2(options.checkerboard.maskHolder,options.checkerboard.gaussFilt,'same');
options = createCheckerboard(options); %   Combine checkerboard and mask
for i=1:2   % For both phases of the checkerboard
    
    cirTexHolder(:,:,1) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,2) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,3) = ((options.checkerboard.texArrayHolder{i}));
    cirTexHolder(:,:,4) = (options.checkerboard.maskHolder*options.whiteCol(1));
    options.checkerboard.surrCircTexArray{i} = cirTexHolder;   % Make background transparent
    
    options.checkerboard.surrCircTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.surrCircTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Reset center points
options.checkerboard.xc = round((options.stim.surrCircTexSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.surrCircTexSize/2)*options.PPD);

% Coord points of the surr circles
% Upper left
options.stim.surrCircPositionArray(1,:) = [options.xc-((options.stim.surrCircTexSize/2)*options.PPD)...
    options.yc-((options.stim.surrCircTexSize/2)*options.PPD)...
    options.xc+((options.stim.surrCircTexSize/2)*options.PPD)...
    options.yc+((options.stim.surrCircTexSize/2)*options.PPD)];

% Draw the stim (for demo)
if options.screenShotSwitch==1
    imageFlip = 1;
end

%% Draw
for i=1:2
    
    % Draw the surround circle
    Screen('DrawTexture',options.windowNum,options.checkerboard.surrCircTex{i},[],options.stim.surrCircPositionArray(1,:));
    
%     % Draw small gray circles that will create a bap between center and
%     % surround
%     Screen('FillOval',options.windowNum,options.grayCol,[options.stim.centCircPositionArray(1,1)-((options.stim.gap))*options.PPD...
%         options.stim.centCircPositionArray(1,2)-((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(1,3)+((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(1,4)+((options.stim.gap)/2)*options.PPD]);
%     Screen('FillOval',options.windowNum,options.grayCol,[options.stim.centCircPositionArray(2,1)-((options.stim.gap))*options.PPD...
%         options.stim.centCircPositionArray(2,2)-((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(2,3)+((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(2,4)+((options.stim.gap)/2)*options.PPD]);
%     Screen('FillOval',options.windowNum,options.grayCol,[options.stim.centCircPositionArray(3,1)-((options.stim.gap))*options.PPD...
%         options.stim.centCircPositionArray(3,2)-((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(3,3)+((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(3,4)+((options.stim.gap)/2)*options.PPD]);
%     Screen('FillOval',options.windowNum,options.grayCol,[options.stim.centCircPositionArray(4,1)-((options.stim.gap))*options.PPD...
%         options.stim.centCircPositionArray(4,2)-((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(4,3)+((options.stim.gap)/2)*options.PPD...
%         options.stim.centCircPositionArray(4,4)+((options.stim.gap)/2)*options.PPD]);
     
    % Draw the center circles
    Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{i},[],options.stim.centCircPositionArray(1,:));
    Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{i},[],options.stim.centCircPositionArray(2,:));
    Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{i},[],options.stim.centCircPositionArray(3,:));
    Screen('DrawTexture',options.windowNum,options.checkerboard.centCircTex{i},[],options.stim.centCircPositionArray(4,:));
     
    Screen('Flip',options.windowNum);
    
    % For taking screen shots
    if options.screenShotSwitch == 1
        imCounter = imCounter + 1;
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
        % imwrite is a Matlab function, not a PTB-3 function
        eval(sprintf('%s%d%s','imwrite(imageArray,''SSVEPMRStim',imCounter,'.jpg'')'))
    end
    
    KbWait;
    
end

Screen('CloseAll');





