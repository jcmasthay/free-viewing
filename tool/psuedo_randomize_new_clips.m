start_ts = clip_table.Start;
stop_ts = clip_table.Stop;
target_dur = 15 * 60;

while ( true )

clips_per_session = generate_clips_per_session( target_dur, start_ts, clip_table.TotalDuration )

all_sources = unique( clip_table.SourceMovie );
sources_per_session = cell( size(clips_per_session) );
for i = 1:numel(clips_per_session)
  [~, loc] = ismembser( clip_table.SourceMovie(clips_per_session{i}), all_sources );
  sources_per_session{i} = loc;
end

has_mult_thieves = any( cellfun(@(x) sum(x == 4) > 1, sources_per_session) );
if ( ~has_mult_thieves )
  break
end

end

%%

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