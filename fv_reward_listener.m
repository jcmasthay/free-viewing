function fv_reward_listener(conf, channels, duration_s)

ListenChar( 2 );
cleanup = onCleanup( @() ListenChar(0) );

reward_manager = create_reward_manager( conf );

t = nan;
timeout = 0.25;

while ( ~ptb.util.is_esc_down )
  if ( ptb.util.is_key_down(ptb.keys.r) && (isnan(t) || toc(t) > timeout) )
    for i = 1:numel(channels)
      deliver_reward( reward_manager, channels(i), duration_s );
    end
    t = tic();
  end
end

close( reward_manager );

end

function arduino_reward_manager = create_reward_manager(conf)

serial = conf.serial;

if ( serial.disabled )
  arduino_reward_manager = [];
  return
end

port = serial.port;
messages = struct();
channels = serial.channels;

arduino_reward_manager = serial_comm.SerialManager( port, messages, channels );
start( arduino_reward_manager );

end

function deliver_reward(reward_manager, channel, duration_s)

if ( ~isempty(reward_manager) && isvalid(reward_manager) )
  reward( reward_manager, channel, duration_s * 1e3 ); % to ms
end

end