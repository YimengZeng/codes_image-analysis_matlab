% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Set Path
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm8';
script_dir  = '/Users/haol/Dropbox/Codes/Image/Preprocess/Preproc_spm8';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';

% Image Configure
suffix    = 'haol';
sesslist  = {'ANT1'; 'ANT2'; 'REST'};
datatype  = 'nii';
run_ppl   = 'swcra';
timerepet = '2';
slcorder  = '[1:2:33 2:2:32]';
smthwidth = '[6 6 6]';
% ======================================================================= %
%% Preprocess fMRI
% Add Path
addpath(genpath(spm_dir));
addpath(genpath(script_dir));

spm fmri
pconfigname = ['config_preproc_spm8_ALLSUB_', suffix, '.m'];
pconfig = fopen(pconfigname, 'a');

fprintf(pconfig,'%s\n',['paralist.suffix       = ''',suffix,''';']);
fprintf(pconfig,'%s\n',['paralist.script_dir   = ''',script_dir,''';']);
fprintf(pconfig,'%s\n',['paralist.preproc_dir  = ''',preproc_dir,''';']);
fprintf(pconfig,'%s', 'paralist.sesslist     = {');
for i = 1:length(sesslist); fprintf(pconfig,'%s',['''',sesslist{i},''';']); end;
fprintf(pconfig,'%s\n', '};');
fprintf(pconfig,'%s\n',['paralist.data_type    = ''',datatype,''';']);
fprintf(pconfig,'%s\n',['paralist.timerepet    = ',timerepet,';']);
fprintf(pconfig,'%s\n',['paralist.sliceorder   = ',slcorder,';']);
fprintf(pconfig,'%s\n',['paralist.smooth_width = ',smthwidth,';']);
fprintf(pconfig,'%s\n','paralist.input_fliter = '''';');
fprintf(pconfig,'%s\n',['paralist.all_pipeline = ''',run_ppl,''';']);
fclose(pconfig);

movefile(pconfigname, fullfile(script_dir, 'Depend'));
fun_preproc_spm8_1by1(pconfigname);

if ~exist(fullfile(script_dir, 'Logs'), 'dir')
    mkdir(fullfile(script_dir, 'Logs'));
end

movefile(fullfile(script_dir, 'Depend', pconfigname), fullfile(script_dir,'Logs'));
unix('rm -rf spm*.ps');

%% Done
