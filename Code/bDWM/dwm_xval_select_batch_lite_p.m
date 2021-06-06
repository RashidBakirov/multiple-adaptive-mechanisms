function max_ind = dwm_xval_select_batch_lite_p(ensemble, dataBatch, labelsBatch, classifier, batchSize, numFolds)


    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(numFolds*2,1);
    
    ensemble_train = cell(numFolds*2,1);
    
    %combining two for loops in one parallel parfor, this is why it looks
    %so strange
    parfor cnt=1:numFolds*2

        i=ceil(cnt/2); 
        j=mod(cnt-1,2)+1;
        
        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        labelsBatchTrain=[labelsBatch(1:1+(i-1)*testSize-1);labelsBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        dsk_train=dataset(dataBatchTrain,labelsBatchTrain);
        dsk_test=dataset(dataBatchTest,labelsBatchTest);
        
        ensemble_train{cnt}=dwm_adapt_batch_lite(ensemble,dsk_train,classifier,j);
        [~, ensemble_train{cnt}] = wm_mult_predict_batch(ensemble_train{cnt},dsk_test,labelsBatchTest);
        sumAccuracy(cnt)=ensemble_train{cnt}{1}.ensemble_accuracy;

    end
    sumAccuracy=reshape(sumAccuracy,2,numFolds);
    [~,max_ind] =max(sum(sumAccuracy,2));     
end