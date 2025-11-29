function results = ptviewmoviecheck2(timeframes,timekeys,triggerkeys,deltatime,wanthide)

% function results = ptviewmoviecheck2(timeframes,timekeys,triggerkeys,deltatime,wanthide)
% 
% <timeframes>,<timekeys> are outputs from ptviewmovie.m
% <triggerkeys> (optional) is a character corresponding to the trigger.
%   We separately process entries in <timekeys> for which the first 
%   character matches <triggerkeys>. Can also be a cell vector of 
%   characters. Default is {'5' 't'}.
% <deltatime> (optional) is the time in milliseconds for which 
%   buttons/triggers are automatically extended if less than this
%   amount of time elapses while the buttons/triggers are still
%   detected. Default is 40.
% <wanthide> (optional) is whether to make the two figure windows that we create
%   invisible. Default: 0.
%
% Draw some figures visualizing the contents of <timeframes> and <timekeys>.
% In the <timekeys> figure, the <mristarttime> is a black line, <buttontimes> are
% colored lines (with text indicating <buttonpressed>), and <triggertimes>
% are light gray lines.
%
% Return <results> as a struct with:
%   <matlabnowtime> is the absolute time for the first frame
%   <mristarttime> is time in seconds (relative to the time of the first frame)
%     that the experiment was started
%   <buttontimes> is a vector of times in seconds indicating button events
%   <buttonpressed> is a cell vector of characters corresponding to <buttontimes>
%   <triggertimes> is a vector of times in seconds indicating trigger events
%   <userkeys> is a cell vector of possible user keys (buttons)
%   <userkeycounts> is a vector of number of times that the keys were pressed.
%
% Compared to ptviewmoviecheck.m, this function (ptviewmoviecheck2.m) is much
% more robust and better at corner cases. It is recommended to use this one for
% mission-critical applications.
%
% See code for internal constants.
%
% example:
% pton;
% [timeframes,timekeys] = ptviewmovie(uint8(255*rand(100,100,3,100)),[],[],2,[],[],[],[],[],0);
% ptoff;
% results = ptviewmoviecheck2(timeframes,timekeys);

%% Setup

% input
if ~exist('triggerkeys','var') || isempty(triggerkeys)
  triggerkeys = {'5' 't'};
end
if ~exist('deltatime','var') || isempty(deltatime)
  deltatime = 40;
end
if ~exist('wanthide','var') || isempty(wanthide)
  wanthide = 0;
end

% internal constants
validkeys = {'1!' '2@' '3#' '4$' '5%' 'r' 'y' 'g' 'b' 't' 'absolutetimefor0' 'trigger' 'DONE'};  % things we expect to get
userkeys = {'1' '2' '3' '4' 'r' 'y' 'g' 'b'};  % user-driven buttons
choicebuttons = {'1' '2' '3' '4'};  % the official buttons we expect subjects to press

% init
clear results;

%% Start the figures

% look at difference in frame times
drawnow; figureprep([],~wanthide); plot(diff(timeframes),'r-');
xlabel('frame difference'); ylabel('duration (seconds)');
title('inspection of timeframes');

% look at timekeys
drawnow; figureprep([50 50 800 300],~wanthide); hold on;

%% Expand simultaneous-keypress cases

% expand multiple-keypress cases
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

%% Deal with terrible button pre-processing stuff

