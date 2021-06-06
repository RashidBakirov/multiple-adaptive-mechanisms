function[new_ensemble] = dwm_change_weights_batch(ensemble)

%using the accuracy of the exert on the batch instead of beta to update the
%weight update according to herbster 1998

new_ensemble=ensemble;
[~, ens_size] =size(new_ensemble);

for j=1:ens_size
    new_ensemble{j}.weight=new_ensemble{j}.weight*exp(-(1-new_ensemble{j}.correct)); %weight update according to herbster 1998
    %new_ensemble{j}.weight=new_ensemble{j}.weight*(1-(1-new_ensemble{j}.correct)*0.5);  %dwm style update
end

%maxW= max(cellfun(@max,new_ensemble{:}.weight)); %max weight
u=[new_ensemble{:}];
maxW= max([u.weight]); %max weight
scale=1/maxW;

to_delete = 1:ens_size;
num_exp=0;

for j=1:ens_size
    weight_new=new_ensemble{j}.weight*scale;
    if (weight_new>=0.01)
        to_delete(j-num_exp) = [];
        new_ensemble{j}.weight=weight_new; %normalizing the weights
        num_exp=num_exp+1;
    end  
end

new_ensemble(:,to_delete)=[]; %kill em all