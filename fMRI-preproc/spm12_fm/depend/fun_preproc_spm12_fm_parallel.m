%% function of preprocessing
% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU

function fun_preproc_spm12_fm_parallel(slcorder, timerepet, vdmdir, vdmfilter, ...
    magdir, magfilter, phasedir, phasefilter, fundir, t1dir, smthdir, smthwidth, ...
    normvox, datatype, fieldmap, templatedir)

cd(magdir);
step1_createVDM(magdir, magfilter, phasedir, phasefilter, ...
    fundir, 'I', t1dir, 'I', datatype, fieldmap, templatedir);
% unix(sprintf('ps2pdf13 %s %s', 'spm_*.ps', ['calcuateVDM_spm12_', runppl, '.pdf']));

cd(fundir);
step2_slictim2coreg(vdmdir, vdmfilter, fundir, 'I', t1dir, 'I', ...
    slcorder, timerepet, datatype, templatedir);
% unix(sprintf('ps2pdf13 %s %s', 'spm_*.ps', ['realign_spm12_', runppl, '.pdf']));
% print -painters -dpsc output_spm.ps;
% unix(sprintf('ps2pdf13 %s %s', 'output_spm.ps', ['coregister_spm12_', runppl, '.pdf']));

step3_seg2smooth(fundir, 'craI', t1dir, 'I', datatype, templatedir, normvox, smthwidth);

% Merge Files
disp('Merge Files ...');

unix(sprintf('fslmerge -a swcraI swmcraI0*.nii'));
unix(sprintf('fslmerge -a wcraI wmcraI0*.nii'));
unix(sprintf('gzip meancraI.nii'));
unix(sprintf('gzip I.nii'));
unix(sprintf('rm *.nii'));

rpfile       = fullfile(fundir, 'rp_aI.txt');
meanfile     = fullfile(fundir, 'meancraI.nii.gz');
vlmGS        = fullfile(fundir, 'VolumRepair_GlobalSignal.txt');
smoothfile   = fullfile(fundir, 'swcraI.nii.gz');
unsmoothfile = fullfile(fundir, 'wcraI.nii.gz');

if ~exist(smthdir, 'dir'); mkdir(smthdir); end;
unix(sprintf(['mv ', rpfile, ' ', smthdir]));
unix(sprintf(['mv ',meanfile, ' ', smthdir]));
unix(sprintf(['mv ',vlmGS, ' ', smthdir]));
unix(sprintf(['mv ',smoothfile, ' ', smthdir]));
unix(sprintf(['mv ',unsmoothfile, ' ', smthdir]));
if ~exist(fullfile(smthdir, 'Logs'), 'dir'); mkdir(fullfile(smthdir, 'Logs')); end;
unix(sprintf(['mv step*.mat ', fullfile(smthdir, 'Logs')]));
% unix(sprintf(['mv *.pdf ', fullfile(smthdir, 'Logs')]));

% unix(sprintf('rm *.ps'));
unix(sprintf('rm *.mat'));

cd(magdir)
% unix(sprintf(['mv *.pdf ', fullfile(smthdir, 'Logs')]));
unix(sprintf(['gzip ', magfilter, '.nii']));
unix(sprintf(['gzip ', phasefilter, '.nii']));
% unix(sprintf('rm *.ps'));
unix(sprintf('rm *.nii'));

end