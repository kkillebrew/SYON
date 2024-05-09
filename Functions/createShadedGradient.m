% Creates a square checkerboard with a gradient mask overlaid mimicing
% shading within a circular mask.
%
% KWK - 20200318

function [options] = createShadedGradient(options)

%% Create the masks
% Size of the circle
options.checkerboard.circSize = options.checkerboard.xDeg;   % Circle size in degrees
options.checkerboard.centRadius = round((options.checkerboard.circSize/2)*options.PPD);   % Circle radius in pixels

% Create the circle mask
% Blank circle mask
[xx,yy] = meshgrid(1:ceil(options.checkerboard.yDim),1:ceil(options.checkerboard.xDim));
options.checkerboard.circMask = false(ceil(options.checkerboard.xDim),ceil(options.checkerboard.yDim));
options.checkerboard.circMask = options.checkerboard.circMask | hypot(xx - options.checkerboard.xc,...
    yy - options.checkerboard.yc) <= options.checkerboard.centRadius;

% Add a gaussian to circle
% options.stim.blurSD = .5;
% options.checkerboard.gaussFilt = fspecial('gaussian',length(options.checkerboard.circMask)+1,options.stim.blurSD*options.PPD);   % Create the gaussian portion of the mask
% options.checkerboard.circMask = conv2(double(options.checkerboard.circMask),double(options.checkerboard.gaussFilt),'same');

% Code for creating the exponential decay instead of linear decay
% for i=0:.2:2
% x = [0:.1:191];
% k = i;
% f = @(x,k) exp(-abs(k*x));
% figure()
% plot(x, f(x,k))
% end

% Create the gradient function
options.checkerboard.gradientMax = 1;   % Maximum value of gradient
options.checkerboard.gradientMin = 0;   % Minimum value of gradient
options.checkerboard.gradientProp = .5;   % Proportion of gradient where shading starts
options.checkerboard.gradientFunc = ones([ceil(options.checkerboard.xDim),1]).*options.checkerboard.gradientMax;   % Start with a straight line
options.checkerboard.gradientIdx = floor((length(options.checkerboard.gradientFunc)*(1-options.checkerboard.gradientProp)))+1:length(options.checkerboard.gradientFunc);
options.checkerboard.gradientLength = ceil(length(options.checkerboard.gradientFunc)*options.checkerboard.gradientProp);   % At what point in the circle should the gradient start (here it's halfway)
x = [0:options.checkerboard.gradientLength-1];
k = .002;
zeroPoint = 2000;
minGrad = 0.5;
% f = @(x,k) exp(-abs(k*x));


f = @(x,k) (1 - minGrad).*exp(-abs(k.*x.*zeroPoint./options.checkerboard.gradientLength)) + minGrad;
% y = f(x,k);
% options.checkerboard.gradientFunc(options.checkerboard.gradientIdx) = linspace(1,.5,options.checkerboard.gradientLength);
options.checkerboard.gradientFunc(options.checkerboard.gradientIdx) = f(x,k);
% figure()
% plot(options.checkerboard.gradientFunc)

% Create gradient mask
options.checkerboard.gradientMask = repmat(options.checkerboard.gradientFunc,[1,ceil(options.checkerboard.xDim)]);

% figure()
% imshow(options.checkerboard.gradientMask)

% Add the two masks together
options.checkerboard.maskHolder = options.checkerboard.circMask.*options.checkerboard.gradientMask;

% figure()
% imshow(options.checkerboard.maskHolder)


%% Create checkerboard
options = createCheckerboard(options);

% figure()
% imagesc(options.checkerboard.texArrayHolder{1});
% figure()
% imagesc(options.checkerboard.texArrayHolder{2});

%% Create alpha layer
options.checkerboard.texArray{1}(:,:,1) = options.checkerboard.texArrayHolder{1};
options.checkerboard.texArray{1}(:,:,2) = options.checkerboard.texArrayHolder{1};
options.checkerboard.texArray{1}(:,:,3) = options.checkerboard.texArrayHolder{1};
options.checkerboard.texArray{1}(:,:,4) = options.checkerboard.circMask*options.whiteCol(1);
% options.checkerboard.texArray{1}(:,:,4) = options.checkerboard.circMask;

options.checkerboard.texArray{2}(:,:,1) = options.checkerboard.texArrayHolder{2};
options.checkerboard.texArray{2}(:,:,2) = options.checkerboard.texArrayHolder{2};
options.checkerboard.texArray{2}(:,:,3) = options.checkerboard.texArrayHolder{2};
options.checkerboard.texArray{2}(:,:,4) = options.checkerboard.circMask*options.whiteCol(1);
% options.checkerboard.texArray{2}(:,:,4) = options.checkerboard.circMask;


end