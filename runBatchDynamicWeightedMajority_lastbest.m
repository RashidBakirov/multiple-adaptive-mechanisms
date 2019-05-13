
function runBatchDynamicWeightedMajority_lastbest(datasetIdentifier, batchSize)

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

data=alldata{datasetIdentifier}{1};
labels=alldata{datasetIdentifier}{2};
test_data=alldata{datasetIdentifier}{3};
test_labels=alldata{datasetIdentifier}{4};

avg_acc = zeros(1,100);
avg_acc_test = zeros(1,100);
acc = cell(1,100);
ams = cell(1,100);

for i=1:100
    disp(['Run: ' num2str(i)]);
    [acc{i}, avg_acc(i) , ~, ~, avg_acc_test(i), ~, ams{i}] = dwm_ams_batch_lastbest(data, labels, naivebc_rb, batchSize, test_data, test_labels);
    save (['results/oco/DWMAMS_lb_' num2str(datasetIdentifier) '_' num2str(batchSize) '.mat'], 'acc', 'avg_acc', 'avg_acc_test', 'ams');
end

exit;