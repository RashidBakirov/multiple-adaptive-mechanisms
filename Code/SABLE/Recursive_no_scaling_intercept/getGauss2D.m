function Z=getGauss2D(xmu, ymu, stdX, stdY, rangeX, rangeY, weights)
%construct gaussian function using parzen window method with one pass
%through all of the features

numFeat=length(stdX);

% the covariance matrix
stdX=reshape(stdX,1,1,1,numFeat);

C = [stdX.^2  zeros(1,1,1,numFeat); zeros(1,1,1,numFeat) repmat(stdY,[1,1,1,numFeat]).^2]; 

%stdX=repmat(stdX,[length(ymu),length(ymu),length(ymu),1]);
%stdY=repmat(stdY,[1,1,1,numFeat]);



X=[];
Y=[];
for iFeat=1:numFeat
    [Xfeat, Yfeat] = meshgrid(rangeX(:,iFeat),rangeY); % matrices used for plotting
    X=cat(4, X, Xfeat);
    Y=cat(4, Y, Yfeat);
end
% Compute value of Gaussian pdf at each point in the grid

X=repmat(X,[1,1,length(xmu),1]);
Y=repmat(Y,[1,1,length(ymu),1]);
xmu=reshape(xmu,1,1,length(xmu),numFeat);
ymu=reshape(ymu,1,1,length(ymu));
ymu=repmat(ymu,[1,1,1,numFeat]);

for iFeat=1:numFeat
   mult(1,1,1,iFeat)=1/(2*pi*sqrt(det(C(:,:,:,iFeat))));
end

Z = bsxfun(@times,mult,exp(-0.5 * (bsxfun(@rdivide,(bsxfun(@minus,X,xmu).^2),stdX.^2) + bsxfun(@minus,Y,ymu).^2./stdY^2)));
Z=permute(Z, [2 1 3 4]);

weights=reshape(weights,1,1,length(weights));
weights=repmat(weights,[1,1,1,numFeat]);

Z=bsxfun(@times,Z,weights);
Z=sum(Z,3);
