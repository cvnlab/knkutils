function results = basicsdtbehavioralanalysis(filenames,choicebuttons,responsewindow);

% function results = basicsdtbehavioralanalysis(filename,choicebuttons,responsewindow);
%
% <filenames> is the .mat file (or cell vector of .mat files) saved from one of the 
%   experiments that conform to a "signal detection" style task. This includes:
%   - runafloc.m (136)
% <choicebuttons> is {C1 C2} such that C1 means different and C2 means same.
%   Default: {'1' '2'}.
% <responsewindow> is [A B] indicating number of milliseconds post-event
%   over which buttons are detected.  For example, [0 4500] means buttons
%   are detected in the range [0,4500] milliseconds after the event.
%
% Check timing and analyze the behavioral data.
% We report information to the command window and
% also return <results>.
%
% <results> is a struct with fields:
%   <presults> is the output of ptviewmoviecheck2.m with lots of information
%     on timing, buttons, and triggers. (In the case of multiple files, this
%     will be a struct array.)
%   <trialinfo> is N x 8 where N is the number of events
%     column 1 is run number (determined via the order of <filenames>)
%     column 2 is event number (within each run)
%     column 3 is the condition number being presented on this trial
%     column 4 is the event time (i.e. time that image comes on) as 
%                 a MATLAB serial date number. the units are days.
%     column 5 is the correct answer: 0 (different) or 1 (same)
%     column 6 is the correctness of the response: 0 (incorrect) or 1 (correct)
%     column 7 is reaction time in milliseconds (time between trial start time
%                 and button-press time). Will be NaN if the button was not pressed.
%     column 8 is the button that we officially score (this will be either 1, 2, or NaN)
%     Note that columns 7-8 are NaN if no button was pressed for this trial.
%   <responserate> is percent of events with at least a button press
%   <medianrt> is the median reaction time in milliseconds
%   <sdtmatrix> as 2 x 2 with [HIT MISS; FA CR]
%   <dprime> with the d-prime performance
%
% We process the last button detected in the <responsewindow>.
% We look specifically for buttons named in <choicebuttons>.
% If the subject fails to press a button, this is treated as an incorrect response,
% and the SDT matrix is incremented accordingly.

% history:
% - 2026/11/26 - initial version

%% Deal with inputs

% input
if ischar(filenames)
  filenames = {filenames};
end

%% Process each file

% initialize
clear results presults;
results.trialinfo = zeros(0,8);

