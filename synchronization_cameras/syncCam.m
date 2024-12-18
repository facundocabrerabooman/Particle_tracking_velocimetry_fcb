 led(1).sig=i_cam1_cutted;
 led(2).sig=i_cam2_cutted;
 freq_led;  %is an input
%%
Nfreq = freq_led;
%Nfilt = Nfreq/2;
Nenv = 1*Nfreq;
% if ne(round(0.9*Nfreq),0.9*Nfreq) %when freq is 5Hz Nenv is not integer and I have problems in envelope
%     Nenv = 1.2*Nfreq;
% end
[B,A]=butter(4,2/freq_led);

for kcam = 1:numel(led)
    % Detect Led ON segments
    s = led(kcam).sig-led(kcam).sig(1);
    s = s/mean(s);
 
    sb = imbinarize(s);
    index_sinuspart = find(sb==1); %fc
    s = led(kcam).sig(index_sinuspart-5); %fc sometimes find peaks doesnt find the firs cause the amplitude is too small 
    %s = led(kcam).sig(sb==1); %before 
    s(end-10:end)=[]; 
    
    led(kcam).istart = find(sb==1,1,'first');
    
    sf=filtfilt(B,A,s);
    
    %[U,L]=envelope(sf,Nenv,'peak'); %envelope is not working for some
    %cases: I move to zero usign the mean instead (next line)
    %sfn = sf-(U+L)/2;
    sfn = sf-mean(sf);
    sfn = sfn/abs(max(sfn));

    %CC = regionprops(abs(sfn)>0.75,abs(sfn),'WeightedCentroid');
    CC = regionprops(abs(sfn)>0.4,abs(sfn),'WeightedCentroid'); %fc - because I am not removing the envelope peaks can be really low
    led(kcam).s = s;
    led(kcam).peaks=vertcat(CC.WeightedCentroid);
    led(kcam).Npeaks=size(led(kcam).peaks,1);
    led(kcam).Nsig=numel(led(kcam).sig);
    
%    clear sf U L sfn CC;
end
%%

Nmax = min([led.Npeaks]);
T1 = led(1).peaks(2:Nmax)+led(1).istart-1;

II = 1:min([led.Nsig]);

led(1).I=II;
led(1).I1=II;

for kcam = 2:numel(led)
    Tk=led(kcam).peaks(2:Nmax)+led(kcam).istart-1;
    [PP,SS]=polyfit(T1,Tk,1); % fits timesteps of camera k against those of camera 1
    Ik = round(polyval(PP,II)); % Ik is the timestep of camera k that corresponds to timestep II of camera 1
    Ik(Ik>led(kcam).Nsig)=[];
    
    [C,IA,IC] = unique(Ik);
    
    I=II(IA); % timesteps of camera 1 that correspond to unique instances of the timesteps of camera k (Ik)
    ii = find((C>0)&(I>0));
    led(kcam).I=C(ii); %timesteps of camera k 
    led(kcam).I1=I(ii);% corresponding timesteps in camera 1
end

%better names
i_cam1_cutted_sync = led(1).sig(led(2).I1);
i_cam2_cutted_sync = led(2).sig(led(2).I);

