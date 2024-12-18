function datacam=centers2raysc_sync_cams(folderin,folderout,calibInterpCfg,fname,camID,shift_on_frames)

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
for kcam=1:numel(camID)
    % select calibration for camera camID(kcam)
    calibNcam=calib(:,camID(kcam));
   
    % load centers for camera camID(kcam)
    fileCenters=[folderin filesep 'centers_' fname 'cam' num2str(camID(kcam)) '.dat'];
    datatmp=readCentersTxt(fileCenters);
    data = datatmp;
    Nframes = numel(data);%
    
    kframes = 1;
    %% MOVE THE CENTERS FILE TO MAXIMIZE MATCH ACCURACY 
    init_frame = 1;
    if kcam==1 
        init_frame = shift_on_frames; 
    end
    
    %%
    % loop over frames
    for k = [init_frame+100 init_frame+round(Nframes/7.5) init_frame+round(Nframes/5) init_frame+round(Nframes/2.5)]
        if rem(k,100)==0
            k;
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
for kframe=[init_frame+100 init_frame+round(Nframes/7.5) init_frame+round(Nframes/5) init_frame+round(Nframes/2.5)]

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
