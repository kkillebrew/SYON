% Calculate the angle and size of the balls relative to the camera and the
% center point, between the two balls in x,y, at which the camera is
% pointing. 
%
% KWK - 20200304

clear all; close all;

%% Constant Values (manually set)
% Determine DoVA
% PPD varialbes
options.mon_width_cm = 53;   % Width of the monitor (cm)
options.mon_dist_cm = 57;   % Viewing distance (cm)
options.mon_width_deg = 2 * (180/pi) * atan((options.mon_width_cm/2)/options.mon_dist_cm);   % Monitor width in DoVA
options.PPD = (1920/options.mon_width_deg);   % pixels per degree

imageDeg = 18;   % Total size of the image, based on Murray

imageSizeX = (options.PPD*imageDeg)*2;   % Must multiply by 2, b/c blender divides input rez by 2 for w/e reason...
imageSizeY = (options.PPD*imageDeg)*2;

isTilted = 0;   % Is the floor/walls tilted upwards?

if isTilted == 1
    floorTilt = 5;   % Tilt of floor in degrees
end

% Angle between camera and ball center and ball edge for 1 and 2 (should be
% the same if retinal size is the same).
% alpha1 = 13.797;   % Degrees of 2x width2
% alpha1 = 7;   % Degrees of 1x width2
% alpha1 = 3.513;   % Degrewes of 1/2x width2
alpha1Initial = 7; % Calculate alhpa1 for 7 degrees (same as alpha2) (used to calculate an initial width1)
alpha2 = 7;

% Angle between center points of balls and midpoint
beta1 = 20;
beta2 = -20;

% Distance between center of balls to camera, for 1 and 2.
% cDistance1 = width1/tand(alpha1);
% cDistance2 = width2/tand(alpha2);
cDistance1 = 2;
cDistance2 = 8;

% Values for far sphere are held constant (unchanging relative to close sphere)
width2 = 2*(tand(alpha2)*cDistance2);
cDistance2x = cDistance2*cosd(beta2);
cDistance2y = cDistance2*sind(beta2);
cDistance2xBlend = cDistance2x;   % In blender coords
cDistance2yBlend = cDistance2y;
% z coords of balls
if isTilted == 0
    cDistance2zBlend = width2/2;
elseif isTilted == 1
    cDistance2zBlend = (width2/2)+(tand(floorTilt)*cDistance2xBlend);
end

% Deteremine a list of proportions of sizes (widths) of far sphere
% options.sizePropArray = [.75:.025:.9 .91:.01:.99 1 1.01:.01:1.09 1.1:0.025:1.25];
width1Initial = 2*(tand(alpha1Initial)*cDistance1);
% options.sizePropArray = [.50 1.50];
options.sizePropArray = [.5:.05:.80 .825:.025:.975 .99 1.01 1 1.025:.025:1.2 1.25:.05:1.5];

