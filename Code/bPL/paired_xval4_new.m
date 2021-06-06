function[max_ind] = paired_xval4_new(ds,ds_react,dataBatch,labelsBatch, classifier, batchSize, numFolds)

    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(1,2);

    for cnt=1:numFolds*2
        
        i=ceil(cnt/2); 
        j=mod(cnt-1,2)+1;

        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        labelsBatchTrain=[labelsBatch(1:1+(i-1)*testSize-1);labelsBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        dsk_train=dataset(dataBatchTrain,labelsBatchTrain);
        dsk_test=dataset(dataBatchTest,labelsBatchTest);
        
        ds_i = [ds; dsk_train];
        ds_react_i = [ds_react; dsk_train];
        
        if j==1
            exp=ds_i*classifier; %retrain stable expert
            tst=dsk_test*exp; %perform classification
            fin_pred=labeld_rb(tst); %get predicted label
            fin_acc=mean(fin_pred==labelsBatchTest);
            sumAccuracy(cnt)=fin_acc;
        elseif j==2
            exp_react=ds_react_i*classifier; %retrain reactive expert
            tst_react=dsk_test*exp_react; %perform classification on reactive expert
            fin_pred_react=labeld_rb(tst_react); %get predicted label
            fin_acc_react=mean(fin_pred_react==labelsBatchTest);
            sumAccuracy(cnt)=fin_acc_react;
        end

    end
    
    sumAccuracy=reshape(sumAccuracy,2,numFolds);
    sumAccuracy=sum(sumAccuracy,2);
    
    tst0=dataBatch*exp; %perform classification
    fin_pred0=labeld_rb(tst0); %get predicted label
    fin_acc0=mean(fin_pred0==labelsBatch);
    
    [~,max_ind] =max([sumAccuracy; fin_acc0*numFolds]);
    
    if max_ind==3
        max_ind=0;
    end
end