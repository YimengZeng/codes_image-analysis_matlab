function fun_preproc_spm8_1by1(config_file)
warning('off')
currentdir = pwd;
disp('======================== Preprocessing Begining ========================');
fprintf('Current Directory: %s\n', currentdir);
fprintf('Script: %s\n', which('fun_preproc_spm8_1by1.m'));
fprintf('Configure File: %s\n', config_file);
disp('========================================================================');

config_file = strtrim(config_file);
if ~strcmp(config_file(end-1:end), '.m')
    config_file = [config_file, '.m'];
end
if ~exist(fullfile(currentdir, 'Depend',config_file), 'file')
    fprintf('Error: cannot find the configuration file ... \n');
    return;
end
config_file = config_file(1:end-2); eval(config_file);

tr           = paralist.timerepet;
slc_order    = paralist.sliceorder;
smooth_width = paralist.smooth_width;
suffix       = strtrim(paralist.suffix);
data_type    = strtrim(paralist.data_type);
sesslist     = strtrim(paralist.sesslist);
script_dir   = strtrim(paralist.script_dir);
preproc_dir  = strtrim(paralist.preproc_dir);
input_fliter = strtrim(paralist.input_fliter);
all_pipeline = strtrim(paralist.all_pipeline);
run_pipeline = all_pipeline(1:end-length(input_fliter));
template_dir = fullfile(script_dir, 'Depend', 'Template');
bounding_box = [-90 -126 -72; 90 90 108];

% pipeline_family = {'swar', 'swavr', 'swgcar', 'swgcavr', 'swfar', 'swfavr', ...
%     'swgcfar', 'swgcfavr', 'swaor', 'swgcaor', 'swfaor', 'swgcfaor'};
% if any(~ismember(all_pipeline, pipeline_family))
%     disp('Error: unrecognized entire pipeline to be implemented'); return;
% end

disp('----------------- Contents of the parameter list -----------------------');
disp(paralist);
disp('========================================================================');

if any(~ismember(data_type, {'nii', 'img'}))
    disp('Error: wrong data type specified'); return;
end
if any(smooth_width < 0)
    disp('Error: smoothing kernel width cannot be negative'); return;
end
if ~exist(template_dir, 'dir')
    disp('Error: template folder does not exist!'); return;
end
% if ismember('f', all_pipeline)
%     flip_flag = 1;
% else
%     flip_flag = 0;
% end

spm('defaults', 'fmri');
spm_jobman('initcfg');

subjlist_t1 = fullfile(script_dir, ['list_Anatomy_yes_', suffix, '.txt']);
fid = fopen(subjlist_t1); sublist_t1 = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist_t1(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*AGROW>
end
fclose(fid);

sesscnt = 0;
for isess = 1:length(sesslist)
    sesscnt = sesscnt + 1; errcnt = 1;
    fprintf('---> Session: %s\n', sesslist{isess});
    
    subjlist_fun = fullfile(script_dir, ['list_', sesslist{isess}, ...
        '_yes_', suffix, '.txt']);
    fid = fopen(subjlist_fun); sublist_fun = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        sublist_fun(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*AGROW>
    end
    fclose(fid);
    
    [sublist_comm, ~, ~] = intersect(sublist_fun, sublist_t1);
    totalsess_num  = length(sublist_comm)*length(sesslist);
    totalsess_dir  = cell(totalsess_num, 1);
    errmsg         = cell(totalsess_num, 1);
    errmsg_flag    = zeros(totalsess_num, 1);
    volrepair_dir  = cell(totalsess_num, 1);
    volrepair_flag = zeros(totalsess_num, 1);
    
    for isub = 1:length(sublist_comm)
        yearID = ['20', sublist_comm{isub}(1:2)];
        fprintf('Processing subject: %s\n', sublist_comm{isub});
        
        subt1_dir = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'sMRI', 'Anatomy');
        subt1_file = '';
        if ismember('c', all_pipeline)
            unix(sprintf('gunzip -fq %s', fullfile(subt1_dir, 'I.nii.gz')));
            list_file = dir(fullfile(subt1_dir, 'I.nii'));
            subt1_file = fullfile(subt1_dir, list_file(1).name);
        end
        
        totalsess_dir{sesscnt} = fullfile(preproc_dir, yearID, sublist_comm{isub}, ...
            'fMRI', sesslist{isess});
        temp_dir = fullfile(totalsess_dir{sesscnt}, ['Temp_', all_pipeline]);
        unnorm_dir = fullfile(totalsess_dir{sesscnt}, 'Unnormal');
        
        if isempty(input_fliter)
            if ~exist(temp_dir, 'dir')
                mkdir(temp_dir);
                sprintf('debug: %s\n', temp_dir);
            else
                unix(sprintf('/bin/rm -rf %s', fullfile(temp_dir, '*')));
            end
            unix(sprintf('cp -af %s %s', fullfile(unnorm_dir, ['I.', data_type, '*']), ...
                temp_dir));
        end
        
        output_dir = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'fMRI', ...
            sesslist{isess}, 'Smooth_spm8');
        pfile_dir = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'fMRI', ...
            sesslist{isess}, 'Pfiles');
        volrepair_dir{sesscnt} = temp_dir;
        
        if ~isempty(input_fliter)
            if ~exist(temp_dir, 'dir')
                errmsg{sesscnt}{errcnt} = sprintf('Directory does not exist: %s\n', temp_dir);
                disp(errmsg{sesscnt}{errcnt});
                errcnt = errcnt + 1; %#ok<*NASGU>
                errmsg_flag(sesscnt) = 1;
            end
            list_file = dir(fullfile(temp_dir, 'meanI*'));
            if isempty(list_file)
                errmsg{sesscnt}{errcnt} = sprintf('Error: no meanI* image found when input_fliter is not empty');
                disp(errmsg{sesscnt}{errcnt});
                errcnt = errcnt + 1;
                errmsg_flag(sesscnt) = 1;
            else
                mean_img = fullfile(temp_dir, list_file(1).name);
            end
        end
        
        pre_prefix = input_fliter;
        nstep = length(run_pipeline);
        
        for icnt = 1:nstep
            p = run_pipeline(nstep-icnt+1);
            switch p
                case 'r' % 3d volumn correction;
                    list_file = dir(fullfile(temp_dir, [pre_prefix, 'I.nii.gz']));
                    if ~isempty(list_file)
                        unix(sprintf('gunzip -fq %s', fullfile(temp_dir, [pre_prefix, 'I*.gz'])));
                    end
                    
                    [input_img, select_err] = preprocessfmri_selectfiles(temp_dir, pre_prefix, data_type);
                    if select_err == 1
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no scans selected');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        return;
                    end
                    preprocessfmri_realign(all_pipeline, currentdir, template_dir, input_img, temp_dir);
                    
                    % list_file = dir(fullfile(temp_dir, ['rp_', pre_prefix, 'I.txt']));
                    % if ~isempty(list_file)
                    %     unix(sprintf('gunzip -fq %s', fullfile(temp_dir, ['rp_', pre_prefix, 'I.txt.gz'])));
                    % else
                    %     list_file = dir(fullfile(output_dir, ['rp_', pre_prefix, 'I.txt']));
                    %     if isempty(list_file)
                    %         unix(sprintf('cp -af %s %s', fullfile(output_dir, ['rp_', pre_prefix, 'I.txt']), temp_dir));
                    %     end
                    % end
                    
                    list_file = dir(fullfile(temp_dir, ['mean', pre_prefix, 'I.', data_type]));
                    mean_img = fullfile(temp_dir, list_file(1).name);
                    
                    if strcmpi(data_type, 'img')
                        P = spm_select('ExtFPList', temp_dir, ['^r', pre_prefix, 'I.*\.img']);
                    else
                        P = fullfile(temp_dir, ['r', pre_prefix, 'I.nii']);
                    end
                    VY = spm_vol(P);
                    uum_scan = length(VY);
                    disp('Calculating the global signals ...');
                    fid = fopen(fullfile(temp_dir, 'VolumRepair_GlobalSignal.txt'), 'w+');
                    for iScan = 1:uum_scan
                        fprintf(fid, '%.4f\n', spm_global(VY(iScan)));
                    end
                    fclose(fid);
                    
                case 'v' % what is volrepair
                    vol_flag = preprocessfmri_VolRepair(temp_dir, data_type, pre_prefix);
                    volrepair_flag(sesscnt) = vol_flag;
                    nifti3Dto4D(temp_dir, pre_prefix);
                    unix(sprintf('gunzip -fq %s', fullfile(temp_dir, ['v', pre_prefix, 'I*.gz'])));
                    
                    if vol_flag == 1
                        disp('Skipping art_global (v) step ...');
                        break;
                    else
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, 'art_deweighted.txt'), output_dir));
                        % unix(sprintf('mv -f %s %s', fullfile(TempDir, 'ArtifactMask.nii'), OutputLog));
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, 'art_repaired.txt'), output_log));
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, '*.jpg'), output_log));
                    end
                    
                case 'o' % preprocessfmri_volrepair_OVersion
                    vol_flag = preprocessfmri_VolRepair_OVersion(temp_dir, data_type, pre_prefix);
                    volrepair_flag(sesscnt) = vol_flag;
                    % nifti3Dto4D(TempDir, PrevPrefix);
                    unix(sprintf('mv -f %s %s', fullfile(temp_dir, ['v', pre_prefix, 'I.nii.gz']), fullfile(temp_dir, ['o', pre_prefix, 'I.nii.gz'])));
                    unix(sprintf('gunzip -fq %s', fullfile(temp_dir, ['o', pre_prefix, 'I*.gz'])));
                    
                    
                    if vol_flag == 1
                        disp('Skipping Art_Global (o) step ...');
                        break;
                    else
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, 'art_deweighted.txt'), fullfile(output_dir, 'art_deweighted_o.txt')));
                        % unix(sprintf('mv -f %s %s', fullfile(TempDir, 'ArtifactMask.nii'), OutputLog));
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, 'art_repaired.txt'), fullfile(output_log, 'art_repaired_o.txt')));
                        unix(sprintf('mv -f %s %s', fullfile(temp_dir, '*.jpg'), output_log));
                    end
                    
                case 'f' % preprocessfmri_FlipZ, only for fsl usage
                    preprocessfmri_FlipZ(temp_dir, pre_prefix);
                    
                case 'a' % preprocessfmri_slicetime
                    list_file = dir(fullfile(temp_dir, [pre_prefix, 'I.nii.gz']));
                    if ~isempty(list_file)
                        unix(sprintf('gunzip -fq %s', fullfile(temp_dir, [pre_prefix, 'I*.gz'])));
                    end
                    
                    [input_img, select_err] = preprocessfmri_selectfiles(temp_dir, pre_prefix, data_type);
                    if select_err == 1
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no scans selected');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        break;
                    end
                    preprocessfmri_slicetime(all_pipeline, template_dir, input_img, pfile_dir, temp_dir, tr, slc_order);
                    
                case 'c' % preprocessfmri_coreg
                    [input_img, select_err] = preprocessfmri_selectfiles(temp_dir, pre_prefix, data_type);
                    if select_err == 1
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no scans selected');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        break;
                    end
                    preprocessfmri_coreg(all_pipeline, template_dir, data_type, subt1_file, mean_img, temp_dir, input_img, pre_prefix);
                    
                case 'w' % preprocessfmri_normalize
                    [input_img, select_err] = preprocessfmri_selectfiles(temp_dir, pre_prefix, data_type);
                    if select_err == 1
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no scans selected');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        break;
                    end
                    preprocessfmri_normalize(all_pipeline, currentdir, template_dir, bounding_box, [run_pipeline, input_fliter], input_img, mean_img, temp_dir, subt1_file);
                    
                case 'g'
                    list_file = dir(fullfile(subt1_dir, 'seg', '*seg_sn.mat'));
                    if isempty(list_file)
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no segmentation has been done, use preprocessfmri_seg.m');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        break;
                    else
                        if strcmp(data_type, 'img')
                            img_list = dir(fullfile(temp_dir, [pre_prefix, 'I*.img']));
                            hdr_list = dir(fullfile(temp_dir, [pre_prefix, 'I*.hdr']));
                            num_file = length(img_list);
                            for iFile = 1:num_file
                                unix(sprintf('cp -af %s %s', fullfile(temp_dir, img_list(iFile).name), ...
                                    fullfile(temp_dir, ['g', img_list(iFile).name])));
                                unix(sprintf('cp -af %s %s', fullfile(temp_dir, hdr_list(iFile).name), ...
                                    fullfile(temp_dir, ['g', hdr_list(iFile).name])));
                            end
                        else
                            list_file = dir(fullfile(temp_dir, [pre_prefix, 'I.nii']));
                            unix(sprintf('cp -af %s %s', fullfile(temp_dir, list_file(1).name), ...
                                fullfile(temp_dir, ['g', list_file(1).name])));
                        end
                    end
                    
                case 's'  % smooth
                    [input_img, select_err] = preprocessfmri_selectfiles(temp_dir, pre_prefix, data_type);
                    if select_err == 1
                        errmsg{sesscnt}{errcnt} = sprintf('Error: no scans selected');
                        disp(errmsg{sesscnt}{errcnt});
                        errcnt = errcnt + 1;
                        errmsg_flag(sesscnt) = 1;
                        break;
                    end
                    preprocessfmri_smooth(all_pipeline, template_dir, input_img, temp_dir, smooth_width);
            end
            pre_prefix = [run_pipeline((nstep-icnt+1):nstep), input_fliter];
        end
        
        unix(sprintf('gzip -fq %s', fullfile(temp_dir, 'meanaI.nii')));
        unix(sprintf('gzip -fq %s', fullfile(temp_dir, 'wcraI.nii')));
        unix(sprintf('gzip -fq %s', fullfile(temp_dir, 'swcraI.nii')));
        unix(sprintf('/bin/rm -rf %s', fullfile(temp_dir, '*.mat')));
        unix(sprintf('/bin/rm -rf %s', fullfile(temp_dir, '*.nii')));
        if exist(output_dir, 'dir'); mkdir(output_dir); end;
        unix(sprintf('mv -f %s %s', fullfile(temp_dir, '*.txt'), output_dir));
        unix(sprintf('mv -f %s %s', fullfile(temp_dir, '*.nii.gz'), output_dir));
        unix(sprintf('mv -f %s %s', fullfile(temp_dir, 'Logs', '*'), ...
            fullfile(output_dir, 'Logs')));
        
        % list_file = dir(fullfile(output_dir, '*.mat*'));
        % if ~isempty(list_file)
        %     unix(sprintf('/bin/rm -rf %s', fullfile(output_dir, '*.mat*')));
        % end
        % list_file = dir(fullfile(output_dir, '*.jpg*'));
        % if ~isempty(list_file)
        %     unix(sprintf('/bin/rm -rf %s', fullfile(output_dir, '*.jpg*')));
        % end
        unix(sprintf('/bin/rm -rf %s', temp_dir));
    end
end

if all(ismember('sc', [run_pipeline, input_fliter]))
    for it1 = 1:length(sublist_t1)
        yearID = ['20', sublist_t1{it1}(1:2)];
        subt1_dir = fullfile(preproc_dir, yearID, sublist_t1{it1}, 'sMRI', 'Anatomy');
        unix(sprintf('gzip -fq %s', fullfile(subt1_dir, 'I.nii')));
        unix(sprintf('/bin/rm -rf %s', fullfile(subt1_dir, 'I_sn.mat')));
    end
end

cd(currentdir);
disp('========================================================================');

if sum(errmsg_flag) == 0
    if ~strcmp(pre_prefix(1), 's') && ismember('c', all_pipeline)
        disp('Please check coregistration quality');
    else
        disp('===================== Preprocessing(spm8) Finished =====================');
    end
else
    tim = fix(clock);
    err_file = sprintf('Errmsg_preprocessfmri_%d_%d_%d_%d_%d_%d.txt', tim);
    fprintf('Please check: %s\n', err_file)
    err_index = find(errmsg_flag == 1);
    fid = fopen(err_file, 'w+');
    for i = 1:length(err_index)
        fprintf(fid, '%s\n', totalsess_dir{err_index(i)});
        for j = 1:length(errmsg{err_index(i)})
            fprintf(fid, '---> %s\n', errmsg{err_index(i)}{j});
        end
    end
    fclose(fid);
end

if ismember('v', run_pipeline)
    if sum(volrepair_flag) > 0
        disp('Please check: Volumerepair_flagged_subjects_sessions.txt for flagged subject_sessions');
        flagfid = fopen('Volumerepair_flagged_subjects_sessions.txt', 'w');
        volrep_indx = find(volrepair_flag == 1);
        for i = 1:length(volrep_indx)
            fprintf(flagfid, '%s\n', volrepair_dir{volrep_indx(i)});
        end
        fclose(flagfid);
    end
end

delete(get(0, 'Children'));
clear all;
close all;
disp('========================================================================');
end
