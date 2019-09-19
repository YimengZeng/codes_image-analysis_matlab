% written by l.hao (ver_18.09.08)
% rock3.hao@gmail.com
% qinlab.BNU
clear

%% Set Up
file_head  = 'Merge';
script_dir = '/Users/hao1ei/xScript/Image/MkFigure';
group_dir  = '/Users/hao1ei/xData/BrainDev_ANT/Image';
group      = {'Fig_SUMA1'; 'Fig_SUMA2'};

%% Convert spmT map to afni+tlrc.
for igrp = 1:length(group)
    group_dir     = fullfile(group_dir, group{igrp});
    niiconvlist = dir(fullfile(group_dir, [file_head, '*.nii']));
    cd(group_dir)
    for nii = 1:length(niiconvlist)
        niifile = niiconvlist(nii).name;
        unix (['3dcopy ', niifile, ' ', niifile(1:end-4)]);
        unix (['3drefit -view tlrc -space MNI ', niifile(1:end-4), '+tlrc.']);
    end
end

%% Done
cd(script_dir)
disp('=== Convert Done ===');