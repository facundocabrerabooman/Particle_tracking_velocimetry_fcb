folderin=['/Users/mbourgoi/Documents/Recherche/LEM/Sander/TracersHIT/Calibration/calibPoints'];
Ncams=3;

%%
for kcam=1:Ncams
    fname=[folderin filesep 'cam_' num2str(kcam-1) '_calibrationpoints.csv'];    
    calibPts=csvread(fname);
    [calibInterp,X_px,Y_px,V]=calibInterpLEM(calibPts,800,1280);
    calibInterp(kcam).calibInterp=calibInterp;    
end

%%
save calibInterpCFG.mat calibInterp
