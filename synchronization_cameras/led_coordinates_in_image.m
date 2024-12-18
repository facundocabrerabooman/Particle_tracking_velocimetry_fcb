function [xi,xf,yi,yf] = led_coordinates_in_image(cam_name)
%% led coordinates in image
% using this we can remove it when we track particles

%im = Im(xi:xf,yi:yf); %in this way you're supposed to cut 
%% find xixfyiyf
%folderin = ;
%files = dir([folderin '*.DNG' ]); im = imread([folderinfiles(15001).name]); imshow(im)
%% values 
% CAM3==CAM1
%%%%%%%%%% 20oct
%disp('20-oct way of cutting led'), pause
% if cam_name == 'cam1'
% xi = 430;xf = 720; yi = 1030; yf = 1280; %cam3
% else if cam_name == 'cam2'
% xi = 1;xf = 230; yi = 1; yf = 230; %cam31
% end
%%%%%%%%%% 21oct
% if cam_name == 'cam1'
% xi = 560;xf = 720; yi = 1120; yf = 1280; %cam3
% else if cam_name == 'cam2'
% xi = 1;xf = 130; yi = 1; yf = 130; %cam31
% end
%%%%%%%%%% 22 nov
if cam_name == 'cam1'
xi = 1;xf = 160; yi = 1060; yf = 1280; %cam31
else if cam_name == 'cam2'
xi = 1;xf = 180; yi = 900; yf = 1280; %cam2
end
end