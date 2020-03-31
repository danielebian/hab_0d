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
 SetUp.EndTime = 5*365*24;	% Duration of batch culture (hours)
 SetUp.dt = 1.0;		% timestep (hours)

 %-------------------------------
 % Light attenuation in the Mixed Layer, including "self-shading"
 % Add the biomass-dependent PAR attenuation in the Biological module
 SetUp.kwPAR = 0.04; 	% pure water PAR attenuation (1/m) 
 SetUp.nzPAR = 100;	% Number of vertical grid points for
			% depth-dependent light calculations

 %-------------------------------
 % Define the type and properties of surface light forcing
 SetUp.iLight = 3;	% 1: Constant light 
			% 2: 12:12 light:darkness cycles
			% 3: Idealized annual cycle
 % Parameters:
 SetUp.MaxPAR = 120;  	% Max PAR for cases 1,2
			% PAR: Photosynthetially Available Radiation umol/m2/s 
 % For case 3, Idealized annual cycle:
 SetUp.day_min_PAR = 355;	% Day of the year with minimum light (e.g. Dec. 21st)
 SetUp.PAR_min = 60;	% Photosynthetially Available Radiation umol/m2/s   
 SetUp.PAR_max = 180; 	% Photosynthetially Available Radiation umol/m2/s  

 %-------------------------------
 % Define the type and properties of ML temperature 
 SetUp.iTemp = 2;	% 1: Constant temperature 
			% 2: Idealized annual cycle
 % Parameters:
 SetUp.TempRef = 15;  	% Temperature for case 1
 % For case 3, Idealized annual cycle:
 SetUp.day_min_Temp = 355;	% Day of the year with minimum temperature (e.g. Dec. 21st)
 SetUp.Temp_min = 5;	% Min temp (C)
 SetUp.Temp_max = 20; 	% Max temp (C)

 %-------------------------------
 % Define the type and properties of MLD dynamics
 SetUp.iMLD = 2;	% 1: Constant MLD
			% 2: Idealized annual cycle
 % Parameters:
 SetUp.MLD0 = 40;  	% Mixed layer depth (m)
 SetUp.day_min_MLD = 265;	% Day of the year with minimum MLD (e.g. Sept. 21st)
 SetUp.MLD_min = 20;	% MLD (m)
 SetUp.MLD_max = 70; 	% MLD (m)

 %-------------------------------
 % Define the type and properties of mixing/upwelling flow
 SetUp.iFlow = 1;	% 1: constant flow
 SetUp.Flow0 = 100;  % Rate of water flow at base of ML (m/year) (typically 100-1000?)

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
    % Case (3) : Idealized annual cycle
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
 otherwise
    error(['Crazy Town! Flow not specified!']);
 end

 %--------------------------------------------------------------------------------

 hab.SetUp = SetUp;

