% close all;
clc, clearvars ;

% Establecer el tamaño y la resolución de la malla del modelo geotécnico
x_tamano = 50;
dx = 1;
y_tamano = -30;
dy = -1;

% Establecer la covarianza y la longitud de correlación espacial
cov = 0.25;
l_ac = 4;

% Nombre de la carpeta y archivo de sismo para simular
folder_name = "suelo_0";
earth_quake_file = "earthquake0.out";

% Definir los cortes que se analizarán en OpenSees (nodos)
cortes = [2, 8];                          % Corte que será analizado en Opensees [nodos]. i.e. corte = 4 es un corte a 3m.

% Obtener la ruta actual del archivo de código en MATLAB
current_path = fileparts(matlab.desktop.editor.getActiveFilename);

% Configurar la ubicación del ejecutable de OpenSees y sus archivos de entrada
opensees_path = join([current_path, '\..\opensees\bin\']);
opensees_executable_file = join([current_path, '\..\opensees\bin\openSees.exe']);

% Crear nombres de carpetas basados en parámetros
tamano_suelo_folder = "x_" + string(x_tamano)+ "--" + "y_" + string(y_tamano) + "--" + "dx_" + string(dx) + "--" + "dy_" + string(dy);
sub_folder = "cov_" + string(cov)+ "--" + "lac_" + string(l_ac);

% Crear una ruta para la carpeta de resultados del suelo
soil_folder = strrep(join([current_path, '\..\..\resultados\', tamano_suelo_folder + "\", sub_folder + "\",folder_name]), " ", "");
soil_file = fullfile( soil_folder, "suelo_espacio.mat");    

% Configurar la ruta de la carpeta de resultados de OpenSees
opensees_results_folder = strrep(join([soil_folder,"\opensees\",extractBefore(earth_quake_file,".out")]), " ", "");

template_model_file = strrep(join([current_path, '\..\..\archivos\suelo_het_00.tcl']), " ", "");
template_earthquake_file = strrep(join([current_path, '\..\..\archivos\earthquake0.OUT']), " ", "");

% Cargar datos del suelo desde un archivo MAT previamente guardado
clear suelo_0
load( soil_file, 'suelo_0')

%% DATOS
% Definir datos geotécnicos iniciales
NF = -5;        %Posición del Nivel freático
gammaw = 10;    % kN/m3
gammasat= 21;   % kN/m3 de la arcilla
GS = 2.55;      % De la arcilla
OCR = 1;        % Asumimos suelo normalmente consolidado
k=1;            % Asumido Braja Das
gravedad = 9.81;    %m/s2 

%% INPUTS PAPER PUBLISHED
% Datos geotécnicos publicados para análisis
cc = [0.56, 1.35, 1.91, 2.08, 2.10, 3.27, 3.80, 5.65];
e50 = [2.05, 2.28, 2.76, 2.93, 2.87, 3.60, 3.97, 4.39];
LL = [87, 120, 148, 196, 204, 234, 300, 348];
LP = [44, 25, 22, 19, 20, 22, 29, 30];

% Crear objetos 'suelo' para cada conjunto de datos geotécnicos
s1 = suelo(LL(1), cc(1), e50(1), LP(1), 0.00039); % gammaref cuando G/Gmax = 0.5.
s2 = suelo(LL(2), cc(2), e50(2), LP(2), 0);
s3 = suelo(LL(3), cc(3), e50(3), LP(3), 0);
s4 = suelo(LL(4), cc(4), e50(4), LP(4), 0);
s5 = suelo(LL(5), cc(5), e50(5), LP(5), 0);
s6 = suelo(LL(6), cc(6), e50(6), LP(6), 0);
s7 = suelo(LL(7), cc(7), e50(7), LP(7), 0);
s8 = suelo(LL(8), cc(8), e50(8), LP(8), 0.019); 


% Loop para procesar cada corte definido
for corte_index = 1:length(cortes)
    corte = cortes(corte_index);
    % Crear una carpeta temporal para trabajar
    tmp_folder = join([current_path, '\..\..\temp\']);
    if ~exist( tmp_folder, "dir")
        mkdir( tmp_folder)
    end

    % Crear un archivo temporal para el sismo
    tmp_earthquake_file = strrep(join([current_path, '\..\..\temp\', earth_quake_file]), " ", "");
    copyfile(template_earthquake_file, tmp_earthquake_file) 
    copyfile(opensees_executable_file, tmp_folder)
    
    % Crear un archivo de entrada temporal para OpenSees
    tmp_file = join([current_path, '\..\..\temp\suelo_het_00.tcl']);
    earthQuakeFile(template_model_file, tmp_file, earth_quake_file)
    
    % Cambiar al directorio temporal
    cd( tmp_folder)
    opensees_arg = [opensees_executable_file, ' '... 
                    tmp_file];                  
    clear opensees_command
    folder_to_test = opensees_results_folder + "\corte_" + string(corte) + "\simulacion";

    if ~exist(folder_to_test, "dir")

        %% PRESIÓN DE POROS, e, ESFUEROS TOTALES Y ESFUERZOS EFECTIVOS
        
        pporos = ones((suelo_0.y_tamano/suelo_0.dy) + 1, (suelo_0.x_tamano/suelo_0.dx) + 1);
        for pporos_index = 1:( suelo_0.y_tamano / suelo_0.dy ) + 1
            pporos(pporos_index, :) = cellfun(@(x) gammaw * ( NF - ( 1 - pporos_index) ) .* x , num2cell(pporos(pporos_index, :)));
        end
        
        esfT = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);       % Matriz Esfuerzos Totales
        esfeff = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);     % Matriz Esfuerzos Effectivos
        vIP = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);

        %% Gmax 
        
        % Gmax_pp en MPa                       
        % Gmax_pp=(16.91.*relv.^-1.728);
        
        %%% Gmax_final
    
        vK0 = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);          % Matriz con los valores de K0 para cada nodo. Ecuación de Braja Das.
        vSigma0 = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);
        esfT = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);
        esfeff = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);
        relv = zeros(( suelo_0.y_tamano / suelo_0.dy) + 1, ( suelo_0.x_tamano / suelo_0.dx) + 1);
        temp = [];    
        temp_hab = [];    
    
        for i = 1:( suelo_0.y_tamano / suelo_0.dy) + 1
    %         i = 1;
            if i == 1
                esfT( i, :) = 0;
            else
                esfT( i, :) = esfT( i - 1, :) + suelo_0.gsat( i - 1, :) * abs( suelo_0.dy);
            end
            
            esfeff(i, :) = esfT(i, :) - pporos(i, :); 
    
            s1 = seteyValue(s1, esfeff(i,:));
            s2 = seteyValue(s2, esfeff(i,:));
            s3 = seteyValue(s3, esfeff(i,:));
            s4 = seteyValue(s4, esfeff(i,:));
            s5 = seteyValue(s5, esfeff(i,:));
            s6 = seteyValue(s6, esfeff(i,:));
            s7 = seteyValue(s7, esfeff(i,:));
            s8 = seteyValue(s8, esfeff(i,:));
            
            temp = suelo_0.vLL(i,:) <= s1.LL;
            suelo_0 = vaciosXNodo( suelo_0, i, s1.seteyValue( esfeff( i, :)).ey .* temp );
            suelo_0 = limitePlastico( suelo_0, i, s1.LP .* temp );
    
            temp = interp1( [ s1.LL; s2.LL; s3.LL; s4.LL; s5.LL; s6.LL; s7.LL; s8.LL], ...
                   [ s1.seteyValue( esfeff( i, 1)).ey; ...
                   s2.seteyValue( esfeff( i, 1)).ey; ...
                   s3.seteyValue( esfeff( i, 1)).ey; ...
                   s4.seteyValue( esfeff( i, 1)).ey; ...
                   s5.seteyValue( esfeff( i, 1)).ey; ...
                   s6.seteyValue( esfeff( i, 1)).ey; ...
                   s7.seteyValue( esfeff( i, 1)).ey; ...
                   s8.seteyValue( esfeff( i, 1)).ey], ...
                   suelo_0.vLL( i, :));
            suelo_0 = vaciosXNodo( suelo_0, i, temp);
    
            temp = interp1([ s1.LL; s2.LL; s3.LL; s4.LL; ...
                   s5.LL; s6.LL; s7.LL; s8.LL], ...
                   [ s1.LP; s2.LP; s3.LP; s4.LP; s5.LP; ...
                   s6.LP; s7.LP; s8.LP], suelo_0.vLL( i, :));
            suelo_0 = limitePlastico( suelo_0, i, temp);
    
            suelo_0.relv = fillmissing(suelo_0.relv, 'constant', s8.seteyValue( esfeff( i, :)).ey);
            suelo_0.vLP = fillmissing(suelo_0.vLP, "constant", s8.LP);
    
            vIP(i, :) = suelo_0.vLL( i, :) - suelo_0.vLP( i, :);
    
            comp_0 = vIP( i, :) <= 40;
            comp_1 = vIP( i, :) > 0;
            temp =  comp_0 .* comp_1;
            vK0( i, :) = (0.4 + 0.007 * ( vIP( i, :))) .* temp;
            
            temp = vK0( i, :) == 0;
            vK0( i, :) = vK0( i, :) + (0.68 + 0.001 * ( vIP( i, :) - 40)) .* temp; 
            
            suelo_0.gsat(i, :) = ( gammaw * ( suelo_0.relv(i, :) + GS)) ./ (1 + suelo_0.relv( i, :));
    
            vSigma0( i, :) = (1/3) * (esfeff( i, :) + 2 * vK0( i, :) .* esfeff( i, :));
    
            suelo_0.Gmax_final( i, :) = ( 16.91 * suelo_0.relv( i, :) .^ ( -1.728)) .* ( vSigma0( i, :) / 50) .^ ( 0.5);
    
            temp = suelo_0.vLL( i, :) <= 95.9;                                      % LL para s1 gammaref.    
            suelo_0.gammaref( i, :) = s1.gammaref * temp;
            
            comp_0 = suelo_0.vLL( i, :) > 95.9;              % LL para s8 gammaref.
            comp_1 = suelo_0.vLL( i, :) <= 370.8;
            temp = comp_0 .* comp_1;
            temp_comp = suelo_0.gammaref( i, :) == 0; 
            suelo_0.gammaref( i, :) = suelo_0.gammaref( i, :) + ( 6.77 * ( 10^-5) * suelo_0.vLL( i, :) - 0.0061) .* temp .* temp_comp;
            
            temp = suelo_0.vLL( i, :) > 370.8;
            temp_comp = suelo_0.gammaref( i, :) == 0; 
            suelo_0.gammaref( i, :) = suelo_0.gammaref( i, :) + s8.gammaref * ( temp_comp .* temp);
    
            suelo_0.Rho( i, :) = suelo_0.gsat( i, :) ./ gravedad;      % Densidad del suelo en Mg/m3
    
            suelo_0.Vs( i, :) = sqrt( ( suelo_0.Gmax_final( i, :) * 1E6) ./ ( suelo_0.Rho( i, :) * 1000));
    
            suelo_0.cohesion( i, :) = repmat( 95 , [ 1, (suelo_0.x_tamano/suelo_0.dx) + 1]);
            suelo_0.nu( i, :) = repmat( 0.45, [ 1, (suelo_0.x_tamano/suelo_0.dx) + 1]);
        end
        
        % cambio de directorio de trabajo a corrida de simulacion
        cd(tmp_folder)
        opensees_command = join(opensees_arg);
        % se corre simulacion
        
        fileGeneration_heterogeneous(suelo_0, corte, y_tamano, dy)

        Status = system(opensees_command);
    
        % se crea estructura de carpetas para almacenamiento de archivos
        if ~exist( opensees_results_folder, "dir") 
            mkdir(opensees_results_folder);
        end
        
        copyfile( tmp_folder + "\*.out", opensees_results_folder + "\corte_" + string(corte) + "\simulacion\heterogeneo" )
        copyfile( tmp_folder + "\*.txt", opensees_results_folder + "\corte_" + string(corte) + "\simulacion\heterogeneo" )
        
        delete(tmp_folder + "*.out")
        delete(tmp_folder + "*.tcl")
        delete(tmp_folder + "*.mat")
        delete(tmp_folder + "*.txt")
        
        % agregar calculo limite superior y limite inferior

        % agregar diferentes analisis comparativo de resultados espectro de frecuencia ..
        % espectro acelarcion y amplitud maxima de señal de aceleracion



    else
        message = "*** LA CARPETA " + ...
                  opensees_results_folder + "\corte_" + string(corte) ...
                  + " YA EXISTE ***";
        disp(message);

    end    

    

end

% Definir coordenadas de muestreo en la malla
px = 0:suelo_0.dx:suelo_0.x_tamano;
py = 0:suelo_0.dy:suelo_0.y_tamano;
[PX, PY] = meshgrid(px, py);

%% GRÁFICAS 2

f1=figure('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf (PX,PY, suelo_0.vLL)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"LL [%]");

f2=figure('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf(PX, PY, suelo_0.Gmax_final)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"Gmax [MPa]");
% set(gca,'FontName','Times New Roman');
% print(f2,'Resultados/Gmax.png','-dpng','-r3000')

f3=figure('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf (PX,PY, suelo_0.gammaref)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"gammaref [-]");
% set(gca,'FontName','Times New Roman');
% print(f3,'Resultados/gammaref.png','-dpng','-r3000')

f4=figure('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf(PX,PY, suelo_0.Vs)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"Vs [m/s]");
% set(gca,'FontName','Times New Roman');
% print(f4,'Resultados/Vs.png','-dpng','-r3000')

f5=figure('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf (PX,PY, suelo_0.relv)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"Relación de Vacíos [-]");
% set(gca,'FontName','Times New Roman');
% print(f5,'Resultados/Relv.png','-dpng','-r3000')

f6=figure ('Units', 'centimeters', 'Position', [0 0 12 9]);
contourf (PX,PY, suelo_0.gsat)
cb=colorbar;
xlabel('x(m)')
ylabel('z(m)')
title (cb,"\gamma sat [kPa]");
% set(gca,'FontName','Times New Roman');
% print(f6,'Resultados/gsat.png','-dpng','-r3000')