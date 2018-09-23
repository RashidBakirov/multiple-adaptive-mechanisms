function [ mutualPDF, mutualPDFPos ] = buildDescriptorsSimpleB( experts, data, kernelSize, oldMutualPDF, oldMutualPDFPos)
%BUILDDESCRIPTORS Summary of this function goes here
%   build pdfs for every input feature for  all experts
%   these pdfs are essentially a meshgrid of of feature value/target value
%   pairs
%   if existingPDFpos not empty, use the existing meshgrid to build on.

global par;

descriptorWeights = generateDescriptorWeights( experts, data );%generate training data weights for the descriptor


oldTargetMesh=[];

%get old(existing) target mesh
if ~isempty(oldMutualPDFPos)            
     oldTargetMesh=oldMutualPDFPos{1}(1:size(oldMutualPDF{1},2),2);       
end

%calculate mesh for the target value
targetMin=min(data{1}{3}{1});
targetMax=max(data{1}{3}{1});

stdY=std(data{1}{3}{1});

%check if min of feature equals to max of feature - if yes set some
%default values to generate grid
if (targetMin==targetMax)
    targetMin=targetMin-1;
    targetMax=targetMax+1;
end
% new target mesh
newTargetMesh=generateMesh(targetMin, targetMax, par.meshgridSize);

%merge and sort old and new target meshes
targetMesh=combineMeshes( oldTargetMesh', newTargetMesh, par.meshgridSize );


for iEx=1:length(experts)
    n_Features=size(data{iEx}{2}{1},2); %number of input features (latent vectors)
    meshes=[];
    
    for iFeat=1:n_Features
        
        oldFeatureMesh=[];
        %get old(existing) feature mesh
        if ~isempty(oldMutualPDFPos)           
             oldFeatureMesh=oldMutualPDFPos{iFeat}(1:size(oldMutualPDF{iFeat},1),1);       
        end

        featMin=min(data{iEx}{2}{1}(:,iFeat));
        featMax=max(data{iEx}{2}{1}(:,iFeat));
        
        stdX(iFeat)=std(data{iEx}{2}{1}(:,iFeat));

        %check if min of feature equals to max of feature - if yes set some
        %default values to generate grid
        if (featMin==featMax)
            featMin=featMin-1;
            featMax=featMax+1;
        end
        
        newFeatureMesh=generateMesh(featMin, featMax, par.meshgridSize);

        featureMesh=combineMeshes(oldFeatureMesh', newFeatureMesh, par.meshgridSize );

        mutualPDFPos{iEx}{iFeat}=-1000*ones(max(length(targetMesh),length(featureMesh)),2);
        mutualPDFPos{iEx}{iFeat}(1:length(featureMesh),1)=featureMesh;
        mutualPDFPos{iEx}{iFeat}(1:length(targetMesh),2)=targetMesh;
        
        meshes=[meshes featureMesh'];
    end
        
        allPDFs=calcParzenWindow2DWeighted([data{iEx}{2}{1}, data{iEx}{3}{1}] , ...
            [kernelSize,kernelSize], meshes, targetMesh,stdX,stdY, 0,descriptorWeights{iEx}); 
    for iFeat=1:n_Features
        mutualPDF{iEx}{iFeat}=allPDFs(:,:,1,iFeat);
    end
        %mutualPDF{iEx}{iFeat}=mutualPDF{iEx}{iFeat}-(min(mutualPDF{iEx}{iFeat}(:)));
        %ORIGINAL: mutualPDF{iEx}{iFeat}=mutualPDF{iEx}{iFeat}./(sum(mutualPDF{iEx}{iFeat}(:)))+1e-1;
        %mutualPDF{iEx}{iFeat}=mutualPDF{iEx}{iFeat}./(sum(mutualPDF{iEx}{iFeat}(:)));
    
    
end
