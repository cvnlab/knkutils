function m1 = placematrix2(m1,m2,pos)

% function m1 = placematrix2(m1,m2,pos)
%
% <m1> is a matrix (cell matrix okay)
% <m2> is a matrix (cell matrix okay)
% <pos> (optional) is [x1 x2 x3 ...] with a position.
%   x1, x2, x3, etc. must be integers (possibly non-positive),
%   and there must be at least ndims(m2) of these numbers.
%   default is ones(1,ndims(m2)).
%
% place <m2> in <m1> positioned with first element at <pos>.
% <m1> and <m2> must both be of the same type (matrix or cell matrix).
% if <m1> is not large enough to accommodate <m2> in the forward
% direction, 0s or []s are automatically filled in. if <m1> is not
% large enough to accommodate <m2> in the backward direction,
% <m2> is simply truncated and only fills into <m1> for the parts
% the overlap <m1>.
%
% example:
% isequal(placematrix2([1 2 3; 4 5 6; 7 8 9],[0 0],[2 1]),[1 2 3; 0 0 6; 7 8 9])
% placematrix2([1 2; 3 4],[9 9; 9 9],[2 2])
% placematrix2([1 2; 3 4],[9 9; 9 9],[0 1])

%% SEE ALSO padarray.m ? 

% input
if ~exist('pos','var') || isempty(pos)
  pos = ones(1,ndims(m2));
end

% figure out indices
indices = {}; indices2 = {};
for p=1:length(pos)
  indices{p} = max(1,pos(p)-1 + 1) : pos(p)-1 + size(m2,p);
  if pos(p) < 1
    indices2{p} = 1 + (1-pos(p)) : size(m2,p);
  else
    indices2{p} = 1:size(m2,p);
  end
end

% do it
m1(indices{:}) = m2(indices2{:});
