% Adds CMAES subroutine:
 hab_root = '/Users/danielebianchi/AOS1/HAB/code/hab_0d_200116/';
 addpath([hab_root])
 addpath([hab_root 'functions/'])
 addpath([hab_root 'CMA_ES/'])
 addpath([hab_root 'optimization/'])

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
%               'alpha',	'BioPar',	0.012/2,	0.012*2;	...
%               'kmax',		'BioPar',	0.12/2,		0.12*2;	...
%               'mumax',	'BioPar',	0.05/2,		0.05*2;	...
%               'klys',		'BioPar',	0.0016/2,	0.0016*2;	...
%               'kexc',		'BioPar',	0.001/2,	0.001*2;	...
%               'maint',	'BioPar',	0.0004/2,	0.0004*2;	...
%               'sPNRmax',	'BioPar',	0.1/2,		0.1*2;		...
%               'kPNRcat',	'BioPar',	0.06/2,		0.06*2;	...
%               'kDA',		'BioPar',	0.0002/2,	0.0002*2;	...
%               'kass',		'BioPar',	0.06/2,		0.06*2;	...
%               'KNO3',		'BioPar',	0.5/2,		0.5*2;		...
%               'KPO4',		'BioPar',	0.3/2,		0.03*2;	...
%               'KSi',		'BioPar',	0.6/2,		0.6*2;		...
%               'ePNFcost',	'BioPar',	0.8/2,		0.8*2;		...
%               'rNC',		'BioPar',	0.2/2,		0.2*2;		...
%               'rSiC',		'BioPar',	0.2/2,		0.2*2;		...
%               'rPC',		'BioPar',	0.015/2,	0.015*2;	...
%               'rNCDA',	'BioPar',	0.07/2,		0.07*2;	...
                'NO3_0',	'BioPar',	0,		2000;		...
                'Si_0',		'BioPar',	0,		2000;		...
                'PO4_0',	'BioPar',	0,		125;		...
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
 optn.MaxFunEvals = 25000;

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
