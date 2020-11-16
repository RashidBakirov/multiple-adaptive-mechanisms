
function runSABLE( batchSize, numSettings, numLV, datasetIdentifier)

%run SABLE experiments (Consult SABLE.sh to see which
%parameters were used for different datasets)
%arguments:
%batchSize - size of the batch
%numSettings - the hyperparameter set used. 
%numLV - number of latent vectors for RPLS
%datasetIdentifier - identifier of the dataset.


    addpath(genpath('/Code'));
    warning ('off','all');	
    load 'data/regressiondata.mat';
    
    batchSize=str2double(batchSize);
    numLV=str2double(numLV);
    datasetIdentifier=str2double(datasetIdentifier);
    numSettings=str2double(numSettings);

    %global parameters defined with defineParameters()
    global par;
       
    if datasetIdentifier==1
        data=dataCat;
        val=valCat;
    elseif datasetIdentifier==2
        data=dataOxidizer;
        val=valOxidizer;
    elseif datasetIdentifier==3
        data=data2Drier;
        val=valDrier;
    elseif datasetIdentifier==4
        data=dataDeb;
        val=valDeb;
    elseif datasetIdentifier==5
        data=dataSulf;
        val=valSulf;
    end

    defineParametersGeneral(numLV)
    
    par.descDecay=settingsFlat{numSettings}{1};
    par.meshgridSize=100;
    par.adaptDescriptorKernelSize=settingsFlat{numSettings}{4};   
    par.forgetFactor=0;
    
    [ avg_errorRT, predictionsRT, ~, ~, ~, ~, ~, mseValRT, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, 2 )
    
    par.forgetFactor=settingsFlat{numSettings}{2}; %then set it to the value spedified in "settings"
    
    [ avg_errorOpt, predictionsOpt, ~, ~, ~, ~, adaptationsOpt,~, ~,~, mseValOpt, ~, ~ ] = processStreamAsBatchComparison2Simple43( [], [], [], data, val, batchSize, 0)   
    [ avg_error0, predictions0, ~, ~, ~, ~, ~, mseVal0, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, 0 )
    [ avg_error1, predictions1, ~, ~, ~, ~, ~, mseVal1, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, 1  )
    [ avg_error2, predictions2, ~, ~, ~, ~, ~, mseVal2, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, 2 )
    [ avg_error4, predictions4, ~, ~, ~, ~, ~, mseVal4, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, 4  )
    [ avg_errorJoint, predictionsJoint, ~, ~, ~, ~, ~, mseValJoint, ~, ~ ] = processStreamAsBatchFixedAMSimple( [], [], [], data, val, batchSize, [2 4]  )
    [ avg_errorXV, predictionsXV, ~, ~, ~, ~, adaptationsXV, ~, ~, mseValXV, ~, ~ ] = processStreamAsBatchComparisonXVSimpleNew( [], [], [], data, val, batchSize, [], 0)
    
    
    [ avg_error0r, predictions0r, ~, mseVal0r, ~, ~, deployed0, retained0 ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, 0);
    [ avg_error1r, predictions1r, ~, mseVal1r, ~, ~, deployed1, retained1 ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, 1);    
    [ avg_error2r, predictions2r, ~, mseVal2r, ~, ~, deployed2, retained2 ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, 2);    
    [ avg_error3r, predictions3r, ~, mseVal3r, ~, ~, deployed3, retained3 ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, 3);    
    [ avg_error4r, predictions4r, ~, mseVal4r, ~, ~, deployed4, retained4 ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, 4);    
    [ avg_errorJointr, predictionsJointr, ~, mseValJointr, ~, ~, deployedJoint, retainedJoint ] = processStreamXVSimpleReturnNstepTreeFixed( [], [], [], data, val, batchSize, 1, [2 4]);    
    [ avg_errorXVr, predictionsXVr, ~, mseValXVr, ~, ~, deployedXV, retainedXV ] = processStreamXVSimpleReturnNstepTreeXV( [], [], [], data, val, batchSize, 1);  
    
    save ([num2str(datasetIdentifier) '_' num2str(batchSize) '_ResultsWithReturnAll.mat']);
    
    
  
    
resTable=[[avg_error0;avg_error1;avg_error2;avg_error4;avg_errorJoint;avg_errorRT
;avg_error0r;avg_error1r;avg_error2r;avg_error3r;avg_error4r;avg_errorJointr;avg_errorXV...
;avg_errorXVr...
;avg_errorOpt]...
[mseVal0;mseVal1;mseVal2;mseVal4;mseValJoint;mseValRT;
;mseVal0r;mseVal1r;mseVal2r;mseVal3r;mseVal4r;mseValJointr;mseValXV...
;mseValXVr...
;mseValOpt...
]];

save (['results/' num2str(datasetIdentifier) '_' num2str(batchSize) '_ResultsWithReturnAll.mat']);
exit;