% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript 
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some documentation will follow:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath ./functions

 % Initialize the model
 clear hab;
 %close all;
 
 % Biological module
 % Options:
 % 'anderson' : Clarissa Anderson simple PN/DA model
 % 'terseleer' : Terseleer Based on 2013 Paper
 %hab.BioModule = 'anderson';
  hab.BioModule = 'terseleer';
 %hab.BioModule = 'bec_diat';

 % Experimental setup
 % Options:
 % 'batch' : models a batch culture
 % 'chemostat' : models a chemostat setup
 % 'mixed_layer' : models a mixed layer setup
  hab.ExpModule = 'batch';
 %hab.ExpModule = 'chemostat';
 %hab.ExpModule = 'mixed_layer';

 % Here, if needed, overrides default parameters for BioModules and SetUp
 % The experiment will adopt these parameters, overriding defaults
 % (use ['property',value] format)
 % (leave an empty cell array {} for default)
 new_BioPar = {};
 % new_BioPar = {'NO3_0',16,'Si_0',16,'PO4_0',1};
 new_SetUp = {'dt',0.05};

 %---------------------
 % Here, creates the input arguments for bio module and experiment setup
 % (includes any overridden parameters in new_BioPar and new_SetUp)
 %---------------------
 % Gets parameter values from Optimization
 ParNames = Optim.ParNames;
 ParModule = Optim.ParModule;
 ParOpt = Optim.ParOpt;
 nparam = length(ParNames);
 %---------------------
 arg_BioPar = new_BioPar;
 arg_SetUp = new_SetUp;
 for indp=1:nparam
    switch ParModule{indp}
    case 'BioPar'
       arg_BioPar = [arg_BioPar ParNames(indp) ParOpt(indp)];
    case 'SetUp'
       arg_SetUp = [arg_SetUp ParNames(indp) ParOpt(indp)];
    otherwise
       error(['module ' Suite.module{ipar}  ' is not valid']);
    end
 end
 %---------------------

 % Initialize biological parameters
 switch hab.BioModule
 case 'anderson'
    hab = hab_biopar_anders(hab,arg_BioPar{:});
 case 'terseleer'
    hab = hab_biopar_tersel(hab,arg_BioPar{:});
 case 'bec_diat'
    hab = hab_biopar_bec_diat(hab,new_BioPar{:});
 otherwise
    error(['Crazy town! (biological case not found)']);
 end

 % Setup experiment type (e.g. batch, chemostat, etc.)
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

 % Run the model
 hab = hab_integrate(hab);

 % Some postprocessing
 hab = hab_postprocess(hab);

 % Plotting
 iplot = 0;
 if (iplot)
    switch hab.BioModule
    case 'anderson'
       hab_plot_anders(hab); %Plot model
    case 'terseleer'
       hab_plot_tersel(hab); %Plot model
    case 'bec_diat'
       hab_plot_all(hab); %Plot model
    otherwise
       error(['Crazy town! (Processing not found)']);
    end
 end
 
