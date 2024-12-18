zPlanes = [0 3.98 7.96 12.27 16.19 20.11 24.03 27.95 31.87 35.79]; %mm
th = [45 45];
dotSize = 12; % pixels
gridSpace = 5; % mm
lnoise = 1; %pixels
dStrel = 10; % pixels
Ncam = 2;
camName={'1','2'};

% xyzRef(1).ref(1:5,:)=repmat([0 0 0],5,1); % pixels
% xyzRef(1).ref(6:9,:)=repmat([6 -7 0],4,1);% pixels
% 
% xyzRef(2).ref(1:4,:)=repmat([12 0 0],4,1);% pixels
% xyzRef(2).ref(5:9,:)=repmat([6 -7 0],5,1);% pixels
% 
% xyzRef(3).ref(1:4,:)=repmat([6 -7 0],4,1);% pixels
% xyzRef(3).ref(5:9,:)=repmat([12 0 0],5,1);% pixels

xyzRef(1).ref(1:12,:) = repmat([0 0 0],12,1); % pixels
xyzRef(2).ref(1:12,:) = repmat([0 0 0],12,1); % pixels
xyzRef(3).ref(1:12,:) = repmat([0 0 0],12,1); % pixels
xyzRef(4).ref(1:12,:) = repmat([0 0 0],12,1); % pixels

dirIn =  '/Users/FC/Doctorat/Quiescent_flow/Calibration/calibration/Nov_non3Dparticles/calibImages' ;
%%
for kz = 1:numel(zPlanes)
    z = zPlanes(kz)
    for kcam = 1:Ncam
        dd = dir([dirIn filesep 'Camera' camName{kcam} '_' num2str(z) '*.JPG']);        
        %%
        Img=sum(imcomplement(imread(dd(1).name)),3);
        ddisk = strel('disk',dotSize);
        ImBk = imopen(Img,ddisk);
        Img = imsubtract(Img,ImBk);
        %%
        [pimg,pos3D,T,Tinv,aRoi]=calib2Df(Img,th(kcam),dotSize,gridSpace,lnoise,z,xyzRef(kcam).ref(kz,:),kcam,dirIn);
    end
end

%% make calib structure
for kz = 1:numel(zPlanes)
    for kcam = 1:Ncam
        kz
        kcam
        load([dirIn filesep 'calib2D_' num2str(zPlanes(kz)) '_cam' num2str(kcam) '.mat']);
        calib(kz,kcam).posPlane = zPlane;
        calib(kz,kcam).pimg = pimg;
        calib(kz,kcam).pos3D = pos3D;
        calib(kz,kcam).T1rw2px = T1rw2px;
        calib(kz,kcam).T1px2rw = T1px2rw;
        calib(kz,kcam).T3rw2px = T3rw2px;
        calib(kz,kcam).T3px2rw = T3px2rw;
        calib(kz,kcam).cHull=convHullpimg;
        calib(kz,kcam).cam = kcam;
    end
end

save calib calib;