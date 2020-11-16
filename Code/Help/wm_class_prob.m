function [ fin_preds ] = wm_class_prob( labels, weights)
    %Probabilistic weighted voting for classification
    
    %weights=repmat(weights, size(labels,1), 1);
    W_cdf = cumsum(weights);
    x = rand;
    C = x<W_cdf;
    idx = [C(1) xor(C(2:end),C(1:end-1))];
    fin_preds=sum(labels.*idx, 2);
    
end