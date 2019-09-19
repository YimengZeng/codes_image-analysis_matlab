% written by l.hao (ver_18.09.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
spm_dir  = '/Users/haol/Dropbox/Toolbox/spm12';
scr_dir  = '/Users/haol/Dropbox/Codes/Image/hmm';
roi_dir  = '/Users/haol/Downloads/scr_test/ROI/NeuroSynth_Fan_mat';
data_dir = '/Users/haol/Downloads/scr_test/Preproc';

task_name = 'REST';
imgfilter = 'swcra';
data_type = 'nii';
subjlist  = '/Users/haol/Downloads/scr_test/sublist.txt';

%% extract time series
% read subject list
fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

% acquire ROIs list
roilist = dir(fullfile(roi_dir,'*.mat'));
roilist = struct2cell(roilist);
roilist = roilist(1,:)';

% add path
addpath(genpath(spm_dir));
addpath(genpath(scr_dir));

[subnum, ~] = size(sublist);
for isub = 1:subnum
    yearID = ['20', sublist{isub}(1:2)];
    for iroi = 1:length(roilist)
        roi_file = fullfile(roi_dir, roilist{iroi});
        temp_dir = fullfile(data_dir, yearID, sublist{isub}, 'fMRI', task_name, 'Smooth_spm12');
        disp(['Extracting ', sublist{isub}, '''s ', roilist{iroi}(1:end-4),' timeseries ...']);
        [roi_ts, roi_name] = extract_ROI_ts_eigen1(roi_file, temp_dir, 0, 0, imgfilter, data_type);
        roi_ts = roi_ts';
        res_ts(isub, iroi, :) = roi_ts;
    end
end

eval(['save res_ts_', task_name, ' res_ts']);

%% Done
disp('=== Extract Done ===');