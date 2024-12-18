load('calib');
nCams = 1;
nPlanes = 8;
dirIn = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/lowRe-1Dtracking/non-spherical/2nd_exp/analysis_usingPTV/calib/'

%% old way
% %% Create plane by plane center files 
% for k = 1:nCams
%     fid = fopen([dirIn filesep 'testCalib' filesep 'centers_cam' num2str(k) '.dat'],'w');
%     fprintf(fid,'%d\n',nPlanes);
%     
%     for kframe = 1:nPlanes
%         
%         pimg = vertcat(calib(kframe,k).pimg);
%         
%         x_px = pimg(:,1);
%         y_px = pimg(:,2);
%         
%         fprintf(fid,'%d\n',kframe-1);
%         fprintf(fid,'%d\n',numel(x_px));
%         for kpart=1:numel(x_px)
%             I=1;
%             %Ncrop=3;
%             %Imc=imcrop(Im,[max(0,round(x(kpart)-Ncrop)) max(0,round(y(kpart)-Ncrop)) 2*Ncrop+1 2*Ncrop+1]);
%             A=1;
%             fprintf(fid,'%6.3f %6.3f %d %d %6.3f %6.3f\n',x_px(kpart),y_px(kpart),I,I,A,A);
%         end
%     end
% end
% 
% %% Create ray files
% 
% data=centers2raysb([dirIn filesep 'testCalib'],[dirIn filesep 'testCalib'],[dirIn filesep 'calib'],[],[1 2]);

%% Create point by pointcenter files 

    pimg1 = vertcat(calib(:,1).pimg);
    pos1 = vertcat(calib(:,1).pos3D);
    
    pimg2 = vertcat(calib(:,2).pimg);
    pos2 = vertcat(calib(:,2).pos3D);
    
    [pos,ia,ib] = intersect(pos1,pos2,'rows');
    pimg1 = pimg1(ia,:);
    pimg2 = pimg2(ib,:);
    
    Nframes = numel(ia)
    
    fid = fopen([dirIn filesep 'testCalib' filesep 'centers_calibPoints_cam' num2str(1) '.dat'],'w');
    fprintf(fid,'%d\n',Nframes);
    for k = 1:Nframes
        x_px = pimg1(k,1);
        y_px = pimg1(k,2);
        
        fprintf(fid,'%d\n',k-1);
        fprintf(fid,'%d\n',1);
        I=1;
        %Ncrop=3;
        %Imc=imcrop(Im,[max(0,round(x(kpart)-Ncrop)) max(0,round(y(kpart)-Ncrop)) 2*Ncrop+1 2*Ncrop+1]);
        A=1;
        fprintf(fid,'%6.3f %6.3f %d %d %6.3f %6.3f\n',x_px,y_px,I,I,A,A);
    end
    
    fid = fopen([dirIn filesep 'testCalib' filesep 'centers_calibPoints_cam' num2str(2) '.dat'],'w');
    fprintf(fid,'%d\n',Nframes);
    for k = 1:Nframes
        x_px = pimg2(k,1);
        y_px = pimg2(k,2);
        
        fprintf(fid,'%d\n',k-1);
        fprintf(fid,'%d\n',1);
        I=1;
        %Ncrop=3;
        %Imc=imcrop(Im,[max(0,round(x(kpart)-Ncrop)) max(0,round(y(kpart)-Ncrop)) 2*Ncrop+1 2*Ncrop+1]);
        A=1;
        fprintf(fid,'%6.3f %6.3f %d %d %6.3f %6.3f\n',x_px,y_px,I,I,A,A);
    end


%% Create ray files

data=centers2raysb([dirIn filesep 'testCalib'],[dirIn filesep 'testCalib'],[dirIn filesep 'testCalib' filesep 'calib.mat'],'calibPoints_',[1 2]);

%% get measurement volume bounding box
pos3D = vertcat(calib.pos3D);
minBBox = min(pos3D)
maxBBox = max(pos3D)

 
%% match lines 

% run in a terminal the CPP mathcing code :
% ./STM /Users/mbourgoi/ownCloud/Recherche/SedimentationMagnetique/cam/test/8-oct-calib/rays_gamma1_p_3_.dat 50 50 50

%% plot
clf
[d,t,others] = readMatches('matched_calibPoints_.dat',999999);
hold on, plot3(d(:,2),d(:,3),d(:,4),'r*'), grid on
