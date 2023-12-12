%%  clip info

vid_p = fullfile( project_directory, 'videos' );
% vid_p = 'D:\data\changlab\jamie\free-viewing\videos';
scram_vid_p = fullfile( vid_p, 'scrambled' );

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/new_clip_table.mat') );

%%

% which day are we running?
session_index = 7;

st_table = shared_utils.io.fload( fullfile(project_directory, 'data/shot_transition_table.mat') );
clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/new_clip_table.mat') );

sesh_I = findeach( st_table, 'session_index' );
st_table = st_table(sesh_I{session_index}, :);
[As, Bs, Cs] = build_shot_transition_blocks( st_table, vid_p, scram_vid_p );
target_clips = clip_table(unique(st_table.clip_index, 'stable'), :);

blocks = generate_randomized_miniblocks( As, Bs, Cs );

source_vids = unique( st_table.VideoFilename );
fprintf( '\n\nUnique videos:\n\n%s\n', strjoin(source_vids, '\n') );

%%  run the task

use_reward = true;
use_eyelink = true;

% win = ptb.Window( [0, 0, 1280, 720] );
% win.Index = 0;
% win.Index = 2;
win = ptb.Window( [] );
win.Index = 1;
win.SkipSyncTests = true;
open( win );

inter_story_interval_s = 60;
inter_mini_block_interval_s = 10;
iti_s = 0;

% change this number to run the next block
block_indices = 1:numel(blocks);

for i = block_indices
  
mini_block_set = blocks{i};
mini_block_I = findeach( mini_block_set, 'block_type' );

err = [];
did_abort = false;

for bi = 1:numel(mini_block_I)
  block = mini_block_set(mini_block_I{bi}, :);
  [err, did_abort] = run_video_task_mini_block( win, block ...
    , 'iti_dur_s', iti_s ...
    , 'target_clips', target_clips ...
    , 'use_eyelink', use_eyelink ...
    , 'use_reward', use_reward ...
  );

  if ( ~isempty(err) || did_abort )
    break
  end
  
  % pause between A, B, C
  if ( bi < numel(mini_block_I) )
    rewarded_break( inter_mini_block_interval_s ...
      , 'max_num_reward_pulses', 4 ...  % max number of pulses
      , 'reward_ipi_s', 2 ...           % interval between reward pulses
      , 'reward_dur_s', 0.2 ...
      , 'use_reward', use_reward ...
    );
  end
end

if ( ~isempty(err) || did_abort )
  break
end

% pause between sets of {A, B, C}
if ( i ~= block_indices(end) )
  rewarded_break( inter_story_interval_s ...
    , 'max_num_reward_pulses', 17 ...
    , 'reward_ipi_s', 10 ...
    , 'reward_dur_s', 0.2 ...
    , 'use_reward', use_reward ...
  );
end

end

close( win );

if ( ~isempty(err) )
  rethrow( err );
end