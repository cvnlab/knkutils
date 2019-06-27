function thecrop = imrectimagecrop

% function thecrop = imrectimagecrop
%
% Allow user to use imrect.m to define a rectangle on the image
% in the current axes. Return [RMIN RMAX CMIN CMAX]
% corresponding to valid crop indices of the image.
% These indices are integer and are within the valid
% image extent.

h = findobj(gca,'type','image');
a = imrect; wait(a); pos = getPosition(a);
cmin = round(pos(1));
rmin = round(pos(2));
cmax = round(pos(1)+pos(3));
rmax = round(pos(2)+pos(4));
rmin = max(1,rmin);
rmax = min(size(h.CData,1),rmax);
cmin = max(1,cmin);
cmax = min(size(h.CData,2),cmax);
thecrop = [rmin rmax cmin cmax];
