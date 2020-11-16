
function runBatchDynamicWeightedMajority(datasetIdentifier, batchSize)

%run bDWM experiments (Consult bDWM.sh to see which
%parameters were used for different datasets)
%arguments:
%batchSize - size of the batch
%datasetIdentifier - identifier of the dataset.

addpath(genpath('/Code'));
warning ('off','all');
load 'data/classificationdata.mat';

% feature('numCores');
% c = parcluster
% c.NumWorkers

datasetIdentifier=str2double(datasetIdentifier);
batchSize=str2double(batchSize);

data_train=alldata{datasetIdentifier}{1};
labels_train=alldata{datasetIdentifier}{2};
data_test=alldata{datasetIdentifier}{3};
labels_test=alldata{datasetIdentifier}{4};

for j=0:1
    %parfor i=0:10
    for i=0:11                                                                                                               
        [acc{i+1}{j+1}, avg_acc{i+1}{j+1}, result{i+1}{j+1}, preds{i+1}{j+1}, avg_acc_test{i+1}{j+1}, pred_test{i+1}{j+1}] = dwm_ams_batch(data_train, labels_train, naivebc_rb, i, j, batchSize ,data_test,labels_test);
    end
end

save (['../results/' num2str(datasetIdentifier) '_DWMAMS_ClassificationResults_batch' num2str(batchSize) '.mat']);

exit;