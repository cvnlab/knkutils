function f = cmaptab10(a,b)

% function f = cmaptab10(a)
% 
% <a> is the desired number of entries (must be >= 1 and <= 10)
%
% return the colormap with the first <a> entries.
%
%   OR
%
% function f = cmaptab10([],b)
%
% <b> is the specific entry desired.
%
% return a single color (the <b>th entry).
%
% example:
% figure;
% colormap(cmaptab10(10));
% colorbar;

% taken from some web site...
colors = [ ...
31 119 180;
255 127 14;
44 160 44;
214 39 40;
148 103 189;
140 86 75;
227 119 194;
127 127 127;
188 189 34;
23 190 207; ...
]/255;

% handle cases
if ~exist('b','var')
  assert(a >= 1 && a <= 10);
  f = colors(1:a,:);
else
  f = colors(b,:);
end
