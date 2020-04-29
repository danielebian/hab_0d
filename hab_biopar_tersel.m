 function hab = hab_biopar_tersel(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of biologial parameters
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Model variables
 BioPar.varnames = {'PNF','PNS','PNR','pDA','dDA','NO3','Si','PO4'};
 BioPar.nvar = length(BioPar.varnames);

% Model variables: set initial values
 BioPar.PNF_0 = 27.5;		% In mmolC/m3  
 BioPar.PNS_0 = 27.5*0.57;	% In mmolC/m3  
 BioPar.PNR_0 = 27.5*0.75; 	% In mmolC/m3  
 BioPar.pDA_0 = 0.009;		% In mmolC/m3  
 BioPar.dDA_0 = 0;  		% In mmolC/m3  
 BioPar.NO3_0 = 974; 		% In mmolN/m3  
 BioPar.Si_0 = 136;  		% In mmolSi/m3  
 BioPar.PO4_0 = 16.3;  		% In mmolP/m3  
%BioPar.NO3_0 = 16;  		% In mmolN/m3  
%BioPar.Si_0 = 16;  		% In mmolSi/m3  
%BioPar.PO4_0 = 1;  		% In mmolP/m3  

 % For the chemostat or mixed layer case, set up input values for all tracers
 % (typically, specify nutrients and set all biological terms to 0)
 BioPar.PNF_in = 0;		% In mmolC/m3  
 BioPar.PNS_in = 0;  		% In mmolC/m3  
 BioPar.PNR_in = 0;  		% In mmolC/m3  
 BioPar.pDA_in = 0;		% In mmolC/m3  
 BioPar.dDA_in = 0;  		% In mmolC/m3  
 BioPar.NO3_in = 29.8041; 		% In mmolN/m3  
 BioPar.Si_in = 36.7160;  		% In mmolSi/m3  
 BioPar.PO4_in = 2.2956;  		% In mmolP/m3  

 % Constants
 BioPar.alpha = 0.001;		% Photosynt. efficiency [1/h * 1/(umol/m2/s)]

 % Rate constants - units should be in hours
 BioPar.kmax = 0.12;		% max photosynthetic rate (1/h)
 BioPar.mumax = 0.05;		% max PNF (structure) synthesis rate (1/h)
 BioPar.klys = 0.0016;		% min autolysis rate (1/h)
 BioPar.kexc = 0.001;		% constant excretion rate (1/h)
 BioPar.maint = 0.0004;		% constant cell maintenance rate (1/h)
 BioPar.sPNRmax = 0.1;		% max PNR (reserve) synthesis rate (1/h)
 BioPar.kPNRcat = 0.06;		% PNR (reserve) catabolism rate (1/h)
 BioPar.kDA = 0.0002;		% DA production rate (1/h)

 % Half saturation constants
 BioPar.kass = 0.06;		% half saturation constant for PNS assimilation (1/h)
 BioPar.KNO3 = 0.5; 		% half sat. constant for NO3 uptake (mmol/m3)
 BioPar.KPO4 = 0.03; 		% half sat. constant for PO4 uptake (mmol/m3)
 BioPar.KSi = 0.6;	        % half sat. constant for Si(OH)4 uptake (mmol/m3)
 
 % Stoichiometric ratios
 BioPar.ePNFcost = 0.8;		% energy cost of PNF synthesis (molC:molC)
 BioPar.rNC = 0.20;         % stoichiometric ratio for PN N:C (Redfield = 16/106)
 BioPar.rSiC = 0.20;		% stoichiometric ratio for PN Si:C (Redfield = 16/106)
 BioPar.rPC = 0.015;		% stoichiometric ratio for PN P:C (Redfield = 1/106)
 BioPar.rNCDA = 1/15;		% stoichiometric ratio for DA N:C 

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 BioPar = parse_pv_pairs(BioPar,varargin);
 %--------------------------------------------------------------------------------

 % Adds in the biological parameters in the main structure
 hab.BioPar = BioPar;

