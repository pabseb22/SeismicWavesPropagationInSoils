% opensees path
% tcl file path

current_path = fileparts(matlab.desktop.editor.getActiveFilename);
opensees_path = join([current_path, '\..\opensees\bin\']);
opensees_executable_file = join([current_path, '\..\opensees\bin\openSees.exe']);

% Es necesario cambiar la ubicacion a donde se encuentra el ejecutable del 
% del opensees para garantizar que no se generen errores al interpretar el 
% contenido del archivo tcl
%cd(opensees_path) 

template_file = join([current_path, '\..\..\archivos\suelo_het_00.tcl']);
tmp_folder = join([current_path, '\..\..\temp\']);
tmp_file = join([current_path, '\..\..\temp\suelo_het_00.tcl']);
copyfile(template_file, tmp_file)
copyfile(opensees_executable_file, tmp_folder)
opensees_arg = [opensees_executable_file, ' '... 
                tmp_file];                  
clear opensees_command

cd(tmp_folder)
opensees_command = join(opensees_arg);
Status = system(opensees_command);
