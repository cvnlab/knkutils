function f = resliceniftitomatch(refvol,vol,newvol,interptype,world2world)

% function f = resliceniftitomatch(refvol,vol,newvol,interptype,world2world)
%
% <refvol> is the reference NIFTI volume file
% <vol> is the NIFTI that you want to reslice to match <refvol>.
%   this NIFTI can have one or more volumes in the fourth dimension.
% <newvol> (optional) is the output NIFTI file to save.
%   If not supplied, we do not write an output NIFTI file.
% <interptype> (optional) is 'nearest' | 'linear' | 'cubic' | 'wta'.
%   Default: 'cubic'. See ba_interp3_wrapper.m for more details.
% <world2world> (optional) is a 4x4 transformation matrix indicating
%   how to take <vol>'s world coordinates to match <refvol>'s world
%   coordinates. In the usual case, <world2world> is unnecessary,
%   since <vol> is supposed to be already aligned to <refvol>.
%   However, it is convenient to allow this input option.
%   Default: eye(4).
%
% Based on the NIFTI header information (srow_*), we reslice/interpolate
% through the data of <vol> to match the voxel sampling locations 
% of <refvol>. The interpolation type is controlled by <interptype>.
% We automatically compute in double format and then cast the output
% to the class of <vol>. The output file inherits all of the header 
% information of <refvol>, with the exception that it inherits
% inherits the 'bitpix' and 'datatype' of <vol>.
%
% We return the new interpolated volume(s) in <f> (this is the same
% as what is saved into <newvol>.

% history:
% - 2024/04/26 - fix minor bug (ensure number of volumes in NIFTI header of <newvol> is correct)
% - 2024/04/23 - add <world2world>
% - 2021/09/02 - add support for more than one volume

% inputs
if ~exist('interptype','var') || isempty(interptype)
  interptype = 'cubic';
end
if ~exist('world2world','var') || isempty(world2world)
  world2world = eye(4);
end

% load
a1 = load_untouch_nii(refvol);
a2 = load_untouch_nii(vol);

% construct transformation matrices
M1 = cat(1,a1.hdr.hist.srow_x,a1.hdr.hist.srow_y,a1.hdr.hist.srow_z);
M1(4,:) = [0 0 0 1];
M2 = cat(1,a2.hdr.hist.srow_x,a2.hdr.hist.srow_y,a2.hdr.hist.srow_z);
M2(4,:) = [0 0 0 1];

% determine where refvol's coordinates lie with respect to vol
[xx1,yy1,zz1] = ndgrid((1:size(a1.img,1))-1,(1:size(a1.img,2))-1,(1:size(a1.img,3))-1);
coord1 = [xx1(:) yy1(:) zz1(:)];
coord1(:,4) = 1;
coord1 = M1*coord1';       % convert 0-based image coordinates (of refvol) to world
coord1 = inv(world2world)*coord1;  % convert world of refvol to world of vol
coord1 = inv(M2)*coord1;   % convert from world to 0-based image coordinates (of vol)

% process each volume (in reverse to ensure memory allocation)
a1sz = sizefull(a1.img,3);
a1 = rmfield(a1,'img');
for xx=size(a2.img,4):-1:1

  % take vol's data and interpolate through it to match refvol
  f = double(a2.img(:,:,:,xx));
  if a2.hdr.dime.scl_slope ~= 0
    f = f * a2.hdr.dime.scl_slope + a2.hdr.dime.scl_inter;
  end
  f = ba_interp3_wrapper(f,coord1(1:3,:)+1,interptype);

  % mangle a1
  a1.img(:,:,:,xx) = cast(reshape(f,a1sz),class(a2.img));

end

% save
a1.hdr.dime.bitpix   = a2.hdr.dime.bitpix;
a1.hdr.dime.datatype = a2.hdr.dime.datatype;
a1.hdr.dime.scl_slope = 1;
a1.hdr.dime.scl_inter = 0;
a1.hdr.dime.dim(5) = size(a2.img,4);  % number of volumes
if size(a2.img,4) > 1
  a1.hdr.dime.dim(1) = 4;
else
  a1.hdr.dime.dim(1) = 3;
end
save_untouch_nii(a1,newvol);
