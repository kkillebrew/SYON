function demog_data = read_in_demog_data_syon(options)
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
% 
% Adapted from MPS/RK code for pHCP
%
% KWK - 20230502

%% Options

if ~exist('options','var')
    options = [];
end
if ~isfield(options,'target_file')
%     options.target_file = '/home/shaw-raid1/data/psychophysics/SYON.git/Demographics/SYON-3TDemographics_DATA_LABELS_2024-04-29_0027.csv';
    options.target_file = 'E:/GitRepos/SYON.git/Demographics/SYON-3TDemographics_DATA_LABELS_2024-04-29_0027.csv';
end
if ~isfield(options,'top_dir')
%     options.top_dir = '/home/shaw-raid1/data/psychophysics/SYON.git/Demographics';
    options.top_dir = 'E:/GitRepos/SYON.git/Demographics/';
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
    % The following if/else statements just look for different types of
    % variable names (lower vs upper case, underscores included, and
    % convertes all potential field name differences to the same field
    % name.
    % i.e. RecordID -> Record_ID
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
            sum(strcmp(demog_data.Properties.VariableNames,'WAIS_IIIEstimatedIQ'))
        demog_data.Properties.VariableNames{strcmp(...
            demog_data.Properties.VariableNames,'WAIS_IIIEstimatedIQ')} = ...
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
    
    demog_data.Properties.VariableNames{strcmp(...
        demog_data.Properties.VariableNames,'x3TMRIDateCompleted')} = ...
        'MRI_3T_Date';
    
%     % Conver the 3T dates (that exist) to datenum to compare later for
%     % acuity checks.
%     for iI=1:length(demog_data.MRI_3T_Date)
%         if ~strcmp(demog_data.MRI_3T_Date(iI),'') & ~isnat(demog_data.MRI_3T_Date(iI))
% %             demog_data.MRI_3T_Date{iI} = num2str(datenum(demog_data.MRI_3T_Date(iI),'yyyy-mm-dd'));
%             demog_data.MRI_3T_Date{iI} = num2str(datenum(demog_data.MRI_3T_Date(iI)));
%         end
%     end
%      
    
    % Remove any non-standard named subjects (i.e. SXXXXXXX)
    % There are a couple subjects named '9999' and '9999999' that should be removed
    % Find all and unique subjects
    validSubjInd = regexp(demog_data.Record_ID, '\w\d\d\d\d\d\d\d','once');
    validSubjInd = ~cellfun('isempty',validSubjInd);
    demog_data = demog_data(validSubjInd,:);
    
end

%% Dx_code formation
% RK added on 6/21/2019 and edited on 4/20/2020

if skip == 0
    for count = 1:numel(demog_data.Record_ID)
        if strcmp(demog_data.Event_Name(count),'Clinical ')
            
            %         % 2023.04.06 mps adding new new consensus diagnosis information
            %         % from Caroline as actual first method for checking Dx
            %         if ~isempty(demog_data.diagnosis{count})
            %
            %             if strfind(lower(demog_data.diagnosis{count}) , 'none')
            %
            %                 demog_data.Dx_code(count) = 0;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'schizoaffective disorder'))
            %
            %                 demog_data.Dx_code(count) = 3;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'major_depression')) | ...
            %                     ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'dysthymic_disorder')) | ...
            %                     ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'adjustment_disorder'))
            %
            %                 demog_data.Dx_code(count) = 1;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'schizophrenia'))
            %
            %                 demog_data.Dx_code(count) = 2;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'bipolar i disorder'))
            %
            %                 demog_data.Dx_code(count) = 4;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}) , 'generalized_anxiety'))
            %
            %                 demog_data.Dx_code(count) = 6;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}), 'alcohol_dependence'))
            %
            %                 demog_data.Dx_code(count) = 10;
            %
            %             elseif ~isempty(strfind(lower(demog_data.diagnosis{count}), 'cannabis_dependence'))
            %
            %                 demog_data.Dx_code(count) = 11;
            %
            %             end
            %
            %         % mps 20220603 using new consensus_dx_primary field in redcap as
            %         % 1st method for determining Dx
            %         elseif ~isnan(demog_data.consensus_dx_primary(count)) % first use the drop down, if value isnt nan
            % %             0 = Schizophrenia
            % %             1 = Schizoaffective - Depressive type
            % %             2 = Schizoaffective - Bipolar type
            % %             3 = Schizophreniform
            % %             4 = Bipolar disorder with psychosis
            % %             5 = Other
            %             if demog_data.consensus_dx_primary(count) == 0
            %                 demog_data.Dx_code(count) = 2; % schizophrenia
            %             elseif demog_data.consensus_dx_primary(count) == 1 || ...
            %                     demog_data.consensus_dx_primary(count) == 2
            %                 demog_data.Dx_code(count) = 3; % schizoaffective
            %             elseif demog_data.consensus_dx_primary(count) == 4
            %                 demog_data.Dx_code(count) = 4; % bipolar
            %             elseif demog_data.consensus_dx_primary(count) == 3 || ...
            %                     demog_data.consensus_dx_primary(count) == 5
            %                 demog_data.Dx_code(count) = 8; % schizophreniform / psychosis NOS / other
            %             else
            %                 error(['Unrecognized value for consensus_dx_primary = ' ...
            %                     num2str(demog_data.consensus_dx_primary(count)) ' for '...
            %                     demog_data.Record_ID{count}]);
            %             end
            %
            %
            %         elseif ~isempty(demog_data.P_HCP_Consensus_Diagnosis{count}) % next use text field for consensus, if not empty
            %
            %             % RK doing SZA checks first to catch individuals with
            %             % schizoaffective - bipolar/depressive type as SZA and not BP
            %             % Individuals with bipolar without psychosis would be marked as
            %             % excluded at this point, so RK only checking for bipolar and
            %             % not bipolar ii/2
            %             if ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'schizoaffective'))
            %
            %                 demog_data.Dx_code(count) = 3;
            %
            %             elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'schizophrenia'))
            %
            %                 demog_data.Dx_code(count) = 2;
            %
            %             elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'bipolar'))
            %
            %                 demog_data.Dx_code(count) = 4;
            %
            %             elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'panic')) | ...
            %                     ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'anxiety'))
            %
            %                 demog_data.Dx_code(count) = 6;
            %
            %             elseif ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'depression')) | ...
            %                     ~isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'depressive')) && ...
            %                     isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'subthreshold')) & ...
            %                     isempty(strfind(lower(demog_data.P_HCP_Consensus_Diagnosis{count}) , 'single'))
            %
            %                 demog_data.Dx_code(count) = 1;
            %
            %             end
            %
            %         else % finally use the text field for prelim dx, if not empty
            %
            
            
            
            
            
            
            %% KWK added since we don't have any of the consensus dx or anything other than initial
            % Codes:
            % 1: Schizophrenia
            % 2: Schizoaffective Bipolar
            % 3: Bipolar
            % 4: Major Depressive Disorder
            % 5: Control
            % 6: Schizophrenia Relative
            % 7: Schizoaffective-Bipolar Relative
            % 8: Bipolar Relative
            % 9: Other
            % 10: Unknown
            % 11: Schizoaffective-Depressed
            % 12: Schizoaffective-Depressed Relative
            if ~isempty(demog_data.InitialDiagnosisGroup{count})
                if strfind(lower(demog_data.InitialDiagnosisGroup{count}), 'control') == 1 % no dx or control
                    
                    demog_data.Dx_code(count) = 5;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'major depressive disorder') == 1
                    
                    demog_data.Dx_code(count) = 4;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizophrenia') == 1
                    
                    demog_data.Dx_code(count) = 1;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'bipolar') == 1
                    
                    demog_data.Dx_code(count) = 3;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizoaffective bipolar') == 1
                    
                    demog_data.Dx_code(count) = 2;    
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizophrenia relative') == 1
                    
                    demog_data.Dx_code(count) = 6;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizoaffective-bipolar relative') ==1
                    
                    demog_data.Dx_code(count) = 7;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'bipolar relative') == 1
                    
                    demog_data.Dx_code(count) = 8;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'unknown') == 1
                    
                    demog_data.Dx_code(count) = 10;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizoaffective-depressed') == 1
                    
                    demog_data.Dx_code(count) = 11;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'schizoaffective-depressed relative') == 1
                    
                    demog_data.Dx_code(count) = 12;
                    
                elseif strfind(lower(demog_data.InitialDiagnosisGroup{count}) , 'other') == 1
                    
                    demog_data.Dx_code(count) = 9;
                    
                elseif strcmp(lower(demog_data.InitialDiagnosisGroup{count}) , '') ~= 0
                    
                    demog_data.Dx_code(count) = 888; % not yet assessed
                    
                end
                
            end
        end
        
    end
