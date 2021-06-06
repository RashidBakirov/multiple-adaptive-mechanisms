
function runBatchDynamicWeightedMajority_single_ht(datasetIdentifier, i, j, batchSize, classifier)

%RUNEXPERIMENTFORJOURNAL run experiment for journal paper
%   Detailed explanation goes here

warning ('off','all');
load '~/rashid/mam/data/classificationdata';

% feature('numCores');
% c = parcluster
% c.NumWorkers

datasetIdentifier=str2double(datasetIdentifier);
batchSize=str2double(batchSize);
i=str2double(i);
j=str2double(j);


data_train=alldata{datasetIdentifier}{1};
labels_train=alldata{datasetIdentifier}{2};
data_test=alldata{datasetIdentifier}{3};
labels_test=alldata{datasetIdentifier}{4};

%options='-L 0';
options='';

diary (['~/rashid/mam/results/bdwm/' num2str(datasetIdentifier) '_DWMAMS_ClassificationResults_batch_weka' num2str(batchSize) ' ' num2str(i) ' ' num2str(j) '.log']);

                                                                                                        
[~, avg_acc, ~, preds, avg_acc_test, pred_test] = dwm_ams_batch_weka(data_train, labels_train, classifier,options, i, j, batchSize ,data_test,labels_test,datasetIdentifier);

save(['~/rashid/mam/results/bdwm/' num2str(datasetIdentifier) 'ACC_DWMAMS_ClassificationResults_batch_weka' num2str(batchSize) ' ' num2str(i) ' ' num2str(j) '.mat'],'avg_acc','avg_acc_test')
save (['~/rashid/mam/results/bdwm/' num2str(datasetIdentifier) '_DWMAMS_ClassificationResults_batch_weka' num2str(batchSize) ' ' num2str(i) ' ' num2str(j) '.mat']);

diary off;

exit;