function [ experts, mutualPDF, mutualPDFPos] = generateExpertSimple(trainingData, trainingValues)
%GENERATELOCALEXPERTS Summary of this function goes here
%  Generating  experts as per recepteive field technology
%  In a local manner, this creating clusters
    global par;

    nLatentVectors=par.PLSnLatentVectors;
    kernelSize=par.adaptDescriptorKernelSize;
    experts={};

   if size(trainingData,1)>par.PLSnLatentVectors

        
        intercept=ones(size(trainingData,1),1);
        
        [B,P,Q,~,T,~,INNER,~,~] = nipals_qin([trainingData intercept],trainingValues,nLatentVectors); %create the expert
        experts{end+1}= createExpert(B, P, INNER, Q);        
        
   end
    
    [ mutualPDF, mutualPDFPos ] = calculateDescriptorsBatchB( experts, trainingData, trainingValues,kernelSize );

end
    