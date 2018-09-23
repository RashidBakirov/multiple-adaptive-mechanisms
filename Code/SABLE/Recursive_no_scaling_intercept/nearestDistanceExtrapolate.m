function [minDif, minDifIndex] =  nearestDistanceExtrapolate(feature,predictions,gridX,gridY,mutualPDF)

a=[feature predictions];
a=reshape(a',1,2,size(a,1));
a=repmat(a,size(gridX,1)*size(gridX,2),1,1);

b=[reshape(gridX,size(gridX,1)*size(gridX,2),1) reshape(gridY,size(gridY,1)*size(gridY,2),1)];
b=repmat(b,1,1,length(feature));
c=b-a;
c=c.^2;
c=sqrt(sum(c,2));

c=permute(c, [1 3 2]);

[minDif, minDifIndex]=min(c);
