function imcropfiles(files)

% function imcropfiles(files)
%
% <files> matches one or more image files
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

% figure out the file paths
files = matchfiles(files);

% process each image
for p=1:length(files)

  % load the image
  im = imread(files{p});

  % if the first one, show it and let the user set the axis range
  if p==1
    figure;
    image(im);
%    axis image tight;
    pause;
    ax = round(axis);
    close;
  end
  
  % crop image
  im = im(ax(3):ax(4),ax(1):ax(2),:);
  
  % write out the image
  imwrite(im,files{p});

end
