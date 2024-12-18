function [F,CC,LL,V] = interppixel2line(calibDataSeg,NL,NC,NiL,NiC,TFORM,ZZ,varargin)

% F=interppixel2line(calibDataSeg,NL,NC,NiL,NiC,calib_prefix,NZZ,ZZ)
%
% calibDataSeg - segmented calib data per plane :
%                   calibDataSeg(k).data(1)=x_px(1)
%                   calibDataSeg(k).data(2)=y_px(1)
%                   calibDataSeg(k).data(3)=X_real(1)
%                   calibDataSeg(k).data(4)=Y_real(1)
%               for plane number k
%
% NL = number of lines per image
% NC = number of columns per image
% NiL = number of interpolating points in lines
% NiC = number of interpolating points in columns
% TFORM - structure array with plane by plane transformations
% ZZ=[-6 0 6]; - Real position of the plane 
% translation_plan : numeros of planes moving in translation

if nargin > 7
    cam_back = varargin{2}; %to be defined if a camera looks the back of the calibration mask;
    e = varargin{1};% in this case, you need to define e, the thickness of the calibration mask;
end

%% Now we first create an ensemble of points in pixel coordinates defnied by their col, row coordinates
% CC and LL. Then for each of this points we will calculate the
% corresponding ray of light, defined by one point O and one vector V in real world.
% Finally given the ensemble of pixel coordinates points (CC,LL) and real
% world rays (O,V) we will create an interpolant allowing to attribute a
% ray in real world coordinates to any arbitrary point in pixel
% coordinates.
%
% The initial ensemble of points in pixel coordinates is made of 2
% different sub-ensembles :
% - first we will use all the points actually used for the calibration
% - if those are to scarce to reasonably sample to full measurement volume 
%   additionnal interpolating points are added on a regular interpolating
%   grid with NiC cols and NiR rows.

%% First calculate the rays for every actual calibration point
calibData=vertcat(calibDataSeg.data);
C=calibData(:,1);
L=calibData(:,2);

kV=0;
for kL=1:numel(L)
    kC=kL;
        if exist('cam_back');
            [xyz0,direction]=pixel2line(calibDataSeg,L(kL),C(kC),TFORM,ZZ,e,cam_back);
        else
            [xyz0,direction]=pixel2line(calibDataSeg,L(kL),C(kC),TFORM,ZZ);
        end
        
        if ~isempty(xyz0);
            direction=sign(direction(3))*direction;
            kV=kV+1;
            V(kV,:)=[xyz0 direction'];
            LL(kV)=L(kL);
            CC(kV)=C(kC);
        end
        clear xyz0 direction;
end


% %% Then calculate the rays for the points on the interpolating grid
% % If the calibration data has a sufficient number of calibration points,
% % this part can be skipped, and the interpolant can be estimated just using
% % the actual calibration points
% 
% stepL=floor(NL/NiL);
%  stepC=floor(NC/NiC);
%  L=0:stepL:NL+1;
%  C=0:stepC:NC+1;
% 
% % iL=linspace(-pi,pi,NiL);
% % iC=linspace(-pi,pi,NiC);
% % L=(tanh(iL)+1)*NL;
% % C=(tanh(iC)+1)*NC;
% 
% for kL=1:numel(L)
%     for kC=1:numel(C)
%         if exist('cam_back');
%             [xyz0,direction]=pixel2line(calibDataSeg,L(kL),C(kC),TFORM,ZZ,e,cam_back);
%         else
%             [xyz0,direction]=pixel2line(calibDataSeg,L(kL),C(kC),TFORM,ZZ);
%         end
%         
%         if ~isempty(xyz0);
%             direction=sign(direction(3))*direction;
%             kV=kV+1;
%             V(kV,:)=[xyz0 direction'];
%             LL(kV)=L(kL);
%             CC(kV)=C(kC);
%         end
%         clear xyz0 direction;
%     end
% end
%% uncomment to define interpolant as (row,col)->line
% In the next lines TriScatteredInterp can be replaced by
% griddedInterpolant withe 'Extrapolation' option set to 'none'

% F(1).f=TriScatteredInterp(LL',CC',V(:,1),'linear','none');
% F(2).f=TriScatteredInterp(LL',CC',V(:,2),'linear','none');
% F(3).f=TriScatteredInterp(LL',CC',V(:,3),'linear','none');
% F(4).f=TriScatteredInterp(LL',CC',V(:,4),'linear','none');
% F(5).f=TriScatteredInterp(LL',CC',V(:,5),'linear','none');
% F(6).f=TriScatteredInterp(LL',CC',V(:,6),'linear','none');

% %% uncomment to define interpolant as (x,y)->line
% In the next lines TriScatteredInterp can be replaced by
% griddedInterpolant withe 'Extrapolation' option set to 'none'

 F(1).f=TriScatteredInterp(CC',LL',V(:,1),'linear');
 F(2).f=TriScatteredInterp(CC',LL',V(:,2),'linear');
 F(3).f=TriScatteredInterp(CC',LL',V(:,3),'linear');
 F(4).f=TriScatteredInterp(CC',LL',V(:,4),'linear');
 F(5).f=TriScatteredInterp(CC',LL',V(:,5),'linear');
 F(6).f=TriScatteredInterp(CC',LL',V(:,6),'linear');

%save(['Interpol_calib_' num2str(length(NZZ)) 'plans_cam_' num2str(ii) '.mat'],'F')

end


