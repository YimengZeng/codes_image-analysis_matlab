% written by l.hao (ver_19.01.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% Set Up
resubmask  = 1;
img_type   = 'con'; % 'spmT' or 'con'
task_name  = 'ANT';
run_ppl    = 'swcra';
cond_name  = {'C2A_A';'C2A_O';'C2A_C'};
rsa_file   = {
    'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\BrainImg\IMGs\OneANOVA_CBDA_CondDep\con_0001.nii';
    'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\BrainImg\IMGs\OneANOVA_CBDA_CondDep\con_0002.nii';
    'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\BrainImg\IMGs\OneANOVA_CBDA_CondDep\con_0003.nii';
    };

spm_dir   = 'C:\Users\haol\Dropbox\Toolbox\spm12';
roi_dir   = 'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\BrainImg\ROIs\Group_CBDA_Indep';
firlv_dir = 'D:\BrainDev_ANT\FirstLv';
subjlist  = 'C:\Users\haol\Dropbox\Projects\2018_BrainDev_ANT\Results11\sublist_seclv_CBDC.txt';

%% RSA correlation
% Read subject list
fid = fopen(subjlist); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list + 1; %#ok<*SAGROW>
end
fclose(fid);

% Acquire ROIs list
roilist = dir(fullfile(roi_dir,'*.nii'));
roilist = struct2cell(roilist);
roilist = roilist(1,:)';

% Add path
addpath(genpath(spm_dir));

allres = {'Scan_ID'};
for con_i = 1:length(cond_name)
    
    for roi_i = 1:length(roilist)
        allres{1,roi_i+1} = roilist{roi_i,1}(1:end-4);
        roifile = fullfile(roi_dir, roilist{roi_i,1});
        
        mask     = spm_read_vols(spm_vol(roifile));
        rsa_img  = spm_read_vols(spm_vol(rsa_file{con_i,1}));
        rsa_vect = rsa_img(mask(:)==1);
        
        % rsa_vect(isnan(rsa_vect)) = nanmean(rsa_vect);
        
        for sub_i = 1:length(sublist)
            allres{sub_i+1,1} = sublist{sub_i,1};
            
            yearID  = ['20',sublist{sub_i,1}(1:2)];
            sub_file = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
                'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], ...
                [img_type, '_000', num2str(con_i), '.nii']);
            
            sub_img = spm_read_vols(spm_vol(sub_file));
            if resubmask == 1
                sub_vect_nan = sub_img(mask(:)==1);
                rsa_vect = rsa_vect(~isnan(sub_vect_nan));
                
                submaskfile = fullfile(firlv_dir, yearID, sublist{sub_i,1},...
                    'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], 'mask.nii');
                submask = spm_read_vols(spm_vol(submaskfile));
                mask = submask & mask;
            end
            
            sub_vect = sub_img(mask(:)==1);
            
            % sub_vect(isnan(sub_vect)) = nanmean(sub_vect);
            
            [rsa_r, rsa_p] = corr(rsa_vect, sub_vect);
            allres{sub_i+1,roi_i+1} = 0.5*log((1+rsa_r)/(1-rsa_r));
        end
    end
    % save Results
    save_name = ['res_rsa_intersub_multi2one_', cond_name{con_i,1}, '_', img_type,'.csv'];
    
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(allres);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end;
    fclose(fid);
end

%% Done
disp('=== RSA calculate done ===');