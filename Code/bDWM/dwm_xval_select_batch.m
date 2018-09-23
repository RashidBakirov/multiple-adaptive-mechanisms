function max_ind = dwm_xval_select_batch(ensemble, dataBatch, labelsBatch, classifier, batchSize, numFolds)


    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(1,8);

    for i=1:numFolds

        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        labelsBatchTrain=[labelsBatch(1:1+(i-1)*testSize-1);labelsBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        dsk_train=dataset(dataBatchTrain,labelsBatchTrain);
        dsk_test=dataset(dataBatchTest,labelsBatchTest);
        
        for j=0:7
            ensemble_train{j+1}=dwm_adapt_batch(ensemble,dsk_train,classifier,j);
            [~, ensemble_train{j+1}] = wm_mult_predict_batch(ensemble_train{j+1},dsk_test,labelsBatchTest);
            sumAccuracy(j+1)=sumAccuracy(j+1)+ensemble_train{j+1}{1}.ensemble_accuracy;
        end
    end
    [maxval,max_ind] =max(sumAccuracy);
    if max_ind==1 & sumAccuracy(1)==sumAccuracy(2) %if the choice of not retraining and retraining are equal, choose retraining
          max_ind = 2;    
    else
    max_ind=max_ind-1;
      
end