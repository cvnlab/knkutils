function [split_design_mats, R] = condition_split(design_mats,R)

% function [split_design_mats, R] = condition_split(design_mats,R)
%
%	INPUTS:
%		design_mats - a cell array of binary N x C matrices, where N is the number of timepoints
%		  and C is the number of conditions (i.e. number of regressors). Number of cells = number of runs
%   R (optional) - the number of condition splits to create.  if [] or not supplied, default
%     to the total number of times the first condition is shown in the first run.
%     otherwise, supply a positive integer (and it's okay if not perfectly evenly 
%     divisible into the number of repetitions!).
%
% CONDITION_SPLIT splits binary design matrices by condition repetition
%	For example, an N x C matrix (N timepoints, C conditions) will be expanded to 
%	an N x (R * C) matrix, where R is the number of condition splits.
%
% history:
% - 2017/12/13 - make more general (implement R as input)

	% Convert all matrices to full if sparse
	if (issparse(design_mats{1}))
		for run_idx = 1:numel(design_mats)
			design_mats{run_idx} = full(design_mats{run_idx});
		end
	end

	% Get number of TRs (N) and conditions (C)
	[N, C] = size(design_mats{1});

	% Determine number of repetitions, R
	if ~exist('R','var') || isempty(R)
  	R = sum(design_mats{1}(:,1));
  end

	% Make split_design_mats
	split_design_mats = cell(1,numel(design_mats));

	% Do condition_split over each run
	for run_idx = 1:numel(design_mats)
		dmat = design_mats{run_idx};
	
		% Split and re-sparsify
		split_design_mats{run_idx} = sparse(split(dmat, N, C, R));		
	end

end %end fx

%% HELPER FUNCTIONS
function split_mat = split(orig, N, C, R)
  % Note that R can be any positive integer!!
	
	split_mat = [];

	% Expand each column
	for c_idx = 1:C
		col = orig(:,c_idx);
		expanded_col = expand_col(col,R);

		% Append to existing matrix
		split_mat = [split_mat expanded_col];
	end
end

function ex_col = expand_col(col,R)
  % Note that R can be any positive integer!!

	% prepare expanded column matrix
	ex_col = zeros(length(col),R);

	% determine random order for condition occurence
	hot_TRs = find(col==1);
	order = randperm(length(hot_TRs));
	hot_TRs = hot_TRs(order);

	% assign groups of occurences to a regressor (depending on what R is)
	for i=1:R
	  ix = picksubset(1:length(hot_TRs),[R i]);
		ex_col(hot_TRs(ix),i) = 1;
	end		
end
