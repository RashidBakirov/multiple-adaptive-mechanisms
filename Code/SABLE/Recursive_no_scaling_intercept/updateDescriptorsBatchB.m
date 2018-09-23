function [mutualPDFUpdated, mutualPDFPosUpdated ] = updateDescriptorsBatchB( experts, X, Y, mutualPDF, mutualPDFPos, kernelSizeAdapt )
%ADAPTDESCRIPTORS Summary of this function goes here
%   Calculate new PDFs and merge with old ones. Use the same grid. Where
%   collisions occur, new PDF wins
    global par;    


    %calculate latent vector values for update
    %calculate latent vector values for update
    updateData={};
    for iEx=1:length(experts)
        
        %add the data to the history
         %newWeightsData=[experts_data{iEx}.weightsData;X]; 
         %newWeightsVal=[experts_data{iEx}.weightsValues;Y];
         


        
        %calculate the data to generate PDFs
        intercept=ones(size(X,1),1);
        T=[X intercept]*pinv(experts{iEx}.P');

        updateData{1}={{X},{T},{Y}};
    
        [ mutualPDFNew(iEx), mutualPDFPosNew(iEx) ] = buildDescriptorsSimpleB( experts(iEx), updateData, kernelSizeAdapt, mutualPDF{iEx}, mutualPDFPos{iEx} );

    end 
    
     %merging old and new PDFs

     [ mutualPDFUpdated, mutualPDFPosUpdated ] =mergePDFs(mutualPDFNew, mutualPDFPosNew,mutualPDF, mutualPDFPos, par.descDecay(1), par.descDecay(2));
     
end

