
clear all; close all; clc; dbstop if error;
addpath(genpath('/media/tw260/Samsung_T5/fMRI/commands'));

subdirs = {'03','05','06','07','08','09','10','12','13','15','16','17','18','19','20','21',...
    '22','24','25','26','27','28','29','30','31','34','36','37','39','40'};

mvpa_dir = '/media/tw260/Samsung_T5/fMRI/results/mvpa_analysis/stroop';

spm('Defaults','FMRI');

analysisdir = strcat(mvpa_dir,'/SecondLevel/Searchlight_crossvalidation');

try cd(analysisdir)
catch mkdir(fullfile(analysisdir)); cd(analysisdir);
end


%% contrasts of interest

try
    S.outdir = fullfile(analysisdir);
    S.imgfiles{1}={};
    
    j = 1;
    for i = 1:numel(subdirs)
        map_unsmoothed = fullfile(mvpa_dir,subdirs{i},'Searchlight_crossvalidation','res_accuracy_minus_chance.nii');
        spm_smooth(map_unsmoothed,sprintf('%s/%s/Searchlight_crossvalidation/s10FWHM_res_accuracy_minus_chance.nii',mvpa_dir,subdirs{i}),[10,10,10]);
        
        S.imgfiles{1}{j} = fullfile(mvpa_dir,subdirs{i},'Searchlight_crossvalidation','s10FWHM_res_accuracy_minus_chance.nii');
        j = j + 1;
    end
    % connames={SPM.xCon.name};ind=~cellfun(@isempty,regexp(connames,'Step\d')); char(connames(ind))
    % temp=[SPM.xCon(ind).Vcon]; char(temp.fname)
    
    S.contrasts{1}.name = sprintf('%s','res_accuracy_minus_chance');
    S.contrasts{1}.type = 'T';
    S.contrasts{1}.c = 1;
    
    S.contrasts{end+1}.name = sprintf('%s','res_chance_minus_accuracy');
    S.contrasts{end}.type = 'T';
    S.contrasts{end}.c = -1;
    
    S.mask = '/media/tw260/Samsung_T5/fMRI/results/SecondLevel-stroop/SecondLevel_con-vs-inc/mask.nii';
    
    % contrasts   - cell array of contrast structures, with fields c
    %                  (matrix) type ('F' or 'T') and name (optional)
    S.uUFp=0.001;
    if ~exist(fullfile(S.outdir,'mask.nii'),'file');
        batch_spm_anova(S);
    end
catch
end


% return