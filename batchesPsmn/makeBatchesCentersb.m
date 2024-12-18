function makeBatches()

DATAFOLDER='/Xnfs/site/lagrangian/PTV';
BATCHPATH='/home/mbourgoi/LEM/Sander/TracersHIT/batchesb';
WORKDIR='/home/mbourgoi/LEM/PTV_LEM';
QUEUE='monointeldeb48';
EXECFILE='/home/mbourgoi/LEM/PTV_LEM/run_CenterFinding2Db.sh';
RUNTIMEFOLDER='/applis/PSMN/generic/Matlab/R2015b';
RESULTSFOLDER='/home/mbourgoi/LEM/Sander/TracersHIT/results';
NmesNcamSep='_';
nstart=1;
nframes=8000;

[status,cmdout]=unix(['find ' DATAFOLDER ' -name "*.mcin2" -not -path "*alibra*"']);
%%
files=strsplit(cmdout,'\n');
files(end)=[];
 
filesSplitted=cellfun(@(X)(strsplit(X,filesep)),files,'UniformOutput',false);
% extract folder name
folder=cellfun(@(X)(strrep(strjoin(X(1:end-1),filesep),' ','\ ')),filesSplitted,'UniformOutput',false);
subfolderout=cellfun(@(X)(strrep(strjoin(X(end-1),filesep),' ','\ ')),filesSplitted,'UniformOutput',false);
% extract folder name
fname=cellfun(@(X)(strrep(X(end),' ','\ ')),filesSplitted,'UniformOutput',false);
% remove .mcin2 extension
fname=cellfun(@(X)(strsplit(char(X(1)),'.mcin2')),fname,'UniformOutput',false);
fname=cellfun(@(X)(char(X(1))),fname,'UniformOutput',false);

%prefix=cellfun(@(X)(strsplit(char(X),'.cam')),fname,'UniformOutput',false);%

% extract cam number
%Ncam=cellfun(@(X)(['cam' char(X(2))]),prefix,'UniformOutput',false);
%
%prefix=cellfun(@(X)(strsplit(char(X(1)),'_')),prefix,'UniformOutput',false);%
% extract measurement number
%Nmes=cellfun(@(X)(X(end)),prefix);
folderout=cellfun(@(X)([RESULTSFOLDER filesep X]),subfolderout,'UniformOutput',false);

% generate prefix
%prefix=cellfun(@(X)([char(strjoin(X(1:end-1),'_')) '_']),prefix,'UniformOutput',false);
%%
% Kspace=[strfind(cmdout,'.mcin2')];
% 
% fnametmp=cmdout(1:Kspace(1)-1);
% ktmp=strfind(fnametmp,'/');
% klast=ktmp(end);
% folder{1}=fnametmp(1:klast-1);
% fname=fnametmp(klast+1:end);
% ktmp=strfind(fname,'_');
% klast=ktmp(end);
% Ncam{1}=fname(klast+1:end);
% prefix{1}=fname(1:ktmp(end-1)-1);
% Nmes{1}=fname(ktmp(end-1)+1:klast-1);
% 
% for k=1:numel(Kspace)-1
%     Nsuffix=6;
%     fnametmp=cmdout(Kspace(k)+Nsuffix:Kspace(k+1)-1);
%     ktmp=strfind(fnametmp,'/');
%     klast=ktmp(end);
%     folder{k+1}=fnametmp(1:klast-1);
%     fname=fnametmp(klast+1:end);
%     ktmp=strfind(fname,'_');
%     klast=ktmp(end);
%     Ncam{k+1}=fname(klast+1:end);
%     prefix{k+1}=fname(1:ktmp(end-1)-1);
%     Nmes{k+1}=fname(ktmp(end-1)+1:klast-1);
% end

for k=1:numel(folder)
    fname{k}
    batchname=[BATCHPATH filesep 'batch' num2str(k) '.csh']
    fid = fopen(batchname,'w');
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'set WORKDIR="%s"\n',WORKDIR);
        fprintf(fid,'cd ${WORKDIR}\n'); 
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'#$ -S /bin/tcsh\n');
        fprintf(fid,'#$ -N job%s\n',fname{k});
        fprintf(fid,'#$ -q %s\n',QUEUE);
        fprintf(fid,'#$ -m be\n');
        fprintf(fid,'cd ${WORKDIR}\n');
        fprintf(fid,'%s %s %s %s %s %d %d\n',EXECFILE,RUNTIMEFOLDER,...
            folder{k},folderout{k},fname{k},nstart,nframes);  
    fclose(fid);
end




