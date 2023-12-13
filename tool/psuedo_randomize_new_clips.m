clip_table = shared_utils.io.fload( fullfile(project_directory, 'data', 'new_clip_table.mat') );

start_ts = clip_table.Start;
stop_ts = clip_table.Stop;
target_dur = 12 * 60;

while ( true )

clips_per_session = generate_clips_per_session( ...
  target_dur, start_ts, clip_table.TotalDuration );

all_sources = unique( clip_table.SourceMovie );
sources_per_session = cell( size(clips_per_session) );
for i = 1:numel(clips_per_session)
  [~, loc] = ismember( clip_table.SourceMovie(clips_per_session{i}), all_sources );
  sources_per_session{i} = loc;
end

% avoid putting multiple monkey thieves clips in one day
thieves_ind = find( contains(all_sources, 'Monkey Thieves') );
assert( numel(thieves_ind) == 1 );
has_mult_thieves = any( cellfun(@(x) sum(x == thieves_ind) > 1, sources_per_session) );
if ( has_mult_thieves )
  continue
end

% heuristic to prefer a similar number of clips per session
num_per_sesh = cellfun( @numel, clips_per_session );
max_delta_n = max( columnize(abs(num_per_sesh - num_per_sesh')) );
if ( max_delta_n >= 2 )
  continue
end

if ( 0 )
planet_ind = find( contains(all_sources, 'Monkey Planet') );
assert( numel(planet_ind) == 1 );
num_planet = cellfun( @(x) sum(x == planet_ind), sources_per_session );
if ( ~any(num_planet == 0) )
  continue;
end
end

% criteria met
break

end

clips_per_session

%%

pred_fs = shared_utils.io.find( ...
  fullfile(project_directory, 'data/clips_copy'), 'scenes.txt' );
pred_tbl = table();
for i = 1:numel(pred_fs)
  pred_f = dlmread( pred_fs{i} );
  ident = strrep( ...
    strrep(shared_utils.io.filenames(pred_fs{i}), '.mp4', ''), '.scenes', '' );
%   ident_ind = find( strcmp(clip_table.Code, ident) );
%   assert( numel(ident_ind) == 1 );
  idents = repmat( string(ident), size(pred_f, 1), 1 );
  pred_tbl = [ pred_tbl; table(pred_f(:, 1), pred_f(:, 2), idents ...
    , 'va', {'start', 'stop', 'identifier'}) ];
end

%%  monkey thieves use full video, others use clip files

clip_mp4s = shared_utils.io.find( ...
  'D:\data\changlab\jamie\free-viewing\videos\clips', '.mp4' );
fnames = shared_utils.io.filenames( clip_mp4s );

[miss_fnames, ia1] = setdiff( fnames(:), clip_table.Code );
[miss_fnames, ia2, ic] = unique( ...
  cellfun(@(x) x(~isstrprop(x, 'digit')), miss_fnames, 'un', 0) );

miss_clips = setdiff( clip_table.Code, fnames(:) );
source_vid = cellfun( ...
  @(x) clip_table.SourceMovie(strcmp(clip_table.Code, x)), miss_clips );
source_vid(~ismember(miss_clips, miss_fnames))

%%  construct a table of shot transitions, properly ordered, for each session

dr = 'D:\data\changlab\jamie\free-viewing';
clip_ext = '.mp4';

st_tbl = table();
prefer_clip_video_files = true;

for sesh_ind = 1:numel(clips_per_session)
  
clip_inds = clips_per_session{sesh_ind};
clips_sesh = clip_table(clip_inds, :);

sesh_st_tbl = table();

% clip_ind = 4;
for clip_ind = 1:numel(clip_inds)

abs_clip_ind = clip_inds(clip_ind);
curr_clip = clips_sesh(clip_ind, :);
num_segs = find( ~isnan(curr_clip.Start), 1, 'last' );
is_thieves = contains( curr_clip.SourceMovie, 'Monkey Thieves' );
is_multi_part = num_segs > 1;

base_vid_filename = curr_clip.VideoFilename;
uses_mult_clips = false;
uses_clip_files = false;

if ( prefer_clip_video_files )
  if ( is_thieves )
    vid_file_p = fullfile(dr, 'videos', sprintf('%s.avi', curr_clip.VideoFilename) );
  else
    if ( is_multi_part )
      pat = '%s1%s';  % first clip
      uses_mult_clips = true;
    else
      pat = '%s%s';
    end
    base_vid_filename = string( curr_clip.Code );
    vid_fname = sprintf( pat, string(curr_clip.Code), clip_ext );
    vid_file_p = fullfile(dr, 'videos/clips', vid_fname );
    uses_clip_files = true;
  end
else
  vid_file_p = fullfile(dr, 'videos', sprintf('%s.avi', curr_clip.VideoFilename) );
end

try
  vr = VideoReader( vid_file_p );
catch err
  fprintf( '\n Missing video: %s', vid_file_p );
  rethrow( err );
end
fps = vr.FrameRate;

for s = 1:num_segs
  search_id = string( curr_clip.Code );
  if ( num_segs > 1 )
    search_id = compose( "%s%d", search_id, s );
  end

  match_pred = pred_tbl.identifier == search_id;
  % @TODO
  assert( nnz(match_pred) > 0, 'No prediction file matched clip code "%s".', search_id );
  
  assign_video_filename = base_vid_filename;
  if ( uses_mult_clips )
    assign_video_filename = sprintf( '%s%d', base_vid_filename, s );
  end

  keep_vars = setdiff( ...
    clips_sesh.Properties.VariableNames, pred_tbl.Properties.VariableNames );

  ones_per_st_tbl = ones( sum(match_pred), 1 );

  curr_st_tbl = [ pred_tbl(match_pred, :) ...
    , repmat(curr_clip(:, keep_vars), sum(match_pred), 1) ];
  
  curr_st_tbl.clip_index = ones_per_st_tbl * abs_clip_ind; 
  curr_st_tbl.session_index = ones_per_st_tbl * sesh_ind;
  
  if ( uses_clip_files )
    curr_st_tbl.start = curr_st_tbl.start / fps;
    curr_st_tbl.stop = curr_st_tbl.stop / fps;
    curr_st_tbl.VideoFilename(:) = assign_video_filename;
  else
    curr_st_tbl.start = curr_st_tbl.start / fps + curr_clip.Start(s);
    curr_st_tbl.stop = curr_st_tbl.stop / fps + curr_clip.Start(s);
  end
  
  sesh_st_tbl = [sesh_st_tbl; curr_st_tbl];
end

end

% only add successful sesssions
st_tbl = [ st_tbl; sesh_st_tbl ];

end

%%

if ( 1 )
  save( fullfile(project_directory, 'data', 'shot_transition_table.mat'), 'st_tbl' );
  save( fullfile(project_directory, 'data', 'clips_per_session_table.mat'), 'clips_per_session' );
end

%%

function clips_per_session = generate_clips_per_session(target_dur, start_ts, total_duration)

num_clips = size( start_ts, 1 );
already_matched = [];

clips_per_session = {};
while ( numel(already_matched) ~= num_clips )
  clips_per_session{end+1, 1} = [];
  
  sub_sample = setdiff( 1:num_clips, already_matched );
  sub_sample = sub_sample(randperm(numel(sub_sample)));
  
  targ_dur = 0;

  while ( targ_dur < target_dur && ~isempty(sub_sample) )
    curr = sub_sample(1);
    sub_sample(1) = [];
    already_matched(end+1, 1) = curr;
    clips_per_session{end}(end+1, 1) = curr;
    targ_dur = targ_dur + total_duration(curr);
  end
end

end