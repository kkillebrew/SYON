% Generate example stimuli for the binocular rivalry task - 20220815


curr_path = pwd;
options.save_path = sprintf('%s%s',curr_path,'\Figures');
match_folder_name = 'SYON.git';
path_idx = strfind(curr_path,match_folder_name);
sca
sca
options.root_path = curr_path(1:path_idx+length(match_folder_name)-1);
addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'/Bistable_Tasks/BinoRiv_Task/Behavioral_Task/Stim'));

options.displayInfo.linearClut = 0:1/255:1;
options.grayCol = [128 128 128];
options.fixCol = [0 0 0];
options.whiteCol = [255 255 255];
options.redCol = [255 0 0];
options.blueCol = [0 0 255];
options.greenCol = [0 255 0];
options.yellowCol = [255 215 0];

Screen('Preference', 'SkipSyncTests', 1);   % Skip sync test w/ monitor
    
% Screen info
numScreens = Screen('Screens');
if length(numScreens) == 3
    options.screenNum = 2;
elseif length(numScreens) == 2
    options.screenNum = 1;
end
options.wInfoOrig = Screen('Resolution',options.screenNum);
options.wInfoNew.hz = options.wInfoOrig.hz;
options.wInfoNew.width = options.wInfoOrig.width;
options.wInfoNew.height = options.wInfoOrig.height;
%     Screen('Resolution',options.screenNum,options.wInfoNew.width,options.wInfoNew.height,options.wInfoNew.hz);

% PPD varialbes
options.mon_width_cm = 28;   % Width of the monitor (cm)
options.mon_dist_cm = 57;   % Viewing distance (cm)
options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
options.PPD = (options.wInfoNew.width/options.mon_width_deg);   % pixels per degree

[options.windowNum,options.rect] = Screen('OpenWindow',options.screenNum,options.grayCol,...
        [0 0 options.wInfoNew.width options.wInfoNew.height],[],[],[],8);
options.xc = options.rect(3)/2;
options.yc = options.rect(4)/2;

%% Stim params
% Make fixation points
% Fixation variables
options.fix.fixSizeOuter = .6;  % In dova
options.fix.fixSizeInner = .2;
options.fix.fixRectX = options.fix.fixSizeOuter/2 * options.PPD;
options.fix.fixRectY = options.fix.fixSizeOuter/2 * options.PPD;
options.fix.fixCrossColor = options.whiteCol;
options.fix.fixInnerOvalColor = options.fixCol;
options.fix.fixOuterOvalColor = options.fixCol;
options.fix.fixColorBlink = options.fixCol;
options.blackFixation = do_fixation(options);
options.fixationRect = [options.xc - options.fix.fixSizeOuter/2*options.PPD,...
    options.yc - options.fix.fixSizeOuter/2*options.PPD,...
    options.xc + options.fix.fixSizeOuter/2*options.PPD,...
    options.yc + options.fix.fixSizeOuter/2*options.PPD];
options.blinkFixation = do_fixation_blink(options);

% general values
options.sp.gratPhase = 2*pi*rand(1, 2);   % Determine a random phase
options.sp.gratSize = 3*options.PPD;   % DoVA
[options.sp.xx, options.sp.yy] = meshgrid(-options.sp.gratSize:options.sp.gratSize, -options.sp.gratSize:options.sp.gratSize);
[options.sp.theta, options.sp.rr] = cart2pol(options.sp.xx, options.sp.yy);
options.sp.backGroundLum = 127.5;   % Color of background - single value
options.sp.meanLuminance = 127.5;   % Mean color of the grating
% options.sp.backGroundLum = options.grayCol(1);   % Color of background - single value
% options.sp.meanLuminance = options.grayCol(1);   % Mean color of the grating
options.sp.eyeAdjust = 0;

% Generate gratings for left and right eye
options = genLeftRightGrating(options);

