function results = basicdetectionbehavioralanalysis(filenames,choicebutton,responsewindow)

% function results = basicdetectionbehavioralanalysis(filenames,choicebutton,responsewindow)
%
% <filenames> is the .mat file (or cell vector of .mat files) saved from one of the 
%   experiments that conform to a "basic detection" style task. This includes:
%   - runvcdprf.m (137, 138, 139) [both the fixation and detection tasks are supported]
%   - runnslook.m (134)
%   Note that it is also possible to use this function to process .mat files with no
%   grading of behavior; in that case, pass <choicebutton> as [].
% <choicebutton> is like '1' indicating which button we will actually
%   process. We ignore any button that is not <choicebutton>.
%   Special case is [] which means no behavior is to be graded.
% <responsewindow> is [A B] indicating number of milliseconds post-event
%   over which a correct response is detected.  For example, [0 1000]
%   means buttons detected in the range [0,1000] milliseconds after the
%   triggering event are deemed to be correct. When <choicebutton> is [],
%   just set <responsewindow> to [].
%
% Check timing and analyze the behavioral data.
% We report information to the command window and
% also return <results>.
%
% <results> is a struct with fields:
%   <presults> is the output of ptviewmoviecheck2.m with lots of information
%     on timing, buttons, and triggers. (In the case of multiple files, this
%     will be a struct array.)
%   <trialinfo> is N x 5 where N is the number of events
%     column 1 is run number (determined via the order of <filenames>)
%     column 2 is event number (within each run)
%     column 3 is the condition number being presented on this trial (expt 134)
%              or otherwise NaN (expt 137-139)
%     column 4 is the event time as a MATLAB serial date number. the units are days.
%     column 5 is reaction time in milliseconds (time between event time
%                 and button-press time). Will be NaN if the button was not pressed.
%   <performance> is [A B C D] where
%     A is the number of total events
%     B is the number of successful hits
%     C is the number of false alarms (extra button presses)
%     D is the overall score calculated as (B-C)/A*100
%   <rts> is a vector corresponding to hits (in chronological order),
%     containing reaction times in milliseconds.
%   <medianrt> is the median of <rts>

% history:
% - 2026/11/25 - allow <choicebutton> to be [].
% - 2026/11/22 - augment to support nslook. allow multiple files. add <trialinfo> output. put into knkutils.
% - 2026/07/09 - initial version

%% Deal with inputs

% input
if ischar(filenames)
  filenames = {filenames};
end

%% Process each file

% initialize
clear results presults;
results.rts = [];
results.trialinfo = zeros(0,5);
numhits = 0;
numfalse = 0;
numtot = 0;
cnt = 1;

% loop over each .mat file
for p=1:length(filenames)

  %% Load data

  a1 = load(filenames{p});

  %% Simple frame and duration stuff

  % pre-process using ptviewmoviecheck2.m
  presults(p) = ptviewmoviecheck2(a1.timeframes,a1.timekeys,[],[],NaN);

  % sanity check that the right button was being pressed in the run
  if ~isempty(choicebutton)
    assert(presults(p).userkeycounts(str2double(choicebutton)) > .95 * sum(presults(p).userkeycounts));
  end

  %% Now analyze the behavior

  % determine when the events occurred.
  % <mainevents> will be indices of the events relative to the actual number of frames in the experiment
  if ~isempty(choicebutton)
    switch a1.setnum(1)
    case {137 138 139}

      % fixation task
      if ~isempty(regexp(a1.setupscript,'fixationsubjectinstructions'))
        mainevents = find(diff(a1.fixationorder(2:end-2)==-1)==1) + 1;  % indices of transitions from some other color to red
      % detection task
      elseif ~isempty(regexp(a1.setupscript,'detectionsubjectinstructions'))
        mainevents = find(a1.targetoccurrence);  % indices of onsets of the target object
      else
        error('could not detect what task this is!');
      end
  
    case {134}
  
      mainevents = find(diff(sum(a1.trialpattern,2))==1) + 1;  % indices of onset of stimuli
      assert(isequal(a1.classorder,1:length(a1.classorder)));

    end
  else
    mainevents = [];
  end

  % <eventtimes> will be the precise times that these events occurred
  eventtimes = presults(p).timeframes(mainevents);
  assert(all(isfinite(eventtimes)));

  % calculate number of total events
  numtot = numtot + length(mainevents);

  % make a temporary copy for processing purposes
  buttontimes0   = presults(p).buttontimes;
  buttonpressed0 = presults(p).buttonpressed;

  % ignore irrelevant buttons
  if ~isempty(choicebutton)
    ok = ismember(buttonpressed0,choicebutton);
    buttontimes0 = buttontimes0(ok);
    buttonpressed0 = buttonpressed0(ok);
  end

  % process each event
  for q=1:length(eventtimes)

    % record trialinfo
    results.trialinfo(cnt,[1 2]) = [p q];
    switch a1.setnum(1)
    case {137 138 139}
      results.trialinfo(cnt,3) = NaN;
    case {134}
      results.trialinfo(cnt,3) = find(a1.trialpattern(mainevents(q),:));  % strong assumption of no randomization! (see classorder. may need to revisit as more experiments are added)
    end
    results.trialinfo(cnt,4) = presults(p).matlabnowtime + eventtimes(q)/60/60/24;  % convert from seconds to days and then add in

    % check if the button was pressed
    okok = (buttontimes0 >= eventtimes(q) + responsewindow(1)/1000) & ...
           (buttontimes0 <= eventtimes(q) + responsewindow(2)/1000);  % logical vector same size as buttontimes0
    if any(okok)
      numhits = numhits + 1;
      ix = firstel(find(okok));  % index of the one we will pull out
      rt = (buttontimes0(ix) - eventtimes(q))*1000;
      results.rts = [results.rts rt];
      buttontimes0(ix) = [];    % remove!
      buttonpressed0(ix) = [];  % remove!
      results.trialinfo(cnt,5) = rt;
    else
      results.trialinfo(cnt,5) = NaN;
    end
    
    % increment
    cnt = cnt + 1;

  end

  % figure out the number of false alarms
  numfalse = numfalse + length(buttontimes0);  % anything that remains is a false alarm

end

% calculate final score
finalscore = (numhits-numfalse)/numtot*100;

% record and finish up
results.performance = [numtot numhits numfalse finalscore];
results.medianrt = median(results.rts);

% include preprocessing results
results.presults = presults;

% report score to command window
fprintf('==============================================================\n');
fprintf(['Out of %d events, you had %d hits and %d false alarms.\n' ...
         'Your score is %d/%d = %d%%.\n' ...
         'Your median RT was %d ms.\n'], ...
        numtot,numhits,numfalse,numhits-numfalse,numtot,round(finalscore), ...
        round(results.medianrt));
fprintf('==============================================================\n');
