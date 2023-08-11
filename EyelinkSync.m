classdef EyelinkSync < handle
  properties
    bypassed = false;
    sync_ts = [];
  end
  
  methods
    function obj = EyelinkSync(bypass)
      if ( nargin < 1 )
        bypass = false;
      end
      obj.bypassed = bypass;
    end
    
    function ts = get_sync_times(obj)
      ts = obj.sync_ts;
    end
    
    function send_frame_info(obj, clip_index, vid_t, curr_t)
      if ( obj.bypassed )
        return
      end
      
      obj.sync_ts(end+1) = curr_t;
      message = sprintf( '%d | %0.4f | %d', clip_index, vid_t, numel(obj.sync_ts) );
      Eyelink( 'Message', message );
    end
  end
end