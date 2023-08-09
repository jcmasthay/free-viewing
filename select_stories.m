function [selected_stories, possible_stories] = select_stories(...
  dendrogram_t, target_total_dur_s, allowed_slop_s, allowed_p_affil_imbalance)

possible_stories = [];
selected_stories = [];

for ns = 2:rows(dendrogram_t)
  % enumerate all possible combinations of clips taken `ns` at a time
  cmbs = nchoosek( 1:size(dendrogram_t, 1), ns );
  
  % try to find a set of stories close enough to the target duration.
  poss_dur = false( size(cmbs, 1), 1 );
  for i = 1:size(cmbs, 1)
    tot_dur = sum( dendrogram_t.duration(cmbs(i, :)) );
    
    if ( tot_dur <= target_total_dur_s && ...
         target_total_dur_s - tot_dur < allowed_slop_s )
      poss_dur(i) = true;
    end
  end
  
  poss_dur = find( poss_dur );
  poss_affil = false( size(poss_dur) );
  
  % for sets of stories close enough to the target duration, try to find
  % a set that balances affiliative-ness vs aggression, to within the
  % allowed slop.
  for i = 1:numel(poss_dur)
    poss_inds = cmbs(poss_dur(i), :);    
    is_affil = dendrogram_t.affiliativeness(poss_inds) == 'affiliative';
    p_affil = sum( is_affil ) / numel( is_affil );
    p_err = abs( p_affil - 0.5 );
    if ( p_err < allowed_p_affil_imbalance )
      poss_affil(i) = true;
    end
  end
  
  % if any survive the above criteria, choose a set at random.
  if ( any(poss_affil) )
    poss_inds = poss_dur(poss_affil);
    possible_stories = cmbs(poss_inds, :);
    ok = poss_inds(randsample(numel(poss_inds), 1));
    selected_stories = cmbs(ok, :);
    selected_stories = selected_stories(randperm(numel(selected_stories)));
    break
  end
end

end