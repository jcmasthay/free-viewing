function did_abort = video_task(win, vid_src_ps, start_ts, stop_ts, src_table, varargin)

defaults = struct();
defaults.iti_dur_s = 2;
defaults.max_num_reward_pulses = 2;
defaults.reward_ipi_s = 1;
defaults.reward_dur_s = 0.2;
defaults.use_eyelink = true;
defaults.save_data = true;
defaults.use_reward = true;
defaults.target_clips = [];
defaults.meta_data = [];
params = shared_utils.general.parsestruct( defaults, varargin );

did_abort = false;

vid_src_ps = cellstr( vid_src_ps );

assert( isequal(numel(vid_src_ps), numel(start_ts), numel(stop_ts)) ...
  , 'Expected 1 start and stop time per video clip file.' );
assert( numel(start_ts) == size(src_table, 1) ...
  , 'Expected 1 clip table row per start time.' );
assert( ~isempty(params.target_clips), 'Expected non-empty target clips.' );

proj_p = fileparts( which(mfilename) );
[data_p, data_file_name] = data_file_paths( proj_p );
shared_utils.io.require_dir( data_p );

use_eyelink = params.use_eyelink;
save_data = params.save_data;
use_reward = params.use_reward;

reward_dur_s = params.reward_dur_s;
reward_ipi_s = params.reward_ipi_s;  % inter-pulse-interval
max_num_reward_pulses = params.max_num_reward_pulses;
iti_dur_s = params.iti_dur_s;

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
t0_timestamp = datetime();

% triggers reward
rwd_cb = @() deliver_reward( rwd_interface, 1, reward_dur_s );

% play the clips
err = [];

try
  % for each clip
  for i = 1:numel(start_ts)
    did_abort = play_movie( ...
        win, vid_src_ps{i}, start_ts(i), stop_ts(i) ...
      , @(frame) frame_sync_loop_cb(frame, i, time_cb) ...
    );
  
    if ( did_abort )
      break
    end
    
    if ( iti_dur_s > 0 )
      iti( win, @task_loop, time_cb, rwd_cb, reward_ipi_s, max_num_reward_pulses, iti_dur_s );
    end
  end
catch err
  % error handled later
end

%{
  shutdown
%}

shutdown( el_interface );

if ( save_data )
  file = make_data_file( el_sync, el_interface, src_table, t0_timestamp, win, params );
  save( fullfile(data_p, data_file_name), 'file' );
end

if ( ~isempty(err) )
  rethrow( err );
end

%{
  local functions
%}

function frame_sync_loop_cb(frame, clip_index, time_cb)
  task_loop();
  send_frame_info( el_sync, clip_index, frame, time_cb() );
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

function data_file = make_data_file(...
  el_sync, el_interface, src_table, t0_timestamp, win, params)

data_file = struct(...
    'edf_file_name', el_interface.data_file_name ...
  , 'edf_sync_times', get_sync_times(el_sync) ...
  , 'clip_table', src_table ...
  , 'time0_timestamp', t0_timestamp ...
  , 'params', params ...
  , 'window', win ...
);

end