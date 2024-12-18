function centers=findcenters(Im)

% 03/2019 - Thomas Basset

se=strel('disk',5); %opening to remove big elements
imo=imopen(Im,se);
Im=imsubtract(Im,imo);

Im(Im<6)=0; %thresholding to remove the background

se=strel('disk',1); %opening to remove little elements
Im=imopen(Im,se);

%detection
Imbw=imbinarize(Im);
part=bwconncomp(Imbw,4);
bigpart=[];
thres=30; %size threshold for overlapping
for k=1:part.NumObjects
    if length(part.PixelIdxList{k})>thres
        bigpart=[bigpart k]; %index of particles bigger than thres
    end
end
imbigpart=false(size(Imbw));
for k=1:length(bigpart)
    imbigpart(part.PixelIdxList{bigpart(k)})=true;
end
cnt=regionprops(imbigpart,'Centroid');
cnt=vertcat(cnt.Centroid);
if ~isempty(cnt) %if there are actually particles bigger than thres
    s=15; %zone size to modify with imregionalmax
    for k=1:length(cnt(:,1))
        x0=round(cnt(k,1));
        y0=round(cnt(k,2));
        if x0<=s
            xlimd=1;
        else
            xlimd=x0-s;
        end
        if x0>size(Imbw,2)-s
            xlimu=size(Imbw,2);
        else
            xlimu=x0+s;
        end
        if y0<=s
            ylimd=1;
        else
            ylimd=y0-s;
        end
        if y0>size(Imbw,1)-s
            ylimu=size(Imbw,1);
        else
            ylimu=y0+s;
        end
        imtemp=Im(ylimd:ylimu,xlimd:xlimu);
        Imbw(ylimd:ylimu,xlimd:xlimu)=imregionalmax(imtemp);
    end
end
cnt=regionprops(Imbw,'Centroid','MajorAxisLength','MinorAxisLength','Area');

c=round(vertcat(cnt.Centroid));
int=zeros(length(c),1); %intensity
for k=1:length(c)
    int(k)=Im(c(k,2),c(k,1));
end

centers=[vertcat(cnt.Centroid) vertcat(cnt.MajorAxisLength) vertcat(cnt.MinorAxisLength) vertcat(cnt.Area) int];

end