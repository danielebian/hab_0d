 function hab = hab_postprocess(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D postprocessing
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Param.C2Chl = 50;	% Default C:Chl ratio (gC:gChl)
 Param.dt_new = nan;	% New timestep (hours) for post-processing (ignored if NaN)
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
    error(['Crazy town! (Processing biomodule not found)']);
 end

 if ~isnan(Param.dt_new)
    % Reduces the frequency of output, by inteprolating on a different timestep
    % New model timestep (hours)
    dt_new = Param.dt_new;
    if dt_new<hab.SetUp.dt
       disp(['WARNING: new timestep in postprocessing SMALLER than original timestep']);
    end
    % Creates a new time vector
    new_time = [hab.SetUp.StartTime:dt_new:hab.SetUp.EndTime]; 
    % Loops through all solution variables to regrid them on time axis
    allvar = setdiff(fieldnames(hab.Sol),'time');
    nvar = length(allvar);
    for indv=1:nvar
       % Gets and interpolates variable on new time axis
       oldvar = hab.Sol.(allvar{indv});
       newvar = interp1(hab.Sol.time,oldvar,new_time);
       % Substitutes back into Solution structure
       hab.Sol.(allvar{indv}) = newvar;
    end
    % Substitutes time vector in Solution strucutre
    hab.Sol.time = new_time;
    % Adds new timestep to solution 
    hab.SetUp.dt_out = dt_new;
 end

