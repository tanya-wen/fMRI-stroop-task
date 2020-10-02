%write behavioral data into .tsv file

clear all; clc; dbstop if error;
%% convert Duke BIAC output to BIDS format
biac_dir = '/media/tw260/Samsung_T5/fMRI/decodCC.01';
bids_dir = '/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS';

sub_list = readtable(strcat(biac_dir,'/Subject_Log.xlsx'));
good_sub_ind = find(cellfun(@isempty,regexp(sub_list.status,'obs')) & ~cellfun(@isempty,regexp(sub_list.examId,'2018')));
good_sub_num = string(regexp(sub_list.number(good_sub_ind),'(\d*)','tokens'));
good_sub_name = sub_list.examId(good_sub_ind);


%% write behavioral data
for sub = 1:numel(good_sub_name)
    for run = 1:6
        if run <=4
            task = 'stroop';
            data_orig = readtable(fullfile(biac_dir,'Behavioral',sprintf('S%d',str2double(good_sub_num{sub})),sprintf('stroop_S%d_r%d.csv',str2double(good_sub_num{sub}),run)));
            fid = fopen(sprintf('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/sub-%02d/func/task-stroop_run-%02d_events.csv',str2double(good_sub_num{sub}),run),'w');
            fprintf(fid,'onset,duration,weight,trial_type\n');
            if ~any(data_orig.sbjACC==0)
                fprintf(fid,'%.2f,%.2f,%d,%s\n',0,0,0,'error');
            end
            for trial = 1:size(data_orig,1)
                onset = data_orig.actualOnset(trial);
                if isnan(data_orig.sbjRT(trial))
                    duration = data_orig.ITIduration(trial)/1000;
                    acc = 'incorrect';
                else
                    duration = data_orig.sbjRT(trial)/1000;
                    if data_orig.sbjACC(trial) == 1
                        acc = 'correct';
                    else
                        acc = 'incorrect';
                    end
                end
                weight = 1;
                if isequal(acc,'incorrect')
                    trialtype{trial} = 'error';
                else
                    trialtype{trial} = data_orig.trialType{trial};
                end
                fprintf(fid,'%.2f,%.2f,%d,%s\n',onset,duration,weight,trialtype{trial});
            end
        elseif run >4
            task = 'mem';
            data_orig = readtable(fullfile(biac_dir,'Behavioral','gp_memory_fMRI_v1_wlabel.csv'));
            subjtask_ind = find(data_orig.sbjId==str2double(good_sub_num(sub)))';
            fid = fopen(sprintf('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/sub-%02d/func/task-mem_run-%02d_events.csv',str2double(good_sub_num{sub}),run-4),'w');
            fprintf(fid,'onset,duration,weight,trial_type\n');
            for trial = subjtask_ind
                onset = data_orig.actualOnset(trial);
                if isnan(data_orig.sbjRT(trial))
                    duration = 2.2;
                else
                    duration = data_orig.sbjRT(trial)/1000;
                end
                weight = 1;
                if isequal(data_orig.blockType{trial},'new')
                    if contains(data_orig.sbjResp{trial},'New')
                        acc = 'correct';
                        trialtype{trial} = 'new-correct';
                    elseif contains(data_orig.sbjResp{trial},'Old')
                        acc = 'incorrect';
                        trialtype{trial} = 'new-incorrect';
                    else acc = 'NoResponse';
                        trialtype{trial} = acc;
                    end
                elseif isequal(data_orig.blockType{trial},'easy') || isequal(data_orig.blockType{trial},'hard')
                    if contains(data_orig.sbjResp{trial},'Old')
                        acc = 'correct';
                        trialtype{trial} = strcat(data_orig.trialType{trial},'-',acc);
                    elseif contains(data_orig.sbjResp{trial},'New')
                        acc = 'incorrect';
                        trialtype{trial} = strcat(data_orig.trialType{trial},'-',acc);
                    else acc = 'NoResponse';
                        trialtype{trial} = acc;
                    end
                end
                fprintf(fid,'%.2f,%.2f,%d,%s\n',onset,duration,weight,trialtype{trial});
            end
            
            all_cond_names = {'con-correct','inc-correct','con-incorrect','inc-incorrect','new-correct','new-incorrect','NoResponse'};
            missing_regressors = setdiff(all_cond_names,trialtype(subjtask_ind));
            if ~isempty(missing_regressors)
                for i = 1:numel(missing_regressors)
                    fprintf(fid,'%.2f,%.2f,%d,%s\n',0,0,0,missing_regressors{i});
                end
            end
        end
        
    end
end
