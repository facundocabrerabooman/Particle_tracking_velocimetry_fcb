%% Step zero 

edit led_coordinates_in_image.m

%% Get led's signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderin_cam1 = '/Volumes/LaCie-FC/9-oct-62percgly/31-oct/31oct_cam1_cam3/' ;
folderin_cam2 = '/Volumes/LaCie-FC/9-oct-62percgly/31-oct/31oct_cam2_cam31/JPG/' ;
folderled = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/31-oct/led/';
name = '31-oct';
videoflag = 0;
plotflag = 0;
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
name_index = ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x'];
cams = {'cam1', 'cam2'};

for pp = 1%:21
    name = name_index(pp);
    
    for kcam = 1%:2
       
        %folderin = ['/Volumes/LaCie-FC/9-oct-62percgly/1-nov/1-nov_' name '/1-nov_' name '_cam' num2str(kcam)];
       % folderout = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/1-nov/centers/';
        
        folderin = ['/Users/FC/Doctorat/Quiescent_flow/Calibration/calibration/Nov_non3Dparticles/vertical/chain22nov_cam1 copy/JPG']
        folderout = '/Users/FC/Doctorat/Quiescent_flow/Calibration/calibration/Nov_non3Dparticles/vertical/';
        
        %fname = ['22-nov_' name '_'];
        fname = ['chain22-nov_'];
        cam = cams{kcam};
        plotflag = 1;
        videoflag = 1;
        tic
        %CC = CenterFinding2Dc_savesphantoms(folderin,folderout,fname,cam, plotflag, videoflag)
        centers=CenterFinding2D(folderin,folderout,fname,1,1)
        toc
        save([folderout fname 'CC' cam],'CC')
    end
end
%% Centers2rays

%% For in shift between images

% precision = []; distances=[]; shift_dist = 0; precision = [0 2e4; 0 4e4];
% while precision(2,2) > precision(1,2)
%     shift_dist = shift_dist + 1
%     datacam=centers2raysd_shiftedimages(folderout,folderout,'calib.mat',fname,[1 2],shift_dist);
%     
%     for kk = 1:size(datacam(1).data,2)
%         if ~isempty(datacam(1).data(kk).P) && ~isempty(datacam(2).data(kk).P)
%             [dist Pc Qc]=distBW2lines([datacam(1).data(kk).P ; datacam(1).data(kk).P + datacam(1).data(kk).V],[datacam(2).data(kk).P; datacam(2).data(kk).P + datacam(2).data(kk).V]);
%             distances=[distances dist] ;
%             mean(distances)
%         end
%     end
%     precision = [shift_dist mean(distances) ; precision]
%     distances=[];
% end
% precision(end,:) = []; precision(end-1,:) = []; % crap values I created just for enter to while
% optimal_shift = precision(2,1);
% 
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




