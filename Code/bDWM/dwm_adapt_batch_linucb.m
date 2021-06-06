function[new_ensemble] = dwm_adapt_batch_linucb(ensemble,dsk,classifier,i)

new_ensemble=ensemble; %if i==4

if i==2
    new_ensemble=dwm_retrain(ensemble,dsk,classifier);
elseif i==5
    new_ensemble=dwm_change_weights_batch(ensemble); 
elseif i==1
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain(new_ensemble,dsk,classifier);   
elseif i==4
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_add_expert(new_ensemble,dsk,classifier);
elseif i==3
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain(new_ensemble,dsk,classifier);
    new_ensemble=dwm_add_expert(new_ensemble,dsk,classifier);
end
