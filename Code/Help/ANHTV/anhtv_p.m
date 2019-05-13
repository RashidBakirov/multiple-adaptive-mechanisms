function [p] = anhtv_p(r,c,t)
%ANHTV_P ANH.TV experts weight update
%   Detailed explanation goes here
p=0;    
for tau=1:t
    p=p+anhtv_weight(sum(r(tau:t)), sum(c(tau:t)))/tau^2;
end
        
end

