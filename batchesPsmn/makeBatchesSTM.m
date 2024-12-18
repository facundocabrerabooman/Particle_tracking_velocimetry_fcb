function makeBatchesRays()
HOME='/home/mbourgoi';
%HOME='/users/mbourgoi/Documents/Recherche';

DATAFOLDER='/Xnfs/site/lagrangian/PTV';
BATCHPATH=[HOME filesep 'LEM/Sander/TracersHIT/batchesSTM'];
WORKDIR=[HOME filesep 'LEM/PTV_LEM/matchingVoxel'];
QUEUE='monointeldeb48';
EXECFILE=['/applis/PSMN/debian7/python/3.5/bin/python3.5 ' HOME filesep 'LEM/PTV_LEM/matchingVoxel/STM.py'];
RESULTSFOLDER=[HOME filesep 'LEM/Sander/TracersHIT/results'];

[status,cmdout]=unix(['find ' RESULTSFOLDER ' -name "rays_*.dat"']);

%%
files=strsplit(cmdout,'\n');
files(end)=[];

for k=1:numel(files)
    batchname=[BATCHPATH filesep 'batch' num2str(k) '.csh']
    if ~isdir(BATCHPATH)
        mkdir(BATCHPATH)
    end
    
    fid = fopen(batchname,'w');
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'module load Base/psmn\n');
        fprintf(fid,'module load python/3.5\n');
        fprintf(fid,'set WORKDIR="%s"\n',WORKDIR);
        fprintf(fid,'cd ${WORKDIR}\n'); 
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'#$ -S /bin/tcsh\n');
        fprintf(fid,'#$ -N jobMatching_%d\n',k);
        fprintf(fid,'#$ -q %s\n',QUEUE);
        fprintf(fid,'#$ -m be\n');
        fprintf(fid,'cd ${WORKDIR}\n');
        fprintf(fid,'%s %s %s %s %s %s %s %s\n',EXECFILE,files{k});  
    fclose(fid);
end




