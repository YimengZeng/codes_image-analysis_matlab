% written by l.hao (ver_18.09.07)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
spm_ver     = 'spm12';
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm12';
proc_dir    = '/Users/haol/Downloads/test/Preproc';
seclv_dir   = '/Users/haol/Downloads/test/SecLv';
script_dir  = '/Users/haol/Dropbox/Codes/Image/UnivarActi/SecLevel';
list_covar  = fullfile(script_dir, 'list_multireg_covar.txt');
list_regvar = fullfile(script_dir, 'list_multireg_regvar.txt');

task_name = 'REST';
tconweig  = [0 0 0 1];
cond_name = {'varA'; 'varB'; 'varC'};
img_index = {
    'swCovRegressed_4DVolume1';
    'swCovRegressed_4DVolume2'
    };

%% run second level
addpath(genpath(spm_dir));
addpath(genpath(script_dir));
load(fullfile(script_dir, 'Depend', 'seclv_multireg.mat'));

tab_covar  = readtable(list_covar, 'Delimiter', '\t');
tab_regvar = readtable(list_regvar, 'Delimiter', '\t');
[~, ncol] = size(tab_covar);
sublist = table2array(tab_covar(:,1));

for icol = 2:ncol
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).c = ...
        table2array(tab_covar(:,icol));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).cname = ...
        tab_covar.Properties.VariableNames{icol};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).iCC = 1;
end

for icond = 1:length(cond_name)
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(ncol).c = ...
        table2array(tab_regvar(:,icond));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(ncol).cname = ...
        cond_name{icond};
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(ncol).iCC = 1;
    
    for iimg = 1:length(img_index)
        imgdir = {};
        for isub = 1:length(sublist)
            yearID = ['20', sublist{isub,1}(1:2)];
            imgdir{isub,1} = fullfile(proc_dir, yearID, sublist{isub,1}, ...
                'fMRI', task_name, ['Smooth_',spm_ver], ...
                [img_index{iimg}, '.nii']); %#ok<*SAGROW>
        end
        
        res_save_dir = fullfile(seclv_dir, ['MultiReg_', img_index{iimg}, ...
            '_', cond_name{icond}]);
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ['MultiReg_', ...
            img_index{iimg}, '_', cond_name{icond}];
        
        run(fullfile(script_dir, 'Depend', 'seclv_multireg.m'));
        
    end
end

%% done
cd(script_dir);
disp('=== second level analysis done ===');
