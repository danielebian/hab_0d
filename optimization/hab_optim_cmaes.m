% Adds CMAES subroutine:
 hab_root = '/Users/danielebianchi/AOS1/HAB/code/hab_0d_master/';
 addpath([hab_root])
 addpath([hab_root 'functions/'])
 addpath([hab_root 'optimization/'])
 addpath([hab_root 'optimization/cma_es/'])

% Handles output directory
% Folder name (will add date to it)
 OptName = 'Optimization_Test_chemostat_series_v1';
% Long name for the optimization (will be saved in output structure)
 OptNameLong = 'Test optimization';
 curdir = pwd;
 DateNow = hab_getDate();
% creates folder for CMAES output
 savedir = ['cmaes_out_' DateNow '_' OptName];
 mkdir([hab_root 'optimOut'],savedir);
 cd([hab_root 'optimOut/' savedir]);

%-------------------------------------------------------------------
% Specifies Cost Function:
% -------------------------
% This determines the setup and type of experiment(s) run, and what cost
% function is calculated for the optimization
% Note that all the details will be in the cost function, which can be used to run
% all sorts of configurations, as long as it produces a single "cost" number in the end 
% (e.g. it can run individual batches, chemostats, series of chemostats etc.)
% -------------------------
% Optimization of batch experiments based on Fehling Si-limited data:
%FunName = 'optim_minimize_batch_SiLim';
% -------------------------
% Optimization of Kudela's series of chemostat experiments, using the data
% in /data/chemostat_data_kudela_v1.xlsx;
 FunName = 'optim_minimize_chemostat_series';
%-------------------------------------------------------------------
% Parallelization:
% -------------------------
% iParallel = 0 : runs on a single processor, or in series
% iParallel = 1 : uses parallel capability of CMAES algorithms
%                 NOTE: this will call a parallelized version of the cost function
%                 which evaluates multiple costs simulataneoulsy
 iParallel = 0;
%-------------------------------------------------------------------

% Matrix of parameters for optimization
% Format: 	name 		module		min_value 	max_value	
 AllParam = {
                'beta',		'BioPar',	0.1*0.137/10,	0.1*0.137*10;	...
                'gamma',	'BioPar',	2/5,		2*5;		...
%               'rSiC',		'BioPar',	0.2/2,		0.2*2;		...
%               'rPC',		'BioPar',	0.015/2,	0.015*2;	...
%               'rNCDA',	'BioPar',	0.07/2,		0.07*2;	...
%               'NO3_0',	'BioPar',	0,		2000;		...
%               'Si_0',		'BioPar',	0,		2000;		...
%               'PO4_0',	'BioPar',	0,		125;		...
                };

 ParNames = AllParam(:,1);
 ParModule = AllParam(:,2);
 nPar = size(ParNames,1); % number of parameters

 ParMin = [AllParam{:,3}]';
 ParMax = [AllParam{:,4}]';

% Initialize final output structure
 Optim.OptName = OptName;
 Optim.OptNameLong = OptNameLong;
 Optim.SaveDir = savedir;
 Optim.ParNames = ParNames;
 Optim.ParModule = ParModule;
 Optim.ParMin = ParMin;
 Optim.ParMax = ParMax;

% NOTES: 
% (1) Parameters are normalized by subtracting the min and dividing by
%     a normalization factor, typically the range (so they are b/w 0-1)
%     This is done to allow the CMAES algorithm to work in the space [0 1]
% (2) If needed, remember to add  constraints on multiple parameter inter-dependencies:
%     This should be done outside this routine, probably in the first step of 
%     cost function calculation as an ad-hoc constraint (removes one degree of freedom)
% Calculates useful quantities for normalization, optimization, etc.
 ParMean = (ParMin + ParMax)/2';
 ParRange = ParMax - ParMin;
 ParNorm = ParRange;
 ParStart = (ParMean - ParMin) ./ ParNorm;
%ParStart = rand(nPar,1);
 ParSigma = ParRange./ParNorm/sqrt(12);

% Options
 optn.EvalParallel = num2str(iParallel);
 optn.LBounds = (ParMin - ParMin) ./ ParNorm;
 optn.UBounds = (ParMax - ParMin) ./ ParNorm;
 optn.MaxFunEvals = 5000;

% Enables parallelization
% Note, the # of cores should be the same as the population size of the CMAES: 
% Popul size: 4 + floor(3*log(nPar))
 if strcmp(optn.EvalParallel,'1')
    FunName = [FunName '_parallel'];
    delete(gcp('nocreate'))
    % Specifies the number of individual cores needed for parrallelization
    % This should match the number of independent calls for each instance of CMAES 
   %nproc = 12;
    nproc = 4 + floor(3*log(nPar));
    ThisPool = parpool('local',nproc);
 end

 FunArg.ParNames = ParNames;
 FunArg.ParMin = ParMin;
 FunArg.ParNorm = ParNorm;
 FunArg.ParModule = ParModule;

% Runs the optimization
 tic;
 [pvarout, pmin, counteval, stopflag, out, bestever] = cmaes(FunName,ParStart,ParSigma,optn,FunArg);

% Stops parallel pool
 if strcmp(optn.EvalParallel,'1')
    delete(ThisPool);
 end

% Fills in some output in final structure
% NOTE: instead of saving last iteration, saves best solution
 % Renormalized parameters
 Optim.ParOpt = ParMin + ParNorm .* bestever.x;
 Optim.ParNorm = ParNorm;
 Optim.cmaes.options = optn; 
 Optim.cmaes.pvarout = bestever.x; 
 Optim.cmaes.pmin = bestever.f; 
 Optim.cmaes.counteval = counteval; 
 Optim.cmaes.stopflag = stopflag; 
 Optim.cmaes.out = out; 
 Optim.cmaes.bestever = bestever; 
 Optim.RunTime = toc;
 % Runs and save best BGC1D parameters
%Optim.hab = hab_run_Optim(Optim);

% Save ga output using today's date
 save(['Optim_' DateNow '_' OptName '.mat'],'Optim');
 cd(curdir)
