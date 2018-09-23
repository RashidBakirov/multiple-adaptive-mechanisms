function [ fin_preds, new_ensemble ] = wm_mult_predict_batch( ensemble, data, true_labels )
%WM_PREDICT Weighted Majority Prediction for one datapoint, given an
%ensemble of experts with weights. For multiclass prediction

    new_ensemble=ensemble;
    [~, ens_size] =size(ensemble); %determine number of experts
    %dsk=dataset(data); %make a new dataset consisiting of current data
    dsk=data;
    
    %this will be matrix of n predictions by m experts
    predmatrix = zeros(size(data,1),ens_size);
    labels=[]; %this will be possible labels
       
    %for each expert get the predictions vector
    for j=1:ens_size
        %get the expert
        exp=ensemble{j}.model;   
        tst=dsk*exp; %perform classification 
        pred=labeld_rb(tst);
        new_ensemble{j}.prediction=pred;
        predmatrix(:,j)=pred; %get predicted label   
        labels=[labels;predmatrix(:,j)];
        
        if ~isempty(true_labels)
            correct_preds=new_ensemble{j}.prediction==true_labels;
            new_ensemble{j}.correct=mean(correct_preds);
        end
        
        new_ensemble{j}.ensemble_prediction=[];
        new_ensemble{j}.ensemble_accuracy=[];
        
    end
    
    labels = unique(labels);
    
    u=[new_ensemble{:}];
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
    
    new_ensemble{1}.ensemble_prediction=fin_preds;
    new_ensemble{1}.ensemble_accuracy=mean(true_labels==fin_preds);
    
end


