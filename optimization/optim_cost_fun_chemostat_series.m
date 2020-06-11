 function cost = optim_cost_fun_chemostat_series(Series)

 % Model variables:
 switch Series.BioModule
 case 'bec_diat'
    var_obs = {'PO4_out','NO3_out','Si_out','Chl_out','PNN_out','PNSi_out','PDA_out','DDA_out'};
    var_mod = {'PO4',    'NO3',    'Si',    'DiChl',  'DiN',    'DiSi',    'pDA',    'dDA'};
    var_wgt = [ 0.5       1         0.5      2         0         0          2         1];  
 otherwise
    error(['Crazy town! (BioModule case not found)']);
 end

 nvar = length(var_obs);

 % Infinitesimal number to prevent divisions by 0
 eps_val = 1e-15;

 % Initialize the cost
 error2_all = [];

 % Loops though all variables and calculate for each individual variable 
 % the NORMALIZED squared errors
 % Normalization is done by taking some form of averaged range
 % This is somewhat unsatisfactoy given the nature of chemostat experiments 
 for indv=1:nvar
    
    tmp_obs = Series.VarAll.(var_obs{indv});
    tmp_mod = Series.OutAll.(var_mod{indv});

    % NORMALIZATION FACTOR:
    % Varous options are possible. For now uses some form of
    % typical range, based on the Observations only
   %norm_fact = mean(tmp_obs,'omitnan');
   %norm_fact = std(tmp_obs,'omitnan');
    norm_fact = max(tmp_obs) - min(tmp_obs);

    % Adds an infinitesimal value to prevent division by 0;
    norm_fact = norm_fact + eps_val;

    % If all model variables are NaN, assigns LARGE cost
    if all(isnan(tmp_mod))
       tmp_err2 = 1e12;
    else
       % If all Observations are NaNs, sets error to NaN
       % Otherwise calculate squared error
       if ~all(isnan(tmp_obs))
          tmp_err2 = sum(((tmp_obs - tmp_mod)./norm_fact).^2,'omitnan');
       else
          tmp_err2 = nan;
       end
    end
    error2_all = [error2_all tmp_err2]; 
 end


 % The final cost will be the sum of individual variable costs (the errors) but squared, so it
 % will penalize variables with larger deviaations more than variables with smaller deviations
 % It will also use different weights for different variables
 cost = sum(error2_all.^2 .* var_wgt,'omitnan')./sum(var_wgt);

 if (0)
    disp(error2_all)
    disp(cost)
 end
