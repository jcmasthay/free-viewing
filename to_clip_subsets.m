function [start_ts, stop_ts] = to_clip_subsets(starts, stops)

start_ts = cell( size(starts, 1), 1 );
stop_ts = cell( size(start_ts) );

for i = 1:size(starts, 1)
  last_ok = find( ~isnan(starts(i, :)), 1, 'last' );
  start_ts{i} = starts(i, 1:last_ok);
  stop_ts{i} = stops(i, 1:last_ok);
end

end