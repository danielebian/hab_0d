 function sms = hab_sms_bec_full(hab,Var,EnvVar)
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
 varnames=hab.BioPar.varnames;
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

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Photosynthesis  
 % Diatom & Small Phyto. N cycle
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Diatoms Chl:N ratio
 QChlNDi = var.DiChl ./ var.DiN;
 % Small Phyto. Chl:N ratio
 QChlNSp = var.SpChl ./ var.SpN;
 % Temperature dependence term
 Tfunc = bio.Q10^((evar.Temp-10)/10);
 % Nutrient limitation terms
 denomN = (1 + var.NO3/bio.KNO3Di + var.NH4/bio.KNH4Di ); 
 vDiNO3 = (var.NO3/bio.KNO3Di) ./ denomN;
 vDiNH4 = (var.NH4/bio.KNH4Di) ./ denomN;
 vDiPO4 = var.PO4 ./ (var.PO4 + bio.KPO4Di);
 vDiFe = var.Fe ./ (var.Fe + bio.KFeDi);
 vDiSi = var.Si ./ (var.Si + bio.KSiDi);
 
 vSpNO3 = (var.NO3/bio.KNO3Sp) ./ denomN;
 vSpNH4 = (var.NH4/bio.KNH4Sp) ./ denomN;
 vSpPO4 = var.PO4 ./ (var.PO4 + bio.KPO4Sp);
 vSpFe = var.Fe ./ (var.Fe + bio.KFeSp);
 
 % Combined nutrient limitation
 NutLimDi = min([vDiNO3+vDiNH4, vDiPO4, vDiFe, vDiSi]);
 NutLimSp = min([vSpNO3+vSpNH4, vSpPO4, vSpFe]);
 
 % Photosynthesis rate:
 % Differentiate culture case (constant light) from Mixed Layer case (depth-dependent light)
 switch hab.ExpModule
 case {'mixed_layer','mixed_layer_3D'}
    % In this case PAR represents light at the surface of the ML
    % Growth need to be averaged over the mixed layer
    %-----------------------
    % 1. Estimates the light attenuation coefficient including "self-shading"
    % Note that since ML is well-mixed, the attenuation coefficient is
    % constant with depth, only PAR and PAR-dependent terms vary in the ML
    % Here uses BEC light attenuation coefficients and formulation
    kPAR = hab.SetUp.kwPAR + bio.kcPAR * (var.DiChl + var.SpChl);
   
    %-----------------------
    % 2. Estimates light in the water column on a vertical grid between [0,MLD]
    zPAR = linspace(0,evar.MLD,hab.SetUp.nzPAR);
    % Since light attenuation is constant in the ML, uses the exponential solution
    PAR = evar.PAR * exp(-kPAR*zPAR);
    
    % 3. Calculates depth-dependent terms (photosynthetic rate and photoacclimation)
    % Note here that these variables are all depth dependent: 
    % PAR, LightFuncDi, rhoN, rhoChl, rhoPhotoAcc
    % Depth-dependent light limitation
    numerLDi = bio.aLightDi * QChlNDi * PAR;
    numerLSp = bio.aLightSp * QChlNSp * PAR;
    denomLDi = bio.muMaxDi * NutLimDi * Tfunc;
    denomLSp = bio.muMaxSp * NutLimSp * Tfunc;
    LightFuncDi = 1 - exp(-numerLDi./denomLDi);
    LightFuncSp = 1 - exp(-numerLSp./denomLSp);
    % Depth-dependent photosynthetic rate
    rhoNDi = bio.muMaxDi * NutLimDi * Tfunc * LightFuncDi;
    rhoNSp = bio.muMaxSp * NutLimSp * Tfunc * LightFuncSp;
    % Depth-dependent rho-chl term of Geider et al., 1998
    rhoChlDi = bio.QNChlDi * rhoNDi ./ (bio.aLightDi * QChlNDi * PAR); 
    rhoChlSp = bio.QNChlSp * rhoNSp ./ (bio.aLightSp * QChlNSp * PAR);
    % Photoacclimation coefficient
    rhoPhotoAccDi = rhoChlDi .* rhoNDi/QChlNDi;
    rhoPhotoAccSp = rhoChlSp .* rhoNSp/QChlNSp;
    % 4. Averages final light-dependent terms over the Mixed Layer
    % Here uses straight average, since dz is constant
    rhoNDi = mean(rhoNDi);
    rhoNSp = mean(rhoNSp);
    rhoPhotoAccDi = mean(rhoPhotoAccDi);
    rhoPhotoAccSp = mean(rhoPhotoAccSp);
 otherwise
    % In this case PAR is constant, with specified value
    PAR = evar.PAR;
    numerLDi = bio.aLightDi * QChlNDi * evar.PAR;
    numerLSp = bio.aLightSp * QChlNSp * evar.PAR;
    denomLDi = bio.muMaxDi * NutLimDi * Tfunc;
    denomLSp = bio.muMaxSp * NutLimSp * Tfunc;
    % Light dependence of photosynthesis
    LightFuncDi = 1 - exp(-numerLDi/denomLDi);
    LightFuncSp = 1 - exp(-numerLSp/denomLSp);
    % Depth-dependent photosynthetic rate
    rhoNDi = bio.muMaxDi * NutLimDi * Tfunc * LightFuncDi;
    rhoNSp = bio.muMaxSp * NutLimSp * Tfunc * LightFuncSp;
    % Photoacclimation rho-chl term of Geider et al., 1998
    rhoChlDi = bio.QNChlDi * rhoNDi / (bio.aLightDi * QChlNDi * PAR); 
    rhoChlSp = bio.QNChlSp * rhoNSp / (bio.aLightSp * QChlNSp * PAR); 
    % Photoacclimation coefficient
    rhoPhotoAccDi = rhoChlDi * rhoN/QChlNDi;
    rhoPhotoAccSp = rhoChlSp * rhoN/QChlNSp;
 end

 %%%%%%%%%%%%%%%%%%%%
 % Photosynthesis &
 % Photoacclimation
 % (Diatom Chl cycle)
 %%%%%%%%%%%%%%%%%%%%
 JPhotoDi = rhoNDi * var.DiN;
 JPhotoAccDi = rhoPhotoAccDi * var.DiChl;
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 % Photosynthesis &
 % Photoacclimation
 % (Small Phyto. Chl cycle)
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 JPhotoSp = rhoNSp * var.SpN;
 JPhotoAccSp = rhoPhotoAccSp * var.SpChl;

 %%%%%%%%%%%%%%%
 % Diatom Losses  
 %%%%%%%%%%%%%%%
 % For losses, allows a "fraction" of phytoplankton to be preserved
 if evar.MLD <= 100
 bGrzThresDi=bio.bGrzThresDi;
 elseif evar.MLD > 100 & evar.MLD < 200
 bGrzThresDi=bio.bGrzThresDi*((200 + evar.MLD)/100);
 else
 bGrzThresDi=0;
 end
 PPDiN=max(var.DiN-bGrzThresDi,0);  
 % Lysis (this is the same as diat_loss in BEC)
 JLysDi = bio.lMortDi * PPDiN;
 % Partition Lysis to three components
 JLysDiPON = bio.aPOCDi * JLysDi;
 JLysDiDON = (1 - bio.fLab) * (1-bio.aPOCDi) * JLysDi;
 JLysDiDIN = bio.fLab * (1-bio.aPOCDi) * JLysDi;
 % Aggregation
 % Takes the minimum of a quadratic and linear terms
 JAggDi = max( bio.tAggDiMin*PPDiN , min( bio.tAggDiMax*PPDiN , bio.lMort2Di*PPDiN*PPDiN ) ); 
 %JAggDi = 0;
 % Grazing
 JGrzDi=bio.JgmaxDi*Tfunc*((var.ZN*PPDiN.^2)./(PPDiN.^2 + 0.81*(bio.bGrzZ^2)));
 JGrzZDi=bio.aGrzDi*JGrzDi;

 % Partition grazing to different components
 JGrzDiPON = bio.JGrzDiPON * JGrzDi;
 JGrzDiDON = bio.JGrzDiDON * JGrzDi;
 JGrzDiDIN = bio.JGrzDiDIN * JGrzDi;
 
 %%%%%%%%%%%%%%%%%%%%%
 % Small Phyto. Losses  
 %%%%%%%%%%%%%%%%%%%%%
 % For losses, allows a "fraction" of phytoplankton to be preserved
 if evar.MLD <= 100
 bGrzThresSp=bio.bGrzThresSp;
 elseif evar.MLD > 100 & evar.MLD < 200
 bGrzThresSp=bio.bGrzThresSp*((200 + evar.MLD)/100);
 else
 bGrzThresSp=0;
 end
 PPSpN=max(var.SpN-bGrzThresSp,0);  
 
 % Lysis
 JLysSp = bio.lMortSp * PPSpN;
 % Partition Lysis to three components
 JLysSpPON = 0.1 * JLysSp; % Note: Qcaco3CSp=0.1; 
 JLysSpDON = (1 - bio.fLab) * ( JLysSp - JLysSpPON);
 JLysSpDIN = bio.fLab * ( JLysSp - JLysSpPON);
 
 % Aggregation
 % Takes the minimum of a quadratic and linear terms
 JAggSp = min( bio.tAggSpMax*PPSpN , bio.lMort2Sp*PPSpN*PPSpN ); 
 %JAggSp = 0;
 % Grazing
 JGrzSp=bio.JgmaxSp*Tfunc*((var.ZN*PPSpN.^2)./(PPSpN.^2 + (bio.bGrzZ^2)));
 JGrzZSp=bio.aGrzSp*JGrzSp; 

 % Partition grazing to different components
 JGrzSpPON = max([0.4*0.1,min([0.18*PPSpN,bio.JGrzSpPON])]) * JGrzSp; % Note: Qcaco3CmaxSp = 0.4; Qcaco3CSp=0.1; 
 JGrzSpDON = bio.JGrzSpDON * JGrzSp - JGrzSpPON;
 JGrzSpDIN = bio.JGrzSpDIN * JGrzSp;
 
 %%%%%%%%%%%%%%%%%%%
 % Zooplakton Losses  
 %%%%%%%%%%%%%%%%%%%
 if evar.MLD <= 100
 bThresZ=bio.bThres0Z;
 elseif evar.MLD > 100 & evar.MLD < 200
 bThresZ=bio.bThres0Z*((200 + evar.MLD)/100);
 else
 bThresZ=0;
 end 
 ZPN=max(var.ZN-bThresZ,0);
 JlZ=bio.lMort2Z*Tfunc*(ZPN^2)+bio.lMortZ*Tfunc*ZPN;
 
 % Partition zooplankton to different components
 fdZ=((0.1333)*JGrzDi + (0.0333)*JGrzSp)/(JGrzDi+JGrzSp);
 if isnan(fdZ)==1
 fdZ=0;
 end
 JlZPON = fdZ*JlZ;
 JlZDON = (1-bio.fLab)*(1-fdZ)*JlZ;
 JlZDIN = (bio.fLab)*(1-fdZ)*JlZ;

 % Diatom Silica cycle
 %%%%%%%%%%%%%%%%%%%%%
 % Si:N  Ratio for Diatom Si losses
 QSiNDi = min( var.DiSi/var.DiN, bio.rSiNmax);
 % Baseline uptake value
 gQSiNDi = bio.rSiN;

 % Modify Si ratios under low ambient iron conditions
 % Silicon
 if var.Fe == 0
    gQSiNDi = bio.rSiNmax;
 elseif (0 < var.Fe < 2*bio.KFeDi) & (var.Si > 2*bio.KSiDi)
    gQSiNDi = min(bio.rSiNmax , ...
                  ((bio.rSiN * 2.5 * 2 * bio.KFeDi/var.Fe) - bio.rSiN * (2.5 - 1)));
 else
    gQSiNDi = bio.rSiN;
 end
 % Overrides values at low Si
 if var.Si < 2*bio.KSiDi
    gQSiNDi = max( bio.rSiNmin, ...
                  (gQSiNDi * var.Si/(2 * bio.KSiDi)));
 end

 %%%%%%%%%%%%%%%%%%%
 % Diatom Iron cycle
 %%%%%%%%%%%%%%%%%%%
 % Diatom biomass Fe:N
 QFeNDi = var.DiFe / var.DiN;
 % Fe:N ratio for growth
 if (var.Fe < 2 * bio.KFeDi)
    gQFeNDi = max( bio.rFeNminDi, ... 
                   bio.rFeNDi * var.Fe /(2 * bio.KFeDi));
 else
    gQFeNDi = bio.rFeNDi;
 end

 %%%%%%%%%%%%%%%%%%%%%%%%%
 % Small Phyto. Iron cycle
 %%%%%%%%%%%%%%%%%%%%%%%%%
 % Small Phyto. biomass Fe:N
 QFeNSp = var.SpFe / var.SpN;
 % Fe:N ratio for growth
 if (var.Fe < 2 * bio.KFeSp)
    gQFeNSp = max( bio.rFeNminSp, ... 
                   bio.rFeNSp * var.Fe /(2 * bio.KFeSp));
 else
    gQFeNSp = bio.rFeNSp;
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
 
 % Split uptake between NO3 and NH4
 vSpTot = vSpNO3 + vSpNH4;
 JNO3Sp = vSpNO3/vSpTot * JPhotoSp;
 JNH4Sp = vSpNH4/vSpTot * JPhotoSp;
 
 % Production of NH4 by Spatom Lysis - equivalent to loss to DIC in BEC
 JNH4Lys =  JLysDiDIN + JLysSpDIN + JlZDIN;
 % Production of NH4 by Grazing - equivalent to loss to DIC in BEC
 JNH4Grz = JGrzDiDIN + JGrzSpDIN;
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
 JGrzDiFe = JGrzDi * (QFeNDi - bio.rFeNZ); 
 JGrzSpFe = JGrzSp * (QFeNSp - bio.rFeNZ); 
 
 %%%%%%%%%%%%%%%%%%%%%
 % DOM/POM
 %%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%
 % DON and DOFe cycles
 %%%%%%%%%%%%%%%%%%%%% 
 % DON production
 JProdDON = JLysDiDON + JLysSpDON + JlZDON +JGrzDiDON + JGrzSpDON;
 % DON Remineralization
 JRemDON = bio.rDOM * var.DON;
 % DOFe productiom
 JProdDOFe = QFeNDi * (JLysDiDON +JGrzDiDON) + QFeNSp*(JLysSpDON  + JGrzSpDON) + bio.rFeNZ*JlZDON ; 
 % DOFe remineralization
 JRemDOFe = bio.rDOM * var.DOFe;

 %%%%%%%%%%%%%%%%%%%%%%%%%
 % PON, POFe and PSi cycles
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 % PON production
 JProdPON = JLysDiPON + JLysSpPON + JlZPON +JAggDi +JAggSp + JGrzDiPON + JGrzSpPON;
 % POFe production
 JProdPOFe = QFeNDi * (JLysDiPON + JAggDi + JGrzDiPON) + 0.1 * JScFe + QFeNSp*(JLysSpPON +JAggSp + JGrzSpPON) +  bio.rFeNZ*JlZPON  ;
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

 %%%%%%%%%%%%%%%%%%%%%%%%%
 % POM sinking
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 % Here adds a sinking terms to all particulate components, for mixed layer case
 % Sinking is just a removal term, assuming a constant sinking speed averaged over the ML.
 % All particle components are assumed to sink at the same rate, given by wSink/MLD (1/time)
 switch hab.ExpModule
 case {'mixed_layer','mixed_layer_3D'}
    sinkRate = bio.wsPOM/evar.MLD;
    sinkPON  = var.PON  * sinkRate;
    sinkPOFe = var.POFe * sinkRate;
    sinkPSi = var.PSi * sinkRate;
    sinkPDA  = var.PDA  * sinkRate;
 otherwise
    sinkPON  = 0;
    sinkPOFe = 0;
    sinkPSi = 0;
    sinkPDA  = 0;
 end

 %-----------------------------------------------------------
 % Final source and sink terms
 % 'NO3','NH4','Si','PO4','Fe','DiN','DiFe','DiChl','DiSi', ...
 % 'DON','DOFe','PON','POFe','PSi','DiDA','DDA','PDA'
 % Dissolved Inorganic Nutrients
 % NOTE: the bio.iRcy term allows recycling of nutrients
 dNO3dt = - JNO3Di - JNO3Sp;
 dNH4dt = - JNH4Di -JNH4Sp + bio.iRcy * (JNH4Lys + JNH4Grz + JNH4DON + JNH4PON);
 dPO4dt = bio.rPN * (- JPhotoDi -JPhotoSp + bio.iRcy * (JNH4DON + JRemPON + JNH4Lys + JNH4Grz));
 dSidt = - gQSiNDi * JPhotoDi + bio.iRcy * (JSiGrz + JSiLys + JRemPSi);  
 dFedt = - gQFeNDi * JPhotoDi - gQFeNSp * JPhotoSp + bio.iRcy * (JRemDOFe + JRemPOFe + (QFeNDi+QFeNSp) * (JNH4Lys + JNH4Grz) + JGrzDiFe + JGrzSpFe) - JScFe;
 % Zooplankton 
 dZNdt=JGrzZDi + JGrzZSp - JlZ;
 % Diatoms
 dDiNdt = JPhotoDi - (JGrzDi + JLysDi + JAggDi);
 dDiFedt = gQFeNDi * JPhotoDi - QFeNDi * (JGrzDi + JLysDi + JAggDi);
 dDiChldt = JPhotoAccDi - QChlNDi * (JGrzDi + JLysDi + JAggDi);
 dDiSidt = gQSiNDi * JPhotoDi - QSiNDi * (JGrzDi + JLysDi + JAggDi);
 % Small Phyto.
 dSpNdt = JPhotoSp - (JGrzSp + JLysSp + JAggSp);
 dSpFedt = gQFeNSp * JPhotoSp - QFeNSp * (JGrzSp + JLysSp + JAggSp);
 dSpChldt = JPhotoAccSp - QChlNSp * (JGrzSp + JLysSp + JAggSp);
 % Dissolved Matter
 dDONdt = JProdDON - JRemDON;
 dDOFedt = JProdDOFe - JRemDOFe;
 % Particulate Matter
 dPONdt = JProdPON - JRemPON - sinkPON;
 dPOFedt = JProdPOFe - JRemPOFe - sinkPOFe;
 dPSidt = JProdPSi - JRemPSi - sinkPSi;
 % DA production
 dDiDAdt = DiDAprod - DiDAloss;
 dDDAdt  = DDAprod  - DDAloss;
 dPDAdt  = PDAprod  - PDAloss - sinkPDA;
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
        dZNdt;...
        dSpNdt;...
        dSpFedt;...
        dSpChldt];

