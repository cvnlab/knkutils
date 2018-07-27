function imaveragefiles(files,outputfile)

% function imaveragefiles(files,outputfile)
%
% <files> matches one or more image files
% <outputfile> is a target filename
%
% this function averages the RGB values of <files>
% and writes the output to <outputfile>.
%
% it is assumed that all of the <files> have
% exactly the same dimensions.

% figure out the file paths
files = matchfiles(files);

% process each image
temp = 0;
for p=1:length(files)
  im = double(imread(files{p}));
  temp = temp + im / length(files);
end

% write out the average image
imwrite(uint8(temp),outputfile);
