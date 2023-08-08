function [As, Bs, Cs] = build_blocks(target_clips, clip_dur, vid_p, scram_vid_p)

As = cell( size(target_clips, 1), 1 );
Bs = cell( size(As) );
Cs = cell( size(As) );

for i = 1:size(target_clips, 1)
  A = table();
  
  [A.start, A.stop, A.index] = generate_clip_chunks( ...
    target_clips.Start(i), target_clips.Stop(i), clip_dur );
  A.index(:) = i;
  A.video_filename = compose( "%s.avi", target_clips.VideoFilename(A.index) );
  A.video_p = fullfile( vid_p, A.video_filename );
  A.block_type = repmat( "A", size(A, 1), 1 );

  % B has shuffled clip order
  B = A(randperm(size(A, 1)), :);
  B.block_type(:) = "B";
  
  % C has the same clip order as A, but scrambled videos
  C = A; 
  C.video_p = fullfile( scram_vid_p, C.video_filename );
  C.block_type(:) = "C";
  
  As{i} = A;
  Bs{i} = B;
  Cs{i} = C;
end

end