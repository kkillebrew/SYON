% Function to create the two checkerboard textures used in ball in hallway stimuli.
%
% KWK - 20200325

function [optionsHolder] = createCheckerboardTextures(optionsHolder,checkSizeSwitch,n)

if checkSizeSwitch == 1   % Maintain constant check size regardless of sphere size
    for i=1:2

        % Re-store screen vals
        optionsHolder2.PPD = optionsHolder.PPD;
        optionsHolder2.displayInfo.linearClut = optionsHolder.displayInfo.linearClut;
        optionsHolder2.whiteCol = optionsHolder.whiteCol;
        
        % Number of checks/degree
        optionsHolder2.checkerboard.numChecksPerDeg = 4;   % Frequency
        
        % Number of checks
        if i==1
            optionsHolder2.checkerboard.numChecks = optionsHolder2.checkerboard.numChecksPerDeg*optionsHolder.circ1SizeDeg(n);   % Number of checks in each texture based on size and freq
        elseif i==2
            optionsHolder2.checkerboard.numChecks = optionsHolder2.checkerboard.numChecksPerDeg*optionsHolder.circ2SizeDeg(n);
        end
        
        % Size of checks in degrees
        optionsHolder2.checkerboard.checkSize = (optionsHolder.PPD/optionsHolder2.checkerboard.numChecksPerDeg)/optionsHolder.PPD;
        
        % Size of checkerboard
        optionsHolder2.checkerboard.xDim = ceil((optionsHolder2.checkerboard.checkSize*optionsHolder2.checkerboard.numChecks)*optionsHolder.PPD);
        optionsHolder2.checkerboard.yDim = ceil((optionsHolder2.checkerboard.checkSize*optionsHolder2.checkerboard.numChecks)*optionsHolder.PPD);
        optionsHolder2.checkerboard.xDeg = optionsHolder2.checkerboard.xDim/optionsHolder.PPD;
        optionsHolder2.checkerboard.yDeg = optionsHolder2.checkerboard.yDim/optionsHolder.PPD;
        
        % Center of the texture
        optionsHolder2.checkerboard.xc = ceil((optionsHolder2.checkerboard.xDeg/2)*optionsHolder.PPD);
        optionsHolder2.checkerboard.yc = ceil((optionsHolder2.checkerboard.yDeg/2)*optionsHolder.PPD);
        
        % Generate
        optionsHolder2 = createShadedGradient(optionsHolder2);
        
        optionsHolder.checkerboard(n,i) = optionsHolder2.checkerboard;
        
        clear optionsHolder2
        
    end
elseif checkSizeSwitch == 2   % Maintain constant number of checks regardless of sphere size
    for i=1:2
       
        % Re-store screen vals
        optionsHolder2.PPD = optionsHolder.PPD;
        optionsHolder2.displayInfo.linearClut = optionsHolder.displayInfo.linearClut;
        optionsHolder2.whiteCol = optionsHolder.whiteCol;
        
        % Number of checks
        optionsHolder2.checkerboard.numChecks = 9;   % Number of checks in each texture based on size and freq
        
        % Number of checks/degree 
        if i==1
            optionsHolder2.checkerboard.numChecksPerDeg = optionsHolder2.checkerboard.numChecks/optionsHolder.circ1SizeDeg(n);   % Frequency
        elseif i==2
            optionsHolder2.checkerboard.numChecksPerDeg = optionsHolder2.checkerboard.numChecks/optionsHolder.circ2SizeDeg(n);   % Frequency
        end
        
        % Size of checks in degrees
        optionsHolder2.checkerboard.checkSize = (optionsHolder.PPD/optionsHolder2.checkerboard.numChecksPerDeg)/optionsHolder.PPD;
        
        % Size of checkerboard
        optionsHolder2.checkerboard.xDim = ceil((optionsHolder2.checkerboard.checkSize*optionsHolder2.checkerboard.numChecks)*optionsHolder.PPD);
        optionsHolder2.checkerboard.yDim = ceil((optionsHolder2.checkerboard.checkSize*optionsHolder2.checkerboard.numChecks)*optionsHolder.PPD);
        optionsHolder2.checkerboard.xDeg = optionsHolder2.checkerboard.xDim/optionsHolder.PPD;
        optionsHolder2.checkerboard.yDeg = optionsHolder2.checkerboard.yDim/optionsHolder.PPD;
        
        % Center of the texture
        optionsHolder2.checkerboard.xc = ceil((optionsHolder2.checkerboard.xDeg/2)*optionsHolder.PPD);
        optionsHolder2.checkerboard.yc = ceil((optionsHolder2.checkerboard.yDeg/2)*optionsHolder.PPD);
        
        % Generate
        optionsHolder2 = createShadedGradient(optionsHolder2);

        optionsHolder.checkerboard(n,i) = optionsHolder2.checkerboard;
        
        clear optionsHolder2
    end
end


end