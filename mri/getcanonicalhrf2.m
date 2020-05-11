function hrf = getcanonicalhrf2(duration,tr)

% function hrf = getcanonicalhrf2(duration,tr)
%
% <duration> is the duration of the stimulus in seconds.
%   should be a multiple of 0.1 (if not, we round to the nearest 0.1).
%   0 is automatically treated as 0.1.
% <tr> is the TR in seconds.
%
% generate two predicted HRFs to a stimulus of duration <duration>, 
% with data sampled at a TR of <tr>. the first HRF reflects the
% group-average "Early" timecourse whereas the second HRF reflects
% the group-average "Late" timecourse (as described in Kay et al.,
% Temporal Decomposition Method...).
%
% the resulting HRFs are returned as 2 x time. the first point is 
% coincident with stimulus onset. each HRF is normalized such 
% that the maximum value is one.
%
% example:
% hrf = getcanonicalhrf2(4,1);
% figure; plot(0:size(hrfs,2)-1,hrf,'o-');

% constants (taken from Kay et al.)
paramsearly = [7.21 17.6  0.5  4.34 1.82 -3.09   50];
paramslate =  [5.76 21.6  1.11 1.72 3.34 0.193   50];

% inputs
if duration == 0
  duration = 0.1;
end

% obtain canonical response to a 0.1-s stimulus
hrf = cat(1,spm_hrf(0.1,paramsearly)', ...
            spm_hrf(0.1,paramslate)');

% convolve to get the predicted response to the desired stimulus duration
trold = 0.1;
hrf = conv2(hrf,ones(1,max(1,round(duration/trold))));

% resample to desired TR
hrf = interp1((0:size(hrf,2)-1)*trold,hrf',0:tr:(size(hrf,2)-1)*trold,'pchip')';

% make the peak equal to one
hrf = hrf ./ repmat(max(hrf,[],2),[1 size(hrf,2)]);
