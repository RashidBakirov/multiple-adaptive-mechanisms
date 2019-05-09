function[acc, avg_acc , result, preds, avg_acc_test, pred_test, ams] = dwm_ams_batch_fs(data, labels, classifier, batchsize, test_data, test_labels, learn_rate, alpha)
tic
% dynamic weighted majority with multiple ams
% mode to select AM
% 1:8 - respective AM only


disp('START');
numlabels = length(unique(labels));

[rows cols]=size(data);

ds1=dataset(data(1:batchsize,:),labels(1:batchsize)) %create the first datapoint
dsk=[];
cl=ds1*classifier;

w_init=1/8;

am_weights=repmat(w_init, 1, 8);

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
avg_acc=[];
avg_acc_test=[];
avg_result_test=zeros(1,rows-1);

%result(1)=1;

exp_count=1;
acc(1)=1;
exp_hist=[];

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
        [batch_preds(:,i), ensemble{i}] = wm_mult_predict_batch(ensemble{i},dsk,labelsBatch);
        loss(i)=1-ensemble{i}{1}.ensemble_accuracy;
    end
    
    preds(1+(k-2)*batchsize:(k-1)*batchsize) = wm_class_prob_batch( batch_preds, am_weights);
    
    %assigning predictions to the probabilistic weighted vote of predictions from all
    %am's.
    s=sum(am_weights.*exp((-learn_rate)*loss));
    for i=1:8
        am_weights(i)=am_weights(i)*exp((-learn_rate)*loss(i))/s;
        am_weights(i)=alpha/8+(1-alpha)*am_weights(i);
    end
     
    %update weights according to fixed share (Cesa Bianchi 2012 version).
    am_weights=am_weights-learn_rate*loss;
    am_weights=simplex_proj(am_weights);
    %normalise weights
    am_weights=am_weights/sum(am_weights);
        
    %---------------------------------------------------------------
    %BEGIN TESTING ON A SEPARATE TESTSET, without learning on itif a
    %testset is given
    
    if ~isempty(test_data)
        test_dsk=dataset(test_data(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize,:));
        for i=1:8
        [batch_preds(:,i), ensemble{i}] = wm_mult_predict_batch(ensemble{i},dsk,labelsBatch);
        loss(i)=1-ensemble{i}{1}.ensemble_accuracy;
    end
        test_preds=wm_mult_predict_batch_test(ensemble{r},test_dsk); %calculate prediction
        pred_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds;
        result_test(1+(k-2)*subwindow_size*batchsize:(k-1)*subwindow_size*batchsize)=test_preds==test_labels(1+(k-1)*subwindow_size*batchsize:(k)*subwindow_size*batchsize);
    end
    %---------------------------------------------------------------
    
    %RC
    r_actual=r;
    [selected_ensemble, r] = dwm_candidate_select_batch(ensemble);
    disp([num2str(k) ': AM optimal = ' num2str(r)])
    ams(k-1,1)=r_actual; ams(k-1,2)=r;
    
    
    
    
    %distr=tabulate(labels(1:k*batchsize)); %get the distribution of labels up to this point to estimate the threshold for DWM
    distr=tabulate(labels(1+(k-2)*batchsize:(k-1)*batchsize)); %get the distribution of labels from the last batch to estimate the threshold for DWM
    threshold=max(distr(:,end))/100; %the proportion of majority label
    
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
        avg_result_test(i)=mean(result_test((i-1)*subwindow_size*batchsize+1:i*subwindow_size*batchsize));
    end
    
    avg_acc_test=mean(result_test);
end




% for j=1:size(ensemble,1)
% exp_hist=[exp_hist; [size(ensemble{j,3},1),1]];
% end
toc
end
