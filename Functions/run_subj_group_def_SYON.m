function output = run_subj_group_def_SYON( options )
% usage: output = run_subj_group_def( options )
%
% KWK - adapted for SYON from MPS code run_subj_group_def for pHCP
%% opts

if ~exist('options','var')
    options = [];
end

%Options for subject_group_def from refit_COP_dataRK by HM 30 OCT 2019
if ~isfield (options, 'subj_group_def')
    options.subj_group_def = 1; % 1 = controls, relatives, probands; 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 4 = healthy (con+rel),
    % SZ+SCA, bipolar,
    warndlg('Warning, options.subj_group_def not provided, assuming you want 1 = controls, relatives, probands');
end
if ~isfield (options, 'subj_number')
    error('options.subj_number not provided, I quit');
end
if ~isfield (options, 'demog_target_file')
%     options.demog_target_file = 'C:\GitRepos\SYON.git\Demographics\SYON-InitialDxGroup_DATA_2023-10-31_1357.csv';
    options.demog_target_file = 'E:\GitRepos\SYON.git\Demographics/SYON-InitialDxGroup_DATA_2024-03-28_1055.csv';
%     options.demog_target_file = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics/SYON-InitialDxGroup_DATA_2024-03-28_1055.csv';
end

output = [];
%% read in demog data
% 1	Schizophrenia
% 2	Schizoaffective Bipolar
% 3	Bipolar
% 4	Major Depressive Disorder
% 5	Control
% 6	Schizophrenia Relative
% 7	Schizoaffective-Bipolar Relative
% 8	Bipolar Relative
% 9	Other
% 10 Unknown
% 11 Schizoaffective-Depressed
% 12 Schizoaffective-Depressed Relative
% Load in initial dx values for sorting
initialDxTable = readtable(fullfile(options.demog_target_file));
% Get list of subj nums from initialDxTable
counter=0;
for iI=1:size(initialDxTable,1)
    if strcmp(initialDxTable{iI,1}{1}(1),'S')
        counter=counter+1;
        initialDxTableConverted(counter,1) = str2num(initialDxTable{iI,1}{:}(2:end));
        initialDxTableConverted(counter,2) = initialDxTable{iI,5};
    end
end
clear counter

% Read in each participants initial_dx
dx_list = nan([numel(options.subj_number) 1])';
missing_dx_list = [];
for iTask = 1:2   % For real / bistable tasks
    for iS = 1:length(options.subj_number)
        dx_list(iS) = ...
            initialDxTableConverted(options.subj_number(iS)==initialDxTableConverted(:,1),2);
    end
end


%% define groups

%Legend for dx codes: 
% 1	Schizophrenia
% 2	Schizoaffective Bipolar
% 3	Bipolar
% 4	Major Depressive Disorder
% 5	Control
% 6	Schizophrenia Relative
% 7	Schizoaffective-Bipolar Relative
% 8	Bipolar Relative
% 9	Other
% 10 Unknown
% 11 Schizoaffective-Depressed
% 12 Schizoaffective-Depressed Relative

if options.subj_group_def == 1   %use controls, probands, and relatives as the different groups
    % Define group variables
    output.use_colors = {'g','b','r'};
    output.use_colors_RGB = {[0 1 0] [0 0 1]  [1 0 0]};
    output.g1_idx = options.subj_number < 2000000;
    output.g1_label = 'Control';
    output.g1_short = 'C';
    output.g2_idx = options.subj_number >= 2000000 & options.subj_number < 6000000;
    output.g2_label = 'Relative';
    output.g2_short = 'R';
    output.g3_idx = options.subj_number > 6000000;
    output.g3_label = 'PwPP';
    output.g3_short = 'P';
    output.corr_colors = {[0.33 1 0.33],[0.33 0.33 1],[1 0.33 0.33]};
    
elseif options.subj_group_def == 2   % look at controls, SZ, BP
    % Define group variables
    output.use_colors = {'g',[0.75 0 0.75],[255 204 0]./255};
    output.use_colors_RGB = {[0 1 0] [0.75 0 0.75]  [255 204 0]./255};
    output.g1_idx = (dx_list == 5) & options.subj_number < 2000000; % 5 dx, and control subject ID
    output.g1_label = 'Control';
    output.g1_short = 'C';
    output.g2_idx = ( (dx_list == 1 | dx_list == 11) ) & options.subj_number > 6000000;
    output.g2_label = 'SZ';
    output.g2_short = 'SZ';
    output.g3_idx = ( (dx_list == 2 | dx_list == 3) ) & options.subj_number > 6000000;
    output.g3_label = 'BP';
    output.g3_short = 'BP';
    
% elseif options.subj_group_def == 3   %look at SZ, SCA, BP
%     output.use_colors = {[0.75 0 0.75],[255 102 0]./255 , [255 204 0]./255};
%     output.use_colors_RGB = {[0.75 0 0.75] [255 102 0]./255  [255 204 0]./255};
%     output.g1_idx = (dx_list == 2) & options.subj_number > 6000000;
%     output.g1_label = 'SZ';
%     output.g1_short = 'SZ';
%     output.g2_idx = (dx_list == 3) & options.subj_number > 6000000;
%     output.g2_label = 'SCA';
%     output.g2_short = 'SCA';
%     output.g3_idx = ( (dx_list == 4 | dx_list == 5) ) & options.subj_number > 6000000;
%     output.g3_label = 'BP';
%     output.g3_short = 'BP';
%     
% elseif options.subj_group_def == 4; %look at controls, SCZ+SCA, BP
%     output.use_colors = {'c','m',[255 204 0]./255};
%     output.use_colors_RGB = {[0 1 1] [1 0 1] [255 204 0]./255};
%     output.g1_idx = (dx_list == 0) & options.subj_number < 6000000;
%     output.g1_label = 'Ctrl + Rel';
%     output.g1_short = 'C+R';
%     output.g2_idx = (dx_list == 2 | dx_list == 3) & options.subj_number > 6000000;
%     output.g2_label = 'SZ+SCA';
%     output.g2_short = 'SZ+A';
%     output.g3_idx = ( (dx_list == 4 | dx_list == 5) ) & options.subj_number > 6000000;
%     output.g3_label = 'BP';
%     output.g3_short = 'BP';
%     
% elseif options.subj_group_def == 5; % flip patients and relatives
%     
%     output.use_colors = {'g','r','b'};
%     output.use_colors_RGB = {[0 1 0] [1 0 0] [0 0 1]};
%     output.g1_idx = options.subj_number < 2000000;
%     output.g1_label = 'Control';
%     output.g1_short = 'C';
%     output.g2_idx = options.subj_number > 6000000;
%     output.g2_label = 'Proband';
%     output.g2_short = 'P';
%     output.g3_idx = options.subj_number >= 2000000 & options.subj_number < 6000000;
%     output.g3_label = 'Relative';
%     output.g3_short = 'R';
    
else
    error(['Unknown value for options.subj_group_def = ' num2str(options.subj_group_def)]);
end

if ~isfield(output,'corr_colors')
    output.corr_colors = output.use_colors;
end

%% out
output.options = options;

end