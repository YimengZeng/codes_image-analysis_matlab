%% function of preprocessing
% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU

function fun_preproc_spm12_1by1(runppl, fundir, t1dir, smthdir, slcorder, ...
    timerepet, normvox, smthwidth, datatype, templatedir)
cd(fundir)
step1_script(fundir, 'I', t1dir, 'I', slcorder, timerepet, datatype, templatedir);

print -painters -dpsc output_spm.ps;
psfile_c = dir(fullfile(fundir, 'output_spm.ps'));
pdffile_c = fullfile(fundir, ['coregister_spm12_', runppl, '.pdf']);
unix(sprintf('ps2pdf13 %s %s', fullfile(fundir, psfile_c.name), pdffile_c));

psfile_r = dir(fullfile(fundir, 'spm_*.ps'));
pdffile_r = fullfile(fundir, ['realign_spm12_', runppl, '.pdf']);
unix(sprintf('ps2pdf13 %s %s', fullfile(fundir, psfile_r.name), pdffile_r));

step2_script(fundir, 'craI', t1dir, 'I', datatype, normvox, smthwidth, templatedir);

unix(sprintf('gzip meanaI.nii'));
unix(sprintf('gzip wcraI.nii'));
unix(sprintf('gzip swcraI.nii'));
unix(sprintf('gzip I.nii'));

rpfile       = fullfile(fundir, 'rp_aI.txt');
meanfile     = fullfile(fundir, 'meanaI.nii.gz');
vlmGS        = fullfile(fundir, 'VolumRepair_GlobalSignal.txt');
smoothfile   = fullfile(fundir, 'wcraI.nii.gz');
unsmoothfile = fullfile(fundir, 'swcraI.nii.gz');

if ~exist(smthdir, 'dir'); mkdir(smthdir); end;
movefile(rpfile, smthdir);
movefile(meanfile, smthdir);
movefile(vlmGS, smthdir);
movefile(smoothfile, smthdir);
movefile(unsmoothfile, smthdir);
movefile('*.pdf', fullfile(smthdir, 'Logs'));
movefile('step*.mat', fullfile(smthdir, 'Logs'));

unix(sprintf('rm *.ps'));
unix(sprintf('rm *.mat'));
unix(sprintf('rm *.nii'));
end