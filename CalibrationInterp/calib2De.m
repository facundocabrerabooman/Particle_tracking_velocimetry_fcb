function [pimg,pos3D,T,Tinv,aRoi]=calib2De(Iimg,threshold,Size_dot,gridspace,lnoise,tolerance,bounds,aRoi)

%
% [pimg,pos2D,T,Tinv]=calib2DC(zPlane,camNumber,Size_dot,gridspace,lnoise,aRoi)
%
% fname = calibration image file
% Size_dot : typical diameter, in pixels, of dots in mask image
% gridspace : grid spacing of calibration mask in mm
% lnoise : typical lengthscal of image noise;
%
% pimg : center coordinates in original image
% pos2D : center coordinates in real world
% T : transformation from real world to image
% Tinv : transformation from image to real world

zPlane=0;
camNumber=1;
fname = ['plane_' num2str(zPlane) '_C' num2str(camNumber,'%03d')];


if ~exist('lnoise','var')
    lnoise=1;
end

ncams=1;
movingaxis='z';
maskaxis=['x', 'y'];
img_inversion='y';
nfig = figure;

axispos=zPlane;
pimg = [];
pos3D = [];

% if lower(img_inversion(1)) == 'y'
%     if (strcmp(fname(end-4:end),'mcin2')==1)
%         Iimg = abs(4095 - double(mCINREAD2(fname, 1, 1, 1)));
%     else
%         %Iimg = 255 - mean(imread(fname), 3);
%         %Iimg = 255 - fname;
%         load(fname);
%         Iimg=mIm;
%     end
% else
%     if (strcmp(fname(end-4:end),'mcin2')==1)
%         Iimg = mean(double(mCINREAD2(fname, 1, 1, 1)), 3);
%     else
%         %Iimg = mean(imread(fname), 3);
%         load(fname);
%         Iimg=mIm;
%         %Iimg = mean(double(cinread(fname, 1, 1, 1)), 3);
%     end
% end
if lower(img_inversion(1)) == 'y'
    Iimg=imcomplement(Iimg);
end

Iimg=bpass2(Iimg,lnoise,Size_dot);
[Npix_y Npix_x] = size(Iimg);
figure(nfig);
redo = 'y';

while strcmp(lower(redo), 'y')
    xc=[];
    yc=[];
    Ap=[];
    Ith = zeros(Npix_y, Npix_x);
    h1 = subplot('position', [0.05 0.3 0.4 0.6]);
    h2 = subplot('position', [0.05 0.08 0.4 0.15]);
    h3 = subplot('position', [0.55 0.3 0.4 0.6]);
    subplot(h1);
    %imshow(uint8(Iimg));
    imagesc(Iimg);colormap(gray);
    hold on;
    %title(prnstr(fname));
    title(fname);
    
    %%
    disp('Now please indicate a square or rectangular region of interest in real space');
    
    if ~exist('aRoi','var')
        [BW_roi,xi,yi]=roipoly;
        aRoi=[xi(1:4) yi(1:4)];
    else
        [BW_roi,xi,yi]=roipoly(Iimg,aRoi(1:4,1),aRoi(1:4,2));
        aRoi=[xi(1:4) yi(1:4)];
    end
    a0=[0 0; 1 0; 1 1; 0 1];
    T0=cp2tform(aRoi,a0,'projective');
    
    %%
    
    
    Ith=zeros(size(Iimg));
    
    Nhist = hist(reshape(double(Iimg), size(Iimg,1)*size(Iimg,2), 1), [0:255]);
    subplot(h2);
    semilogy([0:255], Nhist, 'b-');
    axis([0 255 1 10000]);
    % th = input('Please choose threshold   ');
    th = threshold;
    % Amin = input('Please choose the minimum particle image size   ');
    %Amin=0.9*pi*Size_dot^2/4;
    Amin=10;
    
    SS=regionprops(Iimg.*BW_roi>th,'Centroid','Area');
    Ith=imclearborder(Iimg>th);
    SS=regionprops(Ith,'Centroid','Area');
    Apsub=[SS.Area]';
    II=find(Apsub<0.5*pi*Size_dot^2/4);
    SS(II)=[];
    Apsub(II)=[];
    XX=reshape([SS.Centroid],2,[])';
    xc=XX(:,1);
    yc=XX(:,2);
    
    Ap = [Ap ; Apsub];
    
    Ith = double((Iimg.*BW_roi)>th);%Ith+Ithsub; % Note Ith is a binary image
   
    subplot(h3);
    
    [Itht,xx,yy]=imtransform(Iimg,T0,'Size',size(Ith));
    imagesc(xx,yy,Itht);colormap('gray')
    hold on;
    
    xc0=xc;
    yc0=yc;
    [xc,yc]=tformfwd(T0,xc0,yc0);
    
    plot(xc, yc, 'r+');
    hold off
    redo='n';
%    redo = input('Do you want to re-process the image? (y/n)   ', 's');
end

Np = length(xc);
% % manually remove some points if it's more convenient
% rmman = input('Do you want to manually remove some possibly wrong particles? (y/n)  ', 's');
% if (lower(rmman(1)) == 'y')
%     ind = ones(Np,1);
%     nrm = 0;
%     disp('Please click the particle centers that you want to remove.');
%     disp('Right click the mouse when you are done.');
%     but = 1;
%     hold on
%     while but ~= 3
%         [xrm yrm but] = ginput(1);
%         if but == 1
%             dist = (xc-xrm).^2+(yc-yrm).^2;
%             [mindist irm] = min(dist);
%             plot(xc(irm), yc(irm), 'ro');
%             ind(irm) = 0;
%             nrm = nrm+1;
%         end
%     end
%     hold off
%     xc = xc(logical(ind));
%     yc = yc(logical(ind));
%     xc0 = xc0(logical(ind));
%     yc0 = yc0(logical(ind));
%     
%     Ap = Ap(logical(ind),:);
%     Np = length(xc);
%     disp(strcat(num2str(nrm), ' points have been removed. Please check the image again'));
%     
%     %imagesc(imtransform(Ith,T0,'Size',size(Ith)));
%     imagesc(xx,yy,Itht)
%     hold on;
%     
%     
%     plot(xc, yc, 'r+');
%     hold off
% end

disp('Now please indicate the three base point on the mask by click mouse on the thresholded image in order [0 0], [1 0], [0 1].');
%disp('Starting with the first');
but = 0;
while but ~= 1
    [x0 y0 but] = ginput(1);
end
dist = (xc-x0).^2+(yc-y0).^2;
[mindist i0] = min(dist);
subplot(h3);
hold on
plot(xc(i0), yc(i0), 'bo');
%promptstr = sprintf('What are the indices of this point in %s and %s-dir?\\n', maskaxis(1), maskaxis(2));
%temp = input(promptstr);
%i0xind = temp(1);
%i0yind = temp(2);
i0xind = 0;
i0yind = 0;

%disp('Please indicate the second base point');
but = 0;
while but ~= 1
    [x1 y1 but] = ginput(1);
end
dist = (xc-x1).^2+(yc-y1).^2;
[mindist i1] = min(dist);
plot(xc(i1), yc(i1), 'bo');
% 		promptstr = sprintf('What are the indices of this point in %s and %s-dir?\\n', maskaxis(1), maskaxis(2));
% 		temp = input(promptstr);
% 		i1xind = temp(1);
% 		i1yind = temp(2);
i1xind = 1;
i1yind = 0;

%disp('Please indicate the third base point');
but = 0;
while but ~= 1
    [x2 y2 but] = ginput(1);
end
dist = (xc-x2).^2+(yc-y2).^2;
[mindist i2] = min(dist);
plot(xc(i2), yc(i2), 'bo');

i2xind = 0;
i2yind = 1;



% Now determine the point coordinates
% first, form two base vectors on the mask
e1 = [i1xind-i0xind, i1yind-i0yind];
e2 = [i2xind-i0xind, i2yind-i0yind];
% The prjection of these two vectors on image plane
e1p = [xc(i1)-xc(i0), yc(i1)-yc(i0)];
e2p = [xc(i2)-xc(i0), yc(i2)-yc(i0)];
e1pnorm = sum(e1p.^2);
e2pnorm = sum(e2p.^2);
e1pe2p = sum(e1p.*e2p);
d = (e1pnorm*e2pnorm - e1pe2p*e1pe2p);		% The denominator
% calaulte the coords of all points using the two base vectors
pind = zeros(Np, 2);

for i=1:Np
    c = [xc(i)-xc(i0), yc(i)-yc(i0)];
    A = (sum(c.*e1p)*e2pnorm - sum(c.*e2p)*e1pe2p)/d;
    B = (sum(c.*e2p)*e1pnorm - sum(c.*e1p)*e1pe2p)/d;
    pind(i,:)=[A B];
end


% Now calculate the two components of dots' 3D coordinates on the mask plane
pmask = zeros(Np,2);
originalpmask = zeros(Np,2);


for i=1:Np
    originalpmask(i,1:2) = (e1*pind(i,1)) + (e2*pind(i,2)) + [i0xind i0yind];
    pmask(i,1:2)=round(originalpmask(i,1:2));
    NN(i)=norm(pmask(i,1:2)-originalpmask(i,1:2));

%% for biplane target
%      if mod(pmask(i,2),2)==0
%          pmask(i,3)=0;
%      else
%          pmask(i,3)=-1;
%      end

%% for single plane target
     pmask(i,3)=0;
end


I=find((NN'>tolerance)|(pmask(:,1)<bounds(1))|(pmask(:,1)>bounds(2)|(pmask(:,2)<bounds(3))|pmask(:,2)>bounds(4)));
pmask(I,:)=[];
xc0(I)=[];
yc0(I)=[];
xc(I)=[];
yc(I)=[];

Np=size(pmask,1);

% check to see if there is any inconsistency
ncoll = 0;
icoll = [];

for i=1:Np
    str = strcat('(',num2str(pmask(i,1)),',',num2str(pmask(i,2)),',',num2str(pmask(i,3)),')');
	plot(xc(i),yc(i),'yx');
    text(xc(i), yc(i), str, 'Color', 'm');
end

for i=2:Np
    for j = 1:i-1
        if (pmask(i,1) == pmask(j,1)) & (pmask(i,2) == pmask(j,2))
            ncoll = ncoll+1;
            icoll = [icoll; [i j]];
        end
    end
end

if ncoll == 0
    disp('No confilcts found, but please still check particle coordinates.');
else
    str = sprintf('Some particle coordinates are probably wrong. %d conflicts found: \n', ncoll);
    for  ic = 1:ncoll
        str = strcat(str, sprintf('(%d, %d)\n', pmask(icoll(ic),:)));
    end
    disp(str);
end

pos3D = pmask*gridspace;
pos3D(:,3)=pos3D(:,3)+zPlane;
pimg = [xc0 yc0];
pos2D=pos3D(:,1:2);

%[T, err] = invpersp(pos2D', pimg');
ttype='polynomial';
Tinv=cp2tform(pimg,pos2D,ttype,3);
T=cp2tform(pos2D,pimg,ttype,3);
save(['calib2D_' num2str(zPlane) '_cam' num2str(camNumber)],'pos3D','pimg','T','Tinv');
