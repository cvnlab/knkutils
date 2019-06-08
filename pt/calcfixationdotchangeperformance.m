function [results,resultsrt] = calcfixationdotchangeperformance(files)

% function [results,resultsrt] = calcfixationdotchangeperformance(files)
%
% <files> matches one or more .mat files that are saved by Kendrick's experiment.
%   These .mat files should reflect the 'press-button-when-fixation-dot-color-changes'
%   task that we often use.
%
% We analyze the button presses in <files> to see how well the subject did.
% 
% We report some information to the command window.
%
% We also return some results in <results> as 4 x N.
%   Each column corresponds to a single file that we processed.
%   The values in each column are [A B C D]
%     where A is the number of total color changes
%           B is the number of successful hits
%           C is the number of false alarms (extra button presses)
%           D is the overall score calculated as (B-C)/A*100
%
% We also return reaction times in <resultsrt> as a cell vector of 1 x N. 
%   Each element is a vector of reaction times in milliseconds.
%   We record only hits (not false alarms).
%
% Note that we assume some internal constants (see code).

% history
% - 2019/06/08 - add resultsrt output. also report buttons pressed to command window.

% internal constants
deltatime = 1;    % holding the key down for less than this time will be counted as one button press
respondtime = 1;  % the subject has this much time to press a button
validkeys = {'1!' '2@' '3#' '4$' '5%' 'r' 'y' 'g' 'b' 't' 'absolutetimefor0' 'trigger'};
userkeys = {'1' '2' '3' '4' 'r' 'y' 'g' 'b'};

% get the files
files = matchfiles(files);

% loop over files
results = zeros(4,length(files));
resultsrt = cell(1,length(files));
for zz=1:length(files)

  % report that we are doing this file
  fprintf('Results for %s:\n',files{zz});

  % load .mat file
  a1 = load(files{zz});

  % expand the multiple-keypress cases [create timekeysB]
  timekeysB = {};
  for p=1:size(a1.timekeys,1)
    if iscell(a1.timekeys{p,2})
      for pp=1:length(a1.timekeys{p,2})
        timekeysB{end+1,1} = a1.timekeys{p,1};
        timekeysB{end,2} = a1.timekeys{p,2}{pp};
      end
    else
      timekeysB(end+1,:) = a1.timekeys(p,:);
    end
  end

  % figure out when the user pressed a button [buttontimes]
  oldkey = ''; oldkeytime = -Inf;
  buttontimes = [];
  buttonpressed = {};
  for p=1:size(timekeysB,1)
  
    % warn if weird key found
    if ~ismember(timekeysB{p,2},validkeys)
      fprintf('*** Unknown key detected (%s); ignoring.\n',timekeysB{p,2});
      continue;
    end

    % is this a bogus key press?
    bad = isequal(timekeysB{p,2},'absolutetimefor0') | ...
          isequal(timekeysB{p,2},'trigger') | ...
          isequal(timekeysB{p,2}(1),a1.triggerkey) | ...
          (isequal(timekeysB{p,2},oldkey) & timekeysB{p,1}-oldkeytime <= deltatime);

    % if not bogus, then record the button time
    if ~bad
      buttontimes = [buttontimes timekeysB{p,1}];
      buttonpressed = [buttonpressed {timekeysB{p,2}(1)}];
      oldkey = timekeysB{p,2};
      oldkeytime = timekeysB{p,1};
    end

  end

  % figure out when the dot switched colors [changetimes]
  seq = abs(diff(a1.fixationorder(2:end-2))) > 0;   % NOTE THIS HARD CODING of 2:end-2
  changetimes = a1.timeframes(find(seq) + 1);
  numtot = length(changetimes);

  % figure out the number of hits [numhits]
  numhits = 0;
  for q=1:length(changetimes)
    okok = (buttontimes > changetimes(q)) & (buttontimes <= changetimes(q) + respondtime);
    if any(okok)
      numhits = numhits + 1;
      resultsrt{zz} = [resultsrt{zz} (buttontimes(firstel(find(okok))) - changetimes(q)) * 1000];
      buttontimes(firstel(find(okok))) = [];  % remove!
    end
  end

  % figure out the number of false alarms [numfalse]
  numfalse = length(buttontimes);
  finalscore = (numhits-numfalse)/numtot*100;

  % report buttons pressed (just for sanity checking)
  fprintf('Number of pressed buttons:\n');
  for pp=1:length(userkeys)
    fprintf('%s: %d\n',userkeys{pp},sum(ismember(buttonpressed,userkeys{pp})));
  end

  % report score
  fprintf('==============================================================\n');
  fprintf(['Out of %d events, you had %d hits and %d false alarms.\n' ...
           'Your score is %d/%d = %d%%.\n' ...
           'Your median RT is %d ms.\n'], ...
          numtot,numhits,numfalse,numhits-numfalse,numtot,round(finalscore), ...
          round(median(resultsrt{zz})));
  fprintf('==============================================================\n');
  
  % record results
  results(:,zz) = [numtot numhits numfalse finalscore];

end
