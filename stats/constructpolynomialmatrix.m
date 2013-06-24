function f = constructpolynomialmatrix(n,degrees)

% function f = constructpolynomialmatrix(n,degrees)
%
% <n> is the number of points
% <degrees> is a vector of polynomial degrees
%
% return a matrix of dimensions <n> x length(<degrees>)
% with polynomials in the columns (e.g. x, x^2, x^3, etc.).
% these are evaluated over the range [-1,1].
% beware of numerical precision issues for high degrees...
%
% example:
% figure; imagesc(constructpolynomialmatrix(100,0:3));

% do it
f = [];
temp = linspace(-1,1,n)';
for p=1:length(degrees)
  f = cat(2,f,temp .^ degrees(p));
end
