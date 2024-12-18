function data2=readCentersTxt(fname,varargin)
% data2=readCentersTxt(fname,varargin)

fid = fopen(fname,'r');

Nframes = fscanf(fid,'%d\n',1);
Npread=0;

for kframe=1:Nframes;
    %kframe
    S=fscanf(fid,'%d\n',1);
    Np=fscanf(fid,'%d\n',1);
    data2(kframe).part = Np;
    data=cell2mat(textscan(fid,'%f %f %f %f %f %f\n',Np))';
    %data(1:6,Npread+1:Npread+Np)=dumb';
    Npread=Npread+Np;
    data2(kframe).x=data(1,:);
    data2(kframe).y=data(2,:);
    data2(kframe).I=data(3,:);
    data2(kframe).A=data(4,:);
    %data2(kframe).wx=data(5,:);
    %data2(kframe).wy=data(6,:);
end
fclose(fid);