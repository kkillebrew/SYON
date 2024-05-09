% Ends eyetracking for the eyelink at the CMRR. Coninutation of adapted MPS code.
% KWK - 20201015

function [] = stopCMRREyeTracking(options)

% STEP 7
% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
%Eyelink('StopRecording');
Eyelink('CloseFile');
% download data file
try
    fprintf('Receiving data file ''%s''\n', [options.el_folder options.subjID '_' num2str(options.runID) '_' options.el_datafile '.edf'] );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if ~exist([options.el_folder options.subjID '_' num2str(options.runID) '_' options.el_datafile '.edf'], 'file')
        % Had to switch the naming of the ET files and do a double mover
        % for some reason... Initial move will only move it into the
        % current directory.
%         movefile([datestr(now,'mmddyy') '.edf'])
        movefile([datestr(now,'mmddyy') '.edf'],[options.el_folder options.subjID '_' num2str(options.runID) '_' options.el_datafile '.edf'])
        fprintf('Data file ''%s'' can be found in ''%s''\n',...
            [options.subjID '_' num2str(options.runID) '_' options.el_datafile '.edf'], options.el_folder);
    end
catch rdf    %%%%%%% NOT SURE WHAT THIS DOES
    fprintf('Problem receiving data file ''%s''\n', options.edfFile );
    rdf;
end

% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
end