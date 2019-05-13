function[new_ensemble] = dwm_add_expert(ensemble,dsk,classifier)


% AM3 add a new classifier if final prediction is wrong, with initial
% weight 1

new_ensemble=ensemble;
exp=dsk*classifier ;
new_ensemble{end+1}.model=exp; % add one to cell array (instead of normal array) to store the objects
new_ensemble{end}.weight=1; % and weights
new_ensemble{end}.data=dsk; % and data
new_ensemble{end}.correct=1; % correct prediction flag on by default

