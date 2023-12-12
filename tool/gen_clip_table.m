is_new_clip_tbl = true;

if ( is_new_clip_tbl )
  data_p = fullfile( project_directory(), 'data/new_clips.xlsx' );
else
  data_p = fullfile( project_directory(), 'data/Monkey Clip Submission Form V2 (Responses).xlsx' );
end

clip_xls = readtable( data_p );

%%

if ( is_new_clip_tbl )
  full_start_ts = clip_xls.Start;
  full_stop_ts = clip_xls.End;

  cont_vs_broken = string( clip_xls.Continuous_ );

  start_cols = compose( "Part%dStart", 1:3 );
  stop_cols = compose( "Part%dEnd", 1:3 );
  
else
  full_start_ts = clip_xls.StartTime_00_00Format_;
  full_stop_ts = clip_xls.EndTime;

  cont_vs_broken = string( clip_xls.IsTheClipContinuousOrBroken_i_e__SomePartsInTheMiddleWillBeCutO );

  start_cols = { 'Part1StartTime_00_00Format_', 'Part2StartTime', 'Part3StartTime' };
  stop_cols = { 'Part1EndTime', 'Part2EndTime', 'Part3EndTime' };
end

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

if ( is_new_clip_tbl )
  source_movies = clip_xls.Source;
  seasons = clip_xls.Season;
  episodes = clip_xls.Epi_; % @note
  summaries = clip_xls.Summary;
  codes = clip_xls.Code;
else
  source_movies = clip_xls.SourceMovie;
  seasons = clip_xls.SelectSeason;
  episodes = clip_xls.SelectEpisode_1; % @note
  summaries = clip_xls.PleaseProvideAShortSummaryOfTheClip;
  codes = strings( size(episodes) );
end

dst_tbl = table( ...
    all_clip_starts ...
  , all_clip_stops ...
  , string(source_movies) ...
  , seasons ...
  , episodes ...
  , codes ...
  , 'va', {'Start', 'Stop', 'SourceMovie', 'Season', 'Episode', 'Code'} ...
);

clip_fnames = strings( size(dst_tbl, 1), 1 );

is_monk_th = contains( dst_tbl.SourceMovie, 'Monkey Thieves' );
clip_fnames(is_monk_th) = compose( "Monkey Thieves S%dE%d" ...
  , dst_tbl.Season(is_monk_th), dst_tbl.Episode(is_monk_th) );

is_monk_planet = contains( dst_tbl.SourceMovie, 'Monkey Kingdom' );
clip_fnames(is_monk_planet) = "monkey_planet_take_2";

dst_tbl.VideoFilename = clip_fnames;

dst_tbl.Start = convert_clip_timestamps_to_seconds( dst_tbl.Start );
dst_tbl.Stop = convert_clip_timestamps_to_seconds( dst_tbl.Stop );
dst_tbl.TotalDuration = nansum( dst_tbl.Stop - dst_tbl.Start, 2 );
dst_tbl.Summary = summaries;

if ( is_new_clip_tbl )
  fname = 'new_clip_table.mat';
else
  fname = 'clip_table.mat';
end

if ( 1 )
  save( fullfile(project_directory, 'data', fname), 'dst_tbl' );
end

%%

function ts = convert_clip_timestamps_to_seconds(ts)

minute = floor( ts );
sec = ts - minute;
ts = minute * 60 + floor( sec * 100 );

end