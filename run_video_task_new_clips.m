%%  clip info

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/new_clip_table.mat') );

target_subset = 6;
target_clips = clip_table(target_subset, :);
target_clips.subset_index = target_subset(:);

%%  build blocks

clip_dur = 10;

% vid_p = fullfile( project_directory, 'videos' );
vid_p = 'D:\data\changlab\jamie\free-viewing\videos';
scram_vid_p = fullfile( vid_p, 'scrambled' );

[As, Bs, Cs] = build_blocks( target_clips, clip_dur, vid_p, scram_vid_p );
Cs = Bs;
blocks = generate_randomized_miniblocks( As, Bs, Cs );

%%

num_clips = sum( cellfun(@numel, mini_block_I) );

num_clips * clip_dur + ...
  numel( block_indices ) * inter_story_interval_s + ...
  numel( mini_block_I ) * inter_mini_block_interval_s

%%  run the task

use_reward = false;
use_eyelink = false;

win = ptb.Window( [0, 0, 1280, 720] );
win.Index = 0;
% win.Index = 2;
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