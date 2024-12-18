%% CenterFinding in cutted regions
name_index = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x'];
cams = {'cam1', 'cam2'};

for pp = 1:21
    name = name_index(pp);
    
    for kcam = 1:2
       
        folderin = '/Users/FC/Doctorat/Quiescent_flow/Calibration/calibration/Nov_non3Dparticles/vertical/chain22nov_cam1 copy/JPG';
        folderout = '/Users/FC/Doctorat/Quiescent_flow/Calibration/calibration/Nov_non3Dparticles/vertical/';
        
        fname = ['chain22-nov_'];
        cam = cams{kcam};
        plotflag = 1;
        videoflag = 1;
        tic
        centers=CenterFinding2D(folderin,folderout,fname,1,1)
        toc
        save([folderout fname 'CC' cam],'CC')
    end
end

%% Centers2raysb

folderin = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/2D-tracking/Dec1_path_inst_fluid2/3dec/centers';
folderout = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/2D-tracking/Dec1_path_inst_fluid2/3dec/centers';

%folderout=folderin;
name_index = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'];

for mm = 1:21
name_i = name_index(mm);
    fname = ['3-dec_' name_i '_']
try
datacam=centers2raysb(folderin,folderout,'calib.mat',fname,[1 2]);
catch
end
end
%%  STM.py

%% Plot
%clf
folderout = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/2D-tracking/Dec1_path_inst_fluid2/3dec/centers';
folderout_positions = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/2D-tracking/Dec1_path_inst_fluid2/3dec/positions';
name_index = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'];

for mm = 1:21
%mm=1
name_i = name_index(mm);
fname = ['matched_3-dec_' name_i ]
figure(99)
[d,t,others] = readMatches([folderout filesep fname '_.dat'],999999);
try
hold on, plot3(d(:,2),d(:,3),d(:,4),'.'), grid on
catch
end

save([folderout_positions filesep 'positions_' fname], 'd' , 't', 'others')

end




