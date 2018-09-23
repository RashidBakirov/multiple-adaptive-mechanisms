function [ avg_error, predictions, errors, mseVal, mapeVal, maseVal, deployedAMSeq, retainedAMSeq ] = processStreamXVSimpleReturnNstepTreeXV( experts, mutualPDF, mutualPDFPos, data, val, batchSize, nSteps)
%PROCESSSTREAM AM^n starting points, AM models for XV check
    %global parameters defined with defineParameters()
    global par;
    
    numBatches=floor(length(val)/batchSize);
    predictions={};
    errors={};
    deployedAMSeq=[];
    retainedAMSeq=nan(1, nSteps);
       
    %first check if the initial expert set is empty, if it is, create one
    %from the first batch of data.
    if (isempty(experts) || isempty(mutualPDF) || isempty(mutualPDFPos))
        [ currentModel.experts, currentModel.mutualPDF, currentModel.mutualPDFPos] = generateExpertSimple( data(1:batchSize,:), val(1:batchSize));     
        startBatch=2;
    else
        currentModel.experts=experts;
        currentModel.mutualPDF=mutualPDF;
        currentModel.mutualPDFPos=mutualPDFPos;
        startBatch=1;
    end
    currentModel.AM=NaN;
    modelsTree=tree(currentModel);
    minApostAM=NaN;
    
%     simpleExpert=experts;   

  
    for iBatch=startBatch:numBatches
        %iBatch
        if iBatch==6
           iBatch 
        end
       
        if iBatch*batchSize<=length(val)
            dataBatch=data(1+(iBatch-1)*batchSize:iBatch*batchSize,:);
            valBatch=val(1+(iBatch-1)*batchSize:iBatch*batchSize);
        else
            dataBatch=data(1+(iBatch-1)*batchSize:end,:);
            valBatch=val(1+(iBatch-1)*batchSize:end);
        end
       
        
      
        %predict on a batch
        [ preds, expPreds, weights  ] = calculatePredictionsB( currentModel.experts, currentModel.mutualPDF, currentModel.mutualPDFPos,...
                                                            dataBatch,par.PLSnLatentVectors);
        predictions{iBatch}=preds; 
        err=valBatch-preds;        
        errors{end+1}=err; %save the errors
        
        meanError=mean(abs(err));
      
        %Return part - set the experts to the option which would have been
        %most accurate - by deleting the other part of the models tree
        if iBatch>startBatch                    
            iterator = modelsTree.nodeorderiterator;
            minError=Inf;
            minApostIdx=0;
            minApostAM=NaN;
            %iterate through the model tree 
            disp(['Batch ', num2str(iBatch), ', checking aposteriori errors']);
            for i = iterator
                %only check leaf nodes
                if modelsTree.isleaf(i)==1
                    model=modelsTree.get(i);
                    [model.aposterioriMeanError, ~, ~, ~] = predictAndGetErrors( model.experts, model.mutualPDF, model.mutualPDFPos, dataBatch, valBatch, par.PLSnLatentVectors );
                    modelsTree = modelsTree.set(i,model);
                    path=modelsTree.getparent(i);
                    pathString=[];
                    while path>0                       
                        pathString = [num2str(modelsTree.get(path).AM) pathString];
                        path=modelsTree.getparent(path);
                    end
                    disp([pathString num2str(model.AM) ' ' num2str(model.aposterioriMeanError)]);
                    if model.aposterioriMeanError<minError
                        minError=model.aposterioriMeanError;
                        minApostIdx=i;
                        minApostAM=model.AM;
                    end
                end            
            end
        
  
            %create a subtree from the model tree where the winner node was
            %located
            seq=NaN(1, max([nSteps, 1]));
