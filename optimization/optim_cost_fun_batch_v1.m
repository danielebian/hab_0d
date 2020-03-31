 function cost = optim_cost_fun_batch_v1(DataResamp)

 vars = DataResamp.var;
 nvar = length(vars); 

 % Initialize the cost
 error_all = [];

 % Loops through all variables
 for indv=1:nvar

    % Calculate range of model and obs. together
    % this is done so each variable will be normalized to be between 0-1
    mmin = min([DataResamp.(vars{indv}).obs(:);DataResamp.(vars{indv}).mod(:)]);
    mmax = max([DataResamp.(vars{indv}).obs(:);DataResamp.(vars{indv}).mod(:)]);
    mrange = mmax - mmin;

    % Calculate the squared error for each timestep for the current variable
    merr = (DataResamp.(vars{indv}).obs(:) - DataResamp.(vars{indv}).mod(:)) .^2 / mrange^2;
    % Calculate the mean
    % NOTE: this ignores NANs
    mmerr = nanmean(merr);
    
    % Adds the cost for this variable to a vector of all costs 
    error_all = [error_all mmerr];

 end

 if (0)
    disp(error_all)
 end

 % WARNING: sets the cost of NaNs to 1
 % NOTE: we should not get NaNs, this is an integration problem (e.g. large timestep...)
 error_all(isnan(error_all)) = 1;

 % The final cost will be the sum of individual variable costs (the errors) but squared, so it
 % will penalize variables with larger deviaations more than variables with smaller deviations
 cost = sum(error_all.^2);

 

 
