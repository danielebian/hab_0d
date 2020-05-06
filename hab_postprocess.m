 function hab = hab_postprocess(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D postprocessing
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.C2Chl = 50;	% Default C:Chl ratio (gC:gChl)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse required variables, substituting defaults where necessary
 Param = parse_pv_pairs(Param,varargin);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds important variables, including chlorophyll, etc.
 switch hab.BioModule
 case 'anderson'
    hab.Sol.Chl = 12/Param.C2Chl * (hab.Sol.PN);     %Converting mol C to mg C/m3
    hab.Sol.pDA = hab.Sol.pDA;
    hab.Sol.dDA = hab.Sol.dDA;
    hab.Sol.tDA = hab.Sol.pDA+hab.Sol.dDA;  %mol DA
 case 'terseleer'
    hab.Sol.Chl = 12/Param.C2Chl * (hab.Sol.PNF);    %Converting mol C to mg C/m3
    hab.Sol.pDA = hab.Sol.pDA/15;           %Converting mol C to mol DA
    hab.Sol.dDA = hab.Sol.dDA/15;           %Converting mol C to mol DA
    hab.Sol.tDA = hab.Sol.pDA+hab.Sol.dDA;  %mol DA 
    % Adds PN total organic N for comparison with BEC
    % Based on Terseller includes only finctional C mass and intracellular DA
    hab.Sol.PNN = hab.Sol.PNF * hab.BioPar.rNC + hab.Sol.pDA * hab.BioPar.rNCDA;
 case 'bec_diat'
    hab.Sol.pDA = hab.Sol.DiDA + hab.Sol.PDA;           % Sums diatom and particulate DA to get total
    hab.Sol.dDA = hab.Sol.DDA;           		% Just uses DDA (N units)
  otherwise
    error(['Crazy town! (Processing not found)']);
 end


