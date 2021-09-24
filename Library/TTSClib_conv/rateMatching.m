% -------------------------------------------------------------------------
% function NbitsRM = rateMatching(Nbits,M,tasaCod,patronPerforado)	  
% -------------------------------------------------------------------------
% Ajusta la duración de la simulación a un numero entero de símbolos
%    y de patrones de perforado 
% -------------------------------------------------------------------------
% Entradas
%    Nbits     duracion deseada de la simulacion 
%              (numero de bits de mensaje sin codificar)
%    M         numero de simbolos del alfabeto M-QAM
%    tasaCod   tasa de codificacion
%    patronPerforado   vector binario con patron de perforado
% -------------------------------------------------------------------------
% Salidas
%    NbitsRM     duracion de la simulacion ajustada a 
%                 numero entero de simbolos y de patrones de perforado 
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 28-5-2015  José Tomás Entrambasaguas
% -------------------------------------------------------------------------

function NbitsRM = rateMatching(Nbits, M, tasaCod, patronPerforado)	   

NbitsPerfBloque  = lcm(sum(patronPerforado), log2(M));
NbitsNoCodBloque = NbitsPerfBloque * tasaCod;
NbitsRM          = NbitsNoCodBloque * round(Nbits/NbitsNoCodBloque);
