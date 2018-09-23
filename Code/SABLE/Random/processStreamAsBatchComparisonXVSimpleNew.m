function [ avg_error, predictions, experts, mutualPDF, mutualPDFPos, errors, adaptations, finalNumExperts, numAdaptations, mseVal, mapeVal, maseVal ] = processStreamAsBatchComparisonXVSimpleNew( experts, mutualPDF, mutualPDFPos, data, val, batchSize, AMs, flagMode)
%PROCESSSTREAM process data in streaming fashion batch by batch. Stream is simulated from
%data
% the algorithm learns always from every sample. Additionally
%every time error on current batch is > threshold, ONE adaptation mechanism
%CAN BE triggered
%algorithhm is as follows
%-make predictions on a new batch
%-calculate average error
% ADAPTATION PROCESS
%Comparison: Check all of the adaptation mechanisms 0/1/2/3 at EVERY batch (no change detection). Record the results. Select best/random mechanism to continue. 

    %global parameters defined with defineParameters()
    global par;
    
    numBatches=floor(length(val)/batchSize);
    predictions={};
    errors={};
    adaptations=[];



       
    %first check if the initial expert set is empty, if it is, create one
    %from the first batch of data.
    if (isempty(experts) || isempty(mutualPDF) || isempty(mutualPDFPos))
            [ experts, mutualPDF, mutualPDFPos] = generateExpertSimple( data(1:batchSize,:), val(1:batchSize));
            startBatch=2;
    else
        startBatch=1;
    end

  
    for iBatch=startBatch:numBatches
        
        if iBatch==92
           iBatch 
        end
       
        if iBatch*batchSize<=length(val)
            dataBatch=data(1+(iBatch-1)*batchSize:iBatch*batchSize,:);
            valBatch=val(1+(iBatch-1)*batchSize:iBatch*batchSize);
        else
            dataBatch=data(1+(iBatch-1)*batchSize:end,:);
            valBatch=val(1+(iBatch-1)*batchSize:end);
        end
       
        
      
        %predict on a batch
        [ preds, expPreds, weights  ] = calculatePredictionsB( experts, mutualPDF, mutualPDFPos, dataBatch,par.PLSnLatentVectors);
        predictions{iBatch}=preds; 
        err=valBatch-preds;        
        errors{end+1}=err; %save the errors
        
        meanError=mean(abs(err));

        %first candidate of adaptation - native (RPLS) adaptatiohn
        %here a data instance will only be used for updating only one
        %expert  - the one which gave the most accurate prediction on it
        %small forgetting factor is also used.

        
        [ experts1, experts2 ] = updateExperts( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, par.forgetFactor );   
        mutualPDF1=mutualPDF;
        mutualPDFPos1=mutualPDFPos;
        mutualPDF2=mutualPDF;
        mutualPDFPos2=mutualPDFPos;

        %second candidate - adapt weights
        %adapt weights only if there are more than one expert is
        %present, otherwise go to the next adaptation step
        [mutualPDF3, mutualPDFPos3 ]  = updateDescriptorsBatchB( experts, dataBatch, valBatch, mutualPDF,mutualPDFPos,  par.adaptDescriptorKernelSize );      
        experts3=experts;

        %third candidate - create new experts from the batch
        [ experts4, mutualPDF4, mutualPDFPos4 ] = generateExpertsAndPruneSimple( experts, mutualPDF, mutualPDFPos, ...
                                                                dataBatch, valBatch, par.adaptPruneFlag, ...
                                                                par.adaptPruneDiversityThreshold,par.PLSnLatentVectors, par.adaptDescriptorKernelSize );
                                                         
        [mutualPDF4, mutualPDFPos4 ]  = updateDescriptorsBatchB( experts4, dataBatch, valBatch,mutualPDF4, mutualPDFPos4,  par.adaptDescriptorKernelSize );      
                                                        
         meanError0=meanError; 

%         %look which AM performs better on the current batch and use it
        meanError1=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                            par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                            par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 1, 10  );
        
        meanError2=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                            par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                            par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 2, 10  );
        
        meanError3=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                            par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                            par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 3, 10  );
        meanError4=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                            par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                            par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 4, 10  );    
       
        

        %choose which adaptation mechanism to use - either the one
        %which provides the best error rate on the next batch or
        %randomly


        
        if flagMode==1
            adaptationMechanism=randi(5,1)-1;
            
        elseif flagMode==0
            %the best adaptation mechanism for the current batch
            %             [~,adaptationMechanism]=min([meanError0 meanError1 meanError2 meanError3 meanError4 meanError5]);
            [~,adaptationMechanism]=min([meanError0 meanError1 meanError2 meanError3 meanError4]);
            adaptationMechanism=adaptationMechanism-1;
            
        elseif flagMode==2
            [~,adaptationMechanism]=max([meanError0 meanError1 meanError2 meanError3 meanError4 meanError5]);
            adaptationMechanism=adaptationMechanism-1;
            
            
        elseif flagMode==3
            adaptationMechanism=AMs(iBatch-1);
            
        end

        
        
        disp(['Batch #',num2str(iBatch),' Adaptation mechanism #:',num2str(adaptationMechanism)]); 
     
        experts0=experts;
        mutualPDF0=mutualPDF;
        mutualPDFPos0=mutualPDFPos;
        
        if adaptationMechanism==1
            experts=experts1;
            mutualPDF=mutualPDF1;
            mutualPDFPos=mutualPDFPos1;
        elseif adaptationMechanism==2
            experts=experts2;
            mutualPDF=mutualPDF2;
            mutualPDFPos=mutualPDFPos2;
        elseif adaptationMechanism==3
            experts=experts3;
            mutualPDF=mutualPDF3;
            mutualPDFPos=mutualPDFPos3;
        elseif adaptationMechanism==4
            experts=experts4;
            mutualPDF=mutualPDF4;
            mutualPDFPos=mutualPDFPos4;
        end

        adaptations=[adaptations adaptationMechanism]; %save which adaptation mechanism was used
    
    end
      
    
    avg_error=mean(abs(vertcat(errors{:})));
    %figure;
   % plot(2:numBatches,cellfun(@mean,cellfun(@abs,errors,'UniformOutput',false)),1:numBatches, adaptations);
    
    preds=vertcat(predictions{:});
    if startBatch==2
        mseVal=mse(val(batchSize+1:batchSize+length(preds)),preds);
        mapeVal=mape(val(batchSize+1:batchSize+length(preds)),preds);
        maseVal=mase(val(batchSize+1:batchSize+length(preds)),preds);
    else
        mseVal=mse(val(1:length(preds)),preds);
        mapeVal=mape(val(1:length(preds)),preds);
        maseVal=mase(val(1:length(preds)),preds);
    end
    
    
    finalNumExperts=length(experts);
    numAdaptations=length(adaptations(adaptations~=0));
end