% figure out absolute time for the first frame (this is determined via Matlab's now)
matlabnowtime = timekeysB{find(ismember(timekeysB(:,2),'absolutetimefor0')),1};

% figure out the time that the experiment was started. this time is relative to the
% time of the first frame. for example, -0.017 means we detected the trigger
% 17 ms before we were actually able to show the first stimulus frame.
mristarttime = timekeysB{find(ismember(timekeysB(:,2),'trigger')),1};

% clean up all the button stuff
oldkey = '';
oldkeytime = -Inf;
oldtriggertime = -Inf;
buttontimes = [];    % vector of times in seconds
buttonpressed = {};  % cell vector of characters
triggertimes = [];   % vector of times in seconds
for p=1:size(timekeysB,1)

  % warn if weird key found
  if ~ismember(timekeysB{p,2},validkeys)
    fprintf('*** Unknown key detected (%s); ignoring.\n',timekeysB{p,2});
    continue;
  end

  % figure out auxiliary and trigger events
  bad1a = ismember(timekeysB{p,2},{'absolutetimefor0' 'DONE'});            % auxiliary events (NOTE: 'trigger' is handled in bad1b!!!)
  bad1b = ~bad1a & (ismember(timekeysB{p,2}(1),triggerkeys) | ismember(timekeysB{p,2},{'trigger'}));  % trigger events (as specified by <triggerkeys>, or 'trigger')
  bad = bad1a | bad1b;                                                     % either auxiliary or trigger events

  % is this a "held down" case? (is the current key a user-pressed key that is repeated and within <deltatime>?)
  bad2 = (isequal(timekeysB{p,2},oldkey) & timekeysB{p,1}-oldkeytime <= deltatime/1000);

  % if it appears to be a new key, we should do a special case check for simultaneity.
  % bad3 indicates if we should ignore the current key because it comes while some 
  % other key was originally held down first.
  bad3 = 0;
  if ~bad && ~isequal(timekeysB{p,2},oldkey)  % if not an auxiliary/trigger and appears to be a new user-pressed key

    % scan ahead...
    q = p+1;
    while 1
      if q > size(timekeysB,1)
        break;  % if we run out, just break
      end
      if timekeysB{q,1} > oldkeytime + deltatime/1000
        break;  % if we are past the window, just break
      end
      if isequal(timekeysB{q,2},oldkey)
        bad3 = 1;  % if we are within the deltatime AND it is the same as the old key, then mark the current one for ignoral
        break;
      end
      q = q + 1;
    end

  end

  % if this is a held-down button, just extend the time
  if bad2
    oldkeytime = timekeysB{p,1};
  end

  % if not bogus, then record the button time (for user-pressed keys)
  if ~(bad | bad2 | bad3)
    buttontimes = [buttontimes timekeysB{p,1}];
    buttonpressed = [buttonpressed {timekeysB{p,2}(1)}];
    oldkey = timekeysB{p,2};
    oldkeytime = timekeysB{p,1};
  end

  % deal with triggers
  if bad1b
    if timekeysB{p,1}-oldtriggertime <= deltatime/1000  % if we are within the delta, just extend the time
      oldtriggertime = timekeysB{p,1};
    else
      triggertimes = [triggertimes timekeysB{p,1}];     % otherwise, record it
      oldtriggertime = timekeysB{p,1};
    end
  end

end

% record
results.matlabnowtime = matlabnowtime;
results.mristarttime = mristarttime;
results.buttontimes = buttontimes;
results.buttonpressed = buttonpressed;
results.triggertimes = triggertimes;

%% Do some basic counts of buttons and triggers

% count buttons
userkeycounts = [];
for pp=1:length(userkeys)
  userkeycounts(pp) = sum(ismember(buttonpressed,userkeys{pp}));
end

% record
results.userkeys = userkeys;
results.userkeycounts = userkeycounts;

%% Do some plotting

ylim([0 1.5]);
straightline(mristarttime,'v','k-',[0 0.75]);
cnt = 1;
for p=1:length(buttontimes)
  straightline(buttontimes(p),'v',[getcolorchar(cnt) '-'],[0 1]);
  text(buttontimes(p),1.1 + 0.3*rand,buttonpressed{p},'HorizontalAlignment','center','Color',getcolorchar(cnt));
  cnt = cnt + 1;
end
set(straightline(triggertimes,'v','k-',[0 .5]),'Color',[.7 .7 .7]);
xlabel('time (seconds)');
title('inspection of timekeys');
