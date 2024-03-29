% Slice-timing step
%__________________________________________________________________________
%-SCSNL, Tianwen Chen, 2011-11-06

function preprocessfmri_slicetime_org (WholePipeLine, TemplatePath, ImgFiles, FlipFlag, PfileDir, OutputDir)

Efile = dir(fullfile(PfileDir, 'E*'));

if isempty(Efile)
  disp('No Efile found. TR is set to 2 second');
  TR = 2;
else
  if length(Efile) > 1
    disp('Multiple E files found. TR is set to 2 seconds');
    TR = 2;
  else
    Efile = fullfile(PfileDir, Efile(1).name);
    TR = GetTR(Efile);
  end
end

load(fullfile(TemplatePath, 'batch_slice_timing.mat'));

matlabbatch{1}.spm.temporal.st.scans{1} = {};
matlabbatch{1}.spm.temporal.st.scans{1} = ImgFiles;
V = spm_vol(matlabbatch{1}.spm.temporal.st.scans{1}{1});
nslices = V.dim(3);
matlabbatch{1}.spm.temporal.st.nslices = nslices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TR - TR/nslices;
matlabbatch{1}.spm.temporal.st.refslice = ceil(nslices/2);
if FlipFlag == 1
  matlabbatch{1}.spm.temporal.st.so = nslices:-1:1;
else
  matlabbatch{1}.spm.temporal.st.so = 1:nslices;
end

LogDir = fullfile(OutputDir, 'log');
if ~exist(LogDir, 'dir')
  mkdir(LogDir);
end

% Update and save batch
BatchFile = fullfile(LogDir, ['batch_slice_timing_', WholePipeLine, '.mat']);
save(BatchFile, 'matlabbatch');

% Run batch of slice_timing
spm_jobman('run', BatchFile);
clear matlabbatch;

end


function TR = GetTR (Efile)

fid   = fopen(Efile);

while 1
  tline = fgetl(fid);
  if ~ischar(tline),   break,   end
  [a b c d e] = regexpi(tline, '^TR[\s\t]*=[\s\t]*(\d+)');
  if(~isempty(a))
    TR = str2double(e{1})/1000;
    break;
  end
end

if fid > 0; fclose(fid); end

end