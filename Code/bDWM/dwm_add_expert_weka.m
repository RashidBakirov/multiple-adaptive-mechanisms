function[new_ensemble] = dwm_add_expert_weka(ensemble,dsk,classifier,options)


% AM3 add a new classifier if final prediction is wrong, with initial
% weight 1

new_ensemble=ensemble;
[~, ens_size] =size(new_ensemble);
ens_size=ens_size+1;
%cl = trainWekaClassifier(w_data,classifier,'-L 0');
%cl = trainWekaClassifier(w_data,classifier,'-L 0 -G 20');
cl = trainWekaClassifier(dsk,classifier,options);
new_ensemble{end+1}.model=cl; % add one to cell array (instead of normal array) to store the objects
new_ensemble{end}.weight=1; % and weights
new_ensemble{end}.correct=1; % correct prediction flag on by default

