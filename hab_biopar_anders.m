 function hab = hab_biopar_anders(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of biologial parameters
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Model variables
 BioPar.varnames = {'NO3','Si','PN','pDA','dDA'};
 BioPar.nvar = length(BioPar.varnames);

 % Initialize biogeochemical variables (initial and boundary conditions)
 BioPar = hab_initialize_anders(BioPar,hab.ExpModule);

 % Constants
 BioPar.beta = 0.1; 		% non-dimensional
 BioPar.gamma = 2.0; 		% non-dimensional

 % Rate constants - units should be in hours
 BioPar.muGrw = 1.248/24; 	% max growth rate (1/hour)
 BioPar.muLys = 0.0624/24; 	% lysis and excretion rate (1/hour)
 BioPar.muExDA = 0.24/24; 	% DA excretion rate (1/hour)

 % Half saturation constants
 BioPar.KNO3 = 0.5; 		% Half sat. constant for NO3 uptake (mmol/m3)
 BioPar.KPO4 = 0.03; 		% Half sat. constant for PO4 uptake (mmol/m3)
 BioPar.KSi = 0.43; 		% Half sat. constant for Si(OH)4 uptake (mmol/m3)
 
 % Stoichiometric ratios
 BioPar.rNC = 16/106;		% Stoichiometric ratio for PN N:C 
 BioPar.rSiC = 16/106;		% Stoichiometric ratio for PN Si:C 
 BioPar.rPC = 1/106;		% Stoichiometric ratio for PN P:C 

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(BioPar,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 hab.BioPar = BioPar;

