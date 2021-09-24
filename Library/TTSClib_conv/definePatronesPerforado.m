% function  [patronPerf, tasaPerf] = definePatronPerforado
% -------------------------------------------------------------------------
% Definición de los patrones de perforado
% -------------------------------------------------------------------------
% salidas
%  patronPerf   celda con patrones de longitud variable
%  tasaPerf     celda con tasas de bits no perforados: 
%               ( no perforados / totales )
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 9-6-2015  José Tomás Entrambasaguas
% -------------------------------------------------------------------------

function  [patronPerf, tasaPerf] = definePatronesPerforado()

nPatrones = 6;

patronPerf=cell(1, nPatrones);
% 0: perforado  1: no perforado
patronPerf {1} = [1 1]';                                    %  1/1
patronPerf {2} = [1 1  0 1]';                               %  3/4
patronPerf {3} = [1 1  0 1  0 1]' ;                         %  4/6  = 2/3
patronPerf {4} = [1 1  0 1  0 1  0 1  0 1]';                %  6/10 = 3/5
patronPerf {5} = [1 1  0 1  0 1  0 1  0 1  0 1  0 1  0 1]'; %  9/16
patronPerf {6} = [1 1  0 1  0 1  0 1  0 1  0 1  0 1  0 1,...  
                    0 1  0 1  0 1  0 1  0 1  0 1  0 1  0 1]'; % 17/32

tasaPerf = zeros(1,nPatrones);
for kP = 1:nPatrones
  tasaPerf(kP) = sum(patronPerf{kP})/length(patronPerf{kP});
end