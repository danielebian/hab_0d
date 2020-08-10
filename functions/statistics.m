clear all
clc

path='/home/marcsandovalb/hab_0d/figures/';
files={'bmod_const.mat','bmod_flux.mat','bmod_fluxnut.mat','bmod_fluxnut_wout_ryc.mat','bmod_flux_wout_ryc.mat'};
nfiles=length(files);

for i=1:nfiles
    ld(i)=load([path,files{i}]);
end


Tstart = 0;
Tend = ld(1).hab.Sol.time(end)/24;
eps = 1e-10;

% Sets the variables to plot based on the solution hab.Sol
% (this includes any derived variables added to hab.Sol in postporcessing)
varnames = setdiff(fieldnames(ld(1).hab.Sol),'time','stable');
% Decides the optimal number of subplot given the # of state variables
nvar = length(varnames);

varnames2 = setdiff(fieldnames(ld(1).var1d),'time','stable');
nvar2 = length(varnames2);
for indv=1:nvar2
    if ~isempty(strfind(varnames2{indv},'NO3'))
        pos=indv;
    end
end
years=ld(1).hab.SetUp.EndTime/24/365;
if (isempty(strfind(ld(1).hab.file,'clim')) | isempty(strfind(ld(1).hab.file,'CLIM')))
    year_in=str2num(ld(1).hab.file(26:29));
    year_out=str2num(ld(1).hab.file(31:34));
else
    year_in=1;
    year_out=years*12;
end


for indv=1:nvar
    scrsz = get(0,'ScreenSize'); % left, bottom, width, height
    figure('position',[1 scrsz(4)/100 scrsz(3) scrsz(4)],'visible','off');
    aa=0;
    for fl=1:nfiles
        vname = varnames{indv};
        tvar = ld(fl).sol.(vname);
        
        if isempty(strfind(vname,'DA'))==0
            continue
        end
        disp(['working on ',vname,' file: ',ld(fl).name])
        vname2 = varnames2{indv+(pos-1)};
        tvar2 = ld(fl).var.(vname2);
        
        s1=((detrend(tvar))-mean(detrend(tvar)))./(std(detrend(tvar)).*std(detrend(tvar)));
        s2=((detrend(tvar2))-mean(detrend(tvar2)))./(std(detrend(tvar2)).*std(detrend(tvar2)));
        maxlag=round(0.1*length(s1));
        
        r=corr(s1',s2','rows','complete');
        [xr,lags] = nanxcorr_msb(s1',s2',median(1:length(s1))); 
        aux(median(1:length(xr))-maxlag:median(1:length(xr))+maxlag)=xr(median(1:length(xr))-maxlag:median(1:length(xr))+maxlag);
        [~,I]=max(abs(aux));
        xr_var=xr(I);
        lags_var=lags(I);
        
        for m=1:1000
            ser=remuestreo(s1);
            mr(m)=corr(ser',s2','rows','complete');
            [mxr,mlags] = nanxcorr_msb(ser',s2',median(1:length(ser')));
            aux(median(1:length(mxr))-maxlag:median(1:length(mxr))+maxlag)=mxr(median(1:length(mxr))-maxlag:median(1:length(mxr))+maxlag);
            [~,I]=max(abs(aux));
            mxr_var(m)=mxr(I);
            mlags_var(m)=mlags(I);
            clear ser mxr mlags
        end
        
        rango_corr=[prctile(mr,2.5) prctile(mr,97.5)]; 
        if r>=rango_corr(1) & r<=rango_corr(2)
            sig_corr='non-sig.';
        else
            sig_corr='sig.';
        end
        
        x = unique(mlags_var);
        N = numel(x);
        count = zeros(N,1);
        for k = 1:N
            count(k) = sum(mlags_var==x(k));
        end
        
        rango_lag=prctile(count,5);
        if count(x==lags_var)<=rango_lag
            sig_lag='non-sig.';
        else
            sig_lag='sig.';
        end
        
        rango_xcorr=[prctile(mxr_var,2.5) prctile(mxr_var,97.5)]; 
        if xr_var>=rango_xcorr(1) & xr_var<=rango_xcorr(2)
            sig_xcorr='non-sig.';
        else
            sig_xcorr='sig.';
        end
        
        % figure
        for i=2:nfiles
            mini1(i)=min([ld(i).sol.(vname),ld(i).var.(vname2)]);
            maxi1(i)=max([ld(i).sol.(vname),ld(i).var.(vname2)]);
            
            mini2(i)=min([ld(i).sol.(vname)-ld(i).var.(vname2)]);
            maxi2(i)=max([ld(i).sol.(vname)-ld(i).var.(vname2)]);
        end
        
        aa=aa+1;
        subplot(5,3,aa)
        plot(1:12*(years),tvar,'-k','linewidth',2)
        hold on
        plot(1:12*(years),tvar2,'-r','linewidth',2)
        xlim([1 12*(years)])
        xticks([1:12:years*12])
        xticklabels(num2cell([year_in:year_out]))
        xtickangle(45)
        title([vname,' r=',num2str(r),', ',sig_corr],'fontsize',15);
        grid on
        ylim([0.9*min(mini1)-eps,1.1*max(maxi1)+eps])
        if fl==1
        legend('0D','3D')
        end
        
        aa=aa+1;  
        subplot(5,3,aa)
        plot(1:12*(years),tvar-tvar2,'-b','linewidth',2)
        xlim([1 12*(years)])
        xticks([1:12:years*12])
        xticklabels(num2cell([year_in:year_out]))
        xtickangle(45)
        RMSE = sqrt(mean((tvar-tvar2).^2));  % Root Mean Squared Error
        title([ld(fl).name,' 0D-3D, RMSE ', num2str(RMSE)],'fontsize',15,'interpreter','none');
        ylim([-max([abs(min(mini2)) abs(max(maxi2))]) max([abs(min(mini2)) abs(max(maxi2))])])
        grid on
        
        aa=aa+1;
        subplot(5,3,aa)
        h1=plot(lags,xr,'-b','linewidth',2);
        ylim([-1,1])
        grid on
        title(['Cross-Correlation'],'fontsize',15)
        set(gca,'fontsize',12)
        xlabel('Lag','fontsize',12,'fontweight','bold')
        ylabel('Correlation','fontsize',12,'fontweight','bold')
        hold on
        plot(lags_var,xr_var,'.k','markersize',20)
        h2=plot([-maxlag,-maxlag],[-1,1],'r');
        plot([maxlag,maxlag],[-1,1],'r')
        legend([h1;h2],{['r=' num2str(xr_var) ', ' sig_xcorr char(10) 'lag=' num2str(lags_var) ', ' sig_lag],'10% data'},'Location','BestOutside')
        
    end
    ur8=[path,'b',vname]; set(gcf,'color','w');
    img = getframe(gcf);
    imwrite(img.cdata, [ur8, '.png']);
    clc 
    close all
    
end
