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
    a = imrect; wait(a); pos = getPosition(a);
    cmin = round(pos(1));
    rmin = round(pos(2));
    cmax = round(pos(1)+pos(3));
    rmax = round(pos(2)+pos(4));
    close;
  end
  
  % crop image
  im = im(max(1,rmin):min(size(im,1),rmax),max(1,cmin):min(size(im,2),cmax),:);
  
  % write out the image
  imwrite(im,files{p});

end
