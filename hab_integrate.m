 function hab = hab_integrate(hab)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D integration
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Calculate the sources and sinks
 
 nvar = hab.BioPar.nvar;        % number of model state variables
 nevar = hab.SetUp.nevar;       % number of model state variables
 ntime = hab.SetUp.ntime;       % number of model time steps
 dt = hab.SetUp.dt;             % timestep (hours)

 % Creates a matrix of size [nvar,ntime] to do time integration
 AllVar = nan(nvar,ntime);
 % Set inital conditions 
 for indv=1:nvar
    AllVar(indv,1) = hab.BioPar.([hab.BioPar.varnames{indv} '_0']);
 end

 % Creates a matrix of size [nvar,ntime] to do time integration
 EnvVar = nan(nevar,ntime);
 % Fills in the entire matrix with prescribed environmental forcings
 for indv=1:nevar
    EnvVar(indv,:) = hab.SetUp.Env.([hab.SetUp.evarnames{indv}]);
 end

 % For chemostat/ML case, set vector of inflow concentrations 
 % (one input concentration per variable, set as constant over time)
 for indv=1:nvar
    InVar(indv,1) = hab.BioPar.([hab.BioPar.varnames{indv} '_in']);
 end

 for indt=2:ntime
    % Uncomment this for run-time display of current time-step
    fprintf(['Integration time step #' num2str(indt) '/' num2str(ntime) '\n']);
 
    % Calculates the sources minus sink terms, using the state variables
    % at the previous time step, and all model parameters

    % (1) Gets Biological Sources and Sinks
    switch hab.BioModule
    case 'anderson'
       sms_bio = hab_sms_anderson(hab,AllVar(:,indt-1));
    case 'terseleer'
       sms_bio = hab_sms_tersel(hab,AllVar(:,indt-1),EnvVar(:,indt));
    case 'bec_diat'
       sms_bio = hab_sms_bec_diat(hab,AllVar(:,indt-1),EnvVar(:,indt));
    case 'bec_bec_full'
       sms_bio = hab_sms_bec_full(hab,AllVar(:,indt-1),EnvVar(:,indt));
    otherwise
       error(['Crazy town! (biological case not found)']);
    end
   
    % (2) Gets the physical sources and sinks
    switch hab.ExpModule
    case 'batch'
       sms_phys = zeros(nvar,1);
    case 'chemostat'
       % For the chemostat case, calculates the SMS due to dilution simply as 
       % the difference of tracer coming in minus tracer going out
       sms_phys = hab.SetUp.Flow/hab.SetUp.Vol * (InVar - AllVar(:,indt-1));
    case 'mixed_layer'
       % For the mixed layer case, calculate the sources and sinks due to
       % dilution by deepening of the mixed layer, and by flow through the mixed layer
       % (i.e. mixing or upwelling) following formulation of Evan and Parslow, 1985
       % For simplicity, uses a seprate function
       sms_phys = hab_sms_mixed_layer(hab,AllVar(:,indt-1),EnvVar(:,indt),InVar);
    otherwise
       error(['Crazy town! (physical SMS case not found)']);
    end

   % Actual integration step, using a forward time scheme
   AllVar(:,indt) = AllVar(:,indt-1) + dt * (sms_bio + sms_phys);

 end

 % Transfer variables from integration array to solution structure
 hab.Sol.time = hab.SetUp.time;
 for indv=1:nvar
    hab.Sol.(hab.BioPar.varnames{indv}) = AllVar(indv,:);
 end 
 
 

