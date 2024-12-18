function new_folder_sync_images(folderout, folderin_cam1, folderin_cam2, folderled, name, files_cam1, files_cam2, varargin)

%% defs

%folderout = '/Volumes/LaCie-FC/9-oct-62percgly/21-oct/cutted/';
%folderin_cam2 = '/Volumes/LaCie-FC/9-oct-62percgly/21-oct/cam31/JPG/';
%folderin_cam1 = '/Volumes/LaCie-FC/9-oct-62percgly/21-oct/cam3/JPG/';
%folderled = '/Users/FC/Doctorat/Quiescent_flow/Matlab-track-analysis/magnets_linearB/new_container/2D-tracking/octobre/20-oct/';

%% SYNC CAMERAS
if nargin == 8
    %%% which run do you want to analyse
    prompt = 'Realization number:';
    l = input(prompt,'s');
    l=str2double(l);
    %%%
else if nargin >7
        l = varargin{1}
    end
end
if nargin == 9
            freq_led = varargin{2}
end
    %%%
    tol = 700 ; %frames cutted after the limits of sin wave
    load([folderled 'led_intensity_peaks'])
    %disp('change this, inly valid for 24 oct cause of rule images'), pause(5)
   %%%
      %% neutral values
   
    initial_frame_in_led_cam1 = data_intensity_led(1).locs(2*l-1)-tol;
    initial_frame_in_led_cam2 = data_intensity_led(2).locs(2*l-1)-tol;
    
    if numel(data_intensity_led(1).locs) <~ 2*l+1       %for the last realization in video
        final_frame_in_led_cam1 = numel(data_intensity_led(1).i_cam1);
        final_frame_in_led_cam2 = numel(data_intensity_led(2).i_cam2);
    else
        final_frame_in_led_cam1 = data_intensity_led(1).locs(2*l)-tol/2;
        final_frame_in_led_cam2 = data_intensity_led(2).locs(2*l)-tol/2;
    end
    
   %% 21 oct values of peaks
%    disp('21 oct values of peaks'), pause(2)
%    
%     initial_frame_in_led_cam1 = data_intensity_led(1).locs(2*l+7)-tol;
%     initial_frame_in_led_cam2 = data_intensity_led(2).locs(2*l+1)-tol;
%     
%     if numel(data_intensity_led(1).locs) <~ 2*l+1       %for the last realization in video
%         final_frame_in_led_cam1 = numel(data_intensity_led(1).i_cam1);
%         final_frame_in_led_cam2 = numel(data_intensity_led(2).i_cam2);
%     else
%         final_frame_in_led_cam1 = data_intensity_led(1).locs(2*l+8)-tol/2;
%         final_frame_in_led_cam2 = data_intensity_led(2).locs(2*l+2)-tol/2;
%     end
%     
    %%
    i_cam1_cutted = data_intensity_led(1).i_cam1(initial_frame_in_led_cam1:final_frame_in_led_cam1);
    i_cam2_cutted = data_intensity_led(2).i_cam2(initial_frame_in_led_cam2:final_frame_in_led_cam2);
    
    %disp('syncCam off!!!')
    syncCam; 
 %i_cam1_cutted_sync = i_cam1_cutted;
 %  i_cam2_cutted_sync = i_cam2_cutted;
    %%
    %%% plots to check
    subplot(1,2,1)
    plot(data_intensity_led(2).i_cam2,'g'), hold on, plot(data_intensity_led(1).i_cam1,'r'), hold on
    plot((1:1:numel(i_cam1_cutted))+initial_frame_in_led_cam1,i_cam1_cutted),hold on,plot((1:1:numel(i_cam2_cutted))+initial_frame_in_led_cam2,i_cam2_cutted), title('Entire signal + cutted part')
    subplot(1,2,2)
    plot(i_cam1_cutted_sync); hold on; plot(i_cam2_cutted_sync); title('Signals synchronized')
    savefig([folderout filesep name]), close all
    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAKE COPIES
    % cam3 == cam1
    mkdir([folderout name filesep name '_cam1'])
    mkdir([folderout name filesep name '_cam2'])
%     
%     files_cam1 = dir([folderin_cam1 filesep '*.JPG' ]);
%     files_cam2 = dir([folderin_cam2 filesep '*.jpg' ]); 
    
    N = min(numel(i_cam1_cutted),numel(i_cam2_cutted));
    for ll = 1:N
        ll/N
        copyfile([files_cam1(ll + initial_frame_in_led_cam1).folder filesep files_cam1(ll+initial_frame_in_led_cam1).name], [folderout name filesep name '_cam1'])
        copyfile([files_cam2(ll + initial_frame_in_led_cam2).folder filesep files_cam2(ll+initial_frame_in_led_cam2).name], [folderout name filesep name '_cam2'])
    end
    
end
