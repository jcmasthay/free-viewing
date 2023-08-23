function rewarded_break(pause_time, varargin)

defaults = struct();
defaults.max_num_reward_pulses = 2;
defaults.reward_ipi_s = 1;
defaults.reward_dur_s = 0.2;
defaults.use_reward = true;
params = shared_utils.general.parsestruct( defaults, varargin );

rwd_ipi = params.reward_ipi_s;
reward_dur_s = params.reward_dur_s;
max_num_pulses = params.max_num_reward_pulses;

rwd_interface = RewardInterface( ~params.use_reward );
rwd_cb = @() deliver_reward( rwd_interface, 1, reward_dur_s );

timer = tic();

% reward timing
last_reward_t = -inf;

num_pulses = 0;

while ( toc(timer) < pause_time )
  update( rwd_interface );

  if ( toc(timer) - last_reward_t > rwd_ipi && num_pulses < max_num_pulses )
    rwd_cb();
    last_reward_t = toc( timer );
    num_pulses = num_pulses + 1;
  end
end

end