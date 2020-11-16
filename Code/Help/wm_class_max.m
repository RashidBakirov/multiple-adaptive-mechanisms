function [ fin_preds ] = wm_class_max( predvector, weights)
 
    
    labels = unique(predvector);   
    %Make a cube of the labels that is number of labels by m by n
    labels_cube = repmat(labels, [size(predvector, 2), 1]);  
    %Compare the votes (streched to make surface) against a uniforma surface of each option
    B = repmat(predvector', [1 size(labels_cube,2)]) == labels_cube;
    %Find a weighted sum
    W = sum(repmat(weights', [1 size(B,2)]).*B);
    %Find the options with the highest weighted sum
    [~, i] = max(W);
    fin_preds=labels(i); 
