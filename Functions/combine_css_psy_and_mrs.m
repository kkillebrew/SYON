function [output] = combine_css_psy_and_mrs( options )
% usage: [output] = combine_css_psy_and_mrs( options )
%
% mps 20181121
%%
addpath(genpath('/home/shaw-raid1/matlab_tools/mpsCode/'));
%% opt
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 1; % 1 = yes, 0 = no
end
if ~isfield(options,'mrs_file')
    error('No options.mrs_file provided!')
    % e.g., options.mrs_file = '/home/shaw-raid1/data/MRS/processed_data/20220830_phcp_OCC_193subj_H2O_scaled.csv';
end
if ~isfield(options,'mrs_n_col')
    options.mrs_n_col = 508; % if NOT using Gosia's notes = 439 (LCM default)
end
if ~isfield(options,'mrs_header_lines')
    options.mrs_header_lines = 6; % if NOT using Gosia's notes = 8 (LCM default)
end
mrs_opt.target_file = options.mrs_file;
mrs_opt.n_col = options.mrs_n_col;
mrs_opt.header_lines = options.mrs_header_lines;

if ~isfield(options,'mrs_struct')
    options.mrs_struct = read_in_LCModel_results(mrs_opt);
end

if ~isfield(options,'which_css_version'); % which version of the task to analyze;
    options.which_css_version = 2; % 1 = older, pre-2018, 2 = newer, 0 = combine both
end
if ~isfield(options,'jackknife_css'); % jackknife rather than individual fits
    options.jackknife_css = 2; % 0  = no, 1 = use group means, 2 = use all subject means
end
if ~isfield(options,'lowest_c'); % where to plot & fit 0% pedestal on log x-axis... this seems to give small fit error
    options.lowest_c = 2.5/16; %
end
if ~isfield(options,'avg_within_grp_func');
    options.avg_within_grp_func = @nangeomean;
end
if ~isfield(options,'which_surr_metric');
    options.which_surr_metric = 2;
end
if ~isfield(options,'toss_css_quality')
    options.toss_css_quality = 1;
end
if ~isfield(options,'css_struct')
    refit_CSS = 1;
elseif  options.which_css_version ~= options.css_struct.options.analyze_which_version
    refit_CSS = 1;
else
    refit_CSS = 0;
end
if refit_CSS
    warning('Running refit_CSS_data.m to generate options.css_struct...');
    
    css_opt.displayFigs = 0; % 0 for none, 1 for all figures, 2 for summary only
    css_opt.fit_CRFs = 1; % fit a contrast-response function
    css_opt.analyze_which_version = options.which_css_version; % which version of the task to analyze;
    css_opt.jackknife_CRF_fit = options.jackknife_css;
    css_opt.lowest_c = options.lowest_c;
    css_opt.avg_within_grp_func = options.avg_within_grp_func;
    css_opt.which_surr_metric = options.which_surr_metric;
    css_opt.toss_avg_catch = options.toss_css_quality;
    
    options.css_struct = refit_CSS_data(css_opt);
end
if ~isfield(options,'use_thresh')
    if options.which_css_version == 0 || ...
            options.which_css_version == 1
        options.use_thresh = [1 3:7]; % don't include with surround, or 0.6%
    else
        options.use_thresh = 1:7; % don't include with surround
    end
end
if ~isfield(options,'which_corr')
    options.which_corr = 'Spearman'; % thresholds look like the are not equal variance between groups, so let's go with this
end
if ~isfield(options,'toss_subj_num_date')
    options.toss_subj_num_date = []; % manually toss specific subject + session dates
    % n.b. was tossing [6004213 datenum('20190116','yyyymmdd')] on
    % 20190331, but now this is taken care of by tossing bad MRS quality
    % metrics.
end

if ~isfield(options,'which_group')
    options.which_group = 'all'; % options are all, controls, relatives, patients
end
ctrl_names = {'controls','control','ctrl','ctrls','c','ctr','ctl'};
rel_names = {'relatives','relative','rel','r','rels'};
pat_names = {'patients','patient','proband','pro','pat','p','pats','pts','pros','psy','psychosis'};
ctrl_plus_rel_names = {'controls+relatives','controls + relatives','c+r',...
    'c + r','control + relative','control+relative'};
sz_names = {'schizophrenia','sz'};
sca_names = {'schizoaffective','schizoaffective disorder','sca','sza'};
bp_names = {'bipolar','bipolar disorder','bp'};

all_names{1} = ctrl_names;
all_names{2} = rel_names;
all_names{3} = pat_names;
all_names{4} = ctrl_plus_rel_names;
all_names{5} = sz_names;
all_names{6} = sca_names;
all_names{7} = bp_names;

if strcmp(options.which_group,'all')
    which_group_idx = 0;
elseif sum(strcmp(options.which_group,ctrl_names))
    which_group_idx = 1;
elseif sum(strcmp(options.which_group,rel_names))
    which_group_idx = 2;
elseif sum(strcmp(options.which_group,pat_names))
    which_group_idx = 3;
elseif sum(strcmp(options.which_group,ctrl_plus_rel_names))
    which_group_idx = 4;
elseif sum(strcmp(options.which_group,sz_names))
    which_group_idx = 5;
elseif sum(strcmp(options.which_group,sca_names))
    which_group_idx = 6;
elseif sum(strcmp(options.which_group,bp_names))
    which_group_idx = 7;
else
    error(['options.which_group not recognized: ' options.which_group]);
end

if ~isfield(options,'which_metab')
    options.which_metab = {'Glu','GABA'};
    warning('options.which_metab not specified, assuming you want to look at only Glu and GABA...')
end
if ~isfield(options,'avg_across_contrasts_func')
    options.avg_across_contrasts_func = @geomean;
end
if ~isfield(options,'avg_within_contrasts_func')
    options.avg_within_contrasts_func = @nanmean;
end
if ~isfield(options,'corr_params')
    options.corr_params = 0; % correlate CRF fit params for individual subjects
end
if ~isfield(options,'toss_css_outliers')
    options.toss_css_outliers = 0;
end

if ~isfield(options,'toss_mrs_quality')
    options.toss_mrs_quality = 2; % 1 = old way, 2 = new
end
if ~isfield(options,'quality_file')
    options.quality_file = []; % e.g., options.quality_file = '/home/shaw-raid1/data/MRS/processed_data/data_quality/data_coil_parameters_performance_OCC_20200420.csv';
end
if options.toss_mrs_quality == 1
    if ~isempty(options.quality_file)
        qual_opt.target_file = options.quality_file;
        load_quality = read_in_gosia_data_quality( qual_opt );
        quality_data = load_quality.csv_data;
    else
        error('you set options.toss_mrs_quality = 1, but options.quality_file is empty or missing, so I quit!')
    end    
end

if ~isfield(options,'outlier_n_SDs')
    options.outlier_n_SDs = 3;
