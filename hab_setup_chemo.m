 function hab = hab_setup_chemo(hab,varargin)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HAB_0D initialization of experiment setup
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add documentation here:
% Simulates a batch culture with initial nutrients concentrations and constant conditions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %--------------------------------------------------------------------------------
 % First define all CONSTANT parameters
 %--------------------------------------------------------------------------------

 %-------------------------------
 % General setup
 SetUp.StartTime = 0*24;	% Duration of batch culture (hours)
 SetUp.EndTime = 30*24;	% Duration of batch culture (hours)
 SetUp.dt = 0.1;		% timestep (hours)

 %-------------------------------
 % Chemostat setup
 SetUp.Vol = 1;			% Volume of the culture (m3)
 SetUp.Flow = 1 * 0.3391/24;	% Flow rate in the chemostat (m3/h)

 %-------------------------------
 % Define the type and properties of light forcing
 SetUp.iLight = 1;	% Case (1) : constant light
			% Case (2) : 12:12 light:darkness cycles
 SetUp.MaxPAR = 60;  	% Photosynthetially Available Radiation umol/m2/s  

 %-------------------------------
 % Define the type and properties of light forcing
 SetUp.iTemp = 1;      % Case (1) : constant light
                       % Case (2) : variable temp (to be implemented if needed)
 SetUp.TempRef = 15;   % Temperature of the batch colture

 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 SetUp = parse_pv_pairs(SetUp,varargin);
 %--------------------------------------------------------------------------------

 %--------------------------------------------------------------------------------
 % Second, define/process derived variables
 %--------------------------------------------------------------------------------

 % Environmental conditions
 % add here any environmental conditions, use the time vector for time dependent
 % variables (e.g. light, or temperature)
 SetUp.evarnames = {'PAR','Temp'};
 SetUp.nevar = length(SetUp.evarnames);

 % Time vector
 SetUp.time = [SetUp.StartTime:SetUp.dt:SetUp.EndTime];
 SetUp.ntime = length(SetUp.time);

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
 otherwise
    error(['Crazy Town! Lights Off!']);
 end

 %--------------------------------------------------------------------------------
 % Set temperature conditions
 switch SetUp.iTemp
 case 1
    % Case (1) : constant temperature
    % Vector of light values (defined in each time step):
    SetUp.Env.Temp = SetUp.TempRef * ones(1,SetUp.ntime);
 otherwise
    error(['Crazy Town! Tempearture Off!']);
 end

 hab.SetUp = SetUp;