%             seq(end)=modelsTree.get(minApostIdx).AM;
%             subTreeParent=minApostIdx;
%             %get the sequence
%             seq=NaN(1, nSteps);
%             seq(end)=minApostAM;
%             path=modelsTree.getparent(minApostIdx);
%             q=0;
%             while path>0
%                 q=q+1;
%                 seq(end-q) = modelsTree.get(path).AM;
%                 path=modelsTree.getparent(path);
%             end
%             retainedAMSeq=[retainedAMSeq;seq];
          
            seq(end)=minApostAM;
            subTreeParent=minApostIdx;
            
            iterations=min(iBatch-nSteps, nSteps-1);
            for j=1:iterations 
                subTreeParent=modelsTree.getparent(subTreeParent);
                seq(end-j)=modelsTree.get(subTreeParent).AM;
            end

            retainedAMSeq=[retainedAMSeq;seq];
            disp(['Batch ', num2str(iBatch), ', Retained chain ', num2str(seq)]);
            if iBatch>nSteps-1+startBatch
                modelsTree=modelsTree.subtree(subTreeParent);
            end

        end

        %now adapt all of the leaves of the new tree with all posible AMs
        %and create new leaves
        %compare crossvalidation errors
        iterator = modelsTree.nodeorderiterator;
        minError=Inf;
        minIdx=0;
        %iterate through the model tree
        disp(['Batch ', num2str(iBatch), ', checking apriori errors']);
        for i = iterator
            %only for leaf nodes
            if modelsTree.isleaf(i)==1
                model=modelsTree.get(i);
                
                %get the sequence
                seq=NaN(1, max([nSteps 1]));
                seq(end)=model.AM;
                path=modelsTree.getparent(i);
                q=0;
                while path>0
                    q=q+1;
                    seq(end-q) = modelsTree.get(path).AM;
                    path=modelsTree.getparent(path);
                end
                
                experts=model.experts;
                mutualPDF=model.mutualPDF;
                mutualPDFPos=model.mutualPDFPos;
                
                %0-th adaptation do nothing
                adaptedModel=model;
                adaptedModel.AM=0;
                [modelsTree, idx] = modelsTree.addnode(i, adaptedModel);
                if isequaln(seq,retainedAMSeq(end,:)) || isequaln(retainedAMSeq, nan(1, nSteps))
                    adaptedModel.aprioriMeanError=predictAndGetErrors( experts, mutualPDF, mutualPDFPos, dataBatch, valBatch, par.PLSnLatentVectors );
                    if adaptedModel.aprioriMeanError<minError
                       minError=adaptedModel.aprioriMeanError;
                       minIdx=idx;
                    end 
                    disp([ num2str(seq) ' + 0 ' num2str(adaptedModel.aprioriMeanError)]);
                end
                            
                %first and second candidate of adaptation - native (RPLS) adaptation (with and without forgetting) ;
                %here a data instance will only be used for updating only one
                %expert  - the one which gave the most accurate prediction on it
                %small forgetting factor is also used.
                adaptedModel.mutualPDF=mutualPDF;
                adaptedModel.mutualPDFPos=mutualPDFPos;

                [ experts1, experts2 ] = updateExperts( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, par.forgetFactor );   
                adaptedModel.experts=experts1;                      
                %get apriori errors using XV
                adaptedModel.AM=1;
                [modelsTree, idx] = modelsTree.addnode(i, adaptedModel);
                
                if isequaln(seq,retainedAMSeq(end,:)) || isequaln(retainedAMSeq, nan(1, nSteps))
                    adaptedModel.aprioriMeanError=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                                par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                                par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 1, 10  );
                    if adaptedModel.aprioriMeanError<minError
                       minError=adaptedModel.aprioriMeanError;
                       minIdx=idx;
                    end 
                    disp([ num2str(seq) ' + 1 ' num2str(adaptedModel.aprioriMeanError)]);
                end
                
                adaptedModel.experts=experts2;

                adaptedModel.AM=2;
                [modelsTree, idx] = modelsTree.addnode(i, adaptedModel);
                if isequaln(seq,retainedAMSeq(end,:)) || isequaln(retainedAMSeq, nan(1, nSteps))
                    adaptedModel.aprioriMeanError=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                                par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                                par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 2, 10  );                
                    if adaptedModel.aprioriMeanError<minError
                       minError=adaptedModel.aprioriMeanError;
                       minIdx=idx;
                    end
                    disp([ num2str(seq) ' + 2 ' num2str(adaptedModel.aprioriMeanError)]);
                end
            
                %third candidate - adapt weights
                %adapt weights only if there are more than one expert is
                %present, otherwise go to the next adaptation step
                [adaptedModel.mutualPDF, adaptedModel.mutualPDFPos ]  = updateDescriptorsBatchB( experts, dataBatch, valBatch, mutualPDF,mutualPDFPos,  par.adaptDescriptorKernelSize );      
                adaptedModel.experts=experts;
            
                adaptedModel.AM=3;
                [modelsTree, idx] = modelsTree.addnode(i, adaptedModel);
                
                if isequaln(seq,retainedAMSeq(end,:)) || isequaln(retainedAMSeq, nan(1, nSteps))
                    adaptedModel.aprioriMeanError=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                                par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                                par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 3, 10  );                 
                    if adaptedModel.aprioriMeanError<minError
                       minError=adaptedModel.aprioriMeanError;
                       minIdx=idx;
                    end 
                    disp([ num2str(seq) ' + 3 ' num2str(adaptedModel.aprioriMeanError)]);
                end

                %fourth candidate - create new experts from the batch
                [ adaptedModel.experts, adaptedModel.mutualPDF, adaptedModel.mutualPDFPos ] = generateExpertsAndPruneSimple( experts, mutualPDF, mutualPDFPos, ...
                                                                        dataBatch, valBatch, par.adaptPruneFlag, ...
                                                                        par.adaptPruneDiversityThreshold,par.PLSnLatentVectors, par.adaptDescriptorKernelSize );

                [adaptedModel.mutualPDF, adaptedModel.mutualPDFPos ]  = updateDescriptorsBatchB( adaptedModel.experts, dataBatch, valBatch,adaptedModel.mutualPDF, adaptedModel.mutualPDFPos,  par.adaptDescriptorKernelSize );      
               
                adaptedModel.AM=4;
                [modelsTree, idx] = modelsTree.addnode(i, adaptedModel);
                if isequaln(seq,retainedAMSeq(end,:)) || isequaln(retainedAMSeq, nan(1, nSteps))
                    adaptedModel.aprioriMeanError=crossvalidateAMSimple43( experts, mutualPDF, mutualPDFPos, valBatch, dataBatch, par.PLSnLatentVectors, ...
                                                par.adaptDescriptorKernelSize, par.adaptPruneFlag, ...
                                                par.adaptPruneDiversityThreshold, par.adaptDescriptorKernelSize, par.forgetFactor, 4, 10  );                 
                    if adaptedModel.aprioriMeanError<minError
                       minError=adaptedModel.aprioriMeanError;
                       minIdx=idx;
                    end 
                    disp([ num2str(seq) ' + 4 ' num2str(adaptedModel.aprioriMeanError)]);
                end
            end
        end

        currentModel=modelsTree.get(minIdx);
        
        % record the deployed path    
        seq=[retainedAMSeq(end,:), currentModel.AM];
        deployedAMSeq=[deployedAMSeq;seq];
        disp(['Batch ', num2str(iBatch), ', Deployment chain ', num2str(seq)]); 

