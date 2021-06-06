
function runBatchDynamicWeightedMajority_nb_runtime_lite(alldata,datasetIdentifier)

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

%parpool


%     for j=0:1
%         for cnt=1:10
%             disp(j);
%             disp(cnt);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l{j+1,cnt}] = dwm_ams_batch_lite(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l2{j+1,cnt}] = dwm_ams_batch_lite2(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l_xvp{j+1,cnt}] = dwm_ams_batch_lite_xvpar(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l2_xvp{j+1,cnt}] = dwm_ams_batch_lite2_xvpar(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l_fp{j+1,cnt}] = dwm_ams_batch_lite_fullpar(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%             [~, ~, ~, ~, ~, ~,~, time_50_2_l2_fp{j+1,cnt}] = dwm_ams_batch_lite2_fullpar(data_train, labels_train, naivebc_rb, 10, j, 50,data_test,labels_test, 2);
%   
%         end
%     end

    parfor cnt=1:10
        disp(j);
        disp(cnt);
        [~, ~, ~, ~, ~, ~,~, time_50_2_l_custom{cnt}] = dwm_ams_batch_lite(data_train, labels_train, naivebc_rb, 9, 0, 50,data_test,labels_test, 2);
        [~, ~, ~, ~, ~, ~,~, time_50_2_l2_custom{cnt}] = dwm_ams_batch_lite2(data_train, labels_train, naivebc_rb, 9, 0, 50,data_test,labels_test, 2);
    end

save ('DWMAMS_ClassificationResults_runtimes_lite_custom.mat');



%exit;