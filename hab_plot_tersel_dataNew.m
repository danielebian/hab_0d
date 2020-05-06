 function hab_plot_tersel_dataNew(hab)

 addpath /Users/allisonmoreno/Documents/UCLA/HABProject/hab_0d/data/

 load TersFig2Data.mat;
 load TersFig3Data.mat;
 
 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 psize = 10;

 figure(1)
 subplot(2,4,1)
    plot(hab.Sol.time/24,hab.Sol.NO3,'-k','linewidth',2)
    hold on
    scatter(TersFig2.NTime,TersFig2.N,psize,'filled','r')
    title('NO3','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.NO3)])
 subplot(2,4,2)                                     
    plot(hab.Sol.time/24,hab.Sol.Si,'-k','linewidth',2) 
    hold on
    scatter(TersFig2.SiTime,TersFig2.Si,psize,'filled','r')
    title('Si','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.Si)])
 subplot(2,4,3)                                    
    plot(hab.Sol.time/24,hab.Sol.PO4,'-k','linewidth',2)
    hold on
    scatter(TersFig2.PTime,TersFig2.P,psize,'filled','r')
    title('PO4','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.PO4)])
 subplot(2,4,4)                                     
    plot(hab.Sol.time/24,hab.Sol.DiChl,'-k','linewidth',2)
    hold on
    scatter(TersFig2.ChlTime,TersFig2.Chl,psize,'filled','r')
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.DiChl)])
 subplot(2,4,5)                                     
    hab.Sol.tDA = hab.Sol.DiDA + hab.Sol.DDA + hab.Sol.PDA;    
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    hold on
    scatter(TersFig3.TDATime,TersFig3.TDA,psize,'filled','r')
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.tDA)])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.PDA+hab.Sol.DiDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.PDATime,TersFig3.PDA,psize,'filled','r')
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.PDA+hab.Sol.DiDA)])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.DDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.DDATime,TersFig3.DDA,psize,'filled','r')
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.DDA)])

addpath /Users/allisonmoreno/Documents/UCLA/HABProject/hab_0d/data/
load DataTersPLim.mat; 
    Tstart = 0;
    Tend = hab.Sol.time(end)/24;
    psize = 10;

    figure(2)
 subplot(2,4,1)
    plot(hab.Sol.time/24,hab.Sol.NO3,'-k','linewidth',2)
    %hold on
    %scatter(DataTersPLim.NO3Time,DataTersPLim.NO3,psize,'filled','r')
    title('NO3','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.NO3)])
 subplot(2,4,2)                                     
    plot(hab.Sol.time/24,hab.Sol.Si,'-k','linewidth',2) 
    hold on
    scatter(DataTersPLim.SiTime,DataTersPLim.Si,psize,'filled','r')
    title('Si','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.Si)])
 subplot(2,4,3)                                    
    plot(hab.Sol.time/24,hab.Sol.PO4,'-k','linewidth',2)
    hold on
    scatter(DataTersPLim.PO4Time,DataTersPLim.PO4,psize,'filled','r')
    title('PO4','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.PO4)])
 subplot(2,4,4)                                     
    plot(hab.Sol.time/24,hab.Sol.DiChl,'-k','linewidth',2)
    hold on
    scatter(DataTersPLim.ChlaTime,DataTersPLim.Chla,psize,'filled','r')
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.DiChl)])
 subplot(2,4,5)                                     
    hab.Sol.tDA = hab.Sol.DiDA + hab.Sol.DDA + hab.Sol.PDA;    
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    hold on
    scatter(DataTersPLim.TDATime,DataTersPLim.TDA,psize,'filled','r')
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.tDA)])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.PDA+hab.Sol.DiDA,'-k','linewidth',2) 
    hold on
    scatter(DataTersPLim.pDATime,DataTersPLim.pDA,psize,'filled','r')
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.PDA+hab.Sol.DiDA)])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.DDA,'-k','linewidth',2) 
    hold on
    scatter(DataTersPLim.dDATime,DataTersPLim.dDA,psize,'filled','r')
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.DDA)])
