% Slice-timing step
%__________________________________________________________________________
%-SCSNL, Tianwen Chen, 2011-11-06

function preprocessfmri_slicetime(WholePipeLine, TemplatePath, ImgFiles, PfileDir, OutputDir, tr, sliceorder)

Efile = dir(fullfile(PfileDir, 'E*'));

if isempty(Efile)
  disp(['No Efile found. TR is set to ', num2str(tr),'.']);
  TR = tr;
else
  if length(Efile) > 1
    disp(['Multiple E files found. TR is set to ', num2str(tr),'.']);
    TR = tr;
  else
    Efile = fullfile(PfileDir, Efile(1).name);
    TR = GetTR(Efile);
  end
end
load(fullfile(TemplatePath, 'batch_slice_timing.mat'));

matlabbatch{1}.spm.temporal.st.scans{1} = {};
matlabbatch{1}.spm.temporal.st.scans{1} = ImgFiles;
% V = spm_vol(matlabbatch{1}.spm.temporal.st.scans{1}{1});
% nslices = V.dim(3);
matlabbatch{1}.spm.temporal.st.nslices = max(sliceorder);
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TR - TR/max(sliceorder);
matlabbatch{1}.spm.temporal.st.refslice =sliceorder(ceil(length(sliceorder)/2));
matlabbatch{1}.spm.temporal.st.so = sliceorder;

LogDir = fullfile(OutputDir, 'Logs');
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
  [a b c d e] = regexpi(tline, '^TR[\s\t]*=[\s\t]*(\d+)'); %#ok<*NCOMMA,*ASGLU>
  if(~isempty(a))
    TR = str2double(e{1})/1000;
    break;
  end
end

if fid > 0; fclose(fid); end

end
