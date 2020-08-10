 function BioPar = hab_initialize_bec_full(BioPar,ExpModule,file)

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
    BioPar.ZN_0 = 0;
    BioPar.SpN_0 = 0;
    BioPar.SpFe_0 = 0;
    BioPar.SpChl_0 = 0;
    BioPar.SpSi_0 = 0;
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
    BioPar.ZN_in = 0;
    BioPar.SpN_in = 0;
    BioPar.SpFe_in = 0;
    BioPar.SpChl_in = 0;
    BioPar.SpSi_in = 0;
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
    BioPar.ZN_0 = 0;
    BioPar.SpN_0 = 0;
    BioPar.SpFe_0 = 0;
    BioPar.SpChl_0 = 0;
    BioPar.SpSi_0 = 0;
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
    BioPar.ZN_in = 0;
    BioPar.SpN_in = 0;
    BioPar.SpFe_in = 0;
    BioPar.SpChl_in = 0;
    BioPar.SpSi_in = 0;
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
    BioPar.ZN_0 = 1.0;
    BioPar.SpN_0 = 1.0;
    BioPar.SpFe_0 = 4e-5;
    BioPar.SpChl_0 = 1.0;
    BioPar.SpSi_0 = 1.0;
    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 8.6865;           % In mmolN/m3  
    BioPar.NH4_in = 0;             % In mmolN/m3  
    BioPar.Si_in = 10.7468;             % In mmolSi/m3  
    BioPar.PO4_in = 0.9525;        % In mmolP/m3  
    BioPar.Fe_in = 0.1;            % In nmolFe/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_in = 0.01;
    BioPar.DiFe_in = 0.01/1000;
    BioPar.DiChl_in = 0.01;
    BioPar.DiSi_in = 0.01;
    BioPar.DON_in = 0;
    BioPar.DOFe_in = 0;
    BioPar.PON_in = 0;
    BioPar.POFe_in = 0;
    BioPar.PSi_in = 0;
    BioPar.DiDA_in = 0;
    BioPar.DDA_in = 0;
    BioPar.PDA_in = 0;
    BioPar.ZN_in = 0.01;
    BioPar.SpN_in = 0.01;
    BioPar.SpFe_in = 0.01/1000;
    BioPar.SpChl_in = 0.01;
    BioPar.SpSi_in = 0.01;
    
   case 'mixed_layer_3D'
    % Model variables: set initial values
    %-------------------------------------------
    
    load(char(file))
    
    % Nutrients:
    BioPar.NO3_0 =5;% mean(var1d.NO3);            % In mmolN/m3 (974,780)  
    BioPar.NH4_0 =0;% mean(var1d.NH4);              % In mmolN/m3  
    BioPar.Si_0 =8;% mean(var1d.SiO3);              % In mmolSi/m3 (136,102.2)  
    BioPar.PO4_0 =1;% mean(var1d.PO4);         % In mmolP/m3 (16.3,2.7)  
    BioPar.Fe_0 =1e-1;% mean(var1d.Fe);            % In mmolFe/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_0 =1;% mean(var1d.DIATC*BioPar.rNC);
    BioPar.DiFe_0 =4e-5;% mean(var1d.DIATFE);
    BioPar.DiChl_0 =1;% mean(var1d.DIATCHL);
    BioPar.DiSi_0 =1;% mean(var1d.DIATSI);
    BioPar.DON_0 =0;% mean(var1d.DON);
    BioPar.DOFe_0 =0;%mean(var1d.DOFE);
    BioPar.PON_0 = 0;
    BioPar.POFe_0 = 0;
    BioPar.PSi_0 = 0;
    BioPar.DiDA_0 = 0;
    BioPar.DDA_0 = 0;
    BioPar.PDA_0 = 0;
    BioPar.ZN_0 =1;% mean(var1d.ZOOC*BioPar.rNC);
    BioPar.SpN_0 =1;%mean(var1d.SPC*BioPar.rNC);
    BioPar.SpFe_0 =4e-5;% mean(var1d.SPFE);
    BioPar.SpChl_0 =1;%mean(var1d.SPCHL);
    BioPar.SpSi_0 = 1;%0;
    % For the chemostat or mixed layer case, set up input values for all tracers
    % (typically, specify nutrients and set all biological terms to 0)
    %-------------------------------------------
    % Nutrients:
    BioPar.NO3_in = 8.6865;%var1d.NO3_in;           % In mmolN/m3  
    BioPar.NH4_in =0;% var1d.NH4_in;             % In mmolN/m3  
    BioPar.Si_in = 10.7468;%var1d.SiO3_in;             % In mmolSi/m3  
    BioPar.PO4_in = 0.9525;%var1d.PO4_in;        % In mmolP/m3  
    BioPar.Fe_in =0.1;%var1d.Fe_in;             % In nmolFe/m3  
    %-------------------------------------------
    % Biological pools:
    BioPar.DiN_in =0.01;% var1d.DIATC_in*BioPar.rNC;
    BioPar.DiFe_in =0.01/1000;% var1d.DIATFE_in;
    BioPar.DiChl_in =0.01;% var1d.DIATCHL_in;
    BioPar.DiSi_in = 0.01;%var1d.DIATSI_in;
    BioPar.DON_in = 0;%var1d.DON_in;
    BioPar.DOFe_in = 0;%var1d.DOFE_in;
    BioPar.PON_in = 0;
    BioPar.POFe_in = 0;
    BioPar.PSi_in = 0;
    BioPar.DiDA_in = 0;
    BioPar.DDA_in = 0;
    BioPar.PDA_in = 0;
    BioPar.ZN_in = 0.01;%var1d.ZOOC_in*BioPar.rNC;
    BioPar.SpN_in = 0.01;%var1d.SPC_in*BioPar.rNC;
    BioPar.SpFe_in = 0.01/1000;%var1d.SPFE_in;
    BioPar.SpChl_in = 0.01;%var1d.SPCHL_in;
    BioPar.SpSi_in = 0.01;
 otherwise
    error(['Crazy town! (physical SMS case not found)']);
 end
 
