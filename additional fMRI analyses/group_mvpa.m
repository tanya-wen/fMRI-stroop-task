

results_dir = '/media/tw260/Samsung_T5/fMRI/results/mvpa_analysis';
subs = {'03','05','06','07','08','09','10','12','13','15','16','17','18','19','20','21',...
    '22','24','25','26','27','28','29','30','31','34','36','37','39','40','41'};

for roi = 1:7
    
    for i = 1:length(subs)
        
        decoding_file = load(sprintf('/media/tw260/Samsung_T5/fMRI/results/mvpa_analysis/%s/ROI_crossvalidation/res_accuracy_minus_chance.mat',subs{i}));
        sub_decoding(i,roi) = decoding_file.results.accuracy_minus_chance.output(roi);
        
    end
end

figure; hold on
bar_input = mean(sub_decoding,1);
errorbar_input = std(sub_decoding)/sqrt(length(subs));
bar(bar_input);
errorbar(bar_input,errorbar_input,'.');
roinames = {'AI','aMFG','FEF','IPS','mMFG','pMFG','preSMA'};
set(gca,'XTick',1:7,'XTickLabel',roinames);