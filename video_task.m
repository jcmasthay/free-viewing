function did_abort = video_task(win, vid_src_ps, start_ts, stop_ts)

did_abort = false;

vid_src_ps = cellstr( vid_src_ps );

assert( isequal(numel(vid_src_ps), numel(start_ts), numel(stop_ts)) ...
  , 'Expected 1 start and stop time per video clip file.' );

proj_p = fileparts( which(mfilename) );
[data_p, data_file_name] = data_file_paths( proj_p );
shared_utils.io.require_dir( data_p );

use_eyelink = true;
save_data = true;
use_reward = true;

reward_dur_s = 0.2;
reward_ipi_s = 1;  % inter-pulse-interval
max_num_reward_pulses = 2;
iti_dur_s = 2;

el_interface = EyelinkInterface();
el_interface.bypassed = ~use_eyelink;
initialize( el_interface, data_p );

el_sync = EyelinkSync();
el_sync.bypassed = ~use_eyelink;

rwd_interface = RewardInterface( ~use_reward );

%{
  task
%}

% gets the current time
t0 = tic;
time_cb = @() toc( t0 );

% triggers reward
rwd_cb = @() deliver_reward( rwd_interface, 1, reward_dur_s );

% play the clips
err = [];

try
  % for each clip
  for i = 1:numel(start_ts)
    did_abort = play_movie( ...
        win, vid_src_ps{i}, start_ts(i), stop_ts(i) ...
      , @(frame) frame_sync_loop_cb(frame, vid_src_ps{i}, time_cb) ...
    );
  
    if ( did_abort )
      break
    end
    
    iti( win, @task_loop, time_cb, rwd_cb, reward_ipi_s, max_num_reward_pulses, iti_dur_s );
  end
catch err
  % error handled later
end

%{
  shutdown
%}

shutdown( el_interface );

if ( save_data )
  file = make_data_file( el_sync, el_interface );
  save( fullfile(data_p, data_file_name), 'file' );
end

if ( ~isempty(err) )
  rethrow( err );
end

%{
  local functions
%}

function frame_sync_loop_cb(frame, vid_p, time_cb)
  task_loop();
  send_frame_info( el_sync, vid_p, frame, time_cb() );
end

function task_loop()
  update( rwd_interface );
end

end

function iti(win, loop_cb, time_cb, rwd_cb, rwd_ipi, max_num_pulses, pause_time)

t0 = time_cb();

% reward timing
last_reward_t = -inf;

num_pulses = 0;

while ( time_cb() - t0 < pause_time )
  loop_cb();

  flip( win );
  t = time_cb();

  if ( t - last_reward_t > rwd_ipi && num_pulses < max_num_pulses )
    rwd_cb();
    last_reward_t = t;
    num_pulses = num_pulses + 1;
  end
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