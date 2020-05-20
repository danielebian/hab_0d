% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript 
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Same as hab_run_suite.m but set up for chemostat experiments specifically 
%
% Documentation:
% This script allows to perform "sensitivity experiments", where an arbitrary number
% of model parameters is varied, and the model run for each possible combinations of
% parameters.
% Output for each parameter combination will be stored in the cell array Suite.Out
% Access individual experiments by using the appropriate indices, e.g. Suite.Out{1,1}, ... 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath ./functions

 %-------------------------------------------------------
 % Initialize the model - baseline
 % Based on the code and options in hab_main.m
 %-------------------------------------------------------
 clear hab;

 % Biological module
 %hab.BioModule = 'anderson';
 %hab.BioModule = 'terseleer';
  hab.BioModule = 'bec_diat';

 % Experimental setup
 %hab.ExpModule = 'batch';
  hab.ExpModule = 'chemostat';
 %hab.ExpModule = 'mixed_layer';

 % Here, if needed, overrides default parameters for BioModules and SetUp
 % All Suite experiments will adopt these parameters
 % (use ['property',value] format)
 % NOTE: these should be variables not used as Suite Parameters
 new_BioPar = {};
 new_SetUp = {};

 %-------------------------------------------------------
 % Define the suite of model runs
 %-------------------------------------------------------

 clear Suite;
 Suite.name = 'test';
 NameAdd = 1;  % 1 to add the parameter names to the Suite name
 Suite.base = hab;
 Suite.collapse = 1;    % Collapses the suite Output by taking average output
                        % and packaging the output into arrays with the size 
                        % of the Suite parameters (useful to save space, removes time-dependent output)
 %---------------------
 % Suite parameters
 % Specify the following:
 % params : names of parameters to be varied
 % module : module where parameters are initialized (BioPar or SetUp)
 % values : one vector of values for each parameter
 %---------------------
%Suite.params	= {'Flow'};
%Suite.module	= {'SetUp'};
 Suite.params	= {'Flow','MaxPAR'};
 Suite.module	= {'SetUp','SetUp'};

 Suite.Flow	= [0.05:0.025:1.2]/24;
 Suite.MaxPAR	= exp(linspace(0,log(1000),20))/4.6;
 %-------------------------------------------------------
 Suite.nparam = length(Suite.params);
 Suite.dims = zeros(1,Suite.nparam);
 Suite.AllParam = cell(1,Suite.nparam);
 for ip = 1:Suite.nparam
    Suite.dims(ip) = length(eval(['Suite.' Suite.params{ip}]));
    Suite.AllParam{ip} = eval(['Suite.' Suite.params{ip}]);
 end
 Suite.nruns = prod(Suite.dims);
 if length(Suite.dims)>1
    Suite.Out = cell(Suite.dims);
 else
    Suite.Out = cell(1,Suite.dims);
 end

 %-------------------------------------------------------
 % Loop through experiments
 %-------------------------------------------------------

 Tsuite = Suite.base;
 runindex = cell(Suite.nparam,1);
 for irun = 1:Suite.nruns
    disp(['Run number # ' num2str(irun) '/' num2str(Suite.nruns)]);
    [runindex{:}] = ind2sub(Suite.dims,irun);
    %---------------------
    % Here, creates the input arguments for bio module and experiment setup
    % (includes any overridden parameters in new_BioPar and new_SetUp)
    arg_BioPar = new_BioPar;
    arg_SetUp = new_SetUp;
    for ipar = 1:Suite.nparam
       disp([ Suite.params{ipar} ' - Start ........  ' num2str(Suite.AllParam{ipar}(runindex{ipar}))]);
       switch Suite.module{ipar} 
       case 'BioPar'
          arg_BioPar = [arg_BioPar Suite.params{ipar} Suite.AllParam{ipar}(runindex{ipar})]; 
       case 'SetUp'
          arg_SetUp = [arg_SetUp Suite.params{ipar} Suite.AllParam{ipar}(runindex{ipar})]; 
       otherwise
          error(['module ' Suite.module{ipar}  ' is not valid']);
       end
    end
    %---------------------
    % Initialized Biomodule with user-defined inputs
    switch Tsuite.BioModule
    case 'anderson'
       Tsuite = hab_biopar_anders(Tsuite,arg_BioPar{:});
    case 'terseleer'
       Tsuite = hab_biopar_tersel(Tsuite,arg_BioPar{:});
    case 'bec_diat'
       Tsuite = hab_biopar_bec_diat(Tsuite,arg_BioPar{:});
    otherwise
       error(['Crazy town! (biological case not found)']);
    end

    % Initialized SetUp with user-defined inputs
    switch Tsuite.ExpModule
    case 'batch'
       Tsuite = hab_setup_batch(Tsuite,arg_SetUp{:});
    case 'chemostat'
       Tsuite = hab_setup_chemo(Tsuite,arg_SetUp{:});
    case 'mixed_layer'
       Tsuite = hab_setup_mixed(Tsuite,arg_SetUp{:});
    otherwise
       error(['Crazy town! (experiment case not found)']);
    end
    %---------------------
    Suite.Out{irun} = Tsuite;
    tic;
    % Run the model
    Suite.Out{irun} = hab_integrate(Suite.Out{irun});
    % Postprocess the results
    Suite.Out{irun} = hab_postprocess(Suite.Out{irun},'dt_new',2);
    % Keeps track of runtime
    Suite.Out{irun}.runtime = toc;
 end
 %---------------------
 % Keeps track of total time, summing up individual times
 Suite.runtime = 0;
 for irun = 1:Suite.nruns
     Suite.runtime = Suite.runtime + Suite.Out{irun}.runtime;
 end;

 %-------------------------------------------------------
 % Postprocess, rename and save the suite
 %-------------------------------------------------------
 % If required, collapses Suite output
 if Suite.collapse==1
    % WARNING: this removes the "Out" field
    rmOut = 1;	% 0: keeps Out; 1: removes Out
    Suite = hab_collapse_suite(Suite,'rmOut',rmOut)
 end

 eval([snewname ' = Suite;']);
 % Rename the suite
 snewname = ['Suite_' Suite.name];
 if NameAdd ==1
    % Create a newname that includes all the parameters
    for indn=1:Suite.nparam
       snewname = [snewname '_' Suite.params{indn}];
    end
 end

 % Save the suite
 eval(['save ' snewname ' ' snewname ';']);

