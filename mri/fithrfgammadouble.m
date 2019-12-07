function [params,r,iters] = fithrfgammadouble(x,y,params0,maxiter,tolfun)

% function [params,r,iters] = fithrfgammadouble(x,y,params0,maxiter,tolfun)
%
% <x> is a vector of x-values
% <y> is a vector of y-values
% <params0> (optional) is a seed.  if [] or not supplied,
%   use a default seed.
% <maxiter> (optional) is the max number of iterations.
%   if [] or not supplied, default to [].
% <tolfun> (optional) is the tolfun value.
%   if [] or not supplied, default to [].
%
% return <params> which is like the input to hrfgammadouble.m.
% return <r> which is the correlation value between the
%   actual y-values and the fitted y-values.
% return <iters> which is the number of iterations taken.
%
% try this test:
% x = 0:40;
% y = hrfgammadouble([2 2 4 2 5 -.25 0 100],x) + 1*rand(1,length(x));
% [params,r] = fithrfgammadouble(x,y);
% y2 = hrfgammadouble(params,x);
% figure;
% hold on;
% plot(x,y,'r-');
% plot(x,y2,'b-');
% r
%
% note that we incorporate some a priori assumptions in the following:
% - the default seed for <params0> (see below)
% - the <n> and <t> parameters to hrfgammadouble.m are constrained to be >=0

% deal with input
if ~exist('params0','var') || isempty(params0)
  params0 = [];
end
if ~exist('maxiter','var') || isempty(maxiter)
  maxiter = [];
end
if ~exist('tolfun','var') || isempty(tolfun)
  tolfun = [];
end

% deal with options
options = optimset('Display','off','MaxIter',maxiter,'TolFun',tolfun);

% seed and bounds
xmn = min(x);
xmx = max(x);
ymn = min(y);
ymx = max(y);
if isempty(params0)
  params0 = [2 2 (ymx-ymn)/3 2 2 -(ymx-ymn)/9 xmn (ymn+ymx)/2];
end
paramslb = [  0   0 -Inf   0   0 -Inf -Inf -Inf];
paramsub = [Inf Inf  Inf Inf Inf  Inf  Inf  Inf];

% do it
[params,dummy,dummy,dummy,output] = lsqcurvefit(@hrfgammadouble,params0,x,y,paramslb,paramsub,options);
r = calccorrelation(y,hrfgammadouble(params,x));
iters = output.iterations;
