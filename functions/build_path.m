function [avg_name,flux_name]=build_path(path_files,type,simu,year,month)

%This is how your path looks like
if strcmp(type,'MONTHLY') | strcmp(type,'monthly')
    avg_name=[path_files,type,'/',simu,'_avg.Y',num2str(year),'M',month,'.nc'];
    flux_name=[path_files,type,'/',simu,'_bgc_flux_avg.Y',num2str(year),'M',month,'.nc'];   
else

    avg_name=[path_files,type,'/',simu,'_avg.M',month,year,'.nc'];
    flux_name=[path_files,type,'/',simu,'_bgc_flux_avg.M',month,year,'.nc'];
end

return
