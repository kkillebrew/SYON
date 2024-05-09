% Function to create checkerboard stimuli for the MR versions of the SYON
% experiments. 
% 20200109 = KWK

function [options] = createCheckerboard(options)

if isfield(options.checkerboard,'maskHolder')
    mask = options.checkerboard.maskHolder;
end

pixelsPerDegree = options.PPD;
bkgSize = ceil(options.checkerboard.xDim/pixelsPerDegree); % pixels
checkSize = options.checkerboard.checkSize; % degrees (1/10th of the circ diameter)
shift_check = ceil(checkSize*pixelsPerDegree); % pixels to move the checkerboard pattern within the mask (shift the size of the one check)

% blackchecks = zeros(round(checkSize*pixelsPerDegree));
blackchecks = -ones(ceil(checkSize*pixelsPerDegree));
whitechecks = ones(ceil(checkSize*pixelsPerDegree));
pattern = [blackchecks whitechecks;whitechecks blackchecks];
checkerboard = repmat(pattern, ceil((bkgSize*2)/(checkSize*2)));
% checkerboard = checkerboard(shift_check+1:shift_check+size(mask,1),...
%     shift_check+1:shift_check+size(mask,1));
checkerboard = checkerboard(shift_check+1:shift_check+options.checkerboard.xDim,...
    shift_check+1:shift_check+options.checkerboard.yDim);

checkerboard1 = checkerboard.*(127.5)+(127.5);
checkerboard2 = (checkerboard.*-1).*(127.5)+(127.5);

if isfield(options.checkerboard,'maskHolder')
    options.checkerboard.texArrayHolder{1} = checkerboard1.*mask; % phase 1
    options.checkerboard.texArrayHolder{2} = (checkerboard2.*mask); % phase 2 (counter-phase)
else
    options.checkerboard.texArrayHolder{1} = checkerboard1; % phase 1
    options.checkerboard.texArrayHolder{2} = (checkerboard2); % phase 2 (counter-phase)
end

% % multiply by bg, then add white
% options.checkerboard.texArrayHolder{1} = options.checkerboard.texArrayHolder{1}.*(127.5)+(127.5);
% options.checkerboard.texArrayHolder{2} = options.checkerboard.texArrayHolder{2}.*(127.5)+(127.5);

options.checkerboard.texArrayHolder{1} = 255*options.displayInfo.linearClut(round(options.checkerboard.texArrayHolder{1})+1);
options.checkerboard.texArrayHolder{2} = 255*options.displayInfo.linearClut(round(options.checkerboard.texArrayHolder{2})+1);

% figure()
% imshow(checkerboard_stim{1})
% figure()
% imshow(checkerboard_stim{2})

end