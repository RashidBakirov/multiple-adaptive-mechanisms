
function runPairedLearnerClusterBatch_weka(datasetIdentifier, batchsize, threshold, classifier)

%RUNEXPERIMENTFORJOURNAL run experiment for journal paper
%   Detailed explanation goes here

warning ('off','all');
load '~/rashid/mam/data/classificationdata';

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

options='';

diary (['~/rashid/mam/results/bpl/' num2str(datasetIdentifier) '_PairedLearnerResultsBatch_weka_' classifier '_' num2str(batchsize) '_' num2str(threshold) '.log']);

for j=0:1
    %parfor i=0:10
    for i=0:5
        [result{i+1}{j+1}, preds{i+1}{j+1},~, pred_test{i+1}{j+1}, avg_result{i+1}{j+1}, ~, ~, avg_acc{i+1}{j+1}, avg_acc_test{i+1}{j+1}] = paired_class_ams_batch4_weka(data_train, labels_train, threshold, classifier,options, i, j, batchsize, data_test,labels_test,datasetIdentifier);
        save (['~/rashid/mam/results/bpl/' num2str(datasetIdentifier) '_PairedLearnerResultsBatch_weka_' classifier '_' num2str(batchsize) '_' num2str(threshold) '.mat']);
    end
end

%save ([num2str(datasetIdentifier) '_PairedLearnerResultsBatch_weka_' classifier '_' num2str(batchsize) '_' num2str(threshold) '.mat']);

diary off;

exit;
