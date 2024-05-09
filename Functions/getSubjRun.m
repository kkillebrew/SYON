% Function to set input for subj id and run id in options struct.
% 2019-06-28
%
% Usage:
% [options] = getSubjRun(options [,subjid] [,runid])
%
% Usually run from within the experiment code.
%
% Input:
% options:
%   Struct that contains the computer setup label. Stored in
%   options.compSetup. Must be a known comp: 'vaEEG', 'labComp',
%   'arcEEG', or 'myComp'.
% subjID:
%   Optional string variable containing the participants ID. If left empty,
%   and on lab/personal comp, will set subjID to 'Test'. If 'Test' is set
%   as subjID, will enable certain params, like hide cursor and listen
%   char. If on an EEG comp, will probe for subjID input.
% runID:
%   Optional string variable containing the run number. If left empty on a
%   lab/personal comp, will set runID to 1. If on an EEG comp, will probe.
%
% Output:
% options:
%   Structure including the params of the experiment. Includes monitor and
%   setup options.

function [options] = getSubjRun(options,subjid,runid)

if (strcmp(options.compSetup, 'vaEEG') || strcmp(options.compSetup, 'arcEEG'))
    if isempty(subjid)
        options.subjID = input('Enter Subject Code:','s');
    end
    if isempty(runid)
        options.runID  = input('Enter Run:');
    end
end

if (strcmp(options.compSetup, 'myComp') || strcmp(options.compSetup, 'labComp'))
    if isempty(subjid)
        options.subjID = 'test';
    end
    if isempty(runid)
        options.runID = 1;
    end
end

if ~isempty(subjid)
    options.subjID = subjid;
end

if ~isempty(runid)
    options.runID = runid;
end

end