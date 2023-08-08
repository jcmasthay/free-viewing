function mini_blocks = generate_randomized_miniblocks(As, Bs, Cs)

assert( isequal(size(As), size(Bs), size(Cs)) ...
  , 'Expect same number of clips for A, B and C.' );

% ords = string( ['ABC'; 'ACB'; 'BAC'; 'BCA'; 'CBA'; 'CAB'] );
ords = perms( 1:3 );

num_blocks = ceil( numel(As) / numel(ords) );
conds = shared_utils.general.get_blocked_condition_indices( ...
  num_blocks, size(ords, 1), size(ords, 1) );

sets = { As, Bs, Cs };

mini_blocks = cell( size(As, 1), 1 );

for i = 1:numel(As)
  curr_ord = ords(conds(i), :);
  mini_blocks{i} = [ 
      sets{curr_ord(1)}{i}
      sets{curr_ord(2)}{i}
      sets{curr_ord(3)}{i}
  ];
end

end