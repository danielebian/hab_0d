 function hab = hab_biopar_bec_full(hab,varargin)
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
                    'DiDA','DDA','PDA','ZN',...
                    'SpN','SpFe','SpChl'};
 BioPar.nvar = length(BioPar.varnames);

 % Initialize biogeochemical variables (initial and boundary conditions)
 BioPar = hab_initialize_bec_full(BioPar,hab.ExpModule);

 % Constants
 y2d = 365;
 d2h = 24;
 
 % Parameters for physical coupling
 % Light attenuation by phytoplankton
 BioPar.kcPAR = 0.03;   	% atten. coeff. per unit chlorophyll (1/m/(mg Chl/m^3))

 % Macronutrient recycling term (0: no recycling, 1: recycling)
 BioPar.iRcy = 1;

 % Sinking velocity per POM (for mixed layer case only)
 BioPar.iwsPOM = 1;        	% add 0 to test conservation of mass
 BioPar.wsPOM = 25/24;		% sinking velocity in m/h (typically 25 m/d)
 
 % Stoichiometric ratios
 BioPar.rPC = 0.00855;      			% stoichiometric ratio for PN P:C (Redfield = 1/106)
 BioPar.rNC = 0.137;				% stoichiometric ratio for PN N:C (Redfield = 16/106)
 BioPar.rPN = BioPar.rPC ./ BioPar.rNC; 	% stoichiometric ratio for PN P:N
 BioPar.rSiN = 0.137 ./ BioPar.rNC; 		% baseline Si:N Diatom uptake
 BioPar.rSiNmax = 0.685 / BioPar.rNC;		% max stoichiometric ratio for PN Si:N 
 BioPar.rSiNmin = 0.0685 / BioPar.rNC;		% min stoichiometric ratio for PN Si:N 
 BioPar.rFeNDi = 6*1e-6 / BioPar.rNC;		% baseline stoichiometric ratio for PN Fe:N 
 BioPar.rFeNminDi = 2.5*1e-6 / BioPar.rNC;	% Minimum stoichiometric ratio for PN Fe:N 
 BioPar.rFeNSp = 6*1e-6 / BioPar.rNC;		% baseline stoichiometric ratio for Sp Fe:N 
 BioPar.rFeNminSp = 2.5*1e-6 / BioPar.rNC;	% Minimum stoichiometric ratio for Sp Fe:N 
 BioPar.rFeNZ = 2.5*1e-6 / BioPar.rNC;		% Zooplankton stoichiometric ratio for Z Fe:N 

 % Rate constants - units should be in hours
 BioPar.iSp = 1;
 BioPar.iDi = 1;
 BioPar.muMaxDi = (BioPar.iDi*0.75)/d2h;		% 1/day Max diatmos C specific growth rate at Tref=10C
 BioPar.muMaxSp = (BioPar.iSp*0.75)/d2h;		% 1/day Max small phyto. C specific growth rate at Tref=10C
 BioPar.Q10 = 2;			% T-dependence of growth rates

 % Half saturation constants
 BioPar.KNO3Di = 2.5;		% half sat constant for nut uptake mmol/m3
 BioPar.KNH4Di = 0.1;		% half sat constant for nut uptake mmol/m3
 BioPar.KPO4Di = 0.1;		% half sat constant for nut uptake mmol/m3
 BioPar.KFeDi = 0.08 * 1e-3;	% half sat constant for nut uptake mmol/m3
 BioPar.KSiDi = 1.0;		% half sat constant for nut uptake mmol/m3
 
 BioPar.KNO3Sp = 0.5;		% half sat constant for nut uptake mmol/m3
 BioPar.KNH4Sp = 0.01;		% half sat constant for nut uptake mmol/m3
 BioPar.KPO4Sp = 0.01;		% half sat constant for nut uptake mmol/m3
 BioPar.KFeSp = 0.035 * 1e-3;	% half sat constant for nut uptake mmol/m3


 % Light dependence
 BioPar.aLightDi = 0.3 * BioPar.rNC/d2h;	% mmol N /(mg Chl W/m2 day)
 BioPar.aLightSp = 0.3 * BioPar.rNC/d2h;	% mmol N /(mg Chl W/m2 day)
 
 % Photoacclimation parameters
 BioPar.QNChlDi = 4;			% mgChl/mmolN
 BioPar.QNChlSp = 2.5;			% mgChl/mmolN
 
 % Zooplankton parameters 
 BioPar.iZoo = 1;
 BioPar.bGrzZ=1.05*BioPar.rNC*BioPar.iZoo;              % Grazing coefficient, used in density dependent grazing modification mmol C/m 3 
 BioPar.lMortZ=0.08/d2h;                		% Zooplankton linear mortality  1/d
 BioPar.lMort2Z=0.42/BioPar.rNC/d2h;  			% Zooplankton quadratic mortality  1/(mmol C m 3 d) 
 BioPar.bThres0Z=0.03*BioPar.rNC;        		% Zooplankton threshold concentrations for mortality mmol C/m 3
 
 BioPar.bGrzThresDi=0.02*BioPar.rNC*BioPar.iZoo;      	% Diatom threshold concentration for grazing mmol C/m 3 
 BioPar.bGrzThresSp=0.001*BioPar.rNC*BioPar.iZoo;      	% Small Phyto threshold concentration for grazing mmol C/m 3 
 BioPar.aGrzDi=0.3*BioPar.iZoo;                   	% Fraction of diatom grazing going to zooplankton no units 
 BioPar.aGrzSp=0.3*BioPar.iZoo;                   	% Fraction of Small Phyto grazing going to zooplankton no units 
 BioPar.JgmaxDi=(1.95*BioPar.iZoo)/d2h;                 % Maximum grazing loss for PN 1/d
 BioPar.JgmaxSp=(1.95*BioPar.iZoo)/d2h;                 % Maximum grazing loss for Sp 1/d
 
 % Partition grazing to different components
 BioPar.JGrzDiPON = 0.26; 				%Default fraction of PN grazing going to PON
 BioPar.JGrzDiDON = 0.13; 				%Fraction of PN grazing going to DON
 BioPar.JGrzDiDIN = 0.31; 				%Fraction of PN grazing going to DIN
 BioPar.JGrzSpPON = 0.22; 				%Default fraction of Sp grazing going to PON
 BioPar.JGrzSpDON = 0.34; 				%Fraction of Sp grazing going to DON
 BioPar.JGrzSpDIN = 0.36; 				%Fraction of small phytop. grazing going to DIN

 % Losses parameters
 BioPar.lMortDi = 0.15/d2h;			% 1/day
 BioPar.lMortSp = 0.15/d2h;			% 1/day
 BioPar.lMort2Di = 1 * 0.0035/BioPar.rNC/d2h;	% 1/mmolC/m3/day
 BioPar.lMort2Sp = 1 * 0.0035/BioPar.rNC/d2h;	% 1/mmolC/m3/day
 BioPar.tAggDiMin = 1 * 0.01/d2h;		% 1/day
 BioPar.tAggDiMax = 1 * 0.75/d2h;		% 1/day
 BioPar.tAggSpMax = 1 * 0.75/d2h;		% 1/day
 BioPar.bGrzThres = 0.02 * BioPar.rNC;		% mmolN/m3 
 BioPar.aPOCDi = 0.05; 				%Fraction of diatom loss going to POC no units
 
 BioPar.QCaCSpMax = 0.4; 			%Maximum calcification to C photosynthesis ratio mmolCaCO 3 /mmol C  ----> !!!!!!!!!
 
 % Detritus parameters
 BioPar.fLab = 0.7;				% fraction of diat. lysis going to inorganic fraction
 BioPar.rDOM = 0.01/d2h;			% DON remineral. rate 1/d
 BioPar.rPOM = 0.05/d2h;			% DON remineral. rate 1/d

 % Fe scavenging parameters
 BioPar.rScFe0 = 0.12/(y2d*d2h);		% Baseline Fe-specific scavenging rate (12%/year = 12%/(24*365h))
 BioPar.PONRef = 2e-3 * BioPar.rNC;		% POC reference for Fe scavenging, converted to N
 BioPar.FeMaxScale = 3;				% Maximum PON scaling factor for Fe scavenging

 % Domoic Acid cycle parameters
 BioPar.beta = 0.1*BioPar.rNC;			% Max DA production stoichiomery (DA:N ratio for photo) 
 BioPar.gamma = 2.0;				% Exponent for DA production (in nutrient limitation term)
 
 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(BioPar,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 hab.BioPar = BioPar;

