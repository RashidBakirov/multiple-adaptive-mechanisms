
function runBatchPairedLearner_nb_runtime(alldata,datasetIdentifier)

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




for j=0:1
    time_50_2_c=cell(1,10);
    time_50_5_c=cell(1,10);
    time_50_10_c=cell(1,10);
    parfor cnt=1:10
        disp(j);
        disp(cnt);
        tic
        paired_class_ams_batch4(data_train, labels_train, 0, naivebc_rb, 4, j,  50, data_test, labels_test, 2,[]);
        time_50_2_c{cnt}=toc;
        tic
        paired_class_ams_batch4(data_train, labels_train, 0, naivebc_rb, 4, j,  50, data_test, labels_test, 5,[]);
        time_50_5_c{cnt}=toc;
        tic
        paired_class_ams_batch4(data_train, labels_train, 0, naivebc_rb, 4, j,  50, data_test, labels_test, 10,[]);
        time_50_10_c{cnt}=toc;
    end
    times{5+7*j}=time_50_2_c;
    times{6+7*j}=time_50_5_c;
    times{7+7*j}=time_50_10_c;
end

save ('BPL_ClassificationResults_runtimes_full.mat', 'times');

disp('50_10')
for i=0:3
    for j=0:1
        time_50_10_c=cell(1,10);
        parfor cnt=1:10
            disp(i);
            disp(j);
            disp(cnt);
            tic
            paired_class_ams_batch4(data_train, labels_train, 0, naivebc_rb, i, j,  50, data_test, labels_test, 10,[]);
            time_50_10_c{cnt}=toc;
        end
        times{i+1+7*j}=time_50_10_c;
    end
end

save ('BPL_ClassificationResults_runtimes_full.mat','times');



%exit;