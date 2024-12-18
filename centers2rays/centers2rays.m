function [P,V]=centers2Rays(folderin,folderout,calibInterpCfg,prefix,Nmes,camID)

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
    Nmes=str2double(Nmes);
    camID=str2num(camID);
end

%[P,V]=arrayfun(@(X)(findRays(calibInterpNcam,X.x',X.y')),data,'UniformOutput',false);

% Load calibration file (which contains calibration interpolants for all
% cameras).
load(calibInterpCfg);

% Open results ray file
fileRays=[folderin filesep 'rays_' prefix num2str(Nmes) '.dat']
fid=fopen(fileRays,'w');

% Loop over cameras
for kcam=1:numel(camID)
    % select calibration for camera camID(kcam)
    calibInterpNcam=calibInterp(camID(kcam)+1).calibInterp;
    
    % load centers for camera camID(kcam)
    fileCenters=[folderin filesep 'centers_' prefix num2str(Nmes) '.cam' num2str(camID(kcam)) '.dat']
    data=readCentersTxt(fileCenters);
    Nframes = numel(data)
    
    % loop over frames
    for k=1:Nframes
        if rem(k,100)==0
            k
        end
        % convert pixel coordinates into rays of light using the
        % calibration interpolant
        [P,V]=findRays(calibInterpNcam,data(k).x',data(k).y');
        
        % exclude particles for which rays are obtained by extrapolation
        % outside the actually calibrated convex hull
        rayID=find((~isnan(P(:,1)))&(~isempty(P(:,1))));
        data(k).P=P(rayID,:);
        data(k).V=V(rayID,:);
        data(k).rayID=rayID;
        
    end
    datacam(kcam).data=data;
end

%%
% write results in file
for kframe=1:Nframes
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
