function imagesequencetomovie(images0,mov0,framerate)

% function imagesequencetomovie(images0,mov0,framerate)
%
% <images0> is a path to a directory that contains image files
%   can also be a 3D or 4D uint8 matrix of images.
% <mov0> (optional) is output movie file to write.
%   If <images0> is a directory, we default to [images0 '.mov'].
% <framerate> (optional) is the frames per second for the output movie.
%   Default: 10.
%
% Use QTWriter to make a QuickTime movie from the images in <images0>.
%
% example:
% mkdirquiet('temp');
% for p=1:90
%   imwrite(uint8(255*rand(100,100,3)),sprintf('temp/images%03d.png',p));
% end
% imagesequencetomovie('temp','temp.mov',30);

% inputs
if ~exist('framerate','var') || isempty(framerate)
  framerate = 10;
end

% if a directory, load in the images
if ischar(images0)

  % get the dir
  images0 = matchfiles(images0);

  % make sure just one
  assert(length(images0)==1);
  images0 = images0{1};

  % strip /
  if isequal(images0(end),filesep)
    images0 = images0(1:end-1);
  end
  
  % save the directory name
  dirname0 = images0;

  % read all the images
  images0 = imreadmulti(fullfile(images0,'*'));

end

% inputs
if ~exist('mov0','var') || isempty(mov0)
  mov0 = [dirname0 '.mov'];
end

% init the movie
mov = QTWriter(mov0);
mov.FrameRate = framerate;

% if 3D grayscale images, reshape them..
if size(images0,4)==1
  images0 = permute(images0,[1 2 4 3]);
end

% write the movie
for p=1:size(images0,4)
  writeMovie(mov,images0(:,:,:,p));
end

% finish up
close(mov);
