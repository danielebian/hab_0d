function [R,L] = nanxcorr_ms(s1,s2,Lag);
% function [L,R] = nanxcorr(s1,s2,Lag);
% Funcion que permite obtener la correlacion cruzada
% de un par de series de tiempo que contienen brechas
%
% Input:
%   s1   serie de tiempo [vector]
%   s2   serie de tiempo [vector]
%   lag  numero de rezagos a correlacionar (eg. 20)
%
% Output
%   L     rezago
%   R     coeficiente de correlacion
%
% sam 16/04/2013
% Version Marco Sandoval Belmar 4/1/2018

r=corr(s1,s2,'rows','complete');  % correlacion a lag == 0

% Realiza la correlacion para los distintos rezagos
L = 0; R = r;
for i1 =1:1:Lag
    s11 = s1(1:end-i1);
    s21 = s2(i1+1:end);
    c = corr(s11,s21,'rows','complete');
    R = [c;R];
    L = [-i1;L];
    
    clear s11 s21 c
    
    s21 = s2(1:end-i1);
    s11 = s1(i1+1:end);
    c = corr(s11,s21,'rows','complete');
    R = [R;c];
    L = [L;i1];
    
    clear s21 s11 c
end
end
