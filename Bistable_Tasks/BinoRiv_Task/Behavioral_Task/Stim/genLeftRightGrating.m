% Generate the grating values for left and right eyes
% KWK - 20201014

function [options] = genLeftRightGrating(options)

%% left eye values
options.sp.left.eccentricity = [0.5.*options.PPD options.sp.gratSize];   % Eccentricity of ??? in pixels
options.sp.left.gratSize = options.sp.gratPhase * options.PPD;
options.sp.left.spatialFrequency = .5/options.PPD;   % Spatial frequency in pixels
options.sp.left.gratPhase = options.sp.gratPhase(1);   % Phase - determined randomly
options.sp.left.contrast = 1;   % Full contrast
options.sp.left.rotate = 0;   % Rotation of the grating
options.sp.left.orientation = -45*pi/180;   % Grating orientation in radians
options.sp.left.gratType = 'sin';
options.sp.left.color = [1 0 0];
options.sp.left.gauss_sigma = 5*options.PPD;   % Gaussian sigma
options.sp.left.eyeInd = 1;   % Which eye 1 for left, 2 for right
options.sp.left.t_step = 10;   % Not sure what this is for... (taken from BR_RivalryBlocked script)
options.sp.left.d = 2;   % Not sure what this is for... (taken from BR_RivalryBlocked script)
options.sp.left.rr = options.sp.rr;

switch options.sp.left.gratType
    case 'sin'
        options.sp.left.gratingAnn = options.sp.backGroundLum + ...
            (options.sp.meanLuminance*options.sp.left.contrast).*sin(2*pi*options.sp.left.spatialFrequency*...
            (options.sp.xx.*cos(options.sp.left.orientation) + options.sp.yy.*sin(options.sp.left.orientation))...
            - options.sp.left.gratPhase);
    case 'square'
        options.sp.left.gratingAnn = options.sp.backGroundLum + ...
            (options.sp.meanLuminance*options.sp.left.contrast).*square(2*pi*options.sp.left.spatialFrequency*...
            (options.sp.xx.*cos(options.sp.left.orientation) + options.sp.yy.*sin(options.sp.left.orientation))...
            - options.sp.left.gratPhase);
end

% Add in the gaussian
options.sp.left.gauss_mask = exp(-(options.sp.rr.^2)./(2*options.sp.left.gauss_sigma.^2));
options.sp.left.gratingAnn = options.sp.left.gratingAnn .* options.sp.left.gauss_mask;

% Add in color
options.sp.left.cm = repmat(options.sp.left.color', [1 size(options.sp.left.gratingAnn)]); % Colour matrix
options.sp.left.cm = permute(options.sp.left.cm, [2, 3, 1]);
options.sp.left.gratingAnn = repmat(options.sp.left.gratingAnn, [1, 1, 3]) .* options.sp.left.cm;
options.sp.left.rr = repmat(options.sp.left.rr, [1, 1, 3]);

% Cut off the inner and outer portions of the annulus
options.sp.left.gratingAnn(options.sp.left.rr<options.sp.left.eccentricity(1) | options.sp.left.rr>options.sp.left.eccentricity(2)) = options.sp.backGroundLum;
options.sp.left.center = [round(size(options.sp.left.gratingAnn,1)/2), round(size(options.sp.left.gratingAnn,2)/2)];
% options.sp.left.gratingAnn((options.sp.left.center(1)-1:options.sp.left.center(1)+1),(options.sp.left.center(2)-1:options.sp.left.center(2)+1)) = 0;
% options.sp.left.gratingAnn((options.sp.left.center(1) - 10):(options.sp.left.center(1) + 10), (options.sp.left.center(2)-1):(options.sp.left.center(2)+1)) = 0;
% options.sp.left.gratingAnn((options.sp.left.center(1)-1):(options.sp.left.center(1)+1), (options.sp.left.center(2) - 10):(options.sp.left.center(2) + 10)) = 0;

%% right eye values
options.sp.right.eccentricity = [0.5.*options.PPD options.sp.gratSize];   % Eccentricity of ??? in pixels
options.sp.right.gratSize = options.sp.gratPhase * options.PPD;
options.sp.right.spatialFrequency = .5/options.PPD;   % Spatial frequency in pixels
options.sp.right.gratPhase = options.sp.gratPhase(1);   % Phase - determined randomly
options.sp.right.contrast = 1;   % Full contrast
options.sp.right.rotate = 0;   % Rotation of the grating
options.sp.right.orientation = 45*pi/180;   % Grating orientation in radians
options.sp.right.gratType = 'sin';
options.sp.right.color = [0 1 1];
options.sp.right.gauss_sigma = 5*options.PPD;   % Gaussian sigma
options.sp.right.eyeInd = 1;   % Which eye 1 for left, 2 for right
options.sp.right.t_step = 10;   % Not sure what this is for... (taken from BR_RivalryBlocked script)
options.sp.right.d = 2;   % Not sure what this is for... (taken from BR_RivalryBlocked script)
options.sp.right.rr = options.sp.rr;

switch options.sp.right.gratType
    case 'sin'
        options.sp.right.gratingAnn = options.sp.backGroundLum + ...
            (options.sp.meanLuminance*options.sp.right.contrast).*sin(2*pi*options.sp.right.spatialFrequency*...
            (options.sp.xx.*cos(options.sp.right.orientation) + options.sp.yy.*sin(options.sp.right.orientation))...
            - options.sp.right.gratPhase);
    case 'square'
        options.sp.right.gratingAnn = options.sp.backGroundLum + ...
            (options.sp.meanLuminance*options.sp.right.contrast).*square(2*pi*options.sp.right.spatialFrequency*...
            (options.sp.xx.*cos(options.sp.right.orientation) + options.sp.yy.*sin(options.sp.right.orientation))...
            - options.sp.right.gratPhase);
end

options.sp.right.gauss_mask = exp(-(options.sp.rr.^2)./(2*options.sp.right.gauss_sigma.^2));
options.sp.right.gratingAnn = options.sp.right.gratingAnn .* options.sp.right.gauss_mask;

% Add in color
options.sp.right.cm = repmat(options.sp.right.color', [1 size(options.sp.right.gratingAnn)]); % Colour matrix
options.sp.right.cm = permute(options.sp.right.cm, [2, 3, 1]);
options.sp.right.gratingAnn = repmat(options.sp.right.gratingAnn, [1, 1, 3]) .* options.sp.right.cm;
options.sp.right.rr = repmat(options.sp.right.rr, [1, 1, 3]);

% Cut off the inner and outer portions of the annulus
options.sp.right.gratingAnn(options.sp.right.rr<options.sp.right.eccentricity(1) | options.sp.right.rr>options.sp.right.eccentricity(2)) = options.sp.backGroundLum;
options.sp.right.center = [round(size(options.sp.right.gratingAnn,1)/2), round(size(options.sp.right.gratingAnn,2)/2)];
% options.sp.right.gratingAnn((options.sp.right.center(1)-1:options.sp.right.center(1)+1),(options.sp.right.center(2)-1:options.sp.right.center(2)+1)) = 0;
% options.sp.right.gratingAnn((options.sp.right.center(1) - 10):(options.sp.right.center(1) + 10), (options.sp.right.center(2)-1):(options.sp.right.center(2)+1)) = 0;
% options.sp.right.gratingAnn((options.sp.right.center(1)-1):(options.sp.right.center(1)+1), (options.sp.right.center(2) - 10):(options.sp.right.center(2) + 10)) = 0;


end