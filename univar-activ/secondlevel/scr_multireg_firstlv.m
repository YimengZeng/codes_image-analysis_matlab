% written by l.hao (ver_18.09.07)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
spm_ver    = 'spm12';
spm_dir    = '/Users/haol/Dropbox/Toolbox/BrainTools/spm12';
firlv_dir  = '/Users/haol/Downloads/DataAnalyTest/FirstLv';
seclv_dir  = '/Users/haol/Downloads/DataAnalyTest/SecLv';
script_dir = '/Users/haol/Downloads/DataAnalyTest/Codes/UnivarActi/SecLevel';
var_list   = '/Users/haol/Downloads/DataAnalyTest/Codes/UnivarActi/SecLevel/list_multireg_covar.txt';

task_name  = 'ANT';
run_ppl    = 'swa';
tconweig   = [0 0 1];
res_folder = 'MultiReg_Test';
cond_name  = {'c2_Orient'; 'c3_Conflict'};

%% run second level
addpath(genpath(spm_dir));
addpath(genpath(script_dir));
load(fullfile(script_dir, 'Depend', 'seclv_multireg.mat'));

fid = fopen(var_list); varlist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    varlist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

%subtab = readtable(var_list, 'Delimiter', '\t');
%a=table2array(subtab(:,icol))

[~, ncol] = size(varlist);
sublist = varlist(:,1);

for icol = 2:ncol
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).c = ...
        str2num(cell2mat(varlist(:,icol)));
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).cname = ...
        ['Var_',num2str(icol)];
    matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(icol-1).iCC = 1;
end

for icond = 1:length(cond_name)
    con_name = cond_name{icond};
    imgdir = {};
    for isub = 1:length(sublist)
        yearID = ['20', sublist{isub,1}(1:2)];
        imgdir{isub,1} = fullfile(firlv_dir, yearID, sublist{isub,1}, ...
            'fMRI', ['Stats_', spm_ver], task_name, ['Stats_',spm_ver,'_',run_ppl], ...
            ['con_000', cond_name{icond}(2), '.nii']); %#ok<*SAGROW>
    end
    res_save_dir = fullfile(seclv_dir, res_folder, cond_name{icond});
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = cond_name{icond};
    
    run(fullfile(script_dir, 'Depend', 'seclv_multireg.m'));
end

%% done
cd(script_dir)
disp('=== second level analysis done ===');
