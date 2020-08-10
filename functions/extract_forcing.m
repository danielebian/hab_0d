%Script to get the forcings for one year or yearly climatology
%for the 0D hab model from the 3D BEC model.
%Requires function: build_path.m, zlevs4.m, sw_dens.m, vinterp.m
% Marco Sandoval Belmar
% 07/20/2020

clear all
clc
addpath(genpath(['/home/marcsandovalb/Roms_tools_old']))
addpath(genpath(['/home/marcsandovalb/matlab_scripts']))

%% Paths and domain

path_files='/data/project4/kesf/ROMS/USW4_082018/'; % path of the outputs you want to work. Usually is something like: /data/project4/kesf/ROMS/USW4_082018/
work_path='/home/marcsandovalb/hab_0d/forcings/'; %path where is your mld file (.mat) [2D matrix in the domain you'll select] and you want to save the final 1D variables.
type='CLIM' % or 'clim'. Note, this is the type of output and the name of the folder.
simu='usw42'; % type/name of simulation. usw42=4km, ussw1=1km,
year='_1997_2007';%'2000'; % if you chose 'clim', then you have to put '_1997_2007'
month=sprintf('%02d',1); %do not worry for this.

[avg_name,flux_name]=build_path(path_files,type,simu,year,month);

%
% Selecting your domain
%
yN=35;
yS=33.63;
xW=-121.42;
xE=-118.9;

%% ROMS_grid
grid_name=[path_files,'grid/roms_grd.nc'];

lon_rho=permute(ncread(grid_name,'lon_rho'),[2 1]); %eta_rho, xi_rho) ;
lat_rho=permute(ncread(grid_name,'lat_rho'),[2 1]); %eta_rho, xi_rho) ;

mld_file=[simu,'_',type,'_',year,'_MLD_lat_',num2str(yS),'_',num2str(yN),'_lon_',num2str(xW),'_',num2str(xE),'.mat']; %name of the mld file (.mat)

%this will select your domain as if where a straight rectangle
ind = find(xW <= lon_rho(:) & lon_rho(:) <= xE & yS <= lat_rho(:) & lat_rho(:) < yN);
if isempty(ind)
    error('your subdomain is out of the original domain')
end
lonx=lon_rho(ind);
latx=lat_rho(ind);

[a,b] = size(lon_rho);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if you want to see your rectangle selected on the original domain uncomment this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(1);
% set(gcf,'PaperPosition',[0 1.4 12 8]);
% set(gcf,'Visible','on');
% for i = 1:20:a
%         for j = 1:20:b
%                 plot(lon_rho(i,:),lat_rho(i,:),'r');
%                 hold on
%                 plot(lon_rho(:,j),lat_rho(:,j),'b');
%                 text(double(lon_rho(i,end)),double(lat_rho(i,end)),num2str(i),'fontsize',6);
%                 text(double(lon_rho(end,j)),double(lat_rho(end,j)),num2str(j),'fontsize',6);
%         end
% end
% plot_coast
% plot(lonx,latx,'.') %here I plotted my  rectangle
% print('-dpng','domain1.png')
%keyboard

%this selects which are the lines of the original domain that "touch" your
%straigth rectangle
for i=1:a
    lat_etq(i,:)=i*ones(1,b);
end
for j=1:b
    lon_etq(:,j)=j*ones(a,1);
end
lat_etq=lat_etq(:);
lon_etq=lon_etq(:);

%Now, we select between the first and the last lines that touch your
%domain.
lon_inx=min(lon_etq(ind)):max(lon_etq(ind));
lat_inx=min(lat_etq(ind)):max(lat_etq(ind));

%our new lat and lon
lon = lon_rho(lat_inx,lon_inx);
lat = lat_rho(lat_inx,lon_inx);

