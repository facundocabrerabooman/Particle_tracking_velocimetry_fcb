function makeBatchesRays()
HOME='/home/mbourgoi'
%HOME='/users/mbourgoi/Documents/Recherche';

DATAFOLDER='/Xnfs/site/lagrangian/PTV';
BATCHPATH=[HOME filesep 'LEM/Sander/TracersHIT/batchesRaysb'];
WORKDIR=[HOME filesep 'LEM/PTV_LEM'];
QUEUE='monointeldeb48';
EXECFILE=[HOME filesep 'LEM/PTV_LEM/run_centers2raysb.sh'];
%RUNTIMEFOLDER='/softs/matlabR2011b';
RUNTIMEFOLDER='/applis/PSMN/generic/Matlab/R2015b';
RESULTSFOLDER=[HOME filesep 'LEM/Sander/TracersHIT/results'];
CALIBFILE=[HOME filesep 'LEM/Sander/TracersHIT/Calibration/calibInterpCfg.mat'];
NmesNcamSep='.';
nstart=1;
nframes=8000;
Ncam='0\ 1\ 2';

[status,cmdout]=unix(['find ' RESULTSFOLDER ' -name "centers_*.dat" -not -path "*done*"']);
cmdout=strrep(cmdout,[NmesNcamSep 'cam0'],'');
cmdout=strrep(cmdout,[NmesNcamSep 'cam1'],'');
cmdout=strrep(cmdout,[NmesNcamSep 'cam2'],'');

%%
files=strsplit(cmdout,'\n');
files(end)=[];
files=unique(files);
filesSplitted=cellfun(@(X)(strsplit(X,filesep)),files,'UniformOutput',false);

% extract folder name
folder=cellfun(@(X)(strrep(strjoin(X(1:end-1),filesep),' ','\ ')),filesSplitted,'UniformOutput',false);
subfolderout=cellfun(@(X)(strrep(strjoin(X(end-1),filesep),' ','\ ')),filesSplitted,'UniformOutput',false);

% extract folder name
fname=cellfun(@(X)(strrep(X(end),' ','\ ')),filesSplitted,'UniformOutput',false);

% remove .dat extension
prefix=cellfun(@(X)(strsplit(char(X),'.dat')),fname,'UniformOutput',false);

%
prefix=cellfun(@(X)(strsplit(char(X(1)),'_')),prefix,'UniformOutput',false);
% generate prefix
prefix=cellfun(@(X)(char(strjoin(X(2:end),'_'))),prefix,'UniformOutput',false);


% extract measurement number
%Nmes=cellfun(@(X)(X(end)),prefix);
folderout=cellfun(@(X)([RESULTSFOLDER filesep X]),subfolderout,'UniformOutput',false);


%%
for k=1:numel(folder)
    batchname=[BATCHPATH filesep 'batch' num2str(k) '.csh']
    if ~isdir(BATCHPATH)
        mkdir(BATCHPATH)
    end
    
    fid = fopen(batchname,'w');
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'set WORKDIR="%s"\n',WORKDIR);
        fprintf(fid,'cd ${WORKDIR}\n'); 
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'#$ -S /bin/tcsh\n');
        fprintf(fid,'#$ -N jobRays%d\n',k);
        fprintf(fid,'#$ -q %s\n',QUEUE);
        fprintf(fid,'#$ -m be\n');
        fprintf(fid,'cd ${WORKDIR}\n');
        fprintf(fid,'%s %s %s %s %s %s %s %s\n',EXECFILE,RUNTIMEFOLDER,...
            folder{k},folderout{k},CALIBFILE,prefix{k},Ncam);  
    fclose(fid);
end




