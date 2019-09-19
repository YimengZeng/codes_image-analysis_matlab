% This script performs individual fMRI analysis
% It first loads configuration file containing individual stats parameters
% A changeable configuration file can be found at
% /home/fmri/fmrihome/SPM/spm8_scripts/IndividualStats/individualstats_conf
% ig.m.template
%
% This scripts are compatible with both Analyze and NIFTI formats
% To use either format, change the data type in individualstats_config.m
%
% To run individual fMRI analysis, type at Matlab command line:
% >> indivstats_spm12_1by1('config_indivstats_ANT.m')
% -------------------------------------------------------------------------

function indivstats_1by1(config_file)
global currentdir idata_type session_img;
warning ('off', 'MATLAB:FINITE:obsoleteFunction')
c = fix(clock);
disp('========================================================================');
fprintf('fMRI individualstats start at %d/%02d/%02d %02d:%02d:%02d \n', c);
disp('========================================================================');
disp(['Current Directory is: ', pwd]);
disp('------------------------------------------------------------------------');

%% Check existence of the configuration file
config_file = strtrim(config_file);
if ~exist(config_file, 'file')
    fprintf('Cannot find the configuration file ... \n');
    diary off;
    return;
end

% Read individual stats parameters
currentdir = pwd;
config_file = config_file(1:end-2);
eval(config_file);

% Ignore white space if there is any
suffix            = strtrim(paralist.suffix);
idata_type        = strtrim(paralist.data_type);
preproc_dir       = strtrim(paralist.preproc_dir);
firstlv_dir       = strtrim(paralist.firstlv_dir);
sublist           = strtrim(paralist.sublist);
sesslist          = strtrim(paralist.sesslist);
task_dsgn         = strtrim(paralist.task_dsgn);
pipeline          = strtrim(paralist.pipeline);
contrastmat       = strtrim(paralist.contrastmat);
stats_folder      = strtrim(paralist.stats_folder);
template_path     = strtrim(paralist.template_path);
smoothed_dir      = strtrim(paralist.smoothed_dir);
% artpipeline       = strtrim(paralist.volpipeline);
% repaired_stats    = strtrim(paralist.repaired_stats);
% repaired_folder   = strtrim(paralist.volrepaired_folder);
% include_artrepair = paralist.include_volrepair;
include_mvmnt     = paralist.include_mvmnt;
sessnum           = paralist.sessnum;
tim_tr            = paralist.tr;
tim_slc           = paralist.slc;
tim_refslc        = paralist.refslc;
gzip_yn           = paralist.gzip_yn;

% fname = sprintf('individualstats-%d_%02d_%02d-%02d_%02d_%02.0f.log',c);
fname = sprintf(['indivstats_', suffix ,'-%d_%02d_%02d-%02d_%02d_%02.0f.log'],c);
diary(fname);

disp('----------------- Contents of the Parameter List -----------------------');
disp(paralist);
disp('------------------------------------------------------------------------');
clear paralist;

% Check the location of analysis results
% plumtoken = regexpi(currentdir, '^\/\w+\/plum(\d+)_share\d+', 'tokens');
% if ~isempty(plumtoken)
%   if(strcmpi(plumtoken{1}, '2'))
%     fprintf('Analysis results should not be saved in Plum2_Share<x>. \n');
%     diary off;
%     return;
%   end
% end

if ~exist(template_path,'dir')
    disp('Template folder does not exist!');
end

% Read in subjects and sessions
% Get the subjects, sesses in cell array format
numsub   = length(sublist);
sesses   = sesslist;
if sessnum == 1
    numsess = 1;
else
    numsess = length(sesses);
end

if isempty(contrastmat) && (numsess > 1)
    disp('Contrastmat file is not specified for more than two sessions.');
    diary off; return;
end

