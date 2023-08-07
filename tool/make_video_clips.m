function make_video_clips(vid_path, output_path, start_end_times, video_profile, transform_frame)

if ( nargin < 5 || isempty(transform_frame) )
  transform_frame = @(x) x;
end

if ( isempty(video_profile) )
  video_profile = 'Motion JPEG AVI';
end

video_reader = VideoReader( vid_path );

if ( isempty(start_end_times) )
  % Full movie
  [~, vid_name, ext] = fileparts( vid_path );  
  output_p = fullfile( output_path, sprintf('%s%s', vid_name, ext) );
  video_writer = open_video_writer( video_reader, output_p, video_profile );
  
  while ( hasFrame(video_reader) )
    read_write_frame( video_reader, video_writer, transform_frame );
  end
else
  % Movie clips
  start_s = start_end_times(:, 1);
  end_s = start_end_times(:, 2);

  for i = 1:size(start_s, 1)
    fprintf( '\nMaking clip %d of %d.', i, size(start_s, 1) );

    output_p = fullfile( output_path, sprintf('clip_%d', i) );
    video_writer = open_video_writer( video_reader, output_p, video_profile );
    video_reader.CurrentTime = start_s(i);
    num_frames = max( 1, floor((end_s(i) - start_s(i)) * video_reader.FrameRate) );

    for j = 1:num_frames
      read_write_frame( video_reader, video_writer, transform_frame );
    end

    fprintf( ' Done\n' );
  end
end

end

function read_write_frame(reader, writer, transform_frame)

frame = readFrame( reader );
frame = transform_frame( frame );
writeVideo( writer, frame );

end

function video_writer = open_video_writer(video_reader, output_p, video_profile)

video_writer = VideoWriter( output_p, video_profile );
video_writer.FrameRate = video_reader.FrameRate;

open( video_writer );

end