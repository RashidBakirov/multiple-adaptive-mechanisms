function [ fin_preds ] = wm_class_prob_batch( labels, weights)
 
    
    %Make a cube of the labels that is number of labels by m by n
    labels_cube = repmat(labels, [1, size(predmatrix, 2), size(predmatrix, 1)]);
    
    %Compare the votes (streched to make surface) against a uniforma surface of each option
    B = bsxfun(@eq, permute(predmatrix, [3 2 1]) ,labels_cube);
    %Find a weighted sum
    W = squeeze(sum(bsxfun(@times, repmat(weights, size(labels,1), 1), B), 2))';
    %Find the options with the highest weighted sum
    [xx, i] = max(W, [], 2);
    fin_preds=labels(i); 
