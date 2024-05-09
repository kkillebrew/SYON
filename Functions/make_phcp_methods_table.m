function [output] = make_phcp_methods_table( options )
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
if ~isfield(options,'overwrite_psych_csv')
    options.overwrite_psych_csv = 0; % 1 = yes, 0 = no
end
if ~isfield(options,'subj_number')
    options.subj_number = []; % empty [] = find all, else provide a vector of numbers
end
if ~isfield(options,'date_number')
    options.date_number = []; % empty [] = find all, else provide a vector of numbers
end

output = [];

%% pull data
summ_opt = [];
summ_opt.displayFigs = options.displayFigs;
summ_opt.toss_date = 20170701;
% summ_opt.toss_date = 20180104; % RK added on Jun 23 2022 to exclude A scans
summ_out = summarize_pHCP_data_status( summ_opt );

% toss excluded subj
toss_me = squeeze(summ_out.failed_binary(:,1,4)==1);
subj_number = summ_out.all_dataset_list(~toss_me,1);
date_number = summ_out.all_dataset_list(~toss_me,2);

if ~isempty(options.subj_number) && ~isempty(options.date_number)
    if numel(options.subj_number) ~= numel(options.date_number)
        error('number of subjects in options.subj_number does not match number in options.date_number');
    end
    keep_subj = [];
    keep_date = [];
    for iS = 1:numel(options.subj_number)
        if sum(subj_number == options.subj_number(iS)) && ...
                sum(date_number == options.date_number(iS))
            keep_subj = [keep_subj ; options.subj_number(iS)];
            keep_date = [keep_date ; options.date_number(iS)];
        else
            warning(['You asked to include ' num2str(options.subj_number(iS)) ' ' ...
                datestr(options.date_number(iS)) ', but this data set was ' ...
                'not found by summarize_pHCP_data_status...']);
        end
    end
    subj_number = keep_subj;
    date_number = keep_date;
elseif isempty(options.subj_number) && ~isempty(options.date_number)
    error('date_numbers but not subj_numbers provided');
elseif isempty(options.date_number) && ~isempty(options.subj_number)
    error('subj_numbers but not date_numbers provided');
end
%% subj group def
demog_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
demog_opts.overwrite_demog_csv = options.overwrite_demog_csv;
temp_demog = read_in_demog_data( demog_opts );

dx_list = nan(numel(subj_number),1);
missing_dx_list = [];
for iSubj = 1:numel(subj_number)
    dx_idx = strcmp(['P' num2str(subj_number(iSubj))],temp_demog.Record_ID);
    if sum(dx_idx) == 0 % if this subject isn't in the demographics .csv file
        missing_dx_list = [missing_dx_list ; subj_number(iSubj)];
        continue
    end
    dx_list(iSubj) = temp_demog.Dx_code(dx_idx);
end
output.missing_from_demog_data = missing_dx_list;

find_not_assigned_dx = ( dx_list == 888 );
if sum(find_not_assigned_dx) > 0
    warndlg(['Warning: n = ' num2str(sum(find_not_assigned_dx)) ...
        ' subjects do not yet have diagnosis info in .csv from RedCap!']);
    output.dx_not_assigned = subj_number(find_not_assigned_dx);
end

group_def_opt = [];
group_def_opt.subj_group_def = options.subj_group_def;
group_def_opt.subj_number = subj_number;

group_def_out = run_subj_group_def( group_def_opt ); % mps 20220127 changing how we use subj group def

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

%% find unique & retest
[unique_subj, idx] = unique(subj_number);
idx_unique = zeros(numel(subj_number),1);
idx_unique(idx) = 1;

[~, unique_g1] = unique(subj_number(g1_idx));
[~, unique_g2] = unique(subj_number(g2_idx));
[~, unique_g3] = unique(subj_number(g3_idx));
unique_g1 = g1_idx(unique_g1);
unique_g2 = g2_idx(unique_g2);
unique_g3 = g3_idx(unique_g3);

n_unique.g1 = numel(unique_g1);
n_unique.g2 = numel(unique_g2);
n_unique.g3 = numel(unique_g3);

