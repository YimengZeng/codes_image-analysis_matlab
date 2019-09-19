% written by l.hao (ver_18.09.11)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Set Parallel Pattern
ppl_max_queued = 3;
ppl_mode       = 'batch';
ppl_mode_manag = 'batch';

% Set Path
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm12';
psom_dir    = '/Users/haol/Dropbox/Toolbox/psom';
script_dir  = '/Users/haol/Dropbox/Codes/Image/Preprocess/Preproc_spm12_fm';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';

% Basic Information
suffix    = 'haol';
sesslist  = {'ANT1'; 'ANT2'; 'REST'};
magfile   = {'s2_mag_shortTE' ; 's2_mag_shortTE' ; 's1_mag_shortTE' };
phasefile = {'s2_phase'       ; 's2_phase'       ; 's1_phase'       };
vdmfile   = {'vdm5_scs2_phase'; 'vdm5_scs2_phase'; 'vdm5_scs1_phase'};

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
addpath(genpath(psom_dir));
addpath(genpath(script_dir));

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
        
        ppl_opt.max_queued = ppl_max_queued;
        ppl_opt.mode = ppl_mode;
        ppl_opt.mode_pipeline_manager = ppl_mode_manag;
        ppl_opt.path_logs = fullfile(script_dir,'Logs','Parallel');
        
        sub_preproc = ['Session_', sesslist{isess}, '_', sublist_comm{isub}];
        pipeline.(sub_preproc).command = ['fun_preproc_spm12_fm_parallel(opt.slcorder,', ...
            ' opt.timerepet, opt.vdmdir, opt.vdmfilter, opt.magdir, opt.magfilter,', ...
            ' opt.phasedir, opt.phasefilter, opt.fundir, opt.t1dir, opt.smthdir,', ...
            ' opt.smthwidth, opt.normvox, opt.datatype, opt.fieldmap, opt.templatedir)'];
        pipeline.(sub_preproc).opt.slcorder    = slcorder;
        pipeline.(sub_preproc).opt.timerepet   = timerepet;
        pipeline.(sub_preproc).opt.vdmdir      = vdmdir;
        pipeline.(sub_preproc).opt.vdmfilter   = vdmfilter;
        pipeline.(sub_preproc).opt.magdir      = magdir;
        pipeline.(sub_preproc).opt.magfilter   = magfilter;
        pipeline.(sub_preproc).opt.phasedir    = phasedir;
        pipeline.(sub_preproc).opt.phasefilter = phasefilter;
        pipeline.(sub_preproc).opt.fundir      = fundir;
        pipeline.(sub_preproc).opt.t1dir       = t1dir;
        pipeline.(sub_preproc).opt.smthdir     = smthdir;
        pipeline.(sub_preproc).opt.smthwidth   = smthwidth;
        pipeline.(sub_preproc).opt.normvox     = normvox;
        pipeline.(sub_preproc).opt.datatype    = datatype;
        pipeline.(sub_preproc).opt.fieldmap    = fieldmap;
        pipeline.(sub_preproc).opt.templatedir = templatedir ;
        
    end
end
psom_run_pipeline(pipeline, ppl_opt);

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
