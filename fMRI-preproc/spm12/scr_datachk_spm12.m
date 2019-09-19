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
suffix   = 'haol';
sesslist = {'ANT1'; 'ANT2'; 'REST'};

% Function Switch
mvmntexclu = 1;
processlog = 1;
% ======================================================================= %
%% Add Path
addpath(genpath(spm_dir));
addpath(genpath(script_dir));

%% Movement Exclusion
if mvmntexclu == 1
    mconfigname = ['config_mvmntexclu_spm12_ALLSUB_',suffix,'.m'];
    mconfig = fopen(mconfigname,'a');
    
    fprintf(mconfig,'%s\n',['paralist.suffix        = ''',suffix,''';']);
    fprintf(mconfig,'%s\n',['paralist.script_dir    = ''',script_dir,''';']);
    fprintf(mconfig,'%s\n',['paralist.preproc_dir   = ''',preproc_dir,''';']);
    fprintf(mconfig,'%s', 'paralist.sesslist      = {');
    for i = 1:length(sesslist); fprintf(mconfig,'%s',['''',sesslist{i},''';']); end;
    fprintf(mconfig,'%s\n', '};');
    fprintf(mconfig,'%s\n','paralist.smth_dir      = ''Smooth_spm12'';');
    fprintf(mconfig,'%s\n','paralist.scan2scancrit = 0.5;');
    fclose(mconfig);
    
    movefile(mconfigname, fullfile(script_dir, 'Depend'));
    mvmnt_exclu(mconfigname);
    
    if ~exist(fullfile(script_dir, 'Logs'), 'dir')
        mkdir(fullfile(script_dir, 'Logs'));
    end
    
    movefile(fullfile(script_dir, 'Depend', mconfigname), fullfile(script_dir,'Logs'));
    movefile('Mvmnt*', fullfile(script_dir,'Logs'));
end

%% Preprocessing Logs
if processlog  == 1
    subjlist_t1 = fullfile(script_dir, ['list_Anatomy_yes_', suffix, '.txt']);
    fid = fopen(subjlist_t1); sublist_t1 = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        sublist_t1(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
    end
    fclose(fid);
    
    for isess = 1:length(sesslist)
        datacheck_dir = fullfile(script_dir, 'Logs', 'ProcLog', sesslist{isess});
        if ~exist(datacheck_dir, 'dir')
            mkdir(datacheck_dir);
        end
        
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
            yearID = ['20', sublist_comm{isub,1}(1:2)];
            rfile = fullfile(preproc_dir, yearID, sublist_comm{isub,1}, ...
                'fMRI', sesslist{isess}, 'Smooth_spm12/Logs', ...
                'realign_spm12_swcra.pdf');
            rfile_rename = ['realign_', sublist_comm{isub,1}, '.pdf'];
            cfile = fullfile(preproc_dir, yearID, sublist_comm{isub,1}, ...
                'fMRI', sesslist{isess}, 'Smooth_spm12/Logs', ...
                'coregister_spm12_swcra.pdf');
            cfile_rename = ['coregister_', sublist_comm{isub,1}, '.pdf'];
            
            unix(['cp ', rfile, ' ', fullfile(datacheck_dir, rfile_rename)]);
            unix(['cp ', cfile, ' ', fullfile(datacheck_dir, cfile_rename)]);
        end
    end
    disp('=============== Please Check ''ProcLog'' in Logs Folder ================');
end

%% Done
