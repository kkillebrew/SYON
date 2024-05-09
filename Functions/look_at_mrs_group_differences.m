function [output] = look_at_mrs_group_differences( options )
% usage: [output] = look_at_mrs_group_differences( options )
%
% mps 20181123
%% opt
addpath(genpath('/home/shaw-raid1/matlab_tools/mpsCode')); % add mpsCode to path

if ~exist('options','var')      
    options = [];
end
if ~isfield(options,'displayFigs')
    options.displayFigs = 1; % 1 = yes, 0 = no
end
if ~isfield(options,'mrs_file')
    error('No options.mrs_file provided!')
    % e.g., options.mrs_file = '/home/shaw-raid1/data/MRS/processed_data/20220830_phcp_OCC_193subj_H2O_scaled.csv';
    % options.mrs_file = '/home/shaw-raid1/data/MRS/processed_data/20220830_phcp_PFC_147subj_H2O_scaled.csv';
end
if ~isfield(options,'mrs_n_col')
    %     KWK - using the actual number of columns in csv file (68) (after editing the csv file, by deleting the extra column
%     labels ('met' and 'cormat') and getting rid of the random commas that
%     presumably created).
%     options.mrs_n_col = 68; % These numbers (507 and 439) don't seem to work w/ the output that
    options.mrs_n_col = 504; % 507 = if using Gosia's notes, 439 = LCM default
end
if ~isfield(options,'mrs_header_lines')
    options.mrs_header_lines = 6; % 6 = if using Gosia's notes, 8 = LCM default
%     options.mrs_header_lines = 4; % Worked for KWK along w/ above noted changes.
end
if ~isfield(options,'mrs_overwrite_mat')
    options.mrs_overwrite_mat = 0; % by default, load exisiting .mat file, 1 to overwrite
end
mrs_opt.target_file = options.mrs_file;
mrs_opt.n_col = options.mrs_n_col;
mrs_opt.header_lines = options.mrs_header_lines;
mrs_opt.overwrite_mat = options.mrs_overwrite_mat;
if ~isfield(options,'mrs_struct')
    options.mrs_struct = read_in_LCModel_results(mrs_opt);
end

if ~isfield(options,'toss_subj_num_date')
    options.toss_subj_num_date = []; % this subjects looks like they have bad MRS data on 20190331
    %options.toss_subj_num_date = [6004213 datenum('20190116','yyyymmdd')]; % this subjects looks like they have bad MRS data on 20190331
end
if ~isfield(options,'which_metab')
      options.which_metab = {'Glu','GABA'};
%     options.which_metab = {'Glu','Gln','GABA','NAA','GSH','NAAG'};   % 6 a priori metabolites w/ support in the lit
%    options.which_metab = {'MacY','Asc','Asp','tCho','tCr','GABA','Glc','Gln','Glu','GSH','Ins','Lac','NAA','NAAG','PE','sIns','Tau'};   % all metabs
%    options.which_metab = {'MacY','Asc','Asp','tCho','tCr','Glc','Ins','Lac','PE','sIns','Tau'}; % all metabs minus 6 a priori
    warning('options.which_metab not specified, assuming you want to look at only Glu and GABA...')
end
if ~iscell(options.which_metab) && isstr(options.which_metab)
    options.which_metab = {options.which_metab};
end
% if ~isfield(options,'avg_repeats')
%     options.avg_repeats = 1;
% end
if ~isfield(options,'toss_CRLB')
    options.toss_CRLB = 0; % set value to 0 to turn off, 1 for on
end
if ~isfield(options,'toss_mrs_quality')
    options.toss_mrs_quality = 1;
end
if options.toss_mrs_quality && ~isfield(options,'OCC_mrs_quality_file')
    error('No options.OCC_mrs_quality_file provided!')
    % e.g., options.OCC_mrs_quality_file = '/home/shaw-raid1/data/MRS/processed_data/20220830_phcp_OCC_193subj_H2O_scaled.csv';
end
if options.toss_mrs_quality && ~isfield(options,'PFC_mrs_quality_file')
    error('No options.PFC_mrs_quality_file provided!')
    % e.g., options.PFC_mrs_quality_file = '/home/shaw-raid1/data/MRS/processed_data/20220830_phcp_PFC_147subj_H2O_scaled.csv';
end

% if ~isfield(options,'quality_file') % replace this with data quality from
% sumarrize_phcp_data_status.m
%     options.quality_file = []; % e.g., options.quality_file = '/home/shaw-raid1/data/MRS/processed_data/data_quality/data_coil_parameters_performance_OCC_20200420.csv';
% end
% if options.toss_mrs_quality
%     if ~isempty(options.quality_file)
%         qual_opt.target_file = options.quality_file;
%         load_quality = read_in_gosia_data_quality( qual_opt );
%         quality_data = load_quality.csv_data;
%     else
%         error('you set options.toss_mrs_quality = 1, but options.quality_file is empty or missing, so I quit!')
%     end    
% end
% if ~isfield(options,'outlier_n_SDs')
%     options.outlier_n_SDs = 3;
% end
if ~isfield(options,'corr_metabs')
    options.corr_metabs = 0;
end
if ~isfield (options, 'subj_group_def')
    options.subj_group_def = 1; % 1 = controls, relatives, probands; 
    % 2 = controls, SZ, BP
    % 3 = SZ, schizoaffective (SCA), BP; 
    % 4 = healthy (con+rel), SZ+SCA, bipolar,
    % 5 = controls, probands, relatives (flip order of P & R)
end
if ~isfield(options,'corr_symp')
    options.corr_symp = 0; % correlate symptoms
end
if ~isfield(options,'which_symp')
    options.which_symp = 'SGITotal';
    % valid options currently are SGITotal, BPRSDisorganization, BPRSTotal, SAPSGlobalPositiveSymptoms
end
if ~isfield(options,'plot_groups_separate')
    options.plot_groups_separate = 1;
end
if ~isfield(options,'show_stars')
    options.show_stars = 0;
end
if ~isfield(options,'combine_Cr_Cho')
    options.combine_Cr_Cho = 1;
end
if options.combine_Cr_Cho
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
if ~isfield(options,'skip_last_n_rows')
    options.skip_last_n_rows = 4;
end
if ~isfield(options,'use_demog_covariate')
    options.use_demog_covariate = 0;
end
if ~isfield(options,'add_H2O_lw')
    options.add_H2O_lw = 0;
end
if ~isfield(options,'show_which_stat')
    options.show_which_stat = 'kruskallwallis'; % kruskallwallis or anova
end
if ~isfield(options,'plot_demog')
    options.plot_demog = 0;
end
if ~isfield(options,'log_transform')
    options.log_transform = 0;
end
if ~isfield(options,'plot_retest')
    options.plot_retest = 1;
end

output = [];
%% get mrs file info
for iFile = 1:numel(options.mrs_struct.row_name)-options.skip_last_n_rows % skip last N, mean and sd/mean
    name_idx = regexp(options.mrs_struct.row_name{iFile},'P\d\d\d\d\d\d\d');
    if isempty(name_idx)
        error(['Cannot find subject ID for: ' options.mrs_struct.row_name{name_idx}]);
    end
    options.mrs_struct.subj_number(iFile,1) = str2num(options.mrs_struct.row_name{iFile}...
        (name_idx+1:name_idx+7));
    date_idx = regexp(options.mrs_struct.row_name{iFile},'\d\d\d\d\d\d\d\d');
    options.mrs_struct.date_number(iFile,1) = datenum(options.mrs_struct.row_name{iFile}...
        (date_idx:date_idx+7),'yyyymmdd');
