function [input_img, select_err] = select_files(file_dir, prefix, data_type)

list_file = dir(fullfile(file_dir, [prefix, '.nii.gz']));
if ~isempty(list_file)
    try
        unix(sprintf('gunzip -fq %s', fullfile(file_dir, [prefix, '.nii.gz'])));
    catch
    end
end
select_err = 0;
switch data_type
    case 'img'
        input_img = spm_select('ExtFPList', file_dir, ['^', prefix, '.*.img']);
    case 'nii'
        input_img = spm_select('ExtFPList', file_dir, ['^', prefix, '.nii']);
        V = spm_vol(input_img);
        if size(V(1).private.dat.dim,2)==4
            nframes = V(1).private.dat.dim(4);
            input_img = spm_select('ExtFPList', file_dir, ['^', prefix, '.nii'], (1:nframes));
            clear V nframes;
        end
end
input_img = deblank(cellstr(input_img));
if isempty(input_img{1})
    select_err = 1; %#ok<*NASGU>
    error(['No data  ', fullfile(file_dir, [prefix,'*']), ' was found!!']);
    return; %#ok<*UNRCH>
end
end