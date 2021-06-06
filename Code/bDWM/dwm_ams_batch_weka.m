function[acc, avg_acc , result, preds, avg_acc_test, pred_test, ams] = dwm_ams_batch_weka(data, labels, classifier, options, strategy, flag_rc,  batchsize, test_data, test_labels, dataset_id)
tic
% dynamic weighted majority with multiple ams
% strategy to select AM
% 1:8 - respective AM only
% 9 - original dwm
% 10 - xval
% 11 - optimal

NUMFOLDS = 10 %xval folds
numlabels = length(unique(labels));
 
[rows cols]=size(data);

classifier_id=classifier; 
% classifier short id for logging
if strcmp(classifier,'bayes.NaiveBayes')
    classifier_id='NB';
elseif strcmp(classifier,'trees.HoeffdingTree')
    classifier_id='HT';
end

% dataset id id for logging
if isempty(dataset_id)
    dataset_id=0;
end


%first convert everything to weka instances
w_data_train = matlab2weka('w_data_train', [], [data labels]);
w_data_train = wekaNumericToNominal( w_data_train, 'last');

if ~isempty(test_data)
    w_data_test = matlab2weka('w_data_test', [], [test_data test_labels]);
    w_data_test = wekaNumericToNominal( w_data_test, 'last');
end

ds1=weka.core.Instances(w_data_train,0,batchsize); %create the first datapoint

%cl = trainWekaClassifier(w_data,classifier,'-L 0 -G 20');
cl = trainWekaClassifier(ds1,classifier,options);
%cl = trainWekaClassifier(w_data,classifier,'-L 0');

if flag_rc
    for i=1:8
        % initialize the first learner with weight 1, given classifier
        ensemble{i}{1}.model=cl;
        ensemble{i}{1}.weight=1;
    end
else
    selected_ensemble{1}.model=cl;
    selected_ensemble{1}.weight=1;
end
result = zeros(1,rows-batchsize);
%exp_count=zeros(1,rows);
%ens_hist{1}={ensemble{1}{1}.model ensemble{1}{1}.weight length(ensemble{1}{1}.data)};
acc=zeros(1,floor(rows/batchsize)-1);
preds=zeros(1,rows-batchsize);
ams=zeros(floor(rows/batchsize)-1,2);

subwindow_size=size(test_data,1)/size(data,1)*batchsize;

result_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
pred_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
avg_acc=[];
avg_acc_test=[];
avg_result_test=zeros(1,rows-1);
xval_selection=4;

%result(1)=1;

exp_count=1;
acc(1)=1;
exp_hist=[];

if strategy==11 && ~flag_rc
    return;
end

%for all the data rows do incrementally the following:
numBatches = floor(rows/batchsize);

