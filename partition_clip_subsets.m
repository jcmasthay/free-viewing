function [starts, stops, store_ii] = partition_clip_subsets(start_ts, stop_ts, clip_len)

total_dur = sum( stop_ts(:) - start_ts(:) );
num_segs = floor( total_dur / clip_len );
assert( num_segs > 0, 'Clip is too short: less than %d seconds.', clip_len );

starts = {};
stops = {};
store_ii = {};

ii = 1; % interval index
di = 1; % destination index
offset = 0;
leftover = clip_len;

while ( ii <= numel(start_ts) )
  curr_ii = ii;
  
  start_t = start_ts(ii) + offset;
  stop_t = min( start_t + leftover, stop_ts(ii) );
  
  accum = stop_t - start_t;
  leftover = leftover - accum;
  
  if ( stop_t == stop_ts(ii) )
    offset = 0;
    ii = ii + 1;
  else
    offset = offset + accum;
  end
  
  if ( di > numel(starts) )
    starts{di, 1} = [];
    stops{di, 1} = [];
    store_ii{di, 1} = [];
  end
  
  starts{di, 1}(end+1) = start_t;
  stops{di, 1}(end+1) = stop_t;
  store_ii{di, 1}(end+1) = curr_ii;
  
  if ( leftover == 0 )
    di = di + 1;
    leftover = clip_len;
  end
end

starts = starts(1:num_segs);
stops = stops(1:num_segs);
store_ii = store_ii(1:num_segs);

starts = cellfun( @(x) x(:), starts, 'un', 0 );
stops = cellfun( @(x) x(:), stops, 'un', 0 );
store_ii = cellfun( @(x) x(:), store_ii, 'un', 0 );

end