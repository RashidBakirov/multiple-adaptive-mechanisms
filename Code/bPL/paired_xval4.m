function[max_ind] = paired_xval4(ds,ds_react,dataBatch,labelsBatch, classifier, batchSize, numFolds)

    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(1,2);

    for i=1:numFolds
        
        

        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        labelsBatchTrain=[labelsBatch(1:1+(i-1)*testSize-1);labelsBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        dsk_train=dataset(dataBatchTrain,labelsBatchTrain);
        dsk_test=dataset(dataBatchTest,labelsBatchTest);
        
        ds_i = [ds; dsk_train];
        ds_react_i = [ds_react; dsk_train];
        
        exp=ds_i*classifier; %retrain stable expert
        exp_react=ds_react_i*classifier; %retrain reactive expert
        
        tst=dsk_test*exp; %perform classification
        tst_react=dsk_test*exp_react; %perform classification on reactive expert
        fin_pred=labeld_rb(tst); %get predicted label
        fin_pred_react=labeld_rb(tst_react); %get predicted label
        fin_acc=mean(fin_pred==labelsBatchTest);
        fin_acc_react=mean(fin_pred_react==labelsBatchTest);
        
        sumAccuracy(1)=sumAccuracy(1)+fin_acc;
        sumAccuracy(2)=sumAccuracy(2)+fin_acc_react;

    end
    tst0=dataBatch*exp; %perform classification
    fin_pred0=labeld_rb(tst0); %get predicted label
    fin_acc0=mean(fin_pred0==labelsBatch);
    
    [~,max_ind] =max([sumAccuracy fin_acc0*numFolds]);
    
    if max_ind==3
        max_ind=0;
    end
end