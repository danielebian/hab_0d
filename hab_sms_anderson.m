 function sms = hab_sms_anderson(hab,Var)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D SMS for Anderson's model
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 nvar = hab.BioPar.nvar;        % number of model state variables
 % Create a structure with current state variables, for simplicity 
 for indv=1:nvar
   %var.(hab.BioPar.varnames{indv}) = Var(indv);
    % If a variable is negative, it will be set to zero
    var.(hab.BioPar.varnames{indv}) = max(0,Var(indv));
 end

 % Structure with the bioparameters, for simplicity
 bio = hab.BioPar;
 
 % Calculates nutrient limitation terms:
 limSi = var.Si / (bio.KSi+var.Si); 
 limN = var.NO3 / (bio.KNO3+var.NO3); 
 limNutr = min(limSi,limN);
 nutRat = min(limSi/limN,1);

 % Calculate growth and mortality
 growth = bio.muGrw * limNutr * var.PN; 
 mort = bio.muLys * var.PN;
 
 % DA Production
 alpha = bio.beta  * (1-nutRat)^bio.gamma;
 DAprod = alpha * growth;
 
 % Loss Terms
 DAloss = bio.muExDA * var.pDA;
 Nupt = growth * bio.rNC;
 Siupt = growth * bio.rSiC;

% Final source and sink terms
 % Variables: 'PN','pDA','dDA','NO3','Si'
 dNdt = - Nupt;
 dSidt = - Siupt;
 dPNdt = growth - mort;
 dpDAdt = DAprod - DAloss;
 ddDAdt = DAloss; 

 % Lumps SMS terms into a single vector
 sms = [dNdt;dSidt;dPNdt;dpDAdt;ddDAdt];


