function [finalT,world2world] = alignniftitonifti(refvol,vol,newvol,mcmask,mode)

% function [finalT,world2world] = alignniftitonifti(refvol,vol,newvol,mcmask,mode)
%
% <refvol> is the reference NIFTI volume file
% <vol> is the NIFTI file that you want to align to <refvol>.
% <newvol> (optional) is the output NIFTI file to save.
%   Default: [] which means do not save a file.
% <mcmask> (optional) is {mn sd} with the mn and sd outputs of defineellipse3d.m.
%   If [] or not supplied, we prompt the user to determine these with the GUI.
% <mode> (optional) is
%   0 means use rigid-body
%   1 means use rigid-body + scaling
%   2 means use affine (rigid-body + scaling + shearing)
%   Default: 0.
%
% Align <vol> to <refvol> using alignvolumedata.m.
% If <newvol> is supplied, we write out a new NIFTI file that is the same
%   as <vol> except that it has the srow_* headers set accordingly.
%   Note that the new NIFTI file has identical image data (we change only
%   the header stuff). 
% We also return <finalT> which is the 4x4 transformation matrix that 
%   indicates the result of the alignment, specifically, the mapping of 
%   0-based image indices of <vol> to world coordinates.
% We also return <world2world> which is the 4x4 transformation matrix that
%   maps from world coordinates of <vol> to world coordinates of <refvol>.
%
% NOTE: If you use <mode>==2, which involves shearing, then the <newvol>
%       NIFTI file might be incompatible with certain viewers (ITK-SNAP).
%       This is because shearing transforms don't seem to play nice.
%       But the transforms (e.g. <finalT>) should still be correct.

%% %%%%% INPUTS

% inputs
if ~exist('newvol','var') || isempty(newvol)
  newvol = [];
end
if ~exist('mcmask','var') || isempty(mcmask)
  mcmask = [];
end
if ~exist('mode','var') || isempty(mode)
  mode = 0;
end

%% %%%%% LOAD

% load the niftis
a1 = load_untouch_nii(refvol);
a2 = load_untouch_nii(vol);

% prepare the refvol
a1size = a1.hdr.dime.pixdim(2:4);
a1vol = double(a1.img);
if a1.hdr.dime.scl_slope ~= 0
  a1vol = a1vol * a1.hdr.dime.scl_slope + a1.hdr.dime.scl_inter;
end
a1vol(isnan(a1vol)) = 0;
fprintf('a1 has dimensions %s at %s mm.\n',mat2str(size(a1vol)),mat2str(a1size));

% prepare the vol
a2size = a2.hdr.dime.pixdim(2:4);
a2vol = double(a2.img);
if a2.hdr.dime.scl_slope ~= 0
  a2vol = a2vol * a2.hdr.dime.scl_slope + a2.hdr.dime.scl_inter;
end
a2vol(isnan(a2vol)) = 0;
fprintf('a2 has dimensions %s at %s mm.\n',mat2str(size(a2vol)),mat2str(a2size));

%% %%%%% DEFINE ELLIPSE

% manually define ellipse to be used in the auto alignment
if isempty(mcmask)
  [f,mn,sd] = defineellipse3d(a2vol);
  mcmask = {eval(mat2str(mn,6)) eval(mat2str(sd,6))};
  fprintf('mcmask = %s;\n',cell2str(mcmask));
end
mn = mcmask{1};
sd = mcmask{2};

%% %%%%% START ALIGNMENT

% start the alignment
alignvolumedata(a1vol,a1size,a2vol,a2size);

% pause to do some manual alignment (to get a reasonable starting point)
keyboard;

% report to the user to save just in case
tr = alignvolumedata_exporttransformation;

% auto-align (correlation)
switch mode

% rigid-body
case 0
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[4 4 4]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[2 2 2]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);

% rigid + scaling
case 1
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[4 4 4]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 0 0 0],[4 4 4]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[2 2 2]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 0 0 0],[2 2 2]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 0 0 0],[1 1 1]);

% affine (rigid + scaling + shearing)
case 2
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[4 4 4]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 1 1 1],[4 4 4]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[2 2 2]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 1 1 1],[2 2 2]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 1 1 1],[1 1 1]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 1 1 1],[1 1 1]);
  alignvolumedata_auto(mn,sd,[1 1 1 1 1 1 0 0 0 0 0 0],[1 1 1]);
  alignvolumedata_auto(mn,sd,[0 0 0 0 0 0 1 1 1 1 1 1],[1 1 1]);

end

% record transformation
tr = alignvolumedata_exporttransformation;

% convert the transformation to a matrix
T = transformationtomatrix(tr,0,a1size);  % target to reference
fprintf('T=%s;\n',mat2str(T));

%% %%%%% FIGURE OUT TRANSFORMATIONS

% construct transformation matrices
M1 = cat(1,a1.hdr.hist.srow_x,a1.hdr.hist.srow_y,a1.hdr.hist.srow_z);
M1(4,:) = [0 0 0 1];
M2 = cat(1,a2.hdr.hist.srow_x,a2.hdr.hist.srow_y,a2.hdr.hist.srow_z);
M2(4,:) = [0 0 0 1];

% T maps from 1-based target to 1-based reference
% T*xyztranslate([1 1 1]) maps from 0-based target to 1-based reference
% M1*xyztranslate([-1 -1 -1])*T*xyztranslate([1 1 1]) maps from 0-based target to world (of refvol)
finalT = M1*xyztranslate([-1 -1 -1])*T*xyztranslate([1 1 1]);

% inv(M2) maps from world (of vol) to 0-based target
% finalT*inv(M2) maps from world (of vol) to world (of refvol)
world2world = finalT*inv(M2);

% figure out the voxel size
targetres = [vectorlength(finalT*[1 0 0 0]') ...
             vectorlength(finalT*[0 1 0 0]') ...
             vectorlength(finalT*[0 0 1 0]')];

%% %%%%% NIFTI STUFF

% make a new nifti
if ~isempty(newvol)
  nsd_savenifti(zeros(size(a2.img),class(a2.img)),targetres,newvol);
  a3 = load_untouch_nii(newvol);
  a3.img = a2.img;
  a3.hdr.hist.srow_x = finalT(1,:);
  a3.hdr.hist.srow_y = finalT(2,:); 
  a3.hdr.hist.srow_z = finalT(3,:);
  save_untouch_nii(a3,newvol);
end
