function f = constructbutterfilter3D(matrixsize,cutoff,order,mode)

% function f = constructbutterfilter3D(matrixsize,cutoff,order,mode)
%
% <matrixsize> is [A B C] with the dimensions of the 3D volume
% <cutoff> is a 3-element cell vector with each element being:
%   A means low-pass filter cutoff (in cycles per field-of-view)
%  -B means high-pass filter cutoff (in cycles per field-of-view)
%  [A B] means band-pass filter cutoffs (in cycles per field-of-view)
%  Can also be {G H} where G is a 3-element vector with voxel sizes (e.g. mm)
%  and H is a 3-element vector with the effective desired voxel size (e.g. mm).
%  In this case, we calculate appropriate low-pass filter cutoffs to
%  construct the appropriate Fourier filter, and <mode> must be 0.
% <order> is a positive integer indicating the order of the Butterworth filter
% <mode> (optional) is
%   0 means multiply the Fourier filters constructed for each dimension
%   N where N is 1, 2, or 3 means just create the Fourier filter for
%     the Nth dimension. In this case, <cutoff> should just be directly
%     A, -B, or [A B].
%   Default: 0.
%
% Return a 3D magnitude filter in Fourier space (not fftshifted).
% The range of values is [0,1].
% The result is suitable for use with imagefilter3D.m.
%
% example:
% a = randn(64,64,10);
% figure; imagesc(makeimagestack(a)); colormap(gray); axis equal tight;
% figure; imagesc(makeimagestack(fftshift(abs(fftn(a))))); colormap(jet); axis equal tight; cax = caxis;
% b = imagefilter3D(a,constructbutterfilter3D(size(a),{[2.5 2.5 2.5] [5 5 5]},10));
% figure; imagesc(makeimagestack(b)); colormap(gray); axis equal tight;
% figure; imagesc(makeimagestack(fftshift(abs(fftn(b))))); colormap(jet); axis equal tight; caxis(cax);

% SEE ALSO CONSTRUCTBUTTERFILTER1D.M AND CONSTRUCTBUTTERFILTER.M

% inputs
if ~exist('mode','var') || isempty(mode)
  mode = 0;
end

% calc
if iscell(cutoff) && length(cutoff)==2
  assert(mode==0);
  volsize = cutoff{1};
  desiredsize = cutoff{2};
  cutoff = num2cell((1./(2*desiredsize)) .* (matrixsize.*volsize));
end

% init
f = 1;

% process each dimension
for dim=1:3

  if isequal(mode,0) || dim==mode
  
    % calc
    if isequal(mode,0)
      val = cutoff{dim};
    else
      val = cutoff;
    end

    % band-pass case
    if length(val) > 1

      % low-pass filter with cutoff at high value minus low-pass filter with cutoff at low value
      f = f .* (constructbutterfilter3D(matrixsize,val(2),order,dim) - ...
                constructbutterfilter3D(matrixsize,val(1),order,dim));

    % low-pass case
    elseif val > 0

      % do it
      temp = {};
      [temp{1},temp{2},temp{3}] = calccpfov3D(matrixsize);
      f = f .* ifftshift(sqrt(1./(1+(temp{dim}./val).^(2*order))));

    % high-pass case
    else

      % take one minus a low-pass filter with cutoff at the specified value
      f = f .* (1 - constructbutterfilter3D(matrixsize,-val,order,dim));

    end

  end

end
