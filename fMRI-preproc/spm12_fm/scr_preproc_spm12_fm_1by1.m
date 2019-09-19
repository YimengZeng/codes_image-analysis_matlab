% written by l.hao (ver_18.09.11)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Set Path
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm12';
script_dir  = '/Users/haol/Dropbox/Codes/Image/Preprocess/Preproc_spm12_fm';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';

% Basic Information
suffix    = 'haol';
sesslist  = {'ANT1';'ANT2';'REST'}; % MultiRun: {'Run1';'Run2'}
magfile   = {'s2_mag_shortTE' ;'s2_mag_shortTE' ;'s1_mag_shortTE' };
phasefile = {'s2_phase'       ;'s2_phase'       ;'s1_phase'       };
vdmfile   = {'vdm5_scs2_phase';'vdm5_scs2_phase';'vdm5_scs1_phase'};

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
        
        subdir      = fullfile(preproc_dir, yearID, sublist_comm{isub});
        t1dir       = fullfile(subdir, 'sMRI', 'Anatomy');
        fundir      = fullfile(subdir, 'fMRI', sesslist{isess}, 'Unnormal');
        smthdir     = fullfile(subdir, 'fMRI', sesslist{isess}, 'Smooth_spm12');
        magdir      = fullfile(subdir, 'fMRI', sesslist{isess}, ['FieldMap_', sesslist{isess}]);
        phasedir    = fullfile(subdir, 'fMRI', sesslist{isess}, ['FieldMap_', sesslist{isess}]);
        vdmdir      = fullfile(subdir, 'fMRI', sesslist{isess}, ['FieldMap_', sesslist{isess}]);
        vdmfilter   = vdmfile{isess};
        magfilter   = magfile{isess};
        phasefilter = phasefile{isess};
        fieldmap    = fullfile(script_dir, 'Depend', 'pm_prisma_ep2d_224_64.m');
        
        fun_preproc_spm12_fm_1by1(runppl, slcorder, timerepet, vdmdir, vdmfilter, ...
            magdir, magfilter, phasedir, phasefilter, fundir, t1dir, smthdir, smthwidth, ...
            normvox, datatype, fieldmap, templatedir);
        
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

disp('================ Preprocessing(spm12_fieldmap) Finished =================');
cd(script_dir);

%% Done
