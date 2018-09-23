function [ avg_error, predictions, experts, mutualPDF, mutualPDFPos, errors, adaptations, mseVal, mapeVal, maseVal ] = processStreamAsBatchFixedAMSimple( experts, mutualPDF, mutualPDFPos, data, val, batchSize, AMchoice )
%PROCESSSTREAM process data in streaming fashion batch by batch. Stream is simulated from
%data
% the algorithm learns always from every sample. Additionally
%every time error on current batch is > threshold, ONE adaptation mechanism
%CAN BE triggered
%algorithhm is as follows
%-make predictions on a new batch
%-calculate average error
% ADAPTATION PROCESS
%FixedAM: use only one AM which is given as an input
%Empty AM for random

%nDefBatch: specifying number of the AMs defined by user so the accuracy
%won't be computed there

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
        iBatch;
        
      
       
        if iBatch*batchSize<=length(val)
            dataBatch=data(1+(iBatch-1)*batchSize:iBatch*batchSize,:);
            valBatch=val(1+(iBatch-1)*batchSize:iBatch*batchSize);
        else
            dataBatch=data(1+(iBatch-1)*batchSize:end,:);
            valBatch=val(1+(iBatch-1)*batchSize:end);
        end
        
      
        %predict on a batch
        [ preds, expPreds, expweights  ] = calculatePredictionsB( experts, mutualPDF, mutualPDFPos, dataBatch,par.PLSnLatentVectors);
        predictions{iBatch}=preds; 
        err=valBatch-preds;        
        errors{end+1}=err; %save the errors
       
        meanError=mean(abs(err));

        if isempty(AMchoice)
            AM=randi(5,1)-1;
        else
            AM=AMchoice;
        end
        
       if ismember(0,AM)
            disp(['Batch #',num2str(iBatch), ' AM 0: no adaptation ']); 
       end
       
       %adaptations=[adaptations;AM];

       if ismember(1,AM) || ismember(2,AM)
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
                if ismember(1,AM)
                    disp(['Batch #',num2str(iBatch), ' AM 1: learning ']); 
                    [ experts ]  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, par.PLSnLatentVectors, 1 ); %update experts
                elseif ismember(2,AM)
                    disp(['Batch #',num2str(iBatch), ' AM 2: learning with forgetting ']); 
                    [ experts ]  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, par.PLSnLatentVectors, par.forgetFactor ); %update experts
                end
       end
                 
       if ismember(3,AM)
            %adapt weights only if there are more than one expert is
            %present, otherwise go to the next adaptation step
            disp(['Batch #',num2str(iBatch), ' AM 3: weight change ']); 
            [mutualPDF, mutualPDFPos ]  = updateDescriptorsBatchB( experts, dataBatch, valBatch, mutualPDF, mutualPDFPos, par.adaptDescriptorKernelSize );      
        end
        
        if ismember(4,AM)
            %third candidate - create new experts from the batch
            %the creation of a new expert must be accompanied by the
            %weights change
            disp(['Batch #',num2str(iBatch), ' AM 4: add/merge experts ']); 
           [ newExperts, newMutualPDF, newMutualPDFPos] = generateExpertSimple( dataBatch, valBatch);
           %join with the existing set
           experts = [experts, newExperts];
           mutualPDF = [mutualPDF,newMutualPDF ];
           mutualPDFPos = [mutualPDFPos, newMutualPDFPos];
       
           %pruning
           flag_PruningOn=par.adaptPruneFlag;
           while (flag_PruningOn==1 && length(experts)>1) %if Pruning is on merge the correlated experts one by one
               [ experts, mutualPDF, mutualPDFPos, flag_PruningOn ] = ... %check for correlated experts
                   mergeExperts2BPDF( experts, mutualPDF, mutualPDFPos, dataBatch, par.adaptPruneDiversityThreshold ); %if found, return the merged data, if not turn the flag off
           end
           [mutualPDF, mutualPDFPos ]  = updateDescriptorsBatchB( experts, dataBatch, valBatch, mutualPDF, mutualPDFPos, par.adaptDescriptorKernelSize );      
        end 
      
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
end

