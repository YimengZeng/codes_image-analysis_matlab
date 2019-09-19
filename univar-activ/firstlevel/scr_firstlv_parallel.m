% written by l.hao (ver_18.09.12)
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
spm_ver     = 'spm8';
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm8';
psom_dir    = '/Users/haol/Dropbox/Toolbox/psom';
script_dir  = '/Users/haol/Dropbox/Codes/Image/UnivarActi/FirstLevel';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';
firstlv_dir = '/Users/haol/Downloads/HaoLab/FirstLv/FirstLv_Cond6';
subjlist    = fullfile(script_dir, 'sublist_test_haol.txt');
contrasts   = fullfile(script_dir, 'Contrast', 'BrainDev_ANT_Cond6.mat');

% Basic Configure
gzip_yn      = 1;
tim_tr       = 2;
tim_slc      = 33;
tim_refslc   = 17;
inclu_mvmnt  = '1';
data_type    = 'nii';
run_pipeline = 'swcra';

suffix      = 'haol';
sess_num    = 2;
sess_name   = 'ANT';
sess_list   = 'ANT1'',''ANT2';
% SingleRun: 'run'; MultiRun: 'run1'',''run2'',''run3'.
task_design = 'ANT_rig_hao.m';
% ======================================================================= %
%% The following do not need to be modified
if ~exist(fullfile(script_dir, 'Logs'), 'dir'); mkdir(fullfile(script_dir, ...
        'Logs')); end
if ~exist(fullfile(script_dir, 'Logs', 'Parallel'),'dir'); ...
        mkdir(fullfile(script_dir, 'Logs', 'Parallel')); end
addpath(genpath(spm_dir));
addpath(genpath(psom_dir));
addpath(genpath(script_dir));

fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

for isub = 1:length(sublist)
    iconfigname = ['config_indivstats_', spm_ver, '_', sess_name, '_', ...
        sublist{isub}, '_', suffix, '.m'];
    iconfig     = fopen(iconfigname, 'a');
    
    fprintf(iconfig,'%s\n',['paralist.isub = ''', sublist{isub}, ''';']);
    fprintf(iconfig,'%s\n',['paralist.gzip_yn = ', num2str(gzip_yn), ';']);
    fprintf(iconfig,'%s\n',['paralist.tr = ', num2str(tim_tr), ';']);
    fprintf(iconfig,'%s\n',['paralist.slc = ', num2str(tim_slc), ';']);
    fprintf(iconfig,'%s\n',['paralist.refslc = ', num2str(tim_refslc), ';']);
    fprintf(iconfig,'%s\n',['paralist.sessnum = ', num2str(sess_num), ';']);
    fprintf(iconfig,'%s\n',['paralist.suffix = ''', suffix, ''';']);
    fprintf(iconfig,'%s\n',['paralist.data_type = ''', data_type, ''';']);
    fprintf(iconfig,'%s\n',['paralist.pipeline = ''', run_pipeline, ''';']);
    fprintf(iconfig,'%s\n',['paralist.preproc_dir = ''', preproc_dir, ''';']);
    fprintf(iconfig,'%s\n',['paralist.firstlv_dir = ''', firstlv_dir, ''';']);
    if sess_num == 1; fprintf(iconfig,'%s\n',['paralist.sesslist = ''', ...
            sess_list, ''';']); end
    if sess_num > 1; fprintf(iconfig,'%s\n',['paralist.sesslist = {''', ...
            sess_list, '''};']); end
    fprintf(iconfig,'%s\n',['paralist.task_dsgn = ''', task_design, ''';']);
    fprintf(iconfig,'%s\n',['paralist.contrastmat = ''', contrasts, ''';']);
    fprintf(iconfig,'%s\n',['paralist.smoothed_dir = ''Smooth_', spm_ver, ''';']);
    fprintf(iconfig,'%s\n',['paralist.stats_folder = ''Stats_', spm_ver, ...
        '/', sess_name, '/', 'Stats_', spm_ver, '_', run_pipeline, ''';']);
    fprintf(iconfig,'%s\n',['paralist.include_mvmnt = ', inclu_mvmnt, ';']);
    % fprintf(iconfig,'%s\n','paralist.include_volrepair = 0;');
    % fprintf(iconfig,'%s\n','paralist.volpipeline = ''swavr'';');
    % fprintf(iconfig,'%s\n','paralist.volrepaired_folder = ''volrepair_spm12'';');
    % fprintf(iconfig,'%s\n','paralist.repaired_stats = ''stats_spm12_VolRepair'';');
    fprintf(iconfig,'%s\n',['paralist.template_path = ''', fullfile(script_dir, ...
        'Depend'), ''';']);
    fclose(iconfig);
    movefile (iconfigname, fullfile(script_dir, 'Depend'))
    
    ppl_opt.max_queued = ppl_max_queued;
    ppl_opt.mode = ppl_mode;
    ppl_opt.mode_pipeline_manager = ppl_mode_manag;
    ppl_opt.path_logs = fullfile(script_dir, 'Logs', 'Parallel');
    
    sub_firlv = ['Sub_', sess_name, '_', sublist{isub}];
    pipeline.(sub_firlv).command = 'indivstats_parallel(opt.iconf)';
    pipeline.(sub_firlv).opt.iconf = iconfigname;
end
psom_run_pipeline(pipeline, ppl_opt);
movefile (fullfile(script_dir, 'Depend', 'config*'), fullfile(script_dir, 'Logs'))

%% done
disp('=== First Level Done ===');
