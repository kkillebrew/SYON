% Find eyetracker and create eye tracker object.

function [options] = findEyeTracker(options)

% Add paths for ET SDK
options.ETOptions.sdkPath = 'C:\Users\EEG Task Computer\Desktop\TobiiPro.SDK.Matlab_1.8.0.21';
addpath(fullfile(options.ETOptions.sdkPath));

% Create new eye tracking operations object (class with setup functions for
% eye tracking (locating address, connect to specific eye trackers, etc.) -
% KWK 20200106
options.ETOptions.etm_name = 'TobiiProEyeTrackerManager';
options.ETOptions.Tobii = EyeTrackingOperations();

% Find the eye tracker address (will need to be modified if multiple eye
% trackers are being used)
foundEyeTracker = options.ETOptions.Tobii.find_all_eyetrackers();   
if ~isempty(foundEyeTracker)
    disp(["Address: ", foundEyeTracker.Address])
    disp(["Model: ", foundEyeTracker.Model])
    disp(["Name (It's OK if this is empty): ", foundEyeTracker.Name])
    disp(["Serial number: ", foundEyeTracker.SerialNumber])
else
    error('Could not find options.ETOptions.eyeTracker. Check connection or power!')
end

% Port location of the eye tracker
options.ETOptions.eyetrackerAddress = foundEyeTracker.Address;   % Example: eyetracker_address = 'tet-tcp://172.28.195.1';

% Setup a new eye tracker object using the location of the eye tracker
options.ETOptions.eyeTracker = options.ETOptions.Tobii.get_eyetracker(options.ETOptions.eyetrackerAddress);

end