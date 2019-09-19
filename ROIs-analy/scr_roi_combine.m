% written by l.hao (ver_18.09.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
form_input = 'mat';
comb_name  = 'ROI_Comb_5mm.mat';
comb_func  = 'union'; % 'union' or 'inter'

% path of spm and ROIs to combine
spm_dir = 'C:\Users\haol\Dropbox\Toolbox\BrainTools\spm12';
roi_dir = 'C:\Users\haol\Dropbox\Projects\2019_BrainDev_ANTnet\BrianImg\ROIs\ROIs_Power_n264';

%% multiple ROIs combine
% add path
addpath(genpath(spm_dir));

% make the union ROI
if strcmp(comb_func,'union')
    lab_name = [comb_name(1:end-4), '_', comb_func];
    roi_name = [comb_name(1:end-4), '_', comb_func,'_roi'];
    
    roi_array = dir (fullfile(roi_dir, ['*.',form_input]));
    for roi_i = 1:length(roi_array)
        if strcmp(form_input,'mat')
            roi_list{roi_i} = maroi (fullfile(roi_dir, roi_array(roi_i).name)); %#ok<*SAGROW>
        elseif strcmp(form_input,'nii')
            roi_list{roi_i} = maroi_image (struct('vol', spm_vol(fullfile(roi_dir,roi_array(roi_i).name)), 'binarize', 0, 'func', 'img'));
            roi_list{roi_i} = maroi_matrix(roi_list{roi_i});
        end
    end
    roi_comb = roi_list{1};
    for i = 2:length(roi_array)
        roi_comb = roi_comb | roi_list{i};
    end
    roi_comb = label (roi_comb, lab_name);
    
    if strcmp(comb_name(end-2:end),'mat')
        saveroi (roi_comb, fullfile(roi_dir, roi_name));
    elseif strcmp(comb_name(end-2:end),'nii')
        save_as_image(roi_comb, fullfile(roi_dir, [roi_name,'.nii']))
    end
end

% make the intersection ROI
if strcmp(comb_func,'inter')
    lab_name = [comb_name(1:end-4), '_', comb_func];
    roi_name = [comb_name(1:end-4), '_', comb_func,'_roi'];
    
    roi_array = dir (fullfile(roi_dir, ['*.',form_input]));
    for roi_i = 1:length(roi_array)
        if strcmp(form_input,'mat')
            roi_list{roi_i} = maroi (fullfile(roi_dir, roi_array(roi_i).name)); %#ok<*SAGROW>
        elseif strcmp(form_input,'nii')
            roi_list{roi_i} = maroi_image (struct('vol', spm_vol(fullfile(roi_dir,roi_array(roi_i).name)), 'binarize', 0, 'func', 'img'));
            roi_list{roi_i} = maroi_matrix(roi_list{roi_i});
        end
    end
    
    roi_comb = roi_list{1};
    for i = 2:length(roi_array)
        roi_comb = roi_comb & roi_list{i};
    end
    roi_comb = label (roi_comb, lab_name);
    
    if strcmp(comb_name(end-2:end),'mat')
        saveroi(roi_comb, fullfile(roi_dir, roi_name));
    elseif strcmp(comb_name(end-2:end),'nii')
        save_as_image(roi_comb, fullfile(roi_dir, [roi_name,'.nii']))
    end
end

disp ('=== ROIs combine done ===');