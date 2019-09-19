% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% Set Path
task_name = 'ANT';
spm_ver   = 'spm8';
spm_dir   = '/Users/haol/Dropbox/Toolbox/spm8';
subjlist  = '/Users/haol/Dropbox/Codes/Image/UnivarActi/FirstLevel/sublist_test_haol.txt';
old_dir   = '/Users/haol/Downloads/HaoLab/Preproc';
new_dir   = '/Users/haol/xXxXx';
firlv_dir = '/Users/haol/Downloads/FirstLv_Cond3';

%% Path replace
current_dir = pwd;
fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

for isub = 1:length(sublist)
    yearID = ['20', sublist{isub}(1:2)];
    sub_newdir = fullfile(firlv_dir, yearID, sublist{isub}, 'fMRI', ...
        ['Stats_', spm_ver], task_name, ['Stats_', spm_ver, '_swcra']);
    
    cd(sub_newdir);
    load('SPM.mat');
    SPM.swd = pwd;
    
    P_temp = char();
    for irep = 1:length(SPM.xY.P)
        P_temp(irep,:)= strrep(SPM.xY.P(irep,:), old_dir, new_dir);
    end
    SPM.xY.P = P_temp;

    for irep=1:length(SPM.xY.VY)
        SPM.xY.VY(irep).fname = strrep(SPM.xY.VY(irep).fname, old_dir, new_dir);
    end
    
    save SPM SPM
end

%% Done
cd(current_dir);