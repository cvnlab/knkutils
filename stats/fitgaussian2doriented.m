function [params,R2] = fitgaussian2doriented(m,params0,fixparams,specialmode)

% function [params,R2] = fitgaussian2doriented(m,params0,fixparams,specialmode)
%
% <m> is a 2D matrix
% <params0> (optional) is an initial seed.
%   default is [] which means make up our own initial seed.
% <fixparams> (optional) is
%   0 means do nothing special
%   1 means fix the offset to 0
%   default: 0.
% <specialmode> (optional) is
%   0 means normal mode
%   1 means interpret <m> as a probability density and weight the optimization
%     such that elements of <m> that have higher density contribute more to the
%     error metric.
%
% use lsqcurvefit.m to estimate parameters of an oriented 2D Gaussian function.
% return:
%  <params> is like the input to evalgaussian2doriented.m
%  <R2> is the R^2 between fitted and actual m-values (see calccod.m).
%
% note that the parameters are in the matrix coordinate frame (see example).
%
% example:
% [xx,yy] = meshgrid(1:30,1:20);  % 1:30 in x-direction, 1:20 in y-direction
% im = evalgaussian2doriented([7 12 2 5 10 0 20],xx,yy) + 0.5*randn(20,30);
% [params,R2] = fitgaussian2doriented(im,[],1);
% figure; imagesc(im,[0 10]); axis image tight; set(gca,'YDir','normal');
% figure; imagesc(evalgaussian2doriented(params,xx,yy),[0 10]); axis image tight; set(gca,'YDir','normal');
% title(sprintf('R2=%.5f',R2));

% input
if ~exist('params0','var') || isempty(params0)
  params0 = [];
end
if ~exist('fixparams','var') || isempty(fixparams)
  fixparams = 0;
end
if ~exist('specialmode','var') || isempty(specialmode)
  specialmode = 0;
end

% construct coordinates
[xx,yy] = meshgrid(1:size(m,2),1:size(m,1));

% define options
options = optimset('Display','iter','FunValCheck','on','MaxFunEvals',Inf,'MaxIter',Inf,'TolFun',1e-6,'TolX',1e-6);

% define seed
if isempty(params0)
  params0 = [(1+size(m,2))/2 (1+size(m,1))/2 size(m,2)/5 size(m,1)/5 iqr(m(:)) mean(m(:)) 0];
end

% deal with fixing.
%   ix are the indices that we are optimizing.
%   ixsp are special indices in params0 to fill in to make a full-fledged parameter.
%   ppi are indices to pull out from pp to fill in ixsp with.
switch fixparams
case 0
  ix = 1:7;
  ixsp = ix;
  ppi = 1:7;
case 1
  ix = [1:5 7];
  ixsp = ix;
  ppi = 1:6;
  params0(6) = 0;  % explicitly set
end

% report
fprintf('initial seed is %s\n',mat2str(params0,5));

% define bounds
%             mx   my  sx  sy    g    d  ang
paramslb = [-Inf -Inf   0   0 -Inf -Inf -Inf];
paramsub = [ Inf  Inf Inf Inf  Inf  Inf  Inf];

% do it
switch specialmode
case 0

  % here, lsqcurvefit will simply do sum((modelfit - data).^2),
  % so it is minimizing "image intensity error"
  tt0 = 1;

case 1

  % here, if we interpret the data (<m>) as frequency counts,
  % then image pixels with double the intensity have double the data points.
  % so then, the error of those image pixels should count double in the summation.
  % by setting tt0 to the following, we make it such that the magnitude of <m>
  % is used to weight the squared errors before summing. (The abs is a hack
  % to avoid negative cases, and the sqrt is necessary because the errors are
  % squared by lsqcurvefit.m.)
  tt0 = flatten(sqrt(abs(m)));

end
[params,d,d,exitflag,output] = lsqcurvefit(@(pp,xx) tt0 .* nanreplace(evalgaussian2doriented(copymatrix(params0,ixsp,pp(ppi)),xx),0,2),params0(ix),[flatten(xx); flatten(yy)],tt0 .* flatten(m),paramslb(ix),paramsub(ix),options);
assert(exitflag > 0);
params = copymatrix(params0,ixsp,params(ppi));

% how well did we do?
R2 = calccod(evalgaussian2doriented(params,[flatten(xx); flatten(yy)]),flatten(m));
