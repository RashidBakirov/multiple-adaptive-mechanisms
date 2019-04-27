function max_ind = dwm_xval_select_batch_weka(ensemble, dsk, classifier, options, batchSize, numFolds)


    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(1,8);

    for i=1:numFolds
        
        dsk_train=dsk.trainCV(numFolds,i-1);       
        dsk_test=dsk.testCV(numFolds,i-1); 
        
        labelsBatchTest=[];
        for t=0:dsk_test.numInstances-1
            labelsBatchTest=[labelsBatchTest;str2double(dsk_test.classAttribute.value(dsk_test.get(t).classValue()))];
        end
        
        for j=1:8         
            ensemble_train{j}=dwm_adapt_batch_weka(ensemble,dsk_train,classifier,options,j);         
            [~, ensemble_train{j}] = wm_mult_predict_batch_weka(ensemble_train{j},dsk_test,labelsBatchTest);
            sumAccuracy(j)=sumAccuracy(j)+ensemble_train{j}{1}.ensemble_accuracy;
        end
    end
    [maxval,max_ind] =max(sumAccuracy);
        
end