function [output] = make_syon_methods_table( options )
% usage: [output] = make_phcp_methods_table( options )
%
% mps 20210514
%% opts
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 0; % 1 = yes, 0 = no
end
if ~isfield (options, 'subj_group_def')
    options.subj_group_def = 1; % 1 = controls, relatives, probands; 
    % 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 
    % 4 = healthy (con+rel), SZ+SCA, bipolar,
    % 5 = controls, probands, relatives (flip order of P & R)
end

if ~isfield(options,'overwrite_demog_csv')
    options.overwrite_demog_csv = 0; % 1 = yes, 0 = no
end
% if ~isfield(options,'overwrite_psych_csv')
%     options.overwrite_psych_csv = 0; % 1 = yes, 0 = no
% end
if ~isfield(options,'subj_number')
    options.subj_number = []; % empty [] = find all, else provide a vector of numbers
end
if ~isfield(options,'date_number')
    options.date_number = []; % empty [] = find all, else provide a vector of numbers
end

addpath(genpath('E:\GitRepos\SYON.git\Functions'))
addpath(genpath('E:\GitRepos\SYON.git\Demographics'))

output = [];

%% pull data
% summ_opt = [];
% summ_opt.displayFigs = options.displayFigs;
% summ_opt.toss_date = 20170701;
% % summ_opt.toss_date = 20180104; % RK added on Jun 23 2022 to exclude A scans
% summ_out = summarize_pHCP_data_status( summ_opt );
% 
% % toss excluded subj
% toss_me = squeeze(summ_out.failed_binary(:,1,4)==1);
% subj_number = summ_out.all_dataset_list(~toss_me,1);
% date_number = summ_out.all_dataset_list(~toss_me,2);

% Grab all unique SYON subjects
subj_number = options.subj_number;
date_number = options.date_number;

if ~isempty(options.subj_number) && ~isempty(options.date_number)
    if numel(options.subj_number) ~= numel(options.date_number)
        error('number of subjects in options.subj_number does not match number in options.date_number');
    end
elseif isempty(options.subj_number) && ~isempty(options.date_number)
    error('date_numbers but not subj_numbers provided');
elseif isempty(options.date_number) && ~isempty(options.subj_number)
    error('subj_numbers but not date_numbers provided');
end

%% subj group def
% demog_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
% demog_opts.overwrite_demog_csv = options.overwrite_demog_csv;
% temp_demog = read_in_demog_data( demog_opts );
% 
% dx_list = nan(numel(subj_number),1);
% missing_dx_list = [];
% for iSubj = 1:numel(subj_number)
%     dx_idx = strcmp(['P' num2str(subj_number(iSubj))],temp_demog.Record_ID);
%     if sum(dx_idx) == 0 % if this subject isn't in the demographics .csv file
%         missing_dx_list = [missing_dx_list ; subj_number(iSubj)];
%         continue
%     end
%     dx_list(iSubj) = temp_demog.Dx_code(dx_idx);
% end
% output.missing_from_demog_data = missing_dx_list;
% 
% find_not_assigned_dx = ( dx_list == 888 );
% if sum(find_not_assigned_dx) > 0
%     warndlg(['Warning: n = ' num2str(sum(find_not_assigned_dx)) ...
%         ' subjects do not yet have diagnosis info in .csv from RedCap!']);
%     output.dx_not_assigned = subj_number(find_not_assigned_dx);
% end
% 
group_def_opt = [];
group_def_opt.subj_group_def = options.subj_group_def;
group_def_opt.subj_number = subj_number;

group_def_out = run_subj_group_def_SYON( group_def_opt ); % mps 20220127 changing how we use subj group def

use_colors = group_def_out.use_colors;
use_colors_RGB = group_def_out.use_colors_RGB;
g1_idx = group_def_out.g1_idx;
g2_idx = group_def_out.g2_idx;
g3_idx = group_def_out.g3_idx;
g1_label = group_def_out.g1_label;
g2_label = group_def_out.g2_label;
g3_label = group_def_out.g3_label;
g1_short = group_def_out.g1_short;
g2_short = group_def_out.g2_short;
g3_short = group_def_out.g3_short;
corr_colors = group_def_out.corr_colors;


g1_idx_bin = g1_idx;
g2_idx_bin = g2_idx;
g3_idx_bin = g3_idx;
g1_idx = find(g1_idx); % keep binary indices, but also make numeric
g2_idx = find(g2_idx);
g3_idx = find(g3_idx);

%% demographics
demog_opt.subj_number = subj_number;
demog_opt.date_number = date_number;
demog_opt.subj_group_def = options.subj_group_def;
demographics = syon_demographics( demog_opt );


%% make this a matlab table
group_ID = [1; 2; 3];

% group_Ns = [n_unique.g1; n_unique.g2; n_unique.g3];
group_Ns = [length(g1_idx); length(g2_idx); length(g3_idx)];

age_mean = [demographics.Age.g1.mean; ...
    demographics.Age.g2.mean; ...
    demographics.Age.g3.mean];
age_sd = [demographics.Age.g1.sd; ...
    demographics.Age.g2.sd; ...
    demographics.Age.g3.sd];

n_Female = [demographics.Gender.g1.n_female; ...
    demographics.Gender.g2.n_female; ...
    demographics.Gender.g3.n_female];
n_Male = [demographics.Gender.g1.n_male; ...
    demographics.Gender.g2.n_male; ...
    demographics.Gender.g3.n_male];

YrsEd_mean = [demographics.Education.g1.mean ; ...
    demographics.Education.g2.mean ; ...
    demographics.Education.g3.mean];
YrsEd_sd = [demographics.Education.g1.sd ; ...
    demographics.Education.g2.sd ; ...
    demographics.Education.g3.sd];

Acuity_mean = [demographics.Visual_Acuity.g1.mean ; ...
    demographics.Visual_Acuity.g2.mean ; ...
    demographics.Visual_Acuity.g3.mean];
Acuity_sd = [demographics.Visual_Acuity.g1.sd ; ...
    demographics.Visual_Acuity.g2.sd ; ...
    demographics.Visual_Acuity.g3.sd];

IQ_mean = [demographics.Estimated_IQ.g1.mean ; ...
    demographics.Estimated_IQ.g2.mean ; ...
    demographics.Estimated_IQ.g3.mean];
IQ_sd = [demographics.Estimated_IQ.g1.sd ; ...
    demographics.Estimated_IQ.g2.sd ; ...
    demographics.Estimated_IQ.g3.sd];

% n_retest = [n_retest.g1 ; n_retest.g2 ; n_retest.g3];
% 
% days_retest_mean = [time_retest.g1.mean ; time_retest.g2.mean ; time_retest.g3.mean];
% days_retest_sd = [time_retest.g1.sd ; time_retest.g2.sd ; time_retest.g3.sd];

T = table(group_ID, group_Ns, age_mean, age_sd, n_Female, n_Male, ...
    YrsEd_mean, YrsEd_sd, Acuity_mean, Acuity_sd,...
    IQ_mean, IQ_sd);

%% output
% output.summarize_data = summ_out;
output.options = options;
output.subj_number = subj_number;
output.date_number = date_number;
output.group_idx = {g1_idx, g2_idx, g3_idx};
output.group_labels = {g1_label, g2_label, g3_label};
output.demographics = demographics;
% output.symptoms = symptoms;
output.methods_table = T;

end