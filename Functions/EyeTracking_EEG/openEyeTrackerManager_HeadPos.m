% Open the eye tracker manager to measure head position. Closes after. 
function [options] = openEyeTrackerManager_HeadPos(options)

% % WIll WANT TO COMMENT WHEN USED AS A FUNCTION!!
% Tobii = EyeTrackingOperations;
% foundEyeTracker = Tobii.find_all_eyetrackers();   
% eyetracker = foundEyeTracker.Address;
% options.ETOptions.etm_name = options.ETOptions.options.ETOptions.etm_name;

if ispc
    options.ETOptions.etm_folder  = [sprintf('%s%s',getenv('LocalAppData'),'\Programs') '\' options.ETOptions.etm_name '\'];
%     res = regexp(cellstr(ls(etm_folder)),'(app-.*)','tokens');
%     etm_version_folder = char(string(horzcat(res{:})));
    etm_path = ['"' options.ETOptions.etm_folder options.ETOptions.etm_name '.exe"'];
elseif ismac
    etm_path = ['"/Applications/' options.ETOptions.etm_name '.app/Contents/MacOS/' options.ETOptions.etm_name '"'];
elseif isunix
    etm_path = options.ETOptions.etm_name;
end

% cmd = [etm_path ' ' '--device-address=' eyetracker ' ' '--mode=' etm_mode];
cmd = [etm_path ' ' '--device-address=' options.ETOptions.eyetrackerAddress];
[status, result] = system(cmd);

disp(['status:', num2str(status)]);
disp(['result:', result]);

if status == 0
    disp('Eye Tracker Manager was called successfully!');
else
    disp(['Eye Tracker Manager call returned the error code ', num2str(status)]);
end

end