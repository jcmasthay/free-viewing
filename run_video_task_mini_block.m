function [err, did_abort] = run_video_task_mini_block(win, block, varargin)

err = [];
did_abort = false;
try   
  did_abort = video_task( ...
    win, block.video_p, block.start, block.stop, block, varargin{:} );
  if ( did_abort )
    return
  end
catch err
  %
end

end