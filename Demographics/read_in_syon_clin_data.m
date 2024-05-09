function [ syon_clin_data ] = read_in_syon_clin_data( options )
%% 20240401 HM/HHY, follows EVP and PHCP code

% usage: [clin_data] = read_in_syon_clin_data(options)
%
% input: options - structure with fields:
%   - target_file = string, full path to target .csv file with symptom information
%
% output: csv_data = table with fields = column names from .csv
%
%
% Instructions for CSV management
% Use the SYON Diagnoses & Demographics redcap report, export as a CSV with raw data
% Rename as SYON_clin.csv 
% Import this sheet into
% /home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics

%% check ver
if datenum(version('-date')) < datenum('August 20, 2015')
    error(['This code relies on new functionality of csvread.m, and will NOT function with versions '...
        'of Matlab older than 2015b (ish)'])
end
%% opt
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'target_file')
    options.target_file = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics/SYON_clin.csv';
end
if ~isfield(options,'top_dir')
    options.top_dir = '/home/jaco-raid8/sponheim-data/SYON/SYON.git/Demographics';
end
if ~isfield(options,'overwrite_syon_clin_csv')
    options.overwrite_syon_clin_csv = 0;
    % Provide options.overwrite_syon_clin_csv = 1 if new csv has been pulled from redcap
end
%% Load saved data if available

syon_clin_data_matfile = fullfile(options.top_dir,['syon_clin_data.mat']);
skip = 0;

if exist (syon_clin_data_matfile, 'file') && ~options.overwrite_syon_clin_csv
    
    load_data = load(syon_clin_data_matfile);
    syon_clin_data = load_data.syon_clin_data;
    skip = 1;
    
end
%% Read in syon_clin_data

if skip == 0
    syon_clin_data = readtable(options.target_file,'FileType','text','Delimiter',...
        'comma','HeaderLines',0,'ReadRowNames',0,'ReadVariableNames',1,...
        'TreatAsEmpty','cormat');
end
%% Compute symptom rating datenumber

if skip == 0
    for count = 1: numel(syon_clin_data.record_id)
        use_date = datenum(syon_clin_data.bprs_date{count},'yyyy-mm-dd');
            if ~isempty(use_date)
                syon_clin_data.datenumber{count} = use_date;
% Need to come back and handle for SGI/SPQ/etc (REDCap report only contains
% BPRS date at the moment)
%             else
%                 use_date = datenum(syon_clin_data.spq_date{count},'yyyy-mm-dd');
%                 if ~isempty(use_date)
%                     syon_clin_data.datenumber{count} = use_date;
%                 else
%                     use_date = datenum(syon_clin_data.vaed_date{count},'yyyy-mm-dd');
%                     if ~isempty(use_date)
%                         syon_clin_data.datenumber{count} = use_date;
                    else
                        syon_clin_data.datenumber{count} = [];
                    end
%                end
    end
end    
%% Remove rows with all empty values

if skip == 0
    syon_clin_data(all(isnan(syon_clin_data.bprs_total),2),:) = [];
end
%% Save clin data in mat file 

if skip == 0
    save (syon_clin_data_matfile,'syon_clin_data')
end

