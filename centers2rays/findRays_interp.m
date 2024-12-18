function [P,V]=findRays(calibInterp,x_px,y_px)

x=calibInterp(1).f(x_px,y_px);
y=calibInterp(2).f(x_px,y_px);
z=calibInterp(3).f(x_px,y_px);
u=calibInterp(4).f(x_px,y_px);
v=calibInterp(5).f(x_px,y_px);
w=calibInterp(6).f(x_px,y_px);

P=[x y z];
V=[u v w];

