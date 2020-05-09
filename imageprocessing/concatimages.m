function [f,filenames] = concatimages(files,order,mode,minenlargement)

% function [f,filenames] = concatimages(files,order,mode,minenlargement)
%
% <files> is a pattern that matches image files (see matchfiles.m)
% <order> is a cell vector of things, each of which specifies indices
%   of images to put on the same row (<mode>==0) or same column (<mode>==1).
% <mode> (optional) is 0 (for row) or 1 (for column). Default: 0.
% <minenlargement> (optional) is the minimum enlargement that each image
%   causes along the horizontal dimension (<mode>==0) or the vertical
%   dimension (<mode>==1). If negative, means to also center in that
%   dimension. Default: 0 (which means just adapt to the size of each image).
%
% load and concatenate the images from <files>.
% we do this by first putting images on rows (or columns) and
%   then concatenating the rows (or columns) together.
%   our anchor point is always the upper-left corner.
% we return a uint8 image in <f>.
% we also return a cell vector of the matched filenames in <filenames>.
% we assume that images are either all grayscale or all color.
% we issue a warning if no files are named by <files>.
%
%   OR
%
% function [f,filenames] = concatimages(files)
%
% <files> is a cell vector {A B C ...} where A, B, C, ... are each
%   cell vectors of patterns that match image files (see matchfiles.m)
%
% this is like the previous scheme, except that we have a different
% format for <files>.  each A, B, C, ... corresponds to a row
% in the output image.

% input
if ~exist('mode','var') || isempty(mode)
  mode = 0;
end
if ~exist('minenlargement','var') || isempty(minenlargement)
  minenlargement = 0;
end

if exist('order','var')

  % transform
  filenames = matchfiles(files);
  
  % check sanity
  if length(filenames)==0
    warning('no file matches');
    f = [];
    return;
  end
  
  % do it
  f = [];
  if mode==0
    for pp=1:length(order)
      im0 = [];
      for qq=1:length(order{pp})
        if minenlargement < 0
          temp0 = imread(filenames{order{pp}(qq)});
          temp = placematrix(zeros(size(temp0,1),max(-minenlargement,size(temp0,2)),size(temp0,3)),temp0);
        else
          temp = placematrix2(zeros(0,minenlargement),imread(filenames{order{pp}(qq)}));
        end
        im0 = placematrix2(im0,temp,[1 size(im0,2)+1 1]);
      end
      f = placematrix2(f,im0,[size(f,1)+1 1 1]);
    end
  else
    for pp=1:length(order)
      im0 = [];
      for qq=1:length(order{pp})
        if minenlargement < 0
          temp0 = imread(filenames{order{pp}(qq)});
          temp = placematrix(zeros(max(-minenlargement,size(temp0,1)),size(temp0,2),size(temp0,3)),temp0);
        else
          temp = placematrix2(zeros(minenlargement,0),imread(filenames{order{pp}(qq)}));
        end
        im0 = placematrix2(im0,temp,[size(im0,1)+1 1 1]);
      end
      f = placematrix2(f,im0,[1 size(f,2)+1 1]);
    end
  end
  f = uint8(f);

else

  % do it
  f = []; filenames = {};
  for pp=1:length(files)
    im0 = [];
    for qq=1:length(files{pp})
      temp = matchfiles(files{pp}{qq});
      for rr=1:length(temp)
        filenames = [filenames temp{rr}];
        im0 = placematrix2(im0,imread(temp{rr}),[1 size(im0,2)+1 1]);
      end
    end
    f = placematrix2(f,im0,[size(f,1)+1 1 1]);
  end
  f = uint8(f);

  % check sanity
  if length(filenames)==0
    warning('no file matches');
    f = [];
    return;
  end

end
