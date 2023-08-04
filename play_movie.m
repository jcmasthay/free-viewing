function play_movie(win, movie_file, start_time, end_time, loop_cb)

if ( isa(win, 'ptb.Window') )
  win = win.WindowHandle;
end

[movie, ~, fps] = Screen( 'OpenMovie', win, movie_file );

if ( isempty(start_time) || isempty(end_time) )
  num_frames = inf;
else
  num_frames = max( 1, floor(end_time - start_time) * fps );
  Screen( 'SetMovieTimeIndex', movie, start_time );
end

Screen( 'PlayMovie', movie, 1 );
played_frames = 0;

while played_frames < num_frames
  loop_cb( played_frames );
  
  tex = Screen( 'GetMovieImage', win, movie );
  if ( tex <= 0 )
    break
  end

  Screen( 'DrawTexture', win, tex );
  Screen( 'Flip', win );
  Screen( 'Close', tex );
  
  played_frames = played_frames + 1;
end

Screen( 'PlayMovie', movie, 0 );
Screen( 'CloseMovie', movie );

end