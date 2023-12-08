% Pres 'r' to trigger reward

%fclose( instrfindall );

conf = dg.config.create();

channels = 1;
reward_duration_s = 0.1;

fv_reward_listener( conf, channels, reward_duration_s );