function aborted = play_movie(win, movie_file, start_times, end_times, loop_cb, draw_cb)

if ( nargin < 6 )
  draw_cb = [];
end

aborted = false;

if ( isa(win, 'ptb.Window') )
  win = win.WindowHandle;
end

if ( isempty(start_times) || isempty(end_times) )
  % full segment
  num_segments = 1;
else
  num_segments = numel( start_times );
end

[movie, ~, fps] = Screen( 'OpenMovie', win, movie_file );
Screen( 'PlayMovie', movie, 1 );

for ci = 1:num_segments
  played_frames = 0;

  if ( isempty(start_times) || isempty(end_times) )
    num_frames = inf;
    start_t = 0;
  else
    num_frames = max( 1, floor(end_times(ci) - start_times(ci)) * fps );
    start_t = start_times(ci);
    Screen( 'SetMovieTimeIndex', movie, start_t );
  end

  while played_frames < num_frames
    if ( ~isempty(loop_cb) )
      loop_cb( start_t + played_frames / fps );
    end

    tex = Screen( 'GetMovieImage', win, movie );
    if ( tex <= 0 )
      break
    end
    
    if ( ptb.util.is_esc_down )
      aborted = true;
      break
    end

    Screen( 'DrawTexture', win, tex );
    
    if ( ~isempty(draw_cb) )
      draw_cb( start_t + played_frames / fps );
    end
    
    Screen( 'Flip', win );
    Screen( 'Close', tex );

    played_frames = played_frames + 1;
  end
  
  if ( aborted )
    break
  end
end

Screen( 'PlayMovie', movie, 0 );
Screen( 'CloseMovie', movie );

end