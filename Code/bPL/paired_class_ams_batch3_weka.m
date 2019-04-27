function[result, preds, result_test, pred_test, avg_result_test, change_hist, change, avg_acc, avg_acc_test] = paired_class_ams_batch3_weka(data, labels, threshold, classifier, options, mode, flag_rc,  batchsize, test_data, test_labels)

% Simulation of simple online classfication without forgetting

[rows cols]=size(data);

NUMFOLDS=10;

%first convert everything to weka instances
w_data_train = matlab2weka('w_data_train', [], [data labels]);
w_data_train = wekaNumericToNominal( w_data_train, 'last');

if ~isempty(test_data)
    w_data_test = matlab2weka('w_data_test', [], [test_data test_labels]);
    w_data_test = wekaNumericToNominal( w_data_test, 'last');
end

ds=weka.core.Instances(w_data_train,0,batchsize); %create the first datapoint
ds_react=ds;
exp=trainWekaClassifier(ds,classifier,options);
exp_react=trainWekaClassifier(ds,classifier,options);

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
    dsk=weka.core.Instances(w_data_train,(k-1)*batchsize,batchsize); %make a new dataset consisiting of current data point
    labelsBatch=labels(1+(k-1)*batchsize:k*batchsize);
    
    fin_pred=wekaClassify(dsk,exp); %perform classification
    fin_pred_react=wekaClassify(dsk,exp_react); %perform classification on reactive expert
    fin_acc=mean(fin_pred==labelsBatch);
    fin_acc_react=mean(fin_pred_react==labelsBatch);
    
    exp_old=exp;
    
    %stable learner
    if mode==1 | (mode==4 & xval_select==1)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        disp([num2str(k) ': AM deployed=1']);
        
        %reactive learner
    elseif mode==2 | (mode==4 & xval_select==2)
        preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
        exp=exp_react;
        disp([num2str(k) ': AM deployed=2']);
        
        %paired learner
    elseif mode==3
        if changecounter>threshold
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            changecounter=0;
            change=change+1;
            change_hist=[change_hist k];
            exp=exp_react;
            disp('boom');
        else
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        end
        
        %optimal learner
    else
        if fin_acc<fin_acc_react
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred_react;
            exp=exp_react;
        else
            preds(1+(k-2)*batchsize:(k-1)*batchsize)=fin_pred;
        end
    end
    
    if mode==4
        [xval_select] = paired_xval_weka(exp,exp_react,dsk, batchsize, NUMFOLDS)
    end
    
    if flag_rc
        if fin_acc<fin_acc_react
            exp=exp_react;
        else
            exp=exp_old;
        end
    end
    
    for i=1:dsk.numInstances
        inst = dsk.instance(i-1);
        exp.updateClassifier(inst);
    end
    
    exp_react=trainWekaClassifier(dsk,classifier,options);
 
    result(1+(k-2)*batchsize:(k-1)*batchsize) = (preds(1+(k-2)*batchsize:(k-1)*batchsize)==labelsBatch');
    
    
    
    if (fin_acc<fin_acc_react)
        changecounter=changecounter+1; %reactive learner performs better, set the change bit
    else
        changecounter=changecounter-1; %unset the change bit
    end
    
    if (changecounter<0)
        changecounter=0;
    end
       

    
    %    disp([num2str(k) ': AM deployed=' num2str(selected_index) ', AM optimal=' num2str(correct_index)]);
    
    %---------------------------------------------------------------
    %TESTING ON A SEPARATE TESTSET, without learning on it
    if ~isempty(test_data)
        test_dsk=weka.core.Instances(w_data_test,(k-1)*subwindow_size,subwindow_size);
        test_preds=wekaClassify(test_dsk,exp); %calculate prediction
        pred_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds;
        result_test(1+(k-2)*subwindow_size:(k-1)*subwindow_size)=test_preds==test_labels(1+(k-1)*subwindow_size:(k)*subwindow_size);
    end
    %----
    
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
