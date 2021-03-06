function[new_ensemble] = dwm_retrain_weka(ensemble,dsk)

    new_ensemble=ensemble;
    [~, ens_size] =size(new_ensemble);

    for j=1:ens_size
            classifier = copy(new_ensemble{j}.model);
           
            for i=1:size(dsk)
                inst = dsk.instance(i-1);
                try
                    classifier.updateClassifier(inst);
                catch e
                    %fprintf(2,'Error! The identifier was:\n%s',e.identifier);
                    fprintf('Error!');
                end
                %i
            end

%            w_data = matlab2weka('w_data', [], dsn);
%            w_data = wekaNumericToNominal( w_data, 'last');
%            classifier = trainWekaClassifier(w_data,'bayes.NaiveBayes',{''});

            new_ensemble{j}.model = classifier;
    end