function mesh = generateMesh( min, max, meshSize )
%GENERATEMESH Summary of this function goes here
%   generate 1D Mesh

%newMin=min-(max-min)/10; %add 10% of distance
%newMax=max+(max-min)/10; %add 10% of distance

%step=(newMax-newMin)/99;   

%mesh=newMin:step:newMax; 

mesh=min:(max-min)/(meshSize-1):max; 

