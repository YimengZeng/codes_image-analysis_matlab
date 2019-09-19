% written by l.hao (ver_19.01.08)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
task_name = 'ANT';
run_ppl   = 'swa';
img_type  = 'con'; % 'spmT' or 'con'
cond_num  = {'12';'13';'23'};

spm_dir    = '/Users/haol/Dropbox/Toolbox/BrainTools/spm12';
roi_dir    = '/Users/haol/Downloads/DataAnalyTest/ROIs';
firlv_dir  = '/Users/haol/Downloads/DataAnalyTest/FirstLv';
subjlist   = '/Users/haol/Downloads/DataAnalyTest/Codes/MultivarRSA/list_ANT_yes_haol.txt';

%% RSA correlation
% read subject list
fid = fopen(subjlist); sublist = {}; cnt_list = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_list,:) = linedata{1}; cnt_list = cnt_list + 1; %#ok<*SAGROW>
end
fclose(fid);

% acquire ROIs list
roi_list = dir(fullfile(roi_dir,'*.nii'));
roi_list = struct2cell(roi_list);
roi_list = roi_list(1,:)';

% add path
addpath(genpath(spm_dir));

for icon = 1:length(cond_num)
    allres = {'Scan_ID', 'Conds'};
    for iroi = 1:length(roi_list)
        allres{1,iroi+2} = roi_list{iroi,1}(1:end-4);
        roi_file = fullfile(roi_dir, roi_list{iroi,1});
        mask = spm_read_vols(spm_vol(roi_file));
        
        grp_vect = {};
        for isub = 1:length(sublist)
            yearID = ['20', sublist{isub,1}(1:2)];
            img_1  = fullfile(firlv_dir, yearID, sublist{isub,1},...
                'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], ...
                [img_type,'_000',cond_num{icon,1}(1),'.nii']);
            img_2  = fullfile(firlv_dir, yearID, sublist{isub,1},...
                'fMRI', 'Stats_spm12', task_name, ['Stats_spm12_', run_ppl], ...
                [img_type,'_000',cond_num{icon,1}(2),'.nii']);
            
            sub_img1 = spm_read_vols(spm_vol(img_1));
            sub_vect1 = sub_img1(mask(:)==1);
            sub_img2 = spm_read_vols(spm_vol(img_2));
            sub_vect2 = sub_img2(mask(:)==1);
            
            grp_vect{isub,1} = sub_vect1;
            grp_vect{isub,2} = sub_vect2;
        end
        
        for isub = 1:length(sublist)
            allres{isub+1,1} = sublist{isub,1};
            allres{isub+1,2} = cond_num{icon};
            val_cnt = 0;
            
            for iisub = 1:length(sublist)
                if iisub == isub
                    continue
                else
                    [rsa_r, rsa_p] = corr(grp_vect{isub,1}, grp_vect{iisub,2});
                    val_icnt = 0.5*log((1+rsa_r)/(1-rsa_r));
                    
                end
                val_cnt = val_cnt + val_icnt;
            end
            
            val_cnt = val_cnt / (length(sublist) - 1);
            allres{isub+1,iroi+2} = val_cnt;
            
        end
    end
    
    save_name = ['res_rsa_intersub_intercond_',cond_num{icon,1}, '_', img_type, '.csv'];
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(allres);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, allres{row_i,:}); end;
    fclose(fid);
end

%% done
disp('=== RSA calculate done ===');