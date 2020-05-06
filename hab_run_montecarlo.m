 %-------------------------------------------------------
 % Adds path for local functions
 addpath ./functions
 %-------------------------------------------------------
 % All experiments will be saved in the OutDir folder
 OutDir = './output_montecarlo_test2';
 OutName = 'Montecarlo_test';
 % Create directories for storing output
 if ~(exist(OutDir)==7)
    mkdir(OutDir)
 end
 %-------------------------------------------------------
 % Note: need to use rand to generate random numbers
 % and be able to re-set a different seed each run
 % Re-seeds the random number generator stresm
 rstate = round(sum(clock));
 disp(['Random Seed: ' num2str(rstate)]);
 rand('state',rstate);
 %-------------------------------------------------------

 %-------------------------------------------------------
 % Initialize the model
 % Based on the code and options in hab_main.m
 %-------------------------------------------------------
 clear hab_base;

 % Biological module
 %hab.BioModule = 'anderson';
  hab_base.BioModule = 'terseleer';

 % Experimental setup
 %hab.ExpModule = 'batch';
 %hab.ExpModule = 'chemostat';
  hab_base.ExpModule = 'mixed_layer';

 % Here, if needed, overrides default parameters for BioModules and SetUp
 % All Suite experiments will adopt these parameters
 % (use ['property',value] format)
 % NOTE: these should be variables not used as Suite Parameters
 new_BioPar = {'NO3_0',16,'Si_0',16,'PO4_0',1};
 new_SetUp = {};

 %-------------------------------------------------------
 % Montecarlo simulation parameters
 % input structure is: 
 % {'name', 'module', 'mean', 'std', 'distribution'} 
 % Possible modules are:
 % {'BioPar','SetUp'}
 % possible distributions are:
 % {'uniform','gaussian','gamma'}
 % For uniform, the range will be 2x the standard deviation defined here

 MParams = {
            'kmax',		'BioPar',	0.12,		0.06,		'uniform'
            'mumax',		'BioPar',       0.05,		0.025,		'uniform'
            'kwPAR',		'SetUp',	0.04,		0.01,		'gaussian'
            'MLD_max',		'SetUp',	70,		40,		'uniform'
           };

 nparam = size(MParams,1);
 parnames = MParams(:,1)';
 % Maximum number of runs
 nruns = 10;
 %-------------------------------------------------------

 %-------------------------------------------------------
 % Starts the series of MonteCarlo runs
 %-------------------------------------------------------
 for indr=1:nruns

    % Baseline run setup
    hab = hab_base;

    %---------------------
    % Here, creates the input arguments for bio module and experiment setup
    % (includes any overridden parameters in new_BioPar and new_SetUp)
    arg_BioPar = new_BioPar;
    arg_SetUp = new_SetUp;

    % Loops through all parameters and assigns random values
    for indp=1:nparam
       ParName = MParams{indp,1};
       ProbFun = lower(MParams{indp,5});
       ParMean = abs(MParams{indp,3});
       ParStd  = abs(MParams{indp,4});
       ParSign = sign(MParams{indp,3});
       %--------------------------------------------------------
       % Deals with variable sign by applying it at the end
       rndgen = rand(1);
       switch lower(ProbFun)
       case {'uniform'}
           ParLow = ParMean - ParStd;
           ParHig = ParMean + ParStd;
           ThisPar = ParSign * (ParLow + rndgen * (ParHig-ParLow));
       case {'gauss','gaussian','norm','normal'}
           ThisPar = ParSign * (norminv(rndgen,ParMean,ParStd));
       case {'gamma'};
           ParShape = ParMean.^2/ParStd.^2;
           ParScale = ParStd.^2/ParMean;
           ThisPar = ParSign * (gaminv(rndgen,ParShape,ParScale));
       otherwise
           error([ProbFun ' distribution not implemented']);
       end
       %--------------------------------------------------------
       switch MParams{indp,2}
       case 'BioPar'
          arg_BioPar = [arg_BioPar parnames(indp) ThisPar];
       case 'SetUp'
          arg_SetUp = [arg_SetUp parnames(indp) ThisPar];
       otherwise
          error(['module ' Suite.module{ipar}  ' is not valid']);
       end
    end   % indp - parrameter assignement

    % Creates an unique random name for individual run output
    ThisClock = clock;
    ThisDate  = datestr(now,'mmm-dd-yy');
    RndNum    = num2str(unidrnd(8999,[1 1])+1000); 
    ThisName = [ 'bgc_' ThisDate '-' num2str(ThisClock(4)) 'h' num2str(ThisClock(5)) 'm' '-r' RndNum];

    %---------------------
    % Initialized Biomodule with user-defined inputs
    switch hab.BioModule
    case 'anderson'
       hab = hab_biopar_anders(hab,arg_BioPar{:});
    case 'terseleer'
       hab = hab_biopar_tersel(hab,arg_BioPar{:});
    otherwise
       error(['Crazy town! (biological case not found)']);
    end

    % Initialized SetUp with user-defined inputs
    switch hab.ExpModule
    case 'batch'
       hab = hab_setup_batch(hab,arg_SetUp{:});
    case 'chemostat'
       hab = hab_setup_chemo(hab,arg_SetUp{:});
    case 'mixed_layer'
       hab = hab_setup_mixed(hab,arg_SetUp{:});
    otherwise
       error(['Crazy town! (experiment case not found)']);
    end
    %---------------------
    % Runs the model
    disp(['Running ... ' num2str(indr) '/' num2str(nruns)]);
    hab = hab_integrate(hab);
    % Postprocess the result
    hab = hab_postprocess(hab);
 
    % Saves Output
    disp(['Saving ... ' OutDir '/' OutName '-' ThisName]);
    save([OutDir '/' OutName '-' ThisName],'hab');
    
 end   % indr - single runs

 % To load all files in a dir:
 % dirData=dir('*.mat');
 % filenames={dirData.name};
 % stringi=filenames;   
 % stringi

