function histrobust(varargin)

% function histrobust(varargin)
%
% arguments are the same as to hist.m
%
% first, use robustrange.m to figure out a robust range of values for the first argument.
% then, truncate the first argument according to this determined range.
% finally, call hist on the results.
%
% example:
% xx = [randn(1,1000) 300*ones(1,100)];
% figure; hist(xx);
% figure; histrobust(xx);

rng = robustrange(varargin{1});
if rng(1) == rng(2)
  hist(varargin{1},varargin{2:end});
else
  hist(normalizerange(varargin{1},rng(1),rng(2),rng(1),rng(2)),varargin{2:end});
end
