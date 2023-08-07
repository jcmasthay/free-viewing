function [A, B, C] = build_blocks(target_clips, clip_dur, vid_p, scram_vid_p)

A = table();
[A.start, A.stop, A.index] = generate_clip_chunks( ...
  target_clips.Start, target_clips.Stop, clip_dur );
A.video_filename = compose( "%s.avi", target_clips.VideoFilename(A.index) );
A.video_p = fullfile( vid_p, A.video_filename );

% B has shuffled clip order
B = A(randperm(size(A, 1)), :);
% C has the same clip order as A, but scrambled videos
C = A; 
C.video_p = fullfile( scram_vid_p, C.video_filename );

end