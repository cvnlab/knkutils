function f = imrectsquare(pos)

% function f = imrectsquare(pos)
%
% <pos> is the getPosition output applied to an imrect.
%   The interpretation is [X Y Xwidth Ywidth].
%
% crop the position such that we have a square that
% has integer coordinates.
%
% example:
% figure; hold on;
% imagesc(randn(300,100));
% axis image;
% a = imrect;
% wait(a);
% pos = getPosition(a)
% pos2 = imrectsquare(pos)
% plot([pos2(1) pos2(1)+pos2(3)],[pos2(2) pos2(2)+pos2(4)],'m-');

% massage
ax = [pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(4)];

% round to pixels
ax = round(ax);

% trim excess so that we have a square
if ax(2)-ax(1) > ax(4)-ax(3)
  excess = (ax(2)-ax(1)) - (ax(4)-ax(3));
  ax(1) = ax(1) + round(excess/2);
  ax(2) = ax(2) - (excess - round(excess/2));
else
  excess = (ax(4)-ax(3)) - (ax(2)-ax(1));
  ax(3) = ax(3) + round(excess/2);
  ax(4) = ax(4) - (excess - round(excess/2));
end

% un-massage
f = [ax(1) ax(3) ax(2)-ax(1) ax(4)-ax(3)];
