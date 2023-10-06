classdef suelo
    properties
        LL;
        cc;
        e0;
        ey;
        e50;
        LP;
        gammaref;
%         sete0
%         setey
    end
    methods
        function self = suelo(LL, cc, e50, LP, gammaref)
            self.LL = LL;
            self.cc = cc;
            self.e50 = e50;
            self.LP = LP;
            self.gammaref = gammaref;
            self.e0 = self.e50 + self.cc * log10(50/4);
        end

        function self = seteyValue( self, sigma)
            self.ey = self.e0 - self.cc .* log10( sigma / 4);
        end

%         function self = parametrosComportamiento(self, LL, cc, )
% 
%         end
%         function display
%             disp(test)
%         end
    end
end
