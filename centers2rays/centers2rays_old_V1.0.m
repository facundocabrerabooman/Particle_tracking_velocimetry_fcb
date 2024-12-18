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
    
% loop over frames
    for k=1:numel(data)
       
% convert pixel coordinates into rays of light using the
% calibration interpolant
        [P,V]=findRays(calibInterpNcam,data(k).x',data(k).y');
        
% exclude particles for which rays are obtained by extrapolation
% outside the actually calibrated convex hull
        rayID=find((~isnan(P(:,1)))&(~isempty(P(:,1))));
        
% write results in file
        fwrite(fid,numel(rayID),'uint32');

        for kray=1:numel(rayID)
            fwrite(fid,camID(kcam),'uint8');
            fwrite(fid,rayID(kray),'uint16');
            fwrite(fid,P(rayID(kray),:),'float32');
            fwrite(fid,V(rayID(kray),:),'float32');
        end
    end
end
fclose(fid);