% find retest
retest_g1 = ~idx_unique & g1_idx_bin;
retest_g2 = ~idx_unique & g2_idx_bin;
retest_g3 = ~idx_unique & g3_idx_bin;
n_retest.g1 = sum(retest_g1);
n_retest.g2 = sum(retest_g2);
n_retest.g3 = sum(retest_g3);

idx_retest_g1 = find(retest_g1);
idx_retest_g2 = find(retest_g2);
idx_retest_g3 = find(retest_g3);

pair_g1_idx = [];
pair_g2_idx = [];
pair_g3_idx = [];
for iP = 1:numel(idx_retest_g1)
    pair_g1_idx(iP) = find( subj_number == subj_number(idx_retest_g1(iP)) & ...
        date_number ~= date_number(idx_retest_g1(iP)) );
end
for iP = 1:numel(idx_retest_g2)
    pair_g2_idx(iP) = find( subj_number == subj_number(idx_retest_g2(iP)) & ...
        date_number ~= date_number(idx_retest_g2(iP)) );
end
for iP = 1:numel(idx_retest_g3)
    pair_g3_idx(iP) = find( subj_number == subj_number(idx_retest_g3(iP)) & ...
        date_number ~= date_number(idx_retest_g3(iP)) );
end

%RK edited on Jun23, 2022 to include the if statements previously listed
%for g2 for the g1 and g3 data as well.

if sum(retest_g1 ~= 0)
    time_retest.g1.data = abs(date_number(retest_g1) - ...
        date_number(pair_g1_idx)); % -1 to give us 1st scan
else
    time_retest.g1.data = NaN;
end
if sum(retest_g2 ~= 0)
    time_retest.g2.data = abs(date_number(retest_g2) - ...
        date_number(pair_g2_idx)); % -1 to give us 1st scan
else
    time_retest.g2.data = NaN; % -1 to give us 1st scan
end
if sum(retest_g3 ~= 0)
    time_retest.g3.data = abs(date_number(retest_g3) - ...
        date_number(pair_g3_idx)); % -1 to give us 1st scan
else
    time_retest.g3.data = NaN;
end

time_retest.g1.mean = mean(time_retest.g1.data);
time_retest.g1.median = median(time_retest.g1.data);
time_retest.g1.sd = std(time_retest.g1.data);
time_retest.g1.range = [min(time_retest.g1.data) max(time_retest.g1.data)];

time_retest.g2.mean = mean(time_retest.g2.data);
time_retest.g2.median = median(time_retest.g2.data);
time_retest.g2.sd = std(time_retest.g2.data);
time_retest.g2.range = [min(time_retest.g2.data) max(time_retest.g2.data)];

time_retest.g3.mean = mean(time_retest.g3.data);
time_retest.g3.median = median(time_retest.g3.data);
time_retest.g3.sd = std(time_retest.g3.data);
time_retest.g3.range = [min(time_retest.g3.data) max(time_retest.g3.data)];

%% demographics
demog_opt.subj_number = subj_number(logical(idx_unique));
demog_opt.date_number = date_number(logical(idx_unique));
demog_opt.subj_group_def = options.subj_group_def;
demographics = phcp_demographics( demog_opt );

%% now do symptoms
symptom_list = {'Mars contrast','BACS Composite Z Scores',...
    'BPRS Total Score','SGI',...
    'spq total','PID-5 psychoticism','SAPS Total Scores',...
    'SANS Total Scores','cpz'};
symptom_short = {'Mars','BACS','BPRS','SGI','SPQ','PID5','SAPS','SANS','CPZ'};
sym_opt = [];
sym_opt.subj_number = subj_number;
sym_opt.date_number = date_number;

anova_list = {'Mars','BACS'};
kw_list = {'BPRS','SGI','PID5','SPQ'};
if options.subj_group_def == 3    
    kw_list = cat(2, kw_list ,{'SAPS','SANS','CPZ'});
end

all_grp = {'g1','g1','g2';
    'g2','g3','g3'};
