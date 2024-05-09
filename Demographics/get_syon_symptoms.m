function output = get_syon_symptoms(options)
%% 20240401 HM/HHY, follows EVP and PHCP code
% 
% usage: output = get_syon_symptoms(options)
%
% input - options, structure with required fields:
%           - subj_number -- vector of all subject numbers you want symptom
%                            data for
%           - date_number -- vector of all date numbers (as in the matlab
%                            function datenum) for each data set (must match # of subjects!)
%           - symptom_measure -- name of the symptom measure you
%                                want to examine
%
% output - output, structure with fields:
%               output.clin_list - the symptom metric of interest
%               output.clin_time - difference in days between when relevant
%                                 data set was acquired and when symptom levels were measured
%               output.missing_clin_list - list of data sets that are
%                                         missing symptom levels
%               output.clin_data_label - string label for the symptom
%                                         measure
%% options
if ~exist('options','var')
    options = [];
end

if ~isfield(options,'top_dir')
    options.top_dir = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics';
end

if ~isfield(options,'subj_number')
    error('No options.subj_number list provided!');
else
    subj_number = options.subj_number;
end

if ~isfield(options,'date_number')
    error('No options.date_number list provided!');
else
    date_number = options.date_number;
end

if numel(subj_number) ~= numel(date_number)
    error('Number of elements in options.subj_number is not equal to that in options.date_number.');
end

if ~isfield(options,'symp_date_limit')
    warning('No options.symp_date_limit provided...using 30 days...');
    options.symp_date_limit = 30;
end
symp_date_limit = options.symp_date_limit;

if ~isfield(options,'symptom_measure')
    error('No options.symptom_measure provided! You must specify which symptom measure to examine.');
end

if ~isfield(options,'overwrite_syon_clin_csv')
    options.overwrite_syon_clin_csv = 0;
    % Provide options.overwrite_syon_clin_csv = 1 if new csv has been pulled from redcap
end
%% get symptoms

addpath(genpath(options.top_dir));
clin_opts.target_file = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics/SYON_clin.csv';
clin_opts.overwrite_syon_clin_csv = options.overwrite_syon_clin_csv; % Handles overwrite option
clin_data = read_in_syon_clin_data(clin_opts);

clin_list = nan(numel(subj_number),1);
clin_time = nan(numel(subj_number),1);
missing_clin_list = [];
clin_switch = 0; 
% Switch allows to not look for specific dates if using SGI, SPQ, etc (only collected on CD)
% clin_switch is 1 for any materials only collected on CD

% options.symptom_measure can use the following strings
sgi_total_strings = {'SGI', 'SGI total'};
spq_total_strings = {'spq total' , 'spq' , 'spq tot' , 'spq_total'};
museq_strings = {'museq' , 'museq total', 'museq tot', 'museq_vis', 'museq visual'};

bprs_total_strings = {'BPRS Total Scores', 'BPRS Total Score', ...
    'BPRS Total', 'BPRS Totals', 'BPRS', 'BPRSTotal'};
bprs_pos_strings = {'BPRS Positive Scores', 'BPRS Positive Score', 'BPRS Positive', ...
    'BPRS Positives', 'BPRS Pos'};
bprs_neg_strings = {'BPRS Negative Scores', 'BPRS Negative Score', 'BPRS Negative', ...
    'BPRS Negatives', 'BPRS Neg'};
bprs_disorg_strings = {'BPRS Disorganization Scores', 'BPRS Disorganization Score', ...
    'BPRS Disorganization', 'BPRS Disorg', 'BPRS Disorg Score', 'BPRS Disorg Scores'};
bprs_depress_strings = {'BPRS Depression Scores', 'BPRS Depression Score', ...
    'BPRS Depression', 'BPRS Depressive Scores', 'BPRS Depressive Score', ...
    'BPRS Depressive', 'BPRS Depress', 'BPRS Depress Score', 'BPRS Depress Scores'};
bprs_mania_strings = {'BPRS Mania Scores', 'BPRS Mania Score', 'BPRS Mania'};

saps_total_strings = {'SAPS Total Scores', 'SAPS Total Score', ...
    'SAPS Total', 'SAPS Totals', 'SAPS', 'SAPS Global Positive Symptoms'};
saps_realitydistortion_strings = {'SAPS Reality Distortion Scores', 'SAPS Reality Distortion Score', ...
    'SAPS Reality Distortion', 'Reality Distortion'};
saps_thoughtdisorder_strings = {'SAPS Thought Disorder Scores', 'SAPS Thought Disorder Score', ...
    'SAPS Thought Disorder', 'Thought Disorder'};
saps_bizarre_strings = {'SAPS Bizarre Behavior Scores', 'SAPS Bizarre Behavior Score', ...
    'SAPS Bizarre Behavior', 'SAPS Bizarre Score', 'SAPS Bizarre Scores', 'Bizarre Behavior'};
sans_total_strings = {'SANS Total Scores', 'SANS Total Score', ...
    'SANS Total', 'SANS Totals', 'SANS'};
sans_neg_strings = {'SANS Negative Symptoms Scores', 'SANS Negative Symptoms Score', ...
    'SANS Negative Symptom Scores', 'SANS Negative Symptom Score', 'SANS Negative Symptom', ...
    'SANS Negative Symptoms', 'SANS Negative', 'SANS Negatives'};
sans_bluntaffect_strings = {'SANS Blunted Affect Scores', 'SANS Blunted Affect Score', ...
    'SANS Blunted Affects Scores', 'SANS Blunted Affects Score', 'SANS Blunt Affect Scores', ...
    'SANS Blunt Affect Score', 'SANS Blunted Affect', 'SANS Blunt Affect'};
sans_globalattn_strings = {'SANS Global Attention Scores', 'SANS Global Attention Score', ...
    'SANS Global Attention', 'Global Attention', 'SANS Attention', 'Attention'};

bacs_comp_strings = {'BACS Composite Scores', 'BACS Composite Score', 'BACS Composite', 'BACS'};
bacs_compz_strings = {'BACS Composite Z Scores', 'BACS Composite Z Score', 'BACS Composite Z', ...
    'BACS Composite Z-Scores', 'BACS Composite Z-Score', 'BACS Z Score', 'BACS Z Scores', ...
    'BACS Z-Score', 'BACS Z-Scores', 'BACS Z'};

%  visual_acuity = {'visual acuity', 'vision'};
% 202400401 HM - not sure how/whether this is handled in current syon csv;
% need to revisit

% ensure syon_clin_data.m variables match REDCap report csv; also set switches
if sum( strcmp( lower(options.symptom_measure) , lower(bprs_total_strings) ) )
    clin_variable  = clin_data.bprs_total; 
    clin_data_label = 'BPRS Total';
elseif sum( strcmp( lower(options.symptom_measure) , lower(bprs_pos_strings) ) )
    clin_variable  = clin_data.bprs_pos; 
    clin_data_label = 'BPRS: Positive';
elseif sum( strcmp( lower(options.symptom_measure) , lower(bprs_neg_strings) ) )
    clin_variable  = clin_data.bprs_negative; 
    clin_data_label = 'BPRS: Negative';
elseif sum( strcmp( lower(options.symptom_measure) , lower(bprs_disorg_strings) ) )
    clin_variable  = clin_data.bprs_disorg; 
    clin_data_label = 'BPRS: Disorganization';
elseif sum( strcmp( lower(options.symptom_measure) , lower(bprs_depress_strings) ) )
    clin_variable  = clin_data.bprs_dep; 
    clin_data_label = 'BPRS: Depression';
elseif sum( strcmp( lower(options.symptom_measure) , lower(bprs_mania_strings) ) )
    clin_variable  = clin_data.bprs_mania; 
    clin_data_label = 'BPRS: Mania';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(saps_total_strings) ) )
