function step1_script(fundir, funfilter, t1dir, t1filter, slcorder, timerepet, datatype, templatedir)
%%
[fun, ~] = select_files(fundir, funfilter, datatype);
[t1, ~]  = select_files(t1dir, t1filter, datatype);
spmver   = spm('version');

if strfind(spmver,'SPM12')
    % Preprocess from slice timing, realign & unwarp, coregister
    clear matlabbatch;
    load(fullfile(templatedir,'step1_batch.mat'));
    matlabbatch{1}.spm.temporal.st.scans = {strcat(fun,',1')};
    nslices = max(slcorder);
    matlabbatch{1}.spm.temporal.st.nslices = nslices;
    matlabbatch{1}.spm.temporal.st.tr = timerepet;
    matlabbatch{1}.spm.temporal.st.ta = timerepet-timerepet/nslices;
    matlabbatch{1}.spm.temporal.st.so = slcorder;
    matlabbatch{1}.spm.temporal.st.refslice = slcorder(ceil(nslices/2));
    % matlabbatch{2} is realignment
    matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,1']};
    matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,2']};
    matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,3']};
    matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,4']};
    matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,5']};
    matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {[spm('dir'),filesep,'tpm',filesep,'TPM.nii,6']};
    matlabbatch{4}.spm.spatial.coreg.estimate.source = {strcat(t1{1},',1')};
    save(fullfile(fundir,'step1_subbatch'),'matlabbatch')
    spm_jobman('run',matlabbatch);
    
    % Calculate global signals
    [rfiles,~] = select_files(fundir, 'craI', datatype);
    VY         = spm_vol(rfiles);
    scan_num   = length(VY);
    disp('Calculating the global signals ...');
    fid = fopen(fullfile(fundir, 'VolumRepair_GlobalSignal.txt'), 'w+');
    for iscan = 1:scan_num
        fprintf(fid, '%.4f\n', spm_global(VY{iscan}));
    end
    fclose(fid);
else
    disp('Please use spm12');
    reutrn;
end
end