all_grp_idx = [1 1 2;
               2 3 3];

for iS = 1:numel(symptom_list)
    sym_opt.symptom_measure = symptom_list{iS};
    sym_opt.overwrite_psych_csv = options.overwrite_psych_csv;
    sym_out = get_phcp_symptoms(sym_opt);
    symptoms.(symptom_short{iS}).data = sym_out.psy_list;
    
    % find group mean, median, sd, range
    group_str = {'g1','g2','g3'};
    group_idx = {unique_g1, unique_g2, unique_g3};
    all_group_idx = [unique_g1; unique_g2; unique_g3];
    
    for iG = 1:3
        symptoms.(symptom_short{iS}).(group_str{iG}).mean = nanmean(symptoms.(...
            symptom_short{iS}).data(group_idx{iG}));
        symptoms.(symptom_short{iS}).(group_str{iG}).median = nanmedian(symptoms.(...
            symptom_short{iS}).data(group_idx{iG}));
        symptoms.(symptom_short{iS}).(group_str{iG}).sd = nanstd(symptoms.(...
            symptom_short{iS}).data(group_idx{iG}));
        symptoms.(symptom_short{iS}).(group_str{iG}).range = [nanmin(symptoms.(...
            symptom_short{iS}).data(group_idx{iG})) nanmax(symptoms.(...
            symptom_short{iS}).data(group_idx{iG}))];
        symptoms.(symptom_short{iS}).(group_str{iG}).n_missing = sum(isnan(symptoms.(...
            symptom_short{iS}).data(group_idx{iG})));
    end
    
    all_data = symptoms.(symptom_short{iS}).data(all_group_idx);
    all_subj = 1:numel(all_data);
    all_group = [ones(numel(unique_g1),1) ; 2*ones(numel(unique_g2),1) ; ...
        3*ones(numel(unique_g3),1)];
    
    if sum(strcmp(symptom_short{iS}, anova_list)) % parameteric test
        % do anova
        nest = zeros(2,2);
        nest(1,2) = 1;
        
        [p, table_an, stats] = anovan(all_data(:),{all_subj(:), all_group(:)},'nested',...
            nest,'random',1,'model','full','varnames',{'subj','group'},'display',...
            'off');
        symptoms.(symptom_short{iS}).stats.all3 = table_an;
            
        for iG = 1:size(all_grp,2)
            all_data = symptoms.(symptom_short{iS}).data([group_idx{...
                all_grp_idx(1,iG)} ; group_idx{all_grp_idx(2,iG)}]);
            all_subj = 1:numel(all_data);
            all_group = [ones(numel(group_idx{all_grp_idx(1,iG)}),1) ; ...
                2*ones(numel(group_idx{all_grp_idx(2,iG)}),1)];

            comp_name = [(all_grp{1,iG}) '_' (all_grp{2,iG})];
            [p, table_an, stats] = anovan(all_data(:),{all_subj(:), all_group(:)},'nested',...
                nest,'random',1,'model','full','varnames',{'subj','group'},'display',...
                'off');
            symptoms.(symptom_short{iS}).stats.(comp_name) = table_an;
        end
    
    elseif sum(strcmp(symptom_short{iS}, kw_list)) % nonparametric test
        [p, table_an, stats] = kruskalwallis(all_data(:), all_group(:),...
            'off');
        symptoms.(symptom_short{iS}).stats.all3 = table_an;
        
        for iG = 1:size(all_grp,2)
            all_data = symptoms.(symptom_short{iS}).data([group_idx{...
                all_grp_idx(1,iG)} ; group_idx{all_grp_idx(2,iG)}]);
            all_group = [ones(numel(group_idx{all_grp_idx(1,iG)}),1) ; ...
                2*ones(numel(group_idx{all_grp_idx(2,iG)}),1)];
            
            comp_name = [(all_grp{1,iG}) '_' (all_grp{2,iG})];
            [p, table_an, stats] = kruskalwallis(all_data(:), all_group(:),...
                'off');
            symptoms.(symptom_short{iS}).stats.(comp_name) = table_an;
        end
        
    else
        warning([symptom_short{iS} ' missing from kw_list and anova_list, skipping...'])
    end
    
