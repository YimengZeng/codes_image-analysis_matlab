function step1_createVDM(magdir, magfilter, phasedir, phasefilter, ...
    fundir, funfilter, t1dir, t1filter, datatype, filemapfile, templatedir)
%% introduction:
% This function creates VDM (voxel-distortion map) file based on the phase
% image and magnitude images, using the 'presubtracted phase and magnitude
% data' module in SPM8 and SPM12;

%% inputs:
% 1) magdir: The directory for magnitude image of shorter TE.
%    magfilter: Prefix of the magitude image.
% 2) phasedir: The directory for phase image.
%    phasefilter: Prefix of the phase image.
% 3) funcdir: The directory of functional images the researchers want to preprocess.
%    funcfilter: Prefix of the functional images.
% 4) filemapmfile: a .m file contains all the parameters for the fieldmap data.
%    This file would be different across studies, pertinent to the scanner
%    and sequence you use for data collection. Always it could be got from
%    your technician, absolute path.
% 5) t1dir and t1filter: the high-resolution anatomic image for each subjects, it is
%    optional, you can leave a ~ if you don't want to align anatomic image to DVM
%    for quality check. If you want to do this, t1 image should be in its absolute path.

%% output:
% When the function is finished, you will find an file prefixed 'VDM' in the
% same folder as the phase image; this is the VDM needed in later preprocessing.

%%
[funimg, ~]   = select_files(fundir, funfilter, datatype);
[magimg, ~]   = select_files(magdir, magfilter, datatype);
[phaseimg, ~] = select_files(phasedir, phasefilter, datatype);
spmver        = spm('version');

if strfind(spmver,'SPM12')
    clear matlabbatch;
    load(fullfile(templatedir,'step1_createVDM.mat'));
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {[phaseimg{1}, ',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {[magimg{1}, ',1']};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsfile = {filemapfile};
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi = {[funimg{1}, ',1']};
    % use the first volume of the functional images here, just for quality inspection.
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
    matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
    if exist(t1dir, 'var') && exist(t1filter, 'var')
        [t1, ~] = selectfiles(t1dir, t1filter, datatype);
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = {[t1, ',1']};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 1;
    else
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = {''};
        matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
    end
    
    save(fullfile(fundir, 'step1_subcreateVDM'), 'matlabbatch');
    spm_jobman('run', matlabbatch);
    
else
    disp('Please use spm12');
    reutrn;
end
end
