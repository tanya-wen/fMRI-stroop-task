%get motion outliers

clear all; clc; dbstop if error;
biac_dir = '/media/tw260/Samsung_T5/fMRI/decodCC.01';
bids_dir = '/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS';

sub_list = readtable(strcat(biac_dir,'/Subject_Log.xlsx'));
good_sub_ind = find(cellfun(@isempty,regexp(sub_list.status,'obs')) & ~cellfun(@isempty,regexp(sub_list.examId,'2018')));
good_sub_num = string(regexp(sub_list.number(good_sub_ind),'(\d*)','tokens'));
good_sub_name = sub_list.examId(good_sub_ind);

for sub = 1:numel(good_sub_name)
    for run = 1:6
        if run <=4
            task = 'stroop';
            tsv_struct = tdfread(fullfile(bids_dir,'derivatives','fmriprep',sprintf('sub-%02d',str2double(good_sub_num{sub})),...
                'func',sprintf('sub-%02d_task-%s_run-%d_desc-confounds_regressors.tsv',str2double(good_sub_num{sub}),task,run)));
        elseif run > 4
            task = 'mem';
            tsv_struct = tdfread(fullfile(bids_dir,'derivatives','fmriprep',sprintf('sub-%02d',str2double(good_sub_num{sub})),...
                'func',sprintf('sub-%02d_task-%s_run-%d_desc-confounds_regressors.tsv',str2double(good_sub_num{sub}),task,run-4)));
        end
        confounds = struct2table(tsv_struct);
        motion = [confounds.trans_x, confounds.trans_y, confounds.trans_z, confounds.rot_x, confounds.rot_y, confounds.rot_z];
        max_motion(sub,run) = max(motion(:));
    end
end


