function[selected_ensemble, max_ind] = dwm_candidate_select_batch_lite_p(ensemble)

preds_comparison=zeros(1,2);
parfor i=1:2
    preds_comparison(i)=preds_comparison(i)+ensemble{i}{1}.ensemble_accuracy;
end

%preds_comparison
[~,max_ind] =max(preds_comparison);
selected_ensemble=ensemble{max_ind};

