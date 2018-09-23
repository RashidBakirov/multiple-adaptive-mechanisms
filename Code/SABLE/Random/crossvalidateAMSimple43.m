function [ avgError ] = crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, PLSnLatentVectors, ...
                                            adaptDescriptorKernelSize, adaptPruneFlag, ...
                                            adaptPruneDiversityThreshold, adaptExpGenerationkernelSize, decayFactor, indexAM, numFolds  )
%CROSSVALIDATEAMS Summary of this function goes here

    batchSize=length(valBatch);
    testSize=round(batchSize/numFolds);
    
    sumError=0;

    for i=1:numFolds

        valBatchTest=valBatch(1+(i-1)*testSize:i*testSize);
        dataBatchTest=dataBatch(1+(i-1)*testSize:i*testSize,:);
        
        valBatchTrain=[valBatch(1:1+(i-1)*testSize-1);valBatch(i*testSize+1:end)];
        dataBatchTrain=[dataBatch(1:1+(i-1)*testSize-1,:);dataBatch(i*testSize+1:end,:)];
        
        switch indexAM
           case 1
              [ experts_new, ~ ] = updateExperts( experts, mutualPDF, mutualPDFPos, valBatchTrain, dataBatchTrain, PLSnLatentVectors, decayFactor );
              mutualPDF_new=mutualPDF;
              mutualPDFPos_new=mutualPDFPos;  
            case 2
              [ ~ , experts_new ] = updateExperts( experts, mutualPDF, mutualPDFPos, valBatchTrain, dataBatchTrain, PLSnLatentVectors, decayFactor );
              mutualPDF_new=mutualPDF;
              mutualPDFPos_new=mutualPDFPos;  
           case 3
              [mutualPDF_new, mutualPDFPos_new ]  = updateDescriptorsBatchB( experts, dataBatchTrain, valBatchTrain, mutualPDF, mutualPDFPos, adaptDescriptorKernelSize );      
              experts_new=experts;
           case 4
              [ experts_new , mutualPDF_new , mutualPDFPos_new  ] = generateExpertsAndPruneSimple( experts, mutualPDF, mutualPDFPos, ...
                                                                dataBatchTrain, valBatchTrain,adaptPruneFlag, ...
                                                                adaptPruneDiversityThreshold,PLSnLatentVectors, adaptExpGenerationkernelSize );                                                            
              [mutualPDF_new, mutualPDFPos_new ]  = updateDescriptorsBatchB( experts_new, dataBatchTrain, valBatchTrain,mutualPDF_new , mutualPDFPos_new , adaptDescriptorKernelSize );   

        end
        
        sumError = sumError+predictAndGetErrors( experts_new, mutualPDF_new, mutualPDFPos_new, dataBatchTest, valBatchTest, PLSnLatentVectors );   
    end

    avgError=sumError/numFolds;
end

