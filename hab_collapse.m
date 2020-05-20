 function hab = hab_postprocess(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D postprocessing
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% "Collapses" hab Solution output, by averaging between two time steps
% by default it just takes the last timestep, reducing the solution to single numbers
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.time_start = nan;	% Starting time for averaging (nan uses dt=end)
 Param.time_end   = nan;	% Ending time for averaging (nan uses dt=end) 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 time_vect = hab.Sol.time;

 if ~isnan(Param.time_start)
    dt_start = findin(Param.time_start,time_vect);
 else
    dt_start = length(time_vect);
 end

 if ~isnan(Param.time_end)
    dt_end = findin(Param.time_end,time_vect);
 else
    dt_end = length(time_vect);
 end

 % Averages solution between dt1 and dt2
 % Loops through all solution variables to regrid them on time axis
 allvar = setdiff(fieldnames(hab.Sol),'time');
 nvar = length(allvar);
 for indv=1:nvar
    % Gets and interpolates variable on new time axis
    oldvar = hab.Sol.(allvar{indv});
    newvar = mean(oldvar(:,dt_start:dt_end),2);
    % Substitutes back into Solution structure
    hab.Sol.(allvar{indv}) = newvar;
 end
 % Substitutes time vector in Solution structure
 hab.Sol.time = mean(time_vect(:,dt_start:dt_end),2);
 % Adds new timestep to solution 
 hab.SetUp.dt_out = nan;

