function a1 = transformniftilocation(vol,newvol,world2world)

% function a1 = transformniftilocation(vol,newvol,world2world)
%
% <vol> is the NIFTI file
% <newvol> (optional) is the output NIFTI file to save.
%   If [] or not supplied, we do not write an output NIFTI file. 
% <world2world> is a 4x4 transformation matrix indicating some
%   transformation to apply to <vol>'s world coordinates.
%
% Load <vol> and change the srow_* transformation according to
% <world2world>. Return the loaded and transformed NIFTI
% in <a1>, and this is what is saved to <newvol>.
%
% Note that we reset the qform stuff (e.g. qform_code set to 0),
% and we set sform_code to 2.

% inputs
if ~exist('newvol','var') || isempty(newvol)
  newvol = [];
end

% load
a1 = load_untouch_nii(vol);

% construct transformation matrix
M1 = cat(1,a1.hdr.hist.srow_x,a1.hdr.hist.srow_y,a1.hdr.hist.srow_z);
M1(4,:) = [0 0 0 1];

% M1*coords (where coords is 4 x n) takes points in the 0-based
% image space of <vol> and brings it to world coordinates.

% apply the transformation. this takes the world coordinates
% and maps them somewhere else.
M1 = world2world*M1;

% populate
a1.hdr.hist.sform_code = 2;
a1.hdr.hist.srow_x = M1(1,:);
a1.hdr.hist.srow_y = M1(2,:);
a1.hdr.hist.srow_z = M1(3,:);

% reset qform
a1.hdr.hist.qform_code = 0;
a1.hdr.hist.qoffset_x = 0;
a1.hdr.hist.qoffset_y = 0;
a1.hdr.hist.qoffset_z = 0;
a1.hdr.hist.quatern_b = 0;
a1.hdr.hist.quatern_c = 0;
a1.hdr.hist.quatern_d = 0;

% save
if ~isempty(newvol)
  save_untouch_nii(a1,newvol);
end
