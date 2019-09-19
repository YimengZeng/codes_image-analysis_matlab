% hao adapted for his poject on September 12, 2017 from Qin
% ======================================================================== %
% written by hao (ver_18.06.05)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% set up
% sphere ROI info
roinum   = 'no'; % 'yes' or 'no'
radius   = 6;
roi_form = 'mat';

% set path
spm_dir    = 'C:\Users\haol\Dropbox\Toolbox\BrainTools\spm12';
script_dir = 'C:\Users\haol\Dropbox\Codes\Image\ROI_Analy';
roi_save   = 'C:\Users\haol\Dropbox\Projects\2019_BrainDev_ANTgen\BrainImg\ROIs\FF_GrpxCond_CBD_sphere';

% define ROIs by specifying name, coordinates and radius
myroi{1}.name    = 'ROI_FF_Mcond_r01_spl_l';
myroi{1}.coords  = [-26,-62,50];
myroi{1}.radius  = radius;

myroi{2}.name    = 'ROI_FF_Mcond_r02_spl_r';
myroi{2}.coords  = [28,-58,54];
myroi{2}.radius  = radius;

myroi{3}.name    = 'ROI_FF_Mcond_r03_fef_l';
myroi{3}.coords  = [-26,-4,50];
myroi{3}.radius  = radius;

myroi{4}.name    = 'ROI_FF_Mcond_r04_fef_r';
myroi{4}.coords  = [24,0,50];
myroi{4}.radius  = radius;

myroi{5}.name    = 'ROI_FF_Mcond_r05_tpj_l';
myroi{5}.coords  = [-56,-40,34];
myroi{5}.radius  = radius;

myroi{6}.name    = 'ROI_FF_Mcond_r06_tpj_r';
myroi{6}.coords  = [62,-38,46];
myroi{6}.radius  = radius;

myroi{7}.name    = 'ROI_FF_Mcond_r07_vfc_l';
myroi{7}.coords  = [-38,4,30];
myroi{7}.radius  = radius;

myroi{8}.name    = 'ROI_FF_Mcond_r08_vfc_r';
myroi{8}.coords  = [42,4,28];
myroi{8}.radius  = radius;

myroi{9}.name    = 'ROI_FF_Mcond_r09_dacc_l';
myroi{9}.coords  = [-6,30,20];
myroi{9}.radius  = radius;

myroi{10}.name    = 'ROI_FF_Mcond_r10_dacc_r';
myroi{10}.coords  = [6,30,28];
myroi{10}.radius  = radius;

myroi{11}.name    = 'ROI_FF_Mcond_r11_ai_l';
myroi{11}.coords  = [-44,10,-2];
myroi{11}.radius  = radius;

myroi{12}.name    = 'ROI_FF_Mcond_r12_ai_r';
myroi{12}.coords  = [46,12,-2];
myroi{12}.radius  = radius;

myroi{13}.name    = 'ROI_FF_Mcond_r13_lo_l';
myroi{13}.coords  = [-40,-62,-8];
myroi{13}.radius  = radius;

myroi{14}.name    = 'ROI_FF_Mcond_r14_lo_r';
myroi{14}.coords  = [46,-64,-8];
myroi{14}.radius  = radius;

myroi{15}.name    = 'ROI_FF_Mcond_r15_cuneus_l';
myroi{15}.coords  = [-8,-96,12];
myroi{15}.radius  = radius;

myroi{16}.name    = 'ROI_FF_Mcond_r16_cuneus_r';
myroi{16}.coords  = [10,-92,18];
myroi{16}.radius  = radius;