end

%% num pRF scans for supp table 2
if isempty(options.subj_number) && isempty(options.date_number)
    % can only do for full list
    output.n_prfs.data = summ_out.n_prfs(~toss_me);
    output.n_prfs.g1.n_1prf = sum(output.n_prfs.data(g1_idx_bin) == 1);
    output.n_prfs.g1.n_2prf = sum(output.n_prfs.data(g1_idx_bin) == 2);
    output.n_prfs.g2.n_1prf = sum(output.n_prfs.data(g2_idx_bin) == 1);
    output.n_prfs.g2.n_2prf = sum(output.n_prfs.data(g2_idx_bin) == 2);
    output.n_prfs.g3.n_1prf = sum(output.n_prfs.data(g3_idx_bin) == 1);
    output.n_prfs.g3.n_2prf = sum(output.n_prfs.data(g3_idx_bin) == 2);
    g1_n_prf = [output.n_prfs.g1.n_1prf ; output.n_prfs.g1.n_2prf];
    g2_n_prf = [output.n_prfs.g2.n_1prf ; output.n_prfs.g2.n_2prf];
    g3_n_prf = [output.n_prfs.g3.n_1prf ; output.n_prfs.g3.n_2prf];
    output.n_prfs.table = table(g1_n_prf, g2_n_prf, g3_n_prf);
else
    warning('skipping n_prfs table, because you provided a custom subject list...');
end
%% make this a matlab table

group_ID = [1; 2; 3];

group_Ns = [n_unique.g1; n_unique.g2; n_unique.g3];

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

pct_Asian = [demographics.Race.g1.pct_Asian_or_Pacific_Islander ; ...
    demographics.Race.g2.pct_Asian_or_Pacific_Islander ; ...
    demographics.Race.g3.pct_Asian_or_Pacific_Islander] .*100 ;
pct_Black = [demographics.Race.g1.pct_Black_not_of_Hispanic_Origin ; ...
    demographics.Race.g2.pct_Black_not_of_Hispanic_Origin ; ...
    demographics.Race.g3.pct_Black_not_of_Hispanic_Origin] .*100 ;
pct_Hispanic = [demographics.Race.g1.pct_Hispanic ; ...
    demographics.Race.g2.pct_Hispanic ; ...
    demographics.Race.g3.pct_Hispanic] .*100 ;
pct_NativeAm = [demographics.Race.g1.pct_American_Indian_or_Alaskan_Native ; ...
    demographics.Race.g2.pct_American_Indian_or_Alaskan_Native ; ...
    demographics.Race.g3.pct_American_Indian_or_Alaskan_Native] .*100 ;
pct_White = [demographics.Race.g1.pct_White_not_of_Hispanic_Origin ; ...
    demographics.Race.g2.pct_White_not_of_Hispanic_Origin ; ...
    demographics.Race.g3.pct_White_not_of_Hispanic_Origin] .*100 ;
pct_Other = [demographics.Race.g1.pct_Other ; ...
    demographics.Race.g2.pct_Other ; ...
    demographics.Race.g3.pct_Other] .*100 ;

YrsEd_mean = [demographics.Education.g1.mean ; ...
    demographics.Education.g2.mean ; ...
    demographics.Education.g3.mean];
YrsEd_sd = [demographics.Education.g1.sd ; ...
    demographics.Education.g2.sd ; ...
    demographics.Education.g3.sd];

BMI_mean = [demographics.BMI.g1.mean ; ...
    demographics.BMI.g2.mean ; ...
    demographics.BMI.g3.mean];
BMI_sd = [demographics.BMI.g1.sd ; ...
    demographics.BMI.g2.sd ; ...
    demographics.BMI.g3.sd];

Acuity_mean = [demographics.Visual_Acuity.g1.mean ; ...
    demographics.Visual_Acuity.g2.mean ; ...
    demographics.Visual_Acuity.g3.mean];
