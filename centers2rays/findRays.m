function [P,V]=findRays(calib,x_px,y_px)

%typeT = 'lin';
typeT = 'poly';

Npart = numel(x_px);
Nplans = numel(calib);

XYZ = zeros(numel(calib),3,numel(x_px));

for kplan = 1:Nplans
    if strcmp(typeT,'poly')
        I = inpolygon(x_px,y_px,calib(kplan).pimg(calib(kplan).cHull,1),calib(kplan).pimg(calib(kplan).cHull,2));
        if max(I)>0
            [Xtmp,Ytmp]=tforminv(calib(kplan).T3px2rw,x_px(I==1),y_px(I==1));
            %[Xtmp,Ytmp]=transformPointsInverse(calib(kplan).T3px2rw,x_px(I==1),y_px(I==1));
            XYZ(kplan,1,I==1)=Xtmp;
            XYZ(kplan,2,I==1)=Ytmp;
            XYZ(kplan,3,I==1)=calib(kplan).posPlane;
        end
        
        XYZ(kplan,1,I==0) = NaN;
        XYZ(kplan,2,I==0) = NaN;
        XYZ(kplan,3,I==0) = NaN;
    elseif strcmp(typeT,'lin')
        [Xtmp,Ytmp]=tforminv(calib(kplan).T1px2rw,x_px,y_px);
        %[Xtmp,Ytmp]=transformPointsInverse(calib(kplan).T1px2rw,x_px(I==1),y_px(I==1));
        XYZ(kplan,1,:)=Xtmp;
        XYZ(kplan,2,:)=Ytmp;
        XYZ(kplan,3,:)=calib(kplan).posPlane;
    end
    
end

%%
%figure;plot3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'+')
[P V] = fit3Dline(XYZ);