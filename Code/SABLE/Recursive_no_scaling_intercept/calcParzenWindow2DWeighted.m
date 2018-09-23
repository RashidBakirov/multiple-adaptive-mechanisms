function [outputParzenDistr, success] = calcParzenWindow2DWeighted(samplePoints, ...
    sigma,distrRangeX,distrRangeY,stdX,stdY, kernelType,weights)
% =========================================================================
% [outputParzenDistr, success] = calcParzenWindow2DWeighted(samplePoints,sigma, ...
%    distrRangeX,distrRangeY,kernelType, weights)
%
% -------------------------------------------------------------------------
% Calculates distribution density fanction using the Parzen windows method,
% the distribution is calculated using the samplePoints vector 
%
% Possible calls: 
%   - calcParzenWindow(double[][] samplePoints, double[] sigma, ...
%        double[] distrRangeX, double[] distrRangeY, double kernelType, 
%        double[] weights)
%
% INPUT
% -----
% samplePoints: 2D sample points used to calculate the disribution [Nx2]
%               with N-number of samples
% sigma: the width of the kernel (i.e. smoothing parameter) in both
%        dimensions [sigma_x,sigma_y]
% distrRangeX: x-range of the distribution
% distrRangeY: y-range of the distribution
% kernelType: type of the kernel window- 
%             0- gaussian (default)
% weights: the weight vector of length N, must have the same length as the samplePoints
%          vector
%
% OUTPUT
% ======
% outputParzenDistr: the parzen window distribution estimation
% success: 1- if constructing successful
%          0- otherwise
% 
% (C) Petr Kadlec, 2007
% =========================================================================
% Improvement: try to do it in one pass
% (C) Rashid Bakirov, 2014

%check the input parameters
if (nargin ~= 8)
    success=0;
    outputParzenDistr=[];
    warning('Wrong number of input parameters, 7 parameter required!')
    return;
end
if (isa(samplePoints,'double')==0 || isa(sigma, 'double')==0 || isa(distrRangeX, 'double')==0  || isa(distrRangeY, 'double')==0 ...
        || isa(kernelType, 'double')==0 || isa(weights,'double')==0)
    success=0;
    outputParzenDistr=[];
    warning('Wrong type(s) of input parameters!');
    return;
end

if (size(samplePoints,2)==1)
    success=0;
    outputParzenDistr=[];
    warning('Only 1D samples supplied use calcParzenWindowWeighted!');
    return;
end

% if (size(distrRange,2)==1)
%     distrRange(:,2)=distrRange(:,1);
%     warning('Using the same range in both dimensions!');
%     return;
% end

if (size(sigma,2)==1)
    sigma(2)=sigma(1);
    warning('Using the same sigma in both dimensions!');
    %return;
end

%default kernel
if (isempty(kernelType)==1)
    kernelType=0;
end

if (kernelType~=0)
    warning('Only gaussian kernel (type 0) implemented yet!');
end

if (size(samplePoints,1) ~= length(weights))
    success=0;
    outputParzenDistr=[];
    warning('The length of the samplePoints and weights vector must be the same!');
    return;        
end

distrLengthX=length(distrRangeX);
distrLengthY=length(distrRangeY);
outputParzenDistr=zeros(distrLengthX,distrLengthY);

deltaDistrX=abs(distrRangeX(1)-distrRangeX(2));
deltaDistrY=abs(distrRangeY(1)-distrRangeY(2));
medDistrX=median(distrRangeX);
medDistrY=median(distrRangeY);

%calculation of the parzen windows
%changed: now the input arguments of variance are coefficinets of the
%maximum range of the variable
outputParzenDistr=getGauss2D(samplePoints(:,1:end-1), samplePoints(:,end), sigma(1)*stdX, sigma(2)*stdY, distrRangeX, distrRangeY, weights);


%normalisation to get density distribution
%outputParzenDistr=outputParzenDistr./(sum(outputParzenDistr));