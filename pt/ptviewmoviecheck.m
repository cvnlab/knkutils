function ptviewmoviecheck(timeframes,timekeys,deltatime,badkey)

% function ptviewmoviecheck(timeframes,timekeys,deltatime,badkey)
% 
% <timeframes>,<timekeys> are outputs from ptviewmovie.m
% <deltatime> (optional) is the time differential in seconds that must
%   be exceeded for a key that is detected twice in a row to be
%   counted as an actual keypress for display purposes.  default: 1.
% <badkey> (optional) is a character.  ignore entries in <timekeys>
%   for which the first character matches <badkey>.  if [] do nothing special.
%
% draw some figures visualizing the contents of <timeframes> and <timekeys>.
%
% example:
% pton;
% [timeframes,timekeys] = ptviewmovie(uint8(255*rand(100,100,3,100)),[],[],2,[],[],[],[],[],0);
% ptoff;
% ptviewmoviecheck(timeframes,timekeys);

% input
if ~exist('deltatime','var') || isempty(deltatime)
  deltatime = 1;
end
if ~exist('badkey','var') || isempty(badkey)
  badkey = [];
end

% look at difference in frame times
drawnow; figure; plot(diff(timeframes),'r-');
xlabel('frame difference'); ylabel('duration (seconds)');
title('inspection of timeframes');

% look at timekeys
drawnow; figure; setfigurepos([50 50 800 300]); hold on;
oldkey = ''; oldkeytime = -Inf; cnt = 0;
  % first we have to expand the multiple key press cases
timekeysB = {};
for p=1:size(timekeys,1)
  if iscell(timekeys{p,2})
    for pp=1:length(timekeys{p,2})
      timekeysB{end+1,1} = timekeys{p,1};
      timekeysB{end,2} = timekeys{p,2}{pp};
    end
  else
    timekeysB(end+1,:) = timekeys(p,:);
  end
end
  % then we can process
for p=1:size(timekeysB,1)
  if ~isequal(timekeysB{p,2},'absolutetimefor0') && ...
     (isempty(badkey) || ~isequal(timekeysB{p,2}(1),badkey)) && ...
     (~isequal(timekeysB{p,2},oldkey) || timekeysB{p,1}-oldkeytime > deltatime)  % if we have found a new key
    straightline(timekeysB{p,1},'v',[getcolorchar(cnt) '-']);
    text(timekeysB{p,1},1.1 + 0.5*rand,timekeysB{p,2},'HorizontalAlignment','center','Color',getcolorchar(cnt));
    cnt = cnt + 1;
    oldkey = timekeysB{p,2};
    oldkeytime = timekeysB{p,1};
  end
end
xlabel('time');
ax = axis;
axis([ax(1:2) 0 1.6]);
title(sprintf('inspection of timekeys (repeated keys within %.1f s are not shown)',deltatime));
