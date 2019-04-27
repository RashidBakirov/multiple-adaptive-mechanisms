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
        
        for j=1:8
            ensemble_train{j}=dwm_adapt_batch(ensemble,dsk_train,classifier,j);
            [~, ensemble_train{j}] = wm_mult_predict_batch(ensemble_train{j},dsk_test,labelsBatchTest);
            sumAccuracy(j)=sumAccuracy(j)+ensemble_train{j}{1}.ensemble_accuracy;
        end
    end
    [maxval,max_ind] =max(sumAccuracy);     
end