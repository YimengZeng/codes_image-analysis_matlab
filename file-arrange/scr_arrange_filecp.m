% written by l.hao (ver_18.08.26)
% rock3.hao@gmail.com
% qinlab.BNU
clear
clc

%% Set Up Directory
task_name  = 'WM';

subjlist = '/brain/iCAN/home/haol/sublist_firstlv_ALL.txt';
roislist = '/Users/haol/Dropbox/Codes/Others/list_rois.txt';

preproc_dir    = '/brain/iCAN/home/haol/BrainDev_WM/Preproc';
preproc_arrdir = '/brain/iCAN/home/haol/BrainDev_WM/Preproc_bk';

firstlv_dir    = '/Users/haol/Downloads/scr_test/FirstLv/FirstLv_6Cond';
firstlv_arrdir = '/Users/haol/Downloads/scr_test/FirstLv/FirstLv_6Cond_bk';

%% Function Switch
cp_preproc = 1;
cp_firstlv = 0;
cp_gppi    = 0;

%% Read List
fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Copy Preproc Files
if cp_preproc == 1
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

%% Copy 1stLv Files
if cp_firstlv == 1
    for isub = 1:length(sublist)
        YearID = ['20', sublist{isub}(1:2)];
        firstlv_file1 = fullfile(firstlv_dir, YearID, sublist{isub}, ...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra', 'con_0001.nii');
        firstlv_file2 = fullfile(firstlv_dir, YearID, sublist{isub}, ...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra', 'con_0002.nii');
        firstlv_file3 = fullfile(firstlv_dir, YearID, sublist{isub}, ...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra', 'con_0003.nii');
        
        firstlv_destdir = fullfile(firstlv_arrdir, YearID, sublist{isub}, ...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra');
        mkdir(firstlv_destdir)
        
        copyfile(firstlv_file1, firstlv_destdir)
        copyfile(firstlv_file2, firstlv_destdir)
        copyfile(firstlv_file3, firstlv_destdir)
    end
end

%% Copy gPPI Files
if cp_gppi == 1
    
    fid = fopen(roislist); roilist = {}; cnt = 1;
    while ~feof(fid)
        linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
        roilist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
    end
    fclose(fid);
    
    for isub = 1:length(sublist)
        YearID = ['20',sublist{isub}(1:2)];
        
        sub_dir_origin = fullfile(firstlv_dir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra_gPPI_mask');
        sub_dir_dest = fullfile(firstlv_arrdir,YearID,sublist{isub},...
            'fMRI', '/Stats_spm12', task_name, 'Stats_spm12_swcra_gPPI_mask');
        
        
        for iroi = 1:length(roilist)
            gppi_file1 = fullfile(sub_dir_origin, ['PPI_', roilist{iroi}],...
                ['con_PPI_Alert_', sublist{isub}, '.nii']);
            gppi_file2 = fullfile(sub_dir_origin, ['PPI_', roilist{iroi}],...
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