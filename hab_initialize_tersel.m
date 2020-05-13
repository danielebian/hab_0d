 function BioPar = hab_initialize_tersel(BioPar,ExpModule)

 % Sets initial and boundary conditions for biological variables 
 % Distinguishes between the various physical setups

 switch ExpModule
 case 'batch'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 974;            % In mmolN/m3  
    BioPar.Si_0 = 136;             % In mmolSi/m3  
    BioPar.PO4_0 = 16.3;           % In mmolP/m3 
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_0 = 27.5;           % In mmolC/m3  
    BioPar.PNS_0 = 27.5*0.57;      % In mmolC/m3  
    BioPar.PNR_0 = 27.5*0.75;      % In mmolC/m3  
    BioPar.pDA_0 = 0.009;          % In mmolC/m3  
    BioPar.dDA_0 = 0;              % In mmolC/m3  

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 0;               % In mmolN/m3  
    BioPar.Si_in = 0;                % In mmolSi/m3  
    BioPar.PO4_in = 0;                % In mmolP/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_in = 0;             % In mmolC/m3  
    BioPar.PNS_in = 0;             % In mmolC/m3  
    BioPar.PNR_in = 0;             % In mmolC/m3  
    BioPar.pDA_in = 0;             % In mmolC/m3  
    BioPar.dDA_in = 0;             % In mmolC/m3  

 case 'chemostat'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 561;            % In mmolN/m3  
    BioPar.Si_0 = 45;             % In mmolSi/m3  
    BioPar.PO4_0 = 561/16;           % In mmolP/m3 
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_0 = 27.5;           % In mmolC/m3  
    BioPar.PNS_0 = 27.5*0.57;      % In mmolC/m3  
    BioPar.PNR_0 = 27.5*0.75;      % In mmolC/m3  
    BioPar.pDA_0 = 0.009;          % In mmolC/m3  
    BioPar.dDA_0 = 0;              % In mmolC/m3  

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 561;              % In mmolN/m3  
    BioPar.Si_in = 45;                % In mmolSi/m3  
    BioPar.PO4_in = 561/16;           % In mmolP/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_in = 0;             % In mmolC/m3  
    BioPar.PNS_in = 0;             % In mmolC/m3  
    BioPar.PNR_in = 0;             % In mmolC/m3  
    BioPar.pDA_in = 0;             % In mmolC/m3  
    BioPar.dDA_in = 0;             % In mmolC/m3  

 case 'mixed_layer'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 5;            % In mmolN/m3  
    BioPar.Si_0 = 10;             % In mmolSi/m3  
    BioPar.PO4_0 = 1;           % In mmolP/m3 
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_0 = 0.5;           % In mmolC/m3  
    BioPar.PNS_0 = 0.5*0.57;      % In mmolC/m3  
    BioPar.PNR_0 = 0.5*0.75;      % In mmolC/m3  
    BioPar.pDA_0 = 0;          % In mmolC/m3  
    BioPar.dDA_0 = 0;              % In mmolC/m3  

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients: of [yN=38;yS=34;xW=-124;xE=-117];
    BioPar.NO3_in = 8.6865;               % In mmolN/m3  
    BioPar.Si_in = 10.7468;                % In mmolSi/m3  
    BioPar.PO4_in = 0.9525;                % In mmolP/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.PNF_in = 0;             % In mmolC/m3  
    BioPar.PNS_in = 0;             % In mmolC/m3  
    BioPar.PNR_in = 0;             % In mmolC/m3  
    BioPar.pDA_in = 0;             % In mmolC/m3  
    BioPar.dDA_in = 0;             % In mmolC/m3  

 otherwise
    error(['Crazy town! (physical SMS case not found)']);
 end
 

