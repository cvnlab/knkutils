function [md,pp,mdpp] = calcmdsepct(m,dim,numboot)

% function [md,pp,mdpp] = calcmdsepct(m,dim,numboot)
%
% <m> is a matrix
% <dim> (optional) is the dimension of interest.
%   default to 2 if <m> is a row vector and to 1 if not.
%   special case is 0 which means to calculate globally.
% <numboot> (optional) is number of bootstraps to take.  default: 1000.
%
% return:
%  <md> as the nanmedian of <m>.
%  <pp> as the 15.87th and 84.13th percentiles of the bootstrapped nanmedians.
%     (68% confidence interval).
%  <mdpp> as the concatenation of <md> and <pp> along <dim>.
% 
% the size of <md> is the same as <m> except collapsed along <dim>.
% the size of <pp> is the same as <m> except having two elements along <dim>.
% in the special case where <dim> is 0, <md> is 1 x 1 and <pp> is 2 x 1.
%
% example:
% [md,pp] = calcmdsepct(randn(1,10000))

% input
if ~exist('dim','var') || isempty(dim)
  if isvector(m) && size(m,1)==1
    dim = 2;
  else
    dim = 1;
  end
end
if ~exist('numboot','var') || isempty(numboot)
  numboot = 1000;
end

% do it
if dim==0
  m = m(:);
  dim = 1;
end
md = nanmedian(m,dim);
temp = bootstrapdim(m,dim,@(x) nanmedian(x,dim),numboot);
%pp = prctile(temp,[25 75],dim);
pp = prctile(temp,[15.87 84.13],dim);
mdpp = cat(dim,md,pp);
