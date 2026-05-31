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
% colored lines (with text indicating <buttonpressed>), <triggertimes>
% are light gray lines, and <donetime> is a black line.
%
% Return <results> as a struct with:
%   <droppedcnt> is the number of dropped frames
%   <mdtf> is the mean frame-to-frame difference
%   <totaldur> is the total empirical duration of the experiment (partial runs will have low <totaldur>)
%   <donetime> is the time of the end of the experiment
%   <timeframes> is like the original, but with linear interpolation to fix dropped fames
%   <matlabnowtime> is the absolute time for the first frame
%   <mristarttime> is time in seconds (relative to the time of the first frame)
%     that the experiment was started
%   <buttontimes> is a vector of times in seconds indicating button events
%   <buttonpressed> is a cell vector of characters corresponding to <buttontimes>
%   <triggertimes> is a vector of times in seconds indicating trigger events
%   <userkeys> is a cell vector of possible user keys (buttons)
%   <userkeycounts> is a vector of number of times that the keys were pressed
%   <mdf> is the median trigger diff
%   <mdferrs> is a vector of weird trigger diffs expressed in multiples of the <mdf>
%   <numcrazymdferrs> is number of <mdferrs> that are deemed crazy/weird
%   <numwarnings> is the number of warnings detected in this function.
%     a good sign is if this number is 0.
%
% Note that if the total number of triggers is less than 5, we give up and
% return <mdf> as NaN, <mdferrs> as [], and <numcrazymdferrs> as NaN.
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
results.numwarnings = 0;

%% Make timeframes figure

% look at difference in frame times
drawnow; figureprep([50 500 1200 300],~wanthide); plot(diff(timeframes),'r-');
xlabel('frame difference'); ylabel('duration (seconds)');
title('inspection of timeframes (dropped frames => NaN => gaps)');

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

%% Deal with some basic timing stuff

% check for dropped frames
droppedcnt = sum(isnan(timeframes));  % number of dropped frames

% determine last valid recorded timeframe
ix = find(~isnan(timeframes));
actualnum = ix(end);

% calculate mean frame-to-frame difference
  % mdtf = mean(diff(timeframes)); <-- this is the usual version with no NaNs
mdtf = sum(diff(filterout(timeframes,NaN,0))) / (actualnum-1);

% calc total empirical duration of the experiment (this includes the full completion of the last frame).
% in the case of partial data (run stopped early), we calculate duration up through the last valid recorded timeframe 
totaldur = mdtf * actualnum;

% check ending "trigger" time (recorded after last frame)
ix = find(ismember(timekeysB(:,2),'trigger'));
assert(length(ix) >= 1);
if length(ix) < 2
  warning('*** Did not find the ending "trigger" in timekeys. This must be partial data??? BEWARE! ***');
  results.numwarnings = results.numwarnings + 1;
  donetime = NaN;
else
  assert(length(ix) == 2);
  donetime = timekeysB{ix(2),1};
  timekeysB(ix(2),:) = [];  % NOTE!!! We remove the ending fake trigger to make life easier later
  if abs(donetime-totaldur) > 0.050
    warning('**** the donetime and totaldur are mismatched!! BEWARE!!! ***');
    results.numwarnings = results.numwarnings + 1;
  end
end

% record
results.droppedcnt = droppedcnt;
results.mdtf = mdtf;
results.totaldur = totaldur;
results.donetime = donetime;

%% Interpolate over dropped frames

% use linear interpolation to fill in the NaNs
ii0 = find(~isnan(timeframes));
ii1 = find(isnan(timeframes));
timeframes(ii1) = interp1(ii0,timeframes(ii0),ii1,'linear','extrap');

% record
results.timeframes = timeframes;  % user must use this version from behavioral analysis and not the version in the raw data!!

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

%% Do some basic counts of buttons

% count buttons
userkeycounts = [];
for pp=1:length(userkeys)
  userkeycounts(pp) = sum(ismember(buttonpressed,userkeys{pp}));
end

% record
results.userkeys = userkeys;
results.userkeycounts = userkeycounts;

%% Do some checks of triggers

% calc
totaln = length(triggertimes);  % total number of triggers detected

% if it seems that this is just a behavior experiment
if totaln < 5

  warning('*** Detected less than 5 triggers. This is probably a behavior-only experiment? ***');
  results.numwarnings = results.numwarnings + 1;
  results.mdf = NaN;
  results.mdferrs = [];
  results.numcrazymdferrs = NaN;

% if it seems that this is a run with actual triggers from the scanner
else

  % calculate median trigger diff
  mdf = median(diff(triggertimes));  % typical empirical TR diff

  % find diffs that are more than FRAC larger or FRAC smaller than the mdf.
  % express these as a multiple of the mdf. For example, [1.99860640702692]
  temp = diff(triggertimes);
  errfrac = 0.03125;  % .05 s out of 1.6 s
  mdferrs = temp(temp > mdf*(1+errfrac) | temp < mdf*(1-errfrac)) / mdf;  

  % how many mdf errors are crazy?
  numcrazymdferrs = sum(abs(mdferrs-round(mdferrs)) > 0.01);
  if numcrazymdferrs > 0
    warning('*** We encountered a crazy mdf error; all bets are off!!! ***');
    results.numwarnings = results.numwarnings + 1;
  end

  % record
  results.mdf = mdf;
  results.mdferrs = mdferrs;
  results.numcrazymdferrs = numcrazymdferrs;

end

%% Plot the buttons/triggers

% look at timekeys
drawnow; figureprep([50 50 1200 300],~wanthide); hold on;
ylim([-.1 1.5]);
straightline(mristarttime,'v','k-',[0 0.75]);
cnt = 1;
for p=1:length(buttontimes)
  straightline(buttontimes(p),'v',[getcolorchar(cnt) '-'],[0 1]);
  text(buttontimes(p),1.1 + 0.3*rand,buttonpressed{p},'HorizontalAlignment','center','Color',getcolorchar(cnt));
  cnt = cnt + 1;
end
set(straightline(triggertimes,'v','k-',[-.1 .5]),'Color',[.7 .7 .7]);
straightline(donetime,'v','k-',[0 0.75]);
xlabel('Time (seconds)');
title('Inspection of buttons and triggers');
xlim0 = xlim;
xlim([-10 xlim0(2)+10]);

%% Report to the command window

fprintf('==============================================================\n');
fprintf('Experiment duration (empirical) was %.3f.\n',totaldur);
fprintf('Frames per sec (empirical) was %.6f.\n',1/mdtf);
fprintf('Number of dropped frames: %d.\n',droppedcnt);
fprintf('Median trigger diff: %.6f.\n',mdf);
fprintf('==============================================================\n');
fprintf('Number of pressed buttons:\n');
for pp=1:length(userkeys)
  fprintf('%s: % 5d\n', ...
          userkeys{pp}, ...
          userkeycounts(pp));
end
fprintf('==============================================================\n');
