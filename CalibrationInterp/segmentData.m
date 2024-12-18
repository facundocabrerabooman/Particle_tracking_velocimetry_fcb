function seg=segmentData(data,col);

%
% seg=segmentData(data,col);
%
% Segments the data (MxN) based on the col number (1<=col<=N)
%
% for example if data contains particle tracking data, with data(:,end) 
% being the track number, seg will be a structure where seg(k).data 
% contains the data for track #k

segData=data(:,col);

[Ns,Is]=sort(segData);
data=data(Is,:);

segId= bwconncomp(1-abs(diff(Ns))>=1);
I0=cellfun(@(X)(X(1)),segId.PixelIdxList);
Lseg=cellfun(@numel,segId.PixelIdxList);
[segDataU]=unique(segData(Is));

for kseg=1:segId.NumObjects
        seg(kseg).data=data(I0(kseg):I0(kseg)+Lseg(kseg),:);
end
