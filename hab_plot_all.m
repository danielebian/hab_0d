 function hab_plot_all(hab,varargin);

 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 eps = 1e-10;
 
 % Sets the variables to plot based on the solution hab.Sol
 % (this includes any derived variables added to hab.Sol in postporcessing) 
 varnames = setdiff(fieldnames(hab.Sol),'time','stable');
 % Decides the optimal number of subplot given the # of state variables
 nvar = length(varnames); 
 [nsp, npp] = numSubplots(nvar);

 figure
 for indv=1:nvar; 
    vname = varnames{indv};
    tvar = hab.Sol.(vname);
    
    subplot(nsp(1),nsp(2),indv)
    plot(hab.Sol.time/24,tvar,'-k','linewidth',2)
    hold on
    title([vname],'fontsize',15);
    axis([Tstart Tend 0.9*min(tvar)-eps 1.1*max(tvar)+eps])
 end
