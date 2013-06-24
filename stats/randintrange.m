function f = randintrange(x,y,sz)

% function f = randintrange(x,y,sz)
% 
% <x> and <y> are integers such that <x> <= <y>
% <sz> (optional) is a matrix size.  default: [1 1].
%
% return random integers in the range [<x>,<y>] inclusive.
%
% example:
% randintrange(-2,5)

% input
if ~exist('sz','var') || isempty(sz)
  sz = [1 1];
end

% do it
f = x + floor(rand(sz)*(y-x+1));
