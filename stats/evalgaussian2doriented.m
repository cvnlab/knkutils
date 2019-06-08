function f = evalgaussian2doriented(params,x,y)

% function f = evalgaussian2doriented(params,x,y)
%
% <params> is [mx my sx sy g d ang] where
%   <mx>,<my> is the mean
%   <sx>,<sy> is the standard deviation
%   <g> is the gain
%   <d> is the offset
%   <ang> is the angle (in degrees) to rotate counter-clockwise
% <x>,<y> are matrices containing x- and y-coordinates to evaluate at.
%   you can omit <y> in which case we assume the first row
%   of <x> contains x-coordinates and the second row contains
%   y-coordinates.
%
% evaluate the oriented 2D Gaussian at <x> and <y>.
% 
% example:
% [xx,yy] = meshgrid(0:.01:1,0:.01:1);
% zz = evalgaussian2doriented([.6 .5 .05 .2 2 1 10],xx,yy);
% figure; contour(xx,yy,zz); colorbar; axis equal;

% input
if ~exist('y','var')
  y = x(2,:);
  x = x(1,:);
end
mx  = params(1);
my  = params(2);
sx  = params(3);
sy  = params(4);
g   = params(5);
d   = params(6);
ang = -params(7)/180*pi;  % now in radians

% calc
origsz = size(x);
rot0 = [cos(ang) -sin(ang);
        sin(ang)  cos(ang)];

% make relative to mean of Gaussian and then rotate
coord = rot0*[x(:)-mx y(:)-my]';  % 2 x points

% evaluate the Gaussian
f = reshape(g*exp( coord(1,:).^2/-(2*sx^2) + coord(2,:).^2/-(2*sy^2) ) + d,origsz);
