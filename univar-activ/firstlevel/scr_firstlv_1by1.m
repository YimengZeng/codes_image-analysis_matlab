% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Set Path
spm_ver     = 'spm8';
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm8';
script_dir  = '/Users/haol/Dropbox/Codes/Image/UnivarActi/FirstLevel';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';
firstlv_dir = '/Users/haol/Downloads/HaoLab/FirstLv/FirstLv_Cond3';
subjlist    = fullfile(script_dir, 'sublist_test.txt');
contrasts   = fullfile(script_dir, 'Contrast', 'BrainDev_ANT_Cond3.mat');

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
addpath(genpath(spm_dir));
addpath(genpath(script_dir));

if exist(fullfile(script_dir, 'Logs'), 'dir') == 0
    mkdir(fullfile(script_dir, 'Logs'))
end

iconfigname = ['config_indivstats_', spm_ver, '_', sess_name, '_ALLSUB_', ...
    suffix, '.m'];
iconfig     = fopen(iconfigname, 'a');

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
fprintf(iconfig,'%s\n',['fid = fopen(''', subjlist, ''');']);
fprintf(iconfig,'%s\n','sublist = {};cnt = 1;');
fprintf(iconfig,'%s\n','while ~feof(fid)');
fprintf(iconfig,'%s\n','linedata = textscan(fgetl(fid), ''%s'', ''Delimiter'', ''\t'');');
fprintf(iconfig,'%s\n','sublist(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>');
fprintf(iconfig,'%s\n','end');
fprintf(iconfig,'%s\n','fclose(fid);');
fprintf(iconfig,'%s\n','paralist.sublist = sublist;');
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

movefile(iconfigname, fullfile(script_dir, 'Depend'))
indivstats_1by1(iconfigname);

movefile(fullfile(script_dir,'Depend', iconfigname), fullfile(script_dir, 'Logs'))
movefile('indivstats*', fullfile(script_dir, 'Logs'))
