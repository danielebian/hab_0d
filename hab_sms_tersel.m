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

 % NOTE: here converts PAR from W/m2 to umol/m2/s (1 W/m2 ≈ 4.6 μmole/m2/s);
 evar.PAR = evar.PAR * 4.6;

 % Photosynthesis rate:
 % Differentiate culture case (constant light) from Mixed Layer case (depth-dependent light)
 switch hab.ExpModule
 case 'mixed_layer'
    % In this case PAR represents light at the surface of the ML
    % Growth need to be averaged over the mixed layer
    %-----------------------
    % 1. Estimates the light attenuation coefficient including "self-shading"
    % Note that since ML is well-mixed, the attenuation coefficient is constant with depth
    % Biomass in mmolC/m3 estimated from PNF, converted to Chl units with a fixed C:Chl;
    kPAR = hab.SetUp.kwPAR + bio.kcPAR * var.PNF * 12/50;
    %-----------------------
    % 2. Estimates light in the water column on a vertical grid between [0,MLD]
    zPAR = linspace(0,evar.MLD,hab.SetUp.nzPAR);
    PAR = evar.PAR * exp(-kPAR*zPAR);
    % 3. Calculates depth-dependent photosynthetic rate
    photo_z = bio.kmax * (1-exp(-bio.alpha*PAR/bio.kmax))*var.PNF;
    % 4. Averages photosynthetic rate over the Mixed Layer
    % Here uses straight average, since dz is constant
    photo = mean(photo_z);
 otherwise
    % In this case PAR is constant, with specified value
    photo = bio.kmax * (1-exp(-bio.alpha*evar.PAR/bio.kmax))*var.PNF;
 end

 % Growth rate
 Sut = var.PNS/var.PNF - bio.kass; 
% limNut = (var.NO3*var.PO4*var.Si)/ ...
%      (bio.KNO3*bio.KPO4*bio.KSi + bio.KPO4*bio.KSi*var.Si + ...
%      bio.KSi*bio.KNO3*var.PO4 + bio.KNO3*var.PO4*var.Si + ....
%      bio.KPO4*bio.KSi*var.NO3 + bio.KPO4*var.NO3*var.Si + ...
%      bio.KSi*var.NO3*var.PO4 + var.NO3*var.PO4*var.Si);
 limNut = (var.NO3*var.PO4*var.Si)/ ...
          (bio.KNO3*var.PO4*var.Si + bio.KPO4*var.NO3*var.Si + ...
           bio.KSi*var.NO3*var.PO4 +var.NO3*var.PO4*var.Si);
 growth = bio.mumax * Sut^2/(Sut^2+bio.kass^2) * limNut * var.PNF; 

 % Lysis and excretion rates
 lysPNF = bio.klys * (1+7.5*(1-limNut)) * var.PNF; 
 lysPNS = bio.klys * (1+7.5*(1-limNut)) * var.PNS; 
 lysPNR = bio.klys * (1+7.5*(1-limNut)) * var.PNR; 
 lyspDA = bio.klys * (1+7.5*(1-limNut)) * var.pDA; 

 % Excretion rates
 excPNS = bio.kexc * var.PNS; 
 excpDA = bio.kexc * var.pDA; 

 % DA Production
 limN = var.NO3/(var.NO3 + bio.KNO3);
 prodDA = bio.kDA * var.PNS * limN;

 % Respiration rates
 resp = bio.maint * var.PNF + bio.ePNFcost * growth + bio.ePNFcost * prodDA;

 % Reserve rates
 syntPNR = bio.sPNRmax * Sut^2/(Sut^2+bio.kass^2) * var.PNS; 
 catPNR = bio.kPNRcat * var.PNR;
 
 % Nutrient uptake
 uptNO3 = growth * bio.rNC + prodDA * bio.rNCDA;
 uptPO4 = growth * bio.rPC;
 uptSi = growth * bio.rSiC;

 % Final source and sink terms
 % 'NO3','Si','PO4','PNF','PNS','PNR','pDA','dDA'
 dNO3dt = - uptNO3;
 dPO4dt = - uptPO4;
 dSidt = - uptSi;
 dPNFdt = growth - lysPNF;
 dPNSdt = photo - growth - resp - lysPNS - excPNS - syntPNR + catPNR - prodDA;
 dPNRdt = syntPNR - catPNR - lysPNR;
 dpDAdt = prodDA - excpDA - lyspDA;
 ddDAdt = excpDA + lyspDA;

 % Lumps SMS terms into a single vector
 sms = [dNO3dt;dSidt;dPO4dt;dPNFdt;dPNSdt;dPNRdt;dpDAdt;ddDAdt];

