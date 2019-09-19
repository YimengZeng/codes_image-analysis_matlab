% written by l.hao (ver_18.09.08)
% rock3.hao@gmail.com
% qinlab.BNU
clear

%% Set up
img_head  = '*';
group_dir = '/Users/haol/Dropbox/Projects/2019_BrainDev_ANTgen/BrainImg/IMGs';
group     = {'Grp_CBD_Threshold'};

%% Set tranform surface file
surf_dir  = '/Users/haol/Dropbox/Toolbox/BrainTools/Template_WB/Conte69_Atlas_32k_v2';
transurfL = fullfile(surf_dir, 'Conte69.L.midthickness.32k_fs_LR.surf.gii');
transurfR = fullfile(surf_dir, 'Conte69.R.midthickness.32k_fs_LR.surf.gii');

%% Convert .nii to .shape.gii
% When convert ROI and the resulting surface image have strange shading
% around the edges of the ROIs. Use "-enclosing" instead of "-trilinear"
for igrp = 1:length(group)
    grp_dir     = fullfile(group_dir, group{igrp});
    niiconvlist = dir(fullfile(grp_dir, [img_head, '.nii']));
    for nii = 1: length(niiconvlist)
        niifile = fullfile(grp_dir, niiconvlist(nii).name);
        unix(cat(2, 'wb_command -volume-to-surface-mapping ', niifile, ' ', transurfL,...
            ' ', fullfile(grp_dir, [niiconvlist(nii).name(1:end-4), 'L.shape.gii ']), '-trilinear'));
        unix(cat(2, 'wb_command -volume-to-surface-mapping ', niifile, ' ', transurfR,...
            ' ', fullfile(grp_dir, [niiconvlist(nii).name(1:end-4), 'R.shape.gii ']), '-trilinear'));
    end
end

%% Done
disp('=== Convert Done ===');