end
if ~isfield(options,'toss_CRLB')
    options.toss_CRLB = 0; % toss values above this, set to 0 to skip
end
if ~isfield(options,'use_CSS_thresh')
    options.use_CSS_thresh = 'thresh_refit_comb'; % thresh_refit, thresh_refit_comb, log_avg_thresh
end
if ~isfield(options,'corr_suppression')
    options.corr_suppression = 0;
end
% if ~isfield(options,'divide_suppression')
%     options.divide_suppression = 1;
% end
% if options.corr_suppression
%     ns_10_idx = 6; ss_10_idx = 8;
%    if sum(ismember([ns_10_idx ss_10_idx], options.use_thresh)) == 2
%        warndlg(['Correlating the strength of suppression, as requested...']);
%    else
%        error(['You set options.corr_suppression = 1, but you didn''t include both '...
%            'no surround 10% (idx = 6) and with surround 10% (idx = 8) in '...
%            'options.use_thresh, so I quit.']);
%    end
% end
if ~isfield(options,'plot_rank_corr')
    options.plot_rank_corr = 0;
end
if ~isfield(options,'plot_groups_separate')
    options.plot_groups_separate = 1;
end
if ~isfield(options,'avg_repeats')
    options.avg_repeats = 0;
end
if ~isfield(options,'use_which_repeat')
    options.use_which_repeat = 1; % 1 = use first, 2 = use 2nd, 3 = use both
end
if ~isfield(options,'skip_last_n_rows')
    options.skip_last_n_rows = 4;
end
if ~isfield(options,'combine_Cr_Cho')
    options.combine_Cr_Cho = 1;
    
    cr_idx = strcmp(options.which_metab , 'Cr');
    pcr_idx = strcmp(options.which_metab , 'PCr');
    tcr_idx = strcmp(options.which_metab , 'tCr');
    gpc_idx = strcmp(options.which_metab , 'GPC');
    pcho_idx = strcmp(options.which_metab , 'PCho');
    tcho_idx = strcmp(options.which_metab , 'tCho');
    
    if ( sum(cr_idx) && sum(pcr_idx) ) || sum(tcr_idx)
        warning('Combining Cr and PCr as tCr for analysis...');
        options.which_metab(logical(cr_idx + pcr_idx + tcr_idx)) = [];
        options.which_metab{end+1} = 'tCr';
        options.mrs_struct.tCr = options.mrs_struct.Cr + options.mrs_struct.PCr;
    end    
    if ( sum(gpc_idx) && sum(pcho_idx) ) || sum(tcho_idx)
        warning('Combining GPC and PCho as tCho for analysis...');
        options.which_metab(logical(gpc_idx + pcho_idx + tcho_idx)) = [];
        options.which_metab{end+1} = 'tCho';
        options.mrs_struct.tCho = options.mrs_struct.GPC + options.mrs_struct.PCho;
    end
end
if ~isfield(options,'include_demog_symp')
    options.include_demog_symp = 0;
end

%% get mrs file info
for iFile = 1:numel(options.mrs_struct.row_name)-options.skip_last_n_rows % skip last N, mean and sd/mean
    name_idx = regexp(options.mrs_struct.row_name{iFile},'P\d\d\d\d\d\d\d');
    options.mrs_struct.subj_number(iFile,1) = str2num(options.mrs_struct.row_name{iFile}...
        (name_idx+1:name_idx+7));
    date_idx = regexp(options.mrs_struct.row_name{iFile},'\d\d\d\d\d\d\d\d');
    options.mrs_struct.date_number(iFile,1) = datenum(options.mrs_struct.row_name{iFile}...
        (date_idx:date_idx+7),'yyyymmdd');
end

%% find subjects & dates that overlap
clear corr_css_params corr_css_thresh

demog_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
addpath(genpath('/home/shaw-raid1/matlab_tools/mpsCode'))
demog_data = read_in_demog_data(demog_opts);

% start with MRS, because all the subjects should have psychophysics...?
% MRS_subj_date = [options.mrs_struct.subj_number options.mrs_struct.date_number];

all_subj_date = [options.css_struct.subj_number options.css_struct.date_number ; ...
    options.mrs_struct.subj_number options.mrs_struct.date_number]; % now add all MRS data
% now remove repeats...
all_subj_date = unique(all_subj_date,'rows');

% there are a couple of subjects who completed psychophysics and MRS on
% different days, sort this out

diff_date_idx = [];
for iS = 1:size(all_subj_date,1)
    find_diff_date = find( all_subj_date(:,1) == all_subj_date(iS,1) & ...
        ( all_subj_date(:,2) ~= all_subj_date(iS,2) ) & ...
        ( abs(all_subj_date(:,2) - all_subj_date(iS,2)) <= 14 ) ); % same subject, not the same date, but within 2 weeks
    if ~isempty(find_diff_date)
        diff_date_idx = [diff_date_idx ; iS];
    end
end
if numel(diff_date_idx) ~= 2
    error('Houston, we have a problem...');
end
all_subj_date(diff_date_idx(2),:) = [];

dx_list = nan(size(all_subj_date,1),1);
missing_dx_list = [];
for iSubj = 1:size(all_subj_date,1)
    dx_idx = strcmp(['P' num2str(all_subj_date(iSubj,1))],demog_data.Record_ID);
    if isempty(dx_idx) || ( sum(dx_idx) == 0 ) % if this subject isn't in the demographics .csv file
        missing_dx_list = [missing_dx_list ; all_subj_date(iSubj,1)];
        continue
    end
    dx_list(iSubj) = demog_data.Dx_code(dx_idx);
end

toss_idx = []; wrong_grp_idx = [];
if ~isempty(options.toss_subj_num_date) || which_group_idx
    for iSubj = 1:size(all_subj_date,1)
        
        if which_group_idx == 1
            if all_subj_date(iSubj,1) >= 2000000
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 2
            if all_subj_date(iSubj,1) < 2000000 || ...
                    all_subj_date(iSubj,1) >= 6000000
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 3
            if all_subj_date(iSubj,1) < 6000000;
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 4
            if all_subj_date(iSubj,1) >= 6000000;
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 5
            if all_subj_date(iSubj,1) < 6000000 || dx_list(iSubj) ~= 2;
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 6
            if all_subj_date(iSubj,1) < 6000000 || dx_list(iSubj) ~= 3;
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        elseif which_group_idx == 7
            if all_subj_date(iSubj,1) < 6000000 || dx_list(iSubj) ~= 4;
                wrong_grp_idx = [wrong_grp_idx ; iSubj];
            end
        end
        
        if ~isempty(options.toss_subj_num_date)
            if which_group_idx && ~isempty(wrong_grp_idx)
                if wrong_grp_idx(end) ~= iSubj % if we haven't already tossed this one...
                    for iToss = 1:size(options.toss_subj_num_date,1)
                        if sum(all_subj_date(iSubj,:) == options.toss_subj_num_date(iToss,:)) == 2
                            % both subject num and date are the same, so toss
                            toss_idx = [toss_idx ; iSubj];
                        end
                    end
                end
            else
                for iToss = 1:size(options.toss_subj_num_date,1)
                    if sum(all_subj_date(iSubj,:) == options.toss_subj_num_date(iToss,:)) == 2
                        % both subject num and date are the same, so toss
                        toss_idx = [toss_idx ; iSubj];
                    end
                end
            end
        end
    end
