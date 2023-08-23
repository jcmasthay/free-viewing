%%  clip info

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/clip_table.mat') );
dend_table = shared_utils.io.fload( fullfile(project_directory, 'data/dendro_table.mat') );

%%  select story sequences targeting a specific total duration

target_total_dur_s = 3 * 60;
allowed_slop_s = 10;  % at most N seconds short of target_total_dur_s
use_all_masked_clips = false;

% target 50% affiliative stories, but allow proportional deviations up to X. 
% e.g., if allowed_p_affil_imbalance is 0.1, then +/- 10% (i.e., 40 - 60%) 
% of stories will be affiliative.
allowed_p_affil_imbalance = 0.1;

mask = find( clip_table.VideoFilename ~= "" );
% mask = 1:size(dend_table, 1);

if ( use_all_masked_clips )
  target_subset = mask;
else
  target_subset = mask(select_stories( ...
    dend_table(mask, :), target_total_dur_s, allowed_slop_s, allowed_p_affil_imbalance));
end

target_clips = [ clip_table(target_subset, :), dend_table(target_subset, :) ]
target_clips.subset_index = target_subset(:);

%%  build blocks

clip_dur = 10;

vid_p = fullfile( project_directory, 'videos' );
scram_vid_p = fullfile( vid_p, 'scrambled' );

[As, Bs, Cs] = build_blocks( target_clips, clip_dur, vid_p, scram_vid_p );
blocks = generate_randomized_miniblocks( As, Bs, Cs );

%%  run the task

win = ptb.Window( [] );
win.Index = 1;
% win.Index = 2;
win.SkipSyncTests = true;
open( win );

inter_story_interval_s = 3 * 60;
inter_mini_block_interval_s = 10;
iti_s = 2;

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
    , 'iti_dur_s', iti_s, 'target_clips', target_clips );
  if ( ~isempty(err) || did_abort )
    break
  end
  
  % pause between A, B, C
  if ( bi < numel(mini_block_I) )
    rewarded_break( inter_mini_block_interval_s ...
      , 'max_num_reward_pulses', 4 ...  % max number of pulses
      , 'reward_ipi_s', 2 ...           % interval between reward pulses
      , 'reward_dur_s', 0.2 ...
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
  );
end

end

close( win );

if ( ~isempty(err) )
  rethrow( err );
end