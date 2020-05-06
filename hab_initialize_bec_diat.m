 function BioPar = hab_initialize_bec_diat(BioPar,ExpModule)

 % Sets initial and boundary conditions for biological variables 
 % Distinguishes between the various physical setups

 switch ExpModule
 case 'batch'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 975;            % In mmolN/m3 (974,780)  
    BioPar.NH4_0 = 0;              % In mmolN/m3  
    BioPar.Si_0 = 136;             % In mmolSi/m3 (136,102.2)  
    BioPar.PO4_0 = 16.3;           % In mmolP/m3 (16.3,2.7)  
    BioPar.Fe_0 = 1e-1;            % In mmolFe/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_0 = 5.5;
    BioPar.DiFe_0 = 4e-5;
    BioPar.DiChl_0 = 0.8;
    BioPar.DiSi_0 = 5.5;
    BioPar.DON_0 = 0.00;
    BioPar.DOFe_0 = 0.0;
    BioPar.PON_0 = 0.00;
    BioPar.POFe_0 = 0.00;
    BioPar.PSi_0 = 0.00;
    BioPar.DiDA_0 = 0;
    BioPar.DDA_0 = 0;
    BioPar.PDA_0 = 0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 561;           % In mmolN/m3  
    BioPar.NH4_in = 0;             % In mmolN/m3  
    BioPar.Si_in = 45;             % In mmolSi/m3  
    BioPar.PO4_in = 561/16;        % In mmolP/m3  
    BioPar.Fe_in = 0.1;            % In nmolFe/m3  
    %-------------------------------------------
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
    BioPar.DiDA_in = 0;
    BioPar.DDA_in = 0;
    BioPar.PDA_in = 0;

 case 'chemostat'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 561;            % In mmolN/m3 (561)  
    BioPar.NH4_0 = 0;              % In mmolN/m3 (0) 
    BioPar.Si_0 = 45;              % In mmolSi/m3 (45)
    BioPar.PO4_0 = 561/16;         % In mmolP/m3 (561/16)
    BioPar.Fe_0 = 1e-1;            % In mmolFe/m3 (0.1) 
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_0 = 5.5;
    BioPar.DiFe_0 = 4e-5;
    BioPar.DiChl_0 = 0.8;
    BioPar.DiSi_0 = 5.5;
    BioPar.DON_0 = 0.00;
    BioPar.DOFe_0 = 0.0;
    BioPar.PON_0 = 0.00;
    BioPar.POFe_0 = 0.00;
    BioPar.PSi_0 = 0.00;
    BioPar.DiDA_0 = 0;
    BioPar.DDA_0 = 0;
    BioPar.PDA_0 = 0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 561;            % In mmolN/m3 (561)  
    BioPar.NH4_in = 0;              % In mmolN/m3 (0) 
    BioPar.Si_in = 45;              % In mmolSi/m3 (45)
    BioPar.PO4_in = 561/16;         % In mmolP/m3 (561/16)
    BioPar.Fe_in = 1e-1;            % In mmolFe/m3 (0.1) 
    %-------------------------------------------
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
    BioPar.DiDA_in = 0;
    BioPar.DDA_in = 0;
    BioPar.PDA_in = 0;

 case 'mixed_layer'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 5;            % In mmolN/m3 (974,780)  
    BioPar.NH4_0 = 0;              % In mmolN/m3  
    BioPar.Si_0 = 8;              % In mmolSi/m3 (136,102.2)  
    BioPar.PO4_0 = 1;         % In mmolP/m3 (16.3,2.7)  
    BioPar.Fe_0 = 1e-1;            % In mmolFe/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_0 = 1.0;
    BioPar.DiFe_0 = 4e-5;
    BioPar.DiChl_0 = 1.0;
    BioPar.DiSi_0 = 1.0;
    BioPar.DON_0 = 0.00;
    BioPar.DOFe_0 = 0.0;
    BioPar.PON_0 = 0.00;
    BioPar.POFe_0 = 0.00;
    BioPar.PSi_0 = 0.00;
    BioPar.DiDA_0 = 0;
    BioPar.DDA_0 = 0;
    BioPar.PDA_0 = 0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 15;           % In mmolN/m3  
    BioPar.NH4_in = 0;             % In mmolN/m3  
    BioPar.Si_in = 5;             % In mmolSi/m3  
    BioPar.PO4_in = 2;        % In mmolP/m3  
    BioPar.Fe_in = 0.1;            % In nmolFe/m3  
    %-------------------------------------------
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
    BioPar.DiDA_in = 0;
    BioPar.DDA_in = 0;
    BioPar.PDA_in = 0;

 otherwise
    error(['Crazy town! (physical SMS case not found)']);
 end
 

