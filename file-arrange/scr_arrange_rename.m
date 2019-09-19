% written by l.hao (ver_18.09.14)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Set Up Directory
subjlist = '/home/haolei/BrainDev_ANT/Codes/Others/sublist_All.txt';
work_dir = '/home/haolei/BrainDev_ANT/Preproc';

%% Read Sublist
fid = fopen(subjlist); sublist  = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt+1;  %#ok<*SAGROW>
end
fclose(fid);

%% Copy Preproc Files
for isub = 1:length(sublist)
    yearID = ['20', sublist{isub}(1:2)];
    old_name01 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'swcarI.nii');
    old_name02 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'wcarI.nii');
    old_name03 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'rp_arI.txt');
    old_name04 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'swcarI.nii');
    old_name05 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'wcarI.nii');
    old_name06 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'rp_arI.txt');
    old_name07 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'swcarI.nii');
    old_name08 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'wcarI.nii');
    old_name09 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'rp_arI.txt');
    
    new_name01 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'swcraI.nii');
    new_name02 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'wcraI.nii');
    new_name03 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT1', 'Smooth_spm12', 'rp_aI.txt');
    new_name04 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'swcraI.nii');
    new_name05 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'wcraI.nii');
    new_name06 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'ANT2', 'Smooth_spm12', 'rp_aI.txt');
    new_name07 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'swcraI.nii');
    new_name08 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'wcraI.nii');
    new_name09 = fullfile(work_dir, yearID, sublist{isub}, 'fMRI', ...
        'REST', 'Smooth_spm12', 'rp_aI.txt');
    
    unix(['mv ', old_name01, ' ', new_name01]);
    unix(['mv ', old_name02, ' ', new_name02]);
    unix(['mv ', old_name03, ' ', new_name03]);
    unix(['mv ', old_name04, ' ', new_name04]);
    unix(['mv ', old_name05, ' ', new_name05]);
    unix(['mv ', old_name06, ' ', new_name06]);
    unix(['mv ', old_name07, ' ', new_name07]);
    unix(['mv ', old_name08, ' ', new_name08]);
    unix(['mv ', old_name09, ' ', new_name09]);
    
end

%% Done
disp('All Done');