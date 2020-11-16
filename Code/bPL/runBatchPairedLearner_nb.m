
function runBatchPairedLearner(datasetIdentifier, batchsize, threshold)

%run bPL experiments (Consult bPL.sh to see which
%parameters were used for different datasets)
%arguments:
%batchSize - size of the batch
%threshold - threshold for Paired Learner algorithm
%datasetIdentifier - identifier of the dataset.

addpath(genpath('/Code'));
warning ('off','all');
load 'data/classificationdata.mat';

% feature('numCores');
% c = parcluster
% c.NumWorkers

datasetIdentifier=str2double(datasetIdentifier);
batchsize=str2double(batchsize);
threshold=str2double(threshold);

data_train=alldata{datasetIdentifier}{1};
labels_train=alldata{datasetIdentifier}{2};
data_test=alldata{datasetIdentifier}{3};
labels_test=alldata{datasetIdentifier}{4};

for j=0:1
    %parfor i=0:10
    for i=1:5
        [result{i}{j+1}, preds{i}{j+1},~, pred_test{i}{j+1}, avg_result{i}{j+1}, ~, ~, avg_acc{i}{j+1}, avg_acc_test{i}{j+1}] = paired_class_ams_batch3(data_train, labels_train, threshold, naivebc_rb, i, j, batchsize, data_test,labels_test);
    end
end

save (['results/' num2str(datasetIdentifier) '_PairedLearnerResultsBatch_' num2str(batchsize) '_' num2str(threshold) '.mat']);

exit;