function pteyelinkoff(eyetempfile,eyelinkfile)

% function pteyelinkoff(eyetempfile,eyelinkfile)
%
% <eyetempfile> is the output from pteyelinkon.m
% <eyelinkfile> is a target filename
%
% Do some clean-up after having run pteyelinkon.m.
% Rename the <eyetempfile> to final filename <eyelinkfile>.

Eyelink('StopRecording');
Eyelink('CloseFile');
Eyelink('ReceiveFile');
Eyelink('ShutDown');
movefile(eyetempfile,eyelinkfile);  % RENAME DOWNLOADED FILE TO THE FINAL FILENAME
