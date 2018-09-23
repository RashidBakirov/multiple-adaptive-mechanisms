function [mutualPDFNew, mutualPDFPosNew  ] = calculateDescriptorsBatchB( experts, X, Y,kernelSizeAdapt)
%ADAPTDESCRIPTORS Summary of this function goes here
%   Recalculation of PDF-s according to the last batch (instead of adaptation of existing ones)
    

    %calculate latent vector values for update
    pdfCalculationData={};
    for iEx=1:length(experts)

        %calculate the data to generate PDFs
        intercept=ones(size(X,1),1);
        T=[X intercept]*pinv(experts{iEx}.P'); %was experts{iEx} instead of one not sure about this
        
        pdfCalculationData{1}={{X},{T},{Y}}; 
            
        [ mutualPDFNew(iEx), mutualPDFPosNew(iEx) ] = buildDescriptorsSimpleB( experts(iEx), pdfCalculationData, kernelSizeAdapt,[], [] );         
    end    
end