h=permute(ncread(grid_name,'h',[min(lon_etq(ind)) min(lat_etq(ind))],[length(lon_inx) length(lat_inx)]),[2 1]); %eta_rho, xi_rho) ;
pm=permute(ncread(grid_name,'pm',[min(lon_etq(ind)) min(lat_etq(ind))],[length(lon_inx) length(lat_inx)]),[2 1]); %eta_rho, xi_rho) ;
pn=permute(ncread(grid_name,'pn',[min(lon_etq(ind)) min(lat_etq(ind))],[length(lon_inx) length(lat_inx)]),[2 1]); %eta_rho, xi_rho) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is how your final domain looks like
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(2);
% set(gcf,'PaperPosition',[0 1.4 12 8]);
% set(gcf,'Visible','on');
% pcolor(lon,lat,h)
% shading interp
% colormap('jet')
% plot_coast
% print('-dpng','domain2.png')
%keyboard


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We are gonna create the yearly/climatological MLD file for your domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist([work_path,mld_file])==0
    
    disp('there is not annual MLD for this domain, we will create it')
    %=====================================
    %   Mixed Layer Depth
    %=====================================
    for kk=1:12
        
        month=sprintf('%02d',kk);
        
        [avg_name,~]=build_path(path_files,type,simu,year,month);
        
        disp(['working on ',avg_name])
        %we just load the variables in the domain you specified
        temp = squeeze(permute(ncread(avg_name,'temp',[min(lon_etq(ind)) min(lat_etq(ind)) 1 1],[length(lon_inx) length(lat_inx) inf inf]),[3 2 1]));
        salt = squeeze(permute(ncread(avg_name,'salt',[min(lon_etq(ind)) min(lat_etq(ind)) 1 1],[length(lon_inx) length(lat_inx) inf inf]),[3 2 1]));
        zeta = squeeze(permute(ncread(avg_name,'zeta',[min(lon_etq(ind)) min(lat_etq(ind)) 1],[length(lon_inx) length(lat_inx) inf]),[3 2 1]));
        
        
        theta_s = 6.0;
        theta_b = 3.0;
        hc = 250;
        sc_type = 'new2012';
        dT=0.2;
        
        [Nz,Ny,Nx]=size(temp);
        aux=reshape(zeta,Nx*Ny,1);
        pointer=find(~isnan(aux)); %only where we have data (ocean), not in land (NaN)
        
        [z_w,~] = zlevs4(h, zeta, theta_s, theta_b, hc, Nz, 'r',sc_type);
        
        
        salt2=flipud(salt(:,pointer));
        temp2=flipud(temp(:,pointer));
        zw=flipud(z_w(:,pointer));
        
        mldepth=NaN(1,length(pointer));
        for ii=1:length(pointer)
            
            sst_dT=temp2(1, ii) - dT;
            sigma_t=sw_dens(salt2(:, ii), temp2(:, ii), 0) - 1000;
            sigma_dT=sw_dens(salt2(1, ii), sst_dT, 0) - 1000;
            pos1=find(sigma_t > sigma_dT);
            if ((numel(pos1) > 0) && (pos1(1) > 1))
                p2=pos1(1);
                p1=p2-1;
                mldepth(ii)=interp1(sigma_t([p1, p2]), zw([p1, p2],ii), sigma_dT);
            else
                mldepth(ii)=NaN;
            end
        end
        %we recover our 2D field
        mld2=NaN(Ny,Nx);
        mld2(pointer)=mldepth;
        
        mld(kk,:,:)=mld2;
        
    end
    save([work_path,mld_file],'mld')
else
    load([work_path,mld_file]);
end
clear temp salt zeta aux pointer z_w salt2 temp2 zw mld2 aux auy auz


%% ROMS_avg
%Now we can extract the forcing in the domain

