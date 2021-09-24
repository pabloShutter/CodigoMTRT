% -------------------------------------------------------------------------
% function NbitsRM = rateMatching(Nbits,M,tasaCod,patronPerforado)	  
% -------------------------------------------------------------------------
% Ajusta la duraci�n de la simulaci�n a un numero entero de s�mbolos
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
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 28-5-2015  Jos� Tom�s Entrambasaguas
% -------------------------------------------------------------------------

function NbitsRM = rateMatching(Nbits, M, tasaCod, patronPerforado)	   

NbitsPerfBloque  = lcm(sum(patronPerforado), log2(M));
NbitsNoCodBloque = NbitsPerfBloque * tasaCod;
NbitsRM          = NbitsNoCodBloque * round(Nbits/NbitsNoCodBloque);
