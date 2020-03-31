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
                    'PON','POFe','PSi'};
 BioPar.nvar = length(BioPar.varnames);

 % Model variables: set initial values
 % Nutrients:
 BioPar.NO3_0 = 974; 		% In mmolN/m3  
 BioPar.NH4_0 = 0; 		% In mmolN/m3  
 BioPar.Si_0 = 136;  		% In mmolSi/m3  
 BioPar.PO4_0 = 16.3;  		% In mmolP/m3  
 BioPar.Fe_0 = 1;  		% In mmolFe/m3  
 % Biological pools:
 BioPar.DiN_0 = 5.5;
 BioPar.DiFe_0 = 4.3e-5;
 BioPar.DiChl_0 = 0.8;
 BioPar.DiSi_0 = 5.5;
 BioPar.DON_0 = 0.00;
 BioPar.DOFe_0 = 0.00;
 BioPar.PON_0 = 0.00;
 BioPar.POFe_0 = 0.00;
 BioPar.PSi_0 = 0.00;
 
 % For the chemostat or mixed layer case, set up input values for all tracers
 % (typically, specify nutrients and set all biological terms to 0)
 BioPar.NO3_in = 0; 		% In mmolN/m3  
 BioPar.NH4_in = 0; 		% In mmolN/m3  
 BioPar.Si_in = 0;  		% In mmolSi/m3  
 BioPar.PO4_in = 0;  		% In mmolP/m3  
 BioPar.Fe_in = 0;  		% In nmolFe/m3  
 % Biological pools:
 BioPar.DiN_in = 0;
 BioPar.DiFe_in = 0;
 BioPar.DiChl_in = 0;
 BioPar.DiSi_in = 0;
 BioPar.DON_in = 0;
 BioPar.DOFe_in = 0;
 BioPar.PON_in = 0;
 BioPar.POFe_in = 0;
 BioPar.PSi_in = 0;

 % Constants
 y2d = 365;
 d2h = 24;

 % Light attenuation by phytoplankton
 kcPAR = 0.03;   		% atten. coeff. per unit chlorophyll (1/m/(mg Chl/m^3))
 
 % Stoichiometric ratios
 BioPar.rPC = 0.00855;		% stoichiometric ratio for PN P:C (Redfield = 1/106)
 BioPar.rNC = 0.137;		% stoichiometric ratio for PN N:C (Redfield = 16/106)
 BioPar.rPN = BioPar.rPC ./ BioPar.rNC; 	% stoichiometric ratio for PN P:N
 BioPar.rSiN = 0.137 ./ BioPar.rNC; 	% baseline Si:N Diatom uptake
 BioPar.rSiNmax = 0.685 / BioPar.rNC;	% max stoichiometric ratio for PN Si:N 
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
 BioPar.lMort2Di = 0 * 0.0035/BioPar.rNC/d2h;	% 1/mmolC/m3/day
 BioPar.tAggDiMin = 0 * 0.01/d2h;			% 1/day
 BioPar.tAggDiMax = 0 * 0.75/d2h;			% 1/day
 BioPar.bGrzThres = 0.02 * BioPar.rNC;		% mmolN/m3 

 % Detritus parameters
 BioPar.fLab = 0.7;				% fraction of diat. lysis going to inorganic fraction
 BioPar.rDOM = 0.01/d2h;			% DON remineral. rate 1/d
 BioPar.rPOM = 0.05/d2h;			% DON remineral. rate 1/d

 % Fe scavenging parameters
 BioPar.rScFe0 = 1/12/(y2d*d2h);		% Baseline Fe-specific scavenging rate (1.2%/year)
 BioPar.PONRef = 2e-3 * BioPar.rNC;		% POC reference for Fe scavenging, converted to N
 BioPar.FeMaxScale = 3;				% Maximum PON scaling factor for Fe scavenging
 
 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(BioPar,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 hab.BioPar = BioPar;

