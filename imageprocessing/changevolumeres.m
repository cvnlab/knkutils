function [newvol,newvolsize] = changevolumeres(vol,volsize,newdim)

% function [newvol,newvolsize] = changevolumeres(vol,volsize,newdim)
%
% <vol> is a matrix X x Y x Z. All dimensions must be > 1.
% <volsize> is a 3-element vector with the voxel size
% <newdim> is the desired matrix dimensions
%
% Change the resolution of the volume <vol> to a desired
% resolution using an ideal Fourier filter and cubic
% interpolation. Beware of wraparound issues.
% Note that the field-of-view is exactly preserved.
%
% example:
% a = repmat(getsampleimage,[1 1 2]);
% b = changevolumeres(a,[1 1 1],[731 731 2]);
% c = changevolumeres(a,[1 1 1],[67 67 2]);
% figure; imagesc(a(:,:,1)); axis image tight;
% figure; imagesc(b(:,:,1)); axis image tight;
% figure; imagesc(c(:,:,1)); axis image tight;

% calc new volume voxel size
newvolsize = (sizefull(vol,3).*volsize)./newdim;

% smooth volume
newvol = smoothvolumes(vol,volsize,newvolsize,1);

% figure out coordinates with respect to original volume
[xx,yy,zz] = ndgrid(resamplingindices(1,size(newvol,1),newdim(1)), ...
                    resamplingindices(1,size(newvol,2),newdim(2)), ...
                    resamplingindices(1,size(newvol,3),newdim(3)));

% use cubic interpolation to sample
newvol = reshape(ba_interp3_wrapper(newvol,[flatten(xx); flatten(yy); flatten(zz)],'cubic'),newdim);
