function lambda = calcridgeregressionlambda(X,frac)

% function lambda = calcridgeregressionlambda(X,frac)
%
% <X> is a design matrix
% <frac> is a fraction between 0 and 1 (inclusive).
%   can also be a vector of fractions.
%
% return the lambda value that approximately achieves
% vector-length-reduction of the ordinary-least-squares (OLS)
% solution at the level given by <frac>.
%
% we use some hard-coded constants in the function for interpolation
% purposes. because of this, some very extreme values for
% <frac> (such as 0) will generate NaN as the lambda.
%
% note that we silently ignore regressors that are all zeros.
%
% example:
% y = randn(100,1);
% X = randn(100,10);
% h = inv(X'*X)*X'*y;
% lambda = calcridgeregressionlambda(X,0.3);
% h2 = inv(X'*X + lambda*eye(size(X,2)))*X'*y;
% vectorlength(h)
% vectorlength(h2)
% vectorlength(h2) ./ vectorlength(h)

% ignore bad regressors (those that are all zeros)
bad = all(X==0,1);
good = ~bad;
X = X(:,good);

% decompose X
[u,s,v] = svd(X,0);  % u is 100 x 80, s is 80 x 80, v is 80 x 80

% extract the diagonal (the eigenvalues of s)
selt = diag(s);  % 80 x 1

% first, we need to find a grid of lambdas that will span a reasonable range
% with reasonable level of granularity
val1 = 10^3 *selt(1)^2;    % huge bias (take the biggest eigenvalue down to ~.001 of what OLS would be)
val2 = 10^-3*selt(end)^2;  % tiny bias (just add a small amount)
lambdas = [0 10.^(floor(log10(val2)):0.1:ceil(log10(val1)))];  % no bias to tiny bias to huge bias

% next, we need to estimate how much the vector-length reduction will be for each lambda value.
yval = [];
for qq=1:length(lambdas)
  ref = selt ./ (selt.^2);                   % reference result
  new = selt ./ (selt.^2 + lambdas(qq));     % the regularized result
  fracreduction = new./ref;                  % what fraction is the regularized result?
  reflen = sqrt(length(selt));               % vector length assuming variance 1 for each dimension
  newlen = sqrt(sum(fracreduction.^2));      % estimated vector length
  yval(qq) = newlen./reflen;                 % vector-length reduction
end
% in general, we should save the eigenvalues (selt) and the lambdas chosen for evaluation (lambdas)!

% finally, use cubic interpolation to find the lambda that achieves the desired level
lambda = interp1(yval,lambdas,frac,'pchip',NaN);
