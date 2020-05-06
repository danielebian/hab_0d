 function hab = hab_setup_mixed(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of experiment setup
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% Simulates a Mixed Layer dynamics, with variable MLD and light condition
% Main environmental variables specified here:
%    PAR: light level at the surface (umol/m2/s)
%    MLD: depth of the ML (m)
%    dMLD: rate of change in the depth of the ML (m/hour)
%    Flow: rate of water mixing (or transport -- e.g. upwelling) at the base of ML (m/hour)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %--------------------------------------------------------------------------------
 % First define all CONSTANT parameters
 %--------------------------------------------------------------------------------

 %-------------------------------
 % General setup
 SetUp.StartTime = 0*24;	% Duration of batch culture (hours)
 SetUp.EndTime = 10*365*24;	% Duration of batch culture (hours)
 SetUp.dt = 1.0;		% timestep (hours)

 %-------------------------------
 % Light attenuation in the Mixed Layer, including "self-shading"
 % Add the biomass-dependent PAR attenuation in the Biological module
 SetUp.kwPAR = 0.04; 	% pure water PAR attenuation (1/m) 
 SetUp.nzPAR = 100;	% Number of vertical grid points for
			% depth-dependent light calculations

 %-------------------------------
 % Define the type and properties of surface light forcing
 SetUp.iLight = 4;	% 1: Constant light 
			% 2: 12:12 light:darkness cycles
			% 3: Idealized annual cycle (mid-high latitudes)
			% 4: Observed cycle (California Current)
 % Parameters:
 SetUp.MaxPAR = 120;  	% (iLight=1,2) Max PAR 
			% PAR: Photosynthetially Available Radiation umol/m2/s 
 % For case 3, Idealized annual cycle:
 SetUp.day_min_PAR = 355;	% (iLight=3) Day of the year with minimum light (e.g. Dec. 21st)
 SetUp.PAR_min = 60;		% (iLight=3) Photosynthetially Available Radiation umol/m2/s   
 SetUp.PAR_max = 180; 		% (iLight=3) Photosynthetially Available Radiation umol/m2/s  

 %-------------------------------
 % Define the type and properties of ML temperature 
 SetUp.iTemp = 3;	% 1: Constant temperature 
			% 2: Idealized annual cycle
			% 3: Observed cycle (California Current)
 % Parameters:
 SetUp.TempRef = 15;  		% (iTemp=1) Temperature for case 1
 % For case 3, Idealized annual cycle:
 SetUp.day_min_Temp = 355;	% (iTemp=2) Day of the year with minimum temperature (e.g. Dec. 21st)
 SetUp.Temp_min = 5;		% (iTemp=2) Min temp (C)
 SetUp.Temp_max = 20; 		% (iTemp=2) Max temp (C)

 %-------------------------------
 % Define the type and properties of MLD dynamics
 SetUp.iMLD = 3;	% 1: Constant MLD
			% 2: Idealized annual cycle
			% 3: Observed cycle (California Current)
 % Parameters:
 SetUp.MLD0 = 40;  		% (iMLD=1) Mixed layer depth (m)
 SetUp.day_min_MLD = 265;	% (iMLD=2) Day of the year with minimum MLD (e.g. Sept. 21st)
 SetUp.MLD_min = 20;		% (iMLD=2) shallowest MLD (m)
 SetUp.MLD_max = 70; 		% (iMLD=2) deepest MLD (m)

 %-------------------------------
 % Define the type and properties of mixing/upwelling flow
 SetUp.iFlow = 1;	% 1: constant flow
                        % 2: idealized cycle
			% 3: Observed cycle (California Current)
 SetUp.Flow0 = 0;  		% (iFlow=1) Rate of water flow at base of ML (m/y) (typically 100-1000?)
 SetUp.day_min_Flow = 152;	% (iFlow=2) Day of the year with minimum Flow (June 1)
 SetUp.Flow_min = 0;		% (iFlow=2) Flow (m/y)
 SetUp.Flow_max = 200; 		% (iFlow=2) Flow (m/y)

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 SetUp = parse_pv_pairs(SetUp, varargin); 
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Second, define/process derived variables
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Environmental conditions
 % add here any environmental conditions, use the time vector for time dependent
 % variables (e.g. light, or temperature)
 SetUp.evarnames = {'PAR','Temp','MLD','dMLD','Flow'};
 SetUp.nevar = length(SetUp.evarnames);

 % Time vector
 SetUp.time = [SetUp.StartTime:SetUp.dt:SetUp.EndTime-SetUp.dt];
 SetUp.ntime = length(SetUp.time);

 %--------------------------------------------------------------------------------
 % Set temperature conditions
 switch SetUp.iTemp
 case 1
    % Case (1) : constant temperature
    % Vector of leratureight values (defined in each time step):
    SetUp.Env.Temp = SetUp.MaxTemp * ones(1,SetUp.ntime);
 case 2
    %--------------
    % Case (2) : Idealized annual cycle
    % Here specifies [time,Temp] values and interpolates in between
    % Creates a sinusoidal temperature cycle between a min and a max value
    % Assumes time is specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    % Assumes the minimum is at December 21 (day=355, or -10)
    % time0 = cumsum([0 31 28 31 30 31 30 31 31 30 31 30]) + ...
    %         round([31 28 31 30 31 30 31 31 30 31 30 31]/2)-1;
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];

    % Uses a cosine function shifted by pi, starting at the winter solstice (day=355)
    % Sets minimum value to Temp_min, and maximum value to Temp_max
    Temp0 = 0.5*(SetUp.Temp_min+SetUp.Temp_max) + 0.5*(SetUp.Temp_max-SetUp.Temp_min) * ...
           cos(2*pi*(time0-SetUp.day_min_Temp)/365-pi); 

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.Temp = interpolate_annual_cycle_to_model(time0,Temp0,SetUp.time,int_mode);
 case 3
    %--------------
    % Case (3) : Monthly climatology from........... of [yN=38;yS=34;xW=-124;xE=-117];
    % Assumes time is specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];
    Temp0 = [13.0690   12.9768   12.8284   12.7843   13.1729   13.8342   14.7581   15.5720   16.3578   15.7215   14.8540   13.9342];

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.Temp = interpolate_annual_cycle_to_model(time0,Temp0,SetUp.time,int_mode);
 otherwise
    error(['Crazy Town! Temperature Off!']);
 end
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Set Mixed Layer dynamics 
 %--------------------------------------------------------------------------------
 % Set light conditions
 switch SetUp.iLight
 case 1
    % Case (1) : constant light
    % Vector of light values (defined in each time step):
    SetUp.Env.PAR = SetUp.MaxPAR * ones(1,SetUp.ntime);
 case 2
    % Case (2) : 12:12 light:darkness cycles
    % Vector of light values (defined in each time step):
    SetUp.Env.PAR = SetUp.MaxPAR * ones(1,SetUp.ntime);
    % Find the indices corresponding to times (in hour) between 12-24h, and multiples
    indLight = (((SetUp.time/24) - floor(SetUp.time/24)))<0.5;
    SetUp.Env.PAR(indLight) = 0;
 case 3
    %--------------
    % Case (3) : Idealized annual cycle
    % Here specifies [time,PAR] values and interpolates in between
    % Creates a sinusoidal light cycle between a min and a max value
    % Assumes time si specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    % Assumes the minimum is at December 21 (day=355, or -10)
    % time0 = cumsum([0 31 28 31 30 31 30 31 31 30 31 30]) + ...
    %         round([31 28 31 30 31 30 31 31 30 31 30 31]/2)-1;
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];

    % Uses a cosine function shifted by pi, starting at the winter solstice (day=355)
    % Sets minimum value to PAR_min, and maximum value to PAR_max
    PAR0 = 0.5*(SetUp.PAR_min+SetUp.PAR_max) + 0.5*(SetUp.PAR_max-SetUp.PAR_min) * ...
           cos(2*pi*(time0-SetUp.day_min_PAR)/365-pi); 

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.PAR = interpolate_annual_cycle_to_model(time0,PAR0,SetUp.time,int_mode);
 case 4
    %--------------
    % Case (4) : Monthly Climatology of shortwave atmospheric radiation
    % (CORE-I climatology) of [yN=38;yS=34;xW=-124;xE=-117];
    % Assumes time si specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];
    % Note: PAR here is expressed in W/m2, it will be converted to μmol/m2/s in Terseler's biogeochemical model
    %       Also note that PAR = 0.45 * (Incoming Shortwave Radiation) (W/m2)
    PAR0 = [112.1075  150.6634  189.2540  242.9275  280.2024  308.1101  304.7319  282.4868  236.7022  179.7531  127.0540  101.5912]*0.45; %From SAR to PAR 

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
         % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.PAR = interpolate_annual_cycle_to_model(time0,PAR0,SetUp.time,int_mode);
 otherwise
    error(['Crazy Town! Lights Off!']);
 end
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Set Mixed Layer dynamics 
 switch SetUp.iMLD
 case 1
    % Case (1) : constant MLD
    % Vector of MLD values (defined in each time step):
    SetUp.Env.MLD = SetUp.MLD0 * ones(1,SetUp.ntime);
 case 2
    %--------------
    % Case (2) : Idealized annual cycle
    % Here specifies [time,MLD] values and interpolates in between
    % Creates a sinusoidal MLD cycle between a min and a max value
    % Assumes time si specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    % Assumes the minimum is at September 21 (day=365)
    % time0 = cumsum([0 31 28 31 30 31 30 31 31 30 31 30]) + ...
    %         round([31 28 31 30 31 30 31 31 30 31 30 31]/2)-1;
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];

    % Uses a cosine function shifted by pi, starting at the winter solstice (day=355)
    % Sets minimum value to MLD_min, and maximum value to MLD_max
    MLD0 = 0.5*(SetUp.MLD_min+SetUp.MLD_max) + 0.5*(SetUp.MLD_max-SetUp.MLD_min) * ...
           cos(2*pi*(time0-SetUp.day_min_MLD)/365-pi); 

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.MLD = interpolate_annual_cycle_to_model(time0,MLD0,SetUp.time,int_mode);
 case 3
    %--------------
    % Case (3) : Monthly Climatology from  de Boyer Montegut, 2004 of [yN=38;yS=34;xW=-124;xE=-117];
    % Assumes time si specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];
    MLD0 = [41.2247   38.2636   31.3924   25.7955   19.5287   18.5425   17.7829   18.2620   18.0593   20.7388   26.5198   33.7135];

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.MLD = interpolate_annual_cycle_to_model(time0,MLD0,SetUp.time,int_mode);
 otherwise
    error(['Crazy Town! MLD Off!']);
 end
 
 %-------------------------------
 % dMLD : change in MLD (m/hour)
 %-------------------------------
 % Calculates the rate of change of MLD over time, this will drive the physical evolution 
 % of the system (dilution/concentration)
 % Here calculated this rate based on a forward time difference scheme, consistent with the
 % time-stepping scheme of the integration subroutine
 SetUp.Env.dMLD = nan(1,SetUp.ntime);
 SetUp.Env.dMLD(1,1:end-1) = (SetUp.Env.MLD(1,2:end) - SetUp.Env.MLD(1,1:end-1))/SetUp.dt;
 % Specifes rate of change at last time-step
 % (1) assumes annual cycle: sets last timestep equal to (first - last)
 % (2) assumes continuation: sets last timestep equal to second-to-last
 % (3) assumes no change: 
 iMLDcycle = 2;
 switch iMLDcycle
 case 1
    SetUp.Env.dMLD(end) = (SetUp.Env.MLD(1) - SetUp.Env.MLD(end))/SetUp.dt;
 case 2
    SetUp.Env.dMLD(end) = SetUp.Env.dMLD(end-1);
 case 3
    SetUp.Env.dMLD(end) = 0;
 otherwise
    error(['Crazy Town! dMLD last timestep not specified ']);
 end

 %--------------------------------------------------------------------------------
 % Set Transport at the base of the mixed layer (m/hour)
 % Transport here is defined in units of m/hour, and can be roughly thought to 
 % represent water entering from the base of the mixed layer, and leaving the 
 % mixed layer either at the base (e.g. mixing), or laterally (upwelling)
 switch SetUp.iFlow
 case 1
    % Case (1) : constant Flow
    % Vector of Flow values (defined in each time step):
    % Note conversion here from m/year to m/hour
    SetUp.Env.Flow = SetUp.Flow0/365/24 * ones(1,SetUp.ntime);
 case 2
    %--------------
    % Case (2) : Idealized annual cycle
    % Assumes time is specified in DAYS (later converted to model's hours)
    % Assumes first day is Jan1, corresponding to time0=0
    % Assumes the minimum is at September 21 (day=365)
    % time0 = cumsum([0 31 28 31 30 31 30 31 31 30 31 30]) + ...
    %         round([31 28 31 30 31 30 31 31 30 31 30 31]/2)-1;
    time0 = [15 44 74 104 135 165 196 227 257 288 318 349];

    % Uses a cosine function shifted by pi, starting at the winter solstice (day=355)
    % Sets minimum value to MLD_min, and maximum value to MLD_max
    Flow0 = 0.5*(SetUp.Flow_min+SetUp.Flow_max) + 0.5*(SetUp.Flow_max-SetUp.Flow_min) * ...
           cos(2*pi*(time0-SetUp.day_min_Flow)/365-pi);
    % Conversion here from m/year to m/hour:
    Flow0 = Flow0/365/24;

    %--------------
    % Iterpolation step: interpolate annual cycle onto model time vector
    % including repetiton if multiple years are required
    %int_mode = 'linear';
    int_mode = 'pchip';
    SetUp.Env.Flow = interpolate_annual_cycle_to_model(time0,Flow0,SetUp.time,int_mode);
 otherwise
    error(['Crazy Town! Flow not specified!']);
 end

 %--------------------------------------------------------------------------------

 hab.SetUp = SetUp;

