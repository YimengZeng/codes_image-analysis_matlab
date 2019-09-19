% % written by l.hao (ver_18.09.14)
% % rock3.hao@gmail.com
% % qinlab.BNU
% clear
% clc
% 
% %% Set Up Directory
% script_dir = '/home/haolei/BrainDev_ANT/Codes/Others';
% subjlist   = '/home/haolei/BrainDev_ANT/Codes/Others/sublist_All.txt';
% orig_dir   = '/home/haolei/BrainDev_ANT/Preproc';
% dest_dir   = '/home/haolei/BrainDev_ANT/Preproc_new';
% 
% 
% firlv_dir    = '/home/haolei/ANT_1stLv/ANT_1stLv_4cAll';
% firlv_arrdir = '/home/haolei/MyProjects/ANT_Analy/FirstLv/ANT_1stLv_4cAll';
% 
% %% Function Switch
% cp_preproc = 1;
% cp_firstlv = 0;
% 
% %% Read Sublist
% fid = fopen(subjlist); sublist  = {}; cnt = 1;
% while ~feof(fid)
%     linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
%     sublist(cnt,:) = linedata{1}; cnt = cnt+1;  %#ok<*SAGROW>
% end
% fclose(fid);
% 
% %% Copy Preproc Files
% if cp_preproc == 1
%     for isub = 1:length(sublist)
%         yearID = ['20', sublist{isub}(1:2)];
%         source_dir01 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT1', 'smoothed_spm12', '*');  
%         source_dir02 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT1', 'ANT1_FieldMap', '*');
%         source_dir03 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT1', 'unnormalized', '*');
%         
%         source_dir04 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT2', 'smoothed_spm12', '*');  
%         source_dir05 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT2', 'ANT2_FieldMap', '*');
%         source_dir06 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'ANT2', 'unnormalized', '*');
%         
%         source_dir07 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'REST', 'smoothed_spm12', '*');  
%         source_dir08 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'REST', 'REST_FieldMap', '*');
%         source_dir09 = fullfile(orig_dir, yearID, sublist{isub}, 'fmri', ...
%             'REST', 'unnormalized', '*');
%         
%         source_dir10 = fullfile(orig_dir, yearID, sublist{isub}, 'mri', ...
%             'anatomy', '*');
%         source_dir11 = fullfile(orig_dir, yearID, sublist{isub}, 'mri', ...
%             'S1_FieldMap', '*');
%         source_dir12 = fullfile(orig_dir, yearID, sublist{isub}, 'mri', ...
%             'S2_FieldMap', '*');
%         
%         target_dir01 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT1', 'Smooth_spm12');  
%         target_dir02 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT1', 'FieldMap_ANT1');
%         target_dir03 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT1', 'Unnormal');
%         
%         target_dir04 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT2', 'Smooth_spm12');  
%         target_dir05 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT2', 'FieldMap_ANT2');
%         target_dir06 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'ANT2', 'Unnormal');
%         
%         target_dir07 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'REST', 'Smooth_spm12');  
%         target_dir08 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'REST', 'FieldMap_REST');
%         target_dir09 = fullfile(dest_dir, yearID, sublist{isub}, 'fMRI', ...
%             'REST', 'Unnormal');
%         
%         target_dir10 = fullfile(dest_dir, yearID, sublist{isub}, 'sMRI', ...
%             'Anatomy');
%         target_dir11 = fullfile(dest_dir, yearID, sublist{isub}, 'FieldMap', ...
%             'FieldMap_S1');
%         target_dir12 = fullfile(dest_dir, yearID, sublist{isub}, 'FieldMap', ...
%             'FieldMap_S2');
% 
%         
%         mkdir(target_dir01);
%         mkdir(target_dir02);
%         mkdir(target_dir03);
%         mkdir(target_dir04);
%         mkdir(target_dir05);
%         mkdir(target_dir06);
%         mkdir(target_dir07);
%         mkdir(target_dir08);
%         mkdir(target_dir09);
%         mkdir(target_dir10);
%         mkdir(target_dir11);
%         mkdir(target_dir12);
%         
%         unix(['mv ', source_dir01, ' ', target_dir01]);
%         unix(['mv ', source_dir02, ' ', target_dir02]);
%         unix(['mv ', source_dir03, ' ', target_dir03]);
%         unix(['mv ', source_dir04, ' ', target_dir04]);
%         unix(['mv ', source_dir05, ' ', target_dir05]);
%         unix(['mv ', source_dir06, ' ', target_dir06]);
%         unix(['mv ', source_dir07, ' ', target_dir07]);
%         unix(['mv ', source_dir08, ' ', target_dir08]);
%         unix(['mv ', source_dir09, ' ', target_dir09]);
%         unix(['mv ', source_dir10, ' ', target_dir10]);
%         unix(['mv ', source_dir11, ' ', target_dir11]);
%         unix(['mv ', source_dir12, ' ', target_dir12]);
%         
%     end
% end
% 
% %% Copy FirstLv Files
% if cp_firstlv == 1
%     for isub = 1:length(sublist)
%         yearID = ['20', sublist{isub}(1:2)];
%         firlv_dir1 = fullfile(firlv_dir, yearID, sublist{isub});
%         
%         firlv_arrair1 = fullfile(firlv_arrdir, sublist{isub});
%         mkdir(firlv_arrair1)
%         
%         copyfile(firlv_dir1, firlv_arrair1)
%         
%     end
% end
% 
% %% Done
% cd(script_dir); disp('All Done');