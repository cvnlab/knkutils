function [f,err] = calcmvgaussianpdf(pts,mn,c,wantomitexp)

% function [f,err] = calcmvgaussianpdf(pts,mn,c,wantomitexp)
%
% <pts> is N x D where D corresponds to different dimensions
%   and N corresponds to different data points
% <mn> is 1 x D with the mean of the multivariate Gaussian
% <c> is D x D with the covariance of the multivariate Gaussian
% <wantomitexp> (optional) is whether to omit the final 
%   exponentiation. This is useful when probabilities are
%   very small. Default: 0.
%
% Evaluate the probability density function corresponding to
% a multivariate Gaussian governed by <mn> and <c> at the
% data points specified in <pts>.
%
% Return:
% <f> as N x 1 with the likelihood corresponding to each data point.
%   if <wantomitexp>, we get the log likelihood instead.
% <err> is 0 when <c> is positive definite.
%   when <c> is not positive definite, <f> is returned as [],
%   and <err> is a positive integer (see cholcov.m).
% 
% example:
% mn = [0 0];
% c = [1 .5; .5 1];
% [xx,yy] = meshgrid(-4:.1:4,-4:.1:4);
% [f,err] = calcmvgaussianpdf([xx(:) yy(:)],mn,c);
% assert(err==0);
% figure; scatter3(xx(:),yy(:),f,16,f,'filled'); colormap(jet); xlabel('x'); ylabel('y');
% sum(f)*.1^2

% inputs
if ~exist('wantomitexp','var') || isempty(wantomitexp)
  wantomitexp = 0;
end

% calc
d = size(pts,2);  % number of variables

% remove distribution mean from the data points
pts = pts - repmat(mn,[size(pts,1) 1]);

% decompose covariance matrix
[T,err] = cholcov(c,0);  % T'*T = c

% get out if not positive definite
if err ~= 0
  f = [];
  return;
end

% standardize data
pts = pts / T;

% finish up
f = -0.5*sum(pts.^2,2) - sum(log(diag(T))) - d*log(2*pi)/2;
if ~wantomitexp
  f = exp(f);
end