end

%% toss subj
MRS_subj_date = [options.mrs_struct.subj_number options.mrs_struct.date_number];

toss_idx = [];
if ~isempty(options.toss_subj_num_date)
    for iSubj = 1:size(MRS_subj_date,1)
        for iToss = 1:size(options.toss_subj_num_date,1)
            if sum(MRS_subj_date(iSubj,:) == options.toss_subj_num_date(iToss,:)) == 2
                % both subject num and date are the same, so toss
                toss_idx = [toss_idx ; iSubj];
            end
        end
    end
    if ~isempty(toss_idx)
        warning(['Tossing ' num2str(numel(toss_idx)) ' data sets, as requested...']);
        MRS_subj_date(toss_idx,:) = [];
    end
end

find_out_mrs = [];

if options.toss_mrs_quality
    
    summ_opt = [];
    summ_opt.displayFigs = 0;
    summ_opt.check_MRS_quality = 1;
    summ_opt.toss_date = 20170701;
    summ_opt.OCC_mrs_file = options.OCC_mrs_quality_file;
    summ_opt.PFC_mrs_file = options.PFC_mrs_quality_file;
    if ~isempty(strfind(options.mrs_file,'OCC'))
        useROI = 1;
    elseif ~isempty(strfind(options.mrs_file,'PFC'))
        useROI = 2;
    else
        error('Not sure which ROI to use, can''t parse options.mrs_file name...');
    end
    summarize_data = summarize_pHCP_data_status( summ_opt );
    
    mrs_qual_metrics = {'lw_H2O','lw_LCM','SNR','excluded'};
    high_is_good = [0 0 1 0];
    
%     for iQ = 1:numel(mrs_qual_metrics)
%         if ~sum(ismember(quality_data.Properties.VariableNames, ...
%                 mrs_qual_metrics{iQ}))
%             error(['You asked to toss data based on MRS quality metrics, but '...
%                 'the following metric is not included in your MRS quality data set: '...
%                 mrs_qual_metrics{iQ} ' -- Are you loading data quality '...
%                 'metrics from Gosia??']);
%         end
        
    toss_qual = [];
    for iS = 1:size(MRS_subj_date,1)
        subj_idx = find(summarize_data.subject_numbers == MRS_subj_date(iS,1) & ...
            summarize_data.MRS_date_numbers == MRS_subj_date(iS,2));
        if ~isempty(subj_idx)
            toss_qual(iS,1) = squeeze( nansum( summarize_data.mrs_quality_failed_binary(...
                subj_idx, useROI, :),3)) >= 1;
            % mps 20220503 this already includes redcap exclusion
        else
            toss_qual(iS,1) = NaN;
        end
        
        if options.add_H2O_lw
            if ~isempty(subj_idx)
                H2O_lw(iS,1) = summarize_data.mrs_quality_mat(subj_idx, ...
                    useROI, 1);
            else
                H2O_lw(iS,1) = NaN;
            end
                
        end
    end
                
    output.tossed_subj_date = MRS_subj_date(toss_qual == 1,:);
    find_out_mrs = [find_out_mrs ; find(toss_qual == 1)];
    
    if ~isempty(find_out_mrs)
        MRS_subj_date(find_out_mrs,:) = [];
        warning(['tossing ' num2str(numel(unique(find_out_mrs))) ...
            ' subject(s) for poor MRS data quality.']);
    end

    if options.add_H2O_lw
        options.which_metab = cat(2,options.which_metab,'H2O_lw');
        H2O_lw(end+1:end+options.skip_last_n_rows,1) = NaN;
        options.mrs_struct.H2O_lw = H2O_lw;
    end
end
toss_idx = [toss_idx ; find_out_mrs];

%% if we're using symptom levels, find them BEFORE tossing repeated data
if options.corr_symp
    if ~isempty(strfind(lower(options.which_symp),'bprs')) || ~isempty(...
            strfind(lower(options.which_symp),'saps'))  || ~isempty(...
            strfind(lower(options.which_symp),'sans')) 
        date_cutoff = 30;
    else
        date_cutoff = inf;
    end
    
    addpath(genpath('/home/shaw-raid1/matlab_tools/COP_scripts'));
%     psych_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIPsych.csv';
%     psych_data = read_in_psych_data(psych_opts);
%     
%     all_symp = psych_data.(options.which_symp);
%     
%     corr_symp = nan(size(MRS_subj_date(:,1)));
%     
%     for iS = 1:numel(corr_symp)
%         symp_idx = find( strcmp(['P' num2str(MRS_subj_date(iS,1))] , ...
%             psych_data.Record_ID ));
%         if isempty(symp_idx)
%             error('cannot find subject number in psych table!');
%         end
%         date_diff = MRS_subj_date(iS,2) - cell2mat(...
%             psych_data.datenumber(symp_idx) );
%         [~, sort_idx] = sort(abs(date_diff),'ascend'); % find the most recent symptom dates
%         
%         for iSort = 1:numel(sort_idx)
%             if (date_diff(sort_idx(iSort)) <= date_cutoff) & (~isnan(all_symp...
%                     (symp_idx(sort_idx(iSort)))) ) % use most recent date that is below cuttoff and not missing
%                 corr_symp(iS) = all_symp(symp_idx(sort_idx(iSort)));
%                 break
%             end
%         end
%     end
    sympt_opt.symp_date_limit = date_cutoff;
    sympt_opt.symptom_measure = options.which_symp;
    sympt_opt.subj_number = MRS_subj_date(:,1);
    sympt_opt.date_number = MRS_subj_date(:,2);
    sympt_data = get_phcp_symptoms( sympt_opt );
    corr_symp = sympt_data.psy_list;
end
%% sort out repeated data
% if options.avg_repeats
[~, unique_idx] = unique(MRS_subj_date(:,1),'rows','stable');
[~, repeat_scan_idx] = setxor(MRS_subj_date(:,:),...
    MRS_subj_date(unique_idx,:),'rows','stable'); % find not intersection

for iRep = 1:numel(repeat_scan_idx)
    if MRS_subj_date(repeat_scan_idx(iRep),1) ~= MRS_subj_date(...
            repeat_scan_idx(iRep)-1,1)
        error('MPS wrote bad logic, and subj ID for repeated data ~= idx - 1 (i.e., subjects are not in order by ID #)');
    end
end

output.retest.date.mean = mean(abs(MRS_subj_date(repeat_scan_idx,2) - ...
    MRS_subj_date(repeat_scan_idx-1,2)));
output.retest.date.median = median(abs(MRS_subj_date(repeat_scan_idx,2) - ...
    MRS_subj_date(repeat_scan_idx-1,2)));
output.retest.date.sd = std(abs(MRS_subj_date(repeat_scan_idx,2) - ...
    MRS_subj_date(repeat_scan_idx-1,2)));
output.retest.date.range = [min(abs(MRS_subj_date(repeat_scan_idx,2) - ...
    MRS_subj_date(repeat_scan_idx-1,2))) ...
    max(abs(MRS_subj_date(repeat_scan_idx,2) - ...
    MRS_subj_date(repeat_scan_idx-1,2)))];

output.retest.group_Ns.control = sum(MRS_subj_date(repeat_scan_idx,1) ...
    < 2000000);
output.retest.group_Ns.relative = sum(MRS_subj_date(repeat_scan_idx,1) ...
    >= 2000000 & MRS_subj_date(repeat_scan_idx,1) < 6000000);
