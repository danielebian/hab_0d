% Adds CMAES subroutine:
 hab_root = '/Users/allisonmoreno/Documents/UCLA/HABProject/hab_0d/';
 addpath(hab_root)
 addpath([hab_root 'functions/'])
 addpath([hab_root 'optimization/cma_es/'])
 addpath([hab_root 'optimization/'])
 addpath([hab_root 'data/'])
% Handles output directory
 OptName = 'Optimization_Test_initial_concentr_v2';
 OptNameLong = 'Test optimization';
 curdir = pwd;
 DateNow = hab_getDate();
% creates folder for CMAES output
 savedir = ['cmaes_out_' DateNow '_' OptName];
 mkdir([hab_root 'optimOut'],savedir);
 cd([hab_root 'optimOut/' savedir]);

% Matrix of parameters for optimization
% Format: 	name 		module		min_value 	max_value	
 AllParam = {
                'muMaxDi',	'BioPar',	0.0312/2,	0.0312*2;	...
                'aLightDi',	'BioPar',	0.0017/2,	0.0017*2;	...
                'QNChlDi',	'BioPar',	4/2,		4*2;	...
                'lMortDi',	'BioPar',	0.0062/2,	0.0062*2;	...
                'beta',		'BioPar',	0.0137/2,	0.0137*2;	...
                'gamma',	'BioPar',	2/2,        2*2; ...	
%                 'NO3_0',	'BioPar',	974/2,		974*2;		...
%                 'Si_0',		'BioPar',	136/2,		136*2;		...
%                 'PO4_0',	'BioPar',	16.3/2,		16.3*2;		...
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
 optn.EvalParallel = '0';
 optn.LBounds = (ParMin - ParMin) ./ ParNorm;
 optn.UBounds = (ParMax - ParMin) ./ ParNorm;
 optn.MaxFunEvals = 5000;

% Enables parallelization
% Note, the # of cores should be the same as the population size of the CMAES: 
% Popul size: 4 + floor(3*log(nPar))
 if strcmp(optn.EvalParallel,'1')
    FunName = 'optim_minimize_batch_SiLim_parallel';
    delete(gcp('nocreate'))
    nproc = 12;
    ThisPool = parpool('local',nproc);
 else
    FunName = 'optim_minimize_batch_SiLim';
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
