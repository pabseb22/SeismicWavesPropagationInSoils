function fileGeneration(suelo, corte, x_tamano, dx)
    % crea archivos .out requeridos para evaluacion de modelo con opensees
    %% Descripcion
    % Permite generar los archivos que contienen las propiedades de los 
    % elementos que definen el modelo del suelo requeridos por el archivo
    % tcl empleado como plantilla para correr la simulacion del modelo 
    % en opensees
    %% Syntax:
    %    fileGeneration(suelo, corte, x_tamano, dx)
    %% Input
    % Valores de entrada requeridos:
    %   suelo               - objeto que contiene la informacion requerida 
    %                         y que define las propiedades del suelo
    %   corte               - Arreglo de datos de los puntos en el eje x 
    %                         sobre los cuales se desea realizar el corte.
    %   x_tamano            - tamaño total en el eje y
    %   dx                  - discretizacion del eje y

    % verificar si se pueden emplear parametros definidos en el tamano del
    % suelo generado considerando el eje x
    
    x=0:abs(dx):abs(x_tamano); x=x';
    xint=abs(dx/2):abs(dx):abs(x_tamano)-abs(dx/2); xint=xint';        % int = intermedio
    xgrafica = flip(xint);
    
    % rho
    Rhoinv = interpolationPoints( x, suelo.Rho( :, corte), xint);
    writeFile('rho0.txt', 'rho', Rhoinv)

    % Vs0
    Vsinv = interpolationPoints( x, suelo.Vs( :, corte), xint);
    writeFile('Vs0.txt', 'Vs', Vsinv)
        
    % nu0
    nuinv = interpolationPoints( x, suelo.nu( :, corte), xint);
    writeFile('nu0.txt', 'nu', nuinv)

    %cohesion
    cohesioninv = interpolationPoints( x, suelo.cohesion( :, corte), xint);
    writeFile('cohesion.txt', 'cohesion', cohesioninv)    
    
    % gammaref
    gammarefinv = interpolationPoints( x, suelo.gammaref( :, corte), xint);
    
    
    %% CURVAS DE DEGRADACIÓN
    
    gamma =[ 1.00E-6; 3.16E-6; 1.00E-5; 3.16E-5; 1.00E-4; 3.16E-4; 1.00E-3; 3.16E-3; 1.00E-2; 3.16E-2; 1.00E-1];
    gamma = gamma';
    degradacionG = [];
    aux = [];
    
    nombre_archivo = sprintf('curvasdeg.txt');
    archivo = fopen(nombre_archivo, 'w');
    for k = 1:length( gammarefinv)
        for i = 1:length( gamma)
            vgammaref = gammarefinv( k);
            if i == 1
                degradacionG( i) = 1;
            else
                degradacionG( i) = 1 / ( 1 + ( gamma( i) / vgammaref)^0.736);
            end
        aux( i) = degradacionG( i);
        end
        datos = [ gamma, aux];
        line = sprintf('nDMaterial PressureIndependMultiYield %d 2 $rho(%d) $G(%d) $bulk(%d) $cohesion(%d) $gammaPeak $phi $refPress $pressCoeff  -11\\', k,k,k,k,k);
        fprintf(archivo, '%s\n', line);
        fprintf(archivo, '\t\t');
        for j = 1:length (gamma)
            fprintf(archivo, '%d %d ', gamma(j), aux(j));
        end
        fprintf(archivo, '\n\n');
    end
    fclose(archivo);
    degradacionG = degradacionG';
    
%     os_cohesion = fopen('cohesion.txt', 'w');
%     for i = 1:length(cohesioninv)
%         str = ['set cohesion(' num2str(i) ') ' num2str(cohesioninv(i))];
%         fprintf(os_cohesion, '%s\n', str);
%     end
%     fclose(os_cohesion);
    
