% Draws PLW stim on a PTB screen - KWK
% 20200925

function [] = drawPLW()

clear all; close all;

%% Initialize
curr_path = pwd;
match_folder_name = 'SYON.git';
path_idx = strfind(curr_path,match_folder_name);
if ~isempty(path_idx)
    options.root_path = curr_path(1:path_idx+length(match_folder_name)-1);
else
    error(['Can''t find folder ' match_folder_name ' in current directory list!']);
end

addpath(genpath(fullfile(options.root_path,'Functions')));
cd(fullfile(options.root_path,'\BiStable_Tasks\BioMotion_Task\Behavioral_Task\Stim'));
% end mps 20190730

% Open dialog box for easier user input
% Since they're running this script, we'll set some default params
optionsString = 'myComp';

[optionsString,subjid,runid] = userInputDialogBox(optionsString);
% optionsString = 'myComp';
% subjid = 'test';
% runid = 1;

% Setup options struct
options.compSetup = optionsString;
options.expName = 'BioMotion_Task';
options.expPath = fullfile(options.root_path,'\BiStable_Tasks\',options.expName,'\Behavioral_Task\');   % Path specific to the experiment % mps 20190730
options = getSubjRun(options,subjid,runid);
if strcmp(options.compSetup,'vaEEG')
    load('Asus_VG248QE_vaEEGlab_lightsoff_20190813.mat','displayInfo');
    options.displayInfo = displayInfo;
elseif strcmp(options.compSetup,'arcEEG')
    load('Asus_VG248QE_EEGlab_lightsoff_20190613.mat','displayInfo');
    options.displayInfo = displayInfo;
elseif strcmp(options.compSetup,'vaCoglab')
    load('Asus_VG248QE_vaCoglab_lightsoff_20190904.mat','displayInfo');
    options.displayInfo = displayInfo;
else
        options.displayInfo.linearClut = 0:1/255:1;
%         options.screenNum = max(Screen('Screens')); % mps 20200328
%     load('Asus_VG248QE_vaCoglab_lightsoff_20190904.mat','displayInfo');
%     options.displayInfo = displayInfo;
end
options = localOptions(options);

% Screen center coords
screenCent = [options.xc; options.yc];

%% Ggenerate pointlight display data using 3D coordinates file
options.PLW_stim.filename = '07_01.data3d.txt';% input data file
% scale size of PLW (distance between dots
options.PLW_stim.scale1 = 50;
% image size (not sure what this is...KWK)
options.PLW_stim.imagex = 100;
%it appears the joint numbers are arranged in a series like 26 27 28.
%Order of joints: head; l shoulder; l elbow, l hand; r shoulder; r elbow; r
%hand; l hip; l knee; l foot; r hip; r knee; r foot;
% 0 for head, 1 for left parts and 2 for right parts of PLW.
options.PLW_stim.mapping = [0 1 1 1 2 2 2 1 1 1 2 2 2];

% reading in bvh files
options.PLW_stim.readData = PLWread(options.PLW_stim.filename);

% calculate the discrete dots along each limb
options.PLW_stim.readData.thet = 90;  %to rotate along the first axis
%to rotate across xyz
% options.PLW_stim.readData.xyzseq = [1 3 2];   % To invert
options.PLW_stim.readData.xyzseq = [1 3 2];   % To invert
[options.PLW_stim.dotx, options.PLW_stim.doty] = PLWtransform(options.PLW_stim.readData, options.PLW_stim.scale1, options.PLW_stim.imagex, -1);

% Invert the PLW
options.PLW_stim.dotx = options.PLW_stim.dotx.*-1;
options.PLW_stim.doty = options.PLW_stim.doty.*-1;

options.PLW_stim.gcolor = {[0 0 0],[0 0 255],[255 0 0]};
    
options.PLW_stim.lengthLoop = 130;
options.PLW_stim.dotloop = modloop(1:options.PLW_stim.lengthLoop, size(options.PLW_stim.dotx,1));

% Make array of individual PLW dot positions over time
count=0;
for f=1:options.PLW_stim.lengthLoop  % two for accuracy
    count=count+1;
    % signal parts
    for grouping = 0 : 2
        options.PLW_stim.dotPos{f,grouping+1} = [options.PLW_stim.dotx(options.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping);...
            options.PLW_stim.doty(options.PLW_stim.dotloop(f),options.PLW_stim.mapping == grouping)];
    end
end

% Dot diameter
options.PLW_stim.pointSize = 5;

%% Draw the stimuli 
counter = 0;
[~,~,keycode,~] = KbCheck;
while ~keycode(options.buttons.buttonEscape)
    
    [~,~,keycode,~] = KbCheck;
    
    counter = counter+1;
    Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{counter,1},options.PLW_stim.pointSize,options.PLW_stim.gcolor{1},screenCent');   % Draw 'head'
    Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{counter,2},options.PLW_stim.pointSize,options.PLW_stim.gcolor{2},screenCent');   % Draw 'left side'
    Screen('DrawDots',options.windowNum,options.PLW_stim.dotPos{counter,3},options.PLW_stim.pointSize,options.PLW_stim.gcolor{3},screenCent');   % Draw 'right side'
    Screen('Flip',options.windowNum);
    
    if counter >= length(options.PLW_stim.dotPos)
        counter = 0;
    end
end

% Close and end
cleanUp(options);



end