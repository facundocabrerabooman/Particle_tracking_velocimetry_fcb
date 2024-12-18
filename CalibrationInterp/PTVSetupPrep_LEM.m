%%
ncams=3;

for icam = 0:ncams-1
     filesCam=dir(['cam_' num2str(icam) '*']);
%     pimgAll=[];
%     pos3DAll=[];
%     for k=1:numel(dirPlanes)
%         cd(dirPlanes(k).name);
%         fileCalib=dir('calib*.mat');
%         load(fileCalib.name);
%         pimgAll=[pimgAll ; pimg];
%         pos3DAll=[pos3DAll ; pos3D];
%         cd ..;
%     end
%     clear T Tinv k fileCalib dirPlanes pimg pos3D;
        
    M = csvread(filesCam.name);
    pimg=[M(:,1) M(:,2)];
    pos3D=[M(:,3) M(:,4) M(:,5)];
    Npix_x=1280;
    Npix_y=800;
    camParaknown.Npixh = Npix_y;
    camParaknown.Npixw = Npix_x;
    camParaknown.hpix = 0.020;	% pixel size (mm)
    camParaknown.wpix = 0.020;	% pixel size (mm)
    camParaCalib(icam+1) = calib_Tsai(pimg, pos3D, camParaknown);
    
end
%%
% Now write the configuration file
dirResults='/Users/mbourgoi/Documents/Recherche/LEM/Sander/TracersHIT/Calibration/';

fid = fopen([dirResults filesep 'PTVSetupPrep.cfg'], 'w');
fprintf(fid, '# PTV experiment configuration file\n');
fprintf(fid, '\n %d\t# ncams\n\n', ncams);

for icam = 1:ncams
    fprintf(fid, '######## cam %d ########\n\n', icam-1);
    fprintf(fid, '%d\t\t\t# Npix_x\n', Npix_x);
    fprintf(fid, '%d\t\t\t# Npix_y\n', Npix_y);
    fprintf(fid, '%11.8f\t\t\t# pixsize_x (mm)\n', camParaCalib(icam).wpix);
    fprintf(fid, '%11.8f\t\t# pixsize_y (mm)\n', camParaCalib(icam).hpix);
    fprintf(fid, '%12.8f\t\t# effective focal length (mm)\n', camParaCalib(icam).f_eff);
    % Note the sign change for k1, because its meaning is different in calib_Tsai and the stereomatching code
    fprintf(fid, '%15.8e\t\t# radial distortion k1 (1/pixel)\n', -(camParaCalib(icam).k1));
    fprintf(fid, '%15.8e\t\t# tangential distortion p1 (1/pixel)\n', camParaCalib(icam).p1);
    fprintf(fid, '%15.8e\t\t# tangential distortion p2 (1/pixel)\n', camParaCalib(icam).p2);
    fprintf(fid, '0.0\t\t\t# x0\n');
    fprintf(fid, '0.0\t\t\t# y0\n');
    fprintf(fid, '%6.6f\t\t\t# x0 offset\n', camParaCalib(icam).x0offset);
    fprintf(fid, '%6.6f\t\t\t# y0 offset\n', camParaCalib(icam).y0offset);
    fprintf(fid, '%6.6f\t\t\t# x rot (cos(phi))\n', camParaCalib(icam).xrot);
    fprintf(fid, '%6.6f\t\t\t# y rot (sin(phi))\n', camParaCalib(icam).yrot);
    fprintf(fid, '# rotation matrix R\n');
    fprintf(fid, '%12.8f\t%12.8f\t%12.8f\n', (camParaCalib(icam).R)');
    fprintf(fid, '# translation vector T\n');
    fprintf(fid, '%15.8f\n', camParaCalib(icam).T);
    fprintf(fid, '# inverse rotation matrix Rinv\n');
    fprintf(fid, '%12.8f\t%12.8f\t%12.8f\n', (camParaCalib(icam).Rinv)');
    fprintf(fid, '# inverse translation vector Tinv\n');
    fprintf(fid, '%15.8f\n', camParaCalib(icam).Tinv);
    fprintf(fid, '# rms distance between particle centers found on image plane and their projections\n');
    fprintf(fid, '# %15.8f\t\t# err_x\n', camParaCalib(icam).err_x);
    fprintf(fid, '# %15.8f\t\t# err_y\n', camParaCalib(icam).err_y);
    fprintf(fid, '# %15.8f\t\t# err_t\n', camParaCalib(icam).err_t);
    fprintf(fid, '\n');
end

fprintf(fid,'##### laser beam #####\n');

fprintf(fid,'0		# finite volume illumination\n');
fprintf(fid,'0		# illum_xmin\n');
fprintf(fid,'0		# illum_xmax\n');
fprintf(fid,'0		# illum_ymin\n');
fprintf(fid,'0		# illum_ymax\n');
fprintf(fid,'0		# illum_zmin\n');
fprintf(fid,'0		# illum_zmax\n');

fprintf(fid,'#### thresholds for 3D matching ####\n');

fprintf(fid,'15		# mindist_pix (pixel)\n');
fprintf(fid,'5		# maxdist_3D (mm)\n');

fclose(fid);