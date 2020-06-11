 function mcost = optim_minimize_batch_SiLim(ParStart,FunArg)

 nparam = length(FunArg.ParNames);
 
 % Unfolds arguments
 ParNames = FunArg.ParNames;
 ParMin = FunArg.ParMin;
 ParNorm = FunArg.ParNorm;
 ParModule = FunArg.ParModule;

 % Re-builds non-normalized parameters:
 %ParVal = ParMin + ParStart .* ParNorm;
 ParVal = bsxfun(@plus,ParMin,bsxfun(@times,ParStart,ParNorm));

 % Allows for parallelization of cost function, accepting ParStart input of size [Np x Nm]
 % Np: # parameters for the optimization of the problem
 % Nm: # simultaneous evaluations of cost function for parallel CMAES optimization algorithm

 [Np Nm] = size(ParStart);

 % Initializes cost for Nm parallel evaluations
 mcost = nan(1,Nm);

 parfor indm=1:Nm

    %-------------------------------------------------------
    % Initialize the model - baseline
    % Based on the code and options in hab_main.m
    %-------------------------------------------------------

    % Clear hab;
    hab = struct('EmptyField',0);
   
    % Biological module
    %hab.BioModule = 'anderson';
    %hab.BioModule = 'terseleer';
    hab.BioModule = 'bec_diat';
   
    % Experimental setup
     hab.ExpModule = 'batch';
    %hab.ExpModule = 'chemostat';
    %hab.ExpModule = 'mixed_layer';
   
    % Here, if needed, overrides default parameters for BioModules and SetUp
    % All Suite experiments will adopt these parameters
    % (use ['property',value] format)
    % NOTE: these should be variables not used as Suite Parameters
    new_BioPar = {};
    new_SetUp = {'dt',0.05};
   
    %---------------------
    % Here, creates the input arguments for bio module and experiment setup
    % (includes any overridden parameters in new_BioPar and new_SetUp)
    arg_BioPar = new_BioPar;
    arg_SetUp = new_SetUp;
    for indp=1:nparam
       switch ParModule{indp}
       case 'BioPar'
          arg_BioPar = [arg_BioPar ParNames(indp) ParVal(indp,indm)];
       case 'SetUp'
          arg_SetUp = [arg_SetUp ParNames(indp) ParVal(indp,indm)];
       otherwise
          error(['module ' Suite.module{ipar}  ' is not valid']);
       end
    end 
   
    %---------------------
    % Initialized Biomodule with user-defined inputs
    switch hab.BioModule
    case 'anderson'
       hab = hab_biopar_anders(hab,arg_BioPar{:});
    case 'terseleer'
       hab = hab_biopar_tersel(hab,arg_BioPar{:});
    case 'bec_diat'
       hab = hab_biopar_bec_diat(hab,arg_BioPar{:});
    otherwise
       error(['Crazy town! (biological case not found)']);
    end
   
    % Initialized SetUp with user-defined inputs
    switch hab.ExpModule
    case 'batch'
       hab = hab_setup_batch(hab,arg_SetUp{:});
    case 'chemostat'
       hab = hab_setup_chemo(hab,arg_SetUp{:});
    case 'mixed_layer'
       hab = hab_setup_mixed(hab,arg_SetUp{:});
    otherwise
       error(['Crazy town! (experiment case not found)']);
    end
    %---------------------
    % Runs the model
    hab = hab_integrate(hab);
    % Postprocess the result
    hab = hab_postprocess(hab);
   
    %---------------------
    % Calculates the cost function
    
    % First loads the data for this experiment
    tmp = load('DataTersSiLim.mat');
    DataTersSiLim = tmp.DataTersSiLim;
    % Resamples model on data points
    data_resamp = optim_resample_data(hab,DataTersSiLim);
    % Actual cost function calculation
    tcost = optim_cost_fun_batch_v1(data_resamp);

    % Fill in parallel array of costs for current cost function evaluation
    mcost(1,indm) = tcost;
   
    if (0)
      % Verbose option
      disp(ParVal);
      disp(hab.BioPar);
      disp(['Cost ' num2str(tcost)]);
      disp(['--------------------------------------------------------------------']);
    end

 end 	% parfor indm 
