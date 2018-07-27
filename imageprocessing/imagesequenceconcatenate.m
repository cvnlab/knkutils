function imagesequenceconcatenate(images0,out0,dim,imscfactor)

% function imagesequenceconcatenate(images0,out0,dim,imscfactor)
%
% <images0> is a wildcard pattern matching image files
% <out0> is output image file to write
% <dim> is the dimension along which to concatenate
% <imscfactor> (optional) is a last-minute imresize scale factor to use
%   before concatenating the images.  Default: 1.
%
% Concatenate the images and write to <out0>.
%
% example:
% mkdirquiet('temp');
% for p=1:10
%   imwrite(uint8(repmat(255*rand(1,1,3),[100 100])),sprintf('temp/images%03d.png',p));
% end
% imagesequenceconcatenate('temp/*png','tempALL.png',2);

% inputs
if ~exist('imscfactor','var') || isempty(imscfactor)
  imscfactor = 1;
end

% get the image filenames
images0 = matchfiles(images0);

% do it
im = [];
for p=1:length(images0)
  if imscfactor ~= 1
    im = cat(dim,im,imresize(imread(images0{p}),imscfactor));
  else
    im = cat(dim,im,imread(images0{p}));
  end
end

% write the output image
imwrite(im,out0);
