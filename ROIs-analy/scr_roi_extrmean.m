% written by l.hao (ver_18.09.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
roi_form  = 'nii';
img_type  = 'con';
task_name = 'ANT';
con_name  = {'alert';'orient';'conflict'};
con_num   = {'1'    ;     '2';       '3'};

spm_dir   = 'C:\Users\haol\Dropbox\Toolbox\spm12';
roi_dir   = 'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\BrainImg\ROIs\FF_GrpxCond_CBD';
firlv_dir = 'D:\BrainDev_ANT\FirstLv';
subj_list = 'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\Results\sublist_seclv_CBDC.txt';

%% extract mean value
% add path
addpath(genpath(spm_dir));

% acquire subject list
fid  = fopen (subj_list); subj = {}; Cnt  = 1;
while ~feof (fid)
    linedata = textscan (fgetl (fid), '%s', 'Delimiter', '\t');
    subj (Cnt,:) = linedata{1}; Cnt = Cnt + 1; %#ok<*SAGROW>
end
fclose (fid);

% qcquire ROIs list
roi_list = dir (fullfile (roi_dir, ['*.', roi_form]));
roi_list = struct2cell (roi_list);
roi_list = roi_list(1, :)';

for con_i = 1:length(con_name)
    mean = {'Scan_ID','Conds'};
    for roi_i = 1:length(roi_list)
        mean{1,roi_i+2} = roi_list{roi_i,1}(1:end-4);
        roifile = fullfile(roi_dir, roi_list{roi_i,1});
        for sub_i = 1:length(subj)
            YearID = ['20', subj{sub_i,1}(1:2)];
            subjfile = fullfile (firlv_dir, YearID, subj{sub_i,1}, ...
                'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra', ...
                [img_type,'_000',con_num{con_i,1},'.nii']);
            mean{sub_i+1,1} = subj{sub_i,1};
            mean{sub_i+1,2} = con_name{con_i};
            if strcmp(roi_form, 'nii')
                mean{sub_i+1,roi_i+2} = rex(subjfile,roifile);
            end
            if strcmp(roi_form, 'mat')
                roi_data = get_marsy(maroi(roifile), subjfile, 'mean');
                mean{sub_i+1,roi_i+2} = summary_data(roi_data);
            end
        end
    end
    
    %% save results
    save_name = ['res_extrmean_', con_name{con_i}, '_', img_type,'.csv'];
    
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(mean);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, mean{row_i,:}); end;
    fclose(fid);
    
end

%% done
disp('=== extract done ===');
