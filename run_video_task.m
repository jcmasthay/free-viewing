%%

clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/clip_table.mat') );
clip_subset = clip_table(clip_table.VideoFilename == 'Monkey Thieves S2E2', :);

fix_vars = { 'Start', 'Stop' };
for i = 1:numel(fix_vars)
  minute = floor( clip_subset.(fix_vars{i}) );
  sec = clip_subset.(fix_vars{i}) - minute;
  clip_subset.(fix_vars{i}) = minute * 60 + sec * 100;
end

%%

win = ptb.Window( [0, 0, 1280, 720] );
open( win );

clip_dur = 10;

err = [];
try 
  vid_src_p = fullfile( project_directory, 'videos/Monkey Thieves S2E2.avi' );

  % start + stop times within respective clips
  [start_ts, stop_ts] = to_clip_subsets( clip_subset.Start, clip_subset.Stop );
  
  for i = 1:numel(start_ts)
    [starts, stops] = partition_clip_subsets( start_ts{i}, stop_ts{i}, clip_dur );
    
    % same video in this case for each start / stop time
    vid_src_ps = repmat( {vid_src_p}, numel(starts), 1 );

    video_task( win, vid_src_ps, starts, stops );
  end
catch err
  %
end

if ( ~isempty(err) )
  rethrow( err );
end

close( win );