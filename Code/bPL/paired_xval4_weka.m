function[max_ind] = paired_xval4_weka(exp,exp_react,dsk,labelsBatch,numFolds, batchSize)
 
    testSize=round(batchSize/numFolds);

    sumAccuracy=zeros(1,2);

    for i=1:numFolds
        
        expI = copy(exp);
        exp_reactI = copy(exp_react);

        dsk_train=dsk.trainCV(numFolds,i-1);       
        dsk_test=dsk.testCV(numFolds,i-1);
        
        labelsBatchTest=labelsBatch(1+(i-1)*testSize:i*testSize);
        
        for j=1:dsk_train.numInstances
            inst = dsk_train.instance(j-1);
            expI.updateClassifier(inst);
            exp_reactI.updateClassifier(inst);
        end
        
        fin_pred=wekaClassify(dsk_test,expI); %perform classification
        fin_pred_react=wekaClassify(dsk_test,exp_reactI); %perform classification on reactive expert
        fin_acc=sum(fin_pred==labelsBatchTest);
        fin_acc_react=sum(fin_pred_react==labelsBatchTest);
        
        sumAccuracy(1)=sumAccuracy(1)+fin_acc;
        sumAccuracy(2)=sumAccuracy(2)+fin_acc_react;

    end
    
    fin_pred0=wekaClassify(dsk,exp); %perform classification without adaptation
    fin_acc0=sum(fin_pred0==labelsBatch);
    
    [~,max_ind] =max([sumAccuracy fin_acc0]);
    
    if max_ind==3
        max_ind=0;
    end
end