% Make the combined grating
options.sp.both.gratingAnn = options.sp.right.gratingAnn+options.sp.left.gratingAnn;
% Cut off the inner and outer portions of the annulus
options.sp.both.gratingAnn(options.sp.left.rr<options.sp.left.eccentricity(1) | options.sp.left.rr>options.sp.left.eccentricity(2)) = options.sp.backGroundLum;
options.sp.both.center = [round(size(options.sp.left.gratingAnn,1)/2), round(size(options.sp.both.gratingAnn,2)/2)];
% options.sp.both.gratingAnn((options.sp.both.center(1)-1:options.sp.both.center(1)+1),(options.sp.both.center(2)-1:options.sp.both.center(2)+1)) = 0;
% options.sp.both.gratingAnn((options.sp.both.center(1) - 10):(options.sp.both.center(1) + 10), (options.sp.both.center(2)-1):(options.sp.both.center(2)+1)) = 0;
% options.sp.both.gratingAnn((options.sp.both.center(1)-1):(options.sp.both.center(1)+1), (options.sp.both.center(2) - 10):(options.sp.both.center(2) + 10)) = 0;

% Convert color of grating to updated display options
for i=1:size(options.sp.left.gratingAnn,1)
    for j=1:size(options.sp.left.gratingAnn,2)
        for k=1:size(options.sp.left.gratingAnn,3)
            options.sp.left.gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.left.gratingAnn(i,j,k)+1))*255;
            options.sp.right.gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.right.gratingAnn(i,j,k)+1))*255;
            options.sp.both.gratingAnn(i,j,k) = options.displayInfo.linearClut(round(options.sp.both.gratingAnn(i,j,k)+1))*255;
        end
    end
end

% Make grating rects
options.sp.left.gratingAnnRect = CenterRect(([-1 -1 1 1] * max(options.sp.left.eccentricity)),options.rect);
options.sp.right.gratingAnnRect = CenterRect(([-1 -1 1 1] * max(options.sp.right.eccentricity)),options.rect);
options.sp.both.gratingAnnRect = options.sp.left.gratingAnnRect;

% Make grating texture
options.sp.left.gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.left.gratingAnn);
options.sp.right.gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.right.gratingAnn);
options.sp.both.gratingAnnTexture = Screen('MakeTexture',options.windowNum,options.sp.both.gratingAnn);

% Generate frame
options = genFrame(options);

% Make frame texture
options.sp.frame.frameTexture = Screen('MakeTexture', options.windowNum, options.sp.frame.frame);

%% Draw images
%% Right grating
% Draw
Screen('DrawTexture',options.windowNum,...
    options.sp.right.gratingAnnTexture,...
    [],options.sp.right.gratingAnnRect);
Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
Screen('Flip',options.windowNum);
WaitSecs(.5);

% Screen cap
output.rightGratingIm = Screen('GetImage',options.windowNum,[options.sp.right.gratingAnnRect]);
WaitSecs(.5);

% Save image
imwrite(output.rightGratingIm,sprintf('%s%s',options.save_path,'\rightGrating.png'));

%% Left grating
% Draw
Screen('DrawTexture',options.windowNum,...
    options.sp.left.gratingAnnTexture,...
    [],options.sp.left.gratingAnnRect);
Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
Screen('Flip',options.windowNum);
WaitSecs(.5);

% Screen cap
output.rightGratingIm = Screen('GetImage',options.windowNum,[options.sp.left.gratingAnnRect]);
WaitSecs(.5);

% Save image
imwrite(output.rightGratingIm,sprintf('%s%s',options.save_path,'\leftGrating.png'));

%% Combined grating
% Draw
Screen('DrawTexture',options.windowNum,...
    options.sp.both.gratingAnnTexture,...
    [],options.sp.both.gratingAnnRect);
Screen('DrawTexture',options.windowNum,options.blackFixation,[],options.fixationRect);   % present fixation
Screen('Flip',options.windowNum);
WaitSecs(.5);

% Screen cap
output.rightGratingIm = Screen('GetImage',options.windowNum,[options.sp.both.gratingAnnRect]);
WaitSecs(.5);

% Save image
imwrite(output.rightGratingIm,sprintf('%s%s',options.save_path,'\bothGrating.png'));


Screen('CloseAll');









