% This script is to be edited.
%
% It uses ptviewimage to put up the ptcalibrationimages.
% Use spacebar to cycle, and see ptviewimage.m for more information.

% define
  % [800 600 60 32] [1280 800 0 32] [1600 1200 60 32]
  % '3T2_projector_2010_09_01'
ptonparams = {[1600 1200 60 32],[],-1};
ptonparams = {[1024 768 60 32],[],-1};
ptonparams = {[],[],-1};  % don't change resolution; sqrt the clut
ptonparams = {[1024 768 60 32],[],0};  % 3TB projector
ptonparams = {[1920 1080 120 24],[],0};  % BOLDSCREEN (linear CLUT)
ptonparams = {[],[],0};  % don't change resolution; use a linear clut

% check calibration images 
oldclut = pton(ptonparams{:});
dir0 = strrep(which('ptcalibratescreen'),'ptcalibratescreen.m','ptcalibrationimages');
offset = ptviewimage([dir0 '/*.png'],[0 0],0);  % ,1 means cycle
ptoff(oldclut);

% report offset
fprintf('The offset was found to be %s\n',mat2str(offset));
