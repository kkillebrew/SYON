function demog_data = read_in_demog_data(options)
% usage: demog_data = read_in_demog_data(options)
%
% input: options - structure with fields:
%   - target_file = string, full path to target .csv file with demographic information
%
% output: demog_data = structure with table with fields that are column names from .csv
%                       + visual acuity data list
%
%Legend for dx codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
%6=Panic; 8=PsychNOS; 9=ADHD, 10 = alcohol, 11 = cannabis /
%substance abuse

% mps 20190608
% rk edited on 2021 Jan 5th to save and load csv data and also moved visual
% acuity and age corrections to phcp_demographics
% RK edited on 2021 Mar 22 to include consensus diagnosis information after
% most recent round of consensus
% Also included relative diagnosis information intake from redcap at this
% point
% Instructions for CSV management (RK added on 4/23/21)
% Use the 7T fMRI demographics redcap report, export as a CSV with labels
% Upload/import into google sheets and change the variable headers to match 
% the previously used labels (copy from previous version of sheet)
% Import this sheet into the matlab folder - 
% /home/shaw-raid1/data/7T/demographics, and rename as PHCP7TfMRIDemo.csv
% Delete the old .mat file at /home/shaw-raid1/matlab_tools/COP_analysis.git/demog_data.mat, 
% or use the overwrite function

%% Version check

if datenum(version('-date')) < datenum('August 20, 2015')
    error(['This code relies on new functionality of csvread.m, and will NOT function with versions '...
        'of Matlab older than 2015b (ish)'])
end
%% Options

if ~exist('options','var')
    options = [];
end
if ~isfield(options,'target_file')
    options.target_file = '/home/shaw-raid1/data/7T/demographics/PHCP7TfMRIDemo.csv';
end
% rk added options below for data save - deleted subj_num and date_num on
% Jan 5th 2021 as age correction and visual acuity was moved to
% phcp_demographics
if ~isfield(options,'top_dir')
    options.top_dir = '/home/shaw-raid1/matlab_tools/COP_analysis.git';
end
if ~isfield(options,'overwrite_demog_csv')
    options.overwrite_demog_csv = 0;
    % RK added on 20210104 - provide options.overwrite_csv = 1 if new csv has been pulled from redcap
end

%% Load saved data if available

demog_data_matfile = fullfile(options.top_dir,['demog_data.mat']);
skip = 0;

if exist (demog_data_matfile, 'file') && ~options.overwrite_demog_csv
    
    load_data = load(demog_data_matfile);
    demog_data = load_data.demog_data;
    skip = 1;
    
end

%% Read in table

if skip == 0
    demog_data = readtable(options.target_file,'FileType','text','Delimiter',...
        'comma','HeaderLines',0,'ReadRowNames',0,'ReadVariableNames',1,...
        'TreatAsEmpty','cormat');
    
        % mps 20211129 adding code below to handle various importing options from RedCap
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Record_ID')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'record_id'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'record_id')} = ...
            'Record_ID';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Record_ID')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'RecordID'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'RecordID')} = ...
            'Record_ID';
    end   
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Event_Name')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'redcap_event_name'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'redcap_event_name')} = ...
            'Event_Name';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Event_Name')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'EventName'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'EventName')} = ...
            'Event_Name';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'P_HCP_Preliminary_Dx')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'phcp_prelim_dx'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'phcp_prelim_dx')} = ...
            'P_HCP_Preliminary_Dx';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'P_HCP_Preliminary_Dx')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'P_HCPPreliminaryDiagnosis'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'P_HCPPreliminaryDiagnosis')} = ...
            'P_HCP_Preliminary_Dx';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'P_HCP_Consensus_Diagnosis')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'phcp_consensus_dx'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'phcp_consensus_dx')} = ...
            'P_HCP_Consensus_Diagnosis';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'P_HCP_Consensus_Diagnosis')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'P_HCPConsensusDiagnosis'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'P_HCPConsensusDiagnosis')} = ...
            'P_HCP_Consensus_Diagnosis';
    end
        
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Relative_Type')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'phcp_relative_type'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'phcp_relative_type')} = ...
            'Relative_Type';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Relative_Type')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'RelativeType'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'RelativeType')} = ...
            'Relative_Type';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Date_3T_1')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'mri_3t_date_completed'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'mri_3t_date_completed')} = ...
            'Date_3T_1';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Date_3T_1')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'x3TMRIDateCompleted'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'x3TMRIDateCompleted')} = ...
            'Date_3T_1';
    end    
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Date_3T_2')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'mri_3t2_date_completed'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'mri_3t2_date_completed')} = ...
            'Date_3T_2';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Date_3T_2')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'x3T2MRIDateCompleted'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'x3T2MRIDateCompleted')} = ...
            'Date_3T_2';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Gender')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'gender'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'gender')} = ...
            'Gender';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Gender')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'Sex'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'Sex')} = ...
            'Gender';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Age')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'age'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'age')} = ...
            'Age';
    end    
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Race')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'race'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'race')} = ...
            'Race';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Estimated_IQ')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'wais_estiq'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'wais_estiq')} = ...
            'Estimated_IQ';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Estimated_IQ')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'WAIS_IVEstimatedIQ'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'WAIS_IVEstimatedIQ')} = ...
            'Estimated_IQ';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'Education')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'years_education'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'years_education')} = ...
            'Education';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'Education')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'Subject_sYearsOfEducation'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'Subject_sYearsOfEducation')} = ...
            'Education';
    end
    
    if ~sum(strcmp(demog_data.Properties.VariableNames,'DemogDate')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'demo_date'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'demo_date')} = ...
            'DemogDate';
    elseif ~sum(strcmp(demog_data.Properties.VariableNames,'DemogDate')) && ...
            sum(strcmp(demog_data.Properties.VariableNames,'Date'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'Date')} = ...
            'DemogDate';
    end

