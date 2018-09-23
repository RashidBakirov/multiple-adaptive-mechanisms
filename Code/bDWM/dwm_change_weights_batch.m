function[new_ensemble] = dwm_change_weights_batch(ensemble)

%using the accuracy of the exert on the batch instead of beta to update the
%weight update according to herbster 1998

new_ensemble=ensemble;
[~, ens_size] =size(new_ensemble);

for j=1:ens_size
    new_ensemble{j}.weight=new_ensemble{j}.weight*exp(-new_ensemble{j}.correct); %weight update according to herbster 1998
end

%maxW= max(cellfun(@max,new_ensemble{:}.weight)); %max weight
u=[new_ensemble{:}];
maxW= max([u.weight]); %max weight
scale=1/maxW;

to_delete = [];

for j=1:ens_size
    weight_new=new_ensemble{j}.weight*scale;
    if (weight_new<0.01)
        to_delete(end+1) = j;
        %exp_hist=[exp_hist; [size(new_ensemble{j}.data,1),0]];
    else
        new_ensemble{j}.weight=weight_new; %normalizing the weights
    end
    
end

new_ensemble(:,[to_delete])=[]; %kill em all