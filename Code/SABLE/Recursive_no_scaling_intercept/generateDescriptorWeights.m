function [ descriptorWeights ] = generateDescriptorWeights( experts, expertsData )
%   get wights for every instance of every expert's training data

 
    for i=1:length(experts)
          intercept=ones(size(expertsData{i}{1}{1},1),1);
          Y_pred=[expertsData{i}{1}{1} intercept]*experts{i}.B(end,:)'; %calculate predictions of the expert on its training data
          descriptorWeights{i}=exp(-(Y_pred-expertsData{i}{3}{1}).^2);    
          %descriptorWeights{i}=descriptorWeights{i}/sum(descriptorWeights{i});
    end
end

