function[acc, avg_acc , result, preds, avg_acc_test, pred_test, ams] = dwm_ams_batch_lastbest(data, labels, classifier, batchsize, test_data, test_labels)
tic
% dynamic weighted majority with multiple ams
% mode to select AM
% 1:8 - respective AM only


disp('START');
[rows, ~]=size(data);

ds1=dataset(data(1:batchsize,:),labels(1:batchsize)); %create the first datapoint
cl=ds1*classifier;

ensemble = cell(8,1);

for i=1:8
    % initialize the first learner with weight 1, given classifier
    ensemble{i}{1}.model=cl;
    ensemble{i}{1}.weight=1;
    ensemble{i}{1}.data=ds1;
end

result = zeros(1,rows-batchsize);
%exp_count=zeros(1,rows);
%ens_hist{1}={ensemble{1}{1}.model ensemble{1}{1}.weight length(ensemble{1}{1}.data)};
acc=zeros(1,floor(rows/batchsize)-1);
preds=zeros(1,rows-batchsize);
ams=zeros(floor(rows/batchsize)-1,2);

subwindow_size=size(test_data,1)/size(data,1);

result_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
pred_test = zeros(1,size(test_data,1)-subwindow_size*batchsize);
avg_acc_test=[];

acc(1)=1;

r=1;

%for all the data rows do incrementally the following:
for k = 2:floor(rows/batchsize)
    % 1) calculate prediction of ensemble
    % disp('step 1');
     
    dataBatch=data(1+(k-1)*batchsize:k*batchsize,:);
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);
    dsk=dataset(dataBatch,labelsBatch); %make a new dataset consisiting of current data point
    
    %parfor i=1:8
    % predicting with all possible ensembles
    for i=1:8
        [~, ensemble{i}] = wm_mult_predict_batch(ensemble{i},dsk,labelsBatch);
    end
    preds(1+(k-2)*batchsize:(k-1)*batchsize)=ensemble{r}{1}.ensemble_prediction; %assigning predictions to the predictions of the selected batch r
    
    %---------------------------------------------------------------
    %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
    %testset is given
    
    if ~isempty(test_data)
        test_dsk=dataset(test_data(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize,:));
        test_preds_final = wm_mult_predict_batch_test(ensemble{r},test_dsk);
        pred_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize) = wm_mult_predict_batch_test(ensemble{r},test_dsk);
        result_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds_final==test_labels(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize);
    end
    %---------------------------------------------------------------
    
    %RC
    r_actual=r;
    [selected_ensemble, r] = dwm_candidate_select_batch(ensemble);
    disp([num2str(k) ': AM optimal = ' num2str(r)])
    ams(k-1,1)=r_actual; ams(k-1,2)=r;
      
    resultsBatch=preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch';
    result(1+(k-2)*batchsize:(k-1)*batchsize)=resultsBatch;
     
    %adaptation-----------------------------------------------------
    
    % create all variations of dwm adaptation if flag return is set
    %parfor i=0:7
    
    for i=1:8
        ensemble{i}=dwm_adapt_batch(selected_ensemble,dsk,classifier,i);
    end
     
    
    %create accuracy data for plot
    acc(k) = sum(result)/((k-1)*batchsize);
   
end

avg_acc=mean(result());

if ~isempty(test_data) 
    avg_acc_test=mean(result_test);
end




% for j=1:size(ensemble,1)
% exp_hist=[exp_hist; [size(ensemble{j,3},1),1]];
% end
toc
end
