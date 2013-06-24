function h = imageactual(im)

% function h = imageactual(im)
%
% <im> is the filename of an image or an actual image.
%   if the image is double-format, we use imagesc.m to display it;
%   otherwise, we use image.m.
%
% in the current figure, display the image specified by <im> at its 
% native resolution (thus, avoiding downsampling or upsampling).
% this is accomplished by changing the position and size of the current
% figure and its axes.  return the handle of the created image.
%
% example:
% figure; imageactual(getsampleimage);

% read image
if ischar(im)
  im = imread(im);
end

% calc
r = size(im,1);
c = size(im,2);

% change figure position
set(gcf,'Units','points');
pos = get(gcf,'Position');
newx = pos(1) - (c/1.25 - pos(3))/2;
newy = pos(2) - (r/1.25 - pos(4))/2;
set(gcf,'Position',[newx newy c/1.25 r/1.25]);

% change axis position
set(gca,'Position',[0 0 1 1]);

% draw image and set axes
if isa(im,'double')
  h = imagesc(im);
else
  % for some reason, if the image is grayscale, image.m uses only the range 0 to 63 (i think).
  % so, let's just force it to be color.
  if size(im,3)==1
    im = repmat(im,[1 1 3]);
  end
  h = image(im);
end
axis equal tight off;