end

%% Dx_code formation
% RK added on 6/21/2019 and edited on 4/20/2020

if skip == 0
    for count = 1:numel(demog_data.Record_ID)
        
        % 2023.04.06 mps adding new new consensus diagnosis information
        % from Caroline as actual first method for checking Dx
        if ~isempty(demog_data.diagnosis{count})
            
            if strfind(lower(demog_data.diagnosis{count}) , 'none')
                
                demog_data.Dx_code(count) = 0;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'schizoaffective disorder'))
                
                demog_data.Dx_code(count) = 3;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'major_depression')) | ...
                    ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'dysthymic_disorder')) | ...
                    ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'adjustment_disorder'))
                
                demog_data.Dx_code(count) = 1;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'schizophrenia'))
                
                demog_data.Dx_code(count) = 2;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'bipolar i disorder'))
                
                demog_data.Dx_code(count) = 4;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'generalized_anxiety')) 
                
                demog_data.Dx_code(count) = 6;                
                                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}), 'alcohol_dependence'))
                
                demog_data.Dx_code(count) = 10;
                
            elseif ~isempty(strfind(lower(demog_data.diagnosis{count}), 'cannabis_dependence'))
                
                demog_data.Dx_code(count) = 11;
                
            end
                    
        % mps 20220603 using new consensus_dx_primary field in redcap as
        % 1st method for determining Dx
        elseif ~isnan(demog_data.consensus_dx_primary(count)) % first use the drop down, if value isnt nan
%             0 = Schizophrenia
%             1 = Schizoaffective - Depressive type
%             2 = Schizoaffective - Bipolar type
%             3 = Schizophreniform
%             4 = Bipolar disorder with psychosis
%             5 = Other
            if demog_data.consensus_dx_primary(count) == 0
                demog_data.Dx_code(count) = 2; % schizophrenia
            elseif demog_data.consensus_dx_primary(count) == 1 || ...
                    demog_data.consensus_dx_primary(count) == 2
                demog_data.Dx_code(count) = 3; % schizoaffective
            elseif demog_data.consensus_dx_primary(count) == 4
                demog_data.Dx_code(count) = 4; % bipolar
            elseif demog_data.consensus_dx_primary(count) == 3 || ...
                    demog_data.consensus_dx_primary(count) == 5
                demog_data.Dx_code(count) = 8; % schizophreniform / psychosis NOS / other
            else
                error(['Unrecognized value for consensus_dx_primary = ' ...
                    num2str(demog_data.consensus_dx_primary(count)) ' for '...
                    demog_data.Record_ID{count}]);
            end
            
            
        elseif ~isempty(demog_data.P_HCP_Consensus_Diagnosis{count}) % next use text field for consensus, if not empty

            % RK doing SZA checks first to catch individuals with
            % schizoaffective - bipolar/depressive type as SZA and not BP
            % Individuals with bipolar without psychosis would be marked as
            % excluded at this point, so RK only checking for bipolar and
            % not bipolar ii/2
            if ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'schizoaffective'))
                
                demog_data.Dx_code(count) = 3;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'schizophrenia')) 
                
                demog_data.Dx_code(count) = 2; 
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'bipolar'))
                
                demog_data.Dx_code(count) = 4; 
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'panic')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'anxiety'))
                
                demog_data.Dx_code(count) = 6;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'depression')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'depressive')) && ...
                    isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'subthreshold')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'single')) 
                
                demog_data.Dx_code(count) = 1;
                
            end
        
        else % finally use the text field for prelim dx, if not empty
            
            if strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'none')
                
                demog_data.Dx_code(count) = 0;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'sca')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'schizoaffective'))
                
                demog_data.Dx_code(count) = 3;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'depression')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'depressive')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'dysthymic')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'mdd')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'mood disorder')) && ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'subthreshold')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'single')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'past')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'remission'))
                
                demog_data.Dx_code(count) = 1;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'schizophrenia')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'scz'))
                
                demog_data.Dx_code(count) = 2;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'bipolar 1')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'bipolar i'))
                
                demog_data.Dx_code(count) = 4;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'bipolar 2')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'bipolar ii'))
                
                demog_data.Dx_code(count) = 5;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'panic')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'anxiety')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'social')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'phobia')) && ... % mps 2022.05.27
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'subthreshold')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'single')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'past')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'remission')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'possible')) % mps 2022.05.27
                
                demog_data.Dx_code(count) = 6;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'psychotic disorder nos')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'substance induced psychosis'))
                
                demog_data.Dx_code(count) = 8;
                
                
            elseif strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'adhd')
                
                demog_data.Dx_code(count) = 9;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'alcohol')) & ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'dependence')) && ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'abuse')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'remission'))
                
                demog_data.Dx_code(count) = 10;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'substance')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'cannabis')) & ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'dependence')) && ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'abuse')) & ...
                    isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}), 'remission'))
                
                demog_data.Dx_code(count) = 11;
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'excluded')) | ...
                    ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'withdrew'))
                
                demog_data.Dx_code(count) = 999; % excluded / withdrew
                
            elseif ~isempty(strfind(lower(demog_data.P_HCP_Preliminary_Dx{count}) , 'not yet assessed')) | ...
                    ((strcmp(lower(demog_data.P_HCP_Preliminary_Dx{count}) , '')) ~= 0)
                
                demog_data.Dx_code(count) = 888; % not yet assessed
                
            end
            
        end
        
    end
    if size(demog_data.Dx_code,2) > 1 % not sure why this is making it n x 3, but remove the extra 2 columns of zeros...
        demog_data.Dx_code = demog_data.Dx_code(:,1);
    end
