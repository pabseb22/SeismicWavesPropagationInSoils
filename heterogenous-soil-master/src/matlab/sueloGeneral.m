classdef sueloGeneral
    % Se define o0bjeto que permite almacenar las propiedades del suelo
    % heterogeneo, asi como los parametros que definen su dimension.

    properties
        x_tamano
        y_tamano
        dx % Discretización en x (m)
        dy % Discretización en y (m)
        ll_medio                % Valor medio del LL
        cov                    % COV = 0.3 (JP)    COV = 0.25 (Muñoz & Caicedo)
        desv         % Desviación estándar (%)
        l_ac                     % Longitud de autocorrelación (m)
        vLL
        relv
        vLP
        Rho
        Vs
        nu
        cohesion
        gammaref
        Gmax_final        
        gsat
    end
    methods
        function self = sueloGeneral(x_tamano, dx, y_tamano, dy, ...
                                     ll_medio, cov, l_ac, vLL)
            % se inicializa objeto que define la variable en donde se almacenan
            % las propiedades y dimensiones del suelo heterogeneo.
            %% Descripcion
            % Permite crear un objeto que contienen toda la infomacion que
            % define a un suelo heterogeneo creado aleatoriamente
            %% Syntax:
            %    nombre_suelo = sueloGeneral(x_tamano, dx, y_tamano, dy, ...
                                     ll_medio, cov, l_ac, vLL)
            %% Input
            % Valores de entrada requeridos:
            %   nombre_suelo        - objeto que contiene la informacion requerida 
            %                         y que define las propiedades del
            %                         suelo heterogeneo
            %   x_tamano            - tamaño total en el eje y
            %   dx                  - discretizacion del eje y
            %   y_tamano            - tamaño total en el eje y
            %   dy                  - discretizacion del eje y
            %   ll_medio            - Limite liquido medio.
            %   cov                - covarianza.
            %   l_ac               - longitud de autocorrelacion.
            %   vll                - matriz de limite liquido.
            
        
            % verificar si se pueden emplear parametros definidos en el tamano del
            % suelo generado considerando el eje x
            self.x_tamano = x_tamano;
            self.dx = dx;
            self.y_tamano = y_tamano;
            self.dy = dy;
            self.ll_medio = ll_medio;
            self.cov = cov;
            self.desv = self.cov * self.ll_medio;
            self.l_ac = l_ac;
            self.vLL = vLL;
            self.relv = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.vLP = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.Rho = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.Vs = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.nu = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.cohesion = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.gammaref = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.Gmax_final = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
            self.gsat = zeros(( self.y_tamano / self.dy) + 1, ( self.x_tamano / self.dx) + 1);
        end

        function self = vaciosXNodo( self, i, s)
            m_0 = self.relv( i, :) == 0;
            m_1 = isnan(self.relv( i, :));
            self.relv(i,:) = self.relv(i,:) + s .* xor( m_0, m_1 );
        end

        function self = limitePlastico( self, i, s)
            m_0 = self.vLP(i,:) == 0;
            m_1 = isnan(self.vLP(i,:));
            self.vLP( i, :) = self.vLP( i, :) + s .* xor( m_0, m_1 );
        end

    end
end
