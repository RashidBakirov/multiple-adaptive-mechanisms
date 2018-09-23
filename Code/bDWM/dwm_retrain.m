function[new_ensemble] = dwm_retrain(ensemble,dsk,classifier)

    new_ensemble=ensemble;
    [~, ens_size] =size(new_ensemble);

    for j=1:ens_size
            dsn=[new_ensemble{j}.data; dsk]; %add new datapoint to the old dataset
            new_ensemble{j}.model=dsn*classifier; %retrain NB
            new_ensemble{j}.data=dsn; %save the new dataset
    end