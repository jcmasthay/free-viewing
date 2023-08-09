function t = to_cellstr(t)

if ( size(t, 1) == 0 )
  return
end

vars = t.Properties.VariableNames;
for i = 1:numel(vars)
  if ( isa(t.(vars{i})(1), 'string') )
    t.(vars{i}) = cellstr( t.(vars{i}) );
  end
end

end