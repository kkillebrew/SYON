function [output] = phcp_demographics(options)
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
% mps 20191109
% rk edited on 2021jan20 to include a save function for some of the
% demographic variables to reduce run time
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
    options.overwrite_demog_csv = 0;
    % Equals 1 if new csv is present and needs to be overwritten
end
if ~isfield(options,'overwrite_psych_csv')
    options.overwrite_psych_csv = 0;
    % Would be 1 if new csv is present and needs to be overwritten
end
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
        str = questdlg ('Subj_number list provided contains non-unique IDs (Might be Z scans). Use non-unique list of subjects?');
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
demog_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
if options.overwrite_demog_csv == 1
    demog_opts.overwrite_demog_csv = 1;
end
demog_data = read_in_demog_data(demog_opts);

dx_list = nan(numel(subj_number),1);
missing_dx_list = [];
gender_list = nan(numel(subj_number),1);
age_list = nan(numel(subj_number),1);
IQ_list = nan(numel(subj_number),1);
edu_list = nan(numel(subj_number),1);
acuity_list = nan(numel(subj_number),1);
race_list = nan(numel(subj_number),1);
date_3T_list = nan(numel(subj_number),1);
rel_code_list = nan(numel(subj_number),1);
BMI_list = nan(numel(subj_number),1);

visual_acuity.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIPsych.csv';
if options.overwrite_psych_csv == 1
    visual_acuity.overwrite_psych_csv = 1;
end

addpath(genpath('/home/shaw-raid1/matlab_tools/COP_analysis.git/'))
psych_data = read_in_psych_data(visual_acuity);
acuity_data = psych_data.snellen_denom_v2; %SS is Snellen Score
missing_acuity_list = [];
 
for iSubj = 1:numel(subj_number)
    
    dx_idx = strcmp(['P' num2str(subj_number(iSubj))],demog_data.Record_ID);
    if sum(dx_idx) == 0 % if this subject isn't in the demographics .csv file
        % mps fixing 20200223, needs to be sum == 0
        missing_dx_list = [missing_dx_list ; subj_number(iSubj)];
        continue
    end
    dx_list(iSubj) = demog_data.Dx_code(dx_idx);
    
    if iscell(demog_data.Gender(dx_idx))
        if strcmp(lower(demog_data.Gender(dx_idx)),'female')
            gender_list(iSubj) = 1;
        elseif strcmp(lower(demog_data.Gender(dx_idx)),'male')
            gender_list(iSubj) = 0;
        end
    else
        gender_list(iSubj) = demog_data.Gender(dx_idx);
    end
    
    if iscell(demog_data.Race(dx_idx))
        if strcmp(demog_data.Race(dx_idx), 'American Indian or Alaskan Native')
            race_list(iSubj) = 0;
        elseif strcmp(demog_data.Race(dx_idx), 'Asian or Pacific Islander')
            race_list(iSubj) = 1;
        elseif strcmp(demog_data.Race(dx_idx), 'Black, not of Hispanic Origin')
            race_list(iSubj) = 2;
        elseif strcmp(demog_data.Race(dx_idx), 'Hispanic')
            race_list(iSubj) = 3;
        elseif strcmp(demog_data.Race(dx_idx), 'White, not of Hispanic Origin')
            race_list(iSubj) = 4;
        elseif strcmp(demog_data.Race(dx_idx), 'Other')
            race_list(iSubj) = 5;
        end
    else
        race_list(iSubj) = demog_data.Race(dx_idx);
    end
        
    IQ_list(iSubj) = demog_data.Estimated_IQ(dx_idx);
    edu_list(iSubj) = demog_data.Education(dx_idx);
    
    date_3T_list(iSubj) = date_number(iSubj) - demog_data.Date_3T_final(dx_idx);
    
    rel_code_list(iSubj) = demog_data.Rel_code(dx_idx);
    
    BMI_list(iSubj) = demog_data.bm_bmi(dx_idx);
    
    % Now do age correction
    % RK added in Jan 2021, to correct for ages since scans were done
    % generally a while after the clinical demographic information
    % acquisition
    % Birth year was estimated, before scan year was used to determine
    % their age at clinical versus their age at scan time
    
    yr_of_clinical = char(demog_data.DemogDate(dx_idx));
    
    if isempty(yr_of_clinical) %RK added on 2021Mar21 to accomodate for datasets without up to date demog info
        age_list(iSubj) = demog_data.Age(dx_idx);
        continue
    end
        
    yr_of_clinical = yr_of_clinical(1:4);
    birth_year = str2num(yr_of_clinical) - demog_data.Age(dx_idx);
    scan_year = datestr(date_number(iSubj),'yyyy');
    age_list(iSubj) = str2num(scan_year) - birth_year;
    
    % Now check acuity data from psych csv - match it to specific 7T
    % day
    
    psy_idx = (strcmp(['P' num2str(subj_number(iSubj))],psych_data.record_id) & ...
        eq(date_number(iSubj),cell2mat(psych_data.datenumber)));
    if sum(psy_idx) == 0 % if this subject isn't in the demographics .csv file
        % mps fixing 20200223, needs to be sum == 0
        missing_acuity_list = [missing_acuity_list ; subj_number(iSubj)];
        continue
        
    elseif sum(psy_idx) > 1 % more than 1 data set on the same date??
        find_idx = find(psy_idx);
        error(['More than one data set for ' psych_data.record_id(find_idx(1)) ...
            ' on the same date??? check record IDs = ' num2str(find_idx)]);
    end
    
    acuity_list(iSubj) = 20 ./ acuity_data(psy_idx);

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

