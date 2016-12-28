function f = imagefilter3D(vols,flt)

% function f = imagefilter3D(vols,flt)
%
% <vols> is X x Y x Z x N with one or more 3D volumes
% <flt> is a 3D magnitude filter in the Fourier domain (not fftshifted)
% 
% Perform filtering in the Fourier domain and return the filtered volumes(s).
% We force the output to be real-valued.
% In general, beware of wraparound and edge issues!
%
% example:
% flt = zeros(29,29,9);
% flt(14:16,14:16,4:6) = 1;
% flt = ifftshift(flt);
% figure; imagesc(makeimagestack(imagefilter3D(randn(29,29,9),flt))); colormap(gray); axis equal tight;

% do it
f = zeros(size(vols),class(vols));
for p=1:size(vols,4)
  f(:,:,:,p) = real(ifftn(fftn(vols(:,:,:,p)).*flt));
end
