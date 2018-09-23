function [B,P,Q,W,T,INNER,Xres,Yres,lv] = nipalsRPLS_qin(X,y,errorTol,maxLV)

% Traditional batch-wise PLS algorithm with little modification (Qin 1997)
% (orthogonal T scores -- T'*T = I)
% X dim (NxK), Y dim (NxP), N - number of samples (observations)
% B - coefficients of regression (Y = X * B(lv,:)')
% R. Grbic,  ozujak 2009.

originalX=X; %to check
originalY=y; %to check

[mx,nx] = size(X);

[my,ny] = size(y);

%B     = zeros(lv,nx);
%P     = zeros(nx,lv);
%Q     = ones(ny,lv);
%W     = zeros(nx,lv);
%T     = zeros(mx,lv);
%INNER = zeros(1,lv);

maxit = 100;
itnum = 1;

convcrit = 1e3*eps;


Xres = X;
i=0;

%while (norm(Xres,'fro')>errorTol && i<maxLV)
 while  i<maxLV
    i=i+1;
    
    if ny == 1,
        q = 1;
        u = y;
    else
        u = y(:,1);
    end
    
    told  = zeros(mx,1);
    t = ones(mx,1);
    
    while ((sum(abs(told-t))) > convcrit) & (itnum < maxit),
        itnum = itnum + 1;
        told = t;
        w  = (X'*u)/(u'*u);
        
        t  =  X*w;
        tnorm = sqrt(t'*t);
        t = t/tnorm;
        
        if ny > 1
            q = (y'*t)/sqrt((y'*t)'*(y'*t));
            u  = y*q;
        end
    end
    
    p = (X'*t);
   
    inner = (u'*t) / (t'*t);
    X = X - (t*p');
    y = y - inner*t*q';
    
    P(:,i) = p;
    W(:,i) = w;
    T(:,i) = t;
    Q(:,i) = q;
    INNER(:,i) = inner;
    Xres = X;
    Yres = y;     
end

lv=i;

if (ny==1)
    B  = W*inv(P'*W)*diag(INNER)*diag(Q);
    B  = cumsum(B',1);
else
    B  = W*inv(P'*W)*diag(INNER)*Q';
end
