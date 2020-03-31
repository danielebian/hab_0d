 function data_resamp = optim_resample_data(hab,data)

 % Given a model solution "hab" and an bservational timeseries
 % resamples the model variables at the time of the observations
 % data need to have the following format
 % data.var = {'v1','v2', ...}		: list of variables (should be the same names as model variables)
 % data.v1				: variable 1
 % data.v1Time				: time of observation for variable 1
 % data.v2				: variable 2
 % data.v2Time				: time of observation for variable 2
 % etc.

 data_resamp.var = data.var;

 for indv=1:length(data.var)

    % Picks the observation variable and time
    obs_time = data.([data.var{indv} 'Time']);
    data_resamp.(data.var{indv}).time = obs_time;
    data_resamp.(data.var{indv}).obs = data.([data.var{indv}]); 

    % Adds the model resampled at time of observations
    mod_time = hab.Sol.time;
    mod_var = hab.Sol.(data.var{indv});

    % Interpolates model at time of observations
    % NOTE: this will put NaNs at extrapolated values (i.e. outside model time range)
    mod_var_resamp = interp1(mod_time,mod_var,obs_time,'linear');

    % Fill in model resampled values
    data_resamp.(data.var{indv}).mod = mod_var_resamp;


 end

