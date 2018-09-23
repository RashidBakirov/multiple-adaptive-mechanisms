function [ expertsNew] = adaptUpdateRPLSseparate1( experts, X, Y, numLV,decayFactor )
%ADAPTUPDATE Summary of this function goes here
%   the first level of adaptation - updating the experts with new data
%   here the RPLS update

%   WARNING: The PDFs must be recalculated as the T is changed. here they
%   are recalculated form the old PDF data,(NOT updated)
for iEx=1:length(experts)
    
    %check whether the number unique rows in the dataset is enough to solve
    %the linear equation
    if size(unique(X{iEx},'rows'),1)>numLV
        
        intercept=ones(size(X{iEx},1),1);
    
        [B1,P1,Q1,W1,T1,INNER1,Xres1,Yres1,lv] = nipalsRPLS_qin([X{iEx} intercept],Y{iEx},1e-6,numLV);

        combData=[P1';decayFactor*experts{iEx}.P'];
        combVal=[diag(INNER1)*Q1';decayFactor*diag(experts{iEx}.INNER)*experts{iEx}.Q'];
             
        [Bn,Pn,Qn,~,~,INNERn,~,~,~] = nipalsRPLS_qin(combData,combVal,1e-6,numLV); %update B matrix used to calculate predictions.

        expertsNew{iEx}= createExpert(Bn, Pn, INNERn, Qn);
        
    else
        expertsNew{iEx}=experts{iEx};
    end
   
end    


