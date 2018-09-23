function [ experts1, experts2 ] = updateExperts( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, PLSnLatentVectors, decayFactor )

%Update experts with the data instances they predict the best both with and without decay

%calculate predictions
[ preds, expPreds, ~  ] = calculatePredictionsB( experts, mutualPDF, mutualPDFPos, dataBatch,PLSnLatentVectors);
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
        experts1  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, PLSnLatentVectors, 1 ); %update experts            
        experts2  = adaptUpdateRPLSseparate1( experts, expertsUpdateData, expertsUpdateVal, PLSnLatentVectors, decayFactor ); %update experts

end

