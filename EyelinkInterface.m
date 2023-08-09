classdef EyelinkInterface < handle
  properties
    eyelink = [];
    bypassed = false;
    data_p = [];
    data_file_p = [];
    data_file_name = [];
    has_file = false;
  end
  
  methods
    function obj = EyelinkInterface()
      obj.eyelink = ptb.sources.Eyelink();
    end
    
    function initialize(obj, data_p)
      if ( obj.bypassed )
        return
      end
      
      obj.data_p = data_p;
      obj.has_file = false;
      file_args = {};
      
      if ( ~isempty(obj.data_p) )
        num_edfs = 1;
        try
          edfs = shared_utils.io.find( obj.data_p, '.edf' );
          num_edfs = numel( edfs ) + 1;
        end
        file_args{1} = sprintf( '%d.edf', num_edfs );
        
        obj.has_file = true;
        obj.data_file_name = file_args{1};
        obj.data_file_p = fullfile( obj.data_p, obj.data_file_name );
      end
      
      initialize( obj.eyelink );
      start_recording( obj.eyelink, file_args{:} );
    end
    
    function shutdown(obj)
      if ( obj.bypassed )
        return
      end
      
      stop_recording( obj.eyelink );
      
      if ( obj.has_file )
        receive_file( obj.eyelink, obj.data_p );
      end
    end
  end
end