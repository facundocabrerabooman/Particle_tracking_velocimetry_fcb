function [tracks_lmin,tracks,t_start_stop]=track2d(pos,maxdist,longmin)
%[tracks_lmin,tracks,t_start_stop]=track2d(pos,maxdist,longmin)
% input pour un caméra seul (pos)
%maxdist = dist max d'une particule entre deux images
%longmin = longeur minimum d'une trajectoire
%
tic

tracks=zeros(size(pos,1),8);
tracks(:,1:3)=pos(:,1:3);
tracks(:,4)=0;
tracks(:,5)=1;
%tracks(:,6)=pos(:,4); %particle Diam
%tracks(:,7)=pos(:,5); %intensity au centre (max)
tracks(:,6)=[1:length(pos(:,1))];

% tracks(:,5) dit si les part sont dispo ou non, on demarre avec tout le
% monde a 1;
% l'idée est juste d'affecter le numéro de la trajectoire dans tracks(:,4);

% numeros de trajectoire actif
ind_actif=find(tracks(:,3)==1);
%
tracks(ind_actif,4)=ind_actif;
tracks(ind_actif,5)=0;
numtraj=max(ind_actif);

keep(1:4e6,1) = [1:4e6];      %% used to keep track of length of trajectories, easy elimination of short traj later
keep(1:4e6,2) = 0;            %% everybody has one particle in trajectory in the first frame
                             %%% matrix is pre-allocated arbitrarily
for kk=2:max(tracks(:,3))
    numframe=kk;
    ind_new=find(tracks(:,3)==numframe);
    max_new=max(ind_new);
    min_new=min(ind_new);
        % temporary list of large vector indices to avoid search in
        % a gigantic vector
        dispo0 = [];
        dispo2 = [];
    for ll=1:length(ind_actif)
        %for mm=1:length(ind_new)
        % position de la particule ll dans frame kk-1
        actx=tracks(ind_actif(ll),1);
        acty=tracks(ind_actif(ll),2);  
        
        % on pourrait ajouter un tag: numero dans la trajectoire
        % si tag<=2 : rien
        % si tag==3 actx=actx+vx*dt avec dt=1 ici (3 frames best estimate)
        % si tag==4 actx
        
        
        % numero de traj de cette particule active
        actnum=tracks(ind_actif(ll),4);
        % positions des part frame kk
        newx=tracks(ind_new,1);
        newy=tracks(ind_new,2);
        % calcul de la distance (nearest neighbor..)
        dist=sqrt((actx-newx).^2+(acty-newy).^2);
        % calcul du min
        [dmin,ind_min]=min(dist); 

        if dmin<maxdist
            dispo=tracks(ind_new(ind_min),5);
            if dispo==1
            
                % part dispo donc on change l'indice de dispo en 0
                tracks(ind_new(ind_min),5)=0;
                % on affecte le numeo de traj de la particule active
                tracks(ind_new(ind_min),4)=actnum; 
                keep(actnum,2)= keep(actnum,2)+1;         %lengthen the traj by one
                dispo0 = [dispo0 ind_new(ind_min)];
            elseif dispo==0    
                % la part n'est deja plus dispo, on change don indice en 2
                % car elle peut aller à deux part differentes
                tracks(ind_new(ind_min),5)=2;
                % on remet a zero le lien de trajectoire
                tracks(ind_new(ind_min),4)=0;
                % liste courante des particules 
                dispo2=[dispo2 ind_new(ind_min)];
            end
             
        end  
          
    end    
    
        % definit les particules qui vont etre trackées
        % on garde celles qui sont trouvee 1 seule fois et les non trouvees
        
                ind=find(tracks(min_new:max_new,3)==numframe&tracks(min_new:max_new,5)==0);
                tracks_temp = tracks(min_new:max_new,:);
                ind_actif   = tracks_temp(ind,6);
        
        % les non trouvées se voient affecter un numero de traj
        
                ind=find(tracks(min_new:max_new,3)==numframe&tracks(min_new:max_new,5)==1);
                tracks_temp = tracks(min_new:max_new,:);
                ind_new_part  = tracks_temp(ind,6);

        if isempty(ind_new_part)==0
            for mm=1:length(ind_new_part)
            numtraj=numtraj+1;
            tracks(ind_new_part(mm),4)=numtraj;
            %
            keep(numtraj,1)=numtraj;
            keep(numtraj,2)=1;
            end
        end
      
        ind_actif=[ind_actif;ind_new_part];
end

id=tracks(:,4);
count=0;
ll=1;


ii=find(keep(:,2)>=longmin); %% indice dans tracks des trajectoires >= longmin
tracks_lmin=NaN(length(ii)*1500,size(tracks,2));

for k=1:length(ii);
I=find(id==ii(k));
if length(I)>=longmin
nI=length(I);
tracks_lmin(ll:ll-1+nI,:)=tracks(I,:);
count=count+1;
tracks_lmin(ll:ll-1+nI,4)=count;
%
% t_start_stop used in matching script to avoid searching in giant vector
%
t_start_stop(count,1) = min(tracks_lmin(ll:ll-1+nI,3)); %time(frame) at which the trajectory starts
t_start_stop(count,2) = max(tracks_lmin(ll:ll-1+nI,3)); %time(frame) at which the trajectory finishes
t_start_stop(count,3) = ll; %index in giant matrix at which track starts
ll=ll+nI;
t_start_stop(count,4) = ll-1; %index in giant matrix at which track ends
end

end


tracks_lmin(any(isnan(tracks_lmin),2),:)=[]; % get rid of extraneous lines



disp([int2str(count) ' trajectories longer than ' int2str(longmin) ' frames']);

toc