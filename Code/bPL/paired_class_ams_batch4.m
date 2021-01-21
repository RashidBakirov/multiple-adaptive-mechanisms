function[result, preds, result_test, pred_test, avg_result_test, change_hist, change, avg_acc, avg_acc_test] = paired_class_ams_batch4(data, labels, threshold, classifier, mode, flag_rc,  batchsize, test_data, test_labels)

% Simulation of simple online classfication without forgetting

[rows cols]=size(data);

NUMFOLDS=10;

ds=dataset(data(1:batchsize,:),labels(1:batchsize)); %create the first datapoint
ds_react=ds;
exp=ds*classifier;
exp_react=exp;
exp_old=exp;

avg_result_test=[];

result = zeros(1,rows-batchsize);
acc=zeros(1,rows-batchsize);
preds=zeros(1,rows-batchsize);
%avg_result=zeros(1,rows-batchsize);

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


%for all the data rows do incrementally the following:
for k = 2:floor(rows/batchsize)
    dataBatch=data(1+(k-1)*batchsize:k*batchsize,:);
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);

    dsk=dataset(dataBatch,labelsBatch); 
    
    
    tst=dsk*exp; %perform classification (stable expert)
    tst_react=dsk*exp_react; %perform classification on reactive expert
    tst_0=dsk*exp_old; %perform classification on "old" expert (no adaptation)
    
    fin_pred=labeld_rb(tst); %get predicted label (stable expert)
    fin_pred_react=labeld_rb(tst_react); %get predicted label (reactive expert)
    fin_pred_0=labeld_rb(tst_0); %get predicted label (no adaptation)
    
    fin_acc=mean(fin_pred==labelsBatch);
    fin_acc_react=mean(fin_pred_react==labelsBatch);
    fin_acc_0=mean(fin_pred_0==labelsBatch);
    
    ds_old=ds;
    ds_old_react=ds_react;
    exp_old=exp;
    exp_react_old=exp_react;
    
    %no adaptation
    if mode==0 | (mode==4 & xval_select==0)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_0;
        disp([num2str(k) ': AM deployed=0']);
    
    %stable learner
    elseif mode==1 | (mode==4 & xval_select==1)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        ds=[ds; dsk];
        ds_react = dsk;
        disp([num2str(k) ': AM deployed=1']);
        exp=ds*classifier; %retrain stable expert
        exp_react=ds_react*classifier; %retrain reactive expert
    %reactive learner
    elseif mode==2 | (mode==4 & xval_select==2)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
        ds=[ds_react; dsk];   
        disp([num2str(k) ': AM deployed=2']);
        ds_react = dsk;
        exp=ds*classifier; %retrain stable expert
        exp_react=ds_react*classifier; %retrain reactive expert
        
    %paired learner    
    elseif mode==3
        if changecounter>threshold
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            changecounter=0;
            change=change+1;
            change_hist=[change_hist k];
            ds=[ds_react; dsk];
            disp('boom');
        else
            ds=[ds; dsk];
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        end
        ds_react = dsk;
        exp=ds*classifier; %retrain stable expert
        exp_react=ds_react*classifier; %retrain reactive expert
        
    %optimal learner    
    else
        [~,max_ind] =max([fin_acc fin_acc_react fin_acc_0]);
        if max_ind==1
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
            ds=[ds; dsk];
            ds_react = dsk;
            exp=ds*classifier; %retrain stable expert
            exp_react=ds_react*classifier; %retrain reactive expert
        elseif max_ind==2
            fin_acc<fin_acc_react
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            ds=[ds_react; dsk];
            ds_react = dsk;
            exp=ds*classifier; %retrain stable expert
            exp_react=ds_react*classifier; %retrain reactive expert
        else
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_0;
        end
    end
    
    if mode==4
        [xval_select] = paired_xval4(exp_old, ds_old,ds_old_react,dataBatch,labelsBatch, classifier, batchsize, NUMFOLDS);
    end
    
    ds_react = dsk;
    exp=ds*classifier; %retrain stable expert
    exp_react=ds_react*classifier; %retrain reactive expert
    
       
    result(1+(k-2)*batchsize:(k-1)*batchsize) = (preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch');

    
    
    if (fin_acc<fin_acc_react)
        changecounter=changecounter+1; %reactive learner performs better, set the change bit
    else
        changecounter=changecounter-1; %unset the change bit
    end
    
    if (changecounter<0)
        changecounter=0;
    end
    
    if flag_rc
        [~,max_ind] =max([fin_acc fin_acc_react fin_acc_0]);
        if max_ind==1
            disp([num2str(k) ': RC=1']);
            ds=[ds_old; dsk];
            ds_react = dsk;
            exp=ds*classifier; %retrain stable expert
            exp_react=ds_react*classifier; %retrain reactive expert
        elseif max_ind==2
            disp([num2str(k) ': RC=2']);
            ds=[ds_old_react; dsk];
            ds_react = dsk;
            exp=ds*classifier; %retrain stable expert
            exp_react=ds_react*classifier; %retrain reactive expert
        else
            disp([num2str(k) ': RC=0']);
            ds=ds_old;
            ds_react=ds_old_react;
            exp=exp_old;
            exp_react=exp_react_old;
        end
    end
    
%    disp([num2str(k) ': AM deployed=' num2str(selected_index) ', AM optimal=' num2str(correct_index)]);
    
    %---------------------------------------------------------------
    %TESTING ON A SEPARATE TESTSET, without learning on it
    if (~isempty(test_data) && ~isempty(test_labels))
        dstest=dataset(test_data((k-1)*subwindow_size+1:k*subwindow_size,:));
        tst=dstest*exp; %perform classification
        u =labeld_rb(tst);%calculate predictions
        pred_test((k-2)*subwindow_size+1:(k-1)*subwindow_size)= u;
    end
      
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
