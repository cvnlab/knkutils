function S = constructpathonsphere(pts,ang)

% function S = constructpathonsphere(pts,ang)
%
% <pts> is N x 3 with a sequence of points on the unit sphere. N must be >= 2.
% <ang> is the desired angular separation between successive points (in degrees)
%
% return <S> as P x 3 with a sequence of points on the unit sphere
% such that these points follow great circles. Note that because of
% discretization, there is some "credit" at the end of one segment
% that carries over to the next segment. Note that we do not necessarily
% reach exactly the last point specified in <pts>.
%
% example:
%
% % create an example dataset
% pts = randn(3,3);
% pts(:,1) = abs(pts(:,1));
% pts = unitlength(pts,2);
% pp = constructpathonsphere(pts,5);
% 
% % visualize using orthographic projection
% figure; hold on;
% scatter(pts(1,2),pts(1,3),'ro');
% scatter(pts(2,2),pts(2,3),'go');
% scatter(pts(3,2),pts(3,3),'bo');
% axis equal square;
% axis([-1.5 1.5 -1.5 1.5]);
% drawellipse(0,0,0,1,1,[],[],'k-');
% scatter(pp(:,2),pp(:,3),'c.');
% 
% % visualize in 3D
% figure; hold on;
% randpts = unitlength(randn(1000,3),2);
% scatter3(randpts(:,1),randpts(:,2),randpts(:,3),'k.');
% scatter3(pts(1,1),pts(1,2),pts(1,3),'ro');
% scatter3(pts(2,1),pts(2,2),pts(2,3),'go');
% scatter3(pts(3,1),pts(3,2),pts(3,3),'bo');
% axis equal square;
% scatter3(pp(:,1),pp(:,2),pp(:,3),'c.');

% initialize
p1ix = 1;
p2ix = 2;
S = pts(p1ix,:);  % start at the first point
credit = 0;       % how much credit have we accrued?

% do it
while p2ix <= size(pts,1)

  % define
  p1 = pts(p1ix,:);
  p2 = pts(p2ix,:);

  % orthogonalize p2 with respect to p1
  p2o = unitlength((projectionmatrix(p1')*p2')');

  % calculate total angular separation from p1 to p2 (radians)
  totalsep = acos(p1*p2');

  % how much have we traveled?
  cur = -credit;
  
  % if we can take a step and still stay within the bounds
  while cur + ang/180*pi <= totalsep
  
    % take the step and record it
    cur = cur + ang/180*pi;
    S(end+1,:) = cos(cur)*p1 + sin(cur)*p2o;
  
  end
  
  % if we are done, we may have some credit for the next round
  credit = totalsep-cur;
  p1ix = p1ix + 1;
  p2ix = p2ix + 1;

end