[~, g1_unique] = unique(subj_number(g1_idx));
[~, g2_unique] = unique(subj_number(g2_idx));
[~, g3_unique] = unique(subj_number(g3_idx));

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
demog_list = {'Gender','Age','Estimated_IQ','Education','Visual_Acuity',...
    'Diagnosis','Race','Time_since_3T','Relatives_dx','BMI'};
% demog_list = {'Gender','Age','Estimated_IQ','Education','Diagnosis','Race','Time_since_3T'};   % KWK removed VisAcuity as it was causing errors - 20210601
use_list = {gender_list, age_list, IQ_list, edu_list, acuity_list, ...
    dx_list, race_list, date_3T_list, rel_code_list, BMI_list };

use_group = {'g1','g2','g3','all'};
use_group_idx = {g1_idx, g2_idx, g3_idx, [g1_idx ; g2_idx ; g3_idx]};

% check sorting subject number, give a warning
output.subj_number = subj_number([g1_idx ; g2_idx ; g3_idx]);
output.date_number = date_number([g1_idx ; g2_idx ; g3_idx]);

change_num = 0;
if numel(output.subj_number) ~= numel(subj_number)
    change_num = 1;
else
    diff_num = abs(output.subj_number - subj_number);
    if sum(diff_num) > 0
        change_num = 1;
    end
end
if change_num
    warndlg('NOTE: the number / order of subject numbers has changed between input and output of phcp_demographics!');