% loop over each .mat file
tcnt = 1;  % counter for trialinfo
sdtmatrix = zeros(2,2);  % row 1: hit miss, row 2: FA CR
for ff=1:length(filenames)

  %% Load data

  a1 = load(filenames{ff});

  %% Simple frame and duration stuff

  % pre-process using ptviewmoviecheck2.m
  presults(ff) = ptviewmoviecheck2(a1.timeframes,a1.timekeys,[],[],NaN);

  % sanity check that the right buttons were being pressed in the run
  assert(sum(presults(ff).userkeycounts(str2double(choicebuttons))) > .95 * sum(presults(ff).userkeycounts));

  %% Now analyze the behavior

  % make a temporary copy of the buttons for processing purposes
  buttontimes0   = presults(ff).buttontimes;
  buttonpressed0 = presults(ff).buttonpressed;

  % ignore irrelevant buttons
  ok = ismember(buttonpressed0,choicebuttons);
  buttontimes0 = buttontimes0(ok);
  buttonpressed0 = buttonpressed0(ok);

  % general approach:
  % start grading from 1st stim trial through last stim trial.
  % subject has <responsewindow> time to respond
  % every stim trial has a correct answer!
  % SDT interpretation:
  % - a same image is akin to a "signal" and if you say "same" it is a hit.
  % - a different image is akin to "no signal" and if you say "different" it is correct rejection.
  % if no response, that is counted as getting it wrong.

  % loop
  cnt = 1;   % counter for stimulus trial
  for p=1:size(a1.trialpattern)
    temp = find(a1.trialpattern(p,:));
  
    % if this is not a stimulus trial, just continue
    if isempty(temp)
      continue;
    end

    % record basic information
    results.trialinfo(tcnt,[1 2 3]) = [ff cnt a1.stimclassrec(cnt)];
      
    % calc some times
    assert(isequal(a1.ptonparams{1}(3)/a1.frameduration,60));  % ensure we operate at 60 frames per second
    ondur = length(a1.onpattern);
    trialstart  = presults(ff).timeframes((p-1)*ondur + 1);  % time of first frame for this stimulus trial
    windowstart = trialstart + responsewindow(1)/1000;
    windowend =   trialstart + responsewindow(2)/1000;
  
    % what is the absolute time that the trial started?
    results.trialinfo(tcnt,4) = presults(ff).matlabnowtime + trialstart/60/60/24;  % convert from seconds to days and then add in

    % what is the correct answer?
    if cnt==1  % special case
      correctanswer = 0;  % 0 for first trial
    else
      correctanswer = double(a1.stimclassrec(cnt)==a1.stimclassrec(cnt-1));  % if same, value is 1
    end
    results.trialinfo(tcnt,5) = correctanswer;

    % check if the button was pressed
    okok = (buttontimes0 >  windowstart) & ...
           (buttontimes0 <= windowend);  % logical vector same size as buttontimes0
    if any(okok)
      ix = lastel(find(okok));  % index of the one we will pull out
      rt = (buttontimes0(ix) - trialstart)*1000;
      results.trialinfo(tcnt,7) = rt;
      if isequal(buttonpressed0{ix},choicebuttons{1})
        results.trialinfo(tcnt,8) = 1;
      else
        results.trialinfo(tcnt,8) = 2;
      end
      if correctanswer==1
        if isequal(buttonpressed0{ix},choicebuttons{1})  % stim was a repeat, but subject said "new" ("different")
          sdtmatrix(1,2) = sdtmatrix(1,2) + 1;  % miss
          results.trialinfo(tcnt,6) = 0;
        else
          sdtmatrix(1,1) = sdtmatrix(1,1) + 1;  % hit
          results.trialinfo(tcnt,6) = 1;
        end
      else
        if isequal(buttonpressed0{ix},choicebuttons{1})  % stim was a novel one, subject said "new" ("different")
          sdtmatrix(2,2) = sdtmatrix(2,2) + 1;  % CR
          results.trialinfo(tcnt,6) = 1;
        else
          sdtmatrix(2,1) = sdtmatrix(2,1) + 1;  % FA
          results.trialinfo(tcnt,6) = 0;
        end
      end

    % if no buttons pressed
    else
      results.trialinfo(tcnt,[6 7 8]) = [0 NaN NaN];
      if correctanswer==1
        sdtmatrix(1,2) = sdtmatrix(1,2) + 1;  % stim was a repeat, subject missed it
      else
        sdtmatrix(2,1) = sdtmatrix(2,1) + 1;  % stim was a novel one, subject false alarmed
      end
    end

    % increment the counters
    cnt = cnt + 1;
    tcnt = tcnt + 1;

  end

  % check
  assert((cnt-1)==length(a1.stimclassrec));

end

% calculate some summary metrics
results.responserate = sum(~isnan(results.trialinfo(:,7))) / size(results.trialinfo,1) * 100;  % percent trials with button press
results.medianrt = nanmedian(results.trialinfo(:,7));

% compute d'
hitrate = sdtmatrix(1,1) / sum(sdtmatrix(1,:));
falsealarmrate = sdtmatrix(2,1) / sum(sdtmatrix(2,:));
A = norminv(1-max(min(hitrate,.99),.01),0,1);
B = norminv(1-max(min(falsealarmrate,.99),.01),0,1);

% record
results.sdtmatrix = sdtmatrix;
results.dprime = -A + B;

% include preprocessing results
results.presults = presults;

% report scores
fprintf('==============================================================\n');
fprintf('hitrate is %.2f, falsealarmrate is %.2f\n',hitrate,falsealarmrate);
fprintf('full 2x2 matrix is %s.\n',mat2str(sdtmatrix));
fprintf(['d-prime is %.2f.\n'],results.dprime);
fprintf('==============================================================\n');
