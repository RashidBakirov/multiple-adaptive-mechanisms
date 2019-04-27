function[selected_ensemble, max_ind] = dwm_candidate_select_batch(ensemble)

preds_comparison=zeros(1,8);
for i=1:8
    preds_comparison(i)=preds_comparison(i)+ensemble{i}{1}.ensemble_accuracy;
end

%preds_comparison
[maxval,max_ind] =max(preds_comparison);
selected_ensemble=ensemble{max_ind};