end

% start_date = datenum('20170714','yyyymmdd')-1; % this was the day we ran the first scan, minus 1,
% % use it to cut down matrix size for indexing
% max_date = max([options.css_struct.date_number ; options.mrs_struct.date_number]);
% all_css_thresh = zeros(7000000, max_date - start_date); % looks like using zeros takes up a lot less memory then NaNs... 16GB YIKES
% %%%% this approach is not perfect, because it treats all scans equally -
% %%%% doesn't take repeated scans within subjects into account!!

all_css_thresh = nan(size(all_subj_date,1),1);
all_css_params = zeros(size(all_subj_date,1), ...
    size(options.css_struct.fit_CRF.params,2));

% thresh_idx = sub2ind(size(all_css_thresh),options.css_struct.subj_number,...
%     options.css_struct.date_number - start_date);

for iS = 1:size(all_subj_date,1)
    css_subj_idx = find( options.css_struct.subj_number == all_subj_date(iS,1) & ...
        ( abs(options.css_struct.date_number - all_subj_date(iS,2)) <= 14 ) ); % date within 2 weeks
    
    if ~isempty(css_subj_idx) % if we have css data, else leave as NaN
        
        if options.corr_suppression
            all_css_thresh(iS) = options.css_struct.suppression_index(css_subj_idx);
            
%         if options.corr_suppression && options.divide_suppression
%             all_css_thresh(iS) = ...
%                 options.avg_within_contrasts_func(...
%                 options.css_struct.(options.use_CSS_thresh)(:,ss_10_idx,:),3) ./ ...
%                 options.avg_within_contrasts_func(...
%                 options.css_struct.(options.use_CSS_thresh)(:,ns_10_idx,:),3);
%         elseif options.corr_suppression && ~options.divide_suppression
%             all_css_thresh(iS) = ...
%                 options.avg_within_contrasts_func(...
%                 options.css_struct.(options.use_CSS_thresh)(:,ss_10_idx,:),3) - ...
%                 options.avg_within_contrasts_func(...
%                 options.css_struct.(options.use_CSS_thresh)(:,ns_10_idx,:),3);
        else
            all_css_thresh(iS) = ...
                options.avg_across_contrasts_func(options.avg_within_contrasts_func(...
                options.css_struct.(options.use_CSS_thresh)(...
                css_subj_idx,options.use_thresh,:),3),2);
        end
        
        all_css_params(iS,:) = options.css_struct.fit_CRF.params(css_subj_idx,:);

    end
    
end

% mrs_idx = sub2ind(size(all_css_thresh),options.mrs_struct.subj_number,...
%     options.mrs_struct.date_number - start_date); % need to use the same matrix size, but this time with mrs indices

corr_css_thresh = all_css_thresh;
corr_css_params = all_css_params;

output.subj_number = all_subj_date(:,1);
output.date_number = all_subj_date(:,2);

% clear all_css_thresh
% 
% 
% all_css_params = zeros(7000000, max_date - start_date, ...
%     size(options.css_struct.fit_CRF.params,2));
% 
% for iP = 1:size(options.css_struct.fit_CRF.params,2)
%     params_idx = sub2ind(size(all_css_params), options.css_struct.subj_number,...
%         options.css_struct.date_number - start_date, ...
%         repmat(iP,[numel(options.css_struct.subj_number) 1]) );
%     all_css_params(params_idx) = ...
%         options.css_struct.fit_CRF.params(:,iP);
%     
%     mrs_idx = sub2ind(size(all_css_params), options.mrs_struct.subj_number,...
%         options.mrs_struct.date_number - start_date, ...
%         repmat(iP,[numel(options.mrs_struct.subj_number) 1]) ); % need to use the same matrix size, but this time with mrs indices
%     corr_css_params(:,iP) = all_css_params(mrs_idx);
% end
% clear all_css_params


% % if the subject is included in the MRS data set, but not the CSS for some
% % reason, then they will have a zero for corr_css_thresh - to fix, replace
% % all zeros with NaN
% idx_no_thresh = corr_css_thresh == 0;
% output.subj_number_date_no_thresh = MRS_subj_date(idx_no_thresh,:);
% warning([num2str(size(output.subj_number_date_no_thresh,1)) ' subjects with missing threshold data...']);
% % if looking at OCC, should be the first 10 subjects before 20170906 who
% % didn't get CSS psychophysics...
% 
% corr_css_params(corr_css_thresh == 0,:) = NaN;
% corr_css_thresh(corr_css_thresh == 0) = NaN;

%% toss outliers?
find_out_css=[];
if options.toss_css_outliers
    find_out_css = abs(corr_css_params - repmat(nanmean(corr_css_params,1),...
        [size(corr_css_params,1) 1] )) > repmat(3*nanstd(corr_css_params,0,1),...
        [size(corr_css_params,1) 1] );
    corr_css_params(find_out_css,:) = NaN;
    
    find_out_css = abs(corr_css_thresh - nanmean(corr_css_thresh,1) ) ...
        > options.outlier_n_SDs * nanstd(corr_css_thresh,0,1);
    corr_css_thresh(find_out_css) = NaN;
    
    output.toss_css_outliers = [output.subj_number(find_out_css) ...
        output.date_number(find_out_css)];
end

% toss_catch = [];
% if options.toss_css_quality
%     qual_opt = [];
%     qual_opt.displayFigs = 0;
%     qual_opt.skip_last_n_rows = options.skip_last_n_rows;
%     if ~isfield(options,'data_quality')
%         options.data_quality = summarize_pHCP_data_status(qual_opt);
%     end
%     
%     CSS_task_idx = 2; % where in quality matrix (dim 2) these data live
%     beh_catch_idx = 3; % where in quality matrix (dim 3) these data live
%     exclude_idx = 4; % where in quality matrix (dim 3) these data live
%     catch_fail = options.data_quality.all_dataset_list(...
%         options.data_quality.failed_binary(:, CSS_task_idx, beh_catch_idx)...
%         == 1 | options.data_quality.failed_binary(:, CSS_task_idx, exclude_idx)...
%         == 1, :);
%     
%     toss_catch = [];
%     for iToss = 1:size(catch_fail,1)
%         find_bad = find( (catch_fail(iToss,1) == output.subj_number) & ...
%             (catch_fail(iToss,2) == output.date_number) );
%         toss_catch = [toss_catch find_bad];
%     end
%     
%     corr_css_params(toss_catch,:) = NaN;
%     corr_css_thresh(toss_catch) = NaN;
%     output.toss_css_quality = [output.subj_number(toss_catch) ...
%         output.date_number(toss_catch)];
% end



