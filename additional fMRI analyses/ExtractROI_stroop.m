clear all; close all; clc

for con_ind = 1:4
    con_dir = sprintf('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l2output-stroop/level2/_con_%d_fwhm_0/level2conestimate',con_ind);
    cons{con_ind} = con_dir;
end

rois = {'/media/tw260/Samsung_T5/fMRI/MD rois/AI.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/aMFG.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/preSMA.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/FEF.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/IPS.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/mMFG.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/pMFG.nii',...
    '/media/tw260/Samsung_T5/fMRI/MD rois/ESV.nii'};

Marsbar2ndLevelSS(cons,rois)