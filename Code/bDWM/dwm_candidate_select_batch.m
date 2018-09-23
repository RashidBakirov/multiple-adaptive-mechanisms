function[selected_ensemble, max_ind] = dwm_candidate_select_batch(ensemble)

preds_comparison=zeros(1,8);
for i=1:8
    current_ensemble=ensemble{i};
    [~, ens_size] =size(current_ensemble);

    sum_weights=0;   
    for j=1:ens_size
        preds_comparison(i)=preds_comparison(i)+current_ensemble{j}.weight*current_ensemble{j}.correct;
        sum_weights=sum_weights+current_ensemble{j}.weight;
    end       
    preds_comparison(i)=preds_comparison(i)/sum_weights;   
end


%preds_comparison
[maxval,max_ind] =max(preds_comparison);
if max_ind==1 & preds_comparison(1)==preds_comparison(2) %if the choice of not retraining and retraining are equal, choose retraining
          max_ind = 2;    
end

selected_ensemble=ensemble{max_ind};

% if prediction_correct>=threshold
%     if max_ind==1 & preds_comparison(1)==preds_comparison(5) %choose 5 if value of ensemble's 1 and 5 are equal
%         max_ind = 5;
%     elseif max_ind==1 & preds_comparison(1)==preds_comparison(3) %choose 3 if value of ensemble's 3 and 5 are equal
%         max_ind = 3;
%     elseif max_ind==1 & preds_comparison(1)==preds_comparison(2) %choose 2 if value of ensemble's 2 and 5 are equal
%         max_ind = 2;    
%      else
%          max_ind = find(preds_comparison==maxval,1,'last');
%     end
% else

%if the comparison results are the same choose the candidate in following
%order
% if max_ind==1 & preds_comparison(1)==preds_comparison(2) %choose 2 if value of ensemble's 2 and 5 are equal
%          max_ind = 2;    
% else
% max_ind = find(preds_comparison==maxval,1,'last');
% %end
