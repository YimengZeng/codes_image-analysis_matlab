% written by l.hao (ver_18.08.26)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Set Up Directory
task_name  = 'ANT';

subjlist = '/home/qinlab/home/haol/Codes/BrainDev_ANT/Networks/list_sub_grp_CBDA.txt';
roislist = '/Users/haol/list_rois.txt';

preproc_dir    = '/Users/haol/Preproc';
preproc_arrdir = '/Users/haol/Preproc_bk';

firstlv_dir    = '/PublicData/QinLabData/haol/BrainDev_ANT/FirstLv';
firstlv_arrdir = '/PublicData/QinLabData/haol/BrainDev_ANT/FirstLv_bk';

%% Function Switch
mv_preproc  = 0;
mv_firstlv  = 0;
mv_gppi_all = 1;
mv_gppi_roi = 0;

%% Read Subjects List
fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Move Preproc Files
if mv_preproc == 1
    for isub = 1:length(sublist)
        yearID = ['20', sublist{isub}(1:2)];
        source_file1 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'smoothed_spm12', 'swcarI.nii*');
        source_file2 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'smoothed_spm12', 'rp_*.txt');
        source_file3 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'smoothed_spm12', 'VolumRepair_GlobalSignal.txt');
        source_file4 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'taskdesign', 'taskdesign_Lu.m');
        source_file5 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'unnormalized', 'I.nii*');
        source_file6 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'fmri', 'WM', 'unnormalized', 'I_all.nii*');
        source_file7 = fullfile(preproc_dir, yearID, sublist{isub}, ...
            'mri', 'anatomy', 'I.nii*');
        
        target_dir1 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'Smooth_spm12');
        target_dir2 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'Smooth_spm12');
        target_dir3 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'Smooth_spm12');
        target_dir4 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'TaskDesign');
        target_dir5 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'Unnormal');
        target_dir6 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'fMRI', 'WM', 'Unnormal');
        target_dir7 = fullfile(preproc_arrdir, yearID, sublist{isub}, ...
            'sMRI', 'Anatomy');
        
        
        mkdir(target_dir1);
        mkdir(target_dir2);
        mkdir(target_dir3);
        mkdir(target_dir4);
        mkdir(target_dir5);
        mkdir(target_dir6);
        mkdir(target_dir7);
        
        unix(['cp ', source_file1, ' ', target_dir1]);
        unix(['cp ', source_file2, ' ', target_dir2]);
        unix(['cp ', source_file3, ' ', target_dir3]);
        unix(['cp ', source_file4, ' ', target_dir4]);
        unix(['cp ', source_file5, ' ', target_dir5]);
        unix(['cp ', source_file6, ' ', target_dir6]);
        unix(['cp ', source_file7, ' ', target_dir7]);

    end
end

%% Move FirstLv Files
if mv_firstlv == 1
    for isub = 1:length(sublist)
        YearID = ['20', sublist{isub}(1:2)];
        firstlv_orig = fullfile(firstlv_dir, YearID, sublist{isub}, ...
            'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra');
        firstlv_dest = fullfile(firstlv_arrdir, YearID, sublist{isub}, ...
            'fMRI', 'Stats_spm12', task_name);
        
        mkdir(firstlv_dest)
        movefile(firstlv_orig, firstlv_dest)
    end
end

%% Move gPPI Files (All)
if mv_gppi_all == 1    
    for isub = 1:length(sublist)
        YearID = ['20',sublist{isub}(1:2)];
        
        sub_dir_orig = fullfile(firstlv_dir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra_gPPI_mask');
        sub_dir_dest = fullfile(firstlv_arrdir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name);
        
        mkdir(sub_dir_dest)
        movefile(sub_dir_orig, sub_dir_dest)
        
    end
end

%% Move gPPI Files (ROIs)
if mv_gppi_roi == 1
    
    fid = fopen(roislist); roilist = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        roilist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
    end
    fclose(fid);
    
    for isub = 1:length(sublist)
        YearID = ['20',sublist{isub}(1:2)];
        
        sub_dir_orig = fullfile(firstlv_dir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra_gPPI_mask');
        sub_dir_dest = fullfile(firstlv_arrdir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra_gPPI_mask');
        
        
        for iroi = 1:length(roilist)
            gppi_file1 = fullfile(sub_dir_orig, ['PPI_', roilist{iroi}],...
                ['con_PPI_Alert_', sublist{isub}, '.nii']);
            gppi_file2 = fullfile(sub_dir_orig, ['PPI_', roilist{iroi}],...
                ['con_PPI_Orient_', sublist{isub}, '.nii']);
            
            gppi_dest_dir = fullfile(sub_dir_dest, ['PPI_', roilist{iroi}]);
            mkdir(gppi_dest_dir);
            
            copyfile(gppi_file1, gppi_dest_dir);
            copyfile(gppi_file2, gppi_dest_dir);
        end
    end
end

%% Done
disp('All Done');