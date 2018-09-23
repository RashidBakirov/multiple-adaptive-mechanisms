function [error, errorsAll, preds, stdDevErrors] = predictAndGetErrors( experts, mutualPDF, mutualPDFPos, dataBatch, valBatch, nLatentVectors )
%PREDICTANDGETERRORS Summary of this function goes here
%   Detailed explanation goes here
    [ preds, expertsPredictions, weights   ] = calculatePredictionsB( experts, mutualPDF, mutualPDFPos, dataBatch,nLatentVectors);
    %error=mse(valBatch,preds);
    errorsAll=valBatch-preds;
    error=mean(abs(errorsAll));  
    stdDevErrors=std(errorsAll);
end