for kk=1:12
    tic
    name3d={'PO4';'NO3';'SiO3';'NH4';'Fe';'DON';'DOFE';'DIATC';'DIATCHL';'DIATSI';'DIATFE';'ZOOC';'SPC';'SPCHL';'SPFE';...
        'temp';'salt';'w';'u';'v';'pm';'pn';'diffz'};
    name2d={'PARinc';'zeta';'mld'};
    
    month=sprintf('%02d',kk);
    
    [avg_name,flux_name]=build_path(path_files,type,simu,year,month);
    
    disp(['working on ',avg_name])
    
    for indv=1:length(name3d)-5
        var3d.(name3d{indv}) = squeeze(permute(ncread(avg_name,name3d{indv},[min(lon_etq(ind)) min(lat_etq(ind)) 1 1]...
            ,[length(lon_inx) length(lat_inx) inf inf]),[3 2 1]));
    end
    
    var3d.u = squeeze(permute(ncread(avg_name,'u',[min(lon_etq(ind)) min(lat_etq(ind)) 1 1]...
        ,[length(lon_inx)-1 length(lat_inx) inf inf]),[3 2 1]));
    var3d.v = squeeze(permute(ncread(avg_name,'v',[min(lon_etq(ind)) min(lat_etq(ind)) 1 1]...
        ,[length(lon_inx) length(lat_inx)-1 inf inf]),[3 2 1]));
    
    [Nz,Ny,Nx]=size(var3d.temp);
    
    var3d.pm=permute(repmat(pm,1,1,Nz),[3 1 2]);
    var3d.pn=permute(repmat(pn,1,1,Nz),[3 1 2]);
    
    for indv=1:length(name2d)-1
        var2d.(name2d{indv}) = squeeze(permute(ncread(avg_name,name2d{indv},[min(lon_etq(ind)) min(lat_etq(ind)) 1],...
            [length(lon_inx) length(lat_inx) inf]),[3 2 1]));
    end
    var2d.mld=squeeze(mld(kk,:,:));
    
    %============================================
    % From dimensions of U-V to Rho and W to Rho
    %============================================
    [a,b,c]=size(var3d.u);
    UU=NaN(a,b,c+1);
    UU=u2rho_3d(var3d.u);
    var3d.u=UU(:,:,1:end);
    
    [a,b,c]=size(var3d.v);
    VV=NaN(a,b+1,c);
    VV=v2rho_3d(var3d.v);
    var3d.v=VV(:,1:end,:);
    
    theta_s = 6.0;
    theta_b = 3.0;
    hc = 250;
    sc_type = 'new2012';
    dT=0.2;
    
    [z_r,~] = zlevs4(h, var2d.zeta, theta_s, theta_b, hc, Nz, 'r',sc_type);
    [z_w,~] = zlevs4(h, var2d.zeta, theta_s, theta_b, hc, Nz, 'w',sc_type);
    z_w(end,:,:)=[];
    w1=NaN(Nz,Ny,Nx);
    for i=1:Ny
        for j=1:Nx
            try
                w1(:,i,j)=interp1(z_w(:,i,j),var3d.w(:,i,j),z_r(:,i,j)); %whit this, the surface value of w is NaN but we do not use it
            catch
            end
        end
    end
    
    
    %==========================================
    %   Average in vertical in the mean MLD
    %==========================================
    [z_w,~] = zlevs4(h, var2d.zeta, theta_s, theta_b, hc, Nz, 'w',sc_type);
    dzb = diff(z_w);
    var3d.diffz=dzb;
    
    clear aux auy auz pointer
    
    
    auz=reshape(squeeze(mean(mld)),Ny*Nx,1);
    pointer=find(~isnan(auz)); %where we have data
    
    zwb=z_w(:,pointer);
    dzwb=dzb(:,pointer);
    maxdepth=nanmean(mld(:)); %average mld
    clear aux auy auz
    
    %in which index position is the average mld
    indiceB=NaN(1,length(pointer));
    factorB=NaN(1,length(pointer));
    dzbF=NaN(1,length(pointer));
    for i=1:length(pointer)
        test = squeeze(zwb(:,i)) ; %test(test==0)=NaN;
        if (isnan(test(1))~=1)
            indiceB(i) = interp1(test,1:Nz+1,maxdepth) ;
            if (isnan(indiceB(i))~=1)
                factorB(i) =  indiceB(i) - floor(indiceB(i)) ;
                dzbF(i) = dzwb(floor(indiceB(i)),i) ;
                dzwb(1:floor(indiceB(i)),i) = 0 ; %the maxdepth is not at IndiceB, it is at IndiceB,something. So I need to evaluate in IndiceB+1 and "add" the (1-something).
            end
        end
        clear test
    end
    
    for indv=1:length(name3d)
        varint=NaN(1,length(pointer));
        varint2=NaN(Nz,length(pointer));
        auy=reshape(var3d.(name3d{indv}),Nz,Ny*Nx);
        aux=auy(:,pointer);
        
        aux(dzwb==1)=0 ; aux(isnan(dzwb))=NaN ;
        indz=floor(indiceB) ; indz(isnan(indz))=0 ;
        auz=indz~=0; indz(indz==0)=1; %only when indz=0, auz=0 and the multiplication below is just the left size.
        for i=1:length(indz)
            
            %we kept the values between the maxdepth and the surface. Below
            %that, is just NaN
            varint2(indz(i):end,i)= ((aux(indz(i):end,i).*dzwb(indz(i):end,i))  + ( (1-factorB(i))*auy(indz(i):end,pointer(i))*dzbF(i)) * auz(i))./...
                ((dzwb(indz(i):end,i)) + ((1-factorB(i))*dzbF(i))* auz(i) );
            
            %an average through the mld
            varint(i)= (sum(aux(:,i).*dzwb(:,i))  + ( (1-factorB(i))*auy(indz(i),pointer(i))*dzbF(i)) * auz(i))./...
                (sum(dzwb(:,i)) + ((1-factorB(i))*dzbF(i))* auz(i) );
        end
        %         varint(isinf(varint))=NaN; %if you don't want to use the
        %         correction factor, you will have to do this for the cases that
        %         you don't have mixed layer
        
        var2d.(name3d{indv})=NaN(Ny,Nx);
        var2d.(name3d{indv})(pointer)=varint;
        
        var3dcut.(name3d{indv})=NaN(Nz,Ny,Nx);
        var3dcut.(name3d{indv})(:,pointer)=varint2;
        
        
        clear auy aux indz auz
        
    end
    
    
    %=============================================
    %  Particulate fluxes at the based of MLD
    %=============================================
    
    name2={'POC_FLUX_IN';'SIO2_FLUX_IN';'P_IRON_FLUX_IN'};
    
    
    for indv=1:length(name2)
        varint=NaN(1,length(pointer));
        varint2=NaN(Nz,length(pointer));
        
        auw = squeeze(permute(ncread(flux_name,name2{indv},[min(lon_etq(ind)) min(lat_etq(ind)) 1 1],[length(lon_inx) length(lat_inx) inf inf]),[3 2 1]));
        auy=reshape(auw,Nz,Ny*Nx);
        aux=auy(:,pointer);
        
        aux(dzwb==1)=0 ; aux(isnan(dzwb))=NaN ;
        indz=floor(indiceB) ; indz(isnan(indz))=0 ;
        auz=indz~=0; indz(indz==0)=1; %only when indz=0, auz=0 and the multiplication below is just the left size.
        for i=1:length(indz)
            
            %we kept the values between the maxdepth and the surface. Below
            %that, is just NaN
            varint2(indz(i):end,i)= ((aux(indz(i):end,i).*dzwb(indz(i):end,i))  + ( (1-factorB(i))*auy(indz(i):end,pointer(i))*dzbF(i)) * auz(i))./...
                ((dzwb(indz(i):end,i)) + ((1-factorB(i))*dzbF(i))* auz(i) );
            
            %just the value at the mld (non-average)
            varint(i)= ((aux(indz(i),i).*dzwb(indz(i),i))  + ( (1-factorB(i))*auy(indz(i),pointer(i))*dzbF(i)) * auz(i))./...
                ((dzwb(indz(i),i)) + ((1-factorB(i))*dzbF(i))* auz(i) );
        end
        
        %         varint(isinf(varint))=NaN; %if you don't want to use the
        %         correction factor, you will have to do this for the cases that
        %         you don't have mixed layer
        
        var2d.(name2{indv})=NaN(Ny,Nx);
        var2d.(name2{indv})(pointer)=varint;
        
        var3dcut.(name2{indv})=NaN(Nz,Ny,Nx);
        var3dcut.(name2{indv})(:,pointer)=varint2;
        
        
        clear auy aux indz auz
        
    end
    
    
    % Areas and fluxes on your rectangle
    %
    %   ___coast__       _
    %  /_|_______/|      |
    % |1 |   4  |3|  average_mld
    % |  |2_ _ _| |      |
    % | /    5  | |      |
    % |/________|/       _
    %
    % Area is calculated in walls 1-4 as: dz*dx or dz*dy of each grid and
    % then sum up for the entire wall. here dx=1/pm and dy=1/pn
    % Area is calculated in wall 5 as: dy*dx on each grid size in an
    % 2D interpolated depth (maxdepth)
    
    name3d={'PO4';'NO3';'SiO3';'NH4';'Fe';'DON';'DOFE';'DIATC';'DIATCHL';'DIATSI';'DIATFE';'ZOOC';'SPC';'SPCHL';'SPFE';...
        'temp';'salt';'u';'v';'w';'pm';'pn';'diffz';'POC_FLUX_IN';'SIO2_FLUX_IN';'P_IRON_FLUX_IN'};
    
    %1 to 4
    for indv=1:length(name3d)-3
        var2d_1.(name3d{indv})=squeeze(var3dcut.(name3d{indv})(:,end,:));
        var2d_2.(name3d{indv})=squeeze(var3dcut.(name3d{indv})(:,:,1));
        var2d_3.(name3d{indv})=squeeze(var3dcut.(name3d{indv})(:,1,:));
        var2d_4.(name3d{indv})=squeeze(var3dcut.(name3d{indv})(:,:,end));
    end
    A1=var2d_1.diffz.*(1./var2d_1.pm);
    T1=var2d_1.u.*A1; %volume transport
    T1=abs(min(0,T1,'includenan')); %volume transport going INTO the rectangle
    
    A2=var2d_2.diffz.*(1./var2d_2.pm);
    T2=var2d_2.v.*A2;
    T2=abs(max(0,T2,'includenan'));
    
    A3=var2d_3.diffz.*(1./var2d_3.pm);
    T3=var2d_3.u.*A3;
    T3=abs(max(0,T3,'includenan'));
    
    A4=var2d_4.diffz.*(1./var2d_4.pm);
    T4=var2d_4.v.*A4;
    T4=abs(min(0,T4,'includenan'));
    
    %Get vertical slices for 5
    for indv=1:length(name3d)-3
        aux=var3d.(name3d{indv}); %obs, here is the 3d var that were not 'cut', otherwise it gives wrong values.
        var2d_5.(name3d{indv}) = vinterp(aux,z_r,maxdepth);
    end
    mask5=var2d_5.PO4;
    mask5(~isnan(mask5))=1;
    A5=((1./pm).*(1./pn)).*mask5;
    T5=var2d_5.w.*A5;
    T5=abs(max(0,T5,'includenan'));
    
    T_in=nansum(T1(:))+nansum(T2(:))+nansum(T3(:))+nansum(T4(:))+nansum(T5(:)); %Total transport IN
    
    
    for indv=1:length(name3d)-3
        
        phi_in=nansum(nansum(T1.*var2d_1.(name3d{indv}))) + nansum(nansum(T2.*var2d_2.(name3d{indv}))) + nansum(nansum(T3.*var2d_3.(name3d{indv})))...
            + nansum(nansum(T4.*var2d_4.(name3d{indv}))) + nansum(nansum(T5.*var2d_5.(name3d{indv}))); %total flux IN for each variable
        N_in=phi_in/T_in; %Total stuff IN for each variable
        
        aux=[(name3d{indv}),'_in'];
        var1d.(aux)(kk) = N_in;
        
    end
    var1d.flow_in(kk)=(T_in/(nansum(A5(:))))*60*60*24*365; %Total flow IN assumed as a consequence of upwelling [m/year]
    
    %===================================================================
    %   Average and save in the hab_0d order with NaN when we dont have
    %   the variable
    %===================================================================
    
    names={'temp';'PARinc';'mld';'NO3';'NH4';'SiO3';'PO4';'Fe';'DIATC';'DIATFE';'DIATCHL';'DIATSI';...
        'DON';'DOFE';'POC_FLUX_IN';'P_IRON_FLUX_IN';'SIO2_FLUX_IN'...
        ;'DiDA';'DDA';'PDA';'ZOOC';'SPC';'SPFE';'SPCHL';'pDA';'dDA'};
    
    for indv=1:length(names)
        try
            aux=var2d.(names{indv});
            var1d.(names{indv})(kk) = nanmean(aux(:));
        catch
            var1d.(names{indv})(kk) = NaN;
        end
        clear aux
    end
    
    toc
    clear aux auy auz
    
end
clearvars -except var1d yS yN xW xE work_path simu type year
name3d=[work_path,simu,'_',type,'_',year,'_lat_',num2str(yS),'_',num2str(yN),'_lon_',num2str(xW),'_',num2str(xE),'.mat'];
save(name3d)



