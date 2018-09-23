function[new_ensemble] = dwm_adapt_batch(ensemble,dsk,classifier,i)

if i==0
    new_ensemble=ensemble;
elseif i==1
    new_ensemble=dwm_retrain(ensemble,dsk,classifier);
elseif i==2
    new_ensemble=dwm_change_weights_batch(ensemble); 
elseif i==3
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain(new_ensemble,dsk,classifier);   
elseif i==4
    new_ensemble=dwm_add_expert(ensemble,dsk,classifier);
elseif i==5 
    new_ensemble=dwm_retrain(ensemble,dsk,classifier);
    new_ensemble=dwm_add_expert(new_ensemble,dsk,classifier);
elseif i==6
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_add_expert(new_ensemble,dsk,classifier);
elseif i==7
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain(new_ensemble,dsk,classifier);
    new_ensemble=dwm_add_expert(new_ensemble,dsk,classifier);
end
