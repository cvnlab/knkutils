function thecrop = imcropfiles(files,thecrop,cmap)

% function thecrop = imcropfiles(files,thecrop,cmap)
%
% <files> matches one or more image files
% <thecrop> (optional) is a previous output of this function.
%   This is useful if you want to re-use a crop.  If supplied,
%   we do not need to have any user interaction.
% <cmap> (optional) is a colormap to use for writing indexed
%   color images. If [], don't use a colormap.
%
% this function is for quickly applying a manually
% defined crop to a bunch of images. it is assumed
% that all of the images have the same width and height.
%
% we show the first image and pause to allow the user to use the 
% zoom tool to isolate a section of the image. then, after the
% user presses a key in the command window, we go ahead and apply
% that crop to all of the images and save the results (overwriting
% the original files).
%
% we return the crop in case you want to reuse it.

% input
if ~exist('cmap','var') || isempty(cmap)
  cmap = [];
end

% figure out the file paths
files = matchfiles(files);

% process each image
for p=1:length(files)

  % load the image
  im = imread(files{p});

  % if we don't know the crop, show the first image and let the user set the crop
  if ~exist('thecrop','var') || isempty(thecrop)
    figure;
    image(im);
%    axis image tight;
    thecrop = imrectimagecrop;
    close;
  end
  
  % crop image
  im = im(thecrop(1):thecrop(2),thecrop(3):thecrop(4),:);
  
  % write out the image
  if isempty(cmap)
    imwrite(im,files{p});
  else
    imwrite(im,cmap,files{p});
  end

end
