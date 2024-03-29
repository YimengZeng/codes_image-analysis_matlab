function step3_seg2smooth(fundir, funfilter, t1dir, t1filter, datatype, ...
    templatedir, normvox, smthwidth)
%%
[t1, ~] = select_files(t1dir, t1filter, datatype);
spmver  = spm('version');

if strfind(spmver,'SPM12')
    unix(sprintf(['fslsplit ', funfilter, '.nii ', funfilter, ' -t']));
    unix(sprintf(['gunzip ', funfilter, '*.nii.gz']));
    unix(sprintf(['rm ', funfilter, '.nii']));
    
    % run bias4epi
    p1 = spm_select('ExtFPList', fundir, ['^', 'BiasField', '.*.nii']);
    p2 = spm_select('ExtFPList', fundir, ['^', funfilter, '0', '.*.nii']);
    n  = size(p2,1);
    for i = 1:n
        P = char(p1(1,:), p2(i,:));
        fname = p2(i,:);
        [path, name, ext] = fileparts(fname);
        Q = fullfile(path, ['m' name ext]);
        disp(['Writing: ' fname]);
        f = 'i2.*i1';
        flags = {[], [], [1], [4]}; %#ok<*NBRAK>
        Q = spm_imcalc(P, Q, f, flags); %#ok<*NASGU>
    end
    
    % segment the anatomical images
    clear matlabbatch;
    load(fullfile(templatedir,'step3_seg2smooth.mat'));
    matlabbatch{1}.spm.spatial.preproc.channel.vols = t1;
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,1']};
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,2']};
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,3']};
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,4']};
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,5']};
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,6']};
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{2}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', ...
        substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    muafiles = dir(fullfile(fundir, ['m', funfilter, '0*']));
    muafiles = {muafiles.name};
    muafiles = strcat(fundir, filesep, muafiles', ',1');
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample = muafiles;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72; 90 90 108];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = normvox;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{3}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', ...
        substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{3}.spm.spatial.smooth.fwhm = smthwidth;
    matlabbatch{3}.spm.spatial.smooth.dtype = 0;
    matlabbatch{3}.spm.spatial.smooth.im = 0;
    
    save(fullfile(fundir, 'step3_subseg2smooth'), 'matlabbatch');
    spm_jobman('run',matlabbatch);
    
else
    disp('Please use spm12');
    reutrn;
end
end