output.retest.group_Ns.proband = sum(MRS_subj_date(repeat_scan_idx,1) ...
    >= 6000000);

for iRep = 1:numel(repeat_scan_idx)
    if MRS_subj_date(repeat_scan_idx(iRep),1) ~= MRS_subj_date(repeat_scan_idx(iRep)-1,1)
        % make sure that the repeated scans are immediately after the
        % 1st scan for that subject in the list
        error(['Session # ' num2str(repeat_scan_idx(iRep)) ' is a repeat,'...
            'but is not the same subj# as the scan before it??']);
    end
    if repeat_scan_idx(iRep) > 2
        if MRS_subj_date(repeat_scan_idx(iRep),1) == MRS_subj_date(repeat_scan_idx(iRep)-2,1)
            % make sure there are no 3x repeats..
            error(['Session # ' num2str(repeat_scan_idx(iRep)) ' is a 3x repeat??']);
        end
    end
end

MRS_subj_date_with_repeats = MRS_subj_date;
% warning('averaging repeated subjects, as requested...')
MRS_subj_date(repeat_scan_idx,:) = [];
% end
%% Subject group indices (from refit_COP_dataRK) added by MPS 13 NOV 2019
% demog_opts.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
% demog_data = read_in_demog_data(demog_opts);

demog_opts = [];
demog_opts.subj_group_def = options.subj_group_def;
subj_number = MRS_subj_date_with_repeats(:,1);
date_number = MRS_subj_date_with_repeats(:,2);
demog_opts.subj_number = subj_number;
demog_opts.date_number = date_number;
demog_data = phcp_demographics( demog_opts );

% dx_list = nan(numel(subj_number),1);
% missing_dx_list = [];
% for iSubj = 1:numel(subj_number)
%     dx_idx = strcmp(['P' num2str(subj_number(iSubj))],demog_data.Record_ID);
%     if isempty(dx_idx) || (sum(dx_idx) == 0) % if this subject isn't in the demographics .csv file
%         missing_dx_list = [missing_dx_list ; subj_number(iSubj)];
%         continue
%     end
%     dx_list(iSubj) = demog_data.Dx_code(dx_idx);
% end

%Legend for dx codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
%6=Panic; 7=DeprNOS; 8=PsychNOS; 9=ADHD

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
% 

g1_idx_bin = g1_idx;
g2_idx_bin = g2_idx;
g3_idx_bin = g3_idx;
g1_idx = find(g1_idx); % keep binary indices, but also make numeric
g2_idx = find(g2_idx);
g3_idx = find(g3_idx);

g1_num = subj_number(g1_idx);
g2_num = subj_number(g2_idx);
g3_num = subj_number(g3_idx);

[~, g1_unique] = unique(g1_num);
g1_unique = g1_idx(g1_unique);
[~, g2_unique] = unique(g2_num);
g2_unique = g2_idx(g2_unique);
[~, g3_unique] = unique(g3_num);
g3_unique = g3_idx(g3_unique);

%% look at group differences in whichever metabolites were selected...
all_KW_p_to_FDR.g1_g2 = [];
all_KW_p_to_FDR.g1_g3 = [];
all_KW_p_to_FDR.g2_g3 = [];
all_KW_p_to_FDR.all3 = [];

all_anova_p_to_FDR.g1_g2 = [];
all_anova_p_to_FDR.g1_g3 = [];
all_anova_p_to_FDR.g2_g3 = [];
all_anova_p_to_FDR.all3 = [];

