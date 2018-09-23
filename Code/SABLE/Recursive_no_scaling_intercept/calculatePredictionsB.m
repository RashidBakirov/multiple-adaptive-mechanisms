function [ finalPredictions, expertsPredictions, expWeights ] = calculatePredictionsB( experts, mutualPDF, mutualPDFPos, X, nLatentVectors )
%CALCULATEEXPERTWEIGHT Summary of this function goes here
%   calculate expert expWeights for the given sample

n_Data=size(X,1);

weights={};
expWeights=ones(n_Data,size(experts,2));

n_Ex=size(experts,2);


for iEx=1:n_Ex
    
    %iX=transform(X,experts{iEx}.muX,experts{iEx}.sigmaX); %scale the input data according to the expert's saved muX and sigmaX

    %intercept=ones(size(X,1),1)/sqrt(size(X,1)-1);
    intercept=ones(size(X,1),1);
    
    Y_pred{iEx}=[X intercept]*experts{iEx}.B(end,:)'; %calculate predictions of the expert on the current sample
    %Y_pred{iEx}=pred
    %then, latent vectors matrix needs to be calculated
    T=[X intercept]*pinv(experts{iEx}.P)';
    
    %ORIGINAL: featRangeOutput=mutualPDFPos{iEx}{1}(1:size(mutualPDF{iEx}{1},1),2); %target mesh 1D 
    
    weights{iEx}=[];
    
    for iFeat=1:nLatentVectors
        %ORIGINAL: featRangeInput=mutualPDFPos{iEx}{iFeat}(1:size(mutualPDF{iEx}{iFeat},2),1); %feature values mesh 1D 
        featRangeOutput=mutualPDFPos{iEx}{iFeat}(1:size(mutualPDF{iEx}{iFeat},2),2);
        featRangeInput=mutualPDFPos{iEx}{iFeat}(1:size(mutualPDF{iEx}{iFeat},1),1); 
       [gridX, gridY] = meshgrid(featRangeInput,featRangeOutput); %here 2D meshgrid is constructed
        %[gridY, gridX] = meshgrid(featRangeOutput,featRangeInput); %here 2D meshgrid is constructed
        
        %total weight of the expert is the product of all feature expWeights
        %which will be later divided by the sum of expWeights of all experts
        %(normalization)
%iEx
% iFeat
        %interpolating the weight of the feature using the calculated
        %meshgrid.
        %Scattered interpolant not used atm cause too slow and
        %extrapolation bring negative values = instead interp2 and own
        %extrapolation procedure
        %F=scatteredInterpolant(reshape(gridX,size(gridX,1)*size(gridX,2),1),reshape(gridY,size(gridY,1)*size(gridY,2),1),reshape(mutualPDF{iEx}{iFeat}',size(mutualPDF{iEx}{iFeat}',1)*size(mutualPDF{iEx}{iFeat}',2),1));
        %feature_weight=F(T(:,iFeat), Y_pred{iEx});
        
        [minDif, minDifIndex]=nearestDistanceExtrapolate(T(:,iFeat),Y_pred{iEx},gridX,gridY,mutualPDF{iEx}{iFeat}');
        
        feature_weight=interp2(gridX, gridY, mutualPDF{iEx}{iFeat}', T(:,iFeat), Y_pred{iEx},'nearest');      
        
        if sum(isnan(feature_weight))>0  %if there is at least one NaN, meaning outisde of descriptors range
             minDif=minDif/min(minDif(isnan(feature_weight)));   %normalizing -> nan value with the least distance to the descriptor gets 1      
             mPDF=reshape(mutualPDF{iEx}{iFeat}',size(mutualPDF{iEx}{iFeat}',1)*size(mutualPDF{iEx}{iFeat}',2),1); % flatten the pdf
             extrapVals=mPDF(minDifIndex)'./minDif; %selecting the values which are the closest in the descriptor, and dividing them by the appropriate distances      
             feature_weight(isnan(feature_weight))=extrapVals(isnan(feature_weight));
        end
        
        %save weights in the matrix
        weights{iEx}=[weights{iEx} feature_weight];        
    end 
end



%here the final weights for matrices are identified
    allWeights=cat(3,weights{:});
    
    %divide allWeights by the mean along the second+third dimension to avoid too
    %low numbers which converge to 0

    u=mean(mean(allWeights,2),3);
    u=repmat(u,[1 nLatentVectors n_Ex]);
    allWeights=allWeights./u;
    
    expWeights=prod(allWeights,2);
    expWeights=reshape(expWeights,size(expWeights,1),size(expWeights,3),1);



%calculate the sum of Weights
sum_expWeights=sum(expWeights,2);

sum_expWeights=repmat(sum_expWeights,1,n_Ex);

expWeights=expWeights./sum_expWeights; %final Weights for experts

weightsForNan=zeros(size(expWeights,1),size(expWeights,2)); %dummy matrix to replace NaN weights
weightsForNan(:,end)=ones(size(expWeights,1),1);

expWeights(isnan(expWeights))=weightsForNan(isnan(expWeights));


expertsPredictions=[Y_pred{:}]; %predictions of every expert in a vector

finalPredictions=sum(expertsPredictions.*expWeights,2); %final predictions

end

