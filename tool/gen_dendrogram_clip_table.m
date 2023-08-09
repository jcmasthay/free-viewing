dendo_p = '/Users/nick/source/changlab/jamie/dendogram';
dend_outs = load( fullfile(dendo_p, 'output.mat') );

clip_p = '/Users/nick/source/changlab/jamie/fv_task/data/clip_table.mat';
src_clips = shared_utils.io.fload( clip_p );
src_summaries = lower( strrep(src_clips.Summary, ' ', '') );
dend_summaries = lower( strrep(dend_outs.summary, ' ', '') );
[~, summary_ord] = ismember( dend_summaries(:), src_summaries(:) );

%

fs = fullfile( dendo_p, {'set1.txt', 'set2.txt', 'set3.txt'} );
fs = cellfun( @(x) strsplit(strrep(fileread(x), ' ', '_'), newline), fs, 'un', 0 );
fs = cellfun( @(x) x(:), fs, 'un', 0 );
fs = string( vertcat(fs{:}) );

ls = string( cellstr(dend_outs.linkage_matrix_labels) );
clean_ls = lower( strrep(ls, '_', '') );
clean_fs = lower( strrep(fs, '_', '') );

miss = setdiff( clean_fs, clean_ls );
% one misconverted piece of text, misread 1 as l
assert( miss == 'mcqingroupsettlementbattlel' );
clean_fs(clean_fs == miss) = 'mcqingroupsettlementbattle1';
assert( numel(intersect(clean_fs, clean_ls)) == numel(clean_fs) );

affil = "affiliative";
aggr = "aggressive";
neut = "neutral";

off = 0;
affil_kind = strings( size(fs) );
inter_type = strings( size(fs) );

% affil, orange
n = 7;
affil_kind(off+1:off+n) = affil;
inter_type(off+1:off+n) = "monkey_human";
off = off + n;

% agg,  green
n = 9;
affil_kind(off+1:off+n) = aggr;
inter_type(off+1:off+n) = "monkey_human";
off = off + n;

% affil, red
n = 3;
affil_kind(off+1:off+n) = affil;
inter_type(off+1:off+n) = "monkey_other_animal";
off = off + n;

% agg,  purple
n = 7;
affil_kind(off+1:off+n) = aggr;
inter_type(off+1:off+n) = "monkey_other_animal";
off = off + n;

% agg,  brown
n = 13;
affil_kind(off+1:off+n) = aggr;
inter_type(off+1:off+n) = "monkey_monkey";
off = off + n;

% affil,  pink
n = 19;
affil_kind(off+1:off+n) = affil;
inter_type(off+1:off+n) = "monkey_monkey";
off = off + n;

% neut, gray
n = 9;
affil_kind(off+1:off+n) = neut;
inter_type(off+1:off+n) = "neutral_or_nonsocial";
off = off + n;

% order `clean_fs` based on the order of labels in `dendo_outs`
to_dendro_ord = zeros( size(clean_ls) );
for i = 1:numel(clean_ls)
  to_dendro_ord(i) = find( clean_fs == clean_ls(i) );
end

t = table( affil_kind, inter_type, clean_fs(:) ...
  , 'va', {'affiliativeness', 'interactive_agency', 'clip_id'} );
% t is now in the same order as `src_clips`
t = t(to_dendro_ord, :);
t.duration = src_clips.TotalDuration;

if ( 1 )
  save( fullfile(fileparts(clip_p), 'dendro_table.mat'), 't' );
end