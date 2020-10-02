close all; clear all;

% load data
clear all; close all; clc

load(sprintf('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l2output-stroop/level2/SecondLevel.mat'));
% economise ROI names
rnames=char(rois);
s1=all(repmat(rnames(1,:),[length(rois),1])==rnames);
rnames=rnames(:,find(~s1,1):end);

rnames=cellstr(rnames);
rroot=rois{1}(1:find(~s1,1)-1);
roinames=unique(regexprep(rnames,{'_?left','_?right'},{'',''},'ignorecase'));
roinames=strrep(roinames,'.nii','');

% get the empty conditions
load('/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l2output-stroop/level2/_con_1_fwhm_10/level2conestimate/SPM.mat');
subs = SPM.xY.P;

goodsubjects = 1:numel(subs);


addpath(genpath('/media/tw260/Samsung_T5/fMRI/software/errorbar_groups'));

nROIs = 1:size(data,2);

for ROIs = nROIs
    
    for cond = 1:2
        activation(cond, ROIs) = mean(data(cond,ROIs,goodsubjects));
        stderror(cond,ROIs) = std(mean(data(cond,:,goodsubjects)))/sqrt(numel(goodsubjects)-1);
    end

    
    
    figure;

    bar_input = activation(:,ROIs);
    errorbar_input = stderror(:,ROIs);
    bar(bar_input); hold on
    errorbar(bar_input,errorbar_input,'k.');
    title(roinames{ROIs});

    set(gcf,'color','w');
    ylabel('beta estimates');
    set(gcf,'color','w');
    set(gcf,'position',[1,1,600,300])
    set(gca,'box','off')
    
    xticklabels({'con','inc'})
%     print(gcf,sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s_%s.eps','00019',network,roinames{ROIs}),'-depsc2','-painters');
  
end
% saveas(gcf,sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s.png','00019',network));
% print(sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s.eps','00019',network),'-depsc2','-painters');
% 

