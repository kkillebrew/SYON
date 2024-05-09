
options.screenShotSwitch = 1;

% Gray color
options.grayCol = [128 128 128];

% PPD
options.PPD = 50;

if options.screenShotSwitch == 1
    % For screen shot
    imCounter = 0;
end

% Size variables
options.stim.circDia = 1.5;   % Diameter of the circle
options.stim.circDist = 4.5;   % Distance between the center points of each circle
options.stim.circBarGap = .25;   % Distance between the contour rect and inducer
options.checkerboard.checkSize = .5;   % Size of checks
options.stim.contourLength = options.PPD*(options.stim.circDist-((options.stim.circBarGap*2)+options.stim.circDia));   % Length of contour stim
options.stim.contourWidth = options.PPD*1;   % Width of contour stim

% Make the checkerboard stimuli
% Center of the circle in the texture
options.checkerboard.xc = round((options.stim.circDia/2)*options.PPD);   
options.checkerboard.yc = round((options.stim.circDia/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.circDia)*options.PPD);
options.checkerboard.yDim = round((options.stim.circDia)*options.PPD);
options.checkerboard.radius = round((options.stim.circDia/2)*options.PPD);

% Make the textures
% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.circMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.circMask = options.checkerboard.circMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.radius;

% Open window and set some variables to draw for demo
[options.windowNum,options.rect] = Screen('OpenWindow',1,[128 128 128]);
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;

% UL Texture
options.checkerboard.ULMask = options.checkerboard.circMask;
options.checkerboard.ULMask(options.checkerboard.xc:options.checkerboard.xDim,...
    options.checkerboard.yc:options.checkerboard.yDim) = 0;
options.checkerboard.maskHolder = options.checkerboard.ULMask;   
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.ULTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.ULTexArray{i}(options.checkerboard.ULMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.ULTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.ULTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% UR Texture
options.checkerboard.URMask = options.checkerboard.circMask;
options.checkerboard.URMask(options.checkerboard.xc:options.checkerboard.xDim,...
    1:options.checkerboard.yc) = 0;
options.checkerboard.maskHolder = options.checkerboard.URMask;   
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.URTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.URTexArray{i}(options.checkerboard.URMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.URTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.URTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% LL Texture
options.checkerboard.LLMask = options.checkerboard.circMask;
options.checkerboard.LLMask(1:options.checkerboard.xc,...
    options.checkerboard.yc:options.checkerboard.yDim) = 0;
options.checkerboard.maskHolder = options.checkerboard.LLMask;   
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.LLTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.LLTexArray{i}(options.checkerboard.LLMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.LLTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.LLTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% LR Texture
options.checkerboard.LRMask = options.checkerboard.circMask;
options.checkerboard.LRMask(1:options.checkerboard.xc,...
    1:options.checkerboard.yc) = 0;
options.checkerboard.maskHolder = options.checkerboard.LRMask;   
options = createCheckerboard(options); %   Combine checkerboard and mask
options.checkerboard.LRTexArray = options.checkerboard.texArrayHolder;   % Turn the array into a texture to plot
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.LRTexArray{i}(options.checkerboard.LRMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.LRTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.LRTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Position of each of the 4 inducers
options.stim.circPositionArray(1,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(2,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(3,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)-(( options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)-((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)];
options.stim.circPositionArray(4,:) = [options.xc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc-ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.xc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)...
    options.yc+ceil((options.stim.circDia*options.PPD)/2)+((options.stim.circDist/2)*options.PPD)];

% Contour variables
% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = options.stim.contourLength;
options.checkerboard.yDim = options.stim.contourLength;

% Contour texture
options.checkerboard.contourMask = ones([options.stim.contourLength options.stim.contourLength]);
options.checkerboard.contourMask(:,1:round(options.stim.contourLength/2)-round(options.stim.contourWidth/2)) = 0;
options.checkerboard.contourMask(:,round(options.stim.contourLength/2)+round(options.stim.contourWidth/2):options.stim.contourLength) = 0;
options.checkerboard.maskHolder = options.checkerboard.contourMask;
options = createCheckerboard(options);
options.checkerboard.contourTexArray = options.checkerboard.texArrayHolder;
for i=1:2   % For both phases of the checkerboard
    options.checkerboard.contourTexArray{i}(options.checkerboard.contourMask==0) = options.grayCol(1);   % Make background gray
    options.checkerboard.contourTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.contourTexArray{i});
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Contour coords
% Upper
options.stim.contourPositionArray(1,:) = [options.stim.circPositionArray(1,1)+((options.stim.circDia+options.stim.circBarGap)*options.PPD),...
    (options.stim.circPositionArray(1,2)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.stim.circPositionArray(2,1)-(options.stim.circBarGap*options.PPD),...
    (options.stim.circPositionArray(1,2)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD)];   
% Right
options.stim.contourPositionArray(2,:) = [(options.stim.circPositionArray(2,1)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc-floor(options.stim.contourLength/2),...
    (options.stim.circPositionArray(2,1)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc+floor(options.stim.contourLength/2)];
% Lower
options.stim.contourPositionArray(3,:) = [options.stim.circPositionArray(1,1)+((options.stim.circDia+options.stim.circBarGap)*options.PPD),...
    (options.stim.circPositionArray(3,2)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.stim.circPositionArray(2,1)-(options.stim.circBarGap*options.PPD),...
    (options.stim.circPositionArray(3,2)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD)];   
% Left
options.stim.contourPositionArray(4,:) = [(options.stim.circPositionArray(1,1)+(round(options.stim.circDia/2)*options.PPD))-floor(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc-floor(options.stim.contourLength/2),...
    (options.stim.circPositionArray(1,1)+(round(options.stim.circDia/2)*options.PPD))+ceil(options.stim.contourLength/2)-(options.stim.circBarGap*options.PPD),...
    options.yc+floor(options.stim.contourLength/2)];

% Draw the stim (for demo)
if options.screenShotSwitch==1
    imageFlip = 1;
end

for i=1:2
    
%     Screen('DrawTexture',options.windowNum,options.checkerboard.ULTex{i},[],options.stim.circPositionArray(1,:))
%     Screen('DrawTexture',options.windowNum,options.checkerboard.URTex{i},[],options.stim.circPositionArray(2,:))
%     Screen('DrawTexture',options.windowNum,options.checkerboard.LLTex{i},[],options.stim.circPositionArray(3,:))
%     Screen('DrawTexture',options.windowNum,options.checkerboard.LRTex{i},[],options.stim.circPositionArray(4,:))
    
    Screen('DrawTexture',options.windowNum,options.checkerboard.contourTex{i},[],options.stim.contourPositionArray(1,:),90)
    Screen('DrawTexture',options.windowNum,options.checkerboard.contourTex{i},[],options.stim.contourPositionArray(2,:))
    Screen('DrawTexture',options.windowNum,options.checkerboard.contourTex{i},[],options.stim.contourPositionArray(3,:),90)
    Screen('DrawTexture',options.windowNum,options.checkerboard.contourTex{i},[],options.stim.contourPositionArray(4,:))
    
    Screen('Flip',options.windowNum);
    
    % For taking screen shots
    if options.screenShotSwitch == 1
        imCounter = imCounter + 1;
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
        % imwrite is a Matlab function, not a PTB-3 function
        eval(sprintf('%s%d%s','imwrite(imageArray,''IllContMRStim_Contours',imCounter,'.jpg'')'))
    end
    
    KbWait;
    
end

Screen('CloseAll')