%     %% CAMPO HOMOGÉNEO
%     
%     layers = abs(dimy / dy);
%     Pi = 1/layers;
%     
%     % Corte que será analizado en Opensees [nodos]. i.e. corte = 4 es un corte a 3m. # definido en la preparación de vectores
%     
%     % Gmax_final
%     y=Gmax_final(:,corte);
%     Gmax_finalint=interp1(x,y,xint);
%     Gmax_finalinv = flip(Gmax_finalint);
%     
%     %% LÍMITE INFERIOR
%     
%     %%% G*
%     G_aux =0;
%     for k=1: layers
%         G_aux= G_aux + Pi/Gmax_finalinv(k);
%     end
%     Gmax_ai = 1/G_aux;  
%     
%     vGmax_ai = [];
%     for i=1:layers
%         vGmax_ai (i)= Gmax_ai; 
%     end
%     vGmax_ai = vGmax_ai';
%     
%     %%% gammaref*
%     gammaref_aux =0;
%     for k=1: layers
%         gammaref_aux= gammaref_aux + Pi/gammarefinv(k);
%     end
%     gammaref_ai = 1/gammaref_aux;
%     
%     vgammaref_ai = [];
%     for i=1:layers
%             vgammaref_ai (i)= gammaref_ai; 
%     end
%     vgammaref_ai = vgammaref_ai';
%     
%     %%% Rho*
%     Rho_aux =0;
%     for k=1: layers
%         Rho_aux= Rho_aux + Pi/Rhoinv(k);
%     end
%     Rho_ai = 1/Rho_aux;
%     
%     vRho_ai = [];
%     for i=1:layers
%             vRho_ai (i)= Rho_ai; 
%     end
%     vRho_ai = vRho_ai';
%     
%     %%% Vs*
%     Vs_ai = sqrt((Gmax_ai*1E6)/(Rho_ai*1000));
%     
%     vVs_ai = [];
%     for i=1:layers
%             vVs_ai (i)= Vs_ai; 
%     end
%     vVs_ai = vVs_ai';
%     
%     
%     %% LÍMITE INFERIOR - CURVAS DE DEGRADACION
%     
%     gamma =[1.00E-6; 3.16E-6; 1.00E-5; 3.16E-5; 1.00E-4; 3.16E-4; 1.00E-3; 3.16E-3; 1.00E-2; 3.16E-2; 1.00E-1];
%     gamma = gamma';
%     degradacionG_ai = [];
%     aux = [];
%     
%     mkdir('LimiteInf')
%     nombre_archivo = sprintf('LimiteInf/curvasdeg_ai.txt');
%     archivo = fopen(nombre_archivo, 'w');
%     for k=1: length (vgammaref_ai)
%         for i=1: length (gamma)
%             vgammaref=vgammaref_ai(k);
%             if i==1
%                 degradacionG_ai (i)=1;
%             else
%                 degradacionG_ai (i)= 1/(1+(gamma (i)/vgammaref)^0.736);
%             end
%         aux(i)=degradacionG_ai (i);
%         end
%         datos = [gamma, aux];
%         line = sprintf('nDMaterial PressureIndependMultiYield %d 2 $rho(%d) $G(%d) $bulk(%d) $cohesion(%d) $gammaPeak $phi $refPress $pressCoeff  -11\\', k,k,k,k,k);
%         fprintf(archivo, '%s\n', line);
%         fprintf(archivo, '\t\t');
%         for j = 1:length (gamma)
%             fprintf(archivo, '%d %d ', gamma(j), aux(j));
%         end
%         fprintf(archivo, '\n\n');
%     end
%     fclose(archivo);
%     degradacionG_ai = degradacionG_ai';
%     
%     %% LÍMITE INFERIOR - VECTORES OS
%     
%     os_rho0_ai = fopen('LimiteInf/rho0_ai.txt', 'w');
%     for i = 1:length(vRho_ai)
%         str = ['set rho(' num2str(i) ') ' num2str(vRho_ai(i))];
%         fprintf(os_rho0_ai, '%s\n', str);
%     end
%     fclose(os_rho0_ai);
%     
%     
%     os_Vs0_ai = fopen('LimiteInf/Vs0_ai.txt', 'w');
%     for i = 1:length(vVs_ai)
%         str = ['set Vs(' num2str(i) ') ' num2str(vVs_ai(i))];
%         fprintf(os_Vs0_ai, '%s\n', str);
%     end
%     fclose(os_Vs0_ai);
%     
%     
%     os_nu0 = fopen('LimiteInf/nu0.txt', 'w');
%     for i = 1:length(nuinv)
%         str = ['set nu(' num2str(i) ') ' num2str(nuinv(i))];
%         fprintf(os_nu0, '%s\n', str);
%     end
%     fclose(os_nu0);
%     
%     
%     os_cohesion = fopen('LimiteInf/cohesion.txt', 'w');
%     for i = 1:length(cohesioninv)
%         str = ['set cohesion(' num2str(i) ') ' num2str(cohesioninv(i))];
%         fprintf(os_cohesion, '%s\n', str);
%     end
%     fclose(os_cohesion);
%     
%     
%     
%     %% LÍMITE SUPERIOR
%     
%     %%% G*
%     Gmax_as =0;
%     for k=1: layers
%         Gmax_as= Gmax_as + Pi*Gmax_finalinv(k);
%     end
%     vGmax_as = [];
%     for i=1:layers
%         vGmax_as (i)= Gmax_as; 
%     end
%     vGmax_as = vGmax_as';
%     
%     %%% gammaref*
%     gammaref_as =0;
%     for k=1: layers
%         gammaref_as= gammaref_as + Pi*gammarefinv(k);
%     end
%     vgammaref_as = [];
%     for i=1:layers
%             vgammaref_as (i)= gammaref_as; 
%     end
%     vgammaref_as = vgammaref_as';
%     
%     %%% Rho*
%     Rho_as =0;
%     for k=1: layers
%         Rho_as= Rho_as + Pi*Rhoinv(k);
%     end
%     vRho_as = [];
%     for i=1:layers
%             vRho_as (i)= Rho_as; 
%     end
%     vRho_as = vRho_as';
%     
%     %%% Vs*
%     Vs_as = sqrt((Gmax_as*1E6)/(Rho_as*1000));
%     vVs_as = [];
%     for i=1:layers
%             vVs_as (i)= Vs_as; 
%     end
%     vVs_as = vVs_as';

end

function tmp_variable = interpolationPoints( x, y, xint)
    tmp_variable = interp1( x, y, xint);
    tmp_variable = flip( tmp_variable);    
end

function writeFile(file_path, variable_string_name, variable_to_write)
    % crea el archivo definido por "file_path" con el contenido de la
    % variable definida en "variable_to_write"

    tmp_file = fopen(file_path, 'w');
    for i = 1:length( variable_to_write)
        str = join(['set ', variable_string_name, '(', num2str(i), ') ', num2str( variable_to_write(i))]);
        fprintf(tmp_file, '%s\n', str);
    end
    fclose(tmp_file);
end