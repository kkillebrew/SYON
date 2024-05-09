function [output] = syon_demographics(options)
% [output] = phcp_demographics(options)
%
% options - structure with fields:
%   - subj_number -- a column vector (n x 1) of subject numbers to include
%   - subj_group_def -- a scalar value, where  1 = controls, relatives, probands; 
%                       2 = controls, SZ, BP, 3 = SZ, schizoaffective (SCA), BP;
%                       4 = healthy (con+rel), SZ+SCA, bipolar
%   - date_number -- a column vector (n x 1) of date numbers for scan dates
%
% output - structure with lots of fields...
%
% Created using code from phcp_demographics and read_in_demog_data by RK
% and MPS
%
% KWK - 20230502
%
%% opt
if ~exist('options','var')
    options = [];
end
if ~isfield (options, 'subj_group_def')
    options.subj_group_def = 1; % 1 = controls, relatives, probands; 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 4 = healthy (con+rel),
    % SZ+SCA, bipolar,
end
if ~isfield (options, 'subj_number')
    error('no options.subj_number (list) provided!');
else
    subj_number = options.subj_number;
end
if ~isfield(options,'date_number')
    error('No options.date_number list provided.');
else
    date_number = options.date_number;
end
if numel(subj_number) ~= numel(date_number)
    error('Number of elements in options.subj_number is not equal to that in options.date_number.');
end
if ~isfield (options, 'overwrite_demog_csv')
    options.overwrite_demog_csv = 1;
    % Equals 1 if new csv is present and needs to be overwritten
end
% if ~isfield(options,'overwrite_psych_csv')
%     options.overwrite_psych_csv = 0;
%     % Would be 1 if new csv is present and needs to be overwritten
% end
if ~isfield (options, 'flag_unique')
    options.flag_unique = 0;
    % provide 1 if you want to flag non-unique subject IDs; added 28Mar2021
end

%% figure out groups
% Subject group indices (from refit_COP_dataRK) added by HM 30 OCT 2019
% RK editing on 28March2021 to add check for unique subjects

if options.flag_unique == 1
    [unique_list, subj_hold] = unique(subj_number);
    subj_f = 1:numel(subj_number);
    unique_idx = subj_f(subj_hold);
    
    if numel(unique_list) ~= numel(subj_number)
        str = questdlg ('Subj_number list provided contains non-unique IDs (Might be 2 part scan). Use non-unique list of subjects?');
        switch str
            case 'Yes'
                subj_number = subj_number(unique_idx);
                date_number = date_number(unique_idx);
            case 'Cancel'
                error('Decide between demographics for unique or non-unique subject IDs');
        end
    end
end

h_wait = waitbar(0, 'reading demographic data, please wait...');

demog_opts = [];
demog_opts.target_file = 'E:/GitRepos/SYON.git/Demographics/SYON-3TDemographics_DATA_LABELS_2024-04-29_0027.csv';
if options.overwrite_demog_csv == 1
    demog_opts.overwrite_demog_csv = 1;
end
demog_data = read_in_demog_data_syon(demog_opts);

% create demogrphic lists
dx_list = nan(numel(subj_number),1);
missing_dx_list = [];
gender_list = nan(numel(subj_number),1);
age_list = nan(numel(subj_number),1);
IQ_list = nan(numel(subj_number),1);
edu_list = nan(numel(subj_number),1);
acuity_list = nan(numel(subj_number),1);
race_list = nan(numel(subj_number),1);
% rel_code_list = nan(numel(subj_number),1);
% BMI_list = nan(numel(subj_number),1);

% Seperate out lists for Clinical (demographics) and MRI (vis acuity) to prevent repeats
demog_data_clin = demog_data(strcmp(demog_data.Event_Name(:),'Clinical '),:);
demog_data_mri  = demog_data(strcmp(demog_data.Event_Name(:),'MRI '),:);

