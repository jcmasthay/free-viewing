%%  clip info

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/clip_table.mat') );

%%  target 15 min of actual showing clips

% TODO: Produce `target_subset` attempting to strike a balance between
% affiliative and aggressive clips; also, within those, balance between
% interaction-type (e.g. social v nonsocial, or species)
target_subset = find( clip_table.VideoFilename == 'Monkey Thieves S2E2' );

target_clips = clip_table(target_subset, :);

%%  build blocks

clip_dur = 10;

vid_p = fullfile( project_directory, 'videos' );
scram_vid_p = fullfile( vid_p, 'scrambled' );

[As, Bs, Cs] = build_blocks( target_clips, clip_dur, vid_p, scram_vid_p );
blocks = generate_randomized_miniblocks( As, Bs, Cs );

%%  run the task

win = ptb.Window( [0, 0, 1280, 720] );
open( win );

for i = 1:numel(blocks)
  
block = blocks{i};

err = [];
try   
  video_task( win, block.video_p, block.start, block.stop );
catch err
  break
end

end

if ( ~isempty(err) )
  rethrow( err );
end

close( win );