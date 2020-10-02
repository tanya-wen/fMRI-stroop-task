
function [params]=Marsbar2ndLevelSS(varargin)
% {cons,rois,fout}=Marsbar2ndLevel(P)
% P.cons - cell array of directories containing second level spms
%          or cell array of image volumes
% P.rois - cell array of .mat ROI files
% P.fout - full path to output file 
% P.stat - summary statistic to extract <mean|max|
% Uses marsbar to run 2nd level t-tests for selected ROIs.
% Writes output to Excel spreadsheet.
%
% Danny Mitchell 17/03/08; 23/10/08; 19/11/08
%
% Note: Scaling of beta depends on duration of modelled event, 
% so to compare events of different duration need to account for this...
% To get estimate of signal per event, from MarsBar FAQ:
% "...best estimate of the signal due to the event is the beta values for
% this event multiplied by the regressors in the design matrix. So, to
% reconstruct the height of a single event of this type, we need to
% multiply the betas that we have calculated in the model by a regressor
% which is like the SPM design matrix regressor in scaling, but which is
% just for a single event..."

% SS version allows different ROIs for different subjects (given common naming convention)

dbstop if error

measure='mean';
%measure='eigen1';

addpath(genpath('/home/tw260/Documents/marsbar-0.44'))

%%%%%%%%%%% check inputs
if nargin>1
    cons=varargin{1};
    rois=varargin{2};
else
    try
        if exist(varargin{1}{1},'dir')
            cons=varargin{1};
            rois=[];
        else
            cons=[];
            rois=varargin{1};
        end
    catch, cons=[]; rois=[];
    end
end

oh=spm_figure('FindWin','Interactive');
if ~isempty(oh); delete(oh); end
spm_get_defaults('renderer','painters'); % not sure why needed in spm12?
spm_figure('CreateWin','Interactive',mfilename,'on');
set(gcf,'color',[(str2double(sprintf('%g','d'))-97)/26 ...
                 (str2double(sprintf('%g','j'))-97)/26 ...
                 (str2double(sprintf('%g','m'))-97)/26]);
axis off; txt=feval('help',mfilename); h=text(0,0.5,txt);

% select contrasts
if isempty(cons)
    [cons ok]=spm_select(Inf,'dir','Select directories containing 2nd level SPM.mat files','',pwd);
    if ~ok; return; else cons=cellstr(cons); end
end
%cons is only 1, as all the contrast and subjects are in one model
spm_name = fullfile(cons{1},'SPM.mat');
load(spm_name);
[a b]=spm_str_manip(SPM.xY.P,'E');
subfold=cellstr(strcat(b,a));

% economise contrast path names
cnames=char(cons);
s1=all(repmat(cnames(1,:),[length(cons),1])==cnames);
cnames=cnames(:,find(~s1,1):end);
cnames=cellstr(cnames);
croot=cons{1}(1:find(~s1,1)-1);

% select 1st level SPM file?
[oSPM ok]=spm_select(Inf,'mat','Select a 1st level SPM.mat (if converting beta to signal change)','',[cons{1} '../..']);
if ok
    durs=zeros(1,length(cons));
    for c=1:length(cons)
        [dur ok]=spm_input(sprintf('Duration (s) of event %s',cnames{c}),'+1','r',1);
        if ~ok; oSPM='na'; break; else durs(c)=dur; end
    end
end
% select ROIs
ok=true;
if isempty(rois)
    [rois ok]=spm_select(Inf,'any','Select .nii or Marsbar ROI .mat files','',pwd,'.*(.nii|.mat|.img)$');
end
if ~ok; return; 
else
    rois=cellstr(rois);
      
    for r=1:length(rois)

       if ~isempty(strfind(rois{r},'.mat'))
            % check mat files have correct format...
            temp=load(rois{r});
            if ~isfield(temp,'roi') || ~isfield(temp.roi,'maroi_matrix')
                error('File %s does not seem to be a Marsbar format ROI',rois{r})
            end
       end
        
       % check if it's within a subject folder
       for s=1:length(subfold)
            rois{r}=regexprep(rois{r},subfold{s},'#');
       end
       
    end
