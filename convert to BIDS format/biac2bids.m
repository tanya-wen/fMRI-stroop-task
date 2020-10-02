% Tanya Wen 2020/05/21
clear all; clc; dbstop if error;
%% convert Duke BIAC output to BIDS format
biac_dir = 'C:/Users/Tanya Wen/Desktop/fMRI/decodCC.01';
bids_dir = 'C:/Users/Tanya Wen/Desktop/fMRI/decodCC.01_BIDS/Nifti';

sub_list = readtable(strcat(biac_dir,'/Subject_Log.xlsx'));
good_sub_ind = find(cellfun(@isempty,regexp(sub_list.status,'obs')) & ~cellfun(@isempty,regexp(sub_list.examId,'2018')));
good_sub_num = string(regexp(sub_list.number(good_sub_ind),'(\d*)','tokens'));
good_sub_name = sub_list.examId(good_sub_ind);

%% Make subject folder
for sub = 1:numel(good_sub_name)
    if ~exist(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub}))),'dir')
        mkdir(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub}))));
        mkdir(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'anat'));
        mkdir(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'func'));
    end
end

%% Anat
for sub = 1:numel(good_sub_name)
    % Prepare the BIAC filename (get the first T1 for each subject).
    biacAnatDir = dir(strcat(biac_dir,'/fMRI/Anat/',good_sub_name{sub}));
    biacAnatFiles = find(~cellfun(@isempty,regexp({biacAnatDir.name},'bia5_(\d*)_(\d*).nii.gz')));
    biacAnatFile = biacAnatDir(biacAnatFiles(1)).name;
    % Prepare the BIDS filename.
    bidsAnat = sprintf('sub-%02d_T1w.nii.gz', str2double(good_sub_num(sub)));
    % Do the copying and renaming of the file into BIDS folder.
    copyfile(fullfile(biac_dir,'fMRI','Anat',good_sub_name{sub},biacAnatFile),fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'anat',bidsAnat));
    % Write the json file
    write_anat_josn(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'anat'),good_sub_num{sub});
end

%% Func
for sub = 1:numel(good_sub_name)
    % Prepare the BIAC filename (get the functional runs for each subject: 4 stroop + 2 memory).
    biacFuncDir = dir(strcat(biac_dir,'/fMRI/Func/',good_sub_name{sub}));
    biacFuncFiles = find(~cellfun(@isempty,regexp({biacFuncDir.name},'bia5_(\d*)_(\d*)_(\d*).nii.gz')));
    for run = 1:6
        biacFuncFile = biacFuncDir(biacFuncFiles(run)).name;
        % Prepare the BIDS filename.
        if run <=4
            task = 'stroop';
            bidsFunc = sprintf('sub-%02d_task-%s_run-%02d_bold.nii.gz', str2double(good_sub_num(sub)),task,run);
            write_bold_josn(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'func'),good_sub_num{sub},task,run); % Write the json file
        elseif run >4
            task = 'mem';
            bidsFunc = sprintf('sub-%02d_task-%s_run-%02d_bold.nii.gz', str2double(good_sub_num(sub)),task,run-4);
            write_bold_josn(fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'func'),good_sub_num{sub},task,run-4); % Write the json file
        end
        % Do the copying and renaming of the file into BIDS folder.
        copyfile(fullfile(biac_dir,'fMRI','Func',good_sub_name{sub},biacFuncFile),fullfile(bids_dir,sprintf('sub-%02d',str2double(good_sub_num{sub})),'func',bidsFunc));
    end
    
end
