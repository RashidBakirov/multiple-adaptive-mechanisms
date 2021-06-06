
function runBatchDynamicWeightedMajority_nb_runtime(alldata,datasetIdentifier)

%run bDWM experiments (Consult bDWM.sh to see which
%parameters were used for different datasets)
%arguments:
%batchSize - size of the batch
%datasetIdentifier - identifier of the dataset.

%addpath(genpath('/Code'));
warning ('off','all');
%load 'data/classificationdata.mat';

% feature('numCores');
c = parcluster;
c.NumWorkers

data_train=alldata{datasetIdentifier}{1};
labels_train=alldata{datasetIdentifier}{2};
data_test=alldata{datasetIdentifier}{3};
labels_test=alldata{datasetIdentifier}{4};

time_50_2=cell(2,1,10);
time_50_5=cell(2,1,10);
time_50_10=cell(2,10,10);


for j=0:1
    time_50_2_c=cell(1,10);
    time_50_5_c=cell(1,10);
    time_50_10_c=cell(1,10);
    parfor cnt=1:10
        disp(j);
        disp(cnt);
        [~, ~, ~, ~, ~, ~,~, time_50_2_c{cnt}] = dwm_ams_batch(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
        [~, ~, ~, ~, ~, ~,~, time_50_5_c{cnt}] = dwm_ams_batch(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 5);
        [~, ~, ~, ~, ~, ~,~, time_50_10_c{cnt}] = dwm_ams_batch(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 10);
    end
    time_50_2{j+1,10}=time_50_2_c;
    time_50_5{j+1,10}=time_50_5_c;
    time_50_10{j+1,10}=time_50_10_c;
end

save ('DWMAMS_ClassificationResults_runtimes_full.mat');

disp('50_10')
for i=1:9
    for j=0:1
        time_50_10_c=cell(1,10);
        parfor cnt=1:10
            disp(i);
            disp(j);
            disp(cnt);
            [~, ~, ~, ~, ~, ~,~, time_50_10_c{cnt}] = dwm_ams_batch(data_train, labels_train, naivebc_rb, i, j, 50,data_test,labels_test, 2);
        end
        time_50_10{j+1,i}=time_50_10_c;
    end
end

save ('DWMAMS_ClassificationResults_runtimes_full.mat');



%exit;