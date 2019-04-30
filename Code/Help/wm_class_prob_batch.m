function [ fin_preds ] = wm_class_prob_batch( labels, weights)
    %Probabilistic weighted voting for classification
    
    weights=repmat(weights, size(labels,1), 1);
    W_cdf = cumsum(weights,2);
    x = rand(1,size(weights,1));
    C = repmat(x,size(weights,2),1)'<W_cdf;
    idx = [C(:,1) xor(C(:,2:end),C(:,1:end-1))];
    fin_preds=sum(labels.*idx, 2);
    
end