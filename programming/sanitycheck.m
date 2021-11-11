function sanitycheck(data0)

% function sanitycheck(data0)
% 
% <data0> is a matrix with values
%
% Print out some fprintf statements about basic
% properties of the values in the matrix.

fprintf('size is %s\n',mat2str(size(data0)));
fprintf('class is %s\n',class(data0));
data0 = data0(:);
fprintf('nanmin is %.4f\n',nanmin(data0));
fprintf('nanmax is %.4f\n',nanmax(data0));
fprintf('        number that are nan? %d\n',sum(isnan(data0)));
fprintf(' number that are not finite? %d\n',sum(~isfinite(data0)));
fprintf('number that are less than 0? %d\n',sum(data0 < 0));
fprintf(' number that are equal to 0? %d\n',sum(data0 == 0));
fprintf('       prctile from 5 to 95? %s\n',mat2str(prctile(data0,[5 95])));
