function [Phi] = anhtv_potential(R,C)
%ANHTV_POTENTIAL AdaptiveNormalHedge.TV potential function
Phi=exp(max(R,0)^2/(3*C));
end

