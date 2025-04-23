function f = distributewithconstraints(totalamt,validoptions,numbins,mode,numlookback)

% function f = distributewithconstraints(totalamt,validoptions,numbins,mode,numlookback)
%
% <totalamt> is a positive integer with the total amount of stuff to distribute
% <validoptions> is a vector of unique non-negative integers. It indicates 
%   the bin sizes that are valid to use.
% <numbins> is a positive integer with the number of bins
% <mode> (optional) is
%   0 means to start with bin sizes that are uniformly randomly sampled
%   1 means to start with all bins being the smallest size
%   2 means to start with all bins being the largest size
%   3 means to start with all bins being the middle size (rounding if necessary)
%   Default: 0.
% <numlookback> (optional) is a positive integer indicating how many 
%   iteration errors to average over to check that the error is decreasing.
%   Default: 50.
%
% We figure out how to distribute <totalamt> into <numbins> bins
% such that each bin contains one of the amounts listed in <validoptions>.
%
% We return a vector of length <numbins> where the elements indicate the 
% amounts selected for each bin. The order of the elements is arbitrary
% and can be treated as if they are in random order.
%
% Our algorithm starts with a seed specified by <mode>. We simply
% randomly choose a bin to update, moving by the minimum amount possible
% towards achieving the solution. If a bin cannot be updated, we skip it;
% if no bins can be updated, we crash (as there is no solution).
%
% It is possible that this algorithm may not find a solution (even if
% there is one).
%
% It is also possible that the algorithm may proceed infinitely; hence,
% we stop if the mean error in <numlookback> iterations for the 
% two most recent sets of iterations does not decrease.
% This should be fine for most use-cases, but do be careful about 
% perniciously long execution times.
%
% Example:
% distributewithconstraints(10,[1 2 3],5)

% inputs
if ~exist('mode','var') || isempty(mode)
  mode = 0;
end
if ~exist('numlookback','var') || isempty(numlookback)
  numlookback = 50;
end

% ensure sorted and unique
validoptions = sort(validoptions);

% as a starting point, draw uniform random index for each bin
switch mode
case 0
  ix = ceil(rand(1,numbins)*length(validoptions));
case 1
  ix = repmat(1,[1 numbins]);
case 2
  ix = repmat(length(validoptions),[1 numbins]);
case 3
  ix = repmat(round(length(validoptions)/2),[1 numbins]);
end

% construct the initial guess for the solution
f = validoptions(ix);

% loop
err = [];
while 1
  err(end+1) = abs(sum(f)-totalamt);  % how much absolute error do we have?
  if sum(f)==totalamt  % if we got the total right, we are done!
    break;
  end
  trylist = randperm(numbins);  % we will try to tweak each bin (in some random order)
  fail = 0;
  for zz=1:length(trylist)
    wh = trylist(zz);
    if sum(f) < totalamt  % if we have too little
      ii = find(validoptions > f(wh));  % find the first option that is greater than the bin we are trying to tweak
    else  % we have too much
      ii = find(validoptions < f(wh));  % find the last option that is less than the bin we are trying to tweak
    end
    if isempty(ii)
      if zz==length(trylist)
        fail = 1;  % oops. there is no bin that we can tweak to improve the solution!
      end
    else
      if sum(f) < totalamt
        f(wh) = validoptions(ii(1));    % use first option and update the solution
      else
        f(wh) = validoptions(ii(end));  % use last option and update the solution
      end
      break;
    end
  end
  if fail
    error('Solution cannot be achieved.');
  end
  if length(err) >= 2*numlookback
    if ~(mean(err(end-numlookback+1:end)) < mean(err(end-2*numlookback+1:end-numlookback)))
      error('Error not decreasing; perhaps there is no solution?');
    end
  end
end
