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
spm_dir     = '/Users/haol/Dropbox/Toolbox/spm8';
psom_dir    = '/Users/haol/Dropbox/Toolbox/psom';
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
addpath(genpath(psom_dir));
addpath(genpath(script_dir));

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
        
        pconfigname = ['config_preproc_spm8_', sesslist{isess}, '_', ...
            sublist_comm{isub}, '_', suffix, '.m'];
        pconfig = fopen(pconfigname, 'a');
        
        fprintf(pconfig,'%s\n',['paralist.suffix       = ''',suffix,''';']);
        fprintf(pconfig,'%s\n',['paralist.script_dir   = ''',script_dir,''';']);
        fprintf(pconfig,'%s\n',['paralist.preproc_dir  = ''',preproc_dir,''';']);
        fprintf(pconfig,'%s\n',['paralist.data_type    = ''',datatype,''';']);
        fprintf(pconfig,'%s\n',['paralist.timerepet    = ',timerepet,';']);
        fprintf(pconfig,'%s\n',['paralist.sliceorder   = ',slcorder,';']);
        fprintf(pconfig,'%s\n',['paralist.smooth_width = ',smthwidth,';']);
        fprintf(pconfig,'%s\n','paralist.input_fliter = '''';');
        fprintf(pconfig,'%s\n',['paralist.all_pipeline = ''',run_ppl,''';']);
        fclose(pconfig);
        movefile(pconfigname, fullfile(script_dir, 'Depend'));
        
        ppl_opt.max_queued = ppl_max_queued;
        ppl_opt.mode = ppl_mode;
        ppl_opt.mode_pipeline_manager = ppl_mode_manag;
        ppl_opt.path_logs = fullfile(script_dir,'Logs','Parallel');
        
        sub_preproc = ['Session_', sesslist{isess}, '_', sublist_comm{isub}];
        pipeline.(sub_preproc).command = 'fun_preproc_spm8_parallel(opt.pconfigname, opt.sess, opt.sub)';
        pipeline.(sub_preproc).opt.pconfigname = pconfigname;
        pipeline.(sub_preproc).opt.sess        = sesslist{isess};
        pipeline.(sub_preproc).opt.sub         = sublist_comm{isub};
    end
end
psom_run_pipeline(pipeline, ppl_opt);

if ~exist(fullfile(script_dir, 'Logs'), 'dir')
    mkdir(fullfile(script_dir, 'Logs'));
end
movefile(fullfile(script_dir, 'Depend', 'config_*'), fullfile(script_dir,'Logs'));

if all(ismember('sc', run_ppl))
    for it1 = 1:length(sublist_t1)
        yearID = ['20', sublist_t1{it1}(1:2)];
        subt1_dir = fullfile(preproc_dir, yearID, sublist_t1{it1}, 'sMRI', 'Anatomy');
        unix(sprintf('gzip -fq %s', fullfile(subt1_dir, 'I.nii')));
        unix(sprintf('/bin/rm -rf %s', fullfile(subt1_dir, 'I_sn.mat')));
    end
end

%% Done
