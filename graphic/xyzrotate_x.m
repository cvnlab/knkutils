function f = xyzrotate_x(p)

% function f = xyzrotate_x(p)
%
% return the rotation matrix for rotating
% p degrees around x-axis.

p = p/180*pi;

f = [1      0       0 0 ;...
     0 cos(p) -sin(p) 0 ;...
     0 sin(p)  cos(p) 0 ;...
     0      0       0 1 ];