end


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
            
        elseif strcmp('Race',demog_list{iD})
            %Legend for race can be seen above
            
            output.(demog_list{iD}).(use_group{iG}).n_American_Indian_or_Alaskan_Native = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 0);
            
            output.(demog_list{iD}).(use_group{iG}).n_Asian_or_Pacific_Islander = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 1);
            
            output.(demog_list{iD}).(use_group{iG}).n_Black_not_of_Hispanic_Origin = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 2);
            
            output.(demog_list{iD}).(use_group{iG}).n_Hispanic = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 3);
            
            output.(demog_list{iD}).(use_group{iG}).n_White_not_of_Hispanic_Origin = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 4);
            
            output.(demog_list{iD}).(use_group{iG}).n_Other = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 5);
            
            output.(demog_list{iD}).(use_group{iG}).n_missing = ... 
                sum(isnan(use_list{iD}(use_group_idx{iG})));
                        
            output.(demog_list{iD}).(use_group{iG}).pct_American_Indian_or_Alaskan_Native = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 0) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_Asian_or_Pacific_Islander = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 1) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_Black_not_of_Hispanic_Origin = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 2) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_Hispanic = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 3) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_White_not_of_Hispanic_Origin = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 4) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_Other = ... 
                sum(use_list{iD}(use_group_idx{iG}) == 5) / sum(~isnan(use_list{iD}(use_group_idx{iG})));
            
            output.(demog_list{iD}).(use_group{iG}).pct_missing = ... 
                sum(isnan(use_list{iD}(use_group_idx{iG}))) / numel(use_list{iD}(use_group_idx{iG}));
            
        elseif strcmp('Diagnosis',demog_list{iD})
            %Legend for dx codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
            %6=Panic; 7=DeprNOS; 8=PsychNOS / schizophreniform; 9=ADHD, 
            %10 = alcohol, 11 = canabis / substance abuse
            
            output.(demog_list{iD}).(use_group{iG}).n_SZ = ...
                sum(use_list{iD}(use_group_idx{iG}) == 2);
            
            output.(demog_list{iD}).(use_group{iG}).n_SCA = ...
                sum(use_list{iD}(use_group_idx{iG}) == 3);
            
            output.(demog_list{iD}).(use_group{iG}).n_BP = ...
                sum( use_list{iD}(use_group_idx{iG}) == 4 | ...
                use_list{iD}(use_group_idx{iG}) == 5 );
            
            output.(demog_list{iD}).(use_group{iG}).n_psyNOS = ...
                sum( use_list{iD}(use_group_idx{iG}) == 8 );

            output.(demog_list{iD}).(use_group{iG}).n_other = ...
                sum( use_list{iD}(use_group_idx{iG}) == 1 | ...
                use_list{iD}(use_group_idx{iG}) == 6 | ...
                use_list{iD}(use_group_idx{iG}) == 7 | ...
                use_list{iD}(use_group_idx{iG}) == 9 | ...
                use_list{iD}(use_group_idx{iG}) == 10 | ...
                use_list{iD}(use_group_idx{iG}) == 11 );
            
            output.(demog_list{iD}).(use_group{iG}).n_none = ...
                sum(use_list{iD}(use_group_idx{iG}) == 0);
            
            output.(demog_list{iD}).(use_group{iG}).n_missing = ...
                sum( isnan(use_list{iD}(use_group_idx{iG})) | ...
                use_list{iD}(use_group_idx{iG}) == 888 );
            
        elseif strcmp('Relatives_dx',demog_list{iD})
            output.(demog_list{iD}).(use_group{iG}).n_SZ = ...
                sum(use_list{iD}(use_group_idx{iG}) == 1); 
            % mps 2022.08.07 found that relative dx code changed?
            % 1 = sz, 2 = sca bp, 3 = sca dep, 4 = bp
            % i.e., not the same code as for patient diagnosis
            % confirmed in RedCap
            
            output.(demog_list{iD}).(use_group{iG}).n_SCA = ...
                sum( (use_list{iD}(use_group_idx{iG}) == 2 | ...
                use_list{iD}(use_group_idx{iG}) == 3 ) ); 
            % mps 2022.08.07 found that relative dx code changed?
            
            output.(demog_list{iD}).(use_group{iG}).n_BP = ...
                sum( use_list{iD}(use_group_idx{iG}) == 4 );
            % mps 2022.08.07 found that relative dx code changed?

            output.(demog_list{iD}).(use_group{iG}).n_psyNOS = ...
                sum( use_list{iD}(use_group_idx{iG}) == 8 );

            output.(demog_list{iD}).(use_group{iG}).n_other = ...
                sum( use_list{iD}(use_group_idx{iG}) == 6 | ...
                use_list{iD}(use_group_idx{iG}) == 7 | ...
                use_list{iD}(use_group_idx{iG}) == 9 | ...
                use_list{iD}(use_group_idx{iG}) == 10 | ...
                use_list{iD}(use_group_idx{iG}) == 11 );
            % mps 2022.08.07 found that relative dx code changed?
            
            output.(demog_list{iD}).(use_group{iG}).n_none = ...
                sum(use_list{iD}(use_group_idx{iG}) == 0);
            
            output.(demog_list{iD}).(use_group{iG}).n_missing = ...
                sum(isnan(use_list{iD}(use_group_idx{iG})));
            
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
    all_grp = {'g1','g1','g2';
                'g2','g3','g3'};
    all_grp_idx = {g1_idx,g1_idx,g2_idx;
                g2_idx,g3_idx,g3_idx};
    
    if strcmp('Gender',demog_list{iD})
        n_categories = 3; yates_correction = 0;
        data_table = [output.(demog_list{iD}).g1.n_male ...
            output.(demog_list{iD}).g2.n_male output.(demog_list{iD}).g3.n_male ;...
            output.(demog_list{iD}).g1.n_female output.(demog_list{iD}).g2.n_female ...
            output.(demog_list{iD}).g3.n_female];
        output.(demog_list{iD}).stats.all3 = mpsContingencyTable(n_categories, ...
            data_table, yates_correction);
        
        for iG = 1:size(all_grp,2)
            n_categories = 2; yates_correction = 1;
            data_table = [output.(demog_list{iD}).(all_grp{1,iG}).n_male ...
                output.(demog_list{iD}).(all_grp{2,iG}).n_male ;...
                output.(demog_list{iD}).(all_grp{1,iG}).n_female ...
                output.(demog_list{iD}).(all_grp{2,iG}).n_female];
            comp_name = [(all_grp{1,iG}) '_' (all_grp{2,iG})];
            output.(demog_list{iD}).stats.(comp_name) = mpsContingencyTable(n_categories, ...
                data_table, yates_correction);
        end
        
    elseif strcmp('Diagnosis',demog_list{iD}) || strcmp('Race',demog_list{iD}) || ...
            strcmp('Relatives_dx',demog_list{iD})
        output.(demog_list{iD}).stats = 'N / A';
        
    elseif strcmp('BMI',demog_list{iD})
        % you better not use non-unique data!
        all_data = use_list{iD}([g1_idx ; g2_idx ; g3_idx]);
        all_group = [ones(numel(g1_idx),1) ; 2*ones(numel(g2_idx),1) ; ...
            3*ones(numel(g3_idx),1)];
        
        [p, output.(demog_list{iD}).stats.all3] = kruskalwallis(all_data(:), ...
            all_group(:), 'off');
        
        for iG = 1:size(all_grp,2)
            all_data = use_list{iD}([all_grp_idx{1,iG} ; ...
                all_grp_idx{2,iG}]);
            all_group = [ones(numel(all_grp_idx{1,iG}),1) ; ...
                2*ones(numel(all_grp_idx{2,iG}),1)];
            
            comp_name = [(all_grp{1,iG}) '_' (all_grp{2,iG})];
            [p, output.(demog_list{iD}).stats.(comp_name)] = kruskalwallis(all_data(:), ...
                all_group(:), 'off');
        end
        
    else
        all_data = use_list{iD}([g1_idx ; g2_idx ; g3_idx]);
        all_subj = [1:numel([g1_idx ; g2_idx ; g3_idx])]';
        all_group = [ones(numel(g1_idx),1) ; 2*ones(numel(g2_idx),1) ; ...
            3*ones(numel(g3_idx),1)];
        nest = zeros(2,2);
        nest(1,2)=1;
        
        [p, output.(demog_list{iD}).stats.all3] = anovan(all_data(:), {all_subj(:),...
            all_group(:)}, 'nested', nest, 'random', 1, 'varnames', {'subj',...
            'group'}, 'display', 'off');
        
        for iG = 1:size(all_grp,2)
            all_data = use_list{iD}([all_grp_idx{1,iG} ; all_grp_idx{2,iG}]);
            all_subj = [1:numel([all_grp_idx{1,iG} ; all_grp_idx{2,iG}])]';
            all_group = [ones(numel(all_grp_idx{1,iG}),1) ; ...
                2*ones(numel(all_grp_idx{2,iG}),1)];
            nest = zeros(2,2);
            nest(1,2)=1;
            
            comp_name = [(all_grp{1,iG}) '_' (all_grp{2,iG})];
            [p, output.(demog_list{iD}).stats.(comp_name)] = anovan(all_data(:), {all_subj(:),...
                all_group(:)}, 'nested', nest, 'random', 1, 'varnames', {'subj',...
                'group'}, 'display', 'off');
        end
    end
end

%% out
output.group_labels = {g1_label, g2_label, g3_label};
output.group_n_datasets = [numel(g1_idx) numel(g2_idx) numel(g3_idx)];
output.group_n_unique = [numel(unique(subj_number(g1_idx))) ...
    numel(unique(subj_number(g2_idx))) numel(unique(subj_number(g3_idx)))];
output.missing_dx_list = missing_dx_list;
output.missing_acuity_list = missing_acuity_list;
output.psych_data = psych_data;
output.demog_data = demog_data;
output.options = options;
output.date_run = datestr(now);
end