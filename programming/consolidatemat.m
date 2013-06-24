function results = consolidatemat(files,outfile)

% function results = consolidatemat(files,outfile)
%
% <files> is a wildcard matching one or more .mat files
% <outfile> (optional) is a .mat file to write 'results' to.
%   if [] or not supplied, don't write to a .mat file.
%
% we use matchfiles.m to match the <files>.
% we then construct a struct array with elements 
%   containing the results of loading each .mat file.
% this array is named 'results' and we save it
%   to <outfile> if supplied.
%
% example:
% a = 1; b = 2; save('test001.mat','a','b');
% a = 3; b = 4; save('test002.mat','a','b');
% consolidatemat('test*.mat','final.mat');
% results = loadmulti('final.mat','results');
% results(1)
% results(2)

% TODO: what about mismatches in the contents of the files?
%       save only the intersection?  report to screen?

% input
if ~exist('outfile','var') || isempty(outfile)
  outfile = [];
end

% do it
files = matchfiles(files);
clear results;
fprintf('consolidatemat: ');
for p=1:length(files)
  statusdots(p,length(files));
  a = load(files{p});
  if exist('results','var')
    assert(isequal(sort(fieldnames(results(1))),sort(fieldnames(a))), ...
           sprintf('unexpected fields in file "%s"',files{p}));
  end
  results(p) = a;
end
if ~isempty(outfile)
  fprintf('saving...');
  save(outfile,'results');
end
fprintf('done.\n');
