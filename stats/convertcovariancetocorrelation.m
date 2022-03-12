function [m,bad] = convertcovariancetocorrelation(m)

% function [m,bad] = convertcovariancetocorrelation(m)
%
% <m> is a covariance matrix (N x N)
%
% We attempt to normalize the covariance matrix <m> such
% that the diagonals are equal to 1, thereby enabling
% the interpretation of off-diagonal elements as
% correlation values. This is done by dividing each
% element by its associated row-wise and column-wise
% diagonal elements.
%
% This will fail in cases where a diagonal element
% is 0 or negative. In such cases, we set all 
% associated matrix elements to NaN.
%
% Return:
% <m> as the final correlation matrix
% <bad> as a column logical vector indicating any invalid
%   variances (i.e., variances that are non-positive)
%
% example:
% c = cov(randn(10,10));
% c(2,2) = -1;  % deliberately make a variance invalid
% c2 = convertcovariancetocorrelation(c);
% figure; imagesc(c,[-1 1]);
% figure; imagesc(c2,[-1 1]);

% divide elements row-wise and column-wise by their
% associated diagonal elements
mdiag = diag(m);
t0 = sqrt(posrect(mdiag));  % column vector. note: negative are set to 0!
m = m ./ (t0*t0');

% mark cases with invalid diagonal variances (<= 0) as NaN!
bad = mdiag <= 0;
m(bad,:) = NaN;
m(:,bad) = NaN;
