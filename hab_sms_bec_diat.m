 function sms = hab_sms_tersel(hab,Var,EnvVar)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D SMS for Anderson's model
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %------------------------------------------------
 % Preliminary processing
 nvar = hab.BioPar.nvar;        % number of model state variables
 % Create a structure with current state variables, for simplicity 
 for indv=1:nvar
   %var.(hab.BioPar.varnames{indv}) = Var(indv);
    % If a variable is negative, it will be set to zero (or to a very small number)
   %var.(hab.BioPar.varnames{indv}) = max(1e-6,Var(indv));
    var.(hab.BioPar.varnames{indv}) = max(0,Var(indv));
 end
 
 nevar = hab.SetUp.nevar;        % number of environemntal forcing variables
 % Create a structure with current environmental variables, for simplicity 
 for indv=1:nevar
    evar.(hab.SetUp.evarnames{indv}) = EnvVar(indv);
 end

 % Structure with the bioparameters, for simplicity
 bio = hab.BioPar;
 
 %------------------------------------------------
 % Start Sources and Sinks here:
 %------------------------------------------------

 %%%%%%%%%%%%%%%%%%%
 % Photosynthesis  
 % Diatom N cycle
 %%%%%%%%%%%%%%%%%%%
 % Diatoms Chl:N ratio
 QChlNDi = var.DiChl ./ var.DiN;
 % Temperature dependence term
 Tfunc = bio.Q10^((evar.Temp-10)/10);
 % Nutrient limitation terms
 denomN = (1 + var.NO3/bio.KNO3 + var.NH4/bio.KNH4 ); 
 vDiNO3 = (var.NO3/bio.KNO3) ./ denomN;
 vDiNH4 = (var.NH4/bio.KNH4) ./ denomN;
 vDiPO4 = var.PO4 / (var.PO4 + bio.KPO4);
 vDiFe = var.Fe / (var.Fe + bio.KFe);
 vDiSi = var.Si / (var.Si + bio.KSi);
 % Combined nutrient limitation
 NutLimDi = min([vDiNO3+vDiNH4, vDiPO4, vDiFe, vDiSi]);
 
 % Photosynthesis rate:
 % Differentiate culture case (constant light) from Mixed Layer case (depth-dependent light)
 switch hab.ExpModule
 case 'mixed_layer'
    % In this case PAR represents light at the surface of the ML
    % Growth need to be averaged over the mixed layer
    %-----------------------
    % 1. Estimates the light attenuation coefficient including "self-shading"
    % Note that since ML is well-mixed, the attenuation coefficient is
    % constant with depth, only PAR and PAR-dependent terms vary in the ML
    % Here uses BEC light attenuation coefficients and formulation
    kPAR = hab.SetUp.kwPAR + hab.SetUp.kcPAR * var.DiChl;
    %-----------------------
    % 2. Estimates light in the water column on a vertical grid between [0,MLD]
    zPAR = linspace(0,evar.MLD,hab.SetUp.nzPAR);
    % Since light attenuation is constant in the ML, uses the exponential solution
    PAR = evar.PAR * exp(-kPAR*zPAR);
    % 3. Calculates depth-dependent terms (photosynthetic rate and photoacclimation)
    % Note here that these variables are all depth dependent: 
    % PAR, LightFuncDi, rhoN, rhoChl, rhoPhotoAcc
    % Depth-dependent light limitation
    numerL = bio.aLightDi * QChlNDi * PAR;
    denomL = bio.muMaxDi * NutLimDi * Tfunc;
    LightFuncDi = 1 - exp(-numerL./denomL);
    % Depth-dependent photosynthetic rate
    rhoN = bio.muMaxDi * NutLimDi * Tfunc * LightFuncDi;
    % Depth-dependent rho-chl term of Geider et al., 1998
    rhoChl = bio.QNChlDi * rhoN ./ (bio.aLightDi * QChlNDi * PAR); 
    % Photoacclimation coefficient
    rhoPhotoAcc = rhoChl .* rhoN/QChlNDi;
    % 4. Averages final light-dependent terms over the Mixed Layer
    % Here uses straight average, since dz is constant
    rhoN = mean(rhoN);
    rhoPhotoAcc = mean(rhoPhotoAcc);
 otherwise
    % In this case PAR is constant, with specified value
    PAR = evar.PAR;
    numerL = bio.aLightDi * QChlNDi * evar.PAR;
    denomL = bio.muMaxDi * NutLimDi * Tfunc;
    % Light dependence of photosynthesis
    LightFuncDi = 1 - exp(-numerL/denomL);
    % Depth-dependent photosynthetic rate
    rhoN = bio.muMaxDi * NutLimDi * Tfunc * LightFuncDi;
    % Photoacclimation rho-chl term of Geider et al., 1998
    rhoChl = bio.QNChlDi * rhoN / (bio.aLightDi * QChlNDi * PAR); 
    % Photoacclimation coefficient
    rhoPhotoAcc = rhoChl * rhoN/QChlNDi;
 end

 %%%%%%%%%%%%%%%%%%%%
 % Photosynthesis &
 % Photoacclimation
 % (Diatom Chl cycle)
 %%%%%%%%%%%%%%%%%%%%
 JPhotoDi = rhoN * var.DiN;
 JPhotoAccDi = rhoPhotoAcc * var.DiChl;

 %%%%%%%%%%%%%%%
 % Diatom Losses  
 %%%%%%%%%%%%%%%
 % For losses, allows a "fraction" of phytoplankton to be preserved
 PPDiN = max(var.DiN-bio.bGrzThres,0);
 % Lysis (this is the same as diat_loss in BEC)
 JLysDi = bio.lMortDi * PPDiN;
 % Partition Lysis to three components
 JLysDiPON = 0.05 * JLysDi;
 JLysDiDON = (1 - bio.fLab) * 0.95 * JLysDi;
 JLysDiDIN = bio.fLab * 0.95 * JLysDi;
 % Aggregation
 % Takes the minimum of a quadratic and linear terms
 JAggDi = max( bio.tAggDiMin*PPDiN , min( bio.tAggDiMax*PPDiN , bio.lMort2Di*PPDiN*PPDiN ) ); 
