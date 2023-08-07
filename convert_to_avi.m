vid_path = 'C:\source\free-viewing\videos\mp4 files/Home Hunters - Monkey Thieves S2 613 - Go Wild.mp4';
output_path = fileparts( vid_path );
make_video_clips( vid_path, output_path, [], 'Motion JPEG AVI', false );