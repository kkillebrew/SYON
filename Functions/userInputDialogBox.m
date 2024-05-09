% Open a dialog box that asks for user input for subj/run/exp
% identification.
% 20200219

function [optionsString,subjid,runid,options] = userInputDialogBox(optionsString,options)

% Open input dialog box to get subjid and runid
promptOptionsstring = {'Enter subject id:','Enter run number:','Recording EEG:','Trigger photodiode:','Practice:','Display figures:','Timing testing:','Eyetracking:','Calibrate Eyetracker:'};
dlgtitle = 'Subj/Run Select';
dims = [1 35];

% Check to see if values exist for specific experiments and make them if they don't
if ~isfield(options,'eegRecording')
    options.eegRecording = 0;
end
if ~isfield(options,'practice')
    options.practice.doPractice = 0;
else
    if ~isfield(options.practice,'doPractice')
        options.practice.doPractice = 0;
    end
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 0;
end
if ~isfield(options,'signalPhotodiode')
   options.signalPhotodiode = 0; 
end
if ~isfield(options,'photodiodeTesting')
    options.photodiodeTesting = 0;
end
if ~isfield(options,'eyeTracking')
    options.eyeTracking = 0;
end
if ~isfield(options,'etCalib')
    options.etCalib = 0;
end

% Create default values
definput = {'S','1',...
    num2str(options.eegRecording),num2str(options.signalPhotodiode),num2str(options.practice.doPractice),...
    num2str(options.displayFigs),num2str(options.photodiodeTesting),...
    num2str(options.eyeTracking),num2str(options.etCalib)};
answer = inputdlg(promptOptionsstring,dlgtitle,dims,definput);

% Record user input
subjid = answer{1};
runid = str2double(answer{2});
options.eegRecording = str2double(answer(3));
options.signalPhotodiode = str2double(answer(4));
options.practice.doPractice = str2double(answer(5));
options.displayFigs = str2double(answer(6));
options.photodiodeTesting = str2double(answer(7));
options.eyeTracking = str2double(answer(8));
options.etCalib = str2double(answer(9));

% Open drop down list to select comp setup
optionsStringList ={'CMRR',...
    'CMRR_Psychophysics',...
    'labComp',...
    'myComp',...
    'vaEEG',...
    'vaCoglab',...
    'MPSComp',...
    'arcEEG'};

initialValue = find(strcmp(optionsString,optionsStringList));

[indx,~] = listdlg('ListString',optionsStringList,...
    'SelectionMode','single',...
    'InitialValue',initialValue);

if ~isempty(indx)
    optionsString = optionsStringList{indx};
end

% CODE TO MAKE A SINGLE DIALOG BOX W/ ALL FIELDS - KWK STILL WORKING -
% 20200219
% % Open dialog box at center of screen
% % myDialog.position = [left bottom width height];
% myDialog = dialog('Name','Experiment Setup');
% 
% % First title of first input
% uicontrol('Parent',myDialog,...
%     'Style','Text','String','Choose computer setup:',...
%     'Position',[myDialog.Position(1)+10 myDialog.Position(2)+20 myDialog.Position(1)+50 20]);
% 
% uicontrol('Parent',myDialog,...
%     'Style', 'Edit', 'String', optionsStringList, ...
%     'Position', [myDialog.Position(1)+10,myDialog.Position(2)+10,myDialog.Position(3)-10,myDialog.Position(2)+10]);
%       
% 
% 
% % uicontrol('Style', 'Edit', 'String', Str, ...
% %           'Position', [10, 10, 380, 500]);
%       
%       popup = uicontrol('Parent',d,...
%            'Style','popup',...
%            'Position',[75 70 100 25],...
%            'String',{'Red';'Green';'Blue'},...
%            'Callback',@popup_callback);
%        
%     btn = uicontrol('Parent',d,...
%            'Position',[89 20 70 25],...
%            'String','Close',...
%            'Callback','delete(gcf)');
%        
%     choice = 'Red';
%        
%     % Wait for d to close before running to completion
%     uiwait(d);
%    
%        function popup_callback(popup,event)
%           idx = popup.Value;
%           popup_items = popup.String;
%           % This code uses dot notation to get properties.
%           % Dot notation runs in R2014b and later.
%           % For R2014a and earlier:
%           % idx = get(popup,'Value');
%           % popup_items = get(popup,'String');
%           choice = char(popup_items(idx,:));
%        end
% 

end