Acuity_sd = [demographics.Visual_Acuity.g1.sd ; ...
    demographics.Visual_Acuity.g2.sd ; ...
    demographics.Visual_Acuity.g3.sd];

MARS_mean = [symptoms.Mars.g1.mean ; ...
    symptoms.Mars.g2.mean ; ...
    symptoms.Mars.g3.mean];
MARS_sd = [symptoms.Mars.g1.sd ; ...
    symptoms.Mars.g2.sd ; ...
    symptoms.Mars.g3.sd];

IQ_mean = [demographics.Estimated_IQ.g1.mean ; ...
    demographics.Estimated_IQ.g2.mean ; ...
    demographics.Estimated_IQ.g3.mean];
IQ_sd = [demographics.Estimated_IQ.g1.sd ; ...
    demographics.Estimated_IQ.g2.sd ; ...
    demographics.Estimated_IQ.g3.sd];

BACS_mean = [symptoms.BACS.g1.mean ; ...
    symptoms.BACS.g2.mean ; ...
    symptoms.BACS.g3.mean];
BACS_sd = [symptoms.BACS.g1.sd ; ...
    symptoms.BACS.g2.sd ; ...
    symptoms.BACS.g3.sd];

BPRS_mean = [symptoms.BPRS.g1.mean ; ...
    symptoms.BPRS.g2.mean ; ...
    symptoms.BPRS.g3.mean];
BPRS_sd = [symptoms.BPRS.g1.sd ; ...
    symptoms.BPRS.g2.sd ; ...
    symptoms.BPRS.g3.sd];

SGI_mean = [symptoms.SGI.g1.mean ; ...
    symptoms.SGI.g2.mean ; ...
    symptoms.SGI.g3.mean];
SGI_sd = [symptoms.SGI.g1.sd ; ...
    symptoms.SGI.g2.sd ; ...
    symptoms.SGI.g3.sd];

SPQ_mean = [symptoms.SPQ.g1.mean ; ...
    symptoms.SPQ.g2.mean ; ...
    symptoms.SPQ.g3.mean];
SPQ_sd = [symptoms.SPQ.g1.sd ; ...
    symptoms.SPQ.g2.sd ; ...
    symptoms.SPQ.g3.sd];

PID5_psy_mean = [symptoms.PID5.g1.mean ; ...
    symptoms.PID5.g2.mean ; ...
    symptoms.PID5.g3.mean];
PID5_psy_sd = [symptoms.PID5.g1.sd ; ...
    symptoms.PID5.g2.sd ; ...
    symptoms.PID5.g3.sd];

SAPS_mean = [symptoms.SAPS.g1.mean ; ...
    symptoms.SAPS.g2.mean ; ...
    symptoms.SAPS.g3.mean];
SAPS_sd = [symptoms.SAPS.g1.sd ; ...
    symptoms.SAPS.g2.sd ; ...
    symptoms.SAPS.g3.sd];

SANS_mean = [symptoms.SANS.g1.mean ; ...
    symptoms.SANS.g2.mean ; ...
    symptoms.SANS.g3.mean];
SANS_sd = [symptoms.SANS.g1.sd ; ...
    symptoms.SANS.g2.sd ; ...
    symptoms.SANS.g3.sd];

CPZ_mean = [symptoms.CPZ.g1.mean ; ...
    symptoms.CPZ.g2.mean ; ...
    symptoms.CPZ.g3.mean];
CPZ_sd = [symptoms.CPZ.g1.sd ; ...
    symptoms.CPZ.g2.sd ; ...
    symptoms.CPZ.g3.sd];

n_SZ = [demographics.Diagnosis.g1.n_SZ ; ...
    demographics.Diagnosis.g2.n_SZ ; ...
    demographics.Diagnosis.g3.n_SZ];
n_SCA = [demographics.Diagnosis.g1.n_SCA ; ...
    demographics.Diagnosis.g2.n_SCA ; ...
    demographics.Diagnosis.g3.n_SCA];
n_BP = [demographics.Diagnosis.g1.n_BP ; ...
    demographics.Diagnosis.g2.n_BP ; ...
    demographics.Diagnosis.g3.n_BP];
