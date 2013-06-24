function f = drawpolargrid(res,numspokes,maxecc,numrings,thickness,color)

% function f = drawpolargrid(res,numspokes,maxecc,numrings,thickness,color)
%
% <res> is the number of pixels along one side
% <numspokes> is the positive number of spokes starting from 0 degrees (x+ axis)
% <maxecc> is the number of pixels in the radius of the largest ring
% <numrings> is the positive number of rings
% <thickness> is the line thickness in points
% <color> is a 3-element vector with the line color
%
% draw a polar grid consisting of lines that form rings and spokes.
% the spacing of the rings scales with eccentricity (see code for details).
% return a 2D image where values are in [0,1].
%
% example:
% figure; image(drawpolargrid(600,8,300,5,3,[1 0 0])); axis equal tight;

% internal constants
slope = 1/3;

% calc
angs = linspacecircular(0,pi,numspokes);

% draw spokes
fig = figure; hold on;
for p=1:length(angs)
  xmax = cos(angs(p)) * .5 * (2*maxecc/res);
  ymax = sin(angs(p)) * .5 * (2*maxecc/res);
  h = plot([-1 1] * xmax,[-1 1] * ymax,'r-');
  set(h,'Color',color,'LineWidth',thickness);
end

% figure out ring locations
options = optimset('Display','off','MaxFunEvals',Inf,'MaxIter',Inf,'TolFun',1e-10,'TolX',1e-10);
spaceparams = lsqnonlin(@(x) spatialscaling(x,slope,maxecc), ...
  rand(1,numrings-1),zeros(1,numrings-1),maxecc*ones(1,numrings-1),options);
eccs = [spaceparams maxecc];  % radii in pixels

% draw rings
for p=1:length(eccs)
  h = drawellipse(0,0,0,eccs(p)/res,eccs(p)/res);
  set(h,'Color',color,'LineWidth',thickness);
end

% finish up
axis([-.5 .5 -.5 .5]);
f = renderfigure(res,2);
close(fig);

%%%%%%%%%%%%%%%%%%%%% HELPER FUNCTION

function [f,ecc,width] = spatialscaling(params,slope,maxecc)

ss = sort([0 params maxecc]);
ecc = (ss(2:end)+ss(1:end-1))/2;
width = ss(2:end)-ss(1:end-1);
f = (slope*ecc - width) ./ (ecc.^.5);
