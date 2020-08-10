 function hab_plot_diagn(hab,name);

 load(char(hab.file))
 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 eps = 1e-10;
 
 % Sets the variables to plot based on the solution hab.Sol
 % (this includes any derived variables added to hab.Sol in postporcessing) 
 varnames = setdiff(fieldnames(hab.Sol),'time','stable');
 % Decides the optimal number of subplot given the # of state variables
 nvar = length(varnames); 
 [nsp, npp] = numSubplots(nvar);
 
 varnames2 = setdiff(fieldnames(var1d),'time','stable');
 nvar2 = length(varnames2);
 year=hab.SetUp.EndTime/365/24;
 
 for indv=1:nvar2
     if ~isempty(strfind(varnames2{indv},'NO3'))
         pos=indv;
     end
 end
 
 for indv=pos:nvar2
     vname = varnames2{indv};
     aux=var1d.(vname);
     if strcmp(vname,'DIATC')==1 | strcmp(vname,'ZOOC')==1 | strcmp(vname,'SPC')==1 | strcmp(vname,'POC_FLUX_IN')==1
         aux=aux*(0.137); %N:C (Redfield = 16/106)
     end
     if length(aux)~=year*12
     var.(vname) = repmat(aux,1,year);
     else
     var.(vname) = aux;
     end
 end
 clear aux
 
daysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31];
monthEnds = [0, cumsum(daysInMonths)];
 for indv=1:nvar
     vname = varnames{indv};
      aux = hab.Sol.(vname);
      if strcmp(vname,'PON')==1 | strcmp(vname,'POFe')==1 | strcmp(vname,'PSi')==1
         aux=aux*(hab.BioPar.wsPOM/3600);        
     end

    
     auy=mean(reshape(aux,24,hab.SetUp.EndTime/24));
     auz=reshape(auy,hab.SetUp.EndTime/24/year,year);
     for i=1:length(monthEnds)-1
         firstDay = monthEnds(i)+1;
         lastDay = monthEnds(i+1);
         auw(i,:)=mean(auz(firstDay:lastDay,:));
     end
     sol.(vname)=reshape(auw,1,numel(auw));
 end
 
 
years=hab.SetUp.EndTime/24/365;
if (isempty(strfind(hab.file,'clim')) | isempty(strfind(hab.file,'CLIM')))
year_in=str2num(hab.file(26:29));
year_out=str2num(hab.file(31:34));
else
year_in=1;
year_out=years*12;
end

scrsz = get(0,'ScreenSize'); % left, bottom, width, height
figure('position',[1 scrsz(4)/100 scrsz(3) scrsz(4)],'visible','off');
 for indv=1:nvar
    vname = varnames{indv};
    tvar = sol.(vname);
    
    vname2 = varnames2{indv+(pos-1)};
    tvar2 = var.(vname2);
    
    subplot(nsp(1),nsp(2),indv)
       plot(1:12*(years),tvar,'-k','linewidth',2)
       hold on
       plot(1:12*(years),tvar2,'-r','linewidth',2)
       title([vname],'fontsize',15);
       axis([1 12*(years) 0.9*min(min([tvar tvar2]))-eps 1.1*max(max([tvar tvar2]))+eps])

       xticks([1:12:years*12])
       xticklabels(num2cell([year_in:year_out]))
       xtickangle(45)	
       
 end
clearvars -except hab sol var var1d xE xW yS yN name
ur8=['/home/marcsandovalb/hab_0d/figures/',name]; 
save([ur8,'.mat'])
set(gcf,'color','w');
img = getframe(gcf);
imwrite(img.cdata, [ur8, '.png']);