% Grab demo data for each subject
for iSubj = 1:numel(subj_number)
    
    dx_idx = strcmp(['S' num2str(subj_number(iSubj))],demog_data_clin.Record_ID);
    if sum(dx_idx) == 0 % if this subject isn't in the demographics .csv file
        % mps fixing 20200223, needs to be sum == 0
        missing_dx_list = [missing_dx_list ; subj_number(iSubj)];
    end
    dx_list(iSubj) = demog_data_clin.Dx_code(dx_idx);
    
    if iscell(demog_data_clin.Gender(dx_idx))
        if strcmp(lower(demog_data_clin.Gender(dx_idx)),'female')
            gender_list(iSubj) = 1;
        elseif strcmp(lower(demog_data_clin.Gender(dx_idx)),'male')
            gender_list(iSubj) = 0;
        end
    else
        gender_list(iSubj) = demog_data_clin.Gender(dx_idx);
    end
    
    if iscell(demog_data_clin.Race(dx_idx))
        if strcmp(demog_data_clin.Race(dx_idx), 'American Indian or Alaskan Native')
            race_list(iSubj) = 0;
        elseif strcmp(demog_data_clin.Race(dx_idx), 'Asian or Pacific Islander')
            race_list(iSubj) = 1;
        elseif strcmp(demog_data_clin.Race(dx_idx), 'Black, not of Hispanic Origin')
            race_list(iSubj) = 2;
        elseif strcmp(demog_data_clin.Race(dx_idx), 'Hispanic')
            race_list(iSubj) = 3;
        elseif strcmp(demog_data_clin.Race(dx_idx), 'White, not of Hispanic Origin')
            race_list(iSubj) = 4;
        elseif strcmp(demog_data_clin.Race(dx_idx), 'Other')
            race_list(iSubj) = 5;
        end
    else
        race_list(iSubj) = demog_data_clin.Race(dx_idx);
    end
        
    IQ_list(iSubj) = demog_data_clin.Estimated_IQ(dx_idx);
    edu_list(iSubj) = demog_data_clin.Education(dx_idx);
                
    % Now do age correction
    % RK added in Jan 2021, to correct for ages since scans were done
    % generally a while after the clinical demographic information
    % acquisition
    % Birth year was estimated, before scan year was used to determine
    % their age at clinical versus their age at scan time
    yr_of_clinical = char(demog_data_clin.DemogDate(dx_idx));
    
    if isempty(yr_of_clinical) %RK added on 2021Mar21 to accomodate for datasets without up to date demog info
        age_list(iSubj) = demog_data_clin.Age(dx_idx);
    end
        
    yr_of_clinical = yr_of_clinical(1:4);
    birth_year = str2num(yr_of_clinical) - demog_data_clin.Age(dx_idx);
    scan_year = datestr(date_number(iSubj),'yyyy');
    age_list(iSubj) = str2num(scan_year) - birth_year;
    
    
    % Now check acuity data from MRI demog data
    psy_idx = (strcmp({['S' num2str(subj_number(iSubj))]},demog_data_mri.Record_ID));
    if sum(psy_idx) == 0 % if this subject isn't in the demographics .csv file
        % mps fixing 20200223, needs to be sum == 0
        missing_acuity_list = [missing_acuity_list ; subj_number(iSubj)];
        continue
        
    elseif sum(psy_idx) > 1 % more than 1 data set, take second instance
        psy_idx = (strcmp({['S' num2str(subj_number(iSubj))]},demog_data_mri.Record_ID)) &...
            demog_data_mri.RepeatInstance==2;
    end
    
    acuity_list(iSubj) = 20 ./ demog_data_mri.SnellenScoreDenominator(psy_idx);

    waitbar(iSubj/numel(subj_number),h_wait);
    
    
end


if max(gender_list) == 2
    gender_list = gender_list - 1; % mps 20211129 re-code so 0 = male, 1 = female, rather than 1 and 2
end

