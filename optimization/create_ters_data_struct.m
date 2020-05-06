
 load ./data/TersFig2Data;
 load ./data/TersFig3Data;

 DataTersSiLim.var = {'Si','PO4','NO3','Chl','pDA','dDA'};

 % Note:
 % (1) convert times from days to hours

 DataTersSiLim.Si = TersFig2.Si;
 DataTersSiLim.SiTime = TersFig2.SiTime * 24;

 DataTersSiLim.PO4 = TersFig2.P;
 DataTersSiLim.PO4Time = TersFig2.PTime * 24;

 DataTersSiLim.NO3 = TersFig2.N;
 DataTersSiLim.NO3Time = TersFig2.NTime * 24;

 DataTersSiLim.Chl = TersFig2.Chl;
 DataTersSiLim.ChlTime = TersFig2.ChlTime * 24;

 DataTersSiLim.pDA = TersFig3.PDA;
 DataTersSiLim.pDATime = TersFig3.PDATime * 24;

 DataTersSiLim.dDA = TersFig3.DDA;
 DataTersSiLim.dDATime = TersFig3.DDATime * 24;

 save DataTersSiLim DataTersSiLim

 


