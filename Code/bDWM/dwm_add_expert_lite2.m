function[new_ensemble] = dwm_add_expert_lite2(ensemble,dsk,classifier)


% AM3 add a new classifier if final prediction is wrong, with initial
% weight 1
% lite version where the worse performing expert is replaced by the new one

new_ensemble=ensemble;
exp=dsk*classifier;

if new_ensemble{1}.weight<new_ensemble{1}.weight
    idx_to_replace=1;
else
    idx_to_replace=2;
end

new_ensemble{idx_to_replace}.model=exp; % add one to cell array (instead of normal array) to store the objects
new_ensemble{idx_to_replace}.weight=1; % and weights
new_ensemble{idx_to_replace}.data=dsk; % and data
new_ensemble{idx_to_replace}.correct=1; % correct prediction flag on by default

