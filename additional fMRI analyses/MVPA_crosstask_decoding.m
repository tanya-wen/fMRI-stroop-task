
% This example runs a decoding analysis on the example data that can
% be downloaded from the TDT webpage. It performs various ROI decodings
% between up and down motion.


clear all
addpath(genpath('/home/tw260/Documents/tdt_3.999/decoding_toolbox')); 
dbstop if error % in case something goes wrong

fpath = fileparts(fileparts(mfilename('fullpath')));
addpath(fpath)

%% Check that SPM and TDT are available on the path
if isempty(which('SPM')), error('Please add SPM to the path and restart'), end
if isempty(which('decoding_defaults')), error('Please add TDT to the path and restart'), end

%% Locate data directory
subdirs = {'03','05','06','07','08','09','10','12','13','15','16','17','18','19','20','21',...
    '22','24','25','26','27','28','29','30','31','34','36','37','39','40'};

train_databasedir = '/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l1output-stroop';
for sub = 1:length(subdirs)
    d = fullfile(train_databasedir, subdirs{sub});
    if exist(d, 'dir')
        train_beta_loc{sub} = strcat(d,'/model',sprintf('/_subject_id_%s',subdirs{sub}),'/_fwhm_0');
    end
end
if ~exist('train_beta_loc','var')
    train_beta_loc = uigetdir('', 'Select the sub01_GLM* directory from the demo data (inside sub01_firstlevel*)');
end
dispv(1, 'Located data in %s, starting analysis', train_beta_loc{1});

test_databasedir = '/media/tw260/Samsung_T5/fMRI/decodCC.01_BIDS/l1output-mem';
for sub = 1:length(subdirs)
    d = fullfile(test_databasedir, subdirs{sub});
    if exist(d, 'dir')
        test_beta_loc{sub} = strcat(d,'/model',sprintf('/_subject_id_%s',subdirs{sub}),'/_fwhm_0');
    end
end
if ~exist('test_beta_loc','var')
    test_beta_loc = uigetdir('', 'Select the sub01_GLM* directory from the demo data (inside sub01_firstlevel*)');
end
dispv(1, 'Located data in %s, starting analysis', test_beta_loc{1});

%% General settings

cfg = decoding_defaults; % add all important directories to the path, and set defaults
cfg.analysis = 'searchlight'; % 'searchlight', 'wholebrain', 'ROI' (if ROI, set one or multiple ROI images as mask files below instead of the mask)
cfg.decoding.method='classification';
cfg.design.function.name='make_design_xclass';
% cfg.cv='cvNfold'; % not a TDT field! Will be used to set up cross-validation scheme below
cfg.scale.method='z'; cfg.scale.estimation='all';
cfg.feature_transformation.n_vox='';
cfg.results.overwrite = 1;
cfg.results.setwise=1;
cfg.results.write=1; % the meaning of this changes across versions!! Write nothing, .mat files only, or .mat files and .nii files
cfg.fighandles.plot_design = 10;
cfg.plot_selected_voxels = 0;
cfg.verbose = 1;

%% Set ROIs
try
    if strcmp(cfg.analysis,'roi')==1
    cfg.files.mask = fullfile('/media/tw260/Samsung_T5/fMRI/MD rois', {'rL_AI.nii','rL_aMFG.nii','rL_ESV.nii','rL_FEF.nii','rL_IPS.nii','rL_mMFG.nii','rL_pMFG.nii','rL_preSMA.nii','rR_AI.nii','rR_aMFG.nii','rR_ESV.nii','rR_FEF.nii','rR_IPS.nii','rR_mMFG.nii','rR_pMFG.nii','rR_preSMA.nii','rMDnetwork.nii'}); % reduce data
    elseif strcmp(cfg.analysis,'searchlight')==1
        cfg.files.mask = fullfile('/media/tw260/Samsung_T5/fMRI/results/SecondLevel/SecondLevel_inc-vs-con/spmT_0002.nii');
    end
catch
    cfg.files.mask = uigetfile('', 'Could not automatically find ROI folder, please select which ROIs to use');
end


nruns_stroop = 4;
stroop={'easy-con','easy-inc','hard-con','hard-inc'};
nruns_mem = 2;
mem={'easy-con-correct','easy-inc-correct','hard-con-correct','hard-inc-correct'};
for sub = 1:length(subdirs)
    
%     make_design_xclass(cfg)

    regressor_names = design_from_spm(train_beta_loc{sub});
    train_dat = decoding_describe_data(cfg,stroop,[-1 1 -1 1],regressor_names,train_beta_loc{sub});
    
    regressor_names = design_from_spm(test_beta_loc{sub});
    test_dat = decoding_describe_data(cfg,mem,[-1 1 -1 1],regressor_names,test_beta_loc{sub});

    
    cfg.files.name = [train_dat.files.name;test_dat.files.name];
    cfg.files.chunk = [ones(numel(stroop)*nruns_stroop,1); 2*ones(numel(mem)*nruns_mem,1)];
    cfg.files.label = [kron([-1 1 -1 1],ones(1,4)),kron([-1 1 -1 1],ones(1,2))]';
    cfg.files.set = [];
    cfg.files.xclass = cfg.files.chunk;
    
    
    runs=cfg.files.chunk;
    
    cfg.results.output = {'accuracy_minus_chance'};
    
    % plot_design(cfg);
    % display_design(cfg);
    
    %% analyses
    
    figure(100); clf(100);

    % Settings for this analysis:
    % name=sprintf('%s_scale%s_trans%s%s',...
    %     cfg.decoding.software,cfg.scale.method,...
    %     cfg.feature_transformation.method,num2str(cfg.feature_transformation.n_vox));
    
    if strcmp(cfg.analysis,'roi')==1
        cfg.results.dir = fullfile('/media/tw260/Samsung_T5/fMRI/results/mvpa_analysis', 'crosstask', subdirs{sub},'ROI_crosstask');
    elseif strcmp(cfg.analysis,'searchlight')==1
        cfg.results.dir = fullfile('/media/tw260/Samsung_T5/fMRI/results/mvpa_analysis', 'crosstask', subdirs{sub},'Searchlight_crosstask');
    end
    
   
    
    % run main cv decoding:
    results = decoding(cfg);
    
    
    %% rerun with label permutations:
    if exist('IHaveALotOfTime');
        
        permcfg=cfg;
        if isfield(permcfg,'design'), permcfg=rmfield(permcfg,'design');
        end
        if isfield(permcfg.results,'resultsname'), permcfg.results = rmfield(permcfg.results, 'resultsname');
        end
        permcfg.results.filestart = 'perm';
        permcfg.design.function.name=cfg.design.function.name;
        [results_perm, final_cfg_perm] = decoding(permcfg);
        
        % plot
        figure(100)
        colors=[0 1 .5; 0 .75 .75; 0 .5 1; 0 0 0];
        perms=[results_perm.accuracy_minus_chance.set.output];
        for roi=1:results.n_decodings
            barh(roi,results.accuracy_minus_chance.output(roi),'facecolor',colors(roi,:)); hold on
            plot(prctile(perms(roi,:),[0 95],2),[roi roi],'r-')
        end
        axis tight on; box off; xlim([-50 50])
        [j, s]=spm_str_manip(cfg.files.mask,'C');
        set(gca,'ytick',1:4,'yticklabel',s.m,'xtick',[]);
        
        subplot('position',pos{a,1});
        axis off
        text(mean(xlim),mean(ylim),name,'interpreter','none')
        drawnow
    end
end

% return