%% Calculated Values 
% Calculate values for you range of sizes for close sphere
cd ./ballHallwayTextures/   % CD into the correct folder
for n=1:length(options.sizePropArray)
    % Find alpha1s that result in widths == proportion of the width of a set alpha2 (width2)
    alpha1 = atand((width1Initial*(options.sizePropArray(n)))/(2*cDistance1));
    
    % Size of each of the balls (spheres, same x,y,z)
    width1 = 2*(tand(alpha1)*cDistance1);   % In units for now
    
    % x/y coords of balls
    cDistance1x = cDistance1*cosd(beta1);
    cDistance1y = cDistance1*sind(beta1);
    cDistance1xBlend = cDistance1x;   % In blender coords
    cDistance1yBlend = cDistance1y;
    
    % z coords of balls
    if isTilted == 0
        cDistance1zBlend = width1/2;
    elseif isTilted == 1
        cDistance1zBlend = (width1/2)+(tand(floorTilt)*cDistance1xBlend);
    end
    
    % Camera position
    % cameraZ = mean([width1/2 width2/2]);
    % cameraZ = mean([cDistance1zBlend cDistance2zBlend]);
    cameraZ = .8;
    
    % Lamp position: Hemi type; energy: 1 (whatever that means..)
    % lampx = ;   %
    
    %% Floor x,y,z size
    wallSize1x = (2*cDistance2xBlend)+width2;
    wallSize1y = (abs(cDistance1yBlend)+width1*2)+(abs(cDistance2yBlend)+width2);
    wallSize1z = .1;
    
    % Floor y,z location
    wallLoc1x = 0;
    wallLoc1y = mean([cDistance1yBlend+width1*2 cDistance2yBlend-width2]);
    wallLoc1z = -wallSize1z/2;
    
    %% Back wall x,y,z size
    wallSize2x = .1;
    wallSize2y = wallSize1y;
    wallSize2z = width2*2;   % 5x the size of the large ball
    
    % Back wall x,y,z location
    wallLoc2x = (((2*cDistance2xBlend)+width2)/2);
    wallLoc2y = wallLoc1y;
    wallLoc2z = wallSize2z/2;   % 5x the size of the large ball
    
    %% Left wall x,y,z size
    wallSize3x = (2*cDistance2xBlend)+width2;   % Same as floor size x
    wallSize3y = .1;
    wallSize3z = width2*2;   % Same as back wall height
    
    % Left wall x,y,z location
    wallLoc3x = 0;
    wallLoc3y = (abs(cDistance1yBlend)+width1*2);
    wallLoc3z = wallSize3z/2;
    
    %% Right wall x,y,z size
    wallSize4x = (2*cDistance2xBlend)+width2;   % Same as floor size x
    wallSize4y = .1;
    wallSize4z = width2*2;   % Same as back wall height
    
    % Right wall x,y,z location
    wallLoc4x = 0;
    wallLoc4y = -(abs(cDistance2yBlend)+width2);
    wallLoc4z = wallSize4z/2;
    
    %% Output values
    % Make an easy to use table
    hallwayCoords.ballCoords = table(cDistance1xBlend,cDistance1yBlend,cDistance1zBlend,width1,cDistance2xBlend,cDistance2yBlend,cDistance2zBlend,width2,cameraZ);
    hallwayCoords.ballCoords.Properties.VariableNames = {'X1','Y1','Z1','Size1','X2','Y2','Z2','Size2','CameraZ'};
    
    hallwayCoords.floor = table(wallLoc1x,wallLoc1y,wallLoc1z,wallSize1x,wallSize1y,wallSize1z);
    hallwayCoords.floor.Properties.VariableNames = {'FloorLocX','FloorLocY','FloorLocZ','FloorSizeX','FloorSizeY','FloorSizeZ'};
    
    hallwayCoords.back = table(wallLoc2x,wallLoc2y,wallLoc2z,wallSize2x,wallSize2y,wallSize2z);
    hallwayCoords.back.Properties.VariableNames = {'BackLocX','BackLocY','BackLocZ','BackSizeX','BackSizeY','BackSizeZ'};
    
    hallwayCoords.left = table(wallLoc3x,wallLoc3y,wallLoc3z,wallSize3x,wallSize3y,wallSize3z);
    hallwayCoords.left.Properties.VariableNames = {'LeftLocX','LeftLocY','LeftLocZ','LeftSizeX','LeftSizeY','LeftSizeZ'};
    
    hallwayCoords.right = table(wallLoc4x,wallLoc4y,wallLoc4z,wallSize4x,wallSize4y,wallSize4z);
    hallwayCoords.right.Properties.VariableNames = {'RightLocX','RightLocY','RightLocZ','RightvSizeX','RightSizeY','RightSizeZ'};
    
    % Store ther constant values
    hallwayCoords.constant = table(alpha1,alpha2,beta1,beta2,imageDeg,cDistance1,cDistance2);
    hallwayCoords.constant.Properties.VariableNames = {'Alpha1','Alpha2','Beta1','Beta2','ImageSize_Degs','Distance1','Distance2'};

    
%     % Display tables
%     disp(hallwayCoords.ballCoords)
%     disp(hallwayCoords.floor)
%     disp(hallwayCoords.back)
%     disp(hallwayCoords.left)
%     disp(hallwayCoords.right)
    
    % Save the values labled with sizes in alpha angles for both balls
    save(sprintf('%s%.3f%s%.2f%s%.2f%s','BallHallway_',options.sizePropArray(n),'_',round(alpha1,2),'_',round(alpha2,2),'.mat'),'hallwayCoords')
    
end

cd ../


