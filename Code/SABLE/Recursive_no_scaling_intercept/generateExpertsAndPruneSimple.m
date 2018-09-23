function [ experts4, mutualPDF4, mutualPDFPos4 ] = generateExpertsAndPruneSimple( experts, mutualPDF, mutualPDFPos, dataBatch, valBatch,adaptPruneFlag, adaptPruneDiversityThreshold,PLSnLatentVectors, adaptExpGenerationkernelSize )
%GENERATEEXPERTSANDPRUNE generate new experts and prune with existing set
       [ newExperts, newMutualPDF, newMutualPDFPos] = generateExpertSimple( dataBatch, valBatch);
       %join with the existing set
       experts4 = [experts, newExperts];
       mutualPDF4 = [mutualPDF,newMutualPDF ];
       mutualPDFPos4 = [mutualPDFPos, newMutualPDFPos];
       
       %pruning
       flag_PruningOn=adaptPruneFlag;
       while (flag_PruningOn==1 && length(experts4)>1) %if Pruning is on merge the correlated experts one by one
           [ experts4, mutualPDF4, mutualPDFPos4, flag_PruningOn ] = ... %check for correlated experts
               mergeExperts2BPDF( experts4, mutualPDF4, mutualPDFPos4, dataBatch, adaptPruneDiversityThreshold); %if found, return the merged data, if not turn the flag off
       end

end

