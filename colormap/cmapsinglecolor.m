function f = cmapsinglecolor(n,source,target)

% function f = cmapsinglecolor(n,source,target)
%
% <n> is the desired number of entries
% <source> is the starting color
% <target> is the ending color
%
% return a source-to-target colormap using evenly spaced colors
% (linear interpolation), starting and ending at the supplied colors.
% you can also stick multiple colors in <source> and/or omit <target>.
%
% example:
% figure;
% colormap(cmapsinglecolor(256,[0 0 0],[.7 .4 .9]));
% colorbar;

% inputs
if ~exist('target','var') || isempty(target)
  target = [];
end

% setup
colors = [source; target];

% do it
f = [];
for p=1:size(colors,2)
  f(:,p) = interp1(linspace(0,1,size(colors,1)),colors(:,p)',linspace(0,1,n),'linear');
end

%%%%%%%%%%%%%%%%

% notes:
% [0,0,0],[0 1 0]  black to green
% [0 0 0] [1 0 1]  black to magenta
% [1 1 1] [4 112 47]        white to dark green
% [1 1 1] [11 85 159]       white to dark blue
