% written by hao (ver_18.09.14)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Set Up Directory
spm_ver  = 'spm12';
zip_dir  = '/home/haolei/BrainDev_ANT/Preproc';
zip_mode = 'gzip'; % 'gzip' or 'gunzip'
zip_task = {'ANT1';'ANT2';'REST'};

%% g(un)zip
yearID = struct2cell(dir(fullfile(zip_dir, '20*')));
[~, nyear] = size(yearID);

if strcmp(zip_mode, 'gunzip')
    for iyear = 1:nyear
        % unix(['gunzip ', fullfile(zip_dir, yearID{iyear}, '*', 'sMRI', ...
        %     'Anatomy', 'I.nii.gz')]);
        
        for itask = 1:length(zip_task)

            unix(['gunzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, ['Smooth_', spm_ver], 'swcarI.nii.gz')]);
            unix(['gunzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, ['Smooth_', spm_ver], 'wcarI.nii.gz')]);
            
        end
    end
end

if strcmp(zip_mode, 'gzip')
    for iyear = 1:nyear
        unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'sMRI', ...
            'Anatomy', 'I.nii')]);
        
        for itask = 1:length(zip_task)
            unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, ['Smooth_', spm_ver], 'swcraI.nii')]);
            unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, ['Smooth_', spm_ver], 'wcraI.nii')]);
            unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, ['Smooth_', spm_ver], 'meancarI.nii')]);

            unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, 'Unnormal', 'I.nii')]);
            unix(['gzip ', fullfile(zip_dir, yearID{1,iyear}, '*', 'fMRI', ...
                zip_task{itask}, 'Unnormal', 'I_all.nii')]);
            
        end
    end
end

%% All Done
disp('All Done');