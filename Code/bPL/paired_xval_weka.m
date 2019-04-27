function[max_ind] = paired_xval_weka(exp,exp_react,dsk, batchSize, numFolds)

    testSize=round(batchSize/numFolds);
    
    sumAccuracy=zeros(1,2);

    for i=1:numFolds

        dsk_train=dsk.trainCV(numFolds,i-1);       
        dsk_test=dsk.testCV(numFolds,i-1);
        
        for i=1:dsk_train.numInstances
            inst = dsk_train.instance(i-1);
            exp.updateClassifier(inst);
        end
        
        for i=1:dsk_train.numInstances
            inst = dsk_train.instance(i-1);
            exp_react.updateClassifier(inst);
        end
        
        fin_pred=wekaClassify(dsk_test,exp); %perform classification
        fin_pred_react=wekaClassify(dsk_test,exp_react); %perform classification on reactive expert
        alldataTest=weka2matlab(dsk_test);
        labelsBatchTest=alldataTest(:,end);
        fin_acc=mean(fin_pred==labelsBatchTest);
        fin_acc_react=mean(fin_pred_react==labelsBatchTest);
        
        sumAccuracy(1)=sumAccuracy(1)+fin_acc;
        sumAccuracy(2)=sumAccuracy(2)+fin_acc_react;

    end
    [maxval,max_ind] =max(sumAccuracy);
end