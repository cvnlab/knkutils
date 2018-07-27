function f = xyzrotatetoz(v)

% function f = xyzrotatetoz(v)
%
% <v> is a vector in 3D space
%
% given a vector, return the rotation matrix for rotating
% the coordinate system to align this vector with the positive
% z-axis.  we perform this by first rotating around the x-axis
% and then rotating around the y-axis.

f = xyzrotate_y(-atan2(v(1),norm(v(2:3)))/pi*180)*xyzrotate_x(atan2(v(2),v(3))/pi*180);