%     clin_variable  = syon_clin_data.saps_global_pos; 
%     clin_data_label = 'SAPS Total';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(saps_realitydistortion_strings) ) )
%     clin_variable  = syon_clin_data.saps_real_dist; 
%     clin_data_label = 'SAPS: Reality Distortion';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(saps_thoughtdisorder_strings) ) )
%     clin_variable  = syon_clin_data.saps_thought_dis; 
%     clin_data_label = 'SAPS: Thought Disorder';    
% elseif sum( strcmp( lower(options.symptom_measure) , lower(saps_bizarre_strings) ) )
%     clin_variable  = syon_clin_data.saps_bizarre; 
%     clin_data_label = 'SAPS: Bizarre Behavior';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(sans_total_strings) ) )
%     clin_variable  = syon_clin_data.sans_global_neg; 
%     clin_data_label = 'SANS Total';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(sans_neg_strings) ) )
%     clin_variable  = syon_clin_data.sans_neg; 
%     clin_data_label = 'SANS: Negative Symptoms';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(sans_bluntaffect_strings) ) )
%     clin_variable  = syon_clin_data.sans_blunt_score; 
%     clin_data_label = 'SANS: Blunted Affect';
% elseif sum( strcmp( lower(options.symptom_measure) , lower(sans_globalattn_strings) ) )
%     clin_variable  = syon_clin_data.sans_global_att; 
%     clin_data_label = 'SANS: Attention';

elseif sum( strcmp( lower(options.symptom_measure) , lower(sgi_total_strings) ) )
    clin_variable = clin_data.sgi_total;
    clin_data_label = 'SGI Total';
    clin_switch = 1;
% elseif sum( strcmp( lower(options.symptom_measure) , lower(spq_total_strings) ) )
%     clin_variable = syon_clin_data.spq_total;
%     clin_data_label = 'SPQ Total';
%     clin_switch = 1;
% elseif sum( strcmp( lower(options.symptom_measure) , lower(museq_strings) ) )
%     clin_variable = syon_clin_data.museq_vis_calc;
%     clin_data_label = 'MUSEQ: Visual';
%     clin_switch = 1;
% elseif sum( strcmp( lower(options.symptom_measure) , lower(bacs_comp_strings) ) )
%     clin_variable = syon_clin_data.evp_cog_bacs_comp;
%     clin_data_label = 'BACS Composite';
%     clin_switch = 1;
% elseif sum( strcmp( lower(options.symptom_measure) , lower(bacs_compz_strings) ) )
%     clin_variable = syon_clin_data.evp_cog_bacs_z;
%     clin_data_label = 'BACS Z-score';
%     clin_switch = 1;
%     
% elseif sum( strcmp( lower(options.symptom_measure) , lower(mars_log_contrast_strings) ) )
%     clin_variable = syon_clin_data.mars_log;
%     clin_data_label = 'MARS Log Contrast';
%     clin_switch = 1;
else error ('Unknown clinicial variable');
end

h_wait = waitbar(0, 'Checking symptom data, please wait...');

for iSubj = 1:numel(subj_number)
    for iOps = 1:numel(clin_variable)
        % first check IDs match
        check_IDs = strcmp(['S' num2str(subj_number(iSubj))],...
            clin_data.record_id{iOps});
        if ~check_IDs
            continue
        end
        
        %then look at BPRS/SAPS for that exact visit day
        clin_idx = 0;
        if clin_switch == 0
            clin_idx = (strcmp(['S' num2str(subj_number(iSubj))],clin_data.record_id) & ...
                eq(date_number(iSubj),cell2mat(clin_data.datenumber)));
            if sum (clin_idx) == 1
                break
            end
            
            find_all_dates = strcmp(clin_data.record_id,...
                ['S' num2str(subj_number(iSubj))]);
            
            date_diff = abs( cell2mat( clin_data.datenumber(find_all_dates) ) - ...
                date_number(iSubj) );
            
            if sum(clin_idx) == 0 && ( min(date_diff) < symp_date_limit )
                clin_idx =  find_all_dates & ( abs( cell2mat( clin_data.datenumber ) - ...
                    date_number(iSubj) ) == min(date_diff) );
            end
            if sum (clin_idx) == 1
                break
            end
            
            % Then look for nearest dataset to visit day
            if sum(clin_idx) == 0
                clin_idx = (strcmp(['S' num2str(subj_number(iSubj))],clin_data.record_id) & ...
                    strcmp('eeg_arm_1',clin_data.redcap_event_name));
            end
            if sum (clin_idx) == 1
                break
            end
           
            if sum(clin_idx) == 0
                clin_idx = (strcmp(['S' num2str(subj_number(iSubj))],clin_data.record_id) & ...
                    strcmp('mri_arm_1',clin_data.redcap_event_name));
            end
            
            if sum (clin_idx) == 1
                break
            end
            
            
        end
    end
    
% If nothing else is available, use CD data
    if sum(clin_idx) == 0
        clin_idx = (strcmp(['S' num2str(subj_number(iSubj))],clin_data.record_id) & ...
            strcmp('clinical_arm_1',clin_data.redcap_event_name));
    end
    
%     if sum(clin_idx) > 1 % more than 1 data set on the same date??
%         find_idx = find(clin_idx);
%         error(['More than one data set for ' clin_data.record_id(find_idx(1)) ...
%             ' on the same date??? Check record IDs = ' num2str(find_idx)]);
%     end
    
    if sum(clin_idx) == 0 % if still missing the subject
        missing_clin_list = [missing_clin_list ; subj_number(iSubj)];
        clin_list(iSubj) = NaN;
        clin_time(iSubj) = NaN;
        continue
    end
    
% Keeping this fix from KWK/MPS 20211101 implementing a check to fix lists (clin_variable) that are cells, 
% due to weird importing from RedCap
    if iscell(clin_variable(clin_idx))
        use_variable = str2num(clin_variable{clin_idx});
    else 
        use_variable = clin_variable(clin_idx);
    end
    
    if isempty(use_variable)
        missing_clin_list = [missing_clin_list ; subj_number(iSubj)];
        clin_list(iSubj) = NaN;
    else
        clin_list(iSubj) = use_variable;
    end
    
    clin_time(iSubj) = abs((cell2mat(clin_data.datenumber(clin_idx)) - date_number(iSubj)));
    
    if clin_time(iSubj) > symp_date_limit & clin_switch == 0
        missing_clin_list = [missing_clin_list ; subj_number(iSubj)];
        clin_list(iSubj) = NaN;
    end
    waitbar(iSubj/numel(subj_number),h_wait);
end
close(h_wait);

%% output
output.clin_list = clin_list;
output.clin_time = clin_time;
output.missing_clin_list = missing_clin_list;
output.clin_data_label = clin_data_label;
output.options = options;
output.date_run = datestr(now);
output.syon_clin_data = clin_data;

end

