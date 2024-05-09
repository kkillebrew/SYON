function output = run_subj_group_def( options )
% usage: output = run_subj_group_def( options )
%
% mps 20220127
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
    options.demog_target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
end

output = [];
% %% read in demog data
% demog_opts = [];
% demog_opts.target_file = options.demog_target_file;
% % demog_opts.subj_number = subj_number;
% % demog_opts.date_number = date_number;
% demog_opts.subj_group_def = options.subj_group_def;
% demog_all_data = read_in_demog_data(demog_opts);
% demog_data = demog_all_data;
% 
% dx_list = nan(numel(options.subj_number),1);
% missing_dx_list = [];
% for iSubj = 1:numel(options.subj_number)
%     dx_idx = strcmp(['P' num2str(options.subj_number(iSubj))],demog_data.Record_ID);
%     if isempty(dx_idx) % if this subject isn't in the demographics .csv file
%         missing_dx_list = [missing_dx_list ; options.subj_number(iSubj)];
%         continue
%     end
%     find_dx = demog_data.Dx_code(dx_idx);
%     if ~isempty(find_dx) 
%         dx_list(iSubj) = find_dx;
%     end
% end

%% define groups

%Legend for dx codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
%6=Panic; 7=DeprNOS; 8=PsychNOS; 9=ADHD

if options.subj_group_def == 1; %use controls, probands, and relatives as the different groups
    
    output.use_colors = {'g','b','r'};
    output.use_colors_RGB = {[0 1 0] [0 0 1]  [1 0 0]};
    output.g1_idx = options.subj_number < 2000000;
    output.g1_label = 'Control';
    output.g1_short = 'C';
    output.g2_idx = options.subj_number >= 2000000 & options.subj_number < 6000000;
    output.g2_label = 'Relative';
    output.g2_short = 'R';
    output.g3_idx = options.subj_number > 6000000;
    output.g3_label = 'Psychosis';
    output.g3_short = 'P';
    output.corr_colors = {[0.33 1 0.33],[0.33 0.33 1],[1 0.33 0.33]};
    
elseif options.subj_group_def == 2; % look at controls, SZ, BP
    output.use_colors = {'g',[0.75 0 0.75],[255 204 0]./255};
    output.use_colors_RGB = {[0 1 0] [0.75 0 0.75]  [255 204 0]./255};
    %RK edited Oct 2, 2022 to fix size mismatches 
    if size(dx_list) ~= size(options.subj_number)
        options.subj_number = reshape(options.subj_number, ...
            [size(options.subj_number,2) size(options.subj_number,1)]);
    end
%    output.g1_idx = (dx_list == 0) & options.subj_number < 2000000; % no dx, and control subject ID
    output.g1_idx = options.subj_number < 2000000; % control subject ID, not excluding for dx - mps 20230105
    output.g1_label = 'Control';
    output.g1_short = 'C';
    output.g2_idx = (dx_list == 2) & options.subj_number > 6000000;
    output.g2_label = 'SZ';
    output.g2_short = 'SZ';
    output.g3_idx = ( (dx_list == 4 | dx_list == 5) ) & options.subj_number > 6000000;
    output.g3_label = 'BP';
    output.g3_short = 'BP';
    
elseif options.subj_group_def == 3; %look at SZ, SCA, BP
    output.use_colors = {[0.75 0 0.75],[255 102 0]./255 , [255 204 0]./255};
    output.use_colors_RGB = {[0.75 0 0.75] [255 102 0]./255  [255 204 0]./255};
    output.g1_idx = (dx_list == 2) & options.subj_number > 6000000;
    output.g1_label = 'SZ';
    output.g1_short = 'SZ';
    output.g2_idx = (dx_list == 3) & options.subj_number > 6000000;
    output.g2_label = 'SCA';
    output.g2_short = 'SCA';
    output.g3_idx = ( (dx_list == 4 | dx_list == 5) ) & options.subj_number > 6000000;
    output.g3_label = 'BP';
    output.g3_short = 'BP';
    
elseif options.subj_group_def == 4; %look at controls, SCZ+SCA, BP
    output.use_colors = {'c','m',[255 204 0]./255};
    output.use_colors_RGB = {[0 1 1] [1 0 1] [255 204 0]./255};
    output.g1_idx = (dx_list == 0) & options.subj_number < 6000000;
    output.g1_label = 'Ctrl + Rel';
    output.g1_short = 'C+R';
    output.g2_idx = (dx_list == 2 | dx_list == 3) & options.subj_number > 6000000;
    output.g2_label = 'SZ+SCA';
    output.g2_short = 'SZ+A';
    output.g3_idx = ( (dx_list == 4 | dx_list == 5) ) & options.subj_number > 6000000;
    output.g3_label = 'BP';
    output.g3_short = 'BP';
    
elseif options.subj_group_def == 5; % flip patients and relatives
    
    output.use_colors = {'g','r','b'};
    output.use_colors_RGB = {[0 1 0] [1 0 0] [0 0 1]};
    output.g1_idx = options.subj_number < 2000000;
    output.g1_label = 'Control';
    output.g1_short = 'C';
    output.g2_idx = options.subj_number > 6000000;
    output.g2_label = 'Proband';
    output.g2_short = 'P';
    output.g3_idx = options.subj_number >= 2000000 & options.subj_number < 6000000;
    output.g3_label = 'Relative';
    output.g3_short = 'R';
    
else
    error(['Unknown value for options.subj_group_def = ' num2str(options.subj_group_def)]);
end

if ~isfield(output,'corr_colors')
    output.corr_colors = output.use_colors;
end

%% out
output.options = options;

end