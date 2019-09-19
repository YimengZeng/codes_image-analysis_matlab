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
radius   = 5;
roi_form = 'nii';

% set path
spm_dir    = 'C:\Users\haol\Dropbox\Toolbox\BrainTools\spm12';
script_dir = 'C:\Users\haol\Dropbox\Codes\Image\ROI_Analy';
roi_save   = 'C:\Users\haol\Dropbox\Codes\Image\ROI_Analy\xxx';

% define ROIs by specifying name, coordinates and radius
myroi{1}.name    = 'AI_R';
myroi{1}.coords  = [30,22,4];
myroi{1}.radius  = radius;

myroi{2}.name    = 'AI_L';
myroi{2}.coords  = [-30,24,2];
myroi{2}.radius  = radius;

myroi{3}.name    = 'DLPFC_L';
myroi{3}.coords  = [-44,28,30];
myroi{3}.radius  = radius;

myroi{4}.name    = 'DLPFC_R';
myroi{4}.coords  = [42,38,30];
myroi{4}.radius  = radius;

myroi{5}.name    = 'IFG_R';
myroi{5}.coords  = [54,10,14];
myroi{5}.radius  = radius;

myroi{6}.name    = 'IFG_L';
myroi{6}.coords  = [-50,12,14];
myroi{6}.radius  = radius;

myroi{7}.name    = 'IPL_L';
myroi{7}.coords  = [-34,-48,44];
myroi{7}.radius  = radius;

myroi{8}.name    = 'IPL_R';
myroi{8}.coords  = [38,-48,44];
myroi{8}.radius  = radius;

myroi{9}.name    = 'DACC_R';
myroi{9}.coords  = [8,26,32];
myroi{9}.radius  = radius;

myroi{10}.name    = 'DACC_L';
myroi{10}.coords  = [-10,14,44];
myroi{10}.radius  = radius;

myroi{11}.name    = 'PCC';
myroi{11}.coords  = [-2,-50,24];
myroi{11}.radius  = radius;

myroi{12}.name    = 'VMPFC';
myroi{12}.coords  = [-2,50,-6];
myroi{12}.radius  = radius;

myroi{13}.name    = 'PHG_R';
myroi{13}.coords  = [30,-32,-16];
myroi{13}.radius  = radius;

myroi{14}.name    = 'PHG_L';
myroi{14}.coords  = [-26,-22,-18];
myroi{14}.radius  = radius;

myroi{15}.name    = 'AG_R';
myroi{15}.coords  = [50,-62,26];
myroi{15}.radius  = radius;

myroi{16}.name    = 'AG_L';
myroi{16}.coords  = [-46,-70,32];
myroi{16}.radius  = radius;