%         allErrors=vertcat(errors{:});
%         
%         allpreds=vertcat(predictions{:});
        
%         plot(1:length(allpreds),val(1:length(allpreds)),1:length(allpreds),allpreds,1:length(allpreds),simpleallpreds,':');       
%         drawnow; 
%         
%         disp(['Algorithm accuracy ', num2str(iBatch),' : ', num2str(mean(abs(allErrors)))]);
%         disp(['Simple accuracy ', num2str(iBatch),' : ', num2str(mean(abs(simpleallErrors)))]);
        
    end
      
    
    avg_error=mean(abs(vertcat(errors{:})));
    %figure;
   % plot(2:numBatches,cellfun(@mean,cellfun(@abs,errors,'UniformOutput',false)),1:numBatches, adaptations);
    
    preds=vertcat(predictions{:});
    if startBatch==2
        mseVal=mse(val(batchSize+1:batchSize+length(preds)),preds);
        mapeVal=mape(val(batchSize+1:batchSize+length(preds)),preds);
        maseVal=mase(val(batchSize+1:batchSize+length(preds)),preds);
    else
        mseVal=mse(val(1:length(preds)),preds);
        mapeVal=mape(val(1:length(preds)),preds);
        maseVal=mase(val(1:length(preds)),preds);

end