%% Start individual stats processing
for isub = 1:numsub
    yearID = ['20' sublist{isub}(1:2)];
    fprintf('Processing subject: %s \n',sublist{isub});
    disp('------------------------------------------------------------------------');
    sub_dir       = fullfile(firstlv_dir, yearID, sublist{isub}, 'fMRI');
    sub_stats_dir = fullfile(sub_dir, stats_folder);
    
    % Create stats folder.
    fprintf('Creating the directory: %s \n', sub_stats_dir);
    if ~ exist(sub_stats_dir, 'dir'); mkdir(sub_stats_dir); end
    
    % Change to stats folder
    fprintf('Changing to directory: %s \n', sub_stats_dir);
    cd(sub_stats_dir);
    
    % If stats folder contains SPM.mat file and others, they will be deleted
    if exist('SPM.mat', 'file')
        disp('The stats directory contains SPM.mat. It will be deleted.');
        unix('/bin/rm -rf *');
    end
    session_img     = cell(numsess,1);
    session_raw_dir = cell(numsess,1);
    
    for sesscnt = 1:numsess
        
        % session_raw_dir: directory of subject/session in raw server
        if sessnum == 1
            session_raw_dir{sesscnt} = fullfile(preproc_dir, yearID, ...
                sublist{isub}, 'fMRI', sesses);
        else
            session_raw_dir{sesscnt} = fullfile(preproc_dir, yearID, ...
                sublist{isub}, 'fMRI', sesses{sesscnt});
        end
        
        
        % session_img: directory of subject/session in stats server
        session_img{sesscnt} = fullfile(session_raw_dir{sesscnt}, ...
            smoothed_dir);
        session_img_dir = session_img{sesscnt};
        
        % If there is a ".m" at the end remove it.
        if(~isempty(regexp(task_dsgn, '\.m$', 'once' )))
            task_dsgn = task_dsgn(1:end-2);
        end
        
        % Load TaskDesign file in raw server
        addpath(fullfile(session_raw_dir{sesscnt}, 'TaskDesign'));
        str = which(task_dsgn);
        if isempty(str)
            disp('Cannot find task design file in TaskDesign folder.');
            cd(currentdir);
            diary off; return;
        end
        fprintf('Running the task design file: %s \n',str);
        eval(task_dsgn);
        rmpath(fullfile(session_raw_dir{sesscnt}, 'TaskDesign'));
        
        % Check the existence of preprocessed folder
        if ~exist(session_img_dir, 'dir')
            fprintf('Cannot find %s \n', session_img_dir);
            cd(currentdir);
            diary off; return;
        end
        
        % Unzip files if needed
        unix(sprintf('gunzip -fq %s', fullfile(session_img_dir, ...
            [pipeline, 'I*'])));
        
        % Update the design with the movement covariates
        if(include_mvmnt == 1)
            load task_design;
            reg_file = spm_select('FPList', session_img_dir, '^rp_aI');
            unix(sprintf('gunzip -fq %s', reg_file));
            reg_file = spm_select('FPList', session_img_dir, '^rp_aI');
            if isempty(reg_file)
                reg_path = fullfile(session_raw_dir{sesscnt}, 'Unnormal');
                reg_file = spm_select('FPList', reg_path, '^rp_aI');
                unix(sprintf('gunzip -fq %s', reg_file));
                reg_file = spm_select('FPList', reg_path, '^rp_aI');
                if isempty(reg_file)
                    disp('Cannot find the movement files');
                    cd(currentdir);
                    diary off; return;
                end
            end
            % regressor names, ordered according regressor file structure
            reg_names = {'movement_x','movement_y','movement_z','movement_xr','movement_yr','movement_zr'};
            
            % 0 if regressor of no interest, 1 if regressor of interest
            reg_vec   = [1 1 1 1 1 1];
            disp('Updating the task design with movement covariates');
            save task_design.mat sess_name names onsets durations rest_exists reg_file reg_names reg_vec %#ok<*USENS>
        end
        
        if (numsess > 1)
            % Rename the task design file
            newtaskdesign = ['task_design_sess' num2str(sesscnt) '.mat'];
            movefile('task_design.mat', newtaskdesign);
        end
        
        % Clear the variables used in input task_design.m file
        clear sess_name names onsets durations rest_exists reg_file reg_names reg_vec
    end
    
    % Get the contrast file
    [pathstr, contrast_fname] = fileparts(contrastmat);
    
    if(isempty(pathstr) && ~isempty(contrast_fname))
        contrastmat = [currentdir '/' contrastmat]; %#ok<*AGROW>
    end
    
    cd(sub_stats_dir);
    foname    = cell(1,2);
    foname{1} = template_path;
    foname{2} = smoothed_dir;
    
    % Call the N session batch script
    individualfmri(pipeline, numsess, contrastmat, foname, ...
        tim_tr, tim_slc, tim_refslc, gzip_yn);
    
    % Redo analysis using ArtRepaired images and deweighting
    % if include_artrepair == 1
    %     addpath(genpath('/Users/haol/Dropbox/Toolbox/spm12/toolbox/ArtRepair'));
    %     repaired_folder_dir = cell(numsess, 1);
    %     for scnt = 1:numsess
    %         repaired_folder_dir{scnt} = fullfile(session_raw_dir{scnt}, ...
    %             repaired_folder);
    %         unix(sprintf('gunzip -fq %s', fullfile(repaired_folder_dir{scnt}, ...
    %             '*.txt.gz')));
    %         unix(sprintf('gunzip -fq %s', fullfile(repaired_folder_dir{scnt}, ...
    %             [artpipeline,'I*'])));
    %     end
    %     repaired_stats_dir = fullfile(sub_dir, 'stats_spm12', repaired_stats);
    %     if exist(repaired_stats_dir, 'dir')
    %         disp('------------------------------------------------------------------------');
    %         fprintf('%s already exists! get deleted \n', repaired_stats_dir);
    %         disp('------------------------------------------------------------------------');
    %         unix(sprintf('/bin/rm -rf %s', repaired_stats_dir));
    %     end
    %     mkdir (repaired_stats_dir);
    %     scsnl_art_redo(sub_stats_dir, artpipeline, repaired_stats_dir, ...
    %         repaired_folder_dir);
    %     % Copy contrasts.mat, task_design, batch_stats
    %     unix(sprintf('/bin/cp -af %s %s', fullfile(sub_stats_dir, ['contrasts', '*']), ...
    %         repaired_stats_dir));
    %     unix(sprintf('/bin/cp -af %s %s', fullfile(sub_stats_dir, ['task_design', '*']), ...
    %         repaired_stats_dir));
    %     unix(sprintf('/bin/cp -af %s %s', fullfile(sub_stats_dir, 'batch_stats*'), ...
    %         repaired_stats_dir));
    %     % Remove temporary stats
    %     unix(sprintf('/bin/rm -rf %s', sub_stats_dir));
    %     for scnt = 1:numsess
    %         unix(sprintf('gzip -fq %s', fullfile(repaired_folder_dir{scnt}, ...
    %             [artpipeline,'I*'])));
    %     end
    % end
    
