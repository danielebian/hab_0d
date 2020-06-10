 function cost = optim_cost_fun_chemostat_series(Series)

 % Model variables:
 switch Series.BioModule
 case 'bec_diat'
    var_obs = {'PO4_out','NO3_out','Si_out','Chl_out','PNN_out','PNSi_out','PDA_out','DDA_out'};
    var_mod = {'PO4',    'NO3',    'Si',    'DiChl',  'DiN',    'DiSi',    'pDA',    'dDA'};
    var_wgt = [ 0         1         1        1         0         0          1         1];  
 otherwise
    error(['Crazy town! (BioModule case not found)']);
 end

 nvar = length(var_obs);

 % Initialize the cost
 error2_all = [];

 % Infinitesimal number to prevent divisions by 0
 eps_val = 1e-15;

 % Loops though all variables and calculate for each individual variable 
 % the NORMALIZED squared errors
 for indv=1:nvar
    
    % Adds an infinitesimal value to both terms, to prevent division by 0;
    tmp_obs = Series.VarAll.(var_obs{indv}) + eps_val;
    tmp_mod = Series.OutAll.(var_mod{indv}) + eps_val;

    % If all model variables are NaN, assigns LARGE cost
    if all(isnan(tmp_mod))
       tmp_err2 = 1e12;
    else
       % If all Observations are NaNs, sets error to NaN
       % Otherwise calculate squared error
       if ~all(isnan(tmp_obs))
          tmp_err2 = sum(((tmp_obs - tmp_mod)./tmp_obs).^2,'omitnan');
       else
          tmp_err2 = nan;
       end
    end
    error2_all = [error2_all tmp_err2]; 
 end

 if (0)
    disp(error2_all)
 end

 % The final cost will be the sum of individual variable costs (the errors) but squared, so it
 % will penalize variables with larger deviaations more than variables with smaller deviations
 % It will also use different weights for different variables
 cost = sum(error2_all.^2 .* var_wgt,'omitnan')./sum(var_wgt);

 

 
