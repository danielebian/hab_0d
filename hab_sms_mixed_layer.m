 function sms = hab_sms_mixed_layer(hab,Var,EnvVar,InVar)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D SMS for Anderson's model
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %------------------------------------------------
 % Preliminary processing
 % Create a structure with current environemnental variables, for simplicity 
 nevar = hab.SetUp.nevar;        % number of environmental forcing variables
 % Create a structure with current environmental variables, for simplicity 
 for indv=1:nevar
    evar.(hab.SetUp.evarnames{indv}) = EnvVar(indv);
 end
 %------------------------------------------------------------------------
 % For now assumes all tracers are equally diluted, and that they do NOT concentrate
 % when the ML shoals (this may be the case for swimmers, e.g. zooplankton)
 % This assumption should be fine for "anderson" and "terseller" cases
 % If assumption is re-evaluated, then use a switch option
 
 % Lumps together all transport terms, and normalizes by MLD
 % following formulation of Evan and Parslow, 1985
 % Note the use of the positive change in MLD, to represent dilution only
 Transp = (evar.Flow + max(0,evar.dMLD)) / evar.MLD;
 
 % Applies transport term to all variables, assuming the values below the ML
 % are given by the "_in" terms specified in BioPar
 sms = Transp * (InVar - Var); 
 
 

