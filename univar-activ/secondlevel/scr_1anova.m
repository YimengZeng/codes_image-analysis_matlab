% written by l.hao (ver_18.09.07)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
spm_dir    = '/Users/haol/Dropbox/Toolbox/BrainTools/spm12';
firlv_dir  = '/Users/haol/Downloads/DataAnalyTest/FirstLv';
seclv_dir  = '/Users/haol/Downloads/DataAnalyTest/SecLv';
script_dir = '/Users/haol/Downloads/DataAnalyTest/Codes/UnivarActi/SecLevel';
subjlist   = '/Users/haol/Downloads/DataAnalyTest/Codes/UnivarActi/SecLevel/list_ANT_yes_haol.txt';

task_name  = 'ANT';
run_ppl    = 'swa';
res_folder = 'OneANOVA_Test_CondDep';
cond_name  = {'Alert';'Orient';'Conflict'};
cond_contr = [1,0,0; 0,1,0; 0,0,1];
cond_dep   = 1; % dep:1 & indep:0

%% run second level
addpath ( genpath (spm_dir));
addpath ( genpath (script_dir));
load (fullfile (script_dir,'Depend','seclv_1anova.mat'));

fid = fopen(subjlist); sublist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

imgdir = {};
for i = 1:length(cond_name)
    for j = 1:length(sublist)
        yearID = ['20', sublist{j,1}(1:2)];
        imgdir{j,i} = fullfile(firlv_dir, yearID, sublist{j,1},...
            'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_',run_ppl], ...
            ['con_000',num2str(i),'.nii']); %#ok<*AGROW>
    end
    
    matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(i).scans = imgdir(:,i);
    
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.name = cond_name{i,1};
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.weights = cond_contr(i,:);
    matlabbatch{3}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
end
res_dir = fullfile (seclv_dir, res_folder);
run (fullfile(script_dir,'Depend','seclv_1anova.m'));

%% done
disp('=== second level analysis done ===');
