function earthQuakeFile(fileTemplate, fileTemporal, earth_quake_file)
    fid  = fopen(fileTemplate,'r');
    f=fread(fid,'*char')';
    fclose(fid);
    string_to_search = "set velocityFile velocityHistory.out";
    string_new = "set velocityFile " + earth_quake_file;
    f = strrep(f,string_to_search,string_new);
    fid  = fopen(fileTemporal,'w');
    fprintf(fid,'%s',f);
    fclose(fid);
end