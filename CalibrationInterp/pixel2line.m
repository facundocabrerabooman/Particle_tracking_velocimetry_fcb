                                                                                        function [xyz0,direction]=pixel2line(calibDataSeg,L,C,TFORM,TT,varargin)

% calibDataSeg - segmented calib data per plane :
%                   calibDataSeg(k).data(1)=x_px(1)
%                   calibDataSeg(k).data(2)=y_px(1)
%                   calibDataSeg(k).data(3)=X_real(1)
%                   calibDataSeg(k).data(4)=Y_real(1)
%               for plane number k
% L - line
% C - Column
% TFORM - structure array with plane by plane transformations
% NTT=[1 7 13]; - Number of the plane
% TT=[-6 0 6]; - Real position of the plane
% translation_plan : numeros of planes moving in translation

Nplanes=length(TT);

e=0;

if nargin>5
    cam_back=varargin{2};
    e=varargin{1}/2;
end

%XX=zeros(1,Nplanes);
%YY=zeros(1,Nplanes);
%ZZ=zeros(1,Nplanes);

k=0;
for kplane=1:Nplanes
    CH=convhull(calibDataSeg(kplane).data(:,3),calibDataSeg(kplane).data(:,4));
    %[Xtmp,Ytmp]=tforminv(TFORM(kplane).T,[C L]);
    [Xtmp Ytmp]=transformPointsInverse(TFORM(kplane),C,L);
    if inpolygon(Xtmp,Ytmp,calibDataSeg(kplane).data(CH,3),calibDataSeg(kplane).data(CH,4));
        k=k+1;
        XX(k)=Xtmp;
        YY(k)=Ytmp;
        ZZ(k)=TT(k)+e;
    end
end

if k>1
    [xyz0,direction]=fit3Dline([XX' YY' ZZ']);
else
    xyz0=[];
    direction=[];
end
    