n_PNOS = [demographics.Diagnosis.g1.n_psyNOS ; ...
    demographics.Diagnosis.g2.n_psyNOS ; ...
    demographics.Diagnosis.g3.n_psyNOS];
n_Other = [demographics.Diagnosis.g1.n_other ; ...
    demographics.Diagnosis.g2.n_other ; ...
    demographics.Diagnosis.g3.n_other];
n_None = [demographics.Diagnosis.g1.n_none ; ...
    demographics.Diagnosis.g2.n_none ; ...
    demographics.Diagnosis.g3.n_none];

rel_SZ = [demographics.Relatives_dx.g1.n_SZ ; ...
    demographics.Relatives_dx.g2.n_SZ ; ...
    demographics.Relatives_dx.g3.n_SZ];
rel_SCA = [demographics.Relatives_dx.g1.n_SCA ; ...
    demographics.Relatives_dx.g2.n_SCA ; ...
    demographics.Relatives_dx.g3.n_SCA];
rel_BP = [demographics.Relatives_dx.g1.n_BP ; ...
    demographics.Relatives_dx.g2.n_BP ; ...
    demographics.Relatives_dx.g3.n_BP];
rel_PNOS = [demographics.Relatives_dx.g1.n_psyNOS ; ...
    demographics.Relatives_dx.g2.n_psyNOS ; ...
    demographics.Relatives_dx.g3.n_psyNOS];
rel_Other = [demographics.Relatives_dx.g1.n_other ; ...
    demographics.Relatives_dx.g2.n_other ; ...
    demographics.Relatives_dx.g3.n_other];
rel_None = [demographics.Relatives_dx.g1.n_none ; ...
    demographics.Relatives_dx.g2.n_none ; ...
    demographics.Relatives_dx.g3.n_none];

days3T7T_mean = [demographics.Time_since_3T.g1.mean ; ...
    demographics.Time_since_3T.g2.mean ; ...
    demographics.Time_since_3T.g3.mean];
days3T7T_sd = [demographics.Time_since_3T.g1.sd ; ...
    demographics.Time_since_3T.g2.sd ; ...
    demographics.Time_since_3T.g3.sd];

n_retest = [n_retest.g1 ; n_retest.g2 ; n_retest.g3];

days_retest_mean = [time_retest.g1.mean ; time_retest.g2.mean ; time_retest.g3.mean];
days_retest_sd = [time_retest.g1.sd ; time_retest.g2.sd ; time_retest.g3.sd];

T = table(group_ID, group_Ns, age_mean, age_sd, n_Female, n_Male, ...
    pct_Asian, pct_Black, pct_Hispanic, pct_NativeAm, pct_White, pct_Other, ...
    YrsEd_mean, YrsEd_sd, BMI_mean, BMI_sd, Acuity_mean, Acuity_sd, MARS_mean, MARS_sd, ...
    IQ_mean, IQ_sd, BACS_mean, BACS_sd, BPRS_mean, BPRS_sd, SGI_mean, SGI_sd, ...
    SPQ_mean, SPQ_sd, PID5_psy_mean, PID5_psy_sd, SAPS_mean, SAPS_sd, ...
    SANS_mean, SANS_sd, CPZ_mean, CPZ_sd, n_SZ, n_SCA, n_BP, n_PNOS, n_Other, n_None, rel_SZ, ...
    rel_SCA, rel_BP, rel_PNOS, rel_Other, rel_None, days3T7T_mean, days3T7T_sd, ...
    n_retest, days_retest_mean, days_retest_sd);

%% output
output.summarize_data = summ_out;
output.options = options;
output.subj_number = subj_number;
output.date_number = date_number;
output.group_idx = {g1_idx, g2_idx, g3_idx};
output.group_labels = {g1_label, g2_label, g3_label};
output.n_unique = n_unique;
output.n_retest = n_retest;
output.time_retest = time_retest;
output.demographics = demographics;
output.symptoms = symptoms;
output.methods_table = T;

end
