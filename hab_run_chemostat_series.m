% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript 
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some documentation will follow:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath ./functions

 % Sets the data file and folder:
 data_dir = '/Users/danielebianchi/AOS1/HAB/code/hab_0d_master/';
 data_file = 'chemostat_data_kudela_v0.xlsx';

 % Number of experiments to run
 nruns = 3;

 % Initialize the model
 clear Series;
 %close all;
 
 % Sets the number of chemostat experiments to be run:
 Series.nruns = nruns;

 % Biological module
 % Options:
 % 'anderson' : Clarissa Anderson simple PN/DA model
 % 'terseleer' : Terseleer Based on 2013 Paper
 %Series.BioModule = 'anderson';
 %Series.BioModule = 'terseleer';
  Series.BioModule = 'bec_diat';

 % Experimental setup
 % Options:
 % 'chemostat' : models a chemostat setup
  Series.ExpModule = 'chemostat';

 %-------------------------------------------------------
 % Read the chemostat data for all experiments to be run
 disp(['Loading input table : ' data_file ]);
 tmp = readcell([data_dir data_file]);

 % Assumptions on input table setup:
 % code		dilution	PO4_in		...
 % units	1/day		mmol/m3		...
 % exp1		dil_rate1	po4_in1		...
 % ...		...		...		...
 % Note: set NaN values as -999 in input table
 var_names = tmp(1,2:end);
 var_units = tmp(2,2:end);
 exp_names = tmp(3:2+nruns,1)';
 var_values = cell2mat(tmp(3:2+nruns,2:end));
 % Override -999 values with NaNs
 var_values(var_values==-999) = nan;

 % Initialize structure of experiments
 Series.var_names = var_names;
 Series.var_units = var_units;
 Series.exp_names = exp_names;
 Series.var_values = var_values;
 Series.Out = cell(1,nruns);

 %-------------------------------------------------------
 % Run all experiments
 %-------------------------------------------------------
 % Here, if needed, overrides default parameters for BioModules and SetUp
 % All Suite experiments will adopt these parameters
 % (use ['property',value] format)
 % NOTE: these should be variables not used as Series Parameters
 new_BioPar = {};
 new_SetUp = {'EndTime',100*24};
 %-------------------------------------------------------

 %-------------------------------------------------------
 % Loop through all experiments
 for indr=1:nruns

    % Initialize each run
    hab.BioModule = Series.BioModule;
    hab.ExpModule = Series.ExpModule;

    %-------------------------------------------------------
    % Initialize experiment-specific parameters
    %-------------------------------------------------------
    % Overrides dilution rates
    % These are added to any common set of SetUp parameters: 
    % First finds the index corresponding to the dilution rate
    indv0 = find(strcmp(var_names,'dilution'));
    % NOTE: dilution rate in input table is assumed to be in 1/day
    %       here it is converted to 1/hours
    disp(['WARNING: converting input dilution rate from 1/day to 1/hour']);
    new_SetUp = [new_SetUp 'Flow' var_values(indr,indv0)/24];
    
    % Overrides medium concentrations (input nutrients) 
    % These are added to any common set of BioPar parameters: 
    % First finds the indeces corresponding to the nutrient inputs
    indv1 = find(strcmp(var_names,'PO4_in'));
    indv2 = find(strcmp(var_names,'NO3_in'));
    indv3 = find(strcmp(var_names,'Si_in'));
    new_BioPar = [new_BioPar 'PO4_in' var_values(indr,indv1) ...
                             'NO3_in' var_values(indr,indv2) ... 
                             'Si_in'  var_values(indr,indv3)];

    %-------------------------------------------------------
    % Initialize biological parameters
    switch hab.BioModule
    case 'anderson'
       hab = hab_biopar_anders(hab,new_BioPar{:});
    case 'terseleer'
       hab = hab_biopar_tersel(hab,new_BioPar{:});
    case 'bec_diat'
       hab = hab_biopar_bec_diat(hab,new_BioPar{:});
    otherwise
       error(['Crazy town! (biological case not found)']);
    end
   
    % Setup experiment type (e.g. batch, chemostat, etc.)
    switch hab.ExpModule
    case 'chemostat'
       hab = hab_setup_chemo(hab,new_SetUp{:});
    otherwise
       error(['Crazy town! (experiment case not valid)']);
    end
    %-------------------------------------------------------

    tic;
    % Run the model
    disp(['Running chemostat experiment #' num2str(indr) '/' num2str(nruns)]);
    hab = hab_integrate(hab);
    % Some postprocessing
    % Averages timestep to 1 hour
    hab = hab_postprocess(hab,'dt_new',1);
    % "Collapses" output by taking the last timestep
    hab = hab_collapse(hab,'time_start',nan,'time_end',nan);
    hab.runtime = toc;
    % Stores output in structure array
    Series.Out{indr} = hab;
 end

 % Some postprocessing:
 % (1) Puts input variables into "VarAll" structure 
 for indv=1:length(var_names)
    Series.VarAll.(var_names{indv}) = var_values(:,indv)'; 
 end
 % (2) Collapses output to last time step of model run
 % Note: set 'rmOut' to 1 to remove individual time-dependent outputs "Out"
 %       otherwise they will be kept alongside collapsed ouptu "OutAll"
 Series = hab_collapse_suite(Series,'rmOut',0);

