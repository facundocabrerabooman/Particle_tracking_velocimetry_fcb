DATAFOLDER={'/Xnfs/site/lagrangian/PTV/20161208 - f1.000 - 3125fps','/Xnfs/site/lagrangian/PTV/20161209 - f1.000 - 3125fps','/Xnfs/site/lagrangian/PTV/20161210 - f2.000 - 6250fps','/Xnfs/site/lagrangian/PTV/20161211 - f1.414 - 6250fps','/Xnfs/site/lagrangian/PTV/20161211 - f2.000 - 6250fps - 1','/Xnfs/site/lagrangian/PTV/20161213 - f0.354 - 3125fps'};
BATCHPATH='/home/mbourgoi/LEM/Sander/TracersHIT/batchesH5';
WORKDIR='/home/mbourgoi/LEM/PTV_LEM';
QUEUE='monointeldeb48';
EXECFILE='/home/mbourgoi/LEM/PTV_LEM/run_mcin2h5.sh';
RUNTIMEFOLDER='/applis/PSMN/generic/Matlab/R2015b';
%RESULTSFOLDER='/Xnfs/site/lagrangian/PTV/20161209\ -\ f1.000\ -\ 3125fps';
RESULTSFOLDER={'/Xnfs/site/lagrangian/PTV/20161208\ -\ f1.000\ -\ 3125fps','/Xnfs/site/lagrangian/PTV/20161209\ -\ f1.000\ -\ 3125fps','/Xnfs/site/lagrangian/PTV/20161210\ -\ f2.000\ -\ 6250fps','/Xnfs/site/lagrangian/PTV/20161211\ -\ f1.414\ -\ 6250fps','/Xnfs/site/lagrangian/PTV/20161211\ -\ f2.000\ -\ 6250fps\ -\ 1','/Xnfs/site/lagrangian/PTV/20161213\ -\ f0.354\ -\ 3125fps'};

nbatch=0;
for kfolder=1:numel(DATAFOLDER);
    dirname = dir([DATAFOLDER{kfolder} filesep '*.mcin2']);
    for k=1:numel(dirname)
        nbatch=nbatch+1
        batchname=[BATCHPATH filesep 'batch' num2str(nbatch) '.csh']
        fname=[RESULTSFOLDER{kfolder} filesep dirname(k).name];
        fid = fopen(batchname,'w');
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'set WORKDIR="%s"\n',WORKDIR);
        fprintf(fid,'cd ${WORKDIR}\n');
        fprintf(fid,'#!/bin/tcsh\n');
        fprintf(fid,'#$ -S /bin/tcsh\n');
        fprintf(fid,'#$ -N jobH5%d\n',nbatch);
        fprintf(fid,'#$ -q %s\n',QUEUE);
        fprintf(fid,'#$ -m be\n');
        fprintf(fid,'cd ${WORKDIR}\n');
        fprintf(fid,'%s %s %s %s %s %s %s %s %d %d\n',EXECFILE,RUNTIMEFOLDER,fname);
        fclose(fid);
    end
end