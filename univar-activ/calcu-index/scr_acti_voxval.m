% written by l.hao (ver_19.01.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% Set Up
task_name = 'ANT';
img_type  = 'con'; % 'spmT' or 'con'
run_ppl   = 'swa';
cond_name = {'c1_Alert', 'c2_Orient'};

spm_dir    = '/Users/haol/Dropbox/Toolbox/BrainTools/spm12';
roi_dir    = '/Users/haol/Dropbox/Projects/2019_BrainDev_ANTgen/BrainImg/ROIs/Grp_CBD_Mask';
firlv_dir  = '/Users/haol/Downloads/DataAnalyTest_Done/FirstLv';
subjfile   = '/Users/haol/Dropbox/Codes/Image/UnivarActi/CalcuIndex/list_sub_test_haol.txt';

%% calculate activation voxels
% read subject list
fid = fopen(subjfile); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid),'%s','Delimiter','\t');
    sublist(cnt, :) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

% acquire ROIs list
roi_list = dir(fullfile(roi_dir, '*.nii'));
roi_list = struct2cell(roi_list);
roi_list = roi_list(1, :)';

% add path
addpath(genpath(spm_dir));

for iroi = 1:length(roi_list)
    res_voxval = ['Scan_ID', 'Group', cond_name];
    mask = spm_read_vols(spm_vol(fullfile(roi_dir, roi_list{iroi, 1})));
    nvox = sum(mask(:) == 1);
    
    sub_grp = {};
    sub_val = {};
    for isub = 1:length(sublist)
        sub_grp = [sub_grp; [repmat(sublist(isub, 1), nvox, 1), repmat(sublist(isub, 2), nvox, 1)]];
        
        sub_ival = {};
        for icon = 1:length(cond_name)
            yearID  = ['20', sublist{isub, 1}(1:2)];
            sub_file = fullfile(firlv_dir, yearID, sublist{isub, 1},...
                'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], ...
                [img_type, '_000', cond_name{icon}(2), '.nii']);
            
            sub_img = spm_read_vols(spm_vol(sub_file));
            sub_img_temp = sub_img(mask(:) == 1);
            sub_img_temp(isnan(sub_img_temp)) = nanmean(sub_img_temp);
            sub_ival(:, icon) = num2cell(zscore(sub_img_temp));
        end
        sub_val = [sub_val; sub_ival];
        
    end
    res_voxval = [res_voxval; [sub_grp, sub_val]];
    
    save_name = ['res_acti_voxval_', roi_list{iroi, 1}(1:end-4), '_', img_type, '.csv'];
    fid = fopen(save_name, 'w'); [nrows, ncols] = size(res_voxval); col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num, ',', '%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, res_voxval{row_i, :}); end;
    fclose(fid);
    
end

%% Done
disp('=== Voxels Value Calculate Done ===');
