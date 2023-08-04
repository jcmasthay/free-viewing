classdef RewardInterface < handle
  properties
    bypassed = false;
    port = 'COM3';
    channels = {'A', 'B', 'C'};
    comm = [];
  end
  
  methods
    function obj = RewardInterface(bypassed)
      obj.bypassed = bypassed;

      if ( ~bypassed )
        obj.comm = serial_comm.SerialManager( obj.port, struct(), obj.channels );
        start( obj.comm );
      end
    end
    
    function deliver_reward(obj, channel, duration_s)
      if ( has_comm(obj) )
        reward( obj.comm, channel, duration_s * 1e3 ); % to ms
      end
    end
    
    function tf = has_comm(obj)
      tf = ~obj.bypassed && ~isempty( obj.comm ) && isvalid( obj.comm );
    end
    
    function update(obj)
      if ( has_comm(obj) )
        update( obj.comm );
      end
    end
    
    function delete(obj)
      if ( has_comm(obj) )
        close( obj.comm );
        obj.comm = [];
      end
    end
  end
end