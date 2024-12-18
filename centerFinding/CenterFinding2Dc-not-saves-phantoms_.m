function CC = CenterFinding2Dc(folderin,folderout, fname, cam, plot_flag, video_flag)
%
One particle tracking in fps1000 cameras (using .jpg or .dng)


% Find centers

folderout

if exist(folderout,'dir')==0
    mkdir(folderout);
end


switch cam                  %so i do not have to rename the files all the time
    case 'cam1'
        fid = fopen([folderout filesep 'centers_' fname 'cam1' '.dat'],'w');
    case 'cam2'
        fid = fopen([folderout filesep 'centers_' fname 'cam2' '.dat'],'w');
end


if ~isempty(dir([folderin filesep '*.DNG']))
    images_format = 'DNG'
    files = dir([folderin filesep '*.DNG' ]);
else if  ~isempty(dir([folderin filesep '*.JPG']))
        images_format = 'JPG'
        tic; files = dir([folderin filesep '*.JPG' ]); toc
    end
end
    
    
    nframes = numel(files);
    fprintf(fid,'%d\n',nframes);
    
    if video_flag==1
        %video
        video = VideoWriter([folderout fname cam '.avi']); %create the video object
        video.FrameRate = 1400;
        open(video);
    end
    %%
    index_no_particles_found = 0; CC=[];
    for kframe=1:nframes %START IN 3 WHEN YOU HAVE A WAKE, ALSO CHANGE IMPORT IM0
        kframe/(nframes)
        if files(kframe).name(1) == '.' files(kframe).name(1:2) = []; end  %some files start with ._
        if files(1).name(1) == '.' files(1).name(1:2) = []; end  %some files start with ._
        
        im_original = imread([folderin filesep files(kframe).name]);
        
        
        im0 = imread([folderin filesep files(nframes).name]); %WHEN NO WAKE
        im0 = imread([folderin filesep files(kframe-1).name]);  %WHEN WAKE
        
        im = rgb2gray(im_original);
        im_original = rgb2gray(im_original);
        im0 = rgb2gray(im0);
        
        % cut led from image
        switch cam
            case 'cam1'
                [xi,xf,yi,yf] = led_coordinates_in_image('cam1'); % get places to cut out led
                im_original(xi:xf,yi:yf) = 0;  %cut out led using values from led_coordinates_in_image
                im(xi:xf,yi:yf) = 0;
                im0(xi:xf,yi:yf) = 0;
            case 'cam2'
                [xi,xf,yi,yf] = led_coordinates_in_image('cam2');
                im_original(xi:xf,yi:yf) = 0;
                im(xi:xf,yi:yf) = 0;
                im0(xi:xf,yi:yf) = 0;
        end
        %
        im=imsubtract(imcomplement(im),imcomplement(im0)); % remove background (im0) of im
        im = imbinarize(im);
        
        size_strel = 10;
        dd = strel('disk',size_strel);  % smaller than particle, it's just for elminate crap in image of size size_strel
        
        im = imopen(im,dd);
        Bw = imregionalmax(im);
        PP=regionprops(Bw,im,'Centroid','Area','MajorAxisLength','MinorAxisLength','Orientation');
        %
        PP.Centroid
        if ~isempty(PP.Centroid)
            if ~(PP.Centroid == [640.5 360.5]) %delete phantoms. When there isn't particle detects a phantom in center of image
                kframe = kframe - index_no_particles_found(end) ;
                
               PP = PP(max(PP.Area));
                cc=[PP.Centroid];
                Ma=[PP.MajorAxisLength];
                ma=[PP.MinorAxisLength];
                O = [PP.Orientation];
                A = [PP.Area];
                x=cc(:,1); %beofre
                y=cc(:,2);
                CC(kframe).X=x';
                CC(kframe).Y=y';
                CC(kframe).Ma=Ma';
                CC(kframe).ma=ma';
                CC(kframe).O=O';
                CC(kframe).A=A';
                % checking plots
                if plot_flag == 1
                    if kframe/10 == round(kframe/10)     %plot each 40 steps
                       clf, imshow(im), hold on
                        plot([CC.X],[CC.Y],'r.');title(num2str(kframe)), pause(0.5)
                        if video_flag == 1 writeVideo(video,getframe(gcf)); end
                    end
                end
                
                plot orientation
                    hlen = Ma/2;
                    cosOrient = cosd(O);
                    sinOrient = sind(O);
                    xcoords = cc(1) + hlen .* [cosOrient -cosOrient];
                    ycoords = cc(2) + hlen .* [-sinOrient sinOrient];
                    line(xcoords, ycoords,'LineWidth' , 5); pause(0.2)
                
                %
                fprintf(fid,'%d\n',kframe-1);  %original
                fprintf(fid,'%d\n',kframe); %fc tried this
                fprintf(fid,'%d\n',numel(x));
                for kpart=1:numel(x)
                    I=im_original(round(y(kpart)),round(x(kpart)));
                    Ncrop=3;
                    Imc=imcrop(Im,[max(0,round(x(kpart)-Ncrop)) max(0,round(y(kpart)-Ncrop)) 2*Ncrop+1 2*Ncrop+1]);
                    A=numel(find(Imc>I/3));
                    CC(kframe).I(kpart)=I;
                    CC(kframe).A(kpart)=A;
                    fprintf(fid,'%6.3f %6.3f %d %d %6.3f %6.3f\n',x(kpart),y(kpart),A,O,Ma,ma);
                    
                end
                
                  find centers by 2 1D gaussian fits around maxima (x,y)
                
                    out=gauss2D_cntrd(Im,[round(x) round(y)],8);
                    CC(k).X = out(:,1);  % x center
                    CC(k).Y = out(:,2);  % y center
                    CC(k).Gax = out(:,3); % gaussian amplitude in x direction
                    CC(k).Gay = out(:,4); % gaussian amplitude in y direction
                    CC(k).Gsx = out(:,5); % gaussian width in x direction
                    CC(k).Gsy = out(:,6); % gaussian width in y direction
                
                
                
                    find centers by segmeting the image around maxima (x,y)
                
                    BW=imsegfmm(Im(:,:,1),round(x),round(y),.05);
                    PP=regionprops('table',BW,'Centroid','FilledArea','Eccentricity');
                
                    CC(k).X=PP.Centroid(:,1);
                    CC(k).Y=PP.Centroid(:,2);
                    CC(k).A=PP.FilledArea;
                    CC(k).E=PP.Eccentricity;
                
                
                  find centers by imfindcircles
                
                  [Ctmp,Rtmp] = imfindcircles(Imf,R_range,'EdgeThreshold',0.05,'Sensitivity',0.85);
                    C(k).X=Ctmp(:,1);
                    C(k).Y=Ctmp(:,2);
                    C(k).R=Rtmp;
                    C(k).T=k;
            else index_no_particles_found=[kframe index_no_particles_found];
            end
        else index_no_particles_found=[kframe index_no_particles_found];
        end
    end
    toc
    fclose(fid);
    
    if video_flag==1
        close(video)
    end
    
    % %% Track
    T=reshape(ones(1,N)'*(1:numel(C)),N*numel(C),[]);
    X=reshape([C.X],N*numel(C),[]);
    Y=reshape([C.Y],N*numel(C),[]);
    [tracks_lmin,tracks,t_start_stop]=track2d([X Y T],50,500);
    
    %% convert tracks structure to vtracks
    Ntracks=max(tracks(:,4));
    for k=1:Ntracks
        I=find(tracks(:,4)==k);
    	vtracks(k).X=tracks(I,1);
        vtracks(k).Y=tracks(I,2);
        vtracks(k).T=tracks(I,3);
    end
    figure(10), imshow(im), hold on
    x= [CC.X]; y= [CC.Y]; plot(x,y,'.r')
    savefig([folderout fname 'traj2D_' cam])
end