for iM = 1:numel(options.which_metab)
    metab = options.mrs_struct.(options.which_metab{iM})(1:end-...
        options.skip_last_n_rows); % toss last N values - mean and sd/mean    
    metab(toss_idx) = []; % toss excluded subj
    
    checkSD = 0;
    eval(['checkSD = isfield(options.mrs_struct,''SD' options.which_metab{iM} ''');']); % check if there is an SD for this metab

    if checkSD
        eval(['metab_CRLB = options.mrs_struct.SD' options.which_metab{iM} '(1:end-2);']); % toss last 2 values - mean and sd/mean
        metab_CRLB(toss_idx) = []; % toss excluded subj


        if options.toss_CRLB % remove values that are unreliable (CRLB too high)
            warning(['tossing ' num2str(sum(metab_CRLB > options.toss_CRLB)) ...
                ' ' options.which_metab{iM} ' values for CRLB > ' num2str(...
                options.toss_CRLB)]);
            metab( metab_CRLB > options.toss_CRLB ) = NaN;
        end
        this_metab.CRLB = metab_CRLB;
    end
    
    clear this_metab
%     if options.avg_repeats

    this_metab.stats.corr_retest.type = 'Spearman';

    use_metab_corr_idx = ~isnan(metab(repeat_scan_idx-1)) & ~isnan(...
        metab(repeat_scan_idx));

    repeat_scan_idx = repeat_scan_idx( use_metab_corr_idx ); % exclude NaNs
    [this_metab.stats.corr_retest.r, this_metab.stats.corr_retest.p] = ...
        corr(metab(repeat_scan_idx-1),metab(repeat_scan_idx),...
        'type',this_metab.stats.corr_retest.type);
    this_metab.stats.corr_retest.df = numel(repeat_scan_idx)-2;

    this_metab.stats.ICC_retest = ICC(1, 'k', [metab(repeat_scan_idx-1) ...
        metab(repeat_scan_idx)]);

    if options.displayFigs && options.plot_retest
        figure; hold on

        [poly_fit] = polyfit(metab(repeat_scan_idx-1), ...
            metab(repeat_scan_idx), 1);

        fit_x = [min(metab(repeat_scan_idx-1)) max(metab(repeat_scan_idx-1))];
        fit_y = poly_fit(1).*fit_x + poly_fit(2);
        y_range = [min(metab(repeat_scan_idx)) max(metab(repeat_scan_idx))];

        g1_with_rep = find( MRS_subj_date_with_repeats(:,1) < 2000000 );
        g2_with_rep = find( MRS_subj_date_with_repeats(:,1) >= 2000000 & ...
            MRS_subj_date_with_repeats(:,1) < 2000000 );
        g3_with_rep = find( MRS_subj_date_with_repeats(:,1) >= 6000000 );
        rep_g1_idx = intersect(repeat_scan_idx, g1_with_rep);
        rep_g2_idx = intersect(repeat_scan_idx, g2_with_rep);
        rep_g3_idx = intersect(repeat_scan_idx, g3_with_rep);

        if options.plot_groups_separate
            plot_colors = {[0.33 1 0.33],[0.33 0.33 1],[1 0.33 0.33]};
        else
            plot_colors = {'w','w','w'};
        end

        use_legend = [];
        idx_leg = 0;
        if ~isempty(rep_g1_idx)
            plot(-1, -1 ,'ko',...
                'MarkerFaceColor',plot_colors{1},'linewidth',2,'MarkerSize',8)
            idx_leg = idx_leg+1;
            use_legend{idx_leg} = [g1_short ', n = ' num2str(numel(rep_g1_idx))];
        end
        if ~isempty(rep_g2_idx)
            plot(-1, -1 ,'ko',...
                'MarkerFaceColor',plot_colors{2},'linewidth',2,'MarkerSize',8)
            idx_leg = idx_leg+1;
            use_legend{idx_leg} = [g2_short ', n = ' num2str(numel(rep_g2_idx))];
        end
        if ~isempty(rep_g3_idx)
            plot(-1, -1 ,'ko',...
                'MarkerFaceColor',plot_colors{3},'linewidth',2,'MarkerSize',8)
            idx_leg = idx_leg+1;
            use_legend{idx_leg} = [g3_short ', n = ' num2str(numel(rep_g3_idx))];
        end
%         plot(fit_x,fit_y,'k-','linewidth',2)
        plot([-10 20],[-10 20],'k--','linewidth',2)

        plot(metab(rep_g1_idx-1), metab(rep_g1_idx), 'ko', ...
            'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', plot_colors{1})
        plot(metab(rep_g2_idx-1), metab(rep_g2_idx), 'ko', ...
            'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', plot_colors{2})
        plot(metab(rep_g3_idx-1), metab(rep_g3_idx), 'ko', ...
            'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', plot_colors{3})

        ylabel([options.which_metab{iM} ' scan 2 (mM)'],'Color','k');
        xlabel([options.which_metab{iM} ' scan 1 (mM)'],'Color','k');
        set(gcf,'color','w','POS',[357   275   560   560])
        box off
        set(gca,'XColor','k','YColor','k','Fontsize',18)

        both_range = [ min([metab(repeat_scan_idx-1) ; metab(repeat_scan_idx)]) ...
            max([metab(repeat_scan_idx-1) ; metab(repeat_scan_idx)]) ];
        both_diff = both_range(2) - both_range(1);
        axis([both_range(1)-both_diff*0.1 both_range(2)+both_diff*0.1 ...
            both_range(1)-both_diff*0.1 both_range(2)+both_diff*0.1])
        text(fit_x(1),both_range(2),...
            ['n = ' num2str(numel(repeat_scan_idx))],'fontsize',18)
        text(fit_x(1),both_range(2) - both_diff*0.1,...
            ['ICC = ' num2str(round(100*this_metab.stats.ICC_retest)/100)],'fontsize',18)
        use_tick = get(gca,'YTick');
        set(gca,'XTick',use_tick,'DataAspectRatio',[1 1 1]);

        if options.plot_groups_separate
            legend(use_legend,'Location','SouthEast')
        end

        pause(1)
    end
    
    this_metab.data = metab;
    this_metab.g1_data = metab(g1_idx);
    this_metab.g1_mean = mean(this_metab.g1_data);
    this_metab.g1_median = median(this_metab.g1_data);
    this_metab.g1_sd = std(this_metab.g1_data);
    
    this_metab.g2_data = metab(g2_idx);
    this_metab.g2_mean = mean(this_metab.g2_data);
    this_metab.g2_median = median(this_metab.g2_data);
    this_metab.g2_sd = std(this_metab.g2_data);
    
    this_metab.g3_data = metab(g3_idx);
    this_metab.g3_mean = mean(this_metab.g3_data);
    this_metab.g3_median = median(this_metab.g3_data);
    this_metab.g3_sd = std(this_metab.g3_data);
    
    % do anova not ttest, repeated subj    
    show_anova = 'off';
    
    grp_comp_list = {'g1','g2';'g1','g3';'g2','g3'};
    grp_comp_data = {'g1_data','g2_data';'g1_data','g3_data';'g2_data','g3_data'};
    grp_comp_idx = {g1_idx,g2_idx ; g1_idx,g3_idx ; g2_idx,g3_idx};
    grp_comp_name = {'g1_g2','g1_g3','g2_g3'};
    
    for iComp = 1:numel(grp_comp_name)
        
        all_data = [this_metab.(grp_comp_data{iComp,1}) ; ...
            this_metab.(grp_comp_data{iComp,2})];
        if options.log_transform
            all_data( all_data == 0 ) = 0.001;
            all_data = log10(all_data);
        end
        all_subj = [subj_number(grp_comp_idx{iComp,1}) ; ...
            subj_number(grp_comp_idx{iComp,2})];
        all_group = [ones(size(grp_comp_idx{iComp,1})) ; ...
            2.*ones(size(grp_comp_idx{iComp,2}))];
        
        if options.use_demog_covariate
            all_age = [demog_data.Age.(grp_comp_list{iComp,1}).data ; ...
                demog_data.Age.(grp_comp_list{iComp,2}).data];
            all_gender = [demog_data.Gender.(grp_comp_list{iComp,1}).data ; ...
                demog_data.Gender.(grp_comp_list{iComp,2}).data];
            all_BMI = [demog_data.BMI.(grp_comp_list{iComp,1}).data ; ...
                demog_data.BMI.(grp_comp_list{iComp,2}).data];
            
            nest = zeros(5,5);
            nest(1,2) = 1;
            nest(1,4) = 1;
            
            [p, this_metab.stats.anova.(grp_comp_name{iComp}).table] = ...
                anovan(all_data(:),{all_subj(:),all_group(:),all_age(:),...
                all_gender(:),all_BMI(:)},'random',1,'continuous',[3 5],'nested',nest,...
                'varnames',{'subj','group','age','gender','BMI'},...
                'model','linear','display',show_anova);
            
            % also try lme
            tbl = table(all_data(:),all_subj(:),all_group(:),all_age(:),...
                all_gender(:),all_BMI(:), 'VariableNames', {'metab','subj','group',...
                'age','gender','BMI'});
            tbl.subj = categorical(tbl.subj);
            tbl.group = categorical(tbl.group);
            tbl.gender = categorical(tbl.gender);
            formula = 'metab ~ group + age + gender + BMI + (1 | subj)';
            this_metab.stats.lme.(grp_comp_name{iComp}) = fitlme(tbl, formula);

            
        else
            nest = zeros(2,2);
            nest(1,2) = 1;
            
            [p, this_metab.stats.anova.(grp_comp_name{iComp}).table] = ...
                anovan(all_data(:),{all_subj(:),...
                all_group(:)},'random',1,'nested',nest,'varnames',{'subj','group'},...
                'model','full','display',show_anova);
        end
        
        this_metab.stats.anova.(grp_comp_name{iComp}).p_uncorr = p(2); % group effect;
        this_metab.stats.anova.(grp_comp_name{iComp}).p_bonf = ...
            this_metab.stats.anova.(grp_comp_name{iComp}).p_uncorr.*(...
            numel(options.which_metab));
        if this_metab.stats.anova.(grp_comp_name{iComp}).p_bonf > 1
            this_metab.stats.anova.(grp_comp_name{iComp}).p_bonf = 1;
        end
        all_anova_p_to_FDR.(grp_comp_name{iComp}) = [all_anova_p_to_FDR.(grp_comp_name{iComp}) ...
            this_metab.stats.anova.(grp_comp_name{iComp}).p_uncorr]; % placeholder, come back at the end and correct
    end
    
    % anova all 3 groups
    all_data = [this_metab.g1_data ; this_metab.g2_data ; this_metab.g3_data];
    if options.log_transform
        all_data( all_data == 0 ) = 0.001;
        all_data = log10(all_data);
    end
    all_subj = [subj_number(g1_idx) ; subj_number(g2_idx) ; subj_number(g3_idx)];
    all_group = [ones(size(g1_idx)) ; 2.*ones(size(g2_idx)) ; 3.*ones(size(g3_idx))];
    
    if options.use_demog_covariate
        all_age = [demog_data.Age.g1.data ; demog_data.Age.g2.data ; demog_data.Age.g3.data];
        all_gender = [demog_data.Gender.g1.data ; demog_data.Gender.g2.data ; demog_data.Gender.g3.data];
        all_BMI = [demog_data.BMI.g1.data ; demog_data.BMI.g2.data ; demog_data.BMI.g3.data];
        
        nest = zeros(5,5);
        nest(1,2) = 1;
        nest(1,4) = 1;
        
        [p, this_metab.stats.anova.all3.table] = ...
            anovan(all_data(:),{all_subj(:),all_group(:),all_age(:),...
            all_gender(:),all_BMI(:)},'random',1,'continuous',[3 5],'nested',nest,...
            'varnames',{'subj','group','age','gender','BMI'},...
            'model','linear','display',show_anova);
        
        % also try lme
        tbl = table(all_data(:),all_subj(:),all_group(:),all_age(:),...
            all_gender(:),all_BMI(:), 'VariableNames', {'metab','subj','group',...
            'age','gender','BMI'});
        tbl.subj = categorical(tbl.subj);
        tbl.group = categorical(tbl.group);
        tbl.gender = categorical(tbl.gender);
        formula = 'metab ~ group + age + gender + BMI + (1 | subj)';
        this_metab.stats.lme.all3 = fitlme(tbl, formula);
        
    else
    nest = zeros(2,2);
    nest(1,2) = 1;
    show_anova = 'off';
    
    [p, this_metab.stats.anova.all3.table] = ...
        anovan(all_data(:),{all_subj(:),...
        all_group(:)},'random',1,'nested',nest,'varnames',{'subj','group'},...
        'model','full','display',show_anova);
    
    end
    
    this_metab.stats.anova.all3.p_uncorr = p(2); % group effect;
    this_metab.stats.anova.all3.p_bonf = this_metab.stats.anova.all3.p_uncorr.*(...
        numel(options.which_metab));
    if this_metab.stats.anova.all3.p_bonf > 1
        this_metab.stats.anova.all3.p_bonf = 1;
    end
    all_anova_p_to_FDR.all3 = [all_anova_p_to_FDR.all3 ...
        this_metab.stats.anova.all3.p_uncorr]; % placeholder, come back at the end and correct
    
    showKW = 'off';
        
    % 2 group comp
    grp_comp_u_idx = {g1_unique,g2_unique ; g1_unique,g3_unique ; ...
        g2_unique,g3_unique};

    for iComp = 1:numel(grp_comp_name)
        group_data = [this_metab.data([grp_comp_u_idx{iComp,1} ; ...
            grp_comp_u_idx{iComp,2} ])];
        group_idx = [ones(numel(grp_comp_u_idx{iComp,1}),1) ; ...
            2*ones(numel(grp_comp_u_idx{iComp,2}),1)];
        
        [p, this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).table, ...
            this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).stats] = kruskalwallis(...
            group_data, group_idx, showKW);
        this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).p = p;
        all_KW_p_to_FDR.(grp_comp_name{iComp}) = [...
            all_KW_p_to_FDR.(grp_comp_name{iComp}) p]; % placeholder, come back at the end and correct
        this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).p_bonf = p*numel(options.which_metab);
        if this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).p_bonf > 1
            this_metab.stats.kruskallwallis.(grp_comp_name{iComp}).p_bonf = 1;
        end
    
    end
    % all 3 groups    
    group_data = [this_metab.data([g1_unique ; g2_unique ; g3_unique])];
    group_idx = [ones(numel(g1_unique),1) ; ...
        2*ones(numel(g2_unique),1) ; ...
        3*ones(numel(g3_unique),1)];
    
    [p, this_metab.stats.kruskallwallis.all3.table, ...
        this_metab.stats.kruskallwallis.all3.stats] = kruskalwallis(...
        group_data, group_idx, showKW);
    this_metab.stats.kruskallwallis.all3.p = p;
    all_KW_p_to_FDR.all3 = [all_KW_p_to_FDR.all3 p]; % placeholder, come back at the end and correct
    this_metab.stats.kruskallwallis.all3.p_bonf = p*numel(options.which_metab);
    if this_metab.stats.kruskallwallis.all3.p_bonf > 1
        this_metab.stats.kruskallwallis.all3.p_bonf = 1;
    end
    
    [p, this_metab.stats.levene] = vartestn(group_data, group_idx, ...
        'display', showKW, 'testtype', 'LeveneAbsolute');
    this_metab.stats.levene.p = p;
          
    % correlate metab with symptoms, if requested
    if options.corr_symp
        
        this_metab.corr_symp.name = options.which_symp;
        this_metab.corr_symp.type = 'Spearman';
        this_metab.corr_symp.symp_data = corr_symp;
        
        use_unique = [g1_unique ; g2_unique ; g3_unique];
        corr_symp_idx = use_unique(find(~isnan(corr_symp(use_unique)) &...
            ~isnan(metab(use_unique))));
        g1_symp_idx = find(~isnan(corr_symp(g1_unique)) &...
            ~isnan(metab(g1_unique)));
        g1_symp_idx = g1_unique(g1_symp_idx);
        g2_symp_idx = find(~isnan(corr_symp(g2_unique)) &...
            ~isnan(metab(g2_unique)));
        g2_symp_idx = g2_unique(g2_symp_idx);
        g3_symp_idx = find(~isnan(corr_symp(g3_unique)) &...
            ~isnan(metab(g3_unique)));
        g3_symp_idx = g3_unique(g3_symp_idx);
        
        [this_metab.corr_symp.r, this_metab.corr_symp.p] = corr(...
            metab(corr_symp_idx), corr_symp(corr_symp_idx), 'type',...
            this_metab.corr_symp.type);
        this_metab.corr_symp.df = numel(corr_symp_idx)-2;
        
        if options.displayFigs
            figure; hold on
            pause(1) % let this finish plotting...
            
            [poly_fit] = polyfit(metab(corr_symp_idx), ...
                corr_symp(corr_symp_idx), 1);
                        
            fit_x = [min(metab(corr_symp_idx)) max(metab(corr_symp_idx))];
            fit_y = poly_fit(1).*fit_x + poly_fit(2);
            y_range = [min(corr_symp(corr_symp_idx)) max(corr_symp(corr_symp_idx))];
            plot(fit_x,fit_y,'k-','linewidth',2)
            
            plot(metab(g1_symp_idx), corr_symp(g1_symp_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{1})
            
            plot(metab(g2_symp_idx), corr_symp(g2_symp_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{2})
            
            plot(metab(g3_symp_idx), corr_symp(g3_symp_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{3})
            
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0,...
                ['n = ' num2str(numel(corr_symp_idx))],'fontsize',18)
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.1,...
                ['r = ' num2str(round(100*this_metab.corr_symp.r)/100)],'fontsize',18)
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.2,...
                ['p = ' num2str(round(100*this_metab.corr_symp.p)/100)],'fontsize',18)

            ylabel([options.which_symp ' score'],'Color','k');
            if strcmp(options.which_metab{iM},'MacY')
                use_x_label = 'MacM (arb. units)';
            else
                use_x_label = [options.which_metab{iM} ' (mM)'];
            end
            xlabel(use_x_label,'Color','k');
            set(gcf,'color','w','POS',[357   275   560   560])
            box off
            set(gca,'XColor','k','YColor','k','Fontsize',18)
        end
        
        % do correlation of symptoms with test-retest data
        
        % variance is higher for symptoms than for metabs, so keep metabs
        % on Y to avoid inflating slope values
        t1_y = metab(repeat_scan_idx-1); % metab, time 1
        t2_y = metab(repeat_scan_idx); % metab, time 2
        
        t1_x = corr_symp(repeat_scan_idx-1); % symptoms, time 1
        t2_x = corr_symp(repeat_scan_idx); % symptoms, time 2
        
        symptom_retest_slope = (t2_y - t1_y) ./ (t2_x - t1_x); % rise over run
        symptom_retest_slope( symptom_retest_slope == Inf | ...
            symptom_retest_slope == -Inf ) = 0; % if the symptom values didn't change, then slope should be zero
        
        [h, this_metab.symptom_slope_ttest.p, ci, ...
            this_metab.symptom_slope_ttest.stats] = ...
            ttest(symptom_retest_slope);
        
        if options.displayFigs
            plot_idx = ~isnan(symptom_retest_slope);
            
            figure
            hold on
            plot([t1_x(plot_idx) t2_x(plot_idx)]',[t1_y(plot_idx) t2_y(plot_idx)]',...
                '-o','color',[0.5 0.5 0.5],...
                'MarkerFaceColor',corr_colors{3})
            box off
            set(gcf,'color','w')
            set(gca,'fontsize',18,'XColor','k','YColor','k')
            xlabel(options.which_symp,'color','k')
            if strcmp(options.which_metab{iM},'MacY')
                use_y_label = 'MacM (arb. units)';
            else
                use_y_label = [options.which_metab{iM} ' (mM)'];
            end
            ylabel(use_y_label,'color','k')
            
            [sorted_x sort_idx] = sort([t1_x t2_x],2); % just for plotting a mean
            sorted_y = [t1_y t2_y];
            for iRow = 1:size(sorted_y,1)
                sorted_y(iRow,:) = [sorted_y(iRow,sort_idx(iRow,1)) ...
                    sorted_y(iRow,sort_idx(iRow,2))];
            end
            
            mean_lower_x  = nanmean(sorted_x(plot_idx,1));
            mean_higher_x  = nanmean(sorted_x(plot_idx,2));
            mean_lower_y  = nanmean(sorted_y(plot_idx,1));
            mean_higher_y  = nanmean(sorted_y(plot_idx,2));
            
            plot([mean_lower_x mean_higher_x]',[mean_lower_y mean_higher_y]',...
                '-o','color','k','linewidth',3,...
                'MarkerFaceColor',corr_colors{3},'MarkerSize',10)
            
            title(['Change in ' options.which_metab{iM} ...
                ' with change in ' options.which_symp])
        end
        
    end
    
    % then do demographics
    use_demog_list = {'Age','BMI'};
    
    for iD = 1:numel(use_demog_list)
        this_metab.corr_demog.(use_demog_list{iD}).type = 'Spearman';
        
        corr_demo = nan(numel(subj_number),1);
        corr_demo(g1_idx) = demog_data.(use_demog_list{iD}).g1.data;
        corr_demo(g2_idx) = demog_data.(use_demog_list{iD}).g2.data;
        corr_demo(g3_idx) = demog_data.(use_demog_list{iD}).g3.data;
%         corr_demo = demog_data.(use_demog_list{iD}).all.data;
% mps 20230605 fixing issue with subject_group_def = 3

        use_unique = [g1_unique ; g2_unique ; g3_unique];
        
        corr_demo_idx = use_unique(find(~isnan(corr_demo(use_unique)) &...
            ~isnan(metab(use_unique))));

        g1_demo_idx = find(~isnan(corr_demo(g1_unique)) &...
            ~isnan(metab(g1_unique)));
        g1_demo_idx = g1_unique(g1_demo_idx);
        g2_demo_idx = find(~isnan(corr_demo(g2_unique)) &...
            ~isnan(metab(g2_unique)));
        g2_demo_idx = g2_unique(g2_demo_idx);
        g3_demo_idx = find(~isnan(corr_demo(g3_unique)) &...
            ~isnan(metab(g3_unique)));
        g3_demo_idx = g3_unique(g3_demo_idx);
        
        [this_metab.corr_demog.(use_demog_list{iD}).r, ...
            this_metab.corr_demog.(use_demog_list{iD}).p] = corr(...
            metab(corr_demo_idx), corr_demo(corr_demo_idx), 'type',...
            this_metab.corr_demog.(use_demog_list{iD}).type);
        this_metab.corr_demog.(use_demog_list{iD}).df = ...
            numel(corr_demo_idx)-2;
        
        if options.displayFigs && options.plot_demog
            figure; hold on
            pause(1) % let this finish plotting...
            
            [poly_fit] = polyfit(corr_demo(corr_demo_idx), ...
                metab(corr_demo_idx), 1);
                        
            fit_x = [min(corr_demo(corr_demo_idx)) max(corr_demo(corr_demo_idx))];
            fit_y = poly_fit(1).*fit_x + poly_fit(2);
            y_range = [min(metab(corr_demo_idx)) max(metab(corr_demo_idx))];
            plot(fit_x,fit_y,'k-','linewidth',2)
            
            plot(corr_demo(g1_demo_idx), metab(g1_demo_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{1})
            
            plot(corr_demo(g2_demo_idx), metab(g2_demo_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{2})
            
            plot(corr_demo(g3_demo_idx), metab(g3_demo_idx), 'ko', ...
                'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', ...
                corr_colors{3})
            
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0,...
                ['n = ' num2str(numel(corr_demo_idx))],'fontsize',18)
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.1,...
                ['r = ' num2str(round(100*this_metab.corr_demog.(...
                use_demog_list{iD}).r)/100)],'fontsize',18)
            text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.2,...
                ['p = ' num2str(round(100*this_metab.corr_demog.(...
                use_demog_list{iD}).p)/100)],'fontsize',18)

            xlabel([use_demog_list{iD}],'Color','k');
            if strcmp(options.which_metab{iM},'MacY')
                use_y_label = 'MacM (arb. units)';
            else
                use_y_label = [options.which_metab{iM} ' (mM)'];
            end
            ylabel(use_y_label,'Color','k');
            set(gcf,'color','w','POS',[357   275   560   560])
            box off
            set(gca,'XColor','k','YColor','k','Fontsize',18)
        end
    end
    
    
    output.(options.which_metab{iM}) = this_metab;
        
%% plot, if requested 
    if options.displayFigs        
        figure; hold on
        pause(1) % let this finish plotting...
        
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',4)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',2)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'--','color',[0.5 0.5 0.5],...
            'linewidth',2)
        h = boxplot(group_data, group_idx);
        set(h,'linewidth',2)
        for iH = 1:size(h,2)
            set(h(6,iH), 'linewidth', 4)
            set(h(:,iH), 'color', use_colors{iH})
            set(h(:,iH), 'MarkerEdgeColor', use_colors{iH})
        end
        
        hp = plotSpread({group_data},'binWidth',0.1,...
                'distributionColors',{[0.7 0.7 0.7]},...
                'distributionIdx',group_idx,'spreadWidth',0.5);
        set(hp{1},'MarkerSize',14)
        
        if options.show_stars
            ax = axis;
            plot([1 3],repmat(1.03*max(group_data),[1 2]),'k-','linewidth',2)
            plot([2], 1.45*max(group_data) ,'kp','MarkerFaceColor','k',...
                'linewidth',2)
            axis([ax(1) ax(2) ax(3) 1.06*max(group_data)])
        end
            
        % Plot the stats on the graph below the title - KWK 20201216
        if strcmp(options.show_which_stat,'kruskallwallis')
            use_grp_num = 2;
            use_stat_num = 5;
            use_p_num = 6;
        elseif strcmp(options.show_which_stat,'anova')
            use_grp_num = 3;
            use_stat_num = 6;
            use_p_num = 7;
        end
        
        if this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_stat_num} < 10
            n_digit_stat = '2';
        elseif this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_stat_num} < 100
            n_digit_stat = '1';
        else
            n_digit_stat = '0';
        end
        if this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_p_num} >= 0.195
            n_digit_p = '1';
        elseif this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_p_num} > 0.095
            n_digit_p = '2';
        else
            n_digit_p = '3';
        end
        
        if strcmp(options.show_which_stat,'kruskallwallis')
            title({sprintf('%s%s','\bf ',options.which_metab{iM}),...
                sprintf(['%s%s%s%d%s%.' n_digit_stat 'f%s%.' n_digit_p 'f'],...
                '\rm ',this_metab.stats.(options.show_which_stat).all3.table{1,use_stat_num},'(',...
                this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,3},') = ',...
                this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_stat_num},...
                ', p = ',this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_p_num})})
        elseif strcmp(options.show_which_stat,'anova')
            title({sprintf('%s%s','\bf ',options.which_metab{iM}),...
                sprintf(['%s%s%s%d%s%d%s%.' n_digit_stat 'f%s%.' n_digit_p 'f'],...
                '\rm ',this_metab.stats.(options.show_which_stat).all3.table{1,use_stat_num},'(',...
                this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,3},',',...
                this_metab.stats.(options.show_which_stat).all3.table{2,3},') = ',...
                this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_stat_num},...
                ', p = ',this_metab.stats.(options.show_which_stat).all3.table{use_grp_num,use_p_num})})
        end

        set(gca,'XTick',[1 2 3],'XTickLabel',{[g1_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 1))))], [g2_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 2))))], [g3_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 3))))]})
        if strcmp(options.which_metab{iM},'MacY')
            use_y_label = 'MacM (arb. units)';
        else
            use_y_label = [options.which_metab{iM} ' (mM)'];
        end
        ylabel(use_y_label,'Color','k');
        set(gcf,'color','w','POS',[95   185   750   420])
        box off
        h_leg = legend('Median','25-75%','Range','Data');
        set(h_leg,'Location','northeast','textcolor','k')
        set(gca,'XColor','k','YColor','k','Fontsize',18)
        if options.log_transform
            set(gca,'YScale','log')
        end
        
        % Plot the stats on the graph - KWK 20201216
        
    end
end
% FDR correction, KW 2 groups
for iComp = 1:numel(grp_comp_name)
    [sort_p, sort_idx] = sort(all_KW_p_to_FDR.(grp_comp_name{iComp}));

    FDR_p = sort_p .* [numel(options.which_metab):-1:1];
    FDR_p(FDR_p > 1) = 1;

    for iM = 1:numel(options.which_metab)
        output.(options.which_metab{iM}).stats.kruskallwallis.(...
            grp_comp_name{iComp}).p_FDR = ...
            FDR_p(sort_idx == iM);
    end
end

% FDR correction, KW all3
[sort_p, sort_idx] = sort(all_KW_p_to_FDR.all3);

FDR_p = sort_p .* [numel(options.which_metab):-1:1];
FDR_p(FDR_p > 1) = 1;

for iM = 1:numel(options.which_metab)
    output.(options.which_metab{iM}).stats.kruskallwallis.all3.p_FDR = FDR_p(sort_idx == iM);
end

output.all_p.KW.uncorr_p = all_KW_p_to_FDR.all3;
output.all_p.KW.FDR_p = FDR_p(sort_idx);
output.all_p.KW.bonf_p = all_KW_p_to_FDR.all3(sort_idx)...
    .*numel(all_KW_p_to_FDR.all3);
output.all_p.KW.bonf_p(output.all_p.KW.bonf_p > 1) = 1;

% FDR correction, anova 2 groups
for iComp = 1:numel(grp_comp_name)
    [sort_p, sort_idx] = sort(all_anova_p_to_FDR.(grp_comp_name{iComp}));

    FDR_p = sort_p .* [numel(options.which_metab):-1:1];
    FDR_p(FDR_p > 1) = 1;

    for iM = 1:numel(options.which_metab)
        output.(options.which_metab{iM}).stats.anova.(grp_comp_name{iComp}).p_FDR = ...
            FDR_p(sort_idx == iM);
    end
end

% FDR correction, anova all3
[sort_p, sort_idx] = sort(all_anova_p_to_FDR.all3);

FDR_p = sort_p .* [numel(options.which_metab):-1:1];
FDR_p(FDR_p > 1) = 1;

for iM = 1:numel(options.which_metab)
    output.(options.which_metab{iM}).stats.anova.all3.p_FDR = ...
        FDR_p(sort_idx == iM);
end

output.all_p.anova.uncorr_p = all_anova_p_to_FDR.all3;
output.all_p.anova.FDR_p = FDR_p(sort_idx);
output.all_p.anova.bonf_p = all_anova_p_to_FDR.all3(sort_idx)...
    .*numel(all_anova_p_to_FDR.all3);
output.all_p.anova.bonf_p(output.all_p.anova.bonf_p > 1) = 1;

pause(1);
%% check E/I, if we're looking at Glu & GABA...
if sum(strcmp('Glu',options.which_metab)) && sum(strcmp('GABA',options.which_metab))
    EI.g1_data = output.Glu.g1_data ./ output.GABA.g1_data;
    EI.g2_data = output.Glu.g2_data ./ output.GABA.g2_data;
    EI.g3_data = output.Glu.g3_data ./ output.GABA.g3_data;
    EI.data = output.Glu.data ./ output.GABA.data;
    
    [h p ci EI.stats.ttest2_g1_g3] = ttest2(EI.g1_data, ...
        EI.g3_data);
    EI.stats.ttest2_g1_g3.p = p;
    
    showKW = 'off';
    
    group_data = [EI.data([g1_unique ; g2_unique ; g3_unique])];
    group_idx = [ones(numel(g1_unique),1) ; ...
        2*ones(numel(g2_unique),1) ; ...
        3*ones(numel(g3_unique),1)];
    
    [p EI.stats.kruskallwallis.all3.table,...
        EI.stats.kruskallwallis.all3.stats] = kruskalwallis(...
        group_data, group_idx, showKW);
    EI.stats.kruskallwallis.all3.p = p;
    
    output.EI = EI;
    
%% plot, if requested
    if options.displayFigs
        figure; hold on
        pause(1) % let this finish plotting...
        
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',4)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',2)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'--','color',[0.5 0.5 0.5],...
            'linewidth',2)
        h = boxplot(group_data, group_idx);
        set(h,'linewidth',2)
        for iH = 1:size(h,2)
            set(h(6,iH), 'linewidth', 4)
            set(h(:,iH), 'color', use_colors{iH})
            set(h(:,iH), 'MarkerEdgeColor', use_colors{iH})
        end
        
        hp = plotSpread({group_data},'binWidth',0.1,...
            'distributionColors',{[0.7 0.7 0.7]},...
            'distributionIdx',group_idx,'spreadWidth',0.33);
        set(hp{1},'MarkerSize',14)
        
        title({'Glu / GABA',...
            sprintf('%s%s%s%.4f%s%.4f','\rm ',output.EI.stats.kruskallwallis.all3.table{1,5},' = ',output.EI.stats.kruskallwallis.all3.table{2,5},...
            '; p = ',output.EI.stats.kruskallwallis.all3.table{2,6})})
        set(gca,'XTick',[1 2 3],'XTickLabel',{[g1_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 1))))], [g2_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 2))))], [g3_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 3))))]})
        ylabel(['Glu / GABA ratio'],'Color','k');
        set(gcf,'color','w','POS',[95   185   750   420])
        box off
        h_leg = legend('Median','25-75%','Range','Data');
        set(h_leg,'Location','Best','textcolor','k')
        set(gca,'XColor','k','YColor','k','Fontsize',18)
    end
    options.which_metab = cat(2,options.which_metab,'EI'); % add to metab list
end
%% check GM / (GM + WM) if we're looking at both GM and WM
if sum(strcmp('fgray',options.which_metab)) && sum(strcmp('fwhite',options.which_metab))
    GM_WM.g1_data = output.fgray.g1_data ./ (output.fgray.g1_data + output.fwhite.g1_data);
    GM_WM.g2_data = output.fgray.g2_data ./ (output.fgray.g2_data + output.fwhite.g2_data);
    GM_WM.g3_data = output.fgray.g3_data ./ (output.fgray.g3_data + output.fwhite.g3_data);
    GM_WM.data = output.fgray.data ./ (output.fgray.data + output.fwhite.data);
    
    [h p ci GM_WM.stats.ttest2_g1_g3] = ttest2(GM_WM.g1_data, ...
        GM_WM.g3_data);
    GM_WM.stats.ttest2_g1_g3.p = p;
    
    showKW = 'off';
    
    group_data = [GM_WM.data([g1_unique ; g2_unique ; g3_unique])];
    group_idx = [ones(numel(g1_unique),1) ; ...
        2*ones(numel(g2_unique),1) ; ...
        3*ones(numel(g3_unique),1)];
    
    [p GM_WM.stats.kruskallwallis.all3.table,...
        GM_WM.stats.kruskallwallis.all3.stats] = kruskalwallis(...
        group_data, group_idx, showKW);
    GM_WM.stats.kruskallwallis.all3.p = p;
    
    output.GM_WM = GM_WM;
    
%% plot, if requested
    if options.displayFigs
        figure; hold on
        pause(1) % let this finish plotting...
        
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',4)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'-','color',[0.5 0.5 0.5],...
            'linewidth',2)
        plot([0 0],repmat(this_metab.g1_median,[1 2]),'--','color',[0.5 0.5 0.5],...
            'linewidth',2)
        h = boxplot(group_data, group_idx);
        set(h,'linewidth',2)
        for iH = 1:size(h,2)
            set(h(6,iH), 'linewidth', 4)
            set(h(:,iH), 'color', use_colors{iH})
            set(h(:,iH), 'MarkerEdgeColor', use_colors{iH})
        end
        
        hp = plotSpread({group_data},'binWidth',0.1,...
            'distributionColors',{[0.7 0.7 0.7]},...
            'distributionIdx',group_idx,'spreadWidth',0.33);
        set(hp{1},'MarkerSize',14)
        
        title({'GM / (GM + WM)',...
            sprintf('%s%s%s%.4f%s%.4f','\rm ',output.GM_WM.stats.kruskallwallis.all3.table{1,5},' = ',output.GM_WM.stats.kruskallwallis.all3.table{2,5},...
            '; p = ',output.GM_WM.stats.kruskallwallis.all3.table{2,6})})
        set(gca,'XTick',[1 2 3],'XTickLabel',{[g1_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 1))))], [g2_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 2))))], [g3_short ', n = ' num2str(sum(...
            ~isnan(group_data(group_idx == 3))))]})
        ylabel(['GM / (GM + WM)'],'Color','k');
        set(gcf,'color','w','POS',[95   185   750   420])
        box off
        h_leg = legend('Median','25-75%','Range','Data');
        set(h_leg,'Location','Best','textcolor','k')
        set(gca,'XColor','k','YColor','k','Fontsize',18)
    end
    
    options.which_metab = cat(2,options.which_metab,'GM_WM'); % add to metab list
end

%% check if metabolites correlate, if requested
if options.corr_metabs
    for iM1 = 1:(numel(options.which_metab)-1)
        for iM2 = (iM1+1):numel(options.which_metab) % don't repeat
            corr_M1 = output.(options.which_metab{iM1}).data;
            corr_M2 = output.(options.which_metab{iM2}).data;
            
            use_unique = [g1_unique ; g2_unique ; g3_unique];
            use_metab_corr_idx = use_unique(find(~isnan(corr_M1(use_unique)) &...
                ~isnan(corr_M2(use_unique))));
            use_metab_corr_g1_idx = g1_unique(find(~isnan(corr_M1(g1_unique)) &...
                ~isnan(corr_M2(g1_unique))));
            use_metab_corr_g2_idx = g2_unique(find(~isnan(corr_M1(g2_unique)) &...
                ~isnan(corr_M2(g2_unique))));
            use_metab_corr_g3_idx = g3_unique(find(~isnan(corr_M1(g3_unique)) &...
                ~isnan(corr_M2(g3_unique))));
                        
%             use_metab_corr_idx = ~isnan(corr_M1) & ~isnan(corr_M2);
            
            [r, p] = corr(corr_M1(use_metab_corr_idx), ...
                corr_M2(use_metab_corr_idx),...
                'type','Spearman');
            df = numel(use_metab_corr_idx)-2;
            
            eval(['output.corr_metab.' options.which_metab{iM1} '_' ...
                options.which_metab{iM2} '.r = r;']);
            eval(['output.corr_metab.' options.which_metab{iM1} '_' ...
                options.which_metab{iM2} '.p = p;']);
            eval(['output.corr_metab.' options.which_metab{iM1} '_' ...
                options.which_metab{iM2} '.df = df;']);
            
            if options.displayFigs
                figure; hold on
                
                [poly_fit] = polyfit(corr_M1(use_metab_corr_idx), ...
                    corr_M2(use_metab_corr_idx), 1);
                
                fit_x = [min(corr_M1(use_metab_corr_idx)) max(corr_M1(use_metab_corr_idx))];
                fit_y = poly_fit(1).*fit_x + poly_fit(2);
                y_range = [min(corr_M2(use_metab_corr_idx)) max(corr_M2(use_metab_corr_idx))];
                plot(fit_x,fit_y,'k-','linewidth',2)
                
                plot(corr_M1(use_metab_corr_g1_idx), corr_M2(use_metab_corr_g1_idx), 'ko', ...
                    'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', corr_colors{1})
                plot(corr_M1(use_metab_corr_g2_idx), corr_M2(use_metab_corr_g2_idx), 'ko', ...
                    'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', corr_colors{2})
                plot(corr_M1(use_metab_corr_g3_idx), corr_M2(use_metab_corr_g3_idx), 'ko', ...
                    'linewidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', corr_colors{3})
                
                text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0,...
                    ['n = ' num2str(numel(use_metab_corr_idx))],'fontsize',18)
                text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.1,...
                    ['r = ' num2str(round(100*r)/100)],'fontsize',18)
                text(fit_x(1),y_range(2) - (y_range(2) - y_range(1))*0.2,...
                    ['p = ' num2str(round(100*p)/100)],'fontsize',18)
                
                ylabel([options.which_metab{iM2} ' (mM)'],'Color','k');
                xlabel([options.which_metab{iM1} ' (mM)'],'Color','k');
                set(gcf,'color','w','POS',[357   275   560   560])
                box off
                set(gca,'XColor','k','YColor','k','Fontsize',18)
            end
        end
    end
    pause(1); % let things finish plotting...
end

%% out
output.subj_date = MRS_subj_date_with_repeats;
output.demographics = demog_data;
output.g1_idx = g1_idx;
output.g2_idx = g2_idx;
output.g3_idx = g3_idx;
output.g1_unique = g1_unique;
output.g2_unique = g2_unique;
output.g3_unique = g3_unique;
output.g1_short = g1_short;
output.g2_short = g2_short;
output.g3_short = g3_short;

output.options = options;
output.date_run = datestr(now);
end