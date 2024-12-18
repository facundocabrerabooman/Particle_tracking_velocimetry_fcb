function [calibInterp,X_px,Y_px,V]=calibInterpLEM(calibData,Nrows,Ncols,Nirows,Nicols)

% calibInterp=calibInterpLEM(calibData,Nrows,Ncols)
%
% calibData(:,1) = x_px
% calibData(:,2) = y_px
% calibData(:,3) = x_rw
% calibData(:,4) = y_rw
% calibData(:,5) = z_rw
%
% Nrows = rows per image
% Ncol = cols per image
% Nirows = #of interpolation rows per image
% Nicol = #of interpolation cols per image


% if pixel units for the date are in 'Matlab coordinates' and calibData in 'Mathematica coordinates' use this, otherwise comment
% next 2 lines
%calibData(:,1) = calibData(:,1) + 0.5;
%calibData(:,2) = Nrows - calibData(:,2) + 0.5;

%% First segement the calibData into a plane by plane structure array 
calibDataSeg = segmentData(calibData,5);
%% 
for kplane = 1:numel(calibDataSeg)
    T(kplane)=fitgeotrans([calibDataSeg(kplane).data(:,3) calibDataSeg(kplane).data(:,4)],[calibDataSeg(kplane).data(:,1) calibDataSeg(kplane).data(:,2)],'polynomial',3);
end
ZZ=unique(calibData(:,5));

%% Now calculates the pixel to ray interpolant
[calibInterp,X_px,Y_px,V] = interppixel2line(calibDataSeg,Nrows,Ncols,Nirows,Nicols,T,ZZ);