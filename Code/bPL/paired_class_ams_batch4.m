function[result, preds, result_test, pred_test, avg_result_test, change_hist, change, avg_acc, avg_acc_test] = paired_class_ams_batch4(data, labels, threshold, classifier, mode, flag_rc,  batchsize, test_data, test_labels, nFolds, dataset_id)

% Simulation of simple online classfication without forgetting

if isempty(dataset_id) %dataset_id for logging purposes
    dataset_id=0;
end


[rows , ~]=size(data);

NUMFOLDS=nFolds;

% if ~isempty(test_data)
%     w_data_test = matlab2weka('w_data_test', [], [test_data test_labels]);
%     w_data_test = wekaNumericToNominal( w_data_test, 'last');
% end

ds=dataset(data(1:batchsize,:),labels(1:batchsize)); %create the first datapoint
ds_react=ds;
dsk_old=ds;
dsk_old2=ds;
exp_stable=ds*classifier;
exp_react=exp_stable;
exp_old=exp_stable;

avg_result_test=[];

result = zeros(1,rows-batchsize);
acc=zeros(1,rows-batchsize);
preds=zeros(1,rows-batchsize);
%avg_result=zeros(1,rows-batchsize);

avg_acc=[];
avg_acc_test=[];

subwindow_size=size(test_data,1)/size(data,1)*batchsize;
result_test = zeros(1,size(test_data,1)-subwindow_size);

pred_test = zeros(1,size(test_data,1)-subwindow_size);

result(1)=1;

acc(1)=1;
change_hist=[];
change=0;
changecounter=0;
xval_select=1;

avg_result=[];
flag_counter=1;

if mode>4 && ~flag_rc
    return
end

numBatches = floor(rows/batchsize);

%for all the data rows do incrementally the following:
for k = 2:numBatches
    
    progress = 100*(((k-1)+mode*(numBatches-1)+flag_rc*5*(numBatches-1))/(11*(numBatches-1))); %calculate progress for the whole dataset for logging
      
    dataBatch=data(1+(k-1)*batchsize:k*batchsize,:);
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);
    dsk=dataset(dataBatch,labelsBatch); 
    
    fin_pred=labeld_rb(dsk*exp_stable); %perform classification
    fin_pred_react=labeld_rb(dsk*exp_react); %perform classification on reactive expert
    fin_pred_0=labeld_rb(dsk*exp_old); %perform classification on reactive expert

    fin_acc=mean(fin_pred==labelsBatch);
    fin_acc_react=mean(fin_pred_react==labelsBatch);
    fin_acc_0=mean(fin_pred_0==labelsBatch);
    
    ds_old_react=ds_react;
    ds_old=ds;
   
    %no adaptation
    if mode==0 || (mode==4 && xval_select==0)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_0;
        exp = exp_old;
        disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', AM: 0']);
        
    
    %stable learner
    elseif mode==1 || (mode==4 && xval_select==1)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        exp=exp_stable;
        disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', AM: 1']);

        
    %reactive learner
    elseif mode==2 || (mode==4 && xval_select==2)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
        exp_stable=exp_react;
        exp=exp_react;
        disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', AM: 2']);

        
        %paired learner
    elseif mode==3
        if changecounter>threshold
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            changecounter=0;
            change=change+1;
            %change_hist=[change_hist k];
            exp_stable=exp_react;
            ds=ds_react;
            exp=exp_react;
            disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', AM: 2']);

            %disp('boom');
        else
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
            exp=exp_stable;
            disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', AM: 1']);

        end        
    end
    
        %---------------------------------------------------------------
    %TESTING ON A SEPARATE TESTSET, without learning on it - All strategies
    %except oracle
    if ~isempty(test_data) && mode<=4
        test_dsk=dataset(test_data((k-1)*subwindow_size+1:k*subwindow_size,:));
        test_preds=labeld_rb(test_dsk*exp); %calculate prediction
        pred_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds;
        result_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds==test_labels(1+(k-1)*subwindow_size:(k)*subwindow_size);
    end
    %----
        
    if flag_rc || mode > 4
        [~,max_ind] =max([fin_acc fin_acc_react fin_acc_0]);
        if max_ind==1 && ~(mode==3)
            %disp('RC1');
            exp=exp_stable;
            if mode > 4   %oracle learner
                preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
            end
            disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', RC: 1']);

        elseif max_ind==2 && ~(mode==3)
            %disp('RC2');
            exp=exp_react;
            if mode > 4 %oracle learner
                preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            end
            disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', RC: 2']);

        elseif max_ind==3
            %disp('RC0');
            exp=exp_old;
            dsk_old=dsk_old2;
            flag_counter=0;
            if mode > 4 %oracle learner
                preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_acc_0;
            end
            disp(['Batchsize: ' num2str(batchsize) ', Dataset: ' num2str(dataset_id) ', ' num2str(progress) '%, RC: ' num2str(flag_rc) ', Mode: ' num2str(mode) ', Batch: ' num2str(k) ', RC: 0']);

        end
    end
    
    %TESTING ON A SEPARATE TESTSET, without learning on it - Oracle
    %strategy
    if ~isempty(test_data) && mode>4
        test_dsk=dataset(test_data((k-1)*subwindow_size+1:k*subwindow_size,:));
        test_preds=labeld_rb(test_dsk*exp); %calculate prediction
        pred_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds;
        result_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds==test_labels(1+(k-1)*subwindow_size:(k)*subwindow_size);
    end
    
    if ~(mode==0) || flag_rc %if statement to avoid unnecessary execution
        exp_old=exp;
        exp_stable=exp;
        ds_react=dsk_old; %?
        exp_react=ds_react*classifier;
        
    end
    
    if mode==4
        %[xval_select] = paired_xval4(exp_stable,exp_react,dsk, labelsBatch, NUMFOLDS, batchsize);
        [xval_select] = paired_xval4_new(ds_old,ds_old_react,dataBatch,labelsBatch, classifier, batchsize, NUMFOLDS);
    end
    
    if ~(mode==0 || (mode==4 && xval_select==0)) || flag_rc
        ds=[ds; dsk];
        ds_react=[ds_react; dsk];
        exp_stable=ds*classifier;
        exp_react=ds_react*classifier;
        dsk_old2=dsk_old; %this is to save the pre-previous data batch for the react learner
        dsk_old=dsk; %this is to save the previous data batch for the react learner
    end
 
    result(1+(k-2)*batchsize:(k-1)*batchsize) = (preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch');
       
    if mode==3 && (~flag_rc || (flag_rc && ~(flag_counter==0))) %change the counters only when there is adaptation and mode 3 is required
        if (fin_acc<fin_acc_react)
            changecounter=changecounter+1; %reactive learner performs better, set the change bit
        else
            changecounter=changecounter-1; %unset the change bit
        end

        if (changecounter<0)
            changecounter=0;
        end       
    end
    flag_counter=1;       
end

if (~isempty(test_data) && ~isempty(test_labels))
    result_test = bsxfun(@eq, pred_test,test_labels(1+subwindow_size:end)');
end
%get average accuracy on testset
for i=1:size(result,2)/batchsize
    avg_result(i)=mean(result((i-1)*batchsize+1:i*batchsize));
end

avg_acc=mean(result);

if ~isempty(test_data)
    for i=1:size(result_test,2)/subwindow_size
        avg_result_test(i)=mean(result_test((i-1)*subwindow_size+1:i*subwindow_size));
    end
    
    avg_acc_test=mean(result_test);
end

end