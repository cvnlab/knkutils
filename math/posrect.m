function m = posrect(m,val)

% function m = posrect(m,val)
%
% <m> is a matrix
% <val> (optional) is the cut-off value. Default: 0.
%
% positively-rectify <m>.
% basically do: m(m<val) = val.
%
% example:
% isequal(posrect([2 3 -4]),[2 3 0])
% isequal(posrect([2 3 -4],4),[4 4 4])

% inputs
if ~exist('val','var') || isempty(val)
  val = 0;
end

% do it
m(m<val) = val;
