function f = preparedigits(res,digitsize,grayval,colorval)

% function f = preparedigits(res,digitsize,grayval,colorval)
%
% <res> is the number of pixels
% <digitsize> is the font size in (0,1), relative to the pixels given by <res>
% <grayval> is like 127
% <colorval> is like 255
%
% return some uint8 images.  the dimensions are <res> x <res> x 3 x N.
% the N images are 10 digits (0-9) and then 26 letters (A-Z).
% these are symbols (<colorval>) on a gray background (<grayval>).
%
% example:
% im = preparedigits(100,0.5,127,255);
% figure; imagesc(im(:,:,:,11),[0 255]); colorbar;

% do it
digits = drawtexts(res,0,0,'Helvetica',digitsize, ...
                   [1 1 1],[0 0 0],mat2cell(['0':'9' 'A':'Z'],1,ones(1,10+26)));
digits = round(normalizerange(digits,0,1));  % binarize so that values are either 0 or 1
digsize = sizefull(digits,3);
digits = repmat(vflatten(digits),[1 3]);  % T x 3
whzero = digits(:,1)==0;
digits(whzero,:) = repmat([grayval grayval grayval],[sum(whzero) 1]);  % 0 maps to the grayval
digits(~whzero,:) = colorval;  % 1 maps to the color value

% prepare output
f = uint8(permute(reshape(digits,digsize(1),digsize(2),digsize(3),3),[1 2 4 3]));
