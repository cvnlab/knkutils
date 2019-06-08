function f = quantifymotionparameters(params,paramsref,matrixsize,matrixlength,wantdetrend)

% function f = quantifymotionparameters(params,paramsref,matrixsize,matrixlength,wantdetrend)
%
% <params> is N x 12 with SPM-style parameters
% <paramsref> is 1 x 12 with parameters of the reference volume
% <matrixsize> is 1 x 3 with the matrix dimensions (e.g. [64 64 36])
% <matrixlength> is 1 x 3 with the voxel size in mm (e.g. [2 2 2])
% <wantdetrend> (optional) is whether to remove a constant and line
%   from each column of <params> up front. in this case, we ignore
%   <paramsref> and use zeros(1,6) as the reference.
%   Default: 0.
% 
% compare each of the N volumes in <params> against the reference volume
% as given by <paramsref>. in each comparison, we compute the displacement
% (in mm) of each voxel and then compute the median of these displacements.
% we return <f> as 1 x N with the median voxel displacement for each volume (mm).
%
% this function converts rigid-body parameters into a more meaningful
% quantity. low values in the result (near 0) are good.
%
% we assume that the motion parameters reflect only rigid-body adjuments.

% input
if ~exist('wantdetrend','var') || isempty(wantdetrend)
  wantdetrend = 0;
end

% deal with detrending
if wantdetrend
  X = constructpolynomialmatrix(size(params,1),0:1);
  Xproj = projectionmatrix(X);
  params(:,1:6) = Xproj*params(:,1:6);
  paramsref(1:6) = 0;
end

% construct coordinates for all voxels
[xx,yy,zz] = ndgrid(1:matrixsize(1),1:matrixsize(2),1:matrixsize(3));
numvx = numel(xx);
coords = [flatten(xx); flatten(yy); flatten(zz); ones(1,numvx)];

% deal with reference
tr = spm_matrix(paramsref);
coordsref = tr*coords;

% process each volume
f = zeros(1,size(params,1));
for p=1:size(params,1)
  tr = spm_matrix(params(p,:));
  coords0 = tr*coords;
  displacements = sqrt( sum((coordsref(1:3,:)-coords0(1:3,:)).^2,1) );
  f(p) = median(displacements);
end
