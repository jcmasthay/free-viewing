data_p = '/Users/nick/Downloads/Monkey Clip Submission Form V2 (Responses).xlsx';
clip_xls = readtable( data_p );

%%

full_start_ts = clip_xls.StartTime_00_00Format_;
full_stop_ts = clip_xls.EndTime;

cont_vs_broken = string( clip_xls.IsTheClipContinuousOrBroken_i_e__SomePartsInTheMiddleWillBeCutO );

start_cols = { 'Part1StartTime_00_00Format_', 'Part2StartTime', 'Part3StartTime' };
stop_cols = { 'Part1EndTime', 'Part2EndTime', 'Part3EndTime' };

clip_starts = clip_xls{:, start_cols};
clip_stops = clip_xls{:, stop_cols};

is_cont = cont_vs_broken == 'Continuous';
is_broke = ~is_cont;

has_full = ~isnan( full_start_ts ) & ~isnan( full_stop_ts );
assert( ~any(is_cont & ~has_full) );

has_pt1 = ~isnan( clip_starts(:, 1) ) & ~isnan( clip_stops(:, 1) );
assert( ~any(is_broke & ~has_pt1) );

%%  reformat

all_clip_starts = nan( size(clip_xls, 1), 3 );
all_clip_stops = nan( size(all_clip_starts) );

all_clip_starts(is_cont, 1) = full_start_ts(is_cont);
all_clip_stops(is_cont, 1) = full_stop_ts(is_cont);

all_clip_starts(is_broke, :) = clip_starts(is_broke, :);
all_clip_stops(is_broke, :) = clip_stops(is_broke, :);

dst_tbl = table( ...
    all_clip_starts ...
  , all_clip_stops ...
  , string(clip_xls.SourceMovie) ...
  , clip_xls.SelectSeason ...
  , clip_xls.SelectEpisode_1 ...  % @note
  , 'va', {'Start', 'Stop', 'SourceMovie', 'Season', 'Episode'} ...
);
