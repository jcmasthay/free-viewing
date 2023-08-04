clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/clip_table.mat') );
clip_subset = clip_table(clip_table.VideoFilename == 'Monkey Thieves S2E2', :);

win = ptb.Window( [0, 0, 1280, 720] );
open( win );

err = [];
try 
  vid_src_p = fullfile( project_directory, 'videos/clip_0.mp4.avi' );

  % start + stop times within respective clips
  start_ts = { [1 * 60 + 10, 2 * 60 + 15] };
  stop_ts = { start_ts{1} + [4, 5] };

  % same video in this case for each start / stop time
  vid_src_ps = repmat( {vid_src_p}, numel(start_ts), 1 );
  
  video_task( win, vid_src_ps, start_ts, stop_ts );
catch err
  %
end

if ( ~isempty(err) )
  rethrow( err );
end