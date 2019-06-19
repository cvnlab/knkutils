function [d1,d2,d3,ii] = computebrickandindices(mask)

% function [d1,d2,d3,ii] = computebrickandindices(mask)
%
% <mask> is a 3D binary volume
%
% We want to determine the smallest possible "brick" that
% contains all voxels selected in <mask>. This is useful
% if you want to load only a subset of the voxels in <mask>,
% e.g. using matfile.m.
%
% return:
% <d1> is the range for first dimension, like 20:35.
% <d2> is the range for second dimension, like 11:13.
% <d3> is the range for third dimension, like 30:40.
% <ii> is a row vector of indices into the brick
%   defined by <d1>, <d2>, and <d3>.

ix = find(sum(sum(mask,2),3));
d1 = min(ix):max(ix);

ix = find(sum(sum(mask,1),3));
d2 = min(ix):max(ix);

ix = find(sum(sum(mask,1),2));
d3 = min(ix):max(ix);

ii = flatten(find(mask(d1,d2,d3)));
