 function BioPar = hab_initialize_anders(BioPar,ExpModule)

 % Sets initial and boundary conditions for biological variables 
 % Distinguishes between the various physical setups

 switch ExpModule
 case 'batch'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 980;
    BioPar.Si_0 = 132;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_0 = 0.1;
    BioPar.pDA_0 = 0.0;
    BioPar.dDA_0 = 0.0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 16;
    BioPar.Si_in = 10;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_in = 0;
    BioPar.pDA_in = 0;
    BioPar.dDA_in = 0;

 case 'chemostat'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 561;
    BioPar.Si_0 = 45;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_0 = 0.1;
    BioPar.pDA_0 = 0.0;
    BioPar.dDA_0 = 0.0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 561;
    BioPar.Si_in = 45;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_in = 0;
    BioPar.pDA_in = 0;
    BioPar.dDA_in = 0;

 case 'mixed_layer'
    % Model variables: set initial values
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_0 = 5;
    BioPar.Si_0 = 10;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_0 = 0.1;
    BioPar.pDA_0 = 0.0;
    BioPar.dDA_0 = 0.0;

    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 10;
    BioPar.Si_in = 15;
    %-------------------------------------------
    % Biological pools:
    BioPar.PN_in = 0;
    BioPar.pDA_in = 0;
    BioPar.dDA_in = 0;

 otherwise
    error(['Crazy town! (physical SMS case not found)']);
 end
 

