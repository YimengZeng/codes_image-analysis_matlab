% written by l.hao (ver_18.09.12)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Basic configure
suffix    = 'haol';
fun_name  = {'ANT1'    ; 'ANT2'    ; 'REST'    };
fun_keywd = {'ANT1*nii'; 'ANT2*nii'; 'rest*nii'};
tr_del    = {4         ; 4         ; 5         };
tr_rem    = {173       ; 173       ; 175       };
t1_folder = {'Anatomy'};
t1_keywd  = {'t1*Crop'};

script_dir  = '/home/codetest/Codes/Preprocess/Preproc_spm12';
rawdata_dir = '/home/codetest/HaoData/Raw/SWUC';
preproc_dir = '/home/codetest/HaoData/Preproc_spm12';
subjlist    = fullfile(script_dir, 'sublist_all_match.txt');

% Function Switch
img_conv    = 1;
img_sort    = 1;
tr_delete   = 1;
% ======================================================================= %
%% Acquire Subjects List
fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid); [subnum,~] = size(sublist);

%% Image Format Convert
if img_conv == 1
    for isub = 1:subnum
        sub_rawdata = struct2cell(dir(fullfile(rawdata_dir, sublist{isub,1})));
        sub_rawdata = sub_rawdata(1, cell2mat(sub_rawdata(5,:)))';
        sub_output  = fullfile(preproc_dir, 'Cache', sublist{isub,2});
        mkdir(sub_output);
        for idcm = 3:length(sub_rawdata)
            unix(sprintf(['dcm2niix -x y -z y -o ', sub_output, ' ', ...
                fullfile(rawdata_dir, sublist{isub,1}, sub_rawdata{idcm,1})]));
        end
    end
end

%% Arrange Anatomy and Function Image
if img_sort == 1
    for isub = 1:subnum
        yearID     = ['20', sublist{isub,2}(1:2)];
        sub_output = fullfile(preproc_dir, 'Cache', sublist{isub,2});
        
        % Arrange Anatomy Image
        sub_mridir   = fullfile(preproc_dir,yearID,sublist{isub,2}, 'sMRI', t1_folder{1});
        temp_mriname = dir(fullfile(sub_output, ['*', t1_keywd{1}, '*']));
        if isempty(temp_mriname)
            unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                ['list_', t1_folder{1}, '_no_', suffix, '.txt'])]);
        elseif length(temp_mriname) == 1
            mkdir(sub_mridir);
            unix(['mv ', fullfile(sub_output,temp_mriname.name), ' ', ...
                fullfile(sub_mridir, 'I.nii.gz')]);
            unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                ['list_', t1_folder{1}, '_yes_', suffix, '.txt'])]);
        end
        
        % Arrange Function Image
        for ifun = 1:length(fun_name)
            sub_fundir = fullfile(preproc_dir, yearID, sublist{isub,2}, ...
                'fMRI', fun_name{ifun,1}, 'Unnormal');
            temp_fmriname = dir([sub_output,'/*',fun_keywd{ifun,1},'*']);
            if isempty(temp_fmriname)
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fun_name{ifun,1}, '_no_', suffix, '.txt'])]);
            elseif length(temp_fmriname) == 1
                mkdir(sub_fundir);
                unix (['mv ',fullfile(sub_output,temp_fmriname.name),' ',...
                    fullfile(sub_fundir,'I.nii.gz')]);
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fun_name{ifun,1}, '_yes_', suffix, '.txt'])]);
            end
        end
    end
    % unix(['rm -rf ', fullfile(preproc_dir, 'Cache')]);
end

%% TR Delete
if tr_delete == 1
    for ifun = 1:length(fun_name)
        subjlist_fun = fullfile(script_dir, ['list_', fun_name{ifun}, ...
            '_yes_', suffix, '.txt']);
        fid = fopen(subjlist_fun); sublist_fun = {}; cnt = 1;
        while ~feof(fid)
            linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
            sublist_fun(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
        end
        fclose(fid);
        
        for isub = 1:length(sublist_fun)
            yearID = ['20', sublist_fun{isub}(1:2)];
            sub_dir = fullfile(preproc_dir, yearID, sublist_fun{isub});
            sub_fundir = fullfile(sub_dir, 'fMRI', fun_name{ifun}, 'Unnormal');
            
            unix(['mv ', fullfile(sub_fundir,'I.nii.gz'), ' ', ...
                fullfile(sub_fundir, 'I_all.nii.gz')]);
            unix(['fslroi ', fullfile(sub_fundir, 'I_all.nii.gz'), ' ', ...
                fullfile(sub_fundir, 'I.nii.gz'), ' ', ...
                num2str(tr_del{ifun,1}), ' ', num2str(tr_rem{ifun,1})]);
        end
    end
end

%% Done
disp('=== Image Arrange Done ===');