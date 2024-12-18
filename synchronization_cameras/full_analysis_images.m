%% Step zero 

edit led_coordinates_in_image.m

%% Get led's signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderin_cam1 = '/Volumes/home/Experiments/Nov19_path_inst/22nov/22nov_cam1/JPG/' ;
folderin_cam2 = '/Volumes/home/Experiments/Nov19_path_inst/22nov/22nov_cam2/JPG/' ;
folderled = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/new_container/2D-tracking/Nov_non3Dparticles/led/';
name = '22-nov';
videoflag = 1;
plotflag = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if you want to preload the images:
disp('files1')
files_cam1 = dir([folderin_cam1 filesep '*.JPG' ])
disp('files2')
files_cam2 = dir([folderin_cam2 filesep '*.JPG' ])

led_intensity(folderin_cam1, folderin_cam2, folderled, name, 'JPG',videoflag, plotflag, files_cam1, files_cam2)


%% Get indexes to split video into realizations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderled = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/31-oct/led/';
date_exp = '31-oct';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_index_realizations(folderled, date_exp)
cd(folderled)
savefig('peaks'); cd ..
%% Create new folders with images syncronized

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderin_cam1 = '/Volumes/LaCie-FC/9-oct-62percgly/31-oct/31oct_cam1_cam3/' ;
folderin_cam2 = '/Volumes/LaCie-FC/9-oct-62percgly/31-oct/31oct_cam2_cam31/JPG/' ;
folderled = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/31-oct/led/';
folderout = '/Volumes/LaCie-FC/9-oct-62percgly/31-oct/';
date_exp = '31-oct_';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('files1')
%files_cam1 = dir([folderin_cam1 filesep '*.JPG' ])
disp('files2')
%files_cam2 = dir([folderin_cam2 filesep '*.JPG' ])


freq_leds = [10;20;30;10;20;30;10;20;30;10;20;30;10;20;30;10;20;30;10;20;30;10;20;30;10;20;30];
name_index = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x'];
for ii=3:21
    realization = ii;              %realization number
    name = [date_exp name_index(ii)]
    freq_led = freq_leds(ii);
    
    new_folder_sync_images(folderout, folderin_cam1, folderin_cam2, folderled, name, files_cam1, files_cam2, realization, freq_led)
end

%% CenterFinding in cutted regions
name_index = ['a' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x'];
cams = {'cam1', 'cam2'};

for pp = 12:21
    name = name_index(pp);
    
    for kcam = 1:2
       
        folderin = ['/Volumes/LaCie-FC/9-oct-62percgly/1-nov/1-nov_' name '/1-nov_' name '_cam' num2str(kcam)];
        folderout = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/1-nov/centers/';
        fname = ['1-nov_' name '_'];
        cam = cams{kcam};
        plotflag = 0;
        videoflag = 0;
        tic
        CC = CenterFinding2Dc_savesphantoms(folderin,folderout,fname,cam, plotflag, videoflag)
        toc
        save([folderout fname 'CC' cam],'CC')
    end
end
%% Centers2rays

%% For in shift between images

precision = []; distances=[]; shift_dist = 0; precision = [0 2e4; 0 4e4];
while precision(2,2) > precision(1,2)
    shift_dist = shift_dist + 1
    datacam=centers2raysd_shiftedimages(folderout,folderout,'calib.mat',fname,[1 2],shift_dist);
    
    for kk = 1:size(datacam(1).data,2)
        if ~isempty(datacam(1).data(kk).P) && ~isempty(datacam(2).data(kk).P)
            [dist Pc Qc]=distBW2lines([datacam(1).data(kk).P ; datacam(1).data(kk).P + datacam(1).data(kk).V],[datacam(2).data(kk).P; datacam(2).data(kk).P + datacam(2).data(kk).V]);
            distances=[distances dist] ;
            mean(distances)
        end
    end
    precision = [shift_dist mean(distances) ; precision]
    distances=[];
end
precision(end,:) = []; precision(end-1,:) = []; % crap values I created just for enter to while
optimal_shift = precision(2,1);
% 
%% Centers2raysb

folderin = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/1-nov/centers';
%folderout = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/20-oct/centers';
folderout=folderin;
fname = ['1-nov_' 'd' '_'];

datacam=centers2raysb(folderin,folderout,'calib.mat',fname,[1 2]);

%%  STM.py

%% Plot
%clf
[d,t,others] = readMatches([folderout filesep 'matched_1-nov_e_.dat'],999999);
hold on, plot3(d(:,2),d(:,3),d(:,4),'.'), grid on
stop
save([folderout_positions filesep 'positions_' fname], 'd' , 't', 'others')



