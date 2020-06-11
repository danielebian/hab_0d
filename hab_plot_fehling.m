 function hab_plot_all(hab,varargin);

 %--------------------------------------------------------------------------------
 A.limnut = 'Si';	% Si: Si-limited batch culture data
			% N: N-limited batch culture data
 %--------------------------------------------------------------------------------
 % Here performs any substitution of default parameters based on user input (varargin)
 A = parse_pv_pairs(A,varargin);
 %--------------------------------------------------------------------------------

 switch A.limnut
 case 'Si'
    tmp = load(['./data/DataTersSiLim.mat']);
    data = tmp.DataTersSiLim;
 case 'N'
    tmp = load(['./data/DataTersNLim.mat']);
    data = tmp.DataTersNLim;
 otherwise
    error(['Data not found']);
 end


 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 eps = 1e-10;
 
 % Sets the variables to plot based on the solution hab.Sol
 % (this includes any derived variables added to hab.Sol in postporcessing) 
 varnames = setdiff(fieldnames(hab.Sol),'time','stable');

 % Finds the variables in common wit the data structure
 varplot = intersect(varnames,fieldnames(data));

 % Decides the optimal number of subplot given the # of state variables
 nvar = length(varplot); 
 [nsp, npp] = numSubplots(nvar);

 figure
 for indv=1:nvar; 
    vname = varplot{indv};
    tvar = hab.Sol.(vname);
    
    subplot(nsp(1),nsp(2),indv)
    plot(hab.Sol.time/24,tvar,'-k','linewidth',2)
    hold on
    title([vname],'fontsize',15);
    axis([Tstart Tend 0.9*min(tvar)-eps 1.1*max(tvar)+eps])
    if isfield(data,vname)
       hold on
       ovar = data.(vname);
       plot(data.([vname 'Time'])/24,ovar,'.r','markersize',20);
       eps = 1e-15;
       ylim([min([tvar(:);ovar(:)])-eps max([tvar(:);ovar(:)])+eps]);
    end
 end
