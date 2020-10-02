clear all; close all; dbstop if error;

addpath('/media/tw260/Samsung_T5/fMRI/commands');
addpath('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS');

l1dir = '/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l1output-mem';

folders = dir(l1dir);
folders(ismember({folders.name},{'.','..'})) = [];
nsubs = numel([folders.isdir]);

spm('Defaults','FMRI');

analysisdir = '/media/tw260/Samsung_T5/fMRI/results/SecondLevel';
try cd(analysisdir)
catch eval(sprintf('!mkdir %s',analysisdir)); cd(analysisdir);
end


%% contrasts of interest
load('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/workingdir-mem/level1/_subject_id_03/_fwhm_10/contrastestimate/SPM.mat')
for c = 1:numel({SPM.xCon.name})
    try
    S.outdir = fullfile(analysisdir,sprintf('SecondLevel_%s',SPM.xCon(c).name));
    S.imgfiles{1}={};
    
    j = 1;
    for i = 1:nsubs
        subdir = fullfile(l1dir,folders(i).name,'contrasts',sprintf('_subject_id_%s',folders(i).name),'_fwhm_10');
        fcons = spm_select('FPListRec',subdir,'con_.*\.nii');
        con_ind(c) = find(ismember(cellstr(spm_select('List',subdir,'con_.*\.nii')),sprintf('con_%04d.nii',c)));
        S.imgfiles{1}{j} = fcons(con_ind(c),:);
        j = j + 1;
    end
    % connames={SPM.xCon.name};ind=~cellfun(@isempty,regexp(connames,'Step\d')); char(connames(ind))
    % temp=[SPM.xCon(ind).Vcon]; char(temp.fname)
    
    S.contrasts{1}.name = sprintf('%s',SPM.xCon(c).name);
    S.contrasts{1}.type = 'T';
    S.contrasts{1}.c = 1;
    
    % contrasts   - cell array of contrast structures, with fields c
    %                  (matrix) type ('F' or 'T') and name (optional)
    S.uUFp=0.001;
    if ~exist(fullfile(S.outdir,'mask.nii'),'file');
        batch_spm_anova(S);
    end
    catch
    end
end

% return