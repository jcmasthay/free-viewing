function [As, Bs, Cs] = build_shot_transition_blocks(st_tbl, vid_p, scram_vid_p)

I = findeach( st_tbl, 'clip_index' );

As = cell( size(I) );
Bs = cell( size(I) );
Cs = cell( size(I) );

for i = 1:numel(I)
  clip_st_tbl = st_tbl(I{i}, :);
  
  A = clip_st_tbl;
  A.video_filename = cellstr( compose("%s.avi", A.VideoFilename) );
  A.video_p = fullfile( vid_p, A.video_filename );
  A.block_type = repmat( {'A'}, size(A, 1), 1 );

  % B has shuffled clip order
  B = A(randperm(size(A, 1)), :);
  B.block_type(:) = {'B'};
  
  % C has the same clip order as A, but scrambled videos
  C = A; 
  C.video_p = fullfile( scram_vid_p, C.video_filename );
  C.block_type(:) = {'C'};
  
  As{i} = A;
  Bs{i} = B;
  Cs{i} = C;
end

end