function [all_starts, all_stops, all_inds] = generate_clip_chunks(start, stop, clip_dur)

[start_ts, stop_ts] = to_clip_subsets( start, stop );

all_starts = [];
all_stops = [];
all_inds = [];

for i = 1:numel(start_ts)
  [starts, stops] = partition_clip_subsets( start_ts{i}, stop_ts{i}, clip_dur );
  
  all_starts = [ all_starts; vertcat(starts{:}) ];
  all_stops = [ all_stops; vertcat(stops{:}) ];
  all_inds = [ all_inds; repmat(i, sum(cellfun(@numel, starts)), 1) ];
end

end