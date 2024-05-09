

function [] = GamOscExp_MR()


%% Initialize 
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


%% Trial variables 
% options.varlist = ;


%% Stim variables
% Size variables
options.stim.initSize = 5;   % Diameter in DoVA
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
options.checkerboard.xc = round((options.stim.initSize/2)*options.PPD);
options.checkerboard.yc = round((options.stim.initSize/2)*options.PPD);

% Dimension of the circle (total size of the texture)
options.checkerboard.xDim = round((options.stim.initSize)*options.PPD);
options.checkerboard.yDim = round((options.stim.initSize)*options.PPD);
options.checkerboard.centRadius = round((options.stim.initSize/2)*options.PPD);

% Blank circle mask
[xx,yy] = meshgrid(1:options.checkerboard.yDim,1:options.checkerboard.xDim);
options.checkerboard.circMask = false(options.checkerboard.xDim,options.checkerboard.yDim);
options.checkerboard.circMask = options.checkerboard.circMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.centRadius;

% Center circles checkerboard texture
options.checkerboard.maskHolder = options.checkerboard.circMask;
options = createCheckerboard(options); %   Combine checkerboard and mask
for i=1:2   % For both phases of the checkerboard
    cirTexHolder(:,:,1) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,2) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,3) = (options.checkerboard.texArrayHolder{i});
    cirTexHolder(:,:,4) = options.checkerboard.maskHolder.*options.whiteCol(1);
    options.checkerboard.circTexArray{i} = cirTexHolder;   % Make background transparent
    
    options.checkerboard.circTex{i} = Screen('MakeTexture',options.windowNum,options.checkerboard.circTexArray{i});
    
    clear cirTexHolder
end
options.checkerboard = rmfield(options.checkerboard,{'maskHolder','texArrayHolder'});   % Clear holders

% Coord points of the circle
options.checkerboard.circPositionArray(1,:) = [options.xc-(round((options.stim.initSize/2)*options.PPD))...
    options.yc-(round((options.stim.initSize/2)*options.PPD))...
    options.xc+(round((options.stim.initSize/2)*options.PPD))...
    options.yc+(round((options.stim.initSize/2)*options.PPD))];


%% Draw

% Draw the stim (for demo)
if options.screenShotSwitch==1
    imageFlip = 1;
end

for i=1:2
    
    Screen('DrawTexture',options.windowNum,options.checkerboard.circTex{i},[],options.checkerboard.circPositionArray(1,:));
    Screen('Flip',options.windowNum);
    
    % For taking screen shots
    if options.screenShotSwitch == 1
        imCounter = imCounter + 1;
        % GetImage call. Alter the rect argument to change the location of the screen shot
        imageArray = Screen('GetImage', options.windowNum,[options.xc-options.rect(4)/2 0 options.xc+options.rect(4)/2 options.rect(4)]);
        % imwrite is a Matlab function, not a PTB-3 function
        eval(sprintf('%s%d%s','imwrite(imageArray,''GamOscMRStim',imCounter,'.jpg'')'))
    end
    
    KbWait;
    
end

Screen('CloseAll'); 


