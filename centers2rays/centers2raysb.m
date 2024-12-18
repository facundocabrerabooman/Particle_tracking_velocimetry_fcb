function datacam=centers2raysb(folderin,folderout,calibInterpCfg,fname,camID)

%
% [P,V]=centers2Rays(folderin,folderout,calibInterpCfg,prefix,Nmes,camID)
%
%   For a given set of calibration interpolanst and center files with
%   pixel positions, determines the corresponding rays of light.
%   camID is an array containing the IDs of the cameras center files to be
%   processed (for instance camID=[0 1 2] for a 3 cameras tracking
%   experiment).
%
%%
if isdeployed
    camID=str2num(camID);
end
% 540 550 570 540 560 545 555 552 551 530
%Ibeg = [530 551];
%NN = 1700;


%[P,V]=arrayfun(@(X)(findRays(calibInterpNcam,X.x',X.y')),data,'UniformOutput',false);

% Load calibration file (which contains calibration interpolants for all
% cameras).


load(calibInterpCfg);


% Open results ray file
fileRays=[folderout filesep 'rays_' fname '.dat']
if ~isdir(folderout)
    mkdir(folderout);
end

fid=fopen(fileRays,'w');

% Loop over cameras
for kcam=2:numel(camID)
    % select calibration for camera camID(kcam)
    
    % old version with interpolant
    % calibNcam=calibInterp(camID(kcam)+1).calibInterp;
    
    % new version without interpolant
    calibNcam=calib(:,camID(kcam));
    
    % load centers for camera camID(kcam)
    fileCenters=[folderin filesep 'centers_' fname 'cam' num2str(camID(kcam)) '.dat']
    datatmp=readCentersTxt(fileCenters);
    % data=datatmp(Ibeg(kcam):Ibeg(kcam)+NN-1);
    %Nframes = NN;
    
    data = datatmp;
    
    %Nframes= numel(data); %original. I'VE HAVE TO REMOVE THIS FOR CHAIN
    %ANALISIS, FOR THE FOR IN L.90 I KEEP THE NFRAMES OF CAM2 AND IF IT IS
    %BIGGER THAN NFRAMES CAM1 I GET AN ERROR
    Nframes(kcam)= numel(data);
    
    kframes = 1;
    
    % loop over frames
    for k = 1:Nframes(kcam)
        if rem(k,100)==0
            k
        end
        % convert pixel coordinates into rays of light using the
        % calibration interpolant
        [P,V]=findRays(calibNcam,data(k).x',data(k).y');
        % exclude particles for which rays are obtained by extrapolation
        % outside the actually calibrated convex hull
        if ~isempty(P)
            rayID=find((~isnan(P(:,1)))&(~isempty(P(:,1))));
            if ~isempty(rayID)
                data(kframes).P=P(rayID,:);
                data(kframes).V=V(rayID,:);
                data(kframes).rayID=rayID;
                kframes = kframes + 1;
            end
        else
                data(kframes).P=[];
                data(kframes).V=[];
                data(kframes).rayID=[];
                kframes = kframes + 1;
        end
    end
    datacam(kcam).data=data;
end

%%
% write results in file

%for kframe=1:Nframes % original
for kframe=1:min(Nframes)

    Nrays=0;
    for kcam=1:numel(camID)
        Nrays = Nrays + numel(datacam(kcam).data(kframe).rayID);
    end
    fwrite(fid,Nrays,'uint32');
    
    for kcam=1:numel(camID)
        for kray=1:numel(datacam(kcam).data(kframe).rayID)
            fwrite(fid,camID(kcam),'uint8');
            fwrite(fid,datacam(kcam).data(kframe).rayID(kray),'uint16');
            fwrite(fid,datacam(kcam).data(kframe).P(kray,:),'float32');
            fwrite(fid,datacam(kcam).data(kframe).V(kray,:),'float32');
        end
    end
end

fclose(fid);
