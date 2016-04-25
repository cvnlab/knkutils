function [tsnr,mn,mad] = computetemporalsnr(vols,dim)

% function [tsnr,mn,mad] = computetemporalsnr(vols,dim)
%
% <vols> is X x Y x ... x T with time-series along the last dimension (must be 2 or higher).
% <dim> (optional) is the dimension with time-series data. Default: ndims(vols).
%
% return <tsnr> as a matrix of size X x Y x ... with the temporal SNR.
% also, return <mn> with the mean (of the original time-series).
% also, return <mad> with the median absolute difference (see below).
%
% the temporal SNR is defined as follows:
% 1. first regress out a constant and a line from the time-series
%    of each voxel.
% 2. then compute the absolute value of the difference between each
%    pair of successive time points (if there are N time points,
%    there will be N-1 differences).
% 3. compute the median absolute difference (mad).
% 4. divide by the mean of the original time-series and multiply by 100.
% 5. if any voxel had a negative mean, just return the temporal SNR as NaN.
%
% the purpose of the differencing of successive time points is to be relatively
% insensitive to actual activations (which tend to be slow), if they exist.
%
% if <vols> is [], we return [] for all outputs.
%
% example:
% vols = getsamplebrain(4);
% [tsnr,mn,mad] = computetemporalsnr(vols);
% figure; imagesc(makeimagestack(mn));   caxis([0 2500]); axis image; colormap(gray); colorbar;
% figure; imagesc(makeimagestack(mad));  caxis([0 100]);  axis image; colormap(gray); colorbar;
% figure; imagesc(makeimagestack(tsnr)); caxis([0 5]);    axis image; colormap(jet);  colorbar;

% internal constants
maxtsnrpolydeg = 1;

% calc
if ~exist('dim','var') || isempty(dim)
  dim = ndims(vols);
end

% do it
if isempty(vols)
  tsnr = [];
  mn = [];
  mad = [];
else
  mn = mean(vols,dim);
  mad = median(abs(diff( ...
           reshape((projectionmatrix(constructpolynomialmatrix(size(vols,dim), ...
             0:min(size(vols,dim)-1,maxtsnrpolydeg)))*squish(vols,dim-1)')',size(vols)),1,dim)),dim);
  tsnr = negreplace(mad./mn * 100,NaN);
end
