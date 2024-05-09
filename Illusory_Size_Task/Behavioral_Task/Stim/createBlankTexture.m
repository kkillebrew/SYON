% Create a blank texture to replace the hallway texture for ball in hallway stim.
%
% KWK 20200326

function [options] = createBlankTexture(options,exampleImageDir)
    % First load in an actual hallway stimto mimic the the actual size of the image
    cd ./Ball_In_Hallway_Stimuli/ballHallwayTextures/
    exampleImage = imread(exampleImageDir);

    exampleImageSize = size(exampleImage);

    exampleImageArray = zeros([exampleImageSize])+.5;
    
    options.blankTexDir = './ballHallway_Blank.png';

    imwrite(exampleImageArray,options.blankTexDir)

    cd ../../
end