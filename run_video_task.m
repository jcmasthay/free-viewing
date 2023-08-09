%%  clip info

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/clip_table.mat') );
dend_table = shared_utils.io.fload( fullfile(project_directory, 'data/dendro_table.mat') );

%%  select story sequences targeting a specific total duration

target_total_dur_s = 15 * 60;
allowed_slop_s = 10;  % at most N seconds short of target_total_dur_s

% target 50% affiliative stories, but allow proportional deviations up to X. 
% e.g., if allowed_p_affil_imbalance is 0.1, then +/- 10% (i.e., 40 - 60%) 
% of stories will be affiliative.
allowed_p_affil_imbalance = 0.1;

mask = find( dend_table.affiliativeness ~= 'neutral' & clip_table.VideoFilename ~= "" );
% mask = 1:size(dend_table, 1);

target_subset = mask(select_stories( ...
  dend_table(mask, :), target_total_dur_s, allowed_slop_s, allowed_p_affil_imbalance));

target_clips = [ clip_table(target_subset, :), dend_table(target_subset, :) ]

%%  build blocks

clip_dur = 10;

vid_p = fullfile( project_directory, 'videos' );
scram_vid_p = fullfile( vid_p, 'scrambled' );

[As, Bs, Cs] = build_blocks( target_clips, clip_dur, vid_p, scram_vid_p );
blocks = generate_randomized_miniblocks( As, Bs, Cs );

%%  run the task

win = ptb.Window( [] );
win.Index = 1;
win.SkipSyncTests = true;
open( win );

inter_block_interval_s = 10;

for i = 1:numel(blocks)
  
block = blocks{i};

err = [];
did_abort = false;
try   
  did_abort = video_task( win, block.video_p, block.start, block.stop );
  if ( did_abort )
    break
  end
catch err
  break
end

pause( inter_block_interval_s );

end

close( win );

if ( ~isempty(err) )
  rethrow( err );
end