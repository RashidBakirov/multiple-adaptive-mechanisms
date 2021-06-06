function max_ind = dwm_xval_select_batch_par(ensemble, dataBatch, labelsBatch, classifier, batchSize, numFolds)


    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(10,8);
    
    ensemble_train = cell(numFolds,8);
    
    for i=1:numFolds

        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        labelsBatchTrain=[labelsBatch(1:1+(i-1)*testSize-1);labelsBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        dsk_train=dataset(dataBatchTrain,labelsBatchTrain);
        dsk_test=dataset(dataBatchTest,labelsBatchTest);
        
        %for j=1:8
        parfor j=1:8
            ensemble_train{i,j}=dwm_adapt_batch(ensemble,dsk_train,classifier,j);
            [~, ensemble_train{i,j}] = wm_mult_predict_batch(ensemble_train{i,j},dsk_test,labelsBatchTest);
            sumAccuracy(i,j)=sumAccuracy(i,j)+ensemble_train{i,j}{1}.ensemble_accuracy;
        end
    end
    [maxval,max_ind] =max(sum(sumAccuracy));     
end