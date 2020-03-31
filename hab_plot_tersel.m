 function hab_plot_tersel(hab,TersFig2,TersFig3)

 Tstart = 0;
 Tend = hab.Sol.time(end)/24;

 figure
 subplot(2,4,1)
    plot(hab.Sol.time/24,hab.Sol.NO3,'-k','linewidth',2)
    hold on
    title('NO3','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.NO3)])
 subplot(2,4,2)                                     
    plot(hab.Sol.time/24,hab.Sol.Si,'-k','linewidth',2) 
    hold on
    title('Si','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.Si)])
 subplot(2,4,3)                                    
    plot(hab.Sol.time/24,hab.Sol.PO4,'-k','linewidth',2)
    hold on
    title('PO4','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.PO4)])
 subplot(2,4,4)                                     
    plot(hab.Sol.time/24,hab.Sol.Chl,'-k','linewidth',2)
    hold on
    title('Chl','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.Chl)])
 subplot(2,4,5)                                     
    plot(hab.Sol.time/24,hab.Sol.tDA,'-k','linewidth',2)
    hold on
    title('total DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.tDA)])
 subplot(2,4,6)                                     
    plot(hab.Sol.time/24,hab.Sol.pDA,'-k','linewidth',2) 
    hold on
    title('particulate DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.pDA)])
 subplot(2,4,7)                                     
    plot(hab.Sol.time/24,hab.Sol.dDA,'-k','linewidth',2) 
    hold on
    title('dissolved DA','fontsize',15);
    axis([Tstart Tend 0 1.1*max(hab.Sol.dDA)])
