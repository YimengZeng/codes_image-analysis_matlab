% written by l.hao (ver_18.09.11)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% ============================== Set Up =============================== %%
% Basic Configure
suffix     = 'haol';
fun_name   = {'ANT1'    ; 'ANT2'    ; 'REST'    };
fun_keywd  = {'A1*nii'  ; 'A2*nii'  ; 'rest*nii'};
fun_fmap   = {'s2'      ; 's2'      ; 's1'      };
tr_del     = {4         ; 4         ; 65        };
tr_rem     = {173       ; 173       ; 175       };
fmap_name  = {'FieldMap_S1'; 'FieldMap_S2'};
fmap_keywd = {'s1'         ; 's2'         };
t1_name    = {'Anatomy'};
t1_keywd   = {'t1*Crop'};

script_dir  = '/Users/haol/Dropbox/Codes/Image/Preprocess/Preproc_spm12_fm';
rawdata_dir = '/Users/haol/Downloads/HaoLab/RawData/CBDC';
preproc_dir = '/Users/haol/Downloads/HaoLab/Preproc';

imglist  = fullfile(script_dir, 'sublist_all_img.txt');
subjlist = fullfile(script_dir, 'sublist_all_match.txt');

% Function Switch
img_conv  = 1;
img_sort  = 1;
tr_delete = 1;
% ======================================================================= %
%% Acquire Subjects List
fid = fopen(imglist); imgall = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    imgall(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

fid = fopen(subjlist); sublist = {}; cnt = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid); [subnum,~] = size(sublist);

%% Image Format Convert
if img_conv == 1
    for iimg = 1:length(imgall)
        imgraw_dir  = fullfile(rawdata_dir, imgall{iimg});
        imgnii_dir  = fullfile(preproc_dir, 'Cache', imgall{iimg}(1:9));
        if ~exist(imgnii_dir, 'dir')
            mkdir (imgnii_dir)
        end
        imgnii_dir1 = [imgnii_dir, '_1'];
        imgnii_dir2 = [imgnii_dir, '_2'];
        
        if exist(imgnii_dir1, 'dir') && exist(imgnii_dir2, 'dir')
            return;
            
        elseif ~exist(imgnii_dir1, 'dir')
            mkdir(imgnii_dir1); cd(imgnii_dir1);
            unix(sprintf(['dcm2niix -x y -z y -o ', imgnii_dir1, ' ', imgraw_dir]));
            
            tempfm_name1 = dir(fullfile(imgnii_dir1, '*gre_field_mapping_2*nii*'));
            if length(tempfm_name1) == 3
                fm_s1 = {tempfm_name1.name};
            end
            unix(sprintf(['mv ', fm_s1{1}, ' s1_mag_shortTE.nii.gz']));
            unix(sprintf(['mv ', fm_s1{2}, ' s1_mag_longTE.nii.gz']));
            unix(sprintf(['mv ', fm_s1{3}, ' s1_phase.nii.gz']));
            
            unix(sprintf(['mv *.nii.gz ', imgnii_dir]));
        elseif exist(imgnii_dir1, 'dir')
            mkdir(imgnii_dir2); cd(imgnii_dir2);
            unix(sprintf(['dcm2niix -x y -z y -o ', imgnii_dir2, ' ', imgraw_dir]));
            
            tempfm_name2 = dir(fullfile(imgnii_dir2, '*gre_field_mapping_2*nii*'));
            if length(tempfm_name2) == 3
                fm_s2 = {tempfm_name2.name};
            end
            unix(sprintf(['mv ', fm_s2{1}, ' s2_mag_shortTE.nii.gz']));
            unix(sprintf(['mv ', fm_s2{2}, ' s2_mag_longTE.nii.gz']));
            unix(sprintf(['mv ', fm_s2{3}, ' s2_phase.nii.gz']));
            
            unix(sprintf(['mv *.nii.gz ', imgnii_dir]));
        end
    end
    cd(script_dir)
end

%% Arrange Anatomy and Function Image
if img_sort == 1
    for isub = 1:subnum
        yearID     = ['20', sublist{isub,2}(1:2)];
        sub_dir    = fullfile(preproc_dir, yearID, sublist{isub,2});
        imgnii_dir = fullfile(preproc_dir, 'Cache', sublist{isub,1});
        
        % Arrange Anatomy Image
        sub_mridir = fullfile(sub_dir, 'sMRI', t1_name{1});
        mkdir(sub_mridir);
        temp_mriname = dir(fullfile(imgnii_dir, ['*', t1_keywd{1}, '*']));
        if isempty(temp_mriname)
            unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                ['list_', t1_name{1}, '_no_', suffix, '.txt'])]);
        elseif length(temp_mriname) == 1
            unix(['mv ', fullfile(imgnii_dir, temp_mriname.name), ' ', ...
                fullfile(sub_mridir, 'I.nii.gz')]);
            unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                ['list_', t1_name{1}, '_yes_', suffix, '.txt'])]);
        end
        
        % Arrange Function Image
        for ifun = 1:length(fun_name)
            sub_fmridir = fullfile(sub_dir, 'fMRI', fun_name{ifun},'Unnormal');
            sub_fmapdir = fullfile(sub_dir, 'fMRI', fun_name{ifun}, ['FieldMap_', fun_name{ifun}]);
            
            mkdir(sub_fmridir); mkdir(sub_fmapdir);
            temp_fmriname = dir(fullfile(imgnii_dir, ['*', fun_keywd{ifun}, '*']));
            
            if isempty(temp_fmriname)
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fun_name{ifun}, '_no_', suffix, '.txt'])]);
            elseif length(temp_fmriname) == 1
                unix(['mv ', fullfile(imgnii_dir, temp_fmriname.name), ' ', ...
                    fullfile(sub_fmridir,'I.nii.gz')]);
                unix(['cp ', fullfile(imgnii_dir, [fun_fmap{ifun}, '*']), ' ', sub_fmapdir]);
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fun_name{ifun}, '_yes_', suffix, '.txt'])]);
            end
        end
        
        % Arrange FieldMap
        for ifm = 1:length(fmap_name)
            fmap_dir = fullfile(sub_dir, 'FieldMap', fmap_name{ifm});
            mkdir(fmap_dir);
            temp_mriname = dir(fullfile(imgnii_dir, [fmap_keywd{ifm}, '*']));
            if length(temp_mriname) == 3
                unix(['mv ', fullfile(imgnii_dir, [fmap_keywd{ifm}, '*']), ' ', fmap_dir]);
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fmap_name{ifm}, '_yes_', suffix, '.txt'])]);
            elseif length(temp_mriname) < 3
                unix(['echo ', sublist{isub,2}, ' >> ', fullfile(script_dir, ...
                    ['list_', fmap_name{ifm}, '_no_', suffix, '.txt'])]);
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