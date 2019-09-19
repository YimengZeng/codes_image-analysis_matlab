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
res_folder = 'OneTtest_Test';
cond_name  = {'Alert'; 'Orient'; 'Conflict'};

%% run second level
addpath (genpath (spm_dir));
addpath (genpath (script_dir));
load (fullfile (script_dir,'Depend','seclv_1t.mat'));

fid = fopen(subjlist); sublist = {}; cntlist = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cntlist,:) = linedata{1}; cntlist = cntlist + 1; %#ok<*SAGROW>
end
fclose(fid);

for i = 1:length(cond_name)
    con_name = cond_name{i,1};
    imgdir = {};
    for j = 1:length(sublist)
        yearID = ['20', sublist{j,1}(1:2)];
        imgdir{j,1} = fullfile (firlv_dir, yearID, sublist{j,1}, ...
            'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], ...
            ['con_000', num2str(i), '.nii']); %#ok<*AGROW>
    end
    res_dir = fullfile (seclv_dir, res_folder, cond_name{i,1});
    
    run (fullfile (script_dir, 'Depend', 'seclv_1t.m'));
end

%% done
disp('=== second level analysis done ===');
