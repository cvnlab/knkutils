function eyetempfile = pteyelinkon(el_monitor_size,el_screen_distance,cv_proportion_area,point2point_distance_pix)

% function eyetempfile = pteyelinkon(el_monitor_size,el_screen_distance,cv_proportion_area,point2point_distance_pix)
%
% <el_monitor_size> is 1 x 4 with monitor size in millimeters (center to left, top, right, and bottom)
% <el_screen_distance> is 1 x 2 with distance in millimeters from eye to top and bottom edge of the monitor
% <cv_proportion_area> is 1 x 2 proportion of [x,y] screen resolution (in pixels) at which we place calibration targets
% <point2point_distance_pix> is number of pixels for shift right/left/down/up
%
% Perform some typical Psychtoolbox setup for Eyelink usage.
% Return the filename used to capture .edf data.

assert(EyelinkInit()==1);
win = firstel(Screen('Windows'));
el = EyelinkInitDefaults(win);
if ~isempty(el.callback)
  PsychEyelinkDispatchCallback(el);
end
[wwidth,wheight] = Screen('WindowSize',win);  % returns in pixels
fprintf('Pixel size of window is width: %d, height: %d.\n',wwidth,wheight);
xc_off = wwidth/2;
yc_off = wheight/2;
Eyelink('command',sprintf('screen_phys_coords = %3.1f, %3.1f, %3.1f, %3.1f',el_monitor_size));
Eyelink('command','screen_distance = %ld %ld',el_screen_distance);  % distance in millimeters from eye to top and bottom edge of the monitor
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld',0,0,wwidth-1,wheight-1);
Eyelink('message','DISPLAY_COORDS %ld %ld %ld %ld',0,0,wwidth-1,wheight-1);
Eyelink('command','calibration_type = HV5');
Eyelink('command',sprintf('calibration_area_proportion %1.3f, %1.3f',cv_proportion_area));
Eyelink('command',sprintf('validation_area_proportion %1.3f, %1.3f',cv_proportion_area));
Eyelink('command','generate_default_targets = NO');
Eyelink('command','calibration_samples  = 6');
Eyelink('command','calibration_sequence = 0,1,2,3,4,5');
Eyelink('command','calibration_targets  = %d,%d %d,%d %d,%d %d,%d %d,%d',...
    xc_off,yc_off,  ... center x,y
    xc_off + point2point_distance_pix, yc_off, ... horz shift right
    xc_off - point2point_distance_pix, yc_off, ... horz shift left
    xc_off, yc_off + point2point_distance_pix, ... vert shift down
    xc_off, yc_off - point2point_distance_pix); %  vert shift up
Eyelink('command','validation_samples = 6');
Eyelink('command','validation_sequence = 0,1,2,3,4,5');
Eyelink('command','validation_targets  = %d,%d %d,%d %d,%d %d,%d %d,%d',...
    xc_off,yc_off,  ... center x,y
    xc_off + point2point_distance_pix, yc_off, ... horz shift right
    xc_off - point2point_distance_pix, yc_off, ... horz shift left
    xc_off, yc_off + point2point_distance_pix, ... vert shift down
    xc_off, yc_off - point2point_distance_pix); %  vert shift up
Eyelink('command','active_eye = LEFT');
Eyelink('command','binocular_enabled','NO');
Eyelink('command','enable_automatic_calibration','NO'); % force manual calibration sequencing, if yes, provide Eyelink('command','automatic_calibration_pacing=1500');
Eyelink('command','recording_parse_type = GAZE'); %from manual (default)
Eyelink('command','sample_rate = %d', 1000); % hz
Eyelink('command','driftcorrect_cr_disable = YES'); % yes to disable drift correction -- we don't want that!
  % what events (columns) are recorded in EDF:
Eyelink('command','file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
  % what samples (columns) are recorded in EDF:
Eyelink('command','file_sample_data = LEFT,RIGHT,GAZE,GAZERES,PUPIL,AREA,STATUS');
  % events available for real time:
Eyelink('command','link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
  % samples available for real time:
Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,GAZERES,PUPIL,AREA,STATUS');
eyetempfile = sprintf('%s.edf', datestr(now, 'HHMMSS')); %less than 8 digits!
fprintf('Saving eyetracking data to %s.\n',eyetempfile);
Eyelink('Openfile',eyetempfile);  % NOTE THIS TEMPORARY FILENAME. REMEMBER THAT EYELINK REQUIRES SHORT FILENAME!
checkcalib = input('Do you want to do a calibration (0=no, 1=yes)? ','s');
commandwindow;
if isequal(checkcalib,'1')
  fprintf('Please perform calibration. When done, press the output/record button.\n');
  EyelinkDoTrackerSetup(el);
%  EyelinkDoDriftCorrection(el);
end
Eyelink('StartRecording');
% note that we expect that something should probably issue the command:
%   Eyelink('Message','SYNCTIME');
% before we close out the eyelink.