%JAggDi = 0;
 % Grazing
 JGrzDi = 0;
 % Partition grazing to different components
 JGrzDiPON = 0.26 * JGrzDi;
 JGrzDiDON = 0.13 * JGrzDi;
 JGrzDiDIN = 0.31 * JGrzDi;

 % Diatom Silica cycle
 %%%%%%%%%%%%%%%%%%%
 % Si:N  Ratio for Diatom Si losses
 QSiNDi = min( var.DiSi/var.DiN, bio.rSiNmax);
 % Baseline uptake value
 gQSiNDi = bio.rSiN;

 % Modify Si ratios under low ambient iron conditions
 % Silicon
 if var.Fe == 0
    gQSiNDi = bio.rSiNmax;
 elseif (0 < var.Fe < 2*bio.KFe) & (var.Si > 2*bio.KSi)
    gQSiNDi = min(bio.rSiNmax , ...
                  ((bio.rSiN * 2.5 * 2 * bio.KFe/var.Fe) - bio.rSiN * (2.5 - 1)));
 else
    gQSiNDi = bio.rSiN;
 end
 % Overrides values at low Si
 if var.Si < 2*bio.KSi
    gQSiNDi = max( bio.rSiNmax, ...
                  (gQSiNDi * var.Si/(2 * bio.KSi)));
 end

 %%%%%%%%%%%%%%%%%%%
 % Diatom Iron cycle
 %%%%%%%%%%%%%%%%%%%
 % Diatom biomass Fe:N
 QFeNDi = var.DiFe / var.DiN;
 % Fe:N ratio for growth
 if (var.Fe < 2 * bio.KFe)
    gQFeNDi = max( bio.rFeNmin, ... 
                   bio.rFeN * var.Fe /(2 * bio.KFe));
 else
    gQFeNDi = bio.rFeN;
 end

 %%%%%%%%%%%%%%%%%%%%%
 % Inorganic nutrients
 %%%%%%%%%%%%%%%%%%%%%
 
 %%%%%%%%%%%%%%%%%%%
 % NO3 and NH4 cycle
 %%%%%%%%%%%%%%%%%%%
 % Split uptake between NO3 and NH4
 vDiTot = vDiNO3 + vDiNH4;
 JNO3Di = vDiNO3/vDiTot * JPhotoDi;
 JNH4Di = vDiNH4/vDiTot * JPhotoDi;
 % Production of NH4 by Diatom Lysis - equivalent to loss to DIC in BEC
 JNH4Lys =  JLysDiDIN;
 % Production of NH4 by Grazing - equivalent to loss to DIC in BEC
 JNH4Grz =  JGrzDiDIN;
 % Production of NH4 by DON - AFTER DON section
 % Production of NH4 by PON - AFTER PON section
 
 %%%%%%%%%%%%%%%%%%%
 % SiO2
 %%%%%%%%%%%%%%%%%%%
 % For grazed diatom Si, 50% is remineralized
 JSiGrz = QSiNDi * (0.5 * JGrzDi);
 % For diatom lysls 95% of Si is remineralized
 JSiLys = QSiNDi * (0.95 * JLysDi);

 %%%%%%%%%%%%%%%%%%%
 % Fe
 %%%%%%%%%%%%%%%%%%%
 % NOTE on Scavenging: here approximated from BEC -- might not be identical
 % Baseline Fe-specific scavenging rate is 12%/year = 0.12/year 
 % NOTE: instead of using a reference for POC flux, uses a reference for POC concentration
 %       assuming the numerical value is the same (which is fine e.g. by scaling 
 %       by the same velocity scale)
 % Scale th specific scavenging rate by the available PON, with a maximum scale
 % Note: only 10% of scavenged Fe goes to particles, the rest is assumed lost forever (sediments)
 rScFe = bio.rScFe0 * min( var.PON/bio.PONRef, bio.FeMaxScale);
 % Increase scaveging rate at high Fe, above 0.6nM
 % Note: converts BEC hard-coded parameters from per year to per hours
 if var.Fe > 0.6e-3
   %rScFe = rScFe + (var.Fe - 0.6e-3)/(1.4e-3) * 6.0;
    rScFe = rScFe + (var.Fe - 0.6e-3)/(1.4e-3) * 6.0/(24*365);
 end
 % Decrease scaveging rate linearly before 0.5nM
 % Note: converts BEC hard-coded parameters from per year to per hours
 if var.Fe < 0.5e-3
    rScFe = rScFe * var.Fe/(0.5e-3);
 end
 % Get the scavenging flux from the specific rate
 JScFe = rScFe * var.Fe;

 %%%%%%%%% WARNING - The following line sets scavenging to zero, if needed
