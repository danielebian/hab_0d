% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template HAB_0D runscript 
% Versions: 0.1 : D. Bianchi, A. Moreno, 11-13-2019
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Some documentation will follow:
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Adds path for local functions
 addpath ./functions

 % Initialize the model
 clear hab;
 %close all;
 
 % Biological module
 % Options:
 % 'anderson' : Clarissa Anderson simple PN/DA model
 % 'terseleer' : Terseleer Based on 2013 Paper
 %hab.BioModule = 'anderson';
%  hab.BioModule = 'terseleer';
%   hab.BioModule = 'bec_diat';
  hab.BioModule = 'bec_bec_full';

 % Experimental setup
 % Options:
 % 'batch' : models a batch culture
 % 'chemostat' : models a chemostat setup
 % 'mixed_layer' : models a mixed layer setup
%   hab.ExpModule = 'batch';
 %hab.ExpModule = 'chemostat';
 hab.ExpModule = 'mixed_layer';

 % Here, if needed, overrides default parameters for BioModules and SetUp
 % The experiment will adopt these parameters, overriding defaults
 % (use ['property',value] format)
 % (leave an empty cell array {} for default)
 new_BioPar = {};
 % new_BioPar = {'NO3_0',16,'Si_0',16,'PO4_0',1};
 new_SetUp = {};

 % Initialize biological parameters
 switch hab.BioModule
 case 'anderson'
    hab = hab_biopar_anders(hab,new_BioPar{:});
 case 'terseleer'
    hab = hab_biopar_tersel(hab,new_BioPar{:});
 case 'bec_diat'
    hab = hab_biopar_bec_diat(hab,new_BioPar{:});
 case 'bec_bec_full'
    hab = hab_biopar_bec_full(hab,new_BioPar{:});
 otherwise
    error(['Crazy town! (biological case not found)']);
 end

 % Setup experiment type (e.g. batch, chemostat, etc.)
 switch hab.ExpModule
 case 'batch'
    hab = hab_setup_batch(hab,new_SetUp{:});
 case 'chemostat'
    hab = hab_setup_chemo(hab,new_SetUp{:});
 case 'mixed_layer'
    hab = hab_setup_mixed(hab,new_SetUp{:});
 otherwise
    error(['Crazy town! (experiment case not found)']);
 end

 % Run the model
 hab = hab_integrate(hab);

 % Some postprocessing
 hab = hab_postprocess(hab);

 % Plotting
 iplot = 1;
 if (iplot)
    switch hab.BioModule
    case 'anderson'
      %hab_plot_anders(hab); %Plot model
       hab_plot_all(hab); %Plot model
    case 'terseleer'
      %hab_plot_tersel(hab); %Plot model
       hab_plot_all(hab); %Plot model
    case 'bec_diat'
       hab_plot_all(hab); %Plot model
    case 'bec_bec_full'
       hab_plot_all(hab); %Plot model
    otherwise
       error(['Crazy town! (Processing not found)']);
    end
 end

%mass conservation

varnames = setdiff(fieldnames(hab.Sol),'time','stable');
suma=0;
for indv=1:hab.BioPar.nvar 
    vname = varnames{indv};
    suma= suma +hab.Sol.(vname);
end
plot(suma)

%peaks year 2-3

time=datenum(2001,1,1,hab.SetUp.time,0,0);

figure
subplot 611
plot(time((24*365 +1):2*(24*365)),hab.Sol.NO3((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.Sol.NO3(2*(24*365) +1:3*(24*365)))
title('NO3')
grid on
datetick('x','m')
subplot 612
plot(time((24*365 +1):2*(24*365)),hab.Sol.DiChl((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.Sol.DiChl(2*(24*365) +1:3*(24*365)))
title('DiChl')
grid on
datetick('x','m')
subplot 613
plot(time((24*365 +1):2*(24*365)),hab.Sol.DiN((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.Sol.DiN(2*(24*365) +1:3*(24*365)))
title('DiN')
grid on
datetick('x','m')
subplot 614
plot(time((24*365 +1):2*(24*365)),hab.Sol.ZN((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.Sol.ZN(2*(24*365) +1:3*(24*365)))
title('ZN')
grid on
datetick('x','m')
subplot 615
plot(time((24*365 +1):2*(24*365)),hab.SetUp.Env.Flow((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.SetUp.Env.Flow(2*(24*365) +1:3*(24*365)))
title('Flow')
grid on
datetick('x','m')
subplot 616
plot(time((24*365 +1):2*(24*365)),hab.SetUp.Env.MLD((24*365 +1):2*(24*365)))
hold on
plot(time(2*(24*365) +1:3*(24*365)),hab.SetUp.Env.MLD(2*(24*365) +1:3*(24*365)))
set(gca,'ydir','reverse')
title('MLD')
datetick('x','m')