end

% Change back to the directory from where you started.
fprintf('Changing back to the directory: %s \n', currentdir);
c = fix(clock);
disp('========================================================================');
fprintf('fMRI Individual Stats finished at %d/%02d/%02d %02d:%02d:%02d \n',c);
disp('========================================================================');

cd(currentdir);
diary off;
delete(get(0, 'Children'));
clear all; %#ok<*CLALL>
close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% individualfmri is called by invidualstats.m to creates individual fMRI model.
% it updates batch file with model specification, estimation and contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function individualfmri(pipeline, numsess, contrastmat, foname, tim_tr, ...
    tim_slc, tim_refslc, gzip_yn)
%% Initialization
spm('defaults', 'fmri');
global idata_type session_img;

%% Subject statistics folder
statsdir      = pwd;
template_path = foname{1};

%% fMRI design specification
load(fullfile(template_path, 'firstlv_batch.mat'));

%% Get TR value: initialized to 2 but will be update by calling GetTR.m
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tim_tr;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = tim_slc;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = tim_refslc;

%% Initializing scans
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = {};

for sess = 1:numsess
    % Set preprocessed folder
    datadir = session_img{sess};
    
    % Check the data type
    if isempty(idata_type)
        fselect = spm_select('List', datadir, ['^', pipeline, 'I']);
        [strpath, fname, fext] = fileparts(fselect(1,:)); %#ok<*ASGLU>
        if ismember(fext, {'.img', '.hdr'})
            data_type = 'img';
        else
            data_type = 'nii';
        end
    else
        data_type = idata_type;
    end
    
    switch data_type
        case 'img'
            files  = spm_select('ExtFPList', datadir, ['^', pipeline, 'I.*\.img']);
            nscans = size(files,1);
        case 'nii'
            nifti_file = spm_select('ExtFPList', datadir, ['^', pipeline, 'I.*\.nii']);
            V          = spm_vol(deblank(nifti_file));
            nframes    = V(1).private.dat.dim(4);
            files      = spm_select('ExtFPList', datadir, ['^', pipeline, 'I.*\.nii'], 1:nframes);
            nscans     = size(files,1);
            clear nifti_file V nframes;
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess) = ...
        matlabbatch{1}.spm.stats.fmri_spec.sess(1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans = {};
    
    % Input preprocessed images
    for nthfile = 1:nscans
        matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans{nthfile,1} = deblank(files(nthfile,:));
    end
    
    if(numsess == 1)
        taskdesign_file = fullfile(statsdir, 'task_design.mat');
    else
        taskdesign_file = sprintf('%s/task_design_sess%d.mat', statsdir, sess);
    end
    
    reg_file = '';
    load(taskdesign_file);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi{1}  = taskdesign_file;
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {reg_file};
    
end
matlabbatch{1}.spm.stats.fmri_spec.dir{1} = statsdir;

%% Estimation setup
matlabbatch{2}.spm.stats.fmri_est.spmmat{1} = strcat(statsdir,'/SPM.mat');

%% Contrast setup
matlabbatch{3}.spm.stats.con.spmmat{1} = strcat(statsdir,'/SPM.mat');

% Built the standard contrats only if the number of sessions is one
% else use the user provided contrast file
if isempty(contrastmat)
    if (numsess >1 )
        disp(['The number of session is more than 1, No automatic contrast' ...
            ' generation option allowed, please spcify the contrast file']);
        diary off; return;
    else
        build_contrasts (matlabbatch{1}.spm.stats.fmri_spec.sess);
    end
else
    copyfile (contrastmat, './contrasts.mat');
end

load contrasts.mat;
for i = 1:length(contrastNames)
    if (i <= numTContrasts)
        matlabbatch{3}.spm.stats.con.consess{i}.tcon.name   = contrastNames{i};
        matlabbatch{3}.spm.stats.con.consess{i}.tcon.convec = contrastVecs{i};
    elseif (i > numTContrasts)
        matlabbatch{3}.spm.stats.con.consess{i}.fcon.name = contrastNames{i};
        for j=1:length(contrastVecs{i}(:,1))
            matlabbatch{3}.spm.stats.con.consess{i}.fcon.convec{j} = contrastVecs{i}(j,:);
        end
    end
end

save batch_stats matlabbatch;

%% Initialize the batch system
spm_jobman ('initcfg');
delete (get (0,'Children'));

%% Run analysis
spm_jobman ('run', './batch_stats.mat');

%% Gzip scan data
if gzip_yn == 1
    for sess = 1:numsess
        datadir = session_img{sess};
        disp(['gzip session ', num2str(sess), ' ', pipeline, 'I.nii to ', pipeline, 'I.nii.gz ...']);
        unix (sprintf ('gzip -fq %s', fullfile(datadir, [pipeline, 'I*'])));
    end
end
disp('========================================================================')

end
