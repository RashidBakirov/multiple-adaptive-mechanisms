function [ experts, mutualPDFs, mutualPDFPos, correlationFound ] =mergeExperts2BPDF( experts, mutualPDFs, mutualPDFPos, data, t_div )
%mergeEXPERTS 
%   find similar experts based on the similarity of their predictions (and
%   not weights as in the original proposal)
    correlationFound=0;
    tTestMatrix=zeros(length(experts));
    n_Ex=length(experts);
    

    for iEx=1:n_Ex
        intercept=ones(size(data,1),1);
        Y_pred{iEx}=[data intercept]*experts{iEx}.B(end,:)'; %calculate predictions of the expert on the current sample
    end
    
    expertsPredictions=[Y_pred{:}]; %predictions of every expert in a vector
    
        %find correlated sets of weights
    for kEx=1:size(expertsPredictions,2) 
        for iEx=1:size(expertsPredictions,2) 
              if (kEx~=iEx)
                [tt,p]=ttest(expertsPredictions(:,kEx),expertsPredictions(:,iEx));
                tTestMatrix(kEx,iEx)=p; 
              end
        end
    end
    tTestMatrix(isnan(tTestMatrix))=1;
   
    maxCor=max(max(tTestMatrix));
    [corX,corY]=find(tTestMatrix==maxCor);
    
    if (maxCor>t_div) %two correlated experts found, start merging
        correlationFound=1;       
        
        %[B,P,Q,~,~,INNER,~,~,~] = nipalsRPLS_qin(combData,combVal,1e-6,nLatentVectors); %create the new expert from merged data expert              
        %newExpert{1}= createExpert(B, P, INNER, Q);
        newExpert{1}=experts{max([corX(1) corY(1)])};
         
         [ newmutualPDF, newmutualPDFPos ] = mergePDFs2(mutualPDFs{corX(1)},mutualPDFPos{corX(1)},mutualPDFs{corY(1)},mutualPDFPos{corY(1)} );
         
         %disp(['Two correlated experts merged, new pool size: ' num2str(length(experts))]);
            
         experts([corX(1),corY(1)])=[]; %delete expert, descriptor and weights
         mutualPDFs([corX(1),corY(1)])=[];
         mutualPDFPos([corX(1),corY(1)])=[];
         
         experts=[experts, newExpert];
         mutualPDFs=[mutualPDFs,{newmutualPDF}];
         mutualPDFPos=[mutualPDFPos,{newmutualPDFPos}];
    end 
end

