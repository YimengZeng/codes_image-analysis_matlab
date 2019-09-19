function step2_slictim2coreg(vdmdir, vdmfilter, fundir, funfilter, ...
    t1dir, t1filter, sliceorder, tr, datatype, templatedir)
%% intorduction:
% This function creates VDM (voxel-distortion map) file based on the
% phase image and magnitude images, using the 'presubtracted phase and
% magnitude data' module in SPM8 and SPM12.

%% inputs:
% 1) magimage: the magnitude image for shorter TE, absolute path.
% 2) phaseimage: the phase image, absolute path.
% 3) funcimage: the functional images the researchers want to preprocess, absolute path
% 4) filemapmfile: a .m file contains all the parameters for the fieldmap data.
%    This file would be different across studies, pertinent to the scanner and sequence
%    you use for data collection. Always it could be got from your technician.
% 5) t1: the high-resolution anatomic image for each subjects, it is optional,
%    you can leave a ~ if you don't want to align anatomic image to DVM for quality check.

%% output:
% When the function is finished, you will find an file prefixed 'VDM' in the same folder
% as the phase image; this is the VDM needed in later preprocessing.

%%
[t1, ~]     = select_files(t1dir, t1filter, datatype);
[vdmimg, ~] = select_files(vdmdir, vdmfilter, datatype);
[funimg, ~] = select_files(fundir, funfilter, datatype);
spmver      = spm('version');

if strfind (spmver, 'SPM12')
    % Preprocess from slice timing, realign&unwarp, coregister
    clear matlabbatch;
    load(fullfile(templatedir, 'step2_slictim2coreg.mat'));
    matlabbatch{1}.spm.temporal.st.scans = {strcat(funimg, ',1')};
    matlabbatch{1}.spm.temporal.st.nslices = max(sliceorder);
    matlabbatch{1}.spm.temporal.st.tr = tr;
    matlabbatch{1}.spm.temporal.st.ta = tr-tr/max(sliceorder);
    matlabbatch{1}.spm.temporal.st.so = sliceorder;
    matlabbatch{1}.spm.temporal.st.refslice = sliceorder(ceil(max(sliceorder)/2));
    matlabbatch{2}.spm.spatial.realignunwarp.data.pmscan = {[vdmimg{1}, ',1']};
    matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,1']};
    matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,2']};
    matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,3']};
    matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,4']};
    matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,5']};
    matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,6']};
    matlabbatch{4}.spm.spatial.coreg.estimate.source = {strcat(t1{1}, ',1')};
    
    save(fullfile(fundir, 'step2_subslictim2coreg'), 'matlabbatch');
    spm_jobman('run', matlabbatch);
    
    % Calculate global signals
    [rfiles, ~] = select_files(fundir, 'craI', datatype);
    VY          = spm_vol(rfiles);
    scan_num    = length(VY);
    disp ('Calculating the global signals ...');
    fid = fopen (fullfile (fundir,'VolumRepair_GlobalSignal.txt'),'w+');
    for iScan = 1:scan_num
        fprintf (fid,'%.4f\n',spm_global (VY{iScan}));
    end
    fclose (fid);
    
else
    disp('Please use spm12');
    reutrn;
end
end