end

%% Relative diagnoses and 3T date calculation

if skip == 0
    proband_name = [];
    proband_dx = [];
    proband_fam = [];
    for iCount = 1:numel(demog_data.Record_ID)
        if str2num(demog_data.Record_ID{iCount}(2:end)) > 6000000
            proband_temp = cellstr(demog_data.Record_ID{iCount}(4:7));
            proband_name = [proband_name demog_data.Record_ID(iCount)];
            proband_dx = [proband_dx demog_data.Dx_code(iCount)];
            proband_fam = [proband_fam proband_temp];
        end
    end
    
    demog_data.Rel_code = nan(size(demog_data.Record_ID,1),1);
    demog_data.auto_Rel_code = nan(size(demog_data.Record_ID,1),1);
    demog_data.redcap_Rel_code = nan(size(demog_data.Record_ID,1),1);
    demog_data.relative_code_discrepancies = nan(size(demog_data.Record_ID,1),1);
    
    for iC = 1:numel(demog_data.Record_ID)
        
        if ~isnan(demog_data.Relative_Type(iC))
            if iscell(demog_data.Relative_Type(iC))
                if ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'schizophrenia relative'))
                    demog_data.redcap_Rel_code(iC) = 2;
                elseif ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'schizoaffective'))
                    % RK using schizoaffective to catch both bipolar and
                    % depressive type relatives
                    demog_data.redcap_Rel_code(iC) = 3;
                elseif ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'bipolar relative'))
                    demog_data.redcap_Rel_code(iC) = 4;
                end
            else
                demog_data.redcap_Rel_code(iC) = demog_data.Relative_Type(iC);
            end
        end

        if str2num(demog_data.Record_ID{iC}(2:end)) > 2000000 & ...
                str2num(demog_data.Record_ID{iC}(2:end)) < 6000000
            
            for iG = 1:numel(proband_fam)
                
                if strcmp(demog_data.Record_ID{iC}(4:7),proband_fam(iG))
%                     if proband_dx (iG) == 0
%                         continue
%                     end
                    demog_data.auto_Rel_code(iC) = proband_dx (iG);
                end
                
            end
        end
        
        demog_data.Rel_code(iC) = demog_data.redcap_Rel_code(iC); 
        % mps 2022.08.07 N.B. this is NOT the same code system as for patient diagnoses!!!!
        
        if demog_data.auto_Rel_code(iC) ~= demog_data.redcap_Rel_code(iC)
            demog_data.relative_code_discrepancies(iC) = 1;
        end
        % Choose between 3T-1 and 3T-2 dates for final 3T date
        
        if ~isempty(demog_data.Date_3T_2{iC}) 
            temp_date = demog_data.Date_3T_2{iC};
        else         
            temp_date = demog_data.Date_3T_1{iC};
        end
        
        if isempty(temp_date)
            demog_data.Date_3T_final(iC) = NaN;
        else
            demog_data.Date_3T_final(iC) = datenum(temp_date,'yyyy-mm-dd');
        end
        
    end
end

%Legend for relative codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
%6=Panic; 7=DeprNOS; 8=PsychNOS; 9=ADHD


%% Save demog data in mat file 
% RK added on 202010104

if skip == 0
    save (demog_data_matfile,'demog_data')
end
