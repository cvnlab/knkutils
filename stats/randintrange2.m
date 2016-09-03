function f = randintrange2(x,y,num,prob,wantnotriplets)

% function f = randintrange2(x,y,num,prob,wantnotriplets)
% 
% <x> and <y> are integers such that <x> <= <y>
% <num> is the number of integers desired
% <prob> is the desired probability of a repetition occurring
% <wantnotriplets> (optional) is whether to enforce that the maximum number
%   of integers occurring in a row is 2.  note that this violates the purity
%   of <prob>.  default: 0.
%
% return a vector of length <num> with integers in the range [<x>,<y>] inclusive.
%
% example:
% randintrange2(1,10,10,.5,1)

% input
if ~exist('wantnotriplets','var') || isempty(wantnotriplets)
  wantnotriplets = 0;
end

% init
lastdigit = NaN;    % record of the last digit
repeated = 0;       % whether we have just repeated
f = zeros(1,num);   % the final result

% do it
for p=1:num
  case1 = wantnotriplets && repeated;   % if we want to avoid triplets and we have just repeated...
  case2 = wantnotriplets && ~repeated;  % if we want to avoid triplets and we haven't just repeated...
  case3 = ~wantnotriplets;              % if we don't care about triplets
  if case2 || case3                     % this is the "free" case. we don't have to worry about triplets.
    if p~=1 && rand <= prob             % assuming we aren't on the first one, we rolled our die and decided to repeat
      digit = lastdigit;
      repeated = 1;
    else                                % otherwise, choose a random one that does not repeat
      while 1
        digit = randintrange(x,y);
        if digit ~= lastdigit
          repeated = 0;
          break;
        end
      end
    end
  else                                  % in this case, we have to not repeat
    while 1
      digit = randintrange(x,y);
      if digit ~= lastdigit
        repeated = 0;
        break;
      end
    end
  end
  f(p) = digit;
  lastdigit = digit;
end
