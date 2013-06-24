function f = makedirid(x,num)

% function f = makedirid(x,num)
%
% <x> is a path to a file or directory
% <num> (optional) is the non-negative number of elements desired.  default: 2.
%
% return a string with the last <num> elements of the path joined with '_'.
%
% example:
% isequal(makedirid('/home/knk/dir1/file'),'dir1_file')

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
