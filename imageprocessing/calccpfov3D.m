function varargout = calccpfov3D(matrixsize)

% function [aa,bb,cc] = calccpfov3D(matrixsize)
%
% <matrixsize> is [A B C] with the dimensions of the 3D volume
%  
% return <aa>, <bb>, and <cc> which contain the number of cycles per field-of-view
% in the first three dimensions, corresponding to the output of fftn after 
% fftshifting.
%
% example:
% [aa,bb,cc] = calccpfov3D([10 5 4]);
% figure; imagesc(makeimagestack(aa)); colormap(gray); colorbar;
% figure; imagesc(makeimagestack(bb)); colormap(gray); colorbar;
% figure; imagesc(makeimagestack(cc)); colormap(gray); colorbar;

% SEE ALSO CALCCPFOV1D.M AND CALCCPFOV.m

for dim=1:3
  n = matrixsize(dim);
  if mod(n,2)==0
    vals = -n/2:n/2-1;
  else
    vals = -(n-1)/2:(n-1)/2;
  end
  varargout{dim} = fillmatrix(vals,matrixsize,dim);
end