if options.toss_mrs_quality == 1
    mrs_qual_metrics = {'SNR','lw_H2O','lw_tCr'};
    high_is_good = [1 0 0];
    toss_qual = [];

    find_out_mrs = [];
    for iQ = 1:numel(mrs_qual_metrics)
        if ~sum(ismember(quality_data.Properties.VariableNames, ...
                mrs_qual_metrics{iQ}))
            error(['You asked to toss data based on MRS quality metrics, but '...
                'the following metric is not included in your MRS quality data set: '...
                mrs_qual_metrics{iQ} ' -- Are you loading data quality '...
                'metrics from Gosia??']);
        end
        
        use_qual = [];
        for iS = 1:size(MRS_subj_date,1)
            subj_idx = find(quality_data.subject_num == MRS_subj_date(iS,1) & ...
                quality_data.date_num == MRS_subj_date(iS,2));
            if ~isempty(subj_idx)
                use_qual(iS,1) = quality_data.(mrs_qual_metrics{iQ})(subj_idx);
            else
                use_qual(iS,1) = NaN;
            end
        end
        
        if high_is_good(iQ)
            find_out_mrs = [find_out_mrs ; find( (use_qual - nanmean(use_qual,1) )...
                < -options.outlier_n_SDs * nanstd(use_qual,0,1) )];
        else
            find_out_mrs = [find_out_mrs ; find( (use_qual - nanmean(use_qual,1) )...
                > options.outlier_n_SDs * nanstd(use_qual,0,1) ) ];
        end
    end
    
    
    output.tossed_subj_date = MRS_subj_date(toss_qual == 1,:);
    find_out_mrs = [find_out_mrs ; find(toss_qual == 1)];

    toss_idx = [toss_idx ; find_out_mrs];

    if ~isempty(find_out_mrs)
%         MRS_subj_date(find_out_mrs,:) = [];
        warning(['Tossing ' num2str(numel(find_out_mrs)) ' data sets, for MRS quality outliers..']);
    end
    corr_css_params(find_out_mrs,:) = NaN;
    corr_css_thresh(find_out_mrs) = NaN;
    output.toss_mrs_quality = [output.subj_number(find_out_mrs) ...
        output.date_number(find_out_mrs)];
    
elseif options.toss_mrs_quality == 2

    summ_opt = [];
    summ_opt.displayFigs = 0;
    summ_opt.check_MRS_quality = 1;
    summ_opt.toss_date = 20170701;
    summ_opt.OCC_mrs_file = options.mrs_file; % fudge this here to use whichever 
    % data file we are using for both OCC and PFC, then figure
    % out which ROI's data quality metric to use later...
    summ_opt.PFC_mrs_file = options.mrs_file;
    summ_opt.skip_last_n_rows = options.skip_last_n_rows;
    summarize_data = summarize_pHCP_data_status( summ_opt );
    
    mrs_qual_metrics = {'lw_H2O','lw_LCM','SNR','excluded'};
    high_is_good = [0 0 1 0];
        
    toss_qual = [];
    find_out_mrs = [];
    missing_qual = [];
    for iS = 1:size(all_subj_date,1)
        subj_idx = find(summarize_data.subject_numbers == all_subj_date(iS,1) & ...
            abs(summarize_data.psy_date_numbers - all_subj_date(iS,2)) <= 14); % date within 2 weeks
        if ~isempty(subj_idx)
            toss_qual(iS,1) = squeeze( sum( summarize_data.mrs_quality_failed_binary(...
                subj_idx,1,:),3)) >= 1;
        else
            toss_qual(iS,1) = NaN;
            missing_qual = [missing_qual ; all_subj_date(iS,:)];
        end
    end
    
    if ~isempty(missing_qual)
       error('Houston, we have a problem...'); 
    end
                
    output.tossed_subj_date = all_subj_date(toss_qual == 1,:);
    find_out_mrs = [find_out_mrs ; find(toss_qual == 1)];

    toss_idx = [toss_idx ; find_out_mrs];

    if ~isempty(find_out_mrs)
%         all_subj_date(find_out_mrs,:) = [];
        warning(['Tossing ' num2str(numel(find_out_mrs)) ' data sets, for MRS quality outliers..']);
    end
    corr_css_params(find_out_mrs,:) = NaN;
    corr_css_thresh(find_out_mrs) = NaN;
    output.toss_mrs_quality = [output.subj_number(find_out_mrs) ...
        output.date_number(find_out_mrs)];
end

output.css.thresh = corr_css_thresh;
output.css.params = corr_css_params;

