function [input_img, select_err] = ...
    preprocessfmri_selectfiles(file_dir, prefix, data_type)
select_err = 0;

switch data_type
    case 'img'
        input_img = spm_select('ExtFPList', file_dir, ['^', prefix, 'I.*\.img']);
    case 'nii'
        input_img = spm_select('ExtFPList', file_dir, ['^', prefix, 'I.*\.nii']);
        V = spm_vol(input_img);
        nframes = V(1).private.dat.dim(4);
        input_img = spm_select('ExtFPList', file_dir, ['^', prefix, 'I.*\.nii'], (1:nframes));
        clear V nframes;
end
input_img = deblank(cellstr(input_img));

if isempty(input_img{1})
    select_err = 1;
end

end