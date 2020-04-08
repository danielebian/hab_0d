 function hab_plot_anders(hab,TersFig2,TersFig3)
 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 size = 10;
 
 figure(2) 
 subplot(2,4,1)
    plot(hab.Sol.time/24,hab.Sol.NO3,'-k','linewidth',2)
     hold on
    scatter(TersFig2.NTime,TersFig2.N,size,'filled','r')
    title('NO3','fontsize',15);
    axis([Tstart Tend 0 1000])
 subplot(2,4,2)                                     
    plot(hab.Sol.time/24,hab.Sol.Si,'-k','linewidth',2) 
    hold on
    scatter(TersFig2.SiTime,TersFig2.Si,size,'filled','r')
    title('Si','fontsize',15);
    axis([Tstart Tend 0 160])
 subplot(2,4,4)                                     
    plot(hab.Sol.time/24,hab.Sol.Chl,'-k','linewidth',2)
    hold on
    scatter(TersFig2.ChlTime,TersFig2.Chl,size,'filled','r')
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 200])
 subplot(2,4,5)                                     
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    hold on
    scatter(TersFig3.TDATime,TersFig3.TDA,size,'filled','r')
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.pDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.PDATime,TersFig3.PDA,size,'filled','r')
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 0.6])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.dDA,'-k','linewidth',2) 
    hold on
    scatter(TersFig3.DDATime,TersFig3.DDA,size,'filled','r')
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 0.8])
    
    