%% calculate correlations and plot
for iM = 1:numel(options.which_metab)
    
    corr_metab = nan(size(all_subj_date,1),1);
    metab_CRLB = nan(size(all_subj_date,1),1);
    
    checkSD = 0; % see if this field has a CRLB associated with it
    eval(['checkSD = isfield(options.mrs_struct,''SD' options.which_metab{iM} ''');']); % toss last 2 values - mean and sd/mean
    
    for iS = 1:size(all_subj_date,1)
        mrs_subj_idx = find( options.mrs_struct.subj_number == all_subj_date(iS,1) & ...
            options.mrs_struct.date_number == all_subj_date(iS,2) );
        
        if ~isempty(mrs_subj_idx) % if we have css data, else leave as NaN
            corr_metab(iS) = options.mrs_struct.(options.which_metab{iM})(mrs_subj_idx);
            if checkSD
                metab_CRLB(iS) = options.mrs_struct.(['SD' options.which_metab{iM}])(mrs_subj_idx);
            end
        end
        
    end
        
%     corr_metab = options.mrs_struct.(options.which_metab{iM})...
%         (1:numel(options.mrs_struct.subj_number));
    
    if ~isempty(wrong_grp_idx)
        warning(['Including only ' num2str(size(all_subj_date,1) - ...
            numel(wrong_grp_idx)) ' ' all_names{which_group_idx}{1} ...
            ', as requested...']);
        corr_metab(wrong_grp_idx) = NaN;
    end
    if ~isempty(toss_idx)
        warning(['Tossing ' num2str(numel(toss_idx)) ' data sets, as requested...']);
        corr_metab(toss_idx) = NaN;
    end
    
    % toss high CRLB, if requested

    if checkSD & options.toss_CRLB
%         eval(['metab_CRLB = options.mrs_struct.SD' options.which_metab{iM} '(1:end-2);']); % toss last 2 values - mean and sd/mean
%         toss_all = unique([reshape(find_out_mrs,[numel(find_out_mrs) 1]) ; ...
%             reshape(toss_idx,[numel(toss_idx) 1]) ; ...
%             reshape(wrong_grp_idx,[numel(wrong_grp_idx) 1]) ; ...
%             reshape(find_out_css,[numel(find_out_css) 1]) ; ...
%             reshape(toss_catch,[numel(toss_catch) 1])]);
%         metab_CRLB(toss_all) = NaN; % toss excluded subj

        warning(['tossing ' num2str(sum(metab_CRLB > options.toss_CRLB)) ...
            ' ' options.which_metab{iM} ' values for CRLB > ' num2str(...
            options.toss_CRLB)]);
        corr_metab( metab_CRLB > options.toss_CRLB ) = NaN;
    end
    
    % first correlate thresholds
    throw_out_nans_metab = isnan(corr_metab) | isnan(corr_css_thresh);
    corr_css_thresh_metab = corr_css_thresh;
    corr_css_thresh_metab(throw_out_nans_metab) = [];
    corr_metab_toss = corr_metab;
    corr_metab_toss(throw_out_nans_metab) = [];
    if iM == 1
        output.subj_number(throw_out_nans_metab) = [];
        output.date_number(throw_out_nans_metab) = [];
    end
    
    if ( options.use_which_repeat == 3 ) && ~options.avg_repeats
        warning('Using BOTH first and second data set for repeated subjects (i.e., some subjects are counted twice)...');
        % don't actually need to do anything here, just let it keep both
    else
        % first figure out unique subjects
        if iM == 1
            [~, unique_idx] = unique(output.subj_number,'rows','stable');
            [~, repeat_scan_idx] = setxor([output.subj_number output.date_number],...
                [output.subj_number(unique_idx) output.date_number(unique_idx)],...
                'rows','stable'); % find not intersection

            output.keep_all_subj_number = output.subj_number;
            output.keep_all_date_number = output.date_number;
            
            if options.avg_repeats || (~options.avg_repeats && options.use_which_repeat == 1)
                output.subj_number = output.subj_number(unique_idx);
                output.date_number = output.date_number(unique_idx);
                
            elseif (~options.avg_repeats && options.use_which_repeat == 2)
                output.subj_number = output.subj_number(unique_idx);
                output.date_number(repeat_scan_idx-1) = output.date_number(repeat_scan_idx); % replace 1st with 2nd date
                output.date_number = output.date_number(unique_idx); % then take only 1st (replaced) copy
            end
        end
        
        if options.avg_repeats
            warning('Averaging data sets for repeated subjects...');
            avg_thresh = -1*ones(size(corr_css_thresh_metab));
            avg_thresh(unique_idx) = corr_css_thresh_metab(unique_idx);
            avg_thresh(repeat_scan_idx-1) = nanmean([corr_css_thresh_metab(repeat_scan_idx-1) ...
                corr_css_thresh_metab(repeat_scan_idx)],2); % avg repeated subj
            corr_css_thresh_metab = avg_thresh(~(avg_thresh < 0)); % do it this way, to deal with NaNs for tossed values with CRLB > limit
            
            avg_metab = -1*ones(size(corr_metab_toss));
            avg_metab(unique_idx) = corr_metab_toss(unique_idx);
            avg_metab(repeat_scan_idx-1) = nanmean([corr_metab_toss(repeat_scan_idx-1) ...
                corr_metab_toss(repeat_scan_idx)],2); % avg repeated subj
            corr_metab_toss = avg_metab(~(avg_metab < 0)); % do it this way, to deal with NaNs for tossed values with CRLB > limit
        
        elseif options.use_which_repeat == 1
            warning('Using first data set for repeated subjects...');
            corr_css_thresh_metab = corr_css_thresh_metab(unique_idx);
            corr_metab_toss = corr_metab_toss(unique_idx);
            
        elseif options.use_which_repeat == 2
            warning('Using second data set for repeated subjects...');
            corr_css_thresh_metab(repeat_scan_idx-1) = corr_css_thresh_metab(repeat_scan_idx); % replace 1st with 2nd value
            corr_css_thresh_metab = corr_css_thresh_metab(unique_idx); % keep only replaced (now 2nd) value

            corr_metab_toss(repeat_scan_idx-1) = corr_metab_toss(repeat_scan_idx); % replace 1st with 2nd value
            corr_metab_toss = corr_metab_toss(unique_idx); % keep only replaced (now 2nd) value
            
        else
            error(['unknown value for options.use_which_repeat = ' num2str(options.Suse_which_repeat)]);
        end
    end
    
    if options.plot_rank_corr
        [~, sort_metab_idx] = sort(corr_metab_toss);
        [~, sort_thresh_idx] = sort(corr_css_thresh_metab);
        rank_metab = [];
        rank_thresh = [];
        for iS = 1:numel(sort_metab_idx)
            rank_metab(sort_metab_idx(iS),1) = iS;
            rank_thresh(sort_thresh_idx(iS),1) = iS;            
        end
        corr_metab_toss = rank_metab;
        corr_css_thresh_metab = rank_thresh;
    end
    
    clear metab
    
    [metab.corr_thresh.r, metab.corr_thresh.p] = corr(corr_metab_toss, ...
        corr_css_thresh_metab, ...
        'type',options.which_corr);
    metab.corr_thresh.df = numel(corr_metab_toss)-2;
    
    metab.values = corr_metab_toss;
    
    % add permutation analysis here, copy from split_half...
    
    if options.displayFigs
        figure; hold on
        
        use_title = [upper(options.which_group(1)) options.which_group(2:end)...
            ' subjects'];
        
        if options.plot_rank_corr
            use_x_label = [options.which_metab{iM} ' subj. rank'];
        elseif strcmp(options.which_metab{iM},'lw_H2O')
            use_x_label = ['linewidth H_2O (Hz)'];
        elseif strcmp(options.which_metab{iM},'lw_tCr')
            use_x_label = ['linewidth tCr (Hz)'];
        elseif strcmp(options.which_metab{iM},'SNR')
            use_x_label = ['SNR (arb .units)'];
        elseif strcmp(options.which_metab{iM},'MacY')
            use_x_label = ['MacM (inst. units)'];
        else
            use_x_label = [options.which_metab{iM} ' (mM)'];
        end
        
        [poly_fit] = polyfit(corr_metab_toss, ...
            corr_css_thresh_metab, 1);
        
        fit_x = [min(corr_metab_toss) max(corr_metab_toss)];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);
        y_range = [min(corr_css_thresh_metab) max(corr_css_thresh_metab)];
        
        ctrl_idx = find( output.subj_number < 2000000 );
        rel_idx = find( output.subj_number >= 2000000 & ...
            output.subj_number < 6000000 );
        pat_idx = find( output.subj_number >= 6000000 );
        
        if options.plot_groups_separate
            plot_colors = {[0.33 1 0.33],[0.33 0.33 1],[1 0.33 0.33]};
        else
            plot_colors = {'w','w','w'};
        end
        
        plot(-1, -1 ,'ko',...
            'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
        plot(-1, -1 ,'ko',...
            'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
        plot(-1, -1 ,'ko',...
            'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
        
        plot(fit_x,fit_y,'k-','linewidth',2)

        plot(corr_metab_toss(ctrl_idx), corr_css_thresh_metab(ctrl_idx),'ko',...
            'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
        
        plot(corr_metab_toss(rel_idx), corr_css_thresh_metab(rel_idx),'ko',...
            'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
        
        plot(corr_metab_toss(pat_idx), corr_css_thresh_metab(pat_idx),'ko',...
            'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
        
        xlabel(use_x_label,'color','k')
        
        if options.corr_suppression
            if options.which_surr_metric == 1
                y_label_str = 'Suppression (SS - NS)';
            elseif options.which_surr_metric == 2
                y_label_str = 'Suppression (SS / NS)';
            elseif options.which_surr_metric == 3
                y_label_str = 'Suppression (SS - NS) / NS';
            elseif options.which_surr_metric == 4
                y_label_str = 'Suppression (SS - NS) / (SS + NS)';
            end
        else
            y_label_str = 'Avg. thresh. (%)';
        end
        if options.plot_rank_corr
            use_y_label = [y_label_str ' subj. rank'];
            use_y_scale = 'linear';
            use_y_tick = [1 50 100];
        else
            use_y_label = [y_label_str];
            use_y_scale = 'log';
            use_y_tick = [0.1 0.25 0.5 1 2.5 5 10 25];
        end
        if strcmp(options.which_metab{iM},'MacY')
            use_x_tick = 0:0.005:1;
        else
            use_x_tick = 0:0.5:25;
        end
        
        ylabel(use_y_label,'color','k')
        title(use_title)
        
        range_metab = max(corr_metab_toss) - min(corr_metab_toss);
        range_thresh = max(corr_css_thresh_metab) - min(corr_css_thresh_metab);
        text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab),...
            ['n = ' num2str(numel(corr_metab_toss))],'fontsize',18)
        text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab)-range_thresh*.225,...
            ['r = ' num2str(round(100*metab.corr_thresh.r)/100)],'fontsize',18)
        text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab)-range_thresh*.4,...
            ['p = ' num2str(round(100*metab.corr_thresh.p)/100)],'fontsize',18)
        set(gcf,'color','w')

        set(gca,'FontSize',18,'XColor','k','YColor','k','Yscale',use_y_scale,...
            'YTick',use_y_tick,'XTick',use_x_tick)
        x_span = fit_x(2) - fit_x(1);
        y_span = y_range(2) - y_range(1);
        axis([fit_x(1)-0.1*x_span fit_x(2)+0.1*x_span ...
            y_range(1)-0.05*y_span y_range(2)+0.1*y_span])
        if options.plot_groups_separate && which_group_idx == 0
            legend(['Ctrl, n = ' num2str(numel(ctrl_idx))],...
                ['Rel, n = ' num2str(numel(rel_idx))],...
                ['Psy, n = ' num2str(numel(pat_idx))])
        end
    end
    
    if options.corr_params
        if options.jackknife_css
           % need to re-run refit CSS to use only subjects with both CSS and MRS data
           css_opt.subj_list = output.subj_number;
           css_opt.date_list = output.date_number;
           options.css_struct = refit_CSS_data(css_opt);
           corr_css_params_metab = options.css_struct.fit_CRF.params;
           
           % now need to jackknife metab, so we can correlate both
           % jackknifed
           store_metab = corr_metab_toss;
           if options.jackknife_css == 1
               warndlg('This combination of options doesn''t make sense...')
           for iG = 1:3
               all_idx = options.css_struct.group_idx{iG};
               for iS = 1:numel(all_idx)
                   use_subj = all_idx(all_idx~=all_idx(iS));
                   corr_metab_toss(all_idx(iS)) = mean(store_metab(use_subj));
               end
           end
           elseif options.jackknife_css == 2
               all_idx = 1:numel(store_metab);
               for iS = 1:numel(all_idx)
                   use_subj = all_idx(all_idx~=all_idx(iS));
                   corr_metab_toss(all_idx(iS)) = mean(store_metab(use_subj));
               end
           end
        else
            % now look at correlating params
            corr_css_params_metab = corr_css_params;
            corr_css_params_metab(throw_out_nans_metab,:) = [];
        end
        param_labels = {'A','p','q','sigma'};
        for iP = 1:size(corr_css_params_metab,2)
            [metab.corr_params(iP).r, metab.corr_params(iP).p] = corr(corr_metab_toss, ...
                corr_css_params_metab(:,iP), 'type', options.which_corr);
            metab.corr_params(iP).df = numel(corr_metab_toss)-2;
            
            if options.displayFigs
                figure; hold on
                
                [poly_fit] = polyfit(corr_metab_toss, ...
                    corr_css_params_metab(:,iP), 1);
                
                fit_x = [min(corr_metab_toss) max(corr_metab_toss)];
                fit_y = poly_fit(1).*fit_x + poly_fit(2);
                y_range = [min(corr_css_params_metab(:,iP)) ...
                    max(corr_css_params_metab(:,iP))];
                plot(fit_x,fit_y,'k-','linewidth',2)
                                
                plot(corr_metab_toss(ctrl_idx), corr_css_params_metab(ctrl_idx,iP),'ko',...
                    'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
                
                plot(corr_metab_toss(rel_idx), corr_css_params_metab(rel_idx,iP),'ko',...
                    'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
                
                plot(corr_metab_toss(pat_idx), corr_css_params_metab(pat_idx,iP),'ko',...
                    'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
                
                xlabel([options.which_metab{iM} ' (mM)'],'color','k')
                ylabel([param_labels{iP} ' (arb.)'],'color','k')
                title(use_title)
                
                range_metab = max(corr_metab_toss) - min(corr_metab_toss);
                range_params = max(corr_css_params_metab(:,iP)) - min(corr_css_params_metab(:,iP));
                text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP))+range_params*.1,...
                    ['n = ' num2str(numel(corr_metab_toss))],'fontsize',18)
                text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP)),...
                    ['r = ' num2str(round(100.*metab.corr_params(iP).r)/100)],'fontsize',18)
                text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP))-range_params*.1,...
                    ['p = ' num2str(round(100.*metab.corr_params(iP).p)/100)],'fontsize',18)
                set(gcf,'color','w')
                set(gca,'FontSize',18,'XColor','k','YColor','k')
                x_span = fit_x(2) - fit_x(1);
                y_span = y_range(2) - y_range(1);
                axis([fit_x(1)-0.1*x_span fit_x(2)+0.1*x_span ...
                    y_range(1)-0.1*y_span y_range(2)-0.1*y_span])
            end
        end
    end
    output.(options.which_metab{iM}) = metab;
end
%% check E/I, if we're looking at Glu & GABA...
% if sum(strcmp('Glu',options.which_metab)) && sum(strcmp('GABA',options.which_metab))
%    
%     corr_metab = options.mrs_struct.Glu(1:numel(...
%         options.mrs_struct.subj_number)) ./ options.mrs_struct.GABA(1:numel(...
%         options.mrs_struct.subj_number));
%     
%     if ~isempty(wrong_grp_idx)
%         warning(['Including only ' num2str(size(all_subj_date,1) - ...
%             numel(wrong_grp_idx)) ' ' all_names{which_group_idx}{1} ...
%             ', as requested...']);
%         corr_metab(wrong_grp_idx) = NaN;
%     end
%     if ~isempty(toss_idx)
%         warning(['Tossing ' num2str(numel(toss_idx)) ' data sets, as requested...']);
%         corr_metab(toss_idx) = NaN;
%     end
%     
%     % toss high CRLB, if requested
% 
%     if options.toss_CRLB
%         Glu_CRLB = options.mrs_struct.SDGlu(1:end-2); % toss last 2 values - mean and sd/mean
%         GABA_CRLB = options.mrs_struct.SDGABA(1:end-2); % toss last 2 values - mean and sd/mean
%         metab_CRLB = max([Glu_CRLB GABA_CRLB],[],2); % use higher for exclusion
%         toss_all = unique([reshape(find_out_mrs,[numel(find_out_mrs) 1]) ; ...
%             reshape(toss_idx,[numel(toss_idx) 1]) ; ...
%             reshape(wrong_grp_idx,[numel(wrong_grp_idx) 1]) ; ...
%             reshape(find_out_css,[numel(find_out_css) 1]) ; ...
%             reshape(toss_catch,[numel(toss_catch) 1])]);
%         metab_CRLB(toss_all) = NaN; % toss excluded subj
% 
% 
%         warning(['tossing ' num2str(sum(metab_CRLB > options.toss_CRLB)) ...
%             ' ' options.which_metab{iM} ' values for CRLB > ' num2str(...
%             options.toss_CRLB)]);
%         corr_metab( metab_CRLB > options.toss_CRLB ) = NaN;
%     end
% 
%     % first correlate thresholds
%     throw_out_nans_metab = isnan(corr_metab) | isnan(corr_css_thresh);
%     corr_css_thresh_metab = corr_css_thresh;
%     corr_css_thresh_metab(throw_out_nans_metab) = [];
%     corr_metab_toss = corr_metab;
%     corr_metab_toss(throw_out_nans_metab) = [];
%     
%     if options.avg_repeats
%         warning('Averaging data sets for repeated subjects...');
%         avg_thresh = -1*ones(size(corr_css_thresh_metab));
%         avg_thresh(unique_idx) = corr_css_thresh_metab(unique_idx);
%         avg_thresh(repeat_scan_idx-1) = nanmean([corr_css_thresh_metab(repeat_scan_idx-1) ...
%             corr_css_thresh_metab(repeat_scan_idx)],2); % avg repeated subj
%         corr_css_thresh_metab = avg_thresh(~(avg_thresh < 0)); % do it this way, to deal with NaNs for tossed values with CRLB > limit
%         
%         avg_metab = -1*ones(size(corr_metab_toss));
%         avg_metab(unique_idx) = corr_metab_toss(unique_idx);
%         avg_metab(repeat_scan_idx-1) = nanmean([corr_metab_toss(repeat_scan_idx-1) ...
%             corr_metab_toss(repeat_scan_idx)],2); % avg repeated subj
%         corr_metab_toss = avg_metab(~(avg_metab < 0)); % do it this way, to deal with NaNs for tossed values with CRLB > limit
%         
%     elseif options.use_which_repeat == 1
%         warning('Using first data set for repeated subjects...');
%         corr_css_thresh_metab = corr_css_thresh_metab(unique_idx);
%         corr_metab_toss = corr_metab_toss(unique_idx);
%         
%     elseif options.use_which_repeat == 2
%         warning('Using second data set for repeated subjects...');
%         corr_css_thresh_metab(repeat_scan_idx-1) = corr_css_thresh_metab(repeat_scan_idx); % replace 1st with 2nd value
%         corr_css_thresh_metab = corr_css_thresh_metab(unique_idx); % keep only replaced (now 2nd) value
%         
%         corr_metab_toss(repeat_scan_idx-1) = corr_metab_toss(repeat_scan_idx); % replace 1st with 2nd value
%         corr_metab_toss = corr_metab_toss(unique_idx); % keep only replaced (now 2nd) value
%         
%     elseif options.use_which_repeat == 3
%         warning('Using BOTH first and second data set for repeated subjects (i.e., some subjects are counted twice)...');
%         
%     else
%         error(['unknown value for options.use_which_repeat = ' num2str(use_which_repeat)]);
%     end
%     
%     if options.plot_rank_corr
%         [~, sort_metab_idx] = sort(corr_metab_toss);
%         [~, sort_thresh_idx] = sort(corr_css_thresh_metab);
%         rank_metab = [];
%         rank_thresh = [];
%         for iS = 1:numel(sort_metab_idx)
%             rank_metab(sort_metab_idx(iS),1) = iS;
%             rank_thresh(sort_thresh_idx(iS),1) = iS;            
%         end
%         corr_metab_toss = rank_metab;
%         corr_css_thresh_metab = rank_thresh;
%     end
%     
%     clear metab
%     
%     [metab.corr_thresh.r, metab.corr_thresh.p] = corr(corr_metab_toss, ...
%         corr_css_thresh_metab, ...
%         'type',options.which_corr);
%     metab.corr_thresh.df = numel(corr_metab_toss)-2;
%         
%     if options.displayFigs
%         figure; hold on
%         
%         use_title = [upper(options.which_group(1)) options.which_group(2:end)...
%             ' subjects'];
%         
%         use_x_label = ['Glu / GABA (arb. units)'];
%         
%         [poly_fit] = polyfit(corr_metab_toss, ...
%             corr_css_thresh_metab, 1);
%         
%         fit_x = [min(corr_metab_toss) max(corr_metab_toss)];
%         fit_y = poly_fit(1).*fit_x + poly_fit(2);
%         y_range = [min(corr_css_thresh_metab) max(corr_css_thresh_metab)];
%         plot(fit_x,fit_y,'k-','linewidth',2)
%         
%         plot(corr_metab_toss(ctrl_idx), corr_css_thresh_metab(ctrl_idx),'ko',...
%             'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
%         
%         plot(corr_metab_toss(rel_idx), corr_css_thresh_metab(rel_idx),'ko',...
%             'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
%         
%         plot(corr_metab_toss(pat_idx), corr_css_thresh_metab(pat_idx),'ko',...
%             'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
%         
%         xlabel(use_x_label,'color','k')
%         ylabel('Avg. thresh. (%)','color','k')
%         title(use_title)
%         
%         range_metab = max(corr_metab_toss) - min(corr_metab_toss);
%         range_thresh = max(corr_css_thresh_metab) - min(corr_css_thresh_metab);
%         text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab),...
%             ['n = ' num2str(numel(corr_metab_toss))],'fontsize',18)
%         text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab)-range_thresh*.225,...
%             ['r = ' num2str(round(100*metab.corr_thresh.r)/100)],'fontsize',18)
%         text(max(corr_metab_toss)-range_metab*.2,max(corr_css_thresh_metab)-range_thresh*.4,...
%             ['p = ' num2str(round(100*metab.corr_thresh.p)/100)],'fontsize',18)
%         set(gcf,'color','w')
%         set(gca,'FontSize',18,'XColor','k','YColor','k','Yscale','log',...
%             'YTick',[0.1 0.25 0.5 1 2.5 5 10 25])
%         x_span = fit_x(2) - fit_x(1);
%         y_span = y_range(2) - y_range(1);
%         axis([fit_x(1)-0.1*x_span fit_x(2)+0.1*x_span ...
%             y_range(1)-0.05*y_span y_range(2)+0.1*y_span])
%     end
%     
%     if options.corr_params
%         % now look at correlating params
%         corr_css_params_metab = corr_css_params;
%         corr_css_params_metab(throw_out_nans_metab,:) = [];
%         param_labels = {'A','p','q','sigma'};
%         for iP = 1:size(corr_css_params_metab,2)
%             [metab.corr_params(iP).r, metab.corr_params(iP).p] = corr(corr_metab_toss, ...
%                 corr_css_params_metab(:,iP), 'type',options.which_corr);
%             metab.corr_params(iP).df = numel(corr_metab_toss)-2;
%             
%             if options.displayFigs
%                 figure; hold on
%                 
%                 [poly_fit] = polyfit(corr_metab_toss, ...
%                     corr_css_params_metab(:,iP), 1);
%                 
%                 fit_x = [min(corr_metab_toss) max(corr_metab_toss)];
%                 fit_y = poly_fit(1).*fit_x + poly_fit(2);
%                 y_range = [min(corr_css_params_metab(:,iP)) ...
%                     max(corr_css_params_metab(:,iP))];
%                 plot(fit_x,fit_y,'k-','linewidth',2)
%                 
%                 plot(corr_metab_toss(ctrl_idx), corr_css_params_metab(ctrl_idx,iP),'ko',...
%                     'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
%                 
%                 plot(corr_metab_toss(rel_idx), corr_css_params_metab(rel_idx,iP),'ko',...
%                     'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
%                 
%                 plot(corr_metab_toss(pat_idx), corr_css_params_metab(pat_idx,iP),'ko',...
%                     'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
%                 
%                 use_x_label = ['Glu / GABA (arb. units)'];
%                 xlabel(use_x_label,'color','k')
%                 ylabel([param_labels{iP} ' (arb.)'],'color','k')
%                 title(use_title)
%                 
%                 range_metab = max(corr_metab_toss) - min(corr_metab_toss);
%                 range_params = max(corr_css_params_metab(:,iP)) - min(corr_css_params_metab(:,iP));
%                 text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP))+range_params*.1,...
%                     ['n = ' num2str(numel(corr_metab_toss))],'fontsize',18)
%                 text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP)),...
%                     ['r = ' num2str(round(100.*metab.corr_params(iP).r)/100)],'fontsize',18)
%                 text(max(corr_metab_toss)-range_metab.*.2,max(corr_css_params_metab(:,iP))-range_params*.1,...
%                     ['p = ' num2str(round(100.*metab.corr_params(iP).p)/100)],'fontsize',18)
%                 set(gcf,'color','w')
%                 set(gca,'FontSize',18,'XColor','k','YColor','k')
%                 x_span = fit_x(2) - fit_x(1);
%                 y_span = y_range(2) - y_range(1);
%                 axis([fit_x(1)-0.1*x_span fit_x(2)+0.1*x_span ...
%                     y_range(1)-0.1*y_span y_range(2)-0.1*y_span])
%             end
%         end
%     end
%     output.(options.which_metab{iM}) = metab;
%     
% end

%% get demographics
if options.include_demog_symp
    % get excluded subjects
    exclude_idx = options.data_quality.failed_binary(:,1,4) == 1;
    exclude_subj_date = options.data_quality.all_dataset_list(exclude_idx,:);
    
    all_subj_date_list = [options.mrs_struct.subj_number options.mrs_struct.date_number ; ...
        options.css_struct.subj_number options.css_struct.date_number];
    all_subj_date_list = unique(all_subj_date_list,'rows');
    
    toss_me = [];
    for iS = 1:size(all_subj_date_list,1)
        if ( sum( all_subj_date_list(iS,1) == exclude_subj_date(:,1) ) & ...
                sum( all_subj_date_list(iS,2) == exclude_subj_date(:,2) ) )
            toss_me = [toss_me iS];
        end
    end
    all_subj_date_list(toss_me,:) = []; % toss excluded subjects
    
    [unique_subj unique_idx] = unique(all_subj_date_list(:,1),'stable');
    
    demog_opt.subj_number = unique_subj;
    demog_opt.date_number = all_subj_date_list(unique_idx,2);
    demog_opt.subj_group_def = options.subj_group_def; % controls, rel, patients
    output.demographics = phcp_demographics( demog_opt );
    
    symp_opt = [];
    symp_opt.subj_number = demog_opt.subj_number;
    symp_opt.date_number = demog_opt.date_number;
    symp_opt.symptom_measure = 'BPRS';
    symp_opt.symp_date_limit = 30;
    
    symp_data = get_phcp_symptoms(symp_opt);
    
    g1_idx = find(symp_opt.subj_number < 2000000);
    g2_idx = find(symp_opt.subj_number >= 2000000 & symp_opt.subj_number < 6000000);
    g3_idx = find(symp_opt.subj_number >= 6000000);
    
    output.symptoms.BPRS.data = [nanmean(symp_data.psy_list(g1_idx)) nanstd(symp_data.psy_list(g1_idx)) ; ...
        nanmean(symp_data.psy_list(g2_idx)) nanstd(symp_data.psy_list(g2_idx)) ; ...
        nanmean(symp_data.psy_list(g3_idx)) nanstd(symp_data.psy_list(g3_idx)) ];
    
    group_idx = [ones(numel(g1_idx),1) ; 2*ones(numel(g2_idx),1) ; 3*ones(numel(g3_idx),1)];
    [p, output.symptoms.BPRS.table, stats] = kruskalwallis(symp_data.psy_list, group_idx, 'off');
end
%% out
output.options = options;
end