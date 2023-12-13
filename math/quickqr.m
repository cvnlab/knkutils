function x = quickqr(x)

% function x = quickqr(x)
%
% <x> is a 2D matrix with vectors in the columns
%
% create an orthonormal basis from <x> by iteratively
% orthogonalizing each column with respect to all
% previous columns and then applying unit-length normalization.
% the result will satisfy x'*x equaling the identity matrix.
% note that the basis may not necessary be complete (i.e.
% it is okay if the number of columns in <x> is less than
% or greater than the number of rows).
% 
% this is achieved as:
%   [qq,rr] = qr(x,'econ');
% where the desired output is <qq>.
%
% this function is useful within anonymous functions.
% 
% example:
% x = quickgramschmidt(randn(10,4));
% x'*x

% SLOW WAY:
% for p=1:size(x,2)
%   x(:,p) = unitlength(projectionmatrix(x(:,1:p-1))*x(:,p));
% end

[x,rr] = qr(x,'econ');
