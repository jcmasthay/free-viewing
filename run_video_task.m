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

err = [];
try 
  vid_src_p = fullfile( project_directory, 'videos/Monkey Thieves S2E2.avi' );

  % start + stop times within respective clips
  [start_ts, stop_ts] = to_clip_subsets( clip_subset.Start, clip_subset.Stop );

  % same video in this case for each start / stop time
  vid_src_ps = repmat( {vid_src_p}, numel(start_ts), 1 );
  
  video_task( win, vid_src_ps, start_ts, stop_ts );
catch err
  %
end

if ( ~isempty(err) )
  rethrow( err );
end

close( win );