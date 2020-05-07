 function hab = hab_biopar_tersel(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of biologial parameters
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Model variables
 BioPar.varnames = {'NO3','NH4','Si','PO4','Fe', ...
                    'DiN','DiFe','DiChl','DiSi', ... 
                    'DON','DOFe', ...
                    'PON','POFe','PSi', ...
                    'DiDA','DDA','PDA'};
 BioPar.nvar = length(BioPar.varnames);

 % Initialize biogeochemical variables (initial and boundary conditions)
 BioPar = hab_initialize_bec_diat(BioPar,hab.ExpModule);

 % Constants
 y2d = 365;
 d2h = 24;
 
 % Parameters for physical coupling
 % Light attenuation by phytoplankton
 BioPar.kcPAR = 0.03;   	% atten. coeff. per unit chlorophyll (1/m/(mg Chl/m^3))

 % Macronutrient recycling term (0: no recycling, 1: recycling)
 BioPar.iRcy = 1;

 % Sinking velocity per POM (for mixed layer case only)
 BioPar.wsPOM = 25/24;		% sinking velocity in m/h (typically 25 m/d)
 
 % Stoichiometric ratios
 BioPar.rPC = 0.00855;		% stoichiometric ratio for PN P:C (Redfield = 1/106)
 BioPar.rNC = 0.137;		% stoichiometric ratio for PN N:C (Redfield = 16/106)
 BioPar.rPN = BioPar.rPC ./ BioPar.rNC; 	% stoichiometric ratio for PN P:N
 BioPar.rSiN = 0.137 ./ BioPar.rNC; 	% baseline Si:N Diatom uptake
 BioPar.rSiNmax = 0.685 / BioPar.rNC;	% max stoichiometric ratio for PN Si:N 
 BioPar.rSiNmin = 0.0685 / BioPar.rNC;	% min stoichiometric ratio for PN Si:N 
 BioPar.rFeN = 6*1e-6 / BioPar.rNC;	% baseline stoichiometric ratio for PN Fe:N 
 BioPar.rFeNmin = 2.5*1e-6 / BioPar.rNC;	% Minimum stoichiometric ratio for PN Fe:N 
 BioPar.rFeNzoo = 2.5*1e-6 / BioPar.rNC;	% Zooplankton stoichiometric ratio for PN Fe:N 

 % Rate constants - units should be in hours
 BioPar.muMaxDi = 0.75/d2h;		% 1/day Max phyto C specific growth rate at Tref=10C
 BioPar.Q10 = 2;			% T-dependence of growth rates

 % Half saturation constants
 BioPar.KNO3 = 2.5;		% half sat constant for nut uptake mmol/m3
 BioPar.KNH4 = 0.1;		% half sat constant for nut uptake mmol/m3
 BioPar.KPO4 = 0.1;		% half sat constant for nut uptake mmol/m3
 BioPar.KFe = 0.08 * 1e-3;	% half sat constant for nut uptake mmol/m3
 BioPar.KSi = 1.0;		% half sat constant for nut uptake mmol/m3

 % Light dependence
 BioPar.aLightDi = 0.3 * BioPar.rNC/d2h;	% mmol N /(mg Chl W/m2 day)
 
 % Photoacclimation parameters
 BioPar.QNChlDi = 4;			% mgChl/mmolN

 % Losses parameters
 BioPar.lMortDi = 0.15/d2h;			% 1/day
 BioPar.lMort2Di = 1 * 0.0035/BioPar.rNC/d2h;	% 1/mmolC/m3/day
 BioPar.tAggDiMin = 1 * 0.01/d2h;		% 1/day
 BioPar.tAggDiMax = 1 * 0.75/d2h;		% 1/day
 BioPar.bGrzThres = 0.02 * BioPar.rNC;		% mmolN/m3 
 
 % Detritus parameters
 BioPar.fLab = 0.7;				% fraction of diat. lysis going to inorganic fraction
 BioPar.rDOM = 0.01/d2h;			% DON remineral. rate 1/d
 BioPar.rPOM = 0.05/d2h;			% DON remineral. rate 1/d

 % Fe scavenging parameters
 BioPar.rScFe0 = 0.12/(y2d*d2h);		% Baseline Fe-specific scavenging rate (12%/year = 12%/(24*365h))
 BioPar.PONRef = 2e-3 * BioPar.rNC;		% POC reference for Fe scavenging, converted to N
 BioPar.FeMaxScale = 3;				% Maximum PON scaling factor for Fe scavenging

 % Domoic Acid cycle parameters
 BioPar.beta = 0.1*BioPar.rNC;	% Max DA production stoichiomery (DA:N ratio for photo) 
 BioPar.gamma = 2.0;		% Exponent for DA production (in nutrient limitation term)
 
 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(BioPar,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 hab.BioPar = BioPar;

