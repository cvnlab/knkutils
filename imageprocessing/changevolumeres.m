function [newvol,newvolsize] = changevolumeres(vol,volsize,newdim,wantlabel)

% function [newvol,newvolsize] = changevolumeres(vol,volsize,newdim,wantlabel)
%
% <vol> is a matrix X x Y x Z. All dimensions must be > 1.
% <volsize> is a 3-element vector with the voxel size
% <newdim> is the desired matrix dimensions
% <wantlabel> (optional) is whether to treat <vol> as consisting
%   of discrete integers. in this case, we separately process each
%   integer as a binary volume and the integer with the largest 
%   resulting value at a given voxel coordinate wins. Default: 0.
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
%
% another example (using <wantlabel>):
% a = repmat(ceil(3*getsampleimage),[1 1 2]);
% b = changevolumeres(a,[1 1 1],[30 30 2],1);
% c = changevolumeres(a,[1 1 1],[130 130 2],1);
% figure; imagesc(a(:,:,1),[1 3]); colormap(jet); axis image tight;
% figure; imagesc(b(:,:,1),[1 3]); colormap(jet); axis image tight;
% figure; imagesc(c(:,:,1),[1 3]); colormap(jet); axis image tight;

% input
if ~exist('wantlabel','var') || isempty(wantlabel)
  wantlabel = 0;
end

% calc new volume voxel size
newvolsize = (sizefull(vol,3).*volsize)./newdim;

% usual case
if ~wantlabel

  % smooth volume
  newvol = smoothvolumes(vol,volsize,newvolsize,1);

  % figure out coordinates with respect to original volume
  [xx,yy,zz] = ndgrid(resamplingindices(1,size(newvol,1),newdim(1)), ...
                      resamplingindices(1,size(newvol,2),newdim(2)), ...
                      resamplingindices(1,size(newvol,3),newdim(3)));

  % use cubic interpolation to sample
  newvol = reshape(ba_interp3_wrapper(newvol,[flatten(xx); flatten(yy); flatten(zz)],'cubic'),newdim);

% special discrete-label case
else

  % figure out the discrete integer labels
  alllabels = flatten(union(vol(:),[]));
  assert(all(isfinite(alllabels)));
  
  % loop over each label
  allresults = [];
  for p=1:length(alllabels)
  
    % smooth binary volume (this produces decimal values)
    newvol = smoothvolumes(double(vol==alllabels(p)),volsize,newvolsize,1);

    % figure out coordinates with respect to original volume
    if ~exist('xx','var')
      [xx,yy,zz] = ndgrid(resamplingindices(1,size(newvol,1),newdim(1)), ...
                          resamplingindices(1,size(newvol,2),newdim(2)), ...
                          resamplingindices(1,size(newvol,3),newdim(3)));
    end

    % use cubic interpolation to sample at the voxel centers that we want
    allresults(:,:,:,p) = reshape(ba_interp3_wrapper(newvol,[flatten(xx); flatten(yy); flatten(zz)],'cubic'),newdim);
    
  end

  % perform winner-take-all (ix is the index relative to alllabels)
  [~,ix] = max(allresults,[],4);
  
  % figure out the final labeling scheme
  newvol = alllabels(ix);

end
