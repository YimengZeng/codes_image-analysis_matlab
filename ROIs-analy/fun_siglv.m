% This script produce ROI statistics
% It helps you figure out if a particular ROI is in fact changing between
% conditions in your experiment. Statistics are:
% *Percent Signal Change
% *t-score average
% *t-score percent voxels activated
% *beta average
% -------------------------------------------------------------------------
% 2009-2010 Stanford Cognitive and Systems Neuroscience Laboratory
% Tianwen Chen
% $Id: roi_signallevel.m rev.1 2010-01-24 $
% -------------------------------------------------------------------------

function fun_siglv(config_file)
warning('off', 'MATLAB:FINITE:obsoleteFunction')
c = fix(clock);
disp('========================================================================');
fprintf('ROI signal level analysis start at %d/%02d/%02d %02d:%02d:%02d\n',c);
disp('========================================================================');
fname = sprintf('roi_signallevel-%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
diary(fname);
disp(['current directory is: ',pwd]);
disp('------------------------------------------------------------------------');

% load configuration file
if ~exist(config_file,'file')
    fprintf('cannot find the configuration file ... \n');
    return;
end
config_file = strtrim(config_file);
config_file = config_file(1:end-2);
eval(config_file);

% read in parameters
% server_path        = strtrim(paralist.server_path);
server_path_stats  = strtrim(paralist.server_path_stats);
parent_folder      = strtrim(paralist.parent_folder);
% subjlist_file    = strtrim(paralist.subjlist_file);
subjects           = strtrim(paralist.subject);
stats_folder       = strtrim(paralist.stats_folder);
roi_folder         = strtrim(paralist.roi_folder);
roi_list           = strtrim(paralist.roi_list);
tscore_threshold   = paralist.tscore_threshold;
roi_result_folder  = strtrim(paralist.roi_result_folder);
marsbar_path       = strtrim(paralist.marsbar_path);
scr_dir            = strtrim(script_dir);

disp('----------------- contents of the parameter list -----------------------');
disp(paralist);
disp('------------------------------------------------------------------------');

% add marsbar to the search path
if ~exist(marsbar_path, 'dir')
    fprintf('marsbar toolbox does not exist: %s \n', marsbar_path);
    diary off;
    return;
end

% check the roi_folder
if ~exist(roi_folder, 'dir')
    fprintf('folder does not exist: %s \n', roi_folder);
    diary off;
    return;
end

% check the roi_result_folder % Add by Hao
if ~exist(roi_result_folder, 'dir')
    mkdir (roi_result_folder)
end
numsub = length(subjects);

% construct the subject stats path
sub_stats = cell(numsub,1);
if isempty(parent_folder)
    for subcnt = 1:numsub
        pfolder = ['20' subjects{subcnt}(1:2)];
        sub_stats{subcnt} = fullfile(server_path_stats, pfolder, subjects{subcnt}, ...
            'fmri', 'stats_spm12', stats_folder);
    end
else
    for subcnt = 1:numsub
        sub_stats{subcnt} = fullfile(server_path_stats, parent_folder, subjects{subcnt}, ...
            'fmri', 'stats_spm12', stats_folder);
    end
end

cd(roi_result_folder)
save sub_stats.mat sub_stats

% default, measure sc using entire event duration as coded in task_design
event_duration = [];

% ROIs list
if ~isempty(roi_list)
    ROIname = roi_list;
    num_ROI = length(ROIname);
    roi_file = cell(num_ROI, 1);
    cd(roi_result_folder)
    save x.mat roi_folder ROIname
    
    for iroi = 1:num_ROI
        ROI_file = spm_select('list', roi_folder, ROIname{iroi});
        save roifile.mat ROI_file
        
        if isempty(ROI_file)
            error('folder contains no ROIs');
        end
        roi_file{iroi} = fullfile(roi_folder, ROI_file);
    end
end

% run through all the subjects ...
for isub = 1:numsub
    disp('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    fprintf('processing subject: %s ...... \n', subjects{isub});
    sub_stats_dir = sub_stats{isub};
    if ~exist(sub_stats_dir, 'dir')
        fprintf('folder does not exist: %s \n', sub_stats_dir);
        cd(scr_dir);
        diary off; return;
    end
    
    % get percent signal change
    [signalchange{isub}] = roi_signalchange_onesubject(roi_file, sub_stats_dir, event_duration); %#ok<*AGROW>
    
    % get tscore average and percent voxels activated in ROI
    [tscore_average{isub}, tscore_percent_voxels{isub}] = roi_tscore_onesubject(roi_file,sub_stats_dir,tscore_threshold);
    
    % get beta average in ROI
    [beta_average{isub}] = roi_beta_onesubject(roi_file,sub_stats_dir);
    
    save roi.mat roi_file
end % subjects


% make a folder to hold roi statistics
if ~exist (roi_result_folder, 'dir')
    mkdir(roi_result_folder);
end

% % get summary data and stats for percent signal change,
signal = signalchange; % change to generic name before saving
%[signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_signalchange signal % signal_means signal_stderr signal_stats
%
% % get summary data and stats for tscore_average
signal = tscore_average; % change to generic name before saving
% [signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_tscore_average signal % signal_means signal_stderr signal_stats
%
% % get summary data and stats for tscore_percent_voxels
signal = tscore_percent_voxels; % change to generic name before saving
% [signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_tscore_percent_voxels signal % signal_means signal_stderr signal_stats

% get summary data and stats for tscore_average
signal = beta_average; % change to generic name before saving
%[signal_means, signal_stderr, signal_stats] = roi_stats_activation(signal, [], []); % get stats for all ROIs and events
save ROI_beta_average signal % signal_means signal_stderr signal_stats

% PrintROIResults('signalchange');
% PrintROIResults('tscore_average');
% PrintROIResults('tscore_percent_voxels');
% PrintROIResults('beta_average');

disp('------------------------------------------------------------------------');
fprintf('changing back to the directory: %s \n', scr_dir);
cd(scr_dir);
c = fix(clock);
disp('========================================================================');
fprintf('ROI signal level analysis finished at %d/%02d/%02d %02d:%02d:%02d \n',c);
disp('========================================================================');
diary off;
clear all;
close all;
end
