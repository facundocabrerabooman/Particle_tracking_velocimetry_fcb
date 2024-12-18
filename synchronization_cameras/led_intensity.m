function led_intensity(folderin_cam1,folderin_cam2, folderout, name, images_format, videoflag, plotflag, varargin)
%folderin = '/Volumes/LaCie-FC/9-oct-62percgly/21-oct/cam3/JPG/';
%name = 'cam3_21oct';
tic
%% notes
%folderin = folder where images are
%name = string with name
%images_format = 'JPG' or 'DNG'
%videoflag = 1 if you want a video of led

%% 
nargin
if nargin == 7
if images_format == 'DNG'
    files_cam1 = dir([folderin_cam1 '*.DNG' ]);
    files_cam2 = dir([folderin_cam2 '*.DNG' ]);
else
    disp('Loading files')
    tic
    files_cam1 = dir([folderin_cam1 '*.JPG' ]); toc
    tic
    files_cam2 = dir([folderin_cam2 '*.JPG' ]); toc
end
elseif nargin == 9
    disp('Files pre-loaded')
    files_cam1 = varargin{1};
    files_cam2 = varargin{2};
end

var_name = genvarname(['intensity_' name ]);
eval([var_name '= [];'])

if videoflag == 1
    video = VideoWriter([folderout name '.avi']); %create the video object
    video.FrameRate = 100;
    open(video);
end
%%
intensities=[];
    N = min(numel(files_cam1),numel(files_cam2));
for ii=1:N
    ii/N
    
    %%
    if images_format == 'DNG'
        %%%cam1
        t1 = Tiff([folderin_cam1 files_cam1(ii).name],'r');
        offsets = getTag(t1,'SubIFD');   % read DNG file
        setSubDirectory(t1,offsets(3));
        im1 = read(t1);
        close(t1);
        %%%cam2
        t2 = Tiff([folderin_cam2 files_cam2(ii).name],'r');
        offsets = getTag(t2,'SubIFD');   % read DNG file
        setSubDirectory(t2,offsets(3));
        im2 = read(t2);
        close(t2);
    else
        
        im1 = imread([folderin_cam1 files_cam1(ii).name]); %read JPG
        im2 = imread([folderin_cam2 files_cam2(ii).name]); %read JPG
    end
    %% cam1
    [xi,xf,yi,yf] = led_coordinates_in_image('cam1'); % get places to cut out led
    im1 = im1(xi:xf,yi:yf); %cut out led using values from led_coordinates_in_image
    im1=im2double(im1);
    intensities(ii).cam1 = mean2(im1);
    
    %% cam2
    [xi,xf,yi,yf] = led_coordinates_in_image('cam2'); % get places to cut out led
    im2 = im2(xi:xf,yi:yf); %cut out led using values from led_coordinates_in_image
    im2=im2double(im2);
    intensities(ii).cam2 = mean2(im2);
    %%
     if plotflag==1
         figure(100), subplot(1,2,1),imshow(im1);subplot(1,2,2),imshow(im2),pause(0.2)
     end
    if videoflag == 1
        writeVideo(video,getframe(gcf));
    end
end
eval([var_name '= intensities']);

if videoflag==1 close(video); end

save([folderout name], 'intensities');
toc
