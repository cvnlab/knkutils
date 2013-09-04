function f = consolidatematdir(dir0)

% function f = consolidatematdir(dir0)
%
% <dir0> is a path to a directory
%
% use consolidatemat.m to load all *.mat files
% in <dir0> and write the results to <dir0>.mat.
% return a string that refers to the location of the written file.
%
% example:
% mkdir('test');
% a = 1; b = 2; save('test/001.mat','a','b');
% a = 3; b = 4; save('test/002.mat','a','b');
% consolidatematdir('test');
% results = loadmulti('test.mat','results');
% results(1)
% results(2)

dir0 = matchfiles(dir0);
dir0 = dir0{1};
[f,file0] = stripfile(dir0);
if isempty(f)  % VOODOO.  BE CAREFUL.
  pre0 = '';
else
  pre0 = [f '/'];
end
consolidatemat([pre0 file0 '/*.mat'],[pre0 file0 '.mat']);
f = [pre0 file0 '.mat'];