end

try fout=varargin{3};
catch 
   guess=[regexprep(cons{1},'/[^/]*/$','/ROIanalysis_') datestr(now,'ddmmyy') '.xls'];
   fout=spm_input('Output file:',1,'s',guess); 
end
 
if exist(fout,'file')
    access = spm_input('File already exists.','+1','bd',{'append','overwrite','cancel'},['a';'w';'x'],1,mfilename);
else access = 'w';
end
if strcmp(access,'x'); return; end

%%%%%%%%%%% do it

if ~isempty(oSPM) 
    fprintf('\nLoading 1st level design: ...')
    try oSPM=load(oSPM); fprintf('done.')
    catch, oSPM=[]; fprintf('failed.')
    end
end

% economise ROI path names
rnames=char(rois);
s1=all(repmat(rnames(1,:),[length(rois),1])==rnames);
rnames=rnames(:,find(~s1,1):end); 
rnames=cellstr(rnames);
rroot=rois{1}(1:find(~s1,1)-1);
unsidedrois=unique(regexprep(rnames,{'_?left','_?right'},{'',''},'ignorecase'));

data=[];
scalefactor=[];
nc=1;
newcnames={};
for c=1:length(cons)
    fprintf('\nLoading 2nd level design: ...%s',cnames{c})
    
    % Make marsbar design object
    spm_name = fullfile(cons{c},'SPM.mat'); 
    load(spm_name)
    D  = mardo(SPM);
    
    try l=SPM.factor.levels;
    catch, l=1;
    end
    
    if ~isempty(oSPM) % rescale if requested
        try 
            scalefactor(nc:(nc+l-1))=regressormax(oSPM.SPM,durs(c)); 
            fprintf('\nScale factor for %gs event = %g\n',durs(c),scalefactor(end))
        catch
            scalefactor(nc:(nc+l-1))=1;
            fprintf('\nFailed to convert betas to signal change. Aborted.\n')
        end
    else
        scalefactor(nc:(nc+l-1))=1;
    end
    
    % get_marsy expects us to be in image directory
    cd(cons{c});

    for r=1:length(rois)
        

        if strcmp('#',rois{r}(1))
            fprintf('Extracting data from per subject ROI ...%s: ',rnames{r})
            % repeat for all single subject ROIs
            for s=1:length(subfold)
                fprintf(' (subject %s) ',subfold{s})
                temproiname=regexprep(rois{r},'#',subfold{s});

                % Make marsbar ROI object
                if ~isempty(strfind(temproiname,'.mat'))
                    R  = maroi(temproiname);
                else
                    V=spm_vol(temproiname);
                    R  = maroi_image(V);
                    [pth nam]=fileparts(temproiname);
                    saveroi(R, fullfile(pth,[nam '_MarsBar_roi.mat'])); % roi suffix needed for marsbar to recognise it!
                end

                try
                    % Fetch data into marsbar data object
                    Y  = get_marsy(R, D, measure);

                    tempdata(nc:(nc+l-1),r,:)=reshape(summary_data(Y),l,[]).*scalefactor(end);
                    data(nc:(nc+l-1),r,s)=tempdata(nc:(nc+l-1),r,s);
                catch
                    fprintf(' WARNING: data may not exist in ROI. ')
                    data(nc:(nc+l-1),r,s)=NaN;
                end
                
            end % next subject
        else
            fprintf('Extracting data from common ROI ...%s: ',rnames{r})
            % Make marsbar ROI object
            if ~isempty(strfind(rois{r},'.mat'))
                R  = maroi(rois{r});
            else
                V=spm_vol(rois{r});
                R  = maroi_image(V);
                [pth nam]=fileparts(rois{r});
                saveroi(R, fullfile(pth,[nam '_MarsBar_roi.mat'])); % roi suffix needed for marsbar to recognise it!
            end

            % Fetch data into marsbar data object
            Y  = get_marsy(R, D, measure);

            data(nc:(nc+l-1),r,:)=reshape(summary_data(Y),1,[]).*scalefactor(end);
        end

    end; % next roi

    for el=1:l
        newcnames=[newcnames; sprintf('%s.%g',cnames{c},el)];
    end
    nc=nc+l;
