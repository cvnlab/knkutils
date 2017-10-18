function f = xyzrotate_z(p)

% function f = xyzrotate_z(p)
%
% return the rotation matrix for rotating
% p degrees around z-axis.

p = p/180*pi;

f = [cos(p) -sin(p) 0 0 ;...
     sin(p)  cos(p) 0 0 ;...
          0       0 1 0 ;...
          0       0 0 1 ];
