function f = xyzrotate_y(p)

% function f = xyzrotate_y(p)
%
% return the rotation matrix for rotating
% p degrees around y-axis.

p = p/180*pi;

f = [cos(p)  0  sin(p)  0 ;...
          0  1       0  0 ;...
    -sin(p)  0  cos(p)  0 ;...
          0  0       0  1];