if size(dx_list) ~= size(subj_number)
    subj_number = reshape(subj_number, [size(subj_number,2) size(subj_number,1)]);
end

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

g1_idx = reshape(g1_idx,[numel(g1_idx) 1]);
g2_idx = reshape(g2_idx,[numel(g2_idx) 1]);
g3_idx = reshape(g3_idx,[numel(g3_idx) 1]);

close(h_wait);


%% calculate demographics
demog_list = {'Gender','Age','Estimated_IQ','Education','Visual_Acuity'};
use_list = {gender_list, age_list, IQ_list, edu_list, acuity_list};

use_group = {'g1','g2','g3','all'};
use_group_idx = {g1_idx, g2_idx, g3_idx, [g1_idx ; g2_idx ; g3_idx]};

for iD = 1:numel(demog_list)
    for iG = 1:numel(use_group)
        
        output.(demog_list{iD}).(use_group{iG}).data = use_list{iD}(...
            use_group_idx{iG});
        
        if strcmp('Gender',demog_list{iD})
            output.(demog_list{iD}).(use_group{iG}).n_male = ...
                sum(use_list{iD}(use_group_idx{iG}) == 0);
            
            output.(demog_list{iD}).(use_group{iG}).pct_male = ...
                output.(demog_list{iD}).(use_group{iG}).n_male/numel(use_group_idx{iG});
            
            output.(demog_list{iD}).(use_group{iG}).n_female = ...
                sum(use_list{iD}(use_group_idx{iG}) == 1);
            
            output.(demog_list{iD}).(use_group{iG}).pct_female = ...
                output.(demog_list{iD}).(use_group{iG}).n_female/numel(use_group_idx{iG});
            
            output.(demog_list{iD}).(use_group{iG}).n_missing = ...
                sum(isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_missing = ...
                output.(demog_list{iD}).(use_group{iG}).n_missing/numel(use_group_idx{iG});
            
        
        else
            output.(demog_list{iD}).(use_group{iG}).mean = nanmean(...
                use_list{iD}(use_group_idx{iG}));
            
            output.(demog_list{iD}).(use_group{iG}).sd = nanstd(...
                use_list{iD}(use_group_idx{iG}));
            
            output.(demog_list{iD}).(use_group{iG}).median = nanmedian(...
                use_list{iD}(use_group_idx{iG}));
            
            output.(demog_list{iD}).(use_group{iG}).range = ...
                [min(use_list{iD}(use_group_idx{iG})) ...
                max(use_list{iD}(use_group_idx{iG}))];
            
            output.(demog_list{iD}).(use_group{iG}).n_missing = sum(...
                isnan(use_list{iD}(use_group_idx{iG})));
        end

    end
    % then do stats
    if strcmp('Gender',demog_list{iD})
        n_categories = 3; yates_correction = 0;
        data_table = [output.(demog_list{iD}).g1.n_male ...
            output.(demog_list{iD}).g2.n_male output.(demog_list{iD}).g3.n_male ;...
            output.(demog_list{iD}).g1.n_female output.(demog_list{iD}).g2.n_female ...
            output.(demog_list{iD}).g3.n_female];
        output.(demog_list{iD}).stats = mpsContingencyTable(n_categories, ...
            data_table, yates_correction);
    else
        all_data = use_list{iD}([g1_idx ; g2_idx ; g3_idx]);
        all_subj = [1:numel([g1_idx ; g2_idx ; g3_idx])]';
        all_group = [ones(numel(g1_idx),1) ; 2*ones(numel(g2_idx),1) ; ...
            3*ones(numel(g3_idx),1)];
        nest = zeros(2,2);
        nest(1,2)=1;
        
        [p, output.(demog_list{iD}).stats] = anovan(all_data(:), {all_subj(:),...
            all_group(:)}, 'nested', nest, 'random', 1, 'varnames', {'subj',...
            'group'}, 'display', 'off');
    end
end



end