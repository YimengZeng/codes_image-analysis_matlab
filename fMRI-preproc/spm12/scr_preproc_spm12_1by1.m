% written by l.hao (ver_18.09.10)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Set Path
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm12';
script_dir  = '/Users/haol/Dropbox/Codes/Image/Preprocess/Preproc_spm12';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';

% Basic Information
suffix    = 'haol';
sesslist  = {'ANT1';'ANT2';'REST'}; % MultiRun: {'Run1';'Run2'}
datatype  = 'nii';
runppl    = 'swcra';
timerepet = 2;
slcorder  = [1:2:33 2:2:32];
normvox   = [2 2 2];
smthwidth = [6 6 6];
% ======================================================================= %
%% Preprocess fMRI
% Add Path
addpath(genpath(spm_dir));
addpath(genpath(script_dir));

spm fmri
templatedir = fullfile(script_dir, 'Depend');

subjlist_t1 = fullfile(script_dir, ['list_Anatomy_yes_', suffix, '.txt']);
fid = fopen(subjlist_t1); sublist_t1 = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist_t1(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

for isess = 1:length(sesslist)
    subjlist_fun = fullfile(script_dir, ['list_', sesslist{isess}, ...
        '_yes_', suffix, '.txt']);
    fid = fopen(subjlist_fun); sublist_fun = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        sublist_fun(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
    end
    fclose(fid);
    
    [sublist_comm, ~, ~] = intersect(sublist_fun, sublist_t1);
    for isub = 1:length(sublist_comm)
        yearID = ['20', sublist_comm{isub}(1:2)];
        disp(['========> Session_', sesslist{isess}, '_', sublist_comm{isub}]);
        
        subdir  = fullfile(preproc_dir, yearID, sublist_comm{isub});
        t1dir   = fullfile(subdir, 'sMRI', 'Anatomy');
        fundir  = fullfile(subdir, 'fMRI', sesslist{isess}, 'Unnormal');
        smthdir = fullfile(subdir, 'fMRI', sesslist{isess}, 'Smooth_spm12');
        
        fun_preproc_spm12_1by1(runppl, fundir, t1dir, smthdir, slcorder, ...
            timerepet, normvox, smthwidth, datatype, templatedir)
    end
end

if all(ismember('sc', runppl))
    for it1 = 1:length(sublist_t1)
        yearID = ['20', sublist_t1{it1}(1:2)];
        subt1_dir = fullfile(preproc_dir, yearID, sublist_t1{it1}, 'sMRI', 'Anatomy');
        unix(sprintf('gzip -fq %s', fullfile(subt1_dir, 'I.nii')));
        unix(sprintf('/bin/rm -rf %s', fullfile(subt1_dir, 'y_I.nii')));
        unix(sprintf('/bin/rm -rf %s', fullfile(subt1_dir, 'I_seg8.mat')));
    end
end

disp('===================== Preprocessing(spm12) Finished ====================');
cd(script_dir);

%% Done
