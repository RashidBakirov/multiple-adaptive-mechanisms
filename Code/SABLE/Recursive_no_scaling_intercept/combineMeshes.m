function [ combinedMesh ] = combineMeshes( oldMesh, newMesh, meshSize )
%COMBINEMESHES combine the old and new meshes

combinedMesh=sort([oldMesh newMesh]);
combinedMesh=unique(combinedMesh);

%if |combinedMesh|>k*meshSize prune it uniformly
reducingFactor=max([floor(length(combinedMesh)/meshSize) 1]); %reducing factors will be either one, or if dimesinons are larger than 200, then dimsize mod 200
combinedMesh=combinedMesh(1:reducingFactor:length(combinedMesh));

%if |combinedMesh|>meshSize additional NON random pruning to bring it to the
%same size

if length(combinedMesh)>meshSize
    reducingFactor=length(combinedMesh)/(length(combinedMesh)-meshSize);
    indicesToRemove=round(reducingFactor:reducingFactor:length(combinedMesh));
    combinedMesh(indicesToRemove)=[];
end

end


