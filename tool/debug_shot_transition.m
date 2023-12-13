%%

st_table = shared_utils.io.fload( ...
  fullfile(project_directory, 'data/shot_transition_table.mat') );
clip_table = shared_utils.io.fload( ...
  fullfile(project_directory, 'data/new_clip_table.mat') );

sesh_I = findeach( st_table, 'session_index' );

source_vids = unique( st_table.VideoFilename );
present = zeros( numel(sesh_I), numel(source_vids) );
num_clips = zeros( numel(sesh_I), 1 );
num_clips_per_source = zeros( numel(sesh_I), numel(source_vids) );
for i = 1:numel(sesh_I)
  si = sesh_I{i};
  present(i, :) = arrayfun( ...
    @(x) any(st_table.VideoFilename(si) == x), source_vids );
  num_clips(i) = numel( unique(st_table.clip_index(si)) );
  un_clips = unique( st_table(si, {'clip_index', 'VideoFilename'}) );
  num_clips_per_source(i, :) = arrayfun( ...
    @(x) sum(un_clips.VideoFilename == x), source_vids(:)' );
end

c = char( cellstr(source_vids(:)) );
c = c(:, 1:min(size(c, 2), 20));
figure(1); clf; imagesc( present );
colormap( 'gray' );
set( gca, 'xtick', 1:numel(source_vids) );
set( gca, 'xticklabel', cellstr(c) );
set( gca, 'XTickLabelRotation', 45 );

%%

figure(1); clf;
bar( num_clips(:)' );

%%

figure(1); clf;
imagesc( num_clips_per_source );
colorbar;
c = char( cellstr(source_vids(:)) );
c = c(:, 1:min(size(c, 2), 20));
% figure(1); clf; imagesc( present );
colormap( 'gray' );
set( gca, 'xticklabel', cellstr(c) );
set( gca, 'XTickLabelRotation', 45 );

%%

% which day are we running?
session_index = 1;

st_table = shared_utils.io.fload( fullfile(project_directory, 'data/shot_transition_table.mat') );
clip_table = shared_utils.io.fload( fullfile(project_directory, 'data/new_clip_table.mat') );

sesh_I = findeach( st_table, 'session_index' );
st_table = st_table(sesh_I{session_index}, :);

use_vid_p = vid_p;
use_scram_vid_p = scram_vid_p;
if ( 1 )
  st_table.VideoFilename = compose( "%s.mp4", st_table.VideoFilename );
  use_vid_p = 'D:\data\changlab\jamie\free-viewing\videos\clips\avi';
  use_scram_vid_p = 'D:\data\changlab\jamie\free-viewing\videos\clips\scrambled';
end

[As, Bs, Cs] = build_shot_transition_blocks( st_table, use_vid_p, use_scram_vid_p );
target_clips = clip_table(unique(st_table.clip_index, 'stable'), :);

blocks = generate_randomized_miniblocks( As, Bs, Cs );

source_vids = unique( st_table.VideoFilename );
fprintf( '\n\nUnique videos:\n\n%s\n', strjoin(source_vids, '\n') );

%%

block_index = 2;
shot_index = 4;
slop = 1;
% slop = 0;
% global_off = -123;
global_off = 1;

ct = clip_table(blocks{block_index}.clip_index(1), :);

ct.VideoFilename

pred_fs = shared_utils.io.find( ...
  fullfile(project_directory, 'data/clips_copy'), 'scenes.txt' );
match_pred = contains( pred_fs, ct.Code );
assert( sum(match_pred) == 1 );
shots = dlmread( pred_fs{match_pred} );

vr = VideoReader( blocks{block_index}.video_p{shot_index} );

if ( 0 )
  frame_shot0_0 = read( vr, global_off + floor(ct.Start(1) * vr.FrameRate + shots(shot_index, 1) + slop) );
  frame_shot0_1 = read( vr, global_off + floor(ct.Start(1) * vr.FrameRate + shots(shot_index, 2) - slop) );
  frame_shot1_0 = read( vr, global_off + floor(ct.Start(1) * vr.FrameRate + shots(shot_index+1, 1) + slop) );
else
  frame_shot0_0 = read( vr, global_off + floor(blocks{block_index}.start(shot_index) * vr.FrameRate) + slop );
  frame_shot0_1 = read( vr, global_off + floor(blocks{block_index}.start(shot_index+1) * vr.FrameRate) - slop );
  frame_shot1_0 = read( vr, global_off + floor(blocks{block_index}.start(shot_index+1) * vr.FrameRate) + slop );
end

subplot( 1, 3, 1 );
imshow( frame_shot0_0 ); title( 'start of shot' );

subplot( 1, 3, 2 );
imshow( frame_shot0_1 ); title( 'end of shot' );

subplot( 1, 3, 3 );
imshow( frame_shot1_0 ); title( 'start of next shot' );

%%

block_index = 1;
global_off = 0;
slop = 0;
shot_index = 21;

ct = clip_table(blocks{block_index}.clip_index(1), :);
pred_fs = shared_utils.io.find( ...
  fullfile(project_directory, 'data/clips_copy'), 'scenes.txt' );
match_pred = contains( pred_fs, ct.Code );
shots = dlmread( pred_fs{match_pred} );

vid_file_p = fullfile( 'C:\Users\nick\source\changlab\jamie\free-viewing\data\clips_copy' ...
  , sprintf('%s.mp4.avi', ct.Code{1}) );
vr = VideoReader( vid_file_p );

if ( 1 )
  frame_shot0_0 = read( vr, 1 + global_off + shots(shot_index, 1) + slop );
  frame_shot0_1 = read( vr, 1 + global_off + shots(shot_index, 2) - slop );
  frame_shot1_0 = read( vr, 1 + global_off + shots(shot_index+1, 1) + slop );
end

subplot( 1, 3, 1 );
imshow( frame_shot0_0 ); title( 'start of shot' );

subplot( 1, 3, 2 );
imshow( frame_shot0_1 ); title( 'end of shot' );

subplot( 1, 3, 3 );
imshow( frame_shot1_0 ); title( 'start of next shot' );

