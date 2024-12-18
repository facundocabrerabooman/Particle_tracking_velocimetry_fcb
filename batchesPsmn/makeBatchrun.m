files=dir([pwd filesep 'batch*.csh']);

fid = fopen ('batchrun','w');
    for k=1:numel(files)
        fprintf(fid,'qsub %s\n',files(k).name);
    end
fclose(fid)