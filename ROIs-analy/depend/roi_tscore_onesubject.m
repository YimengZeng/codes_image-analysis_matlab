function [tscore_average, tscore_percent_voxels] = ...
    roi_tscore_onesubject(ROIs, subject_stats_dir, tscore_threshold)
% initialize input
session = 1; % NOTE ONLY 1 session for contrast data all

% initialize output
tscore_average = {};
tscore_percent_voxels = {};
tscore_average.subject_stats_dir = subject_stats_dir; % subject ID
tscore_percent_voxels.subject_stats_dir = subject_stats_dir; % subject ID

% reminder
disp(['using threshold ', mat2str(tscore_threshold), [' to compute tscore.' ...
    ' see marsbar FAQ for explanation']]);

% get ROIs
if iscell(ROIs) % already a cell array
    ROI_list = ROIs;
elseif ischar(ROIs) % is string, check if valid directory
    if isdir(ROIs)
        [files, ~] = spm_select('list',ROIs,'.*\_roi.mat$');
        if (isempty(files))
            error('folder contains no ROIs')
        end
        for i=1:size(files,1)
            ROI_list{i} = strcat(ROIs, '/', files(i,:)); %#ok<*AGROW>
        end
    end
else
    error('please enter a valid ROI cell array or folder');
end

% load SPM.mat
SPM_mat = [subject_stats_dir, '/SPM.mat'];
load(SPM_mat);

% get number of sessions and ROIs
nroi = length(ROI_list);
ncontrasts = size(SPM.xCon, 2);

for contrast = 1:ncontrasts
    if (SPM.xCon(contrast).STAT == 'T')
        fullpath = strfind(SPM.xCon(contrast).Vspm.fname, '/');
        if (length(fullpath) > 0) %#ok<*ISMT>
            spmT_img = strcat('/', SPM.xCon(contrast).Vspm.fname);
        else
            spmT_img = strcat(subject_stats_dir, '/', SPM.xCon(contrast).Vspm.fname);
        end
        tscore_average.event_name{session}{contrast} = SPM.xCon(contrast).name;
        tscore_percent_voxels.event_name{session}{contrast} = SPM.xCon(contrast).name;
        % unix(['gunzip -fq ', spmT_img]); % unzip if zipped
        
        for iroi=1:nroi % for each ROI
            % setup ROI
            rois = ROI_list{iroi};
            
            roi_obj = maroi(rois);
            
            tscore_average.roi_name{iroi} = label(roi_obj); % ROI names
            tscore_percent_voxels.roi_name{iroi} = label(roi_obj);
            
            roi_tscores = getdata(roi_obj, spmT_img, 'z');
            tscore_average.data_roi_sess_event{iroi}{session}(contrast) = mean(roi_tscores);
            tscore_percent_voxels.data_roi_sess_event{iroi}{session}(contrast) = mean(roi_tscores > tscore_threshold) * 100;
        end
        % unix(['gzip -q -1', spmT_img]); % gzip back
    end
end
