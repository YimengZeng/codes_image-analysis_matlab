function mvmnt_exclu(config_file)
config_file = strtrim(config_file);
if ~exist(config_file,'file')
    fprintf('Error: Cannot find the configuration file ... \n');
    return;
end
config_file = config_file(1:end-2);
eval(config_file);

% Configurations
suffix        = strtrim(paralist.suffix);
smth_dir      = strtrim(paralist.smth_dir);
script_dir    = strtrim(paralist.script_dir);
preproc_dir   = strtrim(paralist.preproc_dir);
sesslist      = strtrim(paralist.sesslist);
scan2scancrit = paralist.scan2scancrit;

disp('----------------- Contents of the Parameter List -----------------------');
disp(paralist);
disp('------------------------------------------------------------------------');

subjlist_t1 = fullfile(script_dir, ['list_Anatomy_yes_', suffix, '.txt']);
fid = fopen(subjlist_t1); sublist_t1 = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist_t1(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*AGROW>
end
fclose(fid);

for isess = 1:length(sesslist)
    subjlist_fun = fullfile(script_dir, ['list_', sesslist{isess}, ...
        '_yes_', suffix, '.txt']);
    fid = fopen(subjlist_fun); sublist_fun = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        sublist_fun(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*AGROW>
    end
    fclose(fid);
    
    [sublist_comm, ~, ~] = intersect(sublist_fun, sublist_t1);
    sub_num = length(sublist_comm);
    
    run_index = zeros(sub_num, 2);
    c1 = meshgrid(1:length(sublist_comm));
    run_index(:,1) = c1(1,:);
    run_index(:,2) = 1;
    
    % overall max range | sum of max range | overall max scan to scan movement |
    % max of sum of scan to scan movement | # scans > 0.5 voxel w.r.t. max overall scan
    % to scan movement
    mvmnt_stats = zeros(sub_num, 12);
    mvmnt_dir = cell(sub_num, 1);
    
    icnt = 1;
    for isub = 1:length(sublist_comm)
        yearID = ['20', sublist_comm{isub}(1:2)];
        
        unnorm_dir = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'fMRI', ...
            sesslist{isess}, 'Unnormal');
        unix(sprintf('gunzip -fq %s', fullfile(unnorm_dir, 'I.nii.gz')));
        img_file = fullfile(unnorm_dir, 'I.nii');
        if ~exist(img_file, 'file')
            img_file = fullfile(unnorm_dir, 'I_001.img');
        end
        V = spm_vol(img_file);
        vox_size = abs(V(1).mat(1,1));
        fprintf('---> Subject: %s | Task: %s | VoxelSize: %f\n', sublist_comm{isub}, ...
            sesslist{isess}, vox_size);
        unix(sprintf('gzip -fq %s', fullfile(unnorm_dir, 'I.nii')));
        
        mvmnt_dir{icnt} = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'fMRI', ...
            sesslist{isess}, smth_dir);
        mvmnt_file = fullfile(mvmnt_dir{icnt}, 'rp_aI.txt');
        zipmvmnt_file = fullfile(mvmnt_dir{icnt}, 'rp_aI.txt.gz');
        GS_file = fullfile(mvmnt_dir{icnt}, 'VolumRepair_GlobalSignal.txt');
        zipGS_file = fullfile(mvmnt_dir{icnt}, 'VolumRepair_GlobalSignal.txt.gz');
        
        if exist(zipmvmnt_file, 'file') || exist(zipGS_file, 'file')
            unix(sprintf('gunzip -fq %s', fullfile(mvmnt_dir{icnt}, '*.txt.gz')));
        end
        
        if ~exist(mvmnt_file, 'file') || ~exist(GS_file, 'file')
            fprintf('Cannot find movement file or global signal file: %s\n', sublist_comm{isub});
            run_index(icnt, 2) = 0;
        else
            % Load rp_aI.txt
            rp_aI = load(mvmnt_file);
            
            % Translation and rotation movement
            tran_mvmnt = rp_aI(:, 1:3);
            rota_mvmnt = 65.*rp_aI(:, 4:6);
            totalmvmnt = [tran_mvmnt, rota_mvmnt];
            totaldisp  = sqrt(sum(totalmvmnt.^2, 2));
            
            tran_scan2scan = abs(diff(tran_mvmnt));
            rota_scan2scan = 65.*abs(diff(rp_aI(:, 4:6)));
            mvmnt_scan2can = [tran_scan2scan, rota_scan2scan];
            totaldisp_scan2scan = sqrt(sum(mvmnt_scan2can.^2, 2));
            
            tran_range = range(rp_aI(:, 1:3));
            rota_range = 180/pi*range(rp_aI(:, 4:6));
            
            mvmnt_stats(icnt, 1) = tran_range(1);
            mvmnt_stats(icnt, 2) = tran_range(2);
            mvmnt_stats(icnt, 3) = tran_range(3);
            mvmnt_stats(icnt, 4) = rota_range(1);
            mvmnt_stats(icnt, 5) = rota_range(2);
            mvmnt_stats(icnt, 6) = rota_range(3);
            
            mvmnt_stats(icnt, 7) = max(totaldisp);
            
            mvmnt_stats(icnt, 8) = max(totaldisp_scan2scan);
            
            mvmnt_stats(icnt, 9) = mean(totaldisp_scan2scan);
            
            mvmnt_stats(icnt, 10) = sum(totaldisp_scan2scan > (scan2scancrit*vox_size));
            
            mvnout_idx = (find(totaldisp_scan2scan > (scan2scancrit*vox_size)))'+1;
            
            g = load(GS_file);
            gsigma = std(g);
            gmean = mean(g);
            mincount = 5*gmean/100;
            % z_thresh = max(z_thresh, mincount/gsigma );
            z_thresh = mincount/gsigma; % Default value is PercentThresh.
            z_thresh = 0.1*round(z_thresh*10); % Round to nearest 0.1 Z-score value
            zscoreA = (g - mean(g))./std(g); % in case Matlab zscore is not available
            glout_idx = (find(abs(zscoreA) > z_thresh))';
            
            mvmnt_stats(icnt, 11) = length(glout_idx);
            
            union_idx = unique([1; mvnout_idx(:); glout_idx(:)]);
            mvmnt_stats(icnt, 12) = length(union_idx)/length(g)*100;
            
            imvmnt_file = fullfile(preproc_dir, yearID, sublist_comm{isub}, 'fMRI', ...
                sesslist{isess}, smth_dir, 'MovementStats.txt');
            fid = fopen(imvmnt_file, 'w+');
            fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'TASK', 'Scan_ID', ...
                'Range x', 'Range y', 'Range z', 'Range pitch', 'Range roll', 'Range yaw', 'Max Displacement', ...
                'Max Scan-to-Scan Displacement', 'Mean Scan-to-Scan Displacement', 'Num Scans > 0.5 Voxel Displacement', ...
                'Num Scans > 5% Global Signal', '% of Volumes Repaired');
            fprintf(fid, '%s\t%s\t', sesslist{isess}, sublist_comm{isub});
            fprintf(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
                mvmnt_stats(icnt, 1), mvmnt_stats(icnt, 2), mvmnt_stats(icnt, 3), ...
                mvmnt_stats(icnt, 4), mvmnt_stats(icnt, 5), mvmnt_stats(icnt, 6), ...
                mvmnt_stats(icnt, 7), mvmnt_stats(icnt, 8), mvmnt_stats(icnt, 9), ...
                mvmnt_stats(icnt, 10), mvmnt_stats(icnt, 11), mvmnt_stats(icnt, 12));
            fclose(fid);
            
        end
        icnt = icnt + 1;
    end
    
    fullrunindex = find(run_index(:,2) ~= 0);
    
    if ~isempty(fullrunindex)
        fid = fopen(['MvmntStats_', sesslist{isess}, '_', suffix, '.txt'], 'w+');
        fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'TASK', 'Scan_ID', ...
            'Range x', 'Range y', 'Range z', 'Range pitch', 'Range roll', 'Range yaw', 'Max Displacement', ...
            'Max Scan-to-Scan Displacement', 'Mean Scan-to-Scan Displacement', 'Num Scans > 0.5 Voxel Displacement', ...
            'Num Scans > 5% Global Signal', '% of Volumes Repaired');
        for isave = 1:length(fullrunindex)
            fprintf(fid, '%s\t%s\t', sesslist{isess}, sublist_comm{fullrunindex(isave,1),1});
            fprintf(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', mvmnt_stats(fullrunindex(isave), 1), ...
                mvmnt_stats(fullrunindex(isave), 2), mvmnt_stats(fullrunindex(isave), 3), ...
                mvmnt_stats(fullrunindex(isave), 4), mvmnt_stats(fullrunindex(isave), 5), ...
                mvmnt_stats(fullrunindex(isave), 6), mvmnt_stats(fullrunindex(isave), 7), ...
                mvmnt_stats(fullrunindex(isave), 8), mvmnt_stats(fullrunindex(isave), 9), ...
                mvmnt_stats(fullrunindex(isave), 10), mvmnt_stats(fullrunindex(isave), 11), ...
                mvmnt_stats(fullrunindex(isave), 12));
        end
        fclose(fid);
        
        if length(fullrunindex) < sub_num
            fid = fopen(['MvmntMissInfo_', sesslist{isess}, '_', suffix, '.txt'], 'w+');
            fprintf(fid, '%s\t%s\t%s\n', 'TASK', 'Scan_ID', 'DataDir');
            miss_set = setdiff(1:sub_num, fullrunindex);
            for isave = 1:length(miss_set)
                fprintf(fid, '%s\t%s\t%s\n', sesslist{isess}, sublist_comm{fullrunindex(isave,1),1}, ...
                    mvmnt_dir{miss_set,1});
            end
            fclose(fid);
        end
    else
        disp('None of the runs has rp_aI.txt or global signal file.');
    end
    
end

disp('========================================================================');
fprintf('====================== Movement Calculate Finished =====================\n');
fprintf('Please check: MovementMissingInfo.txt (if any) for subjects that ...\n');
fprintf('              do not have movement files.\n');
fprintf('Please check: MovementSummaryStats.txt for summary stats.\n');
disp('========================================================================');

end
