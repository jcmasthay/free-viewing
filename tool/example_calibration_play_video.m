err = [];

win = ptb.Window( [0, 0, 1280, 720] );
win.SkipSyncTests = true;
open( win );

% movie_file = 'http://meetings-archive.debian.net/pub/debian-meetings/2014/debconf14/webm/QA_with_Linus_Torvalds.webm';
% movie_file = 'C:\Users\nick\source\changlab\jamie\free-viewing\tool\Moo shu Pork is Quick!  Kenjis (quick) Cooking Show.mp4';
movie_file = 'C:\Users\nick\Videos\2023-06-11 09-49-36.webm';
movie_file = 'C:\Users\nick\source\changlab\jamie\free-viewing\tool\eg.webm';
% movie_file = 'https://www.youtube.com/watch?v=5k1e7Ra41Oo';
fallback_fps = 60;

try
  calibration_play_movie( win, movie_file, fallback_fps, 1, 5, [0, 0, 400, 400], @(varargin) 0, @() false );
catch err
  %
end

close( win );

if ( ~isempty(err) )
  rethrow( err );
end