end; % next contrast
save(regexprep(fout,'.xls','.mat'),'data','rois','cons');
%% plot bar graph
% [nrows ncols positions]=fitplots(length(newcnames));
% figure(99)
% clear opts; opts.style='bars';
% for c=1:length(newcnames)
%     subplot('position',positions{c})
%     PlotWithErrors(permute(data(c,:,:),[3 2 1]),{'ROIs',['Beta: ' newcnames{c}],rnames{:}},opts)
% end

% print to spreadsheet
fprintf('\nSaving data to %s...',fout)
fid=fopen(fout,access);

fprintf(fid,'Following data added: %s \n',date);
fprintf(fid,'Contrasts: %s* \n',croot);
fprintf(fid,'ROIs: %s* \n',rroot);
fprintf(fid,'\nConstrast \t Regressor height (multiplied by beta) \t ROI \t');
for s=1:size(data,3)
    fprintf(fid,'Subject_ %i\t',s);
end
fprintf(fid,'Mean \t t \t p(0.05,2-tailed) \t +/-CI.05 \t\n');
for r=1:length(rois)
    for c=1:length(newcnames)
        fprintf(fid,'%s\t %g \t %s\t',newcnames{c},scalefactor(c),rnames{r});
        for s=1:size(data,3)
            fprintf(fid,'%f\t',data(c,r,s));
        end
        M=mean(data,3);
        [H,P,CI,STATS]=ttest(data(c,r,:),0,0.05,'both');
        fprintf(fid,'%f \t %f \t %f \t %f \t\n',M(c,r),STATS.tstat,P,(CI(1,1,2)-CI(1,1,1))/2);
    end;
end;

% and again in format more suitable for SPSS GLM
% key:
fprintf(fid,'\n\n Reformated for SPSS:');
for c=1:length(newcnames); fprintf(fid,'\nc%g=%s',c,newcnames{c}); end
for r=1:length(unsidedrois); fprintf(fid,'\nr%g=%s',r,unsidedrois{r}); end
fprintf(fid,'\nl=left\nr=right\nb=bilateral\n');
% column headings:
fprintf(fid,'\nsubject');
for r=1:length(rois)
    unsidedroi=regexprep(rnames{r},{'_?left','_?right'},{'',''},'ignorecase');
    ur=strmatch(unsidedroi,unsidedrois);
    if ~isempty(regexp(rnames{r},'left','ONCE')); s='l';
    elseif ~isempty(regexp(rnames{r},'right','ONCE')); s='r';
    else s='b';
    end
    for c=1:length(newcnames)
        fprintf(fid,'\tc%g_r%g_%s',c,ur,s);
    end
end
% data:
for s=1:size(data,3)
    fprintf(fid,'\n%s',regexprep(SPM.xY.VY(s).fname,'.*/(CBU\d*)/.*','$1'));
    for r=1:length(rois)
        for c=1:length(newcnames)
            fprintf(fid,'\t%f',data(c,r,s));
        end
    end
end
fclose(fid);
fprintf('Done.\n')

params={cons, rois, fout};

rmpath(genpath('/home/tw260/Documents/marsbar-0.44'))
% try
%     spm_defaults
% catch
% end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scalefactor=regressormax(SPM,dur)
% see Marsbar's event_regressor.m event_fitted.m event_signal.m
% pr_ev_diff.m
%
% Here assume single canonical HRF basis function, and use max as
% scalefactor

dt = SPM.xBF.dt;
try   bf = SPM.xBF.bf;
catch, bf = SPM.xBF.Sess(1).Cond(1).xBF.bf;
end

if ~dur  
  % SPM2 does a second's worth of spike for events without durations
  sf = 1/dt; 
else
  sf = ones(round(dur/dt), 1);
end
reg=conv(sf, bf);

scalefactor=max(reg(:));

return