for k = 2:numBatches

    progress = 100*((k-1)/(numBatches-1)); %calculate progress for the whole dataset for logging
    % 1) calculate prediction of ensemble
    % disp('step 1'); 
    dsk=weka.core.Instances(w_data_train,(k-1)*batchsize,batchsize); %make a new dataset consisiting of current data point
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);
    %select an ensemble member to predict, if flag_return is set
    if flag_rc
    
        if strategy<=8 %always same AM
            r=strategy;

        elseif strategy==9 %original dwm
            if k>2
                if mean(resultsBatch)<threshold    
                    r=5;
                else
                    r=1;
                end
            else
                r=4;
            end
        elseif strategy==10 %optimal
            r=xval_selection;     
        elseif strategy==11
            r=1; %this doesn't matter here
        end
        
        disp(['Batchsize: ' num2str(batchsize) ', ' classifier_id ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', strategy: ' num2str(strategy) ', Batch: ' num2str(k) ', AM: ' num2str(r)]);

 
        %parfor i=1:8
        % predicting with all possible ensembles
        for i=1:8   
            [~, ensemble{i}] = wm_mult_predict_batch_weka(ensemble{i},dsk,labelsBatch); 
        end       
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=ensemble{r}{1}.ensemble_prediction; %assigning predictions to the predictions of the selected batch r

        %---------------------------------------------------------------
        %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
        %testset is given

        if ~isempty(test_data)
             test_dsk=weka.core.Instances(w_data_test,(k-1)*subwindow_size,subwindow_size);   
             test_preds=wm_mult_predict_batch_test_weka(ensemble{r},test_dsk); %calculate prediction
             pred_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds;
             result_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds==test_labels(1+(k-1)*subwindow_size:(k)*subwindow_size);
        end
        %---------------------------------------------------------------

        %RC
        r_actual=r;
        [selected_ensemble, r] = dwm_candidate_select_batch(ensemble);
        %selected_ensemble = ensemble{r};
        %disp([num2str(k) ': AM optimal = ' num2str(r)])
        disp(['Batchsize: ' num2str(batchsize) ', ' classifier_id ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', strategy: ' num2str(strategy) ', Batch: ' num2str(k) ', RC: 1' num2str(r)]);

        if strategy==11 %optimal am
           preds(1+(k-2)*batchsize:(k-1)*batchsize)=selected_ensemble{1}.ensemble_prediction;
        end
        ams(k-1,1)=r_actual; ams(k-1,2)=r;
 
        
    else %flag_rc is not set, only one ensemble
    
        [~, selected_ensemble] = wm_mult_predict_batch_weka(selected_ensemble,dsk,labelsBatch);
        
         %---------------------------------------------------------------
        %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
        %testset is given

        if ~isempty(test_data)
         test_dsk=weka.core.Instances(w_data_test,(k-1)*subwindow_size,subwindow_size);  
         test_preds=wm_mult_predict_batch_test_weka(selected_ensemble,test_dsk); %calculate prediction
         pred_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds;
         result_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds==test_labels(1+(k-1)*subwindow_size:(k)*subwindow_size);
        end
        
        
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=selected_ensemble{1}.ensemble_prediction;
       
    end
    
    %distr=tabulate(labels(1:k*batchsize)); %get the distribution of labels up to this point to estimate the threshold for DWM
    [~,majlabel_size]=mode(labels(1+(k-2)*batchsize:(k-1)*batchsize)); %get the distribution of labels from the last batch to estimate the threshold for DWM
    threshold=majlabel_size/batchsize; %the proportion of majority label
    resultsBatch=preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch';
    result(1+(k-2)*batchsize:(k-1)*batchsize)=resultsBatch;

    %create accuracy data for plot
    acc(k) = sum(result)/((k-1)*batchsize);
    
    %adaptation-----------------------------------------------------  
    %xval selection
    if strategy == 10
        if flag_rc
            [xval_selection] = dwm_xval_select_batch_weka(ensemble{r}, dsk, classifier, options, batchsize, NUMFOLDS, labelsBatch);
        else
            [xval_selection] = dwm_xval_select_batch_weka(selected_ensemble, dsk, classifier, options, batchsize, NUMFOLDS, labelsBatch);
        end
    end
    % create all variations of dwm adaptation if flag return is set
    %parfor i=0:7
    if flag_rc
        %parfor i=1:8
        for i=1:8
            ensemble{i}=dwm_adapt_batch_weka(selected_ensemble,dsk,classifier,options,i);
        end
        
    elseif strategy~=11 %if not set selected_ensemble automatically
        if strategy<=8 %always same AM
            r=strategy;
        elseif strategy==9 %original dwm
                if mean(resultsBatch)<threshold    
                    r=5;
                else
                    r=1;
                end
                
        elseif strategy == 10 %xval
            [r] = xval_selection;

        end
         ams(k-1,1)=r;ams(k-1,2)=r;
        selected_ensemble=dwm_adapt_batch_weka(selected_ensemble,dsk,classifier,options,r);       
    end
    disp(['Batchsize: ' num2str(batchsize) ', ' classifier_id ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', strategy: ' num2str(strategy) ', Batch: ' num2str(k) ', AM: ' num2str(r)]);


%     
    %save the experts, weights and size of dataset
%     ens_hist{k}={};
%     for j=1:size(ensemble,1)
%         aa={ensemble{j,1} ensemble{j,2} length(ensemble{j,3})};
%         ens_hist{k}=[ens_hist{k};aa];
%     end
    
    %save number of experts
%    exp_count(k)=size(ensemble,1);


    
    
end

avg_acc=mean(result());

if ~isempty(test_data)
    for i=1:floor(rows/batchsize)-1
         avg_result_test(i)=mean(result_test((i-1)*subwindow_size+1:i*subwindow_size));
    end
    
    avg_acc_test=mean(result_test);
end
    



% for j=1:size(ensemble,1)        
% exp_hist=[exp_hist; [size(ensemble{j,3},1),1]];
% end
toc
end
