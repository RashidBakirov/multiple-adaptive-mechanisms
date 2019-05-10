
function runBatchDynamicWeightedMajority_ogd(datasetIdentifier, batchSize, learn_rate)

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

avg_acc(i) = zeros(1,100);
avg_acc_test(i) = zeros(1,100);
acc = cell(1,100);
ams = cell(1,100);

for i=1:100
    [acc{i}, avg_acc(i) , ~, ~, avg_acc_test(i), ~, ams{i}] = dwm_ams_batch_ogd(data, labels, classifier, batchsize, test_data, test_labels, learn_rate);
end

save (['results/' num2str(datasetIdentifier) '_DWMAMS_ClassificationResults_batch' num2str(batchSize) '.mat']);

exit;