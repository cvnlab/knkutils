function imagesequencetomovie(images0,mov0,framerate,opts,imscfactor)

% function imagesequencetomovie(images0,mov0,framerate,opts,imscfactor)
%
% <images0> is
%   (1) a path to a directory that contains image files
%   (2) a wildcard pattern matching image files
%   (3) a 3D or 4D uint8 matrix of images
% <mov0> (optional) is output movie file to write.
%   If <images0> is of case (1), then we default to [images0 '.mov'].
%   Otherwise, we default to 'images.mov'.
% <framerate> (optional) is the frames per second for the output movie.
%   Default: 10.
% <opts> (optional) are optional arguments to QTWriter, e.g.
%   {'Loop' 'loop'}.
% <imscfactor> (optional) is a last-minute imresize scale factor to use
%   before writing the movie frames.  Default: 1.
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
if ~exist('opts','var') || isempty(opts)
  opts = {};
end
if ~exist('imscfactor','var') || isempty(imscfactor)
  imscfactor = 1;
end

% if a directory, load in the images
if ischar(images0)

  % get the dir
  images0 = matchfiles(images0);

  % if match just one, this is the directory case
  if length(images0)==1
  
    % massage
    images0 = images0{1};

    % strip /
    if isequal(images0(end),filesep)
      images0 = images0(1:end-1);
    end
  
    % save the directory name
    dirname0 = images0;

    % read all the images
    images0 = imreadmulti(fullfile(images0,'*'));

  else

    % read all the images
    images0 = imreadmulti(images0);

  end

end

% inputs
if ~exist('mov0','var') || isempty(mov0)
  if exist('dirname0','var')
    mov0 = [dirname0 '.mov'];
  else
    mov0 = 'images.mov';
  end
end

% init the movie
mov = QTWriter(mov0,opts{:});
mov.FrameRate = framerate;

% if 3D grayscale images, reshape them..
if size(images0,4)==1
  images0 = permute(images0,[1 2 4 3]);
end

% write the movie
for p=1:size(images0,4)
  if imscfactor ~= 1
    writeMovie(mov,imresize(images0(:,:,:,p),imscfactor));
  else
    writeMovie(mov,images0(:,:,:,p));
  end
end

% finish up
close(mov);
