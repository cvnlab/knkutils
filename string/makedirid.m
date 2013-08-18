function f = makedirid(x,num)

% function f = makedirid(x,num)
%
% <x> is a path to a file or directory
% <num> (optional) is the non-negative number of elements desired.  default: 2.
%
% return a string with the last <num> elements of the path joined with '_'.
% also, any occurrences of '-' are replaced with '_'.
%
% history:
% - 2013/08/18 - now, '-' is replaced with '_' (so that the result
%   can be a valid function name).
%
% example:
% isequal(makedirid('/home/knk/dir1/file-test'),'dir1_file_test')

% input
if ~exist('num','var') || isempty(num)
  num = 2;
end

% do it
f = '';
for p=1:num
  f = ['_' stripfile(x,1) f];
  x = stripfile(x);
end
f = f(2:end);

% replace - with _
f = strrep(f,'-','_');
