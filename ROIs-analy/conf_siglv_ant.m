%% this configuration file is read by roi_signallevel.m
% ----------------------------------------------------------------------- %
% 2009-2010 Stanford Cognitive and Systems Neuroscience Laboratory
% $Id: roi_signallevel_config.m.template 2010-01-24 $
% ----------------------------------------------------------------------- %
restoredefaultpath;
clear

%% set path
spm_dir    = '/Users/hao1ei/xToolbox/spm12';
script_dir = '/Users/hao1ei/xCode/Image/ROICode';

%% specify the server path
paralist.server_path = '/Users/hao1ei/Downloads/Test/data';

%% specify the server path of statistics
paralist.server_path_stats = '/Users/hao1ei/Downloads/Test/FirLv';

%% specify the parent folder
paralist.parent_folder = ['']; %#ok<*NBRAK>

%% specify the subject list (in a .txt file or cell array)
paralist.subjlist = '/Users/hao1ei/xCode/Image/ROICode/list_test.txt';

%% specify the folder containing SPM analysis results
paralist.stats_folder = '/ANT/stats_spm12_swcar';

%% specify the folder (full path) holding defined ROIs
paralist.roi_folder = '/Users/hao1ei/Downloads/Test/AttNetDorsal_Yeo';

%% specify the t statistic threshold
paralist.tscore_threshold = 2.33;

%% specify the folder name to hold saved roi statistics
paralist.roi_result_folder = '/Users/hao1ei/xCode/Image/ROICode/Res_SigLv';

%% ===================================================================== %%
% acquire subject list
fid = fopen(paralist.subjlist); paralist.subject = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    paralist.subject(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

% acquire ROIs list
ROI_list = dir(fullfile(paralist.roi_folder, '*.mat'));
ROI_list = struct2cell(ROI_list);
paralist.ROI_list = ROI_list(1,:)';

% specify the path of the marsbar toolbox
paralist.marsbar_path = fullfile(spm_dir,'/toolbox/marsbar');

% add path
addpath(genpath(spm_dir));
addpath(genpath(script_dir));