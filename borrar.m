clear all
clc
T=10;
Cdiat=linspace(0,3,500);
Czoo=0.01;

Tfunc=2^(0.1*T-3);

betagrzz=1.05; % betagrzz grazing coefficient, used in density dependent grazingmodification mmol C/m 3
betagrzdiatthres=0.02; %Diatom threshold concentration for grazing mmol C/m 3
alphagrzzoodiat=0.3; %Fraction of diatom grazing going to zooplankton no units
lambdamortzoo=0.08; %Zooplankton linear mortality  1/d
lambdamort2zoo=0.42; %Zooplankton quadratic mortality  1/(mmol C m 3 d)
betathres0lzoo=0.03; %Zooplankton threshold concentrations for mortality mmol C/m 3
Jgmaxdiat=1.95; %maximum grazing loss for diatoms 1/d
betagrzdiatthres=betathres0lzoo; %z ≥ -100m

Pprimadiat=max(Cdiat-betagrzdiatthres,0);

betathreslzoo=betathres0lzoo; %z ≥ -100m
Zprimazoo=max(Czoo-betathreslzoo,0);

Jgrzdiat=Jgmaxdiat*Tfunc*((Czoo*Pprimadiat.^2)./(Pprimadiat.^2 + 0.81*(betagrzz^2))); %grazing loss for diatoms mmol C/m 3 /sec

Jgrzdiatzoo=alphagrzzoodiat*Jgrzdiat; % grazed diatoms routed to new zooplankton biomass mmol C/m 3 /sec

Jlzoo=lambdamort2zoo*Tfunc*(Zprimazoo^2)+lambdamortzoo*Tfunc*Zprimazoo;

dCzoodt=Jgrzdiatzoo - Jlzoo;