%     if size(demog_data.Dx_code,2) > 1 % not sure why this is making it n x 3, but remove the extra 2 columns of zeros...
%         demog_data.Dx_code = demog_data.Dx_code(:,1);
%     end
end


%% Relative diagnoses and 3T date calculation
% 
% if skip == 0
%     proband_name = [];
%     proband_dx = [];
%     proband_fam = [];
%     for iCount = 1:numel(demog_data.Record_ID)
%         if str2num(demog_data.Record_ID{iCount}(2:end)) > 6000000
%             proband_temp = cellstr(demog_data.Record_ID{iCount}(4:7));
%             proband_name = [proband_name demog_data.Record_ID(iCount)];
%             proband_dx = [proband_dx demog_data.Dx_code(iCount)];
%             proband_fam = [proband_fam proband_temp];
%         end
%     end
%     
%     demog_data.Rel_code = nan(size(demog_data.Record_ID,1),1);
%     demog_data.auto_Rel_code = nan(size(demog_data.Record_ID,1),1);
%     demog_data.redcap_Rel_code = nan(size(demog_data.Record_ID,1),1);
%     demog_data.relative_code_discrepancies = nan(size(demog_data.Record_ID,1),1);
%     
%     for iC = 1:numel(demog_data.Record_ID)
%         
%         if ~isnan(demog_data.Relative_Type(iC))
%             if iscell(demog_data.Relative_Type(iC))
%                 if ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'schizophrenia relative'))
%                     demog_data.redcap_Rel_code(iC) = 2;
%                 elseif ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'schizoaffective'))
%                     % RK using schizoaffective to catch both bipolar and
%                     % depressive type relatives
%                     demog_data.redcap_Rel_code(iC) = 3;
%                 elseif ~isempty(strfind(lower(demog_data.Relative_Type{iC}) , 'bipolar relative'))
%                     demog_data.redcap_Rel_code(iC) = 4;
%                 end
%             else
%                 demog_data.redcap_Rel_code(iC) = demog_data.Relative_Type(iC);
%             end
%         end
% 
%         if str2num(demog_data.Record_ID{iC}(2:end)) > 2000000 & ...
%                 str2num(demog_data.Record_ID{iC}(2:end)) < 6000000
%             
%             for iG = 1:numel(proband_fam)
%                 
%                 if strcmp(demog_data.Record_ID{iC}(4:7),proband_fam(iG))
% %                     if proband_dx (iG) == 0
% %                         continue
% %                     end
%                     demog_data.auto_Rel_code(iC) = proband_dx (iG);
%                 end
%                 
%             end
%         end
%         
%         demog_data.Rel_code(iC) = demog_data.redcap_Rel_code(iC); 
%         % mps 2022.08.07 N.B. this is NOT the same code system as for patient diagnoses!!!!
%         
%         if demog_data.auto_Rel_code(iC) ~= demog_data.redcap_Rel_code(iC)
%             demog_data.relative_code_discrepancies(iC) = 1;
%         end
%         
%     end
% end

%Legend for relative codes: 0=none; 1=MDD; 2=SZ; 3=SZaff; 4=BP1; 5=BP2;
%6=Panic; 7=DeprNOS; 8=PsychNOS; 9=ADHD

%% Save demog data in mat file 

if skip == 0
    save (demog_data_matfile,'demog_data')
end



end