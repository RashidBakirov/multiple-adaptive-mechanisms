function [ avg_error, predictions, experts, mutualPDF, mutualPDFPos, errors, adaptations,finalNumExperts, numAdaptations,comparisonResult, mseVal, mapeVal, maseVal ] = processStreamAsBatchComparison2Simple43( experts, mutualPDF, mutualPDFPos, data, val, batchSize, flagMode )
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
%Simple: no partitioning of batches


%nDefBatch: specifying number of the AMs defined by user so the accuracy
%won't be computed there

    %global parameters defined with defineParameters()
    global par;
    
    numBatches=floor(length(val)/batchSize);
    predictions={};
    errors={};
    adaptations=[];
    comparisonResult={};
       
    %first check if the initial expert set is empty, if it is, create one
    %from the first batch of data.
    if (isempty(experts) || isempty(mutualPDF) || isempty(mutualPDFPos))
            [ experts, mutualPDF, mutualPDFPos] = generateExpertSimple( data(1:batchSize,:), val(1:batchSize));
            startBatch=2;
    else
        startBatch=1;
    end

  
    for iBatch=startBatch:numBatches
        
        if iBatch==5
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

        %assign the data for update for each expert
        expertsUpdateData={};
        for iEx=1:length(experts)
            expErrors=repmat(valBatch,1,length(experts))- expPreds;
            indexes=(1:1:length(valBatch))';
            indexes=indexes.*(abs(expErrors(:,iEx))==min(abs(expErrors),[],2)); %identify the data instances where the error for the particular expert is minimum
            indexes(indexes==0)=[];
            expertsUpdateData{iEx}=dataBatch(indexes,:);
            expertsUpdateVal{iEx}=valBatch(indexes);
        end
        [ experts1 ]  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, par.PLSnLatentVectors, 1 ); %update experts
        mutualPDF1=mutualPDF;
        mutualPDFPos1=mutualPDFPos;
        
        [ experts2 ]  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, par.PLSnLatentVectors, par.forgetFactor ); %update experts
        mutualPDF2=mutualPDF;
        mutualPDFPos2=mutualPDFPos;
        

        %second candidate - adapt weights
        %adapt weights only if there are more than one expert is
        %present, otherwise go to the next adaptation step
        [mutualPDF3, mutualPDFPos3 ]  = updateDescriptorsBatchB( experts, dataBatch, valBatch, mutualPDF, mutualPDFPos, par.adaptDescriptorKernelSize );      
        experts3=experts;

        %third candidate - create new experts from the batch
        %the creation of a new expert must be accompanied by the
        %weights change
       [ newExperts, newMutualPDF, newMutualPDFPos] = generateExpertSimple( dataBatch, valBatch );
       %join with the existing set
       experts4 = [experts, newExperts];
       mutualPDF4 = [mutualPDF,newMutualPDF ];
       mutualPDFPos4 = [mutualPDFPos, newMutualPDFPos];
       
       %pruning
       flag_PruningOn=par.adaptPruneFlag;
       while (flag_PruningOn==1 && length(experts4)>1) %if Pruning is on merge the correlated experts one by one
           [ experts4, mutualPDF4, mutualPDFPos4, flag_PruningOn ] = ... %check for correlated experts
               mergeExperts2BPDF( experts4, mutualPDF4, mutualPDFPos4, dataBatch, par.adaptPruneDiversityThreshold); %if found, return the merged data, if not turn the flag off
             
       end
       [mutualPDF4, mutualPDFPos4 ]  = updateDescriptorsBatchB( experts4, dataBatch, valBatch, mutualPDF4, mutualPDFPos4, par.adaptDescriptorKernelSize  );    


        %look-ahead part - record the performances of each mechanism on the next batch 
        if (iBatch<numBatches)
            if (iBatch+1)*batchSize<=length(val)
               dataBatchNext=data(1+iBatch*batchSize:(iBatch+1)*batchSize,:);
               valBatchNext=val(1+iBatch*batchSize:(iBatch+1)*batchSize);
            else
               dataBatchNext=data(1+iBatch*batchSize:end,:);
               valBatchNext=val(1+iBatch*batchSize:end);
            end

            [meanError0, ~, preds0, ~] = predictAndGetErrors( experts, mutualPDF, mutualPDFPos, dataBatchNext, valBatchNext, par.PLSnLatentVectors );
            [meanError1, ~, preds1, ~] = predictAndGetErrors( experts1, mutualPDF1, mutualPDFPos1, dataBatchNext, valBatchNext, par.PLSnLatentVectors );
            [meanError2, ~, preds2, ~] = predictAndGetErrors( experts2, mutualPDF2, mutualPDFPos2, dataBatchNext, valBatchNext, par.PLSnLatentVectors );
            [meanError3, ~, preds3, ~] = predictAndGetErrors( experts3, mutualPDF3, mutualPDFPos3, dataBatchNext, valBatchNext, par.PLSnLatentVectors );
            [meanError4, ~, preds4, ~] = predictAndGetErrors( experts4, mutualPDF4, mutualPDFPos4, dataBatchNext, valBatchNext, par.PLSnLatentVectors );
        
            if flagMode==1
                adaptationMechanism=randi(5,1)-1;
            elseif flagMode==0
                [~,adaptationMechanism]=min([meanError0 meanError1 meanError2 meanError3 meanError4]);
                adaptationMechanism=adaptationMechanism-1;
            elseif flagMode==2
                [~,adaptationMechanism]=max([meanError0 meanError1 meanError2 meanError3 meanError4]);
                adaptationMechanism=adaptationMechanism-1;        
            end
            
        else
            if flagMode==1
                adaptationMechanism=randi(5,1)-1;
            else
                adaptationMechanism=0;
            end
        end

        %save comparison results and metadata
        comparisonResult{end+1}{1}=iBatch; %number of batch
        comparisonResult{end}{2}=meanError; %mean error on the current batch       
        comparisonResult{end}{3}=length(experts); %number of experts
        comparisonResult{end}{4}=meanError0;
        comparisonResult{end}{5}=meanError1;
        comparisonResult{end}{6}=meanError2;
        comparisonResult{end}{7}=meanError3;
        comparisonResult{end}{8}=meanError4;
        comparisonResult{end}{8}=meanError4;
        comparisonResult{end}{10}=preds0;
        comparisonResult{end}{11}=preds1;
        comparisonResult{end}{12}=preds2;
        comparisonResult{end}{13}=preds3;
        comparisonResult{end}{14}=preds4;

        %choose which adaptation mechanism to use - either the one
        %which provides the best error rate on the next batch or
        %randomly


        
        disp(['Batch #',num2str(iBatch),' Adaptation mechanism #:',num2str(adaptationMechanism)]); 

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
    %plot(2:numBatches,cellfun(@mean,cellfun(@abs,errors,'UniformOutput',false)),'-s');
    
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

