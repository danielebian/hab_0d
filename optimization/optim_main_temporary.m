% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript 
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some documentation will follow:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath /Users/danielebianchi/AOS1/HAB/code/hab_0d_200116/
 addpath /Users/danielebianchi/AOS1/HAB/code/hab_0d_200116/functions

 %----------------------------------------------------------------------------
 % Folder with temporary output
 optim_root = '/Users/danielebianchi/AOS1/HAB/code/hab_0d_200116/optimOut/';
 optim_name = 'cmaes_out_08_Feb_2020_23_19_32_Optimization_Test_initial_concentr';

 % Reads temporary file and loads and substitutes values
 % Needs to know the names of variables since they are not saved yet
 AllParam = {
                'alpha',        'BioPar',       0.012/2,        0.012*2;        ...
                'kmax',         'BioPar',       0.12/2,         0.12*2;         ...
                'mumax',        'BioPar',       0.05/2,         0.05*2;         ...
                'klys',         'BioPar',       0.0016/2,       0.0016*2;       ...
                'kexc',         'BioPar',       0.001/2,        0.001*2;        ...
                'maint',        'BioPar',       0.0004/2,       0.0004*2;       ...
                'sPNRmax',      'BioPar',       0.1/2,          0.1*2;          ...
                'kPNRcat',      'BioPar',       0.06/2,         0.06*2;         ...
                'kDA',          'BioPar',       0.0002/2,       0.0002*2;       ...
                'kass',         'BioPar',       0.06/2,         0.06*2;         ...
                'KNO3',         'BioPar',       0.5/2,          0.5*2;          ...
                'KPO4',         'BioPar',       0.3/2,          0.03*2;         ...
                'KSi',          'BioPar',       0.6/2,          0.6*2;          ...
                'ePNFcost',     'BioPar',       0.8/2,          0.8*2;          ...
                'rNC',          'BioPar',       0.2/2,          0.2*2;          ...
                'rSiC',         'BioPar',       0.2/2,          0.2*2;          ...
                'rPC',          'BioPar',       0.015/2,        0.015*2;        ...
                'rNCDA',        'BioPar',       0.07/2,         0.07*2;         ...
%               'NO3_0',        'BioPar',       0,              2000;           ...
%               'Si_0',         'BioPar',       0,              2000;           ...
%               'PO4_0',        'BioPar',       0,              125;            ...
                };

 ParNames = AllParam(:,1);
 ParModule = AllParam(:,2);
 nPar = size(ParNames,1); % number of parameters
 ParMin = [AllParam{:,3}]';
 ParMax = [AllParam{:,4}]';
 ParRange = ParMax - ParMin;
 ParNorm = ParRange;

 % loads temporary normalized optimal values
 d.x = load([optim_root optim_name '/outcmaesxrecentbest.dat']);
 d.f = load([optim_root optim_name '/outcmaesfit.dat']);
 dfit = d.f(:,6)-min(d.f(:,6));
 [ignore idxbest] = min(dfit);
 NormParamVal = d.x(idxbest,6:end);
 
 % Recreate best values by re-scaling
  ParVal = ParMin + NormParamVal(:) .* ParNorm;

 %----------------------------------------------------------------------------
 % Initialize the model
 clear hab;
 %close all;
 
 % Biological module
 % Options:
 % 'anderson' : Clarissa Anderson simple PN/DA model
 % 'terseleer' : Terseleer Based on 2013 Paper
 %hab.BioModule = 'anderson';
  hab.BioModule = 'terseleer';

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
 arg_BioPar = new_BioPar;
 arg_SetUp = new_SetUp;
 for indp=1:nPar
    switch ParModule{indp}
    case 'BioPar'
       arg_BioPar = [arg_BioPar ParNames(indp) ParVal(indp)];
    case 'SetUp'
       arg_SetUp = [arg_SetUp ParNames(indp) ParVal(indp)];
    otherwise
       error(['module ' Suite.module{ipar}  ' is not valid']);
    end
 end

 % Initialize biological parameters
 switch hab.BioModule
 case 'anderson'
    hab = hab_biopar_anders(hab,arg_BioPar{:});
 case 'terseleer'
    hab = hab_biopar_tersel(hab,arg_BioPar{:});
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

 
 

