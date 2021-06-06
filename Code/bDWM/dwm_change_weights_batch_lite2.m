function[new_ensemble] = dwm_change_weights_batch_lite2(ensemble)

%using the accuracy of the exert on the batch instead of beta to update the
%weight update according to herbster 1998
%lite version - no deletion of experts

new_ensemble=ensemble;
[~, ens_size] =size(new_ensemble);

for j=1:ens_size
    new_ensemble{j}.weight=new_ensemble{j}.weight*exp(-(1-new_ensemble{j}.correct)); %weight update according to herbster 1998
end

%maxW= max(cellfun(@max,new_ensemble{:}.weight)); %max weight
u=[new_ensemble{:}];
maxW= max([u.weight]); %max weight
scale=1/maxW;


for j=1:ens_size
    new_ensemble{j}.weight=new_ensemble{j}.weight*scale; %normalizing the weights
end
