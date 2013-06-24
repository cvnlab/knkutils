function f = projectionmatrix(X)

% function f = projectionmatrix(X)
%
% <X> is samples x parameters
%
% what we want to do is to perform a regression using <X>
% and subtract out the fit.  this is accomplished by
% y-X*inv(X'*X)*X'*y = (I-X*inv(X'*X)*X')*y = f*y
% where y is the data (samples x cases).
%
% what this function does is to return <f> which has
% dimensions samples x samples.  to accomplish this,
% we rely heavily on olsmatrix.m.
%
% example:
% x = sort(randn(100,1));
% x2 = projectionmatrix(constructpolynomialmatrix(100,0:1))*x;
% figure; hold on; plot(x,'r-'); plot(x2,'g-');

f = eye(size(X,1)) - X*olsmatrix(X);
