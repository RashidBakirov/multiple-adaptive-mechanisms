
function runClassificationCluster_batch_weka(datasetIdentifier, batchSize)

%RUNEXPERIMENTFORJOURNAL run experiment for journal paper
%   Detailed explanation goes here

warning ('off','all');
load classificationdata;

% feature('numCores');
% c = parcluster
% c.NumWorkers

datasetIdentifier=str2double(datasetIdentifier);
batchSize=str2double(batchSize);

data_train=alldata{datasetIdentifier}{1};
labels_train=alldata{datasetIdentifier}{2};
data_test=alldata{datasetIdentifier}{3};
labels_test=alldata{datasetIdentifier}{4};

%options='-L 0';
options='';

for j=0:1
    %parfor i=0:10
    for i=1:11                                                                                                               
        [acc{i+1}{j+1}, avg_acc{i+1}{j+1}, result{i+1}{j+1}, preds{i+1}{j+1}, avg_acc_test{i+1}{j+1}, pred_test{i+1}{j+1}] = dwm_ams_batch_weka(data_train, labels_train, 'trees.HoeffdingTree',options, i, j, batchSize ,data_test,labels_test);
        save ([num2str(datasetIdentifier) '_DWMAMS_ClassificationResults_batch_weka' num2str(batchSize) '.mat']);
    end
end



exit;