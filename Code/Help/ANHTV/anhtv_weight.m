function [w] = anhtv_weight(R,C)
%ANHTV_POTENTIAL AdaptiveNormalHedge.TV weight function
w=(anhtv_potential(R+1, C+1)-anhtv_potential(R-1, C+1))/2;
end

