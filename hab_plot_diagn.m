 function hab_plot_diagn(hab,var);

 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 eps = 1e-10;
 
 % Sets the variables to plot based on the solution hab.Sol
 % (this includes any derived variables added to hab.Sol in postporcessing) 
 varnames = setdiff(fieldnames(hab.Sol),'time','stable');
 % Decides the optimal number of subplot given the # of state variables
 nvar = length(varnames); 
 [nsp, npp] = numSubplots(nvar);
 
 varnames2 = setdiff(fieldnames(var),'time','stable');
 nvar2 = length(varnames2);
 year=hab.SetUp.EndTime/365/24;
 
 for indv=28:nvar2
     vname = varnames2{indv};
     aux=var.(vname);
     if strcmp(vname,'DIATC')==1 | strcmp(vname,'ZOOC')==1 | strcmp(vname,'SPC')==1
         aux=aux*(0.137); %N:C (Redfield = 16/106)
     end
     var.(vname) = repmat(aux,1,year);
 end
 clear aux
 
 mon=[0,31,28,31,30,31,30,31,31,30,31,30,31];
 for indv=1:nvar
     vname = varnames{indv};
     aux = hab.Sol.(vname);
     auy=mean(reshape(aux,24,hab.SetUp.EndTime/24));
     auz=reshape(auy,year,hab.SetUp.EndTime/24/year);
     for i=1:length(mon)-1
         auw(:,i)=mean(auz(:,mon(i)+1:mon(i)+mon(i+1)),2);
     end
     sol.(vname)=reshape(auw',1,numel(auw));
 end
 
 
 %falta el plot
 
 figure
 for indv=1:nvar
    vname = varnames{indv};
    tvar = sol.(vname);
    
    vname2 = varnames2{indv+27};
    tvar2 = var.(vname2);
    
    subplot(nsp(1),nsp(2),indv)
       plot(1:12*(hab.SetUp.EndTime/24/365),tvar,'-k','linewidth',2)
       hold on
       plot(1:12*(hab.SetUp.EndTime/24/365),tvar2,'-r','linewidth',2)
       title([vname],'fontsize',15);
       axis([1 12*(hab.SetUp.EndTime/24/365) 0.9*min(min([tvar tvar2]))-eps 1.1*max(max([tvar tvar2]))+eps])
 end