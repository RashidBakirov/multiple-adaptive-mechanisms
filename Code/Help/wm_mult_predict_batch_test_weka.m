function [ fin_preds ] = wm_mult_predict_batch_test_weka( ensemble, data )
%WM_PREDICT Weighted Majority Prediction for one datapoint, given an
%ensemble of experts with weights. For multiclass prediction

    [~, ens_size] =size(ensemble); %determine number of experts
    %dsk=dataset(data); %make a new dataset consisiting of current data
    dsk=data;
    
    %this will be matrix of n predictions by m experts
    predmatrix = zeros(data.numInstances,ens_size);
    labels=[]; %this will be possible labels
       
    %for each expert get the predictions vector
    for j=1:ens_size
        %get the expert
        exp=ensemble{j}.model;
        [pred, ~] = wekaClassify(data,exp);
        predmatrix(:,j)=pred; %get predicted label   
        labels=[labels;predmatrix(:,j)];       
    end
    
    labels = unique(labels);
    
    u=[ensemble{:}];
    weights=[u.weight]; %create weights vector  
    
    %Make a cube of the labels that is number of labels by m by n
    labels_cube = repmat(labels, [1, size(predmatrix, 2), size(predmatrix, 1)]);
    
    %Compare the votes (streched to make surface) against a uniforma surface of each option
    B = bsxfun(@eq, permute(predmatrix, [3 2 1]) ,labels_cube);
    %Find a weighted sum
    W = squeeze(sum(bsxfun(@times, repmat(weights, size(labels,1), 1), B), 2))';
    %Find the options with the highest weighted sum
    [xx, i] = max(W, [], 2);
    fin_preds=labels(i); 

    
end


