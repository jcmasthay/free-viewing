function video_task()

proj_p = fileparts( which(mfilename) );
[data_p, data_file_name] = data_file_paths( proj_p );
shared_utils.io.require_dir( data_p );

use_eyelink = false;
save_data = true;

el_interface = EyelinkInterface();
el_interface.bypassed = ~use_eyelink;
initialize( el_interface );

el_sync = EyelinkSync();
el_sync.bypassed = ~use_eyelink;

%{
  stimuli
%}

vid_src_p = fullfile( proj_p, 'videos/clip_0.mp4.avi' );

% start + stop times within respective clips
start_ts = [ 1 * 60 + 10; 2 * 60 + 15 ];
stop_ts = start_ts + [4; 5];

% same video in this case for each start / stop time
vid_src_ps = repmat( {vid_src_p}, numel(start_ts), 1 );

%{
  window
%}

win = ptb.Window( [0, 0, 1280, 720] );
open( win );

% does nothing for now
loop_cb = @(frame) 0;

% gets the current time
t0 = tic;
time_cb = @() toc( t0 );

% play the clips
err = [];
try
  clip_block( win, el_sync, vid_src_ps, start_ts, stop_ts, loop_cb, time_cb );
catch err
end

shutdown( el_interface );

if ( save_data )
  file = make_data_file( el_sync, el_interface );
  save( fullfile(data_p, data_file_name), 'file' );
end

close( win );

if ( ~isempty(err) )
  rethrow( err );
end

end

function clip_block(win, el_sync, vid_ps, start_ts, stop_ts, loop_cb, time_cb)

for i = 1:numel(start_ts)
  play_movie( win, vid_ps{i}, start_ts(i), stop_ts(i), @(frame) sync_loop_cb(i, frame) );

  % pause between clips
  pause_time = 5;
  t0 = time_cb();
  while ( time_cb() - t0 < pause_time )
    flip( win );
  end
end

function sync_loop_cb(i, frame)
  loop_cb();
  send_frame_info( el_sync, vid_ps{i}, frame, time_cb() );
end

end

function [data_p, data_file_name] = data_file_paths(proj_p)

data_p = fullfile( proj_p, 'data', datestr(now, 'mmddyyyy') );
data_file_name = sprintf( '%s.mat', strrep(datestr(now), ':', '_') );

end

function data_file = make_data_file(el_sync, el_interface)

data_file = struct(...
    'edf_file_name', el_interface.data_file_name ...
  , 'edf_sync_times', get_sync_times(el_sync) ...
);

end