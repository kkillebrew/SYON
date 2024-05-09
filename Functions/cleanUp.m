% Ending function that saves, closes windows, and resets settings back to
% what they were pre-experiment.
% 2019-06-28
%
% Usage:
% [options,rawdata] = cleanUp(options, rawdata)
%
% Loacted in the functions folder.
%
% Input:
% options: 
%   Stuct containg all the options for the current experiment. Importantly
%   contains compSetup string for iding which setup you are on.
% rawdata:
%   Matrix or struct containing the output data and conditions for each
%   trial. Should contain rawdata as a field. 
% justSave:
%   Switch variable to decide if we only want to save or if we want to save
%   and quit.
%
% Output:

function [] = cleanUp(options,data,justSave)

switch nargin
    case 1   % Save w/out data file
        save(fullfile(options.datadir,options.datafile),'options'); % start mps 20190730 remove '/'
        justSave = 0;
    case 2   % Save w/ data file
        save(fullfile(options.datadir,options.datafile),'data','options');
        justSave = 0;
    case 3   % Only save, don't close out
        save(fullfile(options.datadir,options.datafile),'data','options');
end

if justSave  == 0
    % Close all screens and textures
%     Screen('Close',options.windowNum);
    Screen('CloseAll');
    
    % Show cursor/turn back on keyboard input
    if ~justSave
        ShowCursor;
        ListenChar(0);
    end
    
    % Load in the original monitor CLUT (color look up table)
    if strcmp(options.compSetup,'vaEEG') || strcmp(options.compSetup,'arcEEG')
        % Reset the monitor to its previous settings
        Screen('Resolution',options.screenNum,options.wInfoOrig.width,...
            options.wInfoOrig.height,options.wInfoOrig.hz);
        
        Screen('LoadNormalizedGammaTable',options.screenNum,options.wInfoOrig.CLUT,0);
    end
end

end