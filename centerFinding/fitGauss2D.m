function [fitresult, gof] = createFit(xpx, ypx, Ip)
%CREATEFIT(XPX,YPX,IP)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : xpx
%      Y Input : ypx
%      Z Output: Ip
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 30-Apr-2019 16:11:48


%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( xpx, ypx, Ip );

% Set up fittype and options.
ft = fittype( 'a*exp(-b*((x-c).^2+(y-d).^2))+c', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -1 -1 -1];
opts.Robust = 'LAR';
opts.StartPoint = [65000 0.0004 0 0];
opts.Upper = [66000 1 1 1];

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, 'untitled fit 1', 'Ip vs. xpx, ypx', 'Location', 'NorthEast' );
% Label axes
% xlabel xpx
% ylabel ypx
% zlabel Ip
% grid on
% view( 94.9, 90.0 );


