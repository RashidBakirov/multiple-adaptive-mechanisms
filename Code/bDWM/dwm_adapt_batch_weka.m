function[new_ensemble] = dwm_adapt_batch_weka(ensemble,dsk,classifier,options,i)

if i==4
    new_ensemble=ensemble;
elseif i==2
    new_ensemble=dwm_retrain_weka(ensemble,dsk);
elseif i==3
    new_ensemble=dwm_change_weights_batch(ensemble); 
elseif i==1
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain_weka(new_ensemble,dsk);   
elseif i==8
    new_ensemble=dwm_add_expert_weka(ensemble,dsk,classifier,options);
elseif i==6 
    new_ensemble=dwm_retrain_weka(ensemble,dsk);
    new_ensemble=dwm_add_expert_weka(new_ensemble,dsk,classifier,options);
elseif i==7
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_add_expert_weka(new_ensemble,dsk,classifier,options);
elseif i==5
    new_ensemble=dwm_change_weights_batch(ensemble);
    new_ensemble=dwm_retrain_weka(new_ensemble,dsk);
    new_ensemble=dwm_add_expert_weka(new_ensemble,dsk,classifier,options);
end
