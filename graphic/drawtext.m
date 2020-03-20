function h = drawtext(res,x,y,font,sz,color,bg,word,extraopt)

% function h = drawtext(res,x,y,font,sz,color,bg,word,extraopt)
%
% <res> is
%   0 means standard figure coordinate frame
%  -1 means y-reversed coordinate frame
% <x> is x-position of word
% <y> is y-position of word
% <font> is a string with font name
% <sz> is size in normalized units (relative to size of axes)
% <color> is a 3-element vector with the color (values in [0,1])
% <bg> is a 3-element vector with the background color.
%   [] means do not draw the background.
% <word> is a string
% <extraopt> (optional) is a cell vector of extra options for the text object.
%
% draw text on the current figure.
% the field-of-view of <coord> is assumed to be [-.5,.5]
% <x> and <y> are interpreted with respect to the x-
% and y-axes being bounded by [-.5,.5].  we automatically set the
% axis bounds and also reverse the y-axis if necessary.
% we return the handle to the text object.
%
% example:
% figure; drawtext(0,0,0,'Helvetica',.5,[.5 0 0],[1 1 1],'TEST');

% input
if ~exist('extraopt','var') || isempty(extraopt)
  extraopt = {};
end

% prep figure
hold on;

% draw square for background
if ~isempty(bg)
  hbg = patch([-.5 -.5 .5 .5 -.5],[-.5 .5 .5 -.5 -.5],bg);
  set(hbg,'EdgeColor','none');
end

% draw text
h = text(x,y,word);
set(h,'Color',color,'FontName',font,'FontUnits','normalized', ...
  'FontSize',sz,'HorizontalAlignment','center',extraopt{:});

% prep figure
axis([-.5 .5 -.5 .5]);
if res ~= 0
  set(gca,'YDir','reverse');
end
