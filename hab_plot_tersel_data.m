 function hab_plot_tersel_data(hab)

 addpath /Users/danielebianchi/AOS1/HAB/code/hab_0d_200116/data/

 load TersFig2Data;
 load TersFig3Data;

 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 psize = 10;

 figure
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
    plot(hab.Sol.time/24,hab.Sol.Chl,'-k','linewidth',2)
    hold on
    scatter(TersFig2.ChlTime,TersFig2.Chl,psize,'filled','r')
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.Chl)])
 subplot(2,4,5)                                     
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    hold on
    scatter(TersFig3.TDATime,TersFig3.TDA,psize,'filled','r')
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.tDA)])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.pDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.PDATime,TersFig3.PDA,psize,'filled','r')
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.pDA)])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.dDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.DDATime,TersFig3.DDA,psize,'filled','r')
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.dDA)])
