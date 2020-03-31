 function hab_plot_anders(hab,TersFig2,TersFig3)

 Tstart = 0;
 Tend = hab.Sol.time(end)/24;
 
 figure(2) 
 subplot(2,4,1)
    plot(hab.Sol.time/24,hab.Sol.NO3,'-k','linewidth',2)
    title('NO3','fontsize',15);
    axis([Tstart Tend 0 1000])
 subplot(2,4,2)                                     
    plot(hab.Sol.time/24,hab.Sol.Si,'-k','linewidth',2) 
    title('Si','fontsize',15);
    axis([Tstart Tend 0 160])
 subplot(2,4,4)                                     
    plot(hab.Sol.time/24,hab.Sol.Chl,'-k','linewidth',2)
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 200])
 subplot(2,4,5)                                     
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.pDA,'-k','linewidth',2) 
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 0.6])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.dDA,'-k','linewidth',2) 
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 0.8])
    