%JScFe = 0;
 % Grazing sources of Fe to the dissolved pool
 % (here assumes zooplankton have always less Fe:N ratios than diatoms, 
 %  so excess grazing goes to dissolved Fe)
 JGrzDiFe = JGrzDi * (QFeNDi - bio.rFeNzoo); 
 
 %%%%%%%%%%%%%%%%%%%%%
 % DOM/POM
 %%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%
 % DON and DOFe cycles
 %%%%%%%%%%%%%%%%%%%%% 
 % DON production
 JProdDON = JLysDiDON + JGrzDiDON;
 % DON Remineralization
 JRemDON = bio.rDOM * var.DON;
 % DOFe productiom
 JProdDOFe = QFeNDi * (JLysDiDON + JGrzDiDON); 
 % DOFe remineralization
 JRemDOFe = bio.rDOM * var.DOFe;

 %%%%%%%%%%%%%%%%%%%%%%%%%
 % PON, POFe and PSi cycles
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 % PON production
 JProdPON = JLysDiPON + JAggDi + JGrzDiPON;
 % POFe production
 JProdPOFe = QFeNDi * (JLysDiPON + JAggDi + JGrzDiPON) + 0.1 * JScFe;
 % PSi production
 % For grazed diatom Si, 50% is remineralized
 JProdPSi = QSiNDi * (0.5 * JGrzDi + JAggDi + 0.05 * JLysDi);
 % PON and POFe remineralization
 % To simplify things compared to BEC, we assume here all
 % POM is labile and remineralized, rather than including a protected and
 % a labile fraction (hard and soft in BEC)
 JRemPON = bio.rPOM * var.PON;
 JRemPOFe = bio.rPOM * var.POFe;
 % PSi dissolution assumed negligible in the culture/mixed layer setups
 % (easily changed to a slow dissolution)
 JRemPSi = 0;

 %%%%%%%%%%%%%%%%%%%%%
 % NH4 cycle - part II
 %%%%%%%%%%%%%%%%%%%%%
 % Production of NH4 by DON
 JNH4DON =  JRemDON;
 % Production of NH4 by PON
 JNH4PON =  JRemPON;
 % NOTE : POP and DOP are not represented, because the assumption is Redfield
 % (this needs to be relaxed if diazotrophs are included

 %%%%%%%%%%%%%%%%%%%%%
 % DA production & loss
 %%%%%%%%%%%%%%%%%%%%%
 % Assumes DA production is proportional to phytosynthesis (N-based)
 % according to a parameter "alpha" that is a function of nutrient limitation
 % First gets the smallest of the nutrient (other than N) limitation factors, which
 % will control DA production
 NutLimDA = min([vDiPO4, vDiFe, vDiSi]);
 alpha = bio.beta * (1 - min(NutLimDA/(vDiNO3+vDiNH4),1))^bio.gamma;  
 DiDAprod = alpha * JPhotoDi;
 % Losses: partition all Diatom losses accroding to the diatom DA:N ratios
 % First get the DA:N ratio in livign diatoms:
 QDADiN = var.DiDA/var.DiN;
 DiDAloss = QDADiN * (JLysDi + JAggDi + JGrzDi);
 % Sources fro particulate and dissolved DA
 % Adds together lysis, aggregation, grazing terms, partioning to dissolved and particulate:
 PDAprod = QDADiN * (JLysDiPON + JAggDi + JGrzDiPON); 
 DDAprod = QDADiN * (JLysDiDON + JLysDiDIN + JGrzDiDON + JGrzDiDIN);
 % Losses by remineralization 
 PDAloss = bio.rPOM * var.PDA;
 DDAloss = bio.rDOM * var.DDA;

 %-----------------------------------------------------------
 % Final source and sink terms
 % 'NO3','NH4','Si','PO4','Fe','DiN','DiFe','DiChl','DiSi', ...
 % 'DON','DOFe','PON','POFe','PSi','DiDA','DDA','PDA'
 % Dissolved Inorganic Nutrients
 dNO3dt = - JNO3Di;
 dNH4dt = - JNH4Di + JNH4Lys + JNH4Grz + JNH4DON + JNH4PON;
 dPO4dt = bio.rPN * (- JPhotoDi + JNH4DON + JRemPON + JNH4Lys + JNH4Grz);
 dSidt = - gQSiNDi * JPhotoDi + JSiGrz + JSiLys + JRemPSi;  
 dFedt = - gQFeNDi * JPhotoDi + JRemDOFe + JRemPOFe + QFeNDi * (JNH4Lys + JNH4Grz) + JGrzDiFe - JScFe;
 % Diatoms
 dDiNdt = JPhotoDi - (JGrzDi + JLysDi + JAggDi);
 dDiFedt = gQFeNDi * JPhotoDi - QFeNDi * (JGrzDi + JLysDi + JAggDi);
 dDiChldt = JPhotoAccDi - QChlNDi * (JGrzDi + JLysDi + JAggDi);
 dDiSidt = gQSiNDi * JPhotoDi - QSiNDi * (JGrzDi + JLysDi + JAggDi);
 % Dissolved Matter
 dDONdt = JProdDON - JRemDON;
 dDOFedt = JProdDOFe - JRemDOFe;
 % Particulate Matter
 dPONdt = JProdPON - JRemPON;
 dPOFedt = JProdPOFe - JRemPOFe;
 dPSidt = JProdPSi - JRemPSi;
 % DA production
 dDiDAdt = DiDAprod - DiDAloss;
 dDDAdt  = DDAprod  - DDAloss;
 dPDAdt  = PDAprod  - PDAloss;
 %-----------------------------------------------------------
 % Lumps SMS terms into a single vector
 sms = [dNO3dt; ...
        dNH4dt; ...
        dSidt; ...
        dPO4dt; ...
        dFedt; ...
        dDiNdt; ...
        dDiFedt; ...
        dDiChldt; ...
        dDiSidt; ...
        dDONdt; ...
        dDOFedt; ...
        dPONdt; ...
        dPOFedt; ...
        dPSidt; ...
        dDiDAdt;...
        dDDAdt;...
        dPDAdt;...
        ];

