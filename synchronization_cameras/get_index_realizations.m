%% GET INDEX TO CUT VIDEO INTO PIECES WITH ONE REALIZATION
% index for cut entire video are in data_intensity_led(#).pks and .locs
function get_index_realizations(folderled, name)

    load([folderled name '.mat']),
    data_intensity_led(1).i_cam1 = [intensities.cam1];data_intensity_led(2).i_cam2 = [intensities.cam2]; clear intensities
    
    diff_signal_cam1 = diff(data_intensity_led(1).i_cam1);
    diff_signal_cam2 = diff(data_intensity_led(2).i_cam2);
    [pks, locs] = findpeaks(abs(diff_signal_cam1),'MinPeakProminence',max(diff_signal_cam1)/20,'MinPeakDistance',500);
    data_intensity_led(1).pks = pks;data_intensity_led(1).locs = locs;
    [pks, locs] = findpeaks(abs(diff_signal_cam2),'MinPeakProminence',max(diff_signal_cam2)/20,'MinPeakDistance',500);
    data_intensity_led(2).pks = pks;data_intensity_led(2).locs = locs; clear pks locs
    
    %%%plots to check
    figure(20), plot(data_intensity_led(2).i_cam2,'g'), hold on, plot(data_intensity_led(1).i_cam1,'r'), title('original sans sync')
    hold on, plot(data_intensity_led(1).locs,data_intensity_led(1).pks,'r*')
    hold on, plot(data_intensity_led(2).locs,data_intensity_led(2).pks,'g*')
    %%%
    save([folderled 'led_intensity_peaks'], 'data_intensity_led')
end
