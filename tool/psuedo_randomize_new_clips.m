clip_table = shared_utils.io.fload( fullfile(project_directory, 'data', 'new_clip_table.mat') );

start_ts = clip_table.Start;
stop_ts = clip_table.Stop;
target_dur = 15 * 60;

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

%%  construct a table of shot transitions, properly ordered, for each session

st_tbl = table();

for sesh_ind = 1:numel(clips_per_session)
  
clip_inds = clips_per_session{sesh_ind};
clips_sesh = clip_table(clip_inds, :);

sesh_st_tbl = table();
success = true;

try
% clip_ind = 4;
  for clip_ind = 1:numel(clip_inds)

  abs_clip_ind = clip_inds(clip_ind);
  curr_clip = clips_sesh(clip_ind, :);
  num_segs = find( ~isnan(curr_clip.Start), 1, 'last' );

  for s = 1:num_segs
    search_id = string( curr_clip.Code );
    if ( num_segs > 1 )
      search_id = compose( "%s%d", search_id, s );
    end

    match_pred = pred_tbl.identifier == search_id;
    % @TODO
    assert( nnz(match_pred) > 0, 'No prediction file matched clip code "%s".', search_id );

    keep_vars = setdiff( ...
      clips_sesh.Properties.VariableNames, pred_tbl.Properties.VariableNames );

    ones_per_st_tbl = ones( sum(match_pred), 1 );

    curr_st_tbl = pred_tbl(match_pred, :);
    curr_st_tbl.start = curr_st_tbl.start + curr_clip.Start(s);
    curr_st_tbl.stop = curr_st_tbl.stop + curr_clip.Start(s);
    curr_st_tbl.clip_index = ones_per_st_tbl * abs_clip_ind; 
    curr_st_tbl.session_index = ones_per_st_tbl * sesh_ind;
    curr_st_tbl = [ curr_st_tbl, repmat(curr_clip(:, keep_vars), size(curr_st_tbl, 1), 1) ];

    sesh_st_tbl = [sesh_st_tbl; curr_st_tbl];
  end

  end
catch err
  warning( err.message );
  success = false;
end

if ( success )
  % only add successful sesssions
  st_tbl = [ st_tbl; sesh_st_tbl ];
end

end

%%

if ( 1 )
  save( fullfile(project_directory, 'data', 'shot_transition_table.mat'), 'st